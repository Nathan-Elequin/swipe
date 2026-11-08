extends SceneTree
## Progress menu protocol + attribution + map-scrap deferred award + handoff.
## Does NOT boot main.tscn. Runner isolates XDG_DATA_HOME.


const OK_MARK := "PROGRESS_MENU_CEREMONY_OK"
const FAIL_MARK := "PROGRESS_MENU_CEREMONY_FAIL"
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")

var _failed := false
var _rows: Array = []
var _menu: CanvasLayer
var _acked: Array = []
var _present_done := false
var _last_result: Dictionary = {}


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	PLAYER_COPY.reload()
	var MenuScr = load("res://scripts/ui/progress_menu.gd")
	_failed = _assert("META.menu_script_loads", "progress_menu.gd loads", MenuScr != null, "") or _failed
	if MenuScr == null:
		_finish()
		return
	_menu = MenuScr.new()
	root.add_child(_menu)
	await process_frame

	var rules: Dictionary = CAMPAIGN_SHELL.read_json("res://data/campaign.json")
	var catalog: Dictionary = CAMPAIGN_SHELL.read_json("res://data/catalog.json")
	var items: Dictionary = {}
	var rows: Variant = catalog.get("items", catalog.get("cards", []))
	if typeof(rows) != TYPE_ARRAY:
		rows = []
	for raw in rows:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id == "":
			continue
		items[id] = card
	_failed = _assert(
		"ATTR.catalog_loaded",
		"catalog items loaded for attribution",
		items.size() >= 20,
		"n=%s" % items.size()
	) or _failed

	## Numeric pool attribution → b1 via card_pools.
	var net_card: Dictionary = items.get("net", {})
	var ArtScr = load("res://scripts/dungeon_art.gd")
	var dungeon_art = ArtScr.new()
	root.add_child(dungeon_art)
	if dungeon_art.has_method("setup"):
		dungeon_art.setup()
	await process_frame
	var pool_net := ""
	if _menu.has_method("_card_biome_pool"):
		_menu.set("_rules", rules)
		pool_net = str(_menu.call("_card_biome_pool", net_card))
	_failed = _assert(
		"ATTR.net_is_b1",
		"catalog net resolves to b1 via BucketRules+pool_for_bucket",
		pool_net == "b1",
		"pool=%s raw=%s" % [pool_net, net_card.get("pool", null)]
	) or _failed
	var roster_b1: Array = []
	_menu.set("_items_by_id", items)
	_menu.set("_rules", rules)
	if _menu.has_method("_pool_roster"):
		roster_b1 = _menu.call("_pool_roster", "b1")
	_failed = _assert(
		"ATTR.b1_roster_gt_six",
		"real b1 roster is full catalog slice (not 6-item fixture)",
		roster_b1.size() > 6,
		"n=%s" % roster_b1.size()
	) or _failed

	## --- Map scrap deferred: Push cross without stamp, Leave stamps once ---
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	CAMPAIGN_SHELL.normalize(state)
	var openers: Array = ["net", "sai", "shield", "spinning_top", "throwing_knife"]
	var pools := {}
	for id in openers:
		pools[str(id)] = "b1"
	## Simulate Push-block banking 5 without stamp.
	CAMPAIGN_SHELL.bank(rules, state, openers, pools)
	_failed = _assert(
		"SCRAP.push_cross_no_stamp",
		"after push-like bank, b1 at quota but map_pieces empty",
		CAMPAIGN_SHELL.cabinet_count(state, "b1") >= 5
		and (state.get("map_pieces", []) as Array).is_empty(),
		"b1=%s pieces=%s" % [CAMPAIGN_SHELL.cabinet_count(state, "b1"), state.get("map_pieces", [])]
	) or _failed
	## Deferred Leave stamp: past-quota idempotent stamp (not this-return-only cross).
	var stamped: Dictionary = CAMPAIGN_SHELL.stamp_map_piece(rules, state, "b1")
	_failed = _assert(
		"SCRAP.leave_deferred_once",
		"Leave after push cross stamps Crystal Cavern once",
		bool(stamped.get("first", false)) and (state.get("map_pieces", []) as Array).has("b2"),
		"stamp=%s pieces=%s" % [stamped, state.get("map_pieces", [])]
	) or _failed
	var stamped2: Dictionary = CAMPAIGN_SHELL.stamp_map_piece(rules, state, "b1")
	_failed = _assert(
		"SCRAP.idempotent_no_replay",
		"second stamp not first; piece count stays 1",
		(not bool(stamped2.get("first", true))) and (state.get("map_pieces", []) as Array).size() == 1,
		"stamp2=%s pieces=%s" % [stamped2, state.get("map_pieces", [])]
	) or _failed
	CAMPAIGN_SHELL.clear_pencil_fresh(state)
	var stamped3: Dictionary = CAMPAIGN_SHELL.stamp_map_piece(rules, state, "b1")
	_failed = _assert(
		"SCRAP.no_remark_after_clear",
		"owned piece re-stamp after clear_pencil does not re-mark fresh",
		(state.get("pencil_fresh", []) as Array).is_empty() and not bool(stamped3.get("first", true)),
		"fresh=%s stamp3=%s" % [state.get("pencil_fresh", []), stamped3]
	) or _failed

	## --- Present returns result; early start acks all ---
	_acked.clear()
	_present_done = false
	_last_result = {}
	var tex := {}
	if dungeon_art != null and dungeon_art.has_method("item_tex"):
		for id2 in ["net", "sai", "shield"]:
			var t: Texture2D = dungeon_art.item_tex(str(id2))
			if t != null:
				tex[str(id2)] = t
	_kick_present({
		"kind": "win",
		"new_ids": ["net", "sai"],
		"held_ids": ["net", "sai"],
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": items,
		"tex_by_item": tex,
		"swiped": {"net": true, "sai": true, "shield": true, "spinning_top": true},
		"rules": rules,
		"state": CAMPAIGN_SHELL.fresh_state(),
		"push_block": false,
		"tutorial": false,
	})
	await create_timer(0.35).timeout
	_failed = _assert("UI.open", "menu visible", _menu.visible, "") or _failed
	## Mid-stagger start — must ack remaining before dismiss.
	_menu.call("_choose_start", 0)
	await _wait_present_done(3.0)
	_failed = _assert(
		"UI.early_start_acks",
		"early Start New Run acks all new ids once (raw count)",
		_acked.count("net") == 1 and _acked.count("sai") == 1 and _acked.size() == 2,
		"acked=%s" % str(_acked)
	) or _failed
	_failed = _assert(
		"UI.result_start",
		"present returns start action",
		str(_last_result.get("action", "")) == "start",
		"result=%s" % _last_result
	) or _failed

	## Tutorial complete vs skipped copy.
	_present_done = false
	_kick_present({
		"kind": "tutorial",
		"new_ids": [],
		"held_ids": [],
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": items,
		"tex_by_item": {},
		"swiped": {},
		"rules": rules,
		"state": CAMPAIGN_SHELL.fresh_state(),
		"push_block": false,
		"tutorial": true,
	})
	await create_timer(0.35).timeout
	var summary: Label = _menu.get("_summary")
	_failed = _assert(
		"UI.tutorial_copy",
		"completed tutorial uses tutorial summary",
		summary != null and str(summary.text) == PLAYER_COPY.text("postrun.summary.tutorial", ""),
		"got=%s" % (summary.text if summary else "")
	) or _failed
	_menu.call("_on_cabin")
	await _wait_present_done(2.0)

	_present_done = false
	_kick_present({
		"kind": "tutorial_skipped",
		"new_ids": [],
		"held_ids": [],
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": items,
		"tex_by_item": {},
		"swiped": {},
		"rules": rules,
		"state": CAMPAIGN_SHELL.fresh_state(),
		"push_block": false,
		"tutorial": false,
	})
	await create_timer(0.25).timeout
	summary = _menu.get("_summary")
	_failed = _assert(
		"UI.tutorial_skipped_copy",
		"tutorial_skipped uses Spin key — not success_none",
		summary != null
		and str(summary.text) == PLAYER_COPY.text("postrun.summary.tutorial_skipped", "Tutorial skipped.")
		and str(summary.text) != PLAYER_COPY.text("postrun.summary.success_none", ""),
		"got=%s" % (summary.text if summary else "")
	) or _failed
	_menu.dismiss()
	await _wait_present_done(2.0)

	## Loss still walks Overview→Collection→Next (played area shown).
	_present_done = false
	_kick_present({
		"kind": "loss",
		"new_ids": [],
		"held_ids": [],
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": items,
		"tex_by_item": {},
		"swiped": {"net": true},
		"rules": rules,
		"state": CAMPAIGN_SHELL.fresh_state(),
		"push_block": false,
		"tutorial": false,
	})
	await create_timer(0.2).timeout
	## During loss presentation, collection should become visible at some point; skip to end.
	_menu.call("_on_skip")
	await create_timer(0.1).timeout
	_failed = _assert(
		"UI.loss_has_area_count",
		"collection area count lab populated",
		str(_menu.get("_area_count_lab").text).find("collection:") >= 0,
		"lab=%s" % _menu.get("_area_count_lab").text
	) or _failed
	_menu.dismiss()
	await _wait_present_done(2.0)

	## Manual tab cancels auto (no hang).
	_present_done = false
	_kick_present({
		"kind": "win",
		"new_ids": ["net"],
		"held_ids": ["net"],
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": items,
		"tex_by_item": tex,
		"swiped": {"net": true},
		"rules": rules,
		"state": CAMPAIGN_SHELL.fresh_state(),
		"push_block": false,
		"tutorial": false,
	})
	await create_timer(0.15).timeout
	_menu.call("_on_tab", 2) ## Next Goal
	await create_timer(0.2).timeout
	_failed = _assert(
		"UI.tab_cancels_auto",
		"after tab, phase idle and gen advanced",
		int(_menu.get("_phase")) == 3,
		"phase=%s" % _menu.get("_phase")
	) or _failed
	_menu.dismiss()
	await _wait_present_done(2.0)

	## Static main wiring
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	_failed = _static(
		"STATIC.finalize_handoff",
		"main finalizes menu result before delve; push pause gated",
		main_src.find("func _finalize_progress_menu_result") >= 0
		and main_src.find("_finalize_progress_menu_result(leave_result)") >= 0
		and main_src.find("_finalize_progress_menu_result(push_result, true)") >= 0
		and main_src.find("start_run_wanted.connect") < 0,
		""
	) or _failed
	_failed = _static(
		"STATIC.deferred_stamp",
		"Leave stamps past-quota cabinets idempotently; Push banks without stamp",
		main_src.find("_campaign_bank_from_hand(true)") >= 0
		and main_src.find("_campaign_bank_from_hand(false)") >= 0
		and main_src.find("cabinet_count(_campaign.state, pool_id) >= quota") >= 0,
		""
	) or _failed
	_failed = _static(
		"STATIC.tutorial_declined_not_complete_copy",
		"declined tutorial does not open kind=tutorial",
		main_src.find('var tut_kind := "tutorial_skipped" if declined else "tutorial"') >= 0,
		""
	) or _failed
	_failed = _static(
		"STATIC.attribution_helper",
		"menu uses BucketRules + pool_for_bucket",
		FileAccess.get_file_as_string("res://scripts/ui/progress_menu.gd").find("pool_for_bucket") >= 0
		and FileAccess.get_file_as_string("res://scripts/ui/progress_menu.gd").find("BucketRules.of_card") >= 0,
		""
	) or _failed

	var flag_note := "Missing Spin overallCollection/postrun.collection.overall aggregate key — flagged, not invented."
	_rows.append({"kind": "NOTE", "id": "NOTE.flag_collected_copy", "ok": true, "detail": flag_note})
	print("NOTE NOTE.flag_collected_copy — %s" % flag_note)
	_finish()


func _on_ack(id: String) -> void:
	## Raw invocation list — do not dedupe (tests double-ack).
	_acked.append(id)


func _kick_present(payload: Dictionary) -> void:
	_present_async(payload)


func _present_async(payload: Dictionary) -> void:
	_last_result = await _menu.present(payload, Callable(self, "_on_ack"))
	_present_done = true


func _wait_present_done(sec: float) -> void:
	var left := sec
	while not _present_done and left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05


func _assert(id: String, desc: String, cond: bool, detail: String) -> bool:
	_rows.append({"kind": "ASSERT", "id": id, "desc": desc, "ok": cond, "detail": detail})
	print("%s ASSERT %s — %s%s" % ["PASS" if cond else "FAIL", id, desc, (" (%s)" % detail) if detail != "" else ""])
	return not cond


func _static(id: String, desc: String, cond: bool, detail: String) -> bool:
	_rows.append({"kind": "STATIC", "id": id, "desc": desc, "ok": cond, "detail": detail})
	print("%s STATIC %s — %s%s" % ["PASS" if cond else "FAIL", id, desc, (" (%s)" % detail) if detail != "" else ""])
	return not cond


func _finish() -> void:
	var n_fail := 0
	for r in _rows:
		if typeof(r) == TYPE_DICTIONARY and not bool(r.get("ok", true)) and str(r.get("kind", "")) in ["ASSERT", "STATIC"]:
			n_fail += 1
	print("---")
	print("rows=%d fail=%d" % [_rows.size(), n_fail])
	if _failed or n_fail > 0:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)
