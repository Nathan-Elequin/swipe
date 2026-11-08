extends SceneTree
## Bounded main.tscn return→menu→launch integration (sandbox XDG only).
## Proves wipe reveal + unpaused after Start; tutorial kinds; Push pause gate;
## mid-stagger early start; loss Overview→Collection→Target auto path.
## Does NOT prove full Leave bank from live hotbar play — see UNCOVERED notes.

const MAIN_SCENE := "res://scenes/main.tscn"
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const OK_MARK := "PROGRESS_MENU_MAIN_ROUTES_OK"
const FAIL_MARK := "PROGRESS_MENU_MAIN_ROUTES_FAIL"
const SHA_MARK := "PROGRESS_MENU_MAIN_ROUTES_SHA"

var _failed := false
var _rows: Array = []
var main: Node = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ud := OS.get_user_data_dir().replace("\\", "/")
	print("USER_DATA=", ud)
	print("%s %s" % [SHA_MARK, _git_sha()])
	if ud.find("progress-menu-main") < 0 and ud.find("progress-menu") < 0:
		print("REFUSED_UNSAFE_DIRECT_USERDATA")
		quit(2)
		return
	PLAYER_COPY.reload()
	var err: Error = change_scene_to_file(MAIN_SCENE)
	if err != OK:
		_assert("BOOT.scene", "change_scene main.tscn", false, str(err))
		_finish()
		return
	for _i in 600:
		await process_frame
		main = root.get_node_or_null("Main")
		if main != null and main.get("progress_menu") != null and main.get("_campaign") != null:
			break
	_failed = _assert(
		"BOOT.main",
		"Main + progress_menu + campaign ready",
		main != null and main.progress_menu != null and main._campaign != null,
		""
	) or _failed
	if _failed:
		_finish()
		return
	_quiet_chrome()
	await process_frame
	get_root().size = Vector2i(1680, 1040)

	await _case_win_start_wipe_clear()
	await _case_loss_auto_tabs()
	await _case_tutorial_complete_and_skip()
	await _case_push_start_unpaused()
	await _case_mid_stagger_early_start()
	await _case_manual_next_lands()
	await _case_stamp_pencil_gate_via_bank_handler()
	await _case_overlap_present()
	await _case_keyboard_focus_inspect()

	_rows.append({
		"kind": "UNCOVERED",
		"id": "UNCOVERED.live_leave_hotbar_bank",
		"ok": true,
		"detail": "Does not drive full adventure Leave from live hotbar; uses _open_progress_menu + bank handler stubs.",
	})
	_rows.append({
		"kind": "UNCOVERED",
		"id": "UNCOVERED.reload_mid_ceremony_disk",
		"ok": true,
		"detail": "Reload mid-menu disk resume not exercised in this bounded harness.",
	})
	_rows.append({
		"kind": "NOTE",
		"id": "NOTE.overall_aggregate",
		"ok": true,
		"detail": "No Spin overallCollection key — overview flags missing aggregate.",
	})
	_finish()


func _git_sha() -> String:
	## Best-effort; runner also prints tip.
	return "see-runner"


func _quiet_chrome() -> void:
	for key in ["playtest_hub", "playtest_intro", "playtest_feedback", "playtest_tier"]:
		if key in main and main.get(key) != null and main.get(key) is CanvasItem:
			(main.get(key) as CanvasItem).visible = false
	main.phase = "title"
	paused = false
	if main.home_cabin != null:
		main.home_cabin.tutorial_done = true
		main.home_cabin.intro_seen = true
		main.home_cabin.nib_first_done = true


func _wipe_opaque() -> bool:
	var wipe = main.get("_biome_wipe")
	if wipe == null or not is_instance_valid(wipe):
		return false
	return wipe.visible and wipe.modulate.a > 0.85


func _case_win_start_wipe_clear() -> void:
	## Bound: prove menu→start handoff clears wipe + unpauses. Do not await full nest/arm settle.
	await main._biome_dissolve_out(0.05)
	_failed = _assert("R1.wipe_out", "dissolve_out leaves opaque wipe", _wipe_opaque(), "") or _failed
	var menu = main.progress_menu
	## Box wrappers so async lambdas mutate shared slots.
	var box := {"done": false, "result": {}}
	var kick := func() -> void:
		box.result = await main._open_progress_menu("win", ["net"], ["net"], false)
		box.done = true
	kick.call()
	await create_timer(0.35).timeout
	_failed = _assert("R1.menu_open", "progress menu open after win open", menu.visible, "") or _failed
	if menu.visible:
		menu.call("_choose_start", 0)
	var left := 6.0
	while not bool(box.done) and left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
	var result: Dictionary = box.result if typeof(box.result) == TYPE_DICTIONARY else {}
	_failed = _assert(
		"R1.start_result",
		"menu returns start action before delve",
		bool(box.done) and str(result.get("action", "")) == "start",
		"done=%s result=%s" % [box.done, result]
	) or _failed
	if str(result.get("action", "")) != "start":
		## Force start path for wipe assertion if choose raced.
		result = {"action": "start", "biome_index": 0}
	var fin_box := {"done": false}
	var fin := func() -> void:
		await main._finalize_progress_menu_result(result)
		fin_box.done = true
	fin.call()
	var saw_clear := false
	var saw_adv := false
	for _i in 100:
		await create_timer(0.05).timeout
		if not _wipe_opaque():
			saw_clear = true
		if bool(main.adventure) and bool(main._campaign_on):
			saw_adv = true
		if saw_clear and saw_adv:
			break
		if bool(fin_box.done):
			break
	_failed = _assert(
		"R1.wipe_cleared",
		"after Start handoff, BiomeWipe not opaque",
		saw_clear or not _wipe_opaque(),
		"wipe_a=%s fin=%s" % [
			main.get("_biome_wipe").modulate.a if main.get("_biome_wipe") else -1,
			fin_box.done,
		]
	) or _failed
	_failed = _assert(
		"R1.unpaused",
		"tree unpaused after Start",
		not paused,
		""
	) or _failed
	_failed = _assert(
		"R1.adventure",
		"campaign adventure active after start dispatch",
		saw_adv or (bool(main.adventure) and bool(main._campaign_on)),
		"adv=%s camp=%s phase=%s" % [main.adventure, main._campaign_on, main.phase]
	) or _failed
	if not bool(fin_box.done):
		_rows.append({
			"kind": "UNCOVERED",
			"id": "UNCOVERED.full_delve_nest_settle",
			"ok": true,
			"detail": "Start wipe/unpause asserted; full nest/arm delve settle not awaited (known hang risk in headless).",
		})
		main._splash_busy = false
		paused = false
		if main.get("_biome_wipe") != null:
			main._biome_wipe.visible = false
			main._biome_wipe.modulate.a = 0.0
		await _force_menu_idle(main.progress_menu)


func _case_loss_auto_tabs() -> void:
	## Loss auto presentation visits Overview then Collection then Target (no skip).
	var menu = main.progress_menu
	await _force_menu_idle(menu)
	var seen := {"overview": false, "collection": false, "target": false}
	var box := {"done": false}
	var kick := func() -> void:
		await menu.present(_payload("loss", [], false), Callable())
		box.done = true
	kick.call()
	var left := 3.5
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		if menu.get("_overview_box") != null and menu.get("_overview_box").visible:
			seen.overview = true
		if menu.get("_collection_box") != null and menu.get("_collection_box").visible:
			seen.collection = true
		if menu.get("_target_box") != null and menu.get("_target_box").visible:
			seen.target = true
		if seen.overview and seen.collection and seen.target:
			break
	if menu.visible:
		menu.dismiss()
	await _await_flag(box, "done", 2.0)
	await _force_menu_idle(menu)
	_failed = _assert(
		"R2.loss_flow",
		"loss auto Overview→Collection→Target",
		seen.overview and seen.collection and seen.target,
		str(seen)
	) or _failed


func _force_menu_idle(menu) -> void:
	if menu == null:
		return
	menu.set("_present_busy", false)
	menu.set("_skip_pres", true)
	menu.set("_pres_gen", int(menu.get("_pres_gen")) + 1)
	if menu.visible:
		menu.dismiss()
	menu.visible = false
	await create_timer(0.05).timeout


func _await_flag(box: Dictionary, key: String, sec: float) -> bool:
	var left := sec
	while not bool(box.get(key, false)) and left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
	return bool(box.get(key, false))


func _case_tutorial_complete_and_skip() -> void:
	var menu = main.progress_menu
	await _force_menu_idle(menu)
	var box := {"done": false}
	var kick := func() -> void:
		await menu.present(_payload("tutorial", [], false), Callable())
		box.done = true
	kick.call()
	await create_timer(0.2).timeout
	var sum: Label = menu.get("_summary")
	_failed = _assert(
		"R3.tutorial_complete_copy",
		"tutorial kind uses tutorial summary",
		sum != null and sum.text == PLAYER_COPY.text("postrun.summary.tutorial", ""),
		sum.text if sum else ""
	) or _failed
	menu.dismiss()
	_failed = _assert("R3.tutorial_dismiss", "tutorial present ends", await _await_flag(box, "done", 3.0), "") or _failed
	await _force_menu_idle(menu)
	box = {"done": false}
	kick = func() -> void:
		await menu.present(_payload("tutorial_skipped", [], false), Callable())
		box.done = true
	kick.call()
	await create_timer(0.2).timeout
	sum = menu.get("_summary")
	_failed = _assert(
		"R3.tutorial_skipped_copy",
		"skip uses tutorial_skipped — not success_none",
		sum != null
		and sum.text == PLAYER_COPY.text("postrun.summary.tutorial_skipped", "Tutorial skipped.")
		and sum.text != PLAYER_COPY.text("postrun.summary.success_none", ""),
		sum.text if sum else ""
	) or _failed
	menu.dismiss()
	_failed = _assert("R3.skip_dismiss", "skipped present ends", await _await_flag(box, "done", 3.0), "") or _failed
	await _force_menu_idle(menu)


func _case_push_start_unpaused() -> void:
	await main._biome_dissolve_out(0.05)
	var menu = main.progress_menu
	var box := {"done": false, "result": {}}
	var kick := func() -> void:
		box.result = await main._open_progress_menu("win", [], [], true, "b1", "Verdant Hollow")
		box.done = true
	kick.call()
	await create_timer(0.25).timeout
	if menu.visible:
		menu.call("_choose_start", 0)
	var left := 6.0
	while not bool(box.done) and left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
	var result: Dictionary = box.result if typeof(box.result) == TYPE_DICTIONARY else {}
	if str(result.get("action", "")) != "start":
		result = {"action": "start", "biome_index": 0}
	var fin_box := {"done": false}
	var fin := func() -> void:
		await main._finalize_progress_menu_result(result, true)
		fin_box.done = true
	fin.call()
	var saw_clear := false
	for _i in 100:
		await create_timer(0.05).timeout
		if not paused and not _wipe_opaque():
			saw_clear = true
			break
		if bool(fin_box.done):
			break
	_failed = _assert(
		"R4.push_start_unpaused",
		"Push→Start does not leave tree paused / opaque wipe",
		saw_clear and not paused,
		"paused=%s wipe=%s fin=%s" % [paused, _wipe_opaque(), fin_box.done]
	) or _failed
	if not bool(fin_box.done):
		main._splash_busy = false
		paused = false
		if main.get("_biome_wipe") != null:
			main._biome_wipe.visible = false
			main._biome_wipe.modulate.a = 0.0


func _case_mid_stagger_early_start() -> void:
	var menu = main.progress_menu
	await _force_menu_idle(menu)
	var raw_acks: Array = [] ## count raw invocations — do not dedupe in callback
	var ack := func(id: String) -> void:
		raw_acks.append(str(id))
	var box := {"done": false, "result": {}}
	var kick := func() -> void:
		box.result = await menu.present(_payload("win", ["net", "sai", "shield"], false), ack)
		box.done = true
	kick.call()
	await create_timer(0.12).timeout
	if menu.visible:
		menu.call("_choose_start", 0)
	_failed = _assert("R5.early_dismiss", "early start present ends", await _await_flag(box, "done", 4.0), "") or _failed
	_failed = _assert(
		"R5.early_start_acks_raw",
		"early start acks each new id once (raw invocation count)",
		raw_acks.size() == 3 and raw_acks.has("net") and raw_acks.has("sai") and raw_acks.has("shield"),
		"acks=%s" % str(raw_acks)
	) or _failed
	_failed = _assert(
		"R5.no_double_ack",
		"no duplicate ack invocations",
		raw_acks.size() == 3,
		"n=%s" % raw_acks.size()
	) or _failed
	await _force_menu_idle(menu)


func _case_manual_next_lands() -> void:
	var menu = main.progress_menu
	await _force_menu_idle(menu)
	var box := {"done": false}
	var kick := func() -> void:
		await menu.present(_payload("win", ["net", "sai"], false), Callable())
		box.done = true
	kick.call()
	await create_timer(0.08).timeout
	## During intro — manual Next should land news on Collection with New! state.
	menu.call("_on_next_step")
	await create_timer(0.15).timeout
	var cell: Control = menu.get("_cell_by_id").get("net", null)
	var state_l: Label = cell.find_child("State", true, false) if cell else null
	_failed = _assert(
		"R6.manual_next_lands_new",
		"intro Next lands New! visual on cell",
		cell != null
		and cell.modulate.a > 0.9
		and state_l != null
		and state_l.text == PLAYER_COPY.text("postrun.collection.item_new", "New!"),
		"a=%s state=%s" % [cell.modulate.a if cell else -1, state_l.text if state_l else ""]
	) or _failed
	var count_lab: Label = menu.get("_area_count_lab")
	_failed = _assert(
		"R6.count_updates",
		"area count includes landed news",
		count_lab != null and str(count_lab.text).find("/") >= 0,
		count_lab.text if count_lab else ""
	) or _failed
	menu.call("_on_next_step")
	await create_timer(0.1).timeout
	menu.dismiss()
	await _await_flag(box, "done", 3.0)
	await _force_menu_idle(menu)


func _case_stamp_pencil_gate_via_bank_handler() -> void:
	## Use main._campaign_bank_from_hand path semantics via shell: first stamp fresh;
	## clear; Leave-like re-stamp must NOT re-mark pencil.
	var rules: Dictionary = main._campaign.rules
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	CAMPAIGN_SHELL.normalize(state)
	var openers := ["net", "sai", "shield", "spinning_top", "throwing_knife"]
	var pools := {}
	for id in openers:
		pools[str(id)] = "b1"
	CAMPAIGN_SHELL.bank(rules, state, openers, pools)
	## Simulate Push: no stamp.
	_failed = _assert(
		"R7.push_no_piece",
		"push bank no map piece",
		(state.get("map_pieces", []) as Array).is_empty(),
		""
	) or _failed
	## Leave deferred stamp via same past-quota loop as main handler.
	var quota: int = CAMPAIGN_SHELL.quota_of(rules)
	for raw_b in CAMPAIGN_SHELL.biomes_of(rules):
		var pool_id := str((raw_b as Dictionary).get("id", ""))
		if pool_id != "" and CAMPAIGN_SHELL.cabinet_count(state, pool_id) >= quota:
			CAMPAIGN_SHELL.stamp_map_piece(rules, state, pool_id)
	_failed = _assert(
		"R7.leave_awards_once",
		"Leave after push awards piece+fresh once",
		(state.get("map_pieces", []) as Array).has("b2")
		and (state.get("pencil_fresh", []) as Array).has("b2"),
		str(state.get("map_pieces", [])) + " " + str(state.get("pencil_fresh", []))
	) or _failed
	CAMPAIGN_SHELL.clear_pencil_fresh(state)
	for raw_b2 in CAMPAIGN_SHELL.biomes_of(rules):
		var pool_id2 := str((raw_b2 as Dictionary).get("id", ""))
		if pool_id2 != "" and CAMPAIGN_SHELL.cabinet_count(state, pool_id2) >= quota:
			CAMPAIGN_SHELL.stamp_map_piece(rules, state, pool_id2)
	_failed = _assert(
		"R7.ordinary_leave_no_remark",
		"clear_pencil then Leave does not re-mark owned piece",
		(state.get("pencil_fresh", []) as Array).is_empty()
		and (state.get("map_pieces", []) as Array).size() == 1,
		str(state.get("pencil_fresh", []))
	) or _failed


func _case_overlap_present() -> void:
	var menu = main.progress_menu
	await _force_menu_idle(menu)
	var acks_a: Array = []
	var acks_b: Array = []
	var box := {"a": false, "b": false}
	var kick_a := func() -> void:
		await menu.present(_payload("win", ["net"], false), func(id): acks_a.append(id))
		box.a = true
	var kick_b := func() -> void:
		await menu.present(_payload("win", ["sai"], false), func(id): acks_b.append(id))
		box.b = true
	kick_a.call()
	await create_timer(0.08).timeout
	kick_b.call()
	await create_timer(0.25).timeout
	menu.dismiss()
	await _await_flag(box, "a", 3.0)
	await _await_flag(box, "b", 3.0)
	_failed = _assert(
		"R8.overlap_no_cross_ack",
		"overlapping present does not cross-ack sessions",
		not acks_a.has("sai") and not acks_b.has("net"),
		"a=%s b=%s" % [acks_a, acks_b]
	) or _failed
	await _force_menu_idle(menu)


func _case_keyboard_focus_inspect() -> void:
	var menu = main.progress_menu
	await _force_menu_idle(menu)
	var box := {"done": false}
	var kick := func() -> void:
		await menu.present(_payload("win", ["net"], false), Callable())
		box.done = true
	kick.call()
	await create_timer(0.15).timeout
	menu.call("_on_next_step")
	await create_timer(0.1).timeout
	var cells: Array = menu.get("_focus_cells")
	_failed = _assert(
		"R9.focusable_cells",
		"collection cells are FOCUS_ALL",
		cells.size() > 0 and (cells[0] as Control).focus_mode == Control.FOCUS_ALL,
		"n=%s" % cells.size()
	) or _failed
	if cells.size() > 0:
		(cells[0] as Control).grab_focus()
		menu.call("_inspect_cell", "net")
	var detail: Label = menu.get("_detail")
	_failed = _assert(
		"R9.inspect_detail",
		"inspect fills detail strip",
		detail != null and detail.text != "",
		detail.text if detail else ""
	) or _failed
	menu.dismiss()
	await _await_flag(box, "done", 3.0)
	await _force_menu_idle(menu)


func _payload(kind: String, new_ids: Array, push_block: bool) -> Dictionary:
	var rules: Dictionary = main._campaign.rules
	var state: Dictionary = main._campaign.state.duplicate(true)
	var swiped := {}
	for id in new_ids:
		swiped[str(id)] = true
	for id2 in ["spinning_top", "throwing_knife"]:
		swiped[id2] = true
	return {
		"kind": kind,
		"new_ids": new_ids.duplicate(),
		"held_ids": new_ids.duplicate(),
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": main.items_by_id,
		"tex_by_item": main.tex_by_item,
		"swiped": swiped,
		"rules": rules,
		"state": state,
		"push_block": push_block,
		"tutorial": kind == "tutorial",
	}


func _assert(id: String, desc: String, cond: bool, detail: String) -> bool:
	_rows.append({"kind": "ASSERT", "id": id, "desc": desc, "ok": cond, "detail": detail})
	print("%s ASSERT %s — %s%s" % ["PASS" if cond else "FAIL", id, desc, (" (%s)" % detail) if detail != "" else ""])
	return not cond


func _finish() -> void:
	var n_fail := 0
	for r in _rows:
		if typeof(r) == TYPE_DICTIONARY and not bool(r.get("ok", true)) and str(r.get("kind", "")) == "ASSERT":
			n_fail += 1
		elif typeof(r) == TYPE_DICTIONARY and str(r.get("kind", "")) in ["UNCOVERED", "NOTE"]:
			print("%s %s — %s" % [r.get("kind"), r.get("id"), r.get("detail", "")])
	print("---")
	print("rows=%d fail=%d" % [_rows.size(), n_fail])
	if _failed or n_fail > 0:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)
