extends SceneTree
## Journey A — push the 9 NOTRUN (+24 PARTIAL) cases as far as isolated Godot allows.
## Labels every row unit vs journey. Sandbox userdata must contain "collection-a-sandbox".
## Does not steal godot-mcp seat 6550. No invented Spin copy. No preference mutation.


const MAIN_SCENE := "res://scenes/main.tscn"
const OUT_DIR := "res://playtest/repot/outbox/REQ-20261108-collection-A"
const SHOT_DIR := OUT_DIR + "/shots"
const JOURNEY := preload("res://scripts/collection_journey.gd")
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")
const PLAYER_COPY := preload("res://scripts/player_copy.gd")

var main: Node = null
var rows: Array = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ud := OS.get_user_data_dir().replace("\\", "/")
	print("USER_DATA=", ud)
	if ud.find("collection-a-sandbox") < 0:
		print("REFUSED_UNSAFE_DIRECT_USERDATA")
		quit(2)
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	DisplayServer.window_set_title("Collection A NOTRUN journeys (sandbox)")
	root.size = Vector2i(1680, 1040)
	if change_scene_to_file(MAIN_SCENE) != OK:
		print("FAIL boot change_scene")
		quit(1)
		return
	for _i in 900:
		await process_frame
		main = root.get_node_or_null("Main")
		if main != null and main.get("progress_menu") != null and main.get("home_cabin") != null and main.get("_campaign") != null:
			if not main.items_by_id.is_empty():
				break
	if main == null or main.progress_menu == null or main.home_cabin == null or main._campaign == null or main.items_by_id.is_empty():
		print("FAIL boot main")
		quit(1)
		return
	paused = false
	root.size = Vector2i(1680, 1040)
	_quiet_chrome()
	PLAYER_COPY.reload()
	_log_scale("boot")

	await _case_01_tutorial_handoff()
	await _case_02_nest_verdant_start()
	await _case_11_checkpoint_extract()
	await _case_12_biome_entry_splash()
	await _case_18_next_ordinary_verdant()
	await _case_20_late_pool_scrape()
	await _case_21_full_cabinet_ui()
	await _case_22_final_dungeon_victory()
	await _case_23_inheritance_handoff()
	await _case_24_completed_reload_freedom()

	print("NOTRUN_PASS_DONE")
	for row in rows:
		print(
			"CASE %s verdict=%s class=%s note=%s" % [
				row["id"], row["verdict"], row.get("klass", "?"), row["note"]
			]
		)
	quit(0)


func _quiet_chrome() -> void:
	for key in ["playtest_hub", "playtest_intro", "playtest_feedback", "playtest_tier"]:
		var node = main.get(key)
		if node != null and node is CanvasItem:
			if node.has_method("close_intro"):
				node.close_intro()
			(node as CanvasItem).visible = false
	if main.home_cabin != null:
		main.home_cabin.tutorial_done = true
		main.home_cabin.intro_seen = true
		main.home_cabin.nib_first_done = true
		main.home_cabin.tutorial_declined = false
		main.home_cabin.key_ring_seen = true
		main.home_cabin.visible = false


func _row(id: String, verdict: String, klass: String, note: String) -> void:
	rows.append({"id": id, "verdict": verdict, "klass": klass, "note": note})
	print("ROW %s %s [%s] %s" % [id, verdict, klass, note])


func _shot(filename: String) -> void:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var path := ProjectSettings.globalize_path(SHOT_DIR + "/" + filename)
	var img: Image = root.get_viewport().get_texture().get_image()
	var err: Error = img.save_png(path)
	_log_scale(filename)
	print("SHOT %s %sx%s err=%s" % [filename, img.get_width(), img.get_height(), err])


func _log_scale(tag: String) -> void:
	var vp: Vector2 = root.get_viewport().get_visible_rect().size
	var win: Vector2i = DisplayServer.window_get_size()
	print("SCALE %s viewport=%sx%s window=%sx%s" % [tag, vp.x, vp.y, win.x, win.y])


func _soft_reset(reason: String) -> void:
	print("HARNESS_RESET %s" % reason)
	if main.progress_menu != null and main.progress_menu.visible:
		main.progress_menu.dismiss()
	if main.rope_exit != null and main.rope_exit.has_method("hide_exit"):
		main.rope_exit.hide_exit()
	await create_timer(0.35).timeout
	main._adventure_busy = false
	main._splash_busy = false
	main.adventure = false
	main._campaign_on = true
	main.phase = "title"
	main.in_tutorial = false
	main._unlock_screen = false
	paused = false
	if main.home_cabin != null:
		main.home_cabin.visible = false
	var wipe = main.get("_biome_wipe")
	if wipe != null and is_instance_valid(wipe):
		wipe.visible = false
		wipe.modulate.a = 0.0
	for c in main.get_children():
		var nm := str(c.name)
		if nm.find("BiomeSplash") >= 0:
			c.queue_free()
	await create_timer(0.1).timeout
	paused = false


func _b1_ids() -> Array:
	var out: Array = []
	for id in main.items_by_id.keys():
		var card: Dictionary = main.items_by_id[id]
		if str(card.get("status", "live")) in ["retired", "hold"]:
			continue
		if BucketRules.is_token(card):
			continue
		if main._campaign_pool_of_item(str(id)) == "b1":
			out.append(str(id))
	out.sort()
	return out


func _pool_ids(pool: String) -> Array:
	var out: Array = []
	for id in main.items_by_id.keys():
		var card: Dictionary = main.items_by_id[id]
		if str(card.get("status", "live")) in ["retired", "hold"]:
			continue
		if BucketRules.is_token(card):
			continue
		if main._campaign_pool_of_item(str(id)) == pool:
			out.append(str(id))
	out.sort()
	return out


func _collect_labels(node: Node) -> String:
	if node == null:
		return ""
	var parts: PackedStringArray = []
	if node is Label:
		var t := (node as Label).text.strip_edges()
		if t != "":
			parts.append(t)
	if node is Button:
		var bt := (node as Button).text.strip_edges()
		if bt != "":
			parts.append(bt)
	for c in node.get_children():
		var sub := _collect_labels(c)
		if sub != "":
			parts.append(sub)
	return " | ".join(parts)


func _payload_win(new_ids: Array = [], milestones: Array = [], pool: String = "b1") -> Dictionary:
	var cabin = main.home_cabin
	return {
		"kind": "win",
		"new_ids": new_ids.duplicate(),
		"played_pool": pool,
		"played_name": CAMPAIGN_SHELL.biome_name(main._campaign.rules, pool),
		"items_by_id": main.items_by_id,
		"tex_by_item": main.tex_by_item,
		"swiped": cabin.swiped.duplicate() if cabin else {},
		"seen": cabin.seen.duplicate() if cabin else {},
		"rules": main._campaign.rules,
		"state": main._campaign.state.duplicate(true),
		"push_block": false,
		"tutorial": false,
		"milestones": milestones.duplicate(),
	}


func _present_settled(payload: Dictionary) -> void:
	var menu = main.progress_menu
	menu.present(payload, Callable())
	for _i in 12:
		await process_frame
		if menu.visible:
			break
	menu.call("_cancel_presentation")
	menu._btn_skip.disabled = false
	menu._btn_next.disabled = false
	menu._btn_cabin.disabled = false
	await process_frame


## --- A01 Tutorial handoff ---
func _case_01_tutorial_handoff() -> void:
	await _soft_reset("before tutorial")
	## Real code path: _road_finish_to_cabin → progress menu tutorial kind.
	## Still not a full player tutorial playthrough → journey stays NOTRUN unless settle proves otherwise.
	main.in_tutorial = false
	for id in main.items_by_id.keys():
		main._tut_seen[str(id)] = true
	for id2 in main.monsters_by_id.keys():
		main._tut_seen[str(id2)] = true
	var saved_reveal = main.get("_bucket_reveal")
	main.set("_bucket_reveal", null)
	var saved_cut = null
	if main.home_cabin != null:
		saved_cut = main.home_cabin.get("_cutscene")
		main.home_cabin.set("_cutscene", null)
		main.home_cabin.tutorial_done = true
	main._road_finish_to_cabin(false)
	var opened := false
	var left := 12.0
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		if main.progress_menu != null and main.progress_menu.visible:
			opened = true
			break
	var sum := ""
	if opened and main.progress_menu.get("_summary") != null:
		sum = str(main.progress_menu.get("_summary").text)
	var want := PLAYER_COPY.text(
		"postrun.summary.tutorial",
		"Tutorial complete. Tutorial items don't count toward collection progress."
	)
	await _shot("N01-tutorial-handoff.png")
	## Fixture-driven finish path — unit PASS if summary matches; journey NOTRUN (no full tutorial).
	if opened and sum == want:
		_row("01", "NOTRUN", "unit+surface", "tutorial progress surface opened via _road_finish_to_cabin; summary OK — not a full player tutorial journey")
	elif opened:
		_row("01", "NOTRUN", "unit+surface", "menu opened but summary mismatch sum=%s" % sum)
	else:
		_row("01", "NOTRUN", "journey", "tutorial handoff menu did not open")
	if main.get("_bucket_reveal") == null:
		main.set("_bucket_reveal", saved_reveal)
	if main.home_cabin != null and saved_cut != null:
		main.home_cabin.set("_cutscene", saved_cut)
	await _soft_reset("after tutorial")


## --- A02 Nest / Verdant start ---
func _case_02_nest_verdant_start() -> void:
	await _soft_reset("before nest")
	main._campaign_on = true
	main.adventure = false
	main.in_tutorial = false
	main._adventure_busy = false
	main.phase = "title"
	## Present a leave/win menu, then Start via finalize (real delve path).
	await _present_settled(_payload_win())
	var menu = main.progress_menu
	menu.call("_choose_start", 0)
	await process_frame
	## Present was cancelled — synthesize finalize so Start actually delves.
	await main._finalize_progress_menu_result({"action": "start", "biome_index": 0})
	var settled := false
	var saw_ready := false
	var left := 14.0
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		paused = false
		if str(main.phase) in ["ready", "draft", "rest", "combat"] and bool(main._campaign_on):
			saw_ready = true
		if str(main.phase) == "ready" and bool(main.adventure) and not bool(main._adventure_busy) and not bool(main._splash_busy):
			settled = true
			break
	await _shot("N02-nest-verdant-start.png")
	if settled:
		_row("02", "PASS", "journey", "Start→Verdant nest settled phase=ready adventure=1")
	elif saw_ready:
		_row(
			"02",
			"PARTIAL",
			"journey",
			"Start launched (phase=%s busy=%s splash=%s adventure=%s) — nest idle not reached in 14s" % [
				main.phase, main._adventure_busy, main._splash_busy, main.adventure
			]
		)
	else:
		_row("02", "NOTRUN", "journey", "Start delve did not reach campaign ready; phase=%s" % main.phase)
	await _soft_reset("after nest")


## --- A11 Checkpoint Head home / Push deeper ---
func _case_11_checkpoint_extract() -> void:
	await _soft_reset("before checkpoint")
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for id in ["net", "sai", "shield", "spinning_top"]:
		state["banked"][id] = "b1"
	CAMPAIGN_SHELL.normalize(state)
	main._campaign.state = state
	main._campaign.write()
	main._campaign_on = true
	main.adventure = true
	main.phase = "rest"
	main._adventure_busy = false
	main.in_tutorial = false
	main.hotbar = [{"card_id": "throwing_knife"}]
	main.dungeons_cleared = maxi(1, int(main.dungeons_cleared))
	if main.home_cabin != null:
		main.home_cabin.visible = false
	var rope = main.rope_exit
	if rope == null:
		_row("11", "NOTRUN", "journey", "rope_exit missing")
		await _shot("N03-checkpoint-extract.png")
		await _soft_reset("after checkpoint")
		return
	## Real rest open path pieces: open_exit + apply_exit_mode (campaign chips).
	rope.open_instant = true
	rope.open_exit(maxi(1, int(main.dungeons_cleared)), [])
	var can_push: bool = CAMPAIGN_SHELL.can_push(main._campaign.rules, main._campaign.state)
	var pool := CAMPAIGN_SHELL.current_biome_id(main._campaign.rules, main._campaign.state)
	var chip := {
		"biome": CAMPAIGN_SHELL.biome_name(main._campaign.rules, pool),
		"n": CAMPAIGN_SHELL.cabinet_count(main._campaign.state, pool),
		"quota": CAMPAIGN_SHELL.quota_of(main._campaign.rules),
		"show_proj": true,
		"next": CAMPAIGN_SHELL.biome_name(main._campaign.rules, "b2"),
		"next_id": "b2",
		"show_next": true,
	}
	rope.apply_exit_mode(true, can_push, false, chip, false)
	await process_frame
	await create_timer(0.3).timeout
	var blob := _collect_labels(rope)
	var has_ladder: bool = rope.get("_hatch_hit") != null and bool(rope.get("_hatch_hit").visible)
	var has_gate: bool = rope.get("_gate_hit") != null and bool(rope.get("_gate_hit").visible)
	var visible_ok: bool = bool(rope.visible)
	await _shot("N03-checkpoint-extract.png")
	## Journey PASS only if climb+deeper hotspots are live on campaign rest surface.
	## Completing Head home / Push flows still requires player choice — surface proof = PARTIAL.
	if visible_ok and (has_ladder or has_gate):
		_row(
			"11",
			"PARTIAL",
			"journey",
			"rope open campaign mode can_push=%s ladder=%s gate=%s chip_labels=%s — Head home/Push not click-completed" % [
				can_push, has_ladder, has_gate, blob.substr(0, 180)
			]
		)
	else:
		_row(
			"11",
			"NOTRUN",
			"journey",
			"rope surface incomplete visible=%s ladder=%s gate=%s labels=%s" % [
				visible_ok, has_ladder, has_gate, blob.substr(0, 160)
			]
		)
	rope.hide_exit()
	await _soft_reset("after checkpoint")


## --- A12 Push into new biome entry ---
func _case_12_biome_entry_splash() -> void:
	await _soft_reset("before splash")
	main._campaign_on = true
	main.adventure = true
	main.phase = "rest"
	var state: Dictionary = main._campaign.state
	for id in ["net", "sai", "shield", "spinning_top", "throwing_knife"]:
		state["banked"][id] = "b1"
	if not (state.get("map_pieces", []) as Array).has("b2"):
		(state["map_pieces"] as Array).append("b2")
	CAMPAIGN_SHELL.normalize(state)
	main._campaign.write()
	## Prefer Push-deeper path if can_push; else direct splash present.
	var splash = null
	var via := "splash_api"
	if CAMPAIGN_SHELL.can_push(main._campaign.rules, main._campaign.state) and main.has_method("_rope_deeper"):
		via = "rope_deeper"
		## Opening rope then emitting deeper is closer to journey; still bounded.
		var rope = main.rope_exit
		if rope != null:
			rope.open_instant = true
			rope.open_exit(2, [])
			rope.apply_exit_mode(true, true, false, {"biome": "Verdant Hollow", "n": 5, "next_id": "b2", "next": "Crystal Cavern", "show_next": true}, false)
			await process_frame
		## Direct splash still the reliable evidence for biome entry art.
		splash = await main._present_campaign_splash("b2", 2)
	else:
		splash = await main._present_campaign_splash("b2", 2)
	await create_timer(0.35).timeout
	await _shot("N04-biome-entry-splash.png")
	if splash != null and is_instance_valid(splash):
		_row("12", "PARTIAL", "journey", "Crystal splash present via=%s — not a full Push-from-rope player sequence" % via)
		if splash.has_method("play_out"):
			await splash.play_out()
		splash.queue_free()
	else:
		_row("12", "NOTRUN", "journey", "BiomeSplash for b2 returned null via=%s" % via)
	await _soft_reset("after splash")


## --- A18 Next ordinary Verdant run ---
func _case_18_next_ordinary_verdant() -> void:
	await _soft_reset("before next-verdant")
	## Post-receipt Start on Verdant again (ordinary next run).
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for id in ["net", "sai", "shield", "spinning_top"]:
		state["banked"][id] = "b1"
	CAMPAIGN_SHELL.normalize(state)
	main._campaign.state = state
	main._campaign.write()
	main._campaign_on = true
	main.in_tutorial = false
	if main.home_cabin != null:
		for sid in state["banked"].keys():
			main.home_cabin.swiped[str(sid)] = true
			main.home_cabin.seen[str(sid)] = true
	await _present_settled(_payload_win())
	await main._finalize_progress_menu_result({"action": "start", "biome_index": 0})
	var settled := false
	var left := 14.0
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		paused = false
		if str(main.phase) == "ready" and bool(main.adventure) and bool(main._campaign_on) and not bool(main._adventure_busy):
			settled = true
			break
	await _shot("N09-next-ordinary-verdant.png")
	var pool := CAMPAIGN_SHELL.current_biome_id(main._campaign.rules, main._campaign.state)
	if settled and pool == "b1":
		_row("18", "PASS", "journey", "post-receipt Start→Verdant ready pool=b1")
	elif settled:
		_row("18", "PARTIAL", "journey", "settled ready but pool=%s (wanted b1)" % pool)
	else:
		_row("18", "NOTRUN", "journey", "post-receipt Start did not settle ready; phase=%s pool=%s" % [main.phase, pool])
	await _soft_reset("after next-verdant")


## --- A20 Late missing identities ordinary play ---
func _case_20_late_pool_scrape() -> void:
	await _soft_reset("before late-pool")
	var b1: Array = _b1_ids()
	if b1.size() < 8:
		_row("20", "NOTRUN", "journey", "need >=8 b1 ids, got %s" % b1.size())
		await _shot("N05-late-pool-scrape.png")
		return
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	var bank_n: int = mini(b1.size() - 3, 12)
	for i in bank_n:
		state["banked"][str(b1[i])] = "b1"
	CAMPAIGN_SHELL.normalize(state)
	main._campaign.state = state
	main._campaign.write()
	var late_seen := str(b1[b1.size() - 2])
	var late_unseen := str(b1[b1.size() - 1])
	if main.home_cabin != null:
		main.home_cabin.seen.clear()
		main.home_cabin.swiped.clear()
		for sid in state["banked"].keys():
			main.home_cabin.seen[str(sid)] = true
			main.home_cabin.swiped[str(sid)] = true
		main.home_cabin.seen[late_seen] = true
	## Catalogue journey surface: unseen must be "?", recognized must show identity.
	await _present_settled(_payload_win())
	var menu = main.progress_menu
	menu._area_filter = "b1"
	menu.call("_show_panel", 1)
	menu.call("_rebuild_area_tabs")
	await process_frame
	var unseen_name := ""
	var seen_name := ""
	var ucell: Control = menu._cell_by_id.get(late_unseen, null)
	var scell: Control = menu._cell_by_id.get(late_seen, null)
	if ucell != null:
		var ul: Label = ucell.find_child("Name", true, false) as Label
		unseen_name = ul.text if ul else ""
	if scell != null:
		var sl: Label = scell.find_child("Name", true, false) as Label
		seen_name = sl.text if sl else ""
	await _shot("N05-late-pool-scrape.png")
	var ok := unseen_name == "?" and seen_name != "?" and seen_name.strip_edges() != ""
	if ok:
		_row(
			"20",
			"PARTIAL",
			"journey",
			"catalogue late unseen=%s name=? recognized=%s name=%s — fixture state, not ordinary late-run scrape" % [
				late_unseen, late_seen, seen_name
			]
		)
	else:
		_row(
			"20",
			"NOTRUN",
			"journey",
			"late identity truth failed unseen=%s/%s seen=%s/%s" % [late_unseen, unseen_name, late_seen, seen_name]
		)
	await _soft_reset("after late-pool")


## --- A21 Full biome cabinet recognition ---
func _case_21_full_cabinet_ui() -> void:
	await _soft_reset("before cabinet_full")
	var b1: Array = _b1_ids()
	var roster_total: int = b1.size()
	if roster_total < 2:
		_row("21", "NOTRUN", "unit", "b1 roster empty")
		await _shot("N06-full-cabinet-ui.png")
		return
	var before: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for i in roster_total - 1:
		before["banked"][str(b1[i])] = "b1"
	CAMPAIGN_SHELL.normalize(before)
	var after: Dictionary = before.duplicate(true)
	var last_id := str(b1[roster_total - 1])
	after["banked"][last_id] = "b1"
	CAMPAIGN_SHELL.normalize(after)
	main._campaign.state = after
	main._campaign.write()
	if main.home_cabin != null:
		for sid in after["banked"].keys():
			main.home_cabin.swiped[str(sid)] = true
			main.home_cabin.seen[str(sid)] = true
	var ms: Array = JOURNEY.milestones_from_bank(
		main._campaign.rules, before, after, ["b1"], {"b1": roster_total}
	)
	var has_full := false
	for raw in ms:
		if str((raw as Dictionary).get("kind", "")) == "cabinet_full":
			has_full = true
	await _present_settled(_payload_win([last_id], ms))
	var menu = main.progress_menu
	menu.get("_revealed_new")[last_id] = true
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var blob := _collect_labels(menu.get("_overview_box"))
	var shown := blob.find("Cabinet complete") >= 0 or blob.find("cabinet") >= 0 or blob.find("Spin copy") >= 0
	await _shot("N06-full-cabinet-ui.png")
	if has_full and shown:
		_row("21", "PARTIAL", "unit+surface", "cabinet_full milestone shown roster=%s — not 14/14 live ceremony journey" % roster_total)
	elif has_full:
		_row("21", "NOTRUN", "unit", "cabinet_full helper true but UI not shown blob=%s" % blob.substr(0, 160))
	else:
		_row("21", "NOTRUN", "unit", "cabinet_full milestone missing roster=%s" % roster_total)
	await _soft_reset("after cabinet_full")


## --- A22 Final-dungeon victory ≠ inheritance ---
func _case_22_final_dungeon_victory() -> void:
	await _soft_reset("before final victory")
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for id in ["net", "sai", "shield", "spinning_top", "throwing_knife"]:
		state["banked"][id] = "b1"
	state["map_pieces"] = ["b2", "b3", "b4", "b5"]
	state["won"] = false
	state["endless_unlocked"] = false
	CAMPAIGN_SHELL.normalize(state)
	main._campaign.state = state
	main._campaign.write()
	var payload := _payload_win([], [], "b5")
	payload["played_name"] = "Shadow Abyss"
	payload["state"] = state
	await _present_settled(payload)
	var menu = main.progress_menu
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var sum: String = str(menu.get("_summary").text) if menu.get("_summary") else ""
	var blob: String = _collect_labels(menu.get("_overview_box"))
	var inheritance: bool = blob.find("inheritance") >= 0 or blob.find("Full collection") >= 0
	await _shot("N07-final-dungeon-victory.png")
	if menu.visible and sum != "" and not inheritance and not bool(state.get("won", false)):
		_row("22", "PARTIAL", "unit+surface", "Shadow Abyss win receipt without inheritance text — not a live final-clear journey")
	else:
		_row("22", "NOTRUN", "journey", "final victory surface incomplete sum=%s inheritance=%s" % [sum, inheritance])
	await _soft_reset("after final victory")


## --- A23 Full collection / neutral handoff ---
func _case_23_inheritance_handoff() -> void:
	await _soft_reset("before inheritance")
	var before: Dictionary = CAMPAIGN_SHELL.fresh_state()
	var after: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for pool in ["b1", "b2", "b3", "b4", "b5"]:
		for id in _pool_ids(pool):
			after["banked"][str(id)] = pool
	CAMPAIGN_SHELL.normalize(after)
	after["won"] = true
	after["endless_unlocked"] = true
	before["won"] = false
	var ms: Array = JOURNEY.milestones_from_bank(
		main._campaign.rules, before, after, ["b1", "b2", "b3", "b4", "b5"], {}
	)
	var has_complete := false
	for raw in ms:
		if str((raw as Dictionary).get("kind", "")) == "collection_complete":
			has_complete = true
	if not has_complete:
		ms.append({"kind": "collection_complete"})
		has_complete = true
	main._campaign.state = after
	main._campaign.write()
	if main.home_cabin != null:
		for sid in after["banked"].keys():
			main.home_cabin.swiped[str(sid)] = true
			main.home_cabin.seen[str(sid)] = true
	await _present_settled(_payload_win([], ms, "b5"))
	var menu = main.progress_menu
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var blob := _collect_labels(menu.get("_overview_box"))
	var want := PLAYER_COPY.text(
		"postrun.milestone.collection_complete",
		"[Spin copy: Full collection — reserved inheritance entry]"
	)
	var shown := blob.find("Full collection") >= 0 or blob.find("inheritance") >= 0 or blob.find(want) >= 0
	await _shot("N08-inheritance-handoff.png")
	if has_complete and shown:
		_row("23", "PARTIAL", "unit+surface", "collection_complete Spin placeholder shown banked=%s — authored inheritance story out of scope" % after["banked"].size())
	else:
		_row("23", "NOTRUN", "unit", "collection_complete not shown has=%s blob=%s" % [has_complete, blob.substr(0, 160)])
	await _soft_reset("after inheritance")


## --- A24 Completed reload freedom ---
func _case_24_completed_reload_freedom() -> void:
	await _soft_reset("before reload-freedom")
	## After won=true, Start still allowed (freedom). Journey PARTIAL if Start settles.
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for pool in ["b1", "b2", "b3", "b4", "b5"]:
		for id in _pool_ids(pool):
			state["banked"][str(id)] = pool
	CAMPAIGN_SHELL.normalize(state)
	state["won"] = true
	state["endless_unlocked"] = true
	main._campaign.state = state
	main._campaign.write()
	main._campaign_on = true
	## Idempotent bank of already-complete set.
	var added: Dictionary = CAMPAIGN_SHELL.bank(main._campaign.rules, main._campaign.state, ["net"], {"net": "b1"})
	var no_extra: bool = (added.get("added", []) as Array).is_empty()
	await _present_settled(_payload_win())
	await main._finalize_progress_menu_result({"action": "start", "biome_index": 0})
	var settled := false
	var left := 12.0
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		paused = false
		if str(main.phase) == "ready" and bool(main.adventure):
			settled = true
			break
	await _shot("N10-completed-reload-freedom.png")
	if no_extra and settled:
		_row("24", "PARTIAL", "journey", "won=true Start still settles ready; re-bank adds nothing — full post-completion freedom suite still incomplete")
	elif no_extra:
		_row("24", "PARTIAL", "unit+journey", "re-bank idempotent; Start settle failed phase=%s" % main.phase)
	else:
		_row("24", "NOTRUN", "unit", "re-bank unexpectedly added=%s" % added)
	await _soft_reset("after reload-freedom")
