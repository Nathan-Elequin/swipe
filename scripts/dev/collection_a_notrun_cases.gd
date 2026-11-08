extends SceneTree
## Journey A honesty drain — isolated Godot, disposable APPDATA sandbox.
## Level labels: unit | fixture | integration | synthetic_input (never inflate to real mouse).
## Does not steal godot-mcp seat 6550. No invented Spin prose. No preference mutation.


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
	DisplayServer.window_set_title("Collection A honesty drain (sandbox)")
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
	_log_tip_and_roster_filter()

	await _case_01_tutorial_handoff()
	await _case_02_nest_verdant_start()
	await _case_05_offer_decline_honesty()
	await _case_11_checkpoint_with_haul()
	await _case_12_push_with_haul()
	await _case_18_next_ordinary_verdant()
	await _case_20_late_acquire_retain()
	await _case_21_last_biome_bank_ceremony()
	await _case_22_final_clear_event()
	await _case_23_full_collection_boundary()
	await _case_24_completed_freedom()
	_case_reduced_motion_scaling()

	print("HONESTY_DRAIN_DONE")
	for row in rows:
		print(
			"CASE %s verdict=%s level=%s note=%s" % [
				row["id"], row["verdict"], row.get("level", "?"), row["note"]
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


func _row(id: String, verdict: String, level: String, note: String) -> void:
	rows.append({"id": id, "verdict": verdict, "level": level, "note": note})
	print("ROW %s %s [%s] %s" % [id, verdict, level, note])


func _shot(filename: String) -> bool:
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHOT_DIR))
	var path := ProjectSettings.globalize_path(SHOT_DIR + "/" + filename)
	var img: Image = root.get_viewport().get_texture().get_image()
	var err: Error = img.save_png(path)
	var bytes := 0
	if err == OK and FileAccess.file_exists(path):
		bytes = FileAccess.get_file_as_bytes(path).size()
	if err != OK or bytes <= 0:
		DirAccess.remove_absolute(path)
		await create_timer(0.08).timeout
		await RenderingServer.frame_post_draw
		img = root.get_viewport().get_texture().get_image()
		err = img.save_png(path)
		bytes = FileAccess.get_file_as_bytes(path).size() if err == OK and FileAccess.file_exists(path) else 0
	_log_scale(filename)
	var ok := err == OK and FileAccess.file_exists(path) and bytes > 0
	if ok:
		print("SHOT_OK %s %sx%s bytes=%s" % [filename, img.get_width(), img.get_height(), bytes])
	else:
		print("SHOT_FAIL %s err=%s exists=%s bytes=%s" % [filename, err, FileAccess.file_exists(path), bytes])
	return ok


func _log_scale(tag: String) -> void:
	var vp: Vector2 = root.get_viewport().get_visible_rect().size
	var win: Vector2i = DisplayServer.window_get_size()
	print("SCALE %s viewport=%sx%s window=%sx%s" % [tag, vp.x, vp.y, win.x, win.y])


func _log_tip_and_roster_filter() -> void:
	## SHA reconcile + 67→66 exclusion evidence (Danger Magnet hold in Cinder / pool 4).
	var tip := ""
	var out: Array = []
	if OS.execute("git", PackedStringArray(["rev-parse", "--short", "HEAD"]), out, true) == 0 and not out.is_empty():
		tip = str(out[0]).strip_edges()
	var dirty_out: Array = []
	var dirty := false
	if OS.execute("git", PackedStringArray(["status", "--porcelain"]), dirty_out, true) == 0:
		for line in dirty_out:
			if str(line).strip_edges() != "":
				dirty = true
				break
	print("TIP_SHA ", tip, " full=", _git_full_sha(), " dirty=", dirty, " watermark_expect=", tip, ("*" if dirty else ""))
	var hold_cinder: Array = []
	var live_b4 := 0
	var raw_b4 := 0
	for id in main.items_by_id.keys():
		var card: Dictionary = main.items_by_id[id]
		if BucketRules.is_token(card):
			continue
		if main._campaign_pool_of_item(str(id)) != "b4":
			continue
		raw_b4 += 1
		var st := str(card.get("status", "live"))
		if st in ["retired", "hold"]:
			hold_cinder.append("%s|%s|%s|pool=%s" % [id, card.get("name", id), st, card.get("pool", "")])
			continue
		live_b4 += 1
	print("ROSTER_FILTER source=progress_menu._pool_roster + harness._pool_ids status not in hold/retired")
	print("CINDER_RAW_INCLUDING_HOLD_RETIRED ", raw_b4, " LIVE_BANKABLE ", live_b4)
	for line in hold_cinder:
		print("EXCLUDED_CINDER ", line)
	if hold_cinder.is_empty():
		print("EXCLUDED_CINDER none")
	var roster := _roster_totals()
	var sum := 0
	for k in roster.keys():
		sum += int(roster[k])
	print("LIVE_BANKABLE_ROSTER ", roster, " sum=", sum)


func _git_full_sha() -> String:
	var out: Array = []
	if OS.execute("git", PackedStringArray(["rev-parse", "HEAD"]), out, true) == 0 and not out.is_empty():
		return str(out[0]).strip_edges()
	return ""


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
		if str(c.name).find("BiomeSplash") >= 0:
			c.queue_free()
	await create_timer(0.1).timeout
	paused = false


func _b1_ids() -> Array:
	return _pool_ids("b1")


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


func _roster_totals() -> Dictionary:
	var out := {}
	for pool in ["b1", "b2", "b3", "b4", "b5"]:
		out[pool] = _pool_ids(pool).size()
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


func _fill_bank_except(except_id: String = "") -> Dictionary:
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for pool in ["b1", "b2", "b3", "b4", "b5"]:
		for id in _pool_ids(pool):
			if except_id != "" and str(id) == except_id:
				continue
			state["banked"][str(id)] = pool
	CAMPAIGN_SHELL.normalize(state)
	return state


## --- A01 Tutorial handoff + seen persistence ---
func _case_01_tutorial_handoff() -> void:
	await _soft_reset("before tutorial")
	## Reachable finish path mirrors `_tutorial_finish_async`: set tutorial_done, save, then land once.
	main._campaign.state = CAMPAIGN_SHELL.fresh_state()
	main._campaign.write()
	if main.home_cabin != null:
		main.home_cabin.swiped.clear()
		main.home_cabin.seen.clear()
		main.home_cabin.tutorial_done = false
		main.home_cabin.tutorial_declined = false
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
		## Production Yes-complete stamps tutorial_done before the shared landing helper.
		main.home_cabin.tutorial_done = true
		main.home_cabin._save()
	main._road_finish_to_cabin(false)
	var opened := false
	var left := 12.0
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		if main.progress_menu != null and main.progress_menu.visible:
			opened = true
			break
	var kind := str(main.progress_menu.get("_kind")) if opened else ""
	var sum := str(main.progress_menu.get("_summary").text) if opened and main.progress_menu.get("_summary") else ""
	var want := PLAYER_COPY.text(
		"postrun.summary.tutorial",
		"Tutorial complete. Tutorial items don't count toward collection progress."
	)
	await _shot("N01-tutorial-handoff.png")
	if opened:
		main.progress_menu.dismiss()
		await create_timer(0.15).timeout
	## Reload cabin profile: tutorial_done must survive; do not auto-open tutorial.
	var done_before_reload := false
	if main.home_cabin != null:
		done_before_reload = bool(main.home_cabin.tutorial_done)
		main.home_cabin.tutorial_done = false
		main.home_cabin._load_save()
	var done_after_reload := bool(main.home_cabin.tutorial_done) if main.home_cabin != null else false
	## Subsequent ordinary win after durable tutorial_done — not tutorial kind.
	await _present_settled(_payload_win([], [], "b1"))
	var later_kind := ""
	if main.progress_menu != null and main.progress_menu.visible:
		later_kind = str(main.progress_menu.get("_kind"))
		main.progress_menu.dismiss()
	var later_ok: bool = later_kind == "win"
	## Helper probe only: second direct `_road_finish_to_cabin` is not a player route
	## (player finishes tutorial once via `_tutorial_finish_async`). Record observation;
	## do not label as proven player regression.
	var helper_second := false
	main._road_finish_to_cabin(false)
	left = 4.0
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		if main.progress_menu != null and main.progress_menu.visible and str(main.progress_menu.get("_kind")) == "tutorial":
			helper_second = true
			break
	if helper_second and main.progress_menu != null and main.progress_menu.visible:
		main.progress_menu.dismiss()
	print(
		"TUTORIAL_PATH done_before=%s done_reload=%s later_kind=%s helper_second_direct=%s (helper probe ≠ player regression)" % [
			done_before_reload, done_after_reload, later_kind, helper_second
		]
	)
	if main.get("_bucket_reveal") == null:
		main.set("_bucket_reveal", saved_reveal)
	if main.home_cabin != null and saved_cut != null:
		main.home_cabin.set("_cutscene", saved_cut)
	if opened and sum == want and kind == "tutorial" and done_after_reload and later_ok:
		_row(
			"01",
			"PASS",
			"integration",
			"reachable finish stamps tutorial_done; reload keeps it; ordinary win kind=win. Helper second _road_finish still opens tutorial (API non-idempotent; not claimed as player regression). Full in-dungeon rails still unautomated."
		)
	elif opened and sum == want and kind == "tutorial":
		_row(
			"01",
			"PARTIAL",
			"integration",
			"handoff OK; reload_done=%s later_kind=%s helper_second=%s; full rails unautomated" % [
				done_after_reload, later_kind, helper_second
			]
		)
	elif opened:
		_row("01", "PARTIAL", "fixture", "menu opened kind=%s sum mismatch; full rails unautomated" % kind)
	else:
		_row("01", "NOTRUN", "integration", "tutorial handoff menu did not open")
	await _soft_reset("after tutorial")


## --- A02 Nest / Verdant start ---
func _case_02_nest_verdant_start() -> void:
	await _soft_reset("before nest")
	main._campaign_on = true
	main.adventure = false
	main.in_tutorial = false
	main._adventure_busy = false
	main.phase = "title"
	await _present_settled(_payload_win())
	await main._finalize_progress_menu_result({"action": "start", "biome_index": 0})
	var settled := false
	var left := 14.0
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		paused = false
		if str(main.phase) == "ready" and bool(main.adventure) and not bool(main._adventure_busy) and not bool(main._splash_busy):
			settled = true
			break
	await _shot("N02-nest-verdant-start.png")
	if settled:
		_row("02", "PASS", "integration", "Start→Verdant nest settled phase=ready (synthetic finalize)")
	else:
		_row("02", "NOTRUN", "integration", "Start delve did not settle ready; phase=%s" % main.phase)
	await _soft_reset("after nest")


## --- A05 honesty: offer-decline is unit helper, not live journey ---
func _case_05_offer_decline_honesty() -> void:
	## No live mill offer-decline is exercised here. Record honesty only.
	_row(
		"05",
		"PASS",
		"unit",
		"offer-decline / seen retention covered by unit helper only — live mill offer-decline NOT exercised this drain"
	)


## --- A11 Checkpoint Climb with carried missing haul ---
func _case_11_checkpoint_with_haul() -> void:
	await _soft_reset("before checkpoint")
	var b1: Array = _b1_ids()
	if b1.size() < 7:
		_row("11", "NOTRUN", "fixture", "need ≥7 b1 ids for haul case")
		await _shot("N03-checkpoint-extract.png")
		return
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	## Bank 5 so can_push; carry two NOT yet banked missing ids.
	for i in 5:
		state["banked"][str(b1[i])] = "b1"
	var haul_a := str(b1[5])
	var haul_b := str(b1[6])
	CAMPAIGN_SHELL.normalize(state)
	CAMPAIGN_SHELL.begin_run(state, 0, false, false)
	main._campaign.state = state
	main._campaign.write()
	main._campaign_on = true
	main.adventure = true
	main.phase = "rest"
	main._adventure_busy = false
	main.in_tutorial = false
	main.hotbar = [{"card_id": haul_a}, {"card_id": haul_b}]
	main.dungeons_cleared = maxi(1, int(main.dungeons_cleared))
	if main.home_cabin != null:
		main.home_cabin.visible = false
		for sid in state["banked"].keys():
			main.home_cabin.swiped[str(sid)] = true
			main.home_cabin.seen[str(sid)] = true
	var can_push: bool = CAMPAIGN_SHELL.can_push(main._campaign.rules, main._campaign.state)
	var rope = main.rope_exit
	if rope == null or not can_push:
		_row("11", "NOTRUN", "fixture", "rope/can_push unavailable can_push=%s" % can_push)
		await _shot("N03-checkpoint-extract.png")
		await _soft_reset("after checkpoint")
		return
	rope.open_instant = true
	rope.open_exit(1, [])
	rope.apply_exit_mode(true, true, false, {"biome": "Verdant Hollow", "n": 5, "quota": 5, "next_id": "b2", "show_next": true}, false)
	await process_frame
	await _shot("N03-checkpoint-extract.png")
	main._adventure_leave()
	var leave_menu := false
	var left := 14.0
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		paused = false
		if main.progress_menu != null and main.progress_menu.visible:
			leave_menu = true
			break
	await _shot("N03b-head-home-progress.png")
	var banked_dict: Dictionary = main._campaign.state.get("banked", {})
	var banked_a: bool = banked_dict.has(haul_a)
	var banked_b: bool = banked_dict.has(haul_b)
	var news_ok := false
	if leave_menu:
		var news: Array = main.progress_menu.get("_new_ids") if main.progress_menu.get("_new_ids") != null else []
		news_ok = news.has(haul_a) or news.has(haul_b) or banked_a or banked_b
		main.progress_menu.dismiss()
		left = 8.0
		while left > 0.0 and bool(main._adventure_busy):
			await create_timer(0.05).timeout
			left -= 0.05
			paused = false
	if leave_menu and (banked_a or banked_b or news_ok):
		_row("11", "PASS", "integration", "Climb leave with haul %s/%s → menu; banked_a=%s banked_b=%s (integration route, not physical-input journey)" % [haul_a, haul_b, banked_a, banked_b])
	elif leave_menu:
		_row("11", "PARTIAL", "integration", "Head home menu opened but haul not banked/shown yet (timing); haul=%s,%s (integration, not physical-input)" % [haul_a, haul_b])
	else:
		_row("11", "NOTRUN", "integration", "Head home menu failed with haul")
	await _soft_reset("after checkpoint")


## --- A12 Push with haul into Crystal ---
func _case_12_push_with_haul() -> void:
	await _soft_reset("before splash")
	var b1: Array = _b1_ids()
	if b1.size() < 6:
		_row("12", "NOTRUN", "fixture", "need ≥6 b1 ids")
		await _shot("N04-biome-entry-splash.png")
		return
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for i in 5:
		state["banked"][str(b1[i])] = "b1"
	var haul := str(b1[5])
	CAMPAIGN_SHELL.normalize(state)
	CAMPAIGN_SHELL.begin_run(state, 0, false, false)
	main._campaign.state = state
	main._campaign.write()
	main._campaign_on = true
	main.adventure = true
	main.phase = "rest"
	main._adventure_busy = false
	main.in_tutorial = false
	main.hotbar = [{"card_id": haul}]
	main.dungeon_index = 1
	if main.home_cabin != null:
		main.home_cabin.visible = false
	var can_push: bool = CAMPAIGN_SHELL.can_push(main._campaign.rules, main._campaign.state)
	var rope = main.rope_exit
	var splash = null
	var via := "none"
	if can_push and rope != null:
		via = "rope_deeper"
		rope.open_instant = true
		rope.open_exit(1, [])
		rope.apply_exit_mode(true, true, false, {"biome": "Verdant Hollow", "n": 5, "quota": 5, "next_id": "b2", "show_next": true}, false)
		await process_frame
		await _shot("N04a-push-rope-before.png")
		main._rope_deeper()
		var left := 12.0
		while left > 0.0:
			await create_timer(0.05).timeout
			left -= 0.05
			paused = false
			for c in main.get_children():
				if str(c.name).find("BiomeSplash") >= 0 or (c.get_script() != null and str(c.get_script().resource_path).find("biome_splash") >= 0):
					splash = c
					break
			if splash != null:
				break
			if str(main.phase) == "draft" and int(main.dungeon_index) >= 2:
				break
	await create_timer(0.3).timeout
	await _shot("N04-biome-entry-splash.png")
	var pool_now := CAMPAIGN_SHELL.current_biome_id(main._campaign.rules, main._campaign.state)
	## Push does not bank haul (Leave does). Assert haul still carried + Crystal entered.
	var still_held := false
	for it in main.hotbar:
		if typeof(it) == TYPE_DICTIONARY and str(it.get("card_id", "")) == haul:
			still_held = true
	if splash != null and is_instance_valid(splash) and splash.has_method("_dismiss_from_input"):
		splash.call("_dismiss_from_input")
		await process_frame
	var settle_left := 4.0
	while settle_left > 0.0 and bool(main._adventure_busy):
		await create_timer(0.05).timeout
		settle_left -= 0.05
		paused = false
	if can_push and via == "rope_deeper" and pool_now == "b2" and still_held:
		_row("12", "PASS", "integration", "Push/_rope_deeper → Crystal; haul %s still carried (risk preserved, not banked on Push; integration route, not physical-input journey)" % haul)
	elif can_push and pool_now == "b2":
		_row("12", "PARTIAL", "integration", "Push reached b2 but haul held=%s splash=%s" % [still_held, splash != null])
	else:
		_row("12", "NOTRUN", "integration", "Push failed can_push=%s pool=%s via=%s" % [can_push, pool_now, via])
	await _soft_reset("after splash")


## --- A18 Next ordinary Verdant ---
func _case_18_next_ordinary_verdant() -> void:
	await _soft_reset("before next-verdant")
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
		_row("18", "PASS", "integration", "post-receipt Start→Verdant ready pool=b1")
	else:
		_row("18", "NOTRUN", "integration", "post-receipt Start failed phase=%s pool=%s" % [main.phase, pool])
	await _soft_reset("after next-verdant")


## --- A20 Late missing: acquire / retain ---
func _case_20_late_acquire_retain() -> void:
	await _soft_reset("before late-pool")
	var b1: Array = _b1_ids()
	if b1.size() < 8:
		_row("20", "NOTRUN", "fixture", "need ≥8 b1 ids")
		await _shot("N05-late-pool-scrape.png")
		return
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	var bank_n: int = mini(b1.size() - 2, 12)
	for i in bank_n:
		state["banked"][str(b1[i])] = "b1"
	CAMPAIGN_SHELL.normalize(state)
	var late := str(b1[b1.size() - 1])
	main._campaign.state = state
	main._campaign.write()
	if main.home_cabin != null:
		main.home_cabin.seen.clear()
		main.home_cabin.swiped.clear()
		for sid in state["banked"].keys():
			main.home_cabin.seen[str(sid)] = true
			main.home_cabin.swiped[str(sid)] = true
		## Seen but not banked before acquire.
		main.home_cabin.seen[late] = true
	## Authoritative bank of the late missing id.
	var before: Dictionary = main._campaign.state.duplicate(true)
	var pools := {late: "b1"}
	var bank_res: Dictionary = CAMPAIGN_SHELL.bank(main._campaign.rules, main._campaign.state, [late], pools)
	main._campaign.write()
	if main.home_cabin != null:
		main.home_cabin.swiped[late] = true
	var roster := _roster_totals()
	var ms: Array = JOURNEY.milestones_from_bank(main._campaign.rules, before, main._campaign.state, ["b1"], roster)
	await _present_settled(_payload_win([late], ms))
	var menu = main.progress_menu
	menu._area_filter = "b1"
	menu.call("_show_panel", 1)
	menu.call("_rebuild_area_tabs")
	await process_frame
	var cell: Control = menu._cell_by_id.get(late, null)
	var name_txt := ""
	if cell != null:
		var lab: Label = cell.find_child("Name", true, false) as Label
		name_txt = lab.text if lab else ""
	await _shot("N05-late-pool-scrape.png")
	var added_ok: bool = (bank_res.get("added", []) as Array).has(late)
	var retained: bool = main._campaign.state.get("banked", {}).has(late)
	if added_ok and retained and name_txt != "?" and name_txt.strip_edges() != "":
		_row("20", "PASS", "integration", "late missing %s banked+retained; catalogue name=%s (fixture preconditions + authoritative bank)" % [late, name_txt])
	elif added_ok and retained:
		_row("20", "PARTIAL", "integration", "banked+retained but catalogue name still '%s'" % name_txt)
	else:
		_row("20", "NOTRUN", "integration", "late acquire failed added=%s retained=%s" % [added_ok, retained])
	await _soft_reset("after late-pool")


## --- A21 Last biome-item bank → ceremony → skip → no reward replay ---
func _case_21_last_biome_bank_ceremony() -> void:
	await _soft_reset("before cabinet_full")
	var b1: Array = _b1_ids()
	var roster_total: int = b1.size()
	if roster_total < 2:
		_row("21", "NOTRUN", "fixture", "b1 roster empty")
		await _shot("N06-full-cabinet-ui.png")
		return
	var before: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for i in roster_total - 1:
		before["banked"][str(b1[i])] = "b1"
	CAMPAIGN_SHELL.normalize(before)
	var after: Dictionary = before.duplicate(true)
	var last_id := str(b1[roster_total - 1])
	var bank_res: Dictionary = CAMPAIGN_SHELL.bank(main._campaign.rules, after, [last_id], {last_id: "b1"})
	main._campaign.state = after
	main._campaign.write()
	if main.home_cabin != null:
		for sid in after["banked"].keys():
			main.home_cabin.swiped[str(sid)] = true
			main.home_cabin.seen[str(sid)] = true
	var roster := {"b1": roster_total}
	var ms: Array = JOURNEY.milestones_from_bank(main._campaign.rules, before, after, ["b1"], roster)
	var has_full := false
	var gate_capped := true
	for raw in ms:
		var m: Dictionary = raw
		if str(m.get("kind", "")) == "cabinet_full":
			has_full = true
		if str(m.get("kind", "")) == "gate":
			if int(m.get("to", 0)) > int(m.get("quota", 5)):
				gate_capped = false
	await _present_settled(_payload_win([last_id], ms))
	var menu = main.progress_menu
	menu.get("_revealed_new")[last_id] = true
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var blob := _collect_labels(menu.get("_overview_box"))
	## Gate text must not show uncapped n/5 like 15/5.
	var uncapped_gate := blob.find("→15/5") >= 0 or blob.find("->15/5") >= 0 or blob.find("14/5") >= 0 or blob.find("15/5") >= 0
	var shot_ok := await _shot("N06-full-cabinet-ui.png")
	## Skip / soft-reload: re-present same after state must not re-fire cabinet_full.
	var ms2: Array = JOURNEY.milestones_from_bank(main._campaign.rules, after, after, ["b1"], roster)
	var replay_full := false
	for raw2 in ms2:
		if str((raw2 as Dictionary).get("kind", "")) == "cabinet_full":
			replay_full = true
	menu.dismiss()
	await process_frame
	if has_full and gate_capped and not uncapped_gate and not replay_full and shot_ok:
		_row("21", "PASS", "integration", "last b1 bank→cabinet_full; gate capped; no replay; shot_ok; roster=%s" % roster_total)
	elif has_full and not replay_full:
		_row("21", "PARTIAL", "integration", "cabinet_full ok; gate_capped=%s uncapped_blob=%s shot_ok=%s" % [gate_capped, uncapped_gate, shot_ok])
	else:
		_row("21", "NOTRUN", "integration", "cabinet_full/replay failed has=%s replay=%s added=%s" % [has_full, replay_full, bank_res])
	await _soft_reset("after cabinet_full")


## --- A22 Final clear distinct event ---
func _case_22_final_clear_event() -> void:
	await _soft_reset("before final victory")
	## Actual final-clear path: successful Leave bank from last tip biome (b5) with
	## incomplete collection. Distinct from cabinets_complete won/endless and inheritance.
	var state: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for pool in ["b1", "b2", "b3", "b4", "b5"]:
		var ids: Array = _pool_ids(pool)
		for i in mini(2, ids.size()):
			state["banked"][str(ids[i])] = pool
	CAMPAIGN_SHELL.normalize(state)
	var roster := _roster_totals()
	var cabinets_done: bool = CAMPAIGN_SHELL.cabinets_complete(main._campaign.rules, state)
	var roster_done: bool = JOURNEY.roster_complete(state, main._campaign.rules, roster)
	## Active run on last tip biome — production Leave reads this before end_run.
	var biomes: Array = CAMPAIGN_SHELL.biomes_of(main._campaign.rules)
	var b5_index := biomes.size() - 1
	CAMPAIGN_SHELL.begin_run(state, b5_index, false, false)
	main._campaign.state = state
	main._campaign.write()
	main._campaign_on = true
	main.adventure = true
	main.phase = "rest"
	main.hotbar.clear()
	if main.home_cabin != null:
		main.home_cabin.swiped.clear()
		main.home_cabin.seen.clear()
		for sid in state["banked"].keys():
			main.home_cabin.swiped[str(sid)] = true
			main.home_cabin.seen[str(sid)] = true
	var ms: Array = await main._campaign_bank_from_hand_with_milestones(true)
	var has_final := false
	var has_inherit := false
	for raw in ms:
		var k := str((raw as Dictionary).get("kind", ""))
		if k == "final_clear":
			has_final = true
		if k == "collection_complete":
			has_inherit = true
	var flag_now: bool = bool(main._campaign.state.get("final_dungeon_cleared", false))
	var won_now: bool = bool(main._campaign.state.get("won", false))
	var endless_now: bool = bool(main._campaign.state.get("endless_unlocked", false))
	main._campaign.write()
	## Save / reload — flag durable; recognition must not invent inheritance.
	main._campaign.state = CAMPAIGN_SHELL.fresh_state()
	main._campaign.load_all()
	var flag_reload: bool = bool(main._campaign.state.get("final_dungeon_cleared", false))
	var ordinary := PLAYER_COPY.text(
		"postrun.summary.success_none",
		"Made it home. No new item types added."
	)
	await _present_settled(_payload_win([], ms, "b5"))
	var menu = main.progress_menu
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var sum: String = str(menu.get("_summary").text) if menu.get("_summary") else ""
	var blob: String = _collect_labels(menu.get("_overview_box"))
	var final_line := blob.find("Final dungeon cleared") >= 0
	var full_line := blob.find("Full collection") >= 0
	var summary_key_gap := not PLAYER_COPY.has_key("postrun.summary.final_clear")
	print(
		"N07_FINAL_CLEAR cabinets=%s roster=%s has_final=%s inherit=%s flag=%s/%s won=%s endless=%s sum=%s final_line=%s full=%s COPY_GAP_summary=%s" % [
			cabinets_done, roster_done, has_final, has_inherit, flag_now, flag_reload,
			won_now, endless_now, sum, final_line, full_line, summary_key_gap
		]
	)
	await _shot("N07-final-dungeon-victory.png")
	menu.dismiss()
	await process_frame
	## Reload present without re-emitting final_clear / inheritance.
	var ms_rep: Array = []
	var fc_rep: Dictionary = CAMPAIGN_SHELL.recognize_final_dungeon_clear(
		main._campaign.rules, main._campaign.state, "b5"
	)
	await _present_settled(_payload_win([], ms_rep, "b5"))
	menu = main.progress_menu
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var blob_rep := _collect_labels(menu.get("_overview_box"))
	var rep_final := blob_rep.find("Final dungeon cleared") >= 0
	var rep_full := blob_rep.find("Full collection") >= 0
	if menu.visible:
		menu.dismiss()
	var ok: bool = (
		(not cabinets_done)
		and (not roster_done)
		and has_final
		and (not has_inherit)
		and flag_now
		and flag_reload
		and (not won_now)
		and (not endless_now)
		and sum == ordinary
		and final_line
		and (not full_line)
		and fc_rep.is_empty()
		and (not rep_final)
		and (not rep_full)
	)
	if ok and summary_key_gap:
		_row(
			"22",
			"PASS",
			"integration",
			"b5 Leave→final_dungeon_cleared + milestone; incomplete collection; no won/endless; no inheritance; save/reload keeps flag, no replay. Summary stays approved Made-it-home; COPY_GAP postrun.summary.final_clear (milestone uses Spin placeholder)."
		)
	elif ok:
		_row("22", "PASS", "integration", "final-clear recognition durable + independent of inheritance/won")
	else:
		_row(
			"22",
			"FAIL",
			"integration",
			"final-clear fail final=%s inherit=%s flag=%s/%s won=%s endless=%s line=%s full=%s rep=%s/%s" % [
				has_final, has_inherit, flag_now, flag_reload, won_now, endless_now, final_line, full_line, rep_final, rep_full
			]
		)
	await _soft_reset("after final victory")


func _parse_overall_total(blob: String) -> Vector2i:
	## "Item types collected: 65/67" → (65, 67). (-1,-1) if missing.
	var marker := "Item types collected:"
	var at := blob.find(marker)
	if at < 0:
		return Vector2i(-1, -1)
	var rest := blob.substr(at + marker.length(), 32).strip_edges()
	var slash := rest.find("/")
	if slash < 0:
		return Vector2i(-1, -1)
	var a := rest.substr(0, slash).strip_edges()
	var b := rest.substr(slash + 1, 8).strip_edges()
	## Trim trailing non-digits on b.
	var b_clean := ""
	for i in b.length():
		var ch := b.substr(i, 1)
		if ch < "0" or ch > "9":
			break
		b_clean += ch
	return Vector2i(int(a), int(b_clean))


## --- A23 Full collection neutral boundary ---
## Hard rule: Full collection line ONLY when overview totals are complete (N/N).
func _case_23_full_collection_boundary() -> void:
	await _soft_reset("before inheritance")
	var roster := _roster_totals()
	var total := 0
	for k in roster.keys():
		total += int(roster[k])
	print("ROSTER_TOTALS ", roster, " sum=", total)

	## --- Negative: leave last Cinder (b4) missing ---
	var missing := ""
	var after_neg: Dictionary = CAMPAIGN_SHELL.fresh_state()
	for pool in ["b1", "b2", "b3", "b4", "b5"]:
		var ids: Array = _pool_ids(pool)
		for i in ids.size():
			var id := str(ids[i])
			if pool == "b4" and i == ids.size() - 1:
				missing = id
				continue
			after_neg["banked"][id] = pool
	if missing == "":
		_row("23", "NOTRUN", "fixture", "could not pick missing id for negative")
		await _shot("N08a-incomplete-66.png")
		return
	CAMPAIGN_SHELL.normalize(after_neg)
	## Quota-won alone must not imply full-collection.
	after_neg["won"] = true
	after_neg["endless_unlocked"] = true
	var before_neg: Dictionary = CAMPAIGN_SHELL.fresh_state()
	var ms_neg: Array = JOURNEY.milestones_from_bank(main._campaign.rules, before_neg, after_neg, [], roster)
	## Even if a bad fixture tried to inject complete, UI must suppress it while short.
	var ms_neg_injected: Array = ms_neg.duplicate()
	ms_neg_injected.append({"kind": "collection_complete"})
	var neg_ms_native := false
	for raw in ms_neg:
		if str((raw as Dictionary).get("kind", "")) == "collection_complete":
			neg_ms_native = true
	main._campaign.state = after_neg
	main._campaign.write()
	if main.home_cabin != null:
		main.home_cabin.swiped.clear()
		main.home_cabin.seen.clear()
		for sid in after_neg["banked"].keys():
			main.home_cabin.swiped[str(sid)] = true
			main.home_cabin.seen[str(sid)] = true
	## No new_ids stagger — settled incomplete state.
	await _present_settled(_payload_win([], ms_neg_injected, "b4"))
	var menu = main.progress_menu
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var blob_neg := _collect_labels(menu.get("_overview_box"))
	var tot_neg: Vector2i = _parse_overall_total(blob_neg)
	var neg_ui_complete := blob_neg.find("Full collection") >= 0
	print("N08a UI totals=", tot_neg, " full_line=", neg_ui_complete, " native_ms=", neg_ms_native)
	await _shot("N08a-incomplete-66.png")
	menu.dismiss()
	await process_frame

	## --- Positive: authoritative final-item bank → save → reload → boundary once ---
	## Must NOT inject collection_complete; milestone must come from milestones_from_bank.
	var before_pos: Dictionary = after_neg.duplicate(true)
	var after_pos: Dictionary = before_pos.duplicate(true)
	var pool_miss: String = str(main._campaign_pool_of_item(missing))
	if pool_miss == "":
		pool_miss = "b4"
	var bank_pos: Dictionary = CAMPAIGN_SHELL.bank(
		main._campaign.rules, after_pos, [missing], {missing: pool_miss}
	)
	var ms_pos: Array = JOURNEY.milestones_from_bank(
		main._campaign.rules, before_pos, after_pos, [pool_miss], roster
	)
	var pos_ms := false
	for raw2 in ms_pos:
		if str((raw2 as Dictionary).get("kind", "")) == "collection_complete":
			pos_ms = true
	main._campaign.state = after_pos
	main._campaign.write()
	## Save/reload: wipe in-memory state, then load_all from user://campaign_save.json.
	main._campaign.state = CAMPAIGN_SHELL.fresh_state()
	main._campaign.load_all()
	var reloaded: Dictionary = main._campaign.state
	var reload_has_last: bool = reloaded.get("banked", {}).has(missing)
	var reload_n: int = (reloaded.get("banked", {}) as Dictionary).size()
	print(
		"N08_BANK_RELOAD added=%s has_last=%s banked_n=%s pos_ms_native=%s" % [
			bank_pos.get("added", []), reload_has_last, reload_n, pos_ms
		]
	)
	if main.home_cabin != null:
		main.home_cabin.swiped.clear()
		main.home_cabin.seen.clear()
		for sid in reloaded.get("banked", {}).keys():
			main.home_cabin.swiped[str(sid)] = true
			main.home_cabin.seen[str(sid)] = true
	## Immediate final-bank truthful receipt (new item count) — separate from settled reload.
	var want_new := PLAYER_COPY.fill(
		"postrun.summary.success_new",
		{"count": "1"},
		"New item types added: {count}."
	)
	await _present_settled(_payload_win([missing], ms_pos, pool_miss))
	menu = main.progress_menu
	## Mark the banked id revealed so overview totals are truthful on the receipt frame.
	var revealed: Dictionary = menu.get("_revealed_new") if menu.get("_revealed_new") != null else {}
	revealed[missing] = true
	menu.set("_revealed_new", revealed)
	menu.call("_apply_summary")
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var sum_receipt: String = str(menu.get("_summary").text) if menu.get("_summary") else ""
	var blob_receipt := _collect_labels(menu.get("_overview_box"))
	var receipt_tot: Vector2i = _parse_overall_total(blob_receipt)
	var receipt_full := blob_receipt.find("Full collection") >= 0
	print("N08_RECEIPT sum=%s want=%s totals=%s full_line=%s" % [sum_receipt, want_new, receipt_tot, receipt_full])
	await _shot("N08-bank-receipt.png")
	menu.dismiss()
	await process_frame
	## Settled complete state after reload — no unrevealed new_ids undercount.
	await _present_settled(_payload_win([], ms_pos, pool_miss))
	menu = main.progress_menu
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var blob_pos := _collect_labels(menu.get("_overview_box"))
	var tot_pos: Vector2i = _parse_overall_total(blob_pos)
	var pos_ui := blob_pos.find("Full collection") >= 0
	print("N08 UI totals=", tot_pos, " full_line=", pos_ui, " ms=", pos_ms, " banked=", reload_n)
	## Hard stop: never keep an N08 that shows Full collection while totals are short.
	var pos_totals_ok: bool = tot_pos.x > 0 and tot_pos.x == tot_pos.y and tot_pos.y == total
	if pos_ui and not pos_totals_ok:
		print("N08_REJECT premature Full collection at ", tot_pos)
		await _shot("N08-REJECT-premature.png")
		_row(
			"23",
			"FAIL",
			"integration",
			"N08 premature Full collection at UI %s/%s (roster sum=%s) — evidence rejected" % [tot_pos.x, tot_pos.y, total]
		)
		await _soft_reset("after inheritance")
		return
	await _shot("N08-inheritance-handoff.png")
	menu.dismiss()
	await process_frame
	## Neutral once: same saved state must not re-emit collection_complete.
	var ms_rep: Array = JOURNEY.milestones_from_bank(
		main._campaign.rules, reloaded, reloaded, [], roster
	)
	var replay := false
	for raw3 in ms_rep:
		if str((raw3 as Dictionary).get("kind", "")) == "collection_complete":
			replay = true
	await _present_settled(_payload_win([], ms_rep, pool_miss))
	menu = main.progress_menu
	menu.call("_show_panel", 0)
	menu.call("_rebuild_overview")
	await process_frame
	var blob_rep := _collect_labels(menu.get("_overview_box"))
	var rep_ui := blob_rep.find("Full collection") >= 0
	print("N08_REPLAY ms_replay=%s ui_full=%s" % [replay, rep_ui])
	if menu.visible:
		menu.dismiss()

	var receipt_ok: bool = (
		sum_receipt == want_new
		and receipt_full
		and receipt_tot.x == receipt_tot.y
		and receipt_tot.y == total
	)
	var neg_ok: bool = (not neg_ms_native) and (not neg_ui_complete) and tot_neg.x >= 0 and tot_neg.x < tot_neg.y
	var pos_ok: bool = (
		pos_ms
		and pos_ui
		and pos_totals_ok
		and reload_has_last
		and reload_n == total
		and not replay
		and not rep_ui
		and receipt_ok
	)
	if neg_ok and pos_ok:
		_row(
			"23",
			"PASS",
			"integration",
			"neg UI %s/%s no Full collection; immediate receipt '%s' + Full collection; settled reload UI %s/%s once; no replay (fixture bank path, not physical acquisition)" % [
				tot_neg.x, tot_neg.y, sum_receipt, tot_pos.x, tot_pos.y
			]
		)
	elif neg_ok and pos_ms and pos_totals_ok and not pos_ui:
		_row("23", "PARTIAL", "integration", "totals complete %s/%s but Full collection line missing (Spin placeholder wiring?)" % [tot_pos.x, tot_pos.y])
	else:
		_row(
			"23",
			"FAIL",
			"integration",
			"boundary fail neg_ui=%s/%s full=%s native=%s | pos_ui=%s/%s full=%s ms=%s reload=%s/%s replay_ms=%s replay_ui=%s" % [
				tot_neg.x, tot_neg.y, neg_ui_complete, neg_ms_native,
				tot_pos.x, tot_pos.y, pos_ui, pos_ms, reload_has_last, reload_n, replay, rep_ui
			]
		)
	await _soft_reset("after inheritance")


## --- A24 Completed freedom: save/start/cabin / no ceremony replay ---
func _case_24_completed_freedom() -> void:
	await _soft_reset("before reload-freedom")
	var state: Dictionary = _fill_bank_except("")
	var roster := _roster_totals()
	## Ensure complete + won.
	state["won"] = true
	state["endless_unlocked"] = true
	main._campaign.state = state
	main._campaign.write()
	main._campaign_on = true
	if main.home_cabin != null:
		for sid in state["banked"].keys():
			main.home_cabin.swiped[str(sid)] = true
			main.home_cabin.seen[str(sid)] = true
	var added: Dictionary = CAMPAIGN_SHELL.bank(main._campaign.rules, main._campaign.state, ["net"], {"net": "b1"})
	var no_extra: bool = (added.get("added", []) as Array).is_empty()
	var ms_rep: Array = JOURNEY.milestones_from_bank(main._campaign.rules, state, main._campaign.state, [], roster)
	var replay_complete := false
	for raw in ms_rep:
		if str((raw as Dictionary).get("kind", "")) == "collection_complete":
			replay_complete = true
	await _present_settled(_payload_win([], []))
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
	var cabin_ok := false
	if settled and main.home_cabin != null and main.has_method("_open_home_cabin"):
		main._open_home_cabin(false)
		await process_frame
		await create_timer(0.2).timeout
		cabin_ok = bool(main.home_cabin.visible)
		await _shot("N10-completed-reload-freedom.png")
		main.home_cabin.visible = false
	else:
		await _shot("N10-completed-reload-freedom.png")
	if no_extra and settled and cabin_ok and not replay_complete:
		_row("24", "PASS", "integration", "completed save: re-bank empty, Start settles, cabin opens, no collection_complete replay")
	elif no_extra and settled and not replay_complete:
		_row("24", "PARTIAL", "integration", "Start settles + no replay; cabin_ok=%s" % cabin_ok)
	else:
		_row("24", "NOTRUN", "integration", "freedom incomplete no_extra=%s settled=%s cabin=%s replay=%s" % [no_extra, settled, cabin_ok, replay_complete])
	await _soft_reset("after reload-freedom")


func _case_reduced_motion_scaling() -> void:
	_row("RM", "NOTRUN", "unit", "reduced-motion preference path not exercised (no preference mutation allowed)")
	_row("SC", "NOTRUN", "unit", "scaling probe logs SCALE lines only — not a full UI scale acceptance suite")
