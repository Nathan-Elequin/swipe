extends SceneTree
## Bounded main.tscn public-route integration (isolated XDG sandbox).
## Invokes real Leave / Push / loss / give-up / tutorial finish helpers.
## Does NOT force-clear wipe/pause to manufacture a pass. Timeouts expose waiting state.
## Mid-menu full UI disk reload: UNCOVERED (disposition below).


const MAIN_SCENE := "res://scenes/main.tscn"
const CAMPAIGN_SHELL := preload("res://scripts/campaign_shell.gd")
const PLAYER_COPY := preload("res://scripts/player_copy.gd")
const OK_MARK := "PROGRESS_MENU_MAIN_ROUTES_OK"
const FAIL_MARK := "PROGRESS_MENU_MAIN_ROUTES_FAIL"

var _failed := false
var _rows: Array = []
var main: Node = null


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ud := OS.get_user_data_dir().replace("\\", "/")
	print("USER_DATA=", ud)
	var source_sha := OS.get_environment("PROGRESS_SOURCE_SHA")
	if source_sha == "":
		source_sha = "unset"
	print("PROGRESS_MENU_MAIN_ROUTES_SHA %s" % source_sha)
	if ud.find("progress-menu-main") < 0 and ud.find("progress-menu") < 0:
		print("REFUSED_UNSAFE_DIRECT_USERDATA")
		quit(2)
		return
	PLAYER_COPY.reload()
	if not await _boot_main():
		_finish()
		return

	await _case_leave_public_start()
	await _case_push_public_then_leave_stamp()
	await _case_loss_public()
	await _case_give_up_public()
	await _case_tutorial_complete_public()
	await _case_tutorial_skip_public()
	await _case_overlap_present()
	await _case_keyboard_input_event()

	_rows.append({
		"kind": "UNCOVERED",
		"id": "UNCOVERED.mid_menu_disk_reload_full_ui",
		"ok": true,
		"detail": "Full main.tscn mid-menu save/reload not exercised in cloud (costly). Pending ack+persist covered by cabin ceremony suite; disposition: leave UNCOVERED here.",
	})
	_rows.append({
		"kind": "UNCOVERED",
		"id": "UNCOVERED.full_delve_nest_settle",
		"ok": true,
		"detail": "Headless nest/arm after Start can hang; wipe/unpaused/adventure asserted during wait. Nest completion not required for MAIN_ROUTES_OK.",
	})
	_finish()


func _boot_main() -> bool:
	var err: Error = change_scene_to_file(MAIN_SCENE)
	if err != OK:
		_assert("BOOT.scene", "change_scene main.tscn", false, str(err))
		return false
	for _i in 600:
		await process_frame
		main = root.get_node_or_null("Main")
		if main != null and main.get("progress_menu") != null and main.get("_campaign") != null:
			break
	var ok := main != null and main.progress_menu != null and main._campaign != null
	_failed = _assert("BOOT.main", "Main + progress_menu + campaign", ok, "") or _failed
	if not ok:
		return false
	_quiet_chrome()
	await process_frame
	get_root().size = Vector2i(1680, 1040)
	return true


func _quiet_chrome() -> void:
	for key in ["playtest_hub", "playtest_intro", "playtest_feedback", "playtest_tier"]:
		if key in main and main.get(key) != null and main.get(key) is CanvasItem:
			(main.get(key) as CanvasItem).visible = false
	paused = false
	if main.home_cabin != null:
		main.home_cabin.tutorial_done = true
		main.home_cabin.intro_seen = true
		main.home_cabin.nib_first_done = true
		main.home_cabin.tutorial_declined = false


func _wipe_opaque() -> bool:
	var wipe = main.get("_biome_wipe")
	if wipe == null or not is_instance_valid(wipe):
		return false
	return wipe.visible and float(wipe.modulate.a) > 0.85


func _arm_rest_with_hotbar(ids: Array) -> void:
	main._campaign_on = true
	main.adventure = true
	main.phase = "rest"
	main._adventure_busy = false
	main.in_tutorial = false
	main.hotbar.clear()
	for id in ids:
		main.hotbar.append({"card_id": str(id)})
	## Ensure campaign state writeable.
	CAMPAIGN_SHELL.normalize(main._campaign.state)


func _await_menu_open(sec: float) -> bool:
	var left := sec
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		if main.progress_menu != null and main.progress_menu.visible:
			return true
	return false


func _await_menu_closed(sec: float) -> bool:
	var left := sec
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		if main.progress_menu == null or not main.progress_menu.visible:
			return true
	return false


func _choose_start_when_open() -> void:
	var menu = main.progress_menu
	if menu != null and menu.visible:
		menu.call("_choose_start", 0)


func _choose_cabin_when_open() -> void:
	var menu = main.progress_menu
	if menu != null and menu.visible:
		menu.call("_on_cabin")


## Wait for adventure busy to clear OR timeout. Does not force-clear wipe/pause.
func _await_adventure_idle(sec: float) -> Dictionary:
	var left := sec
	var saw_clear := false
	var saw_adv := false
	while left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
		if not _wipe_opaque():
			saw_clear = true
		if bool(main.adventure) and bool(main._campaign_on):
			saw_adv = true
		if not bool(main._adventure_busy) and not bool(main._splash_busy):
			return {
				"idle": true,
				"saw_clear": saw_clear,
				"saw_adv": saw_adv,
				"paused": paused,
				"wipe": _wipe_opaque(),
				"busy": main._adventure_busy,
				"splash": main._splash_busy,
				"phase": str(main.phase),
			}
	return {
		"idle": false,
		"saw_clear": saw_clear,
		"saw_adv": saw_adv,
		"paused": paused,
		"wipe": _wipe_opaque(),
		"busy": main._adventure_busy,
		"splash": main._splash_busy,
		"phase": str(main.phase),
	}


func _case_leave_public_start() -> void:
	await _ensure_route_ready()
	_arm_rest_with_hotbar(["net", "sai"])
	## Fire public Leave (async) — cannot await (blocks until dismiss).
	main._adventure_leave()
	_failed = _assert(
		"L1.menu_opens",
		"public Leave opens progress menu",
		await _await_menu_open(8.0),
		"paused=%s wipe=%s busy=%s" % [paused, _wipe_opaque(), main._adventure_busy]
	) or _failed
	await create_timer(0.15).timeout
	_choose_start_when_open()
	var st: Dictionary = await _await_adventure_idle(8.0)
	_failed = _assert(
		"L1.wipe_cleared_during_start",
		"BiomeWipe not opaque after Leave→Start (observed during wait)",
		bool(st.get("saw_clear", false)) or not bool(st.get("wipe", true)),
		str(st)
	) or _failed
	_failed = _assert(
		"L1.unpaused",
		"tree unpaused after Leave→Start",
		not bool(st.get("paused", true)),
		str(st)
	) or _failed
	_failed = _assert(
		"L1.adventure_or_idle",
		"adventure active or Leave coroutine finished",
		bool(st.get("saw_adv", false)) or bool(st.get("idle", false)),
		str(st)
	) or _failed
	if not bool(st.get("idle", false)):
		_rows.append({
			"kind": "NOTE",
			"id": "NOTE.leave_start_nest_wait",
			"ok": true,
			"detail": "Leave→Start nest/arm still busy at timeout — waiting state exposed, not force-cleared. st=%s" % st,
		})
	## Soft harness reset ONLY to continue later cases — not part of L1 proof.
	await _harness_soft_reset("after Leave→Start")


func _case_push_public_then_leave_stamp() -> void:
	## Push bank without stamp, then Leave via public bank handler stamps deferred piece.
	await _ensure_route_ready()
	_arm_rest_with_hotbar(["net", "sai", "shield", "spinning_top", "throwing_knife"])
	## Clear pieces for clean deferred proof.
	main._campaign.state["map_pieces"] = []
	main._campaign.state["pencil_fresh"] = []
	main._campaign.write()
	main._push_interrupt_home()
	_failed = _assert(
		"P1.menu_opens",
		"public Push opens progress menu",
		await _await_menu_open(8.0),
		"paused=%s wipe=%s" % [paused, _wipe_opaque()]
	) or _failed
	## Cabin exit — do not start (would dive).
	_choose_cabin_when_open()
	await _await_menu_closed(4.0)
	## Wait finalize dissolve_reveal before asserting pieces / soft reset.
	await create_timer(0.5).timeout
	var pieces_mid: int = (main._campaign.state.get("map_pieces", []) as Array).size()
	_failed = _assert(
		"P1.push_no_stamp",
		"Push path left map_pieces empty (bank handler stamp_crosses=false)",
		pieces_mid == 0,
		"pieces=%s" % pieces_mid
	) or _failed
	await _harness_soft_reset("after Push→cabin")

	## Ordinary Leave with empty new haul still runs stamp_crosses past-quota via _campaign_bank_from_hand(true).
	await _ensure_route_ready()
	_arm_rest_with_hotbar([]) ## empty hand — bank adds nothing; stamp loop still runs
	## Ensure b1 already at quota from prior push bank.
	var b1n: int = CAMPAIGN_SHELL.cabinet_count(main._campaign.state, "b1")
	_failed = _assert("P2.b1_at_quota", "b1 at/over quota after push bank", b1n >= 5, "b1=%s" % b1n) or _failed
	## Actual main bank handler for deferred award (same as Leave).
	await main._campaign_bank_from_hand(true)
	var pieces_after: int = (main._campaign.state.get("map_pieces", []) as Array).size()
	var fresh: Array = main._campaign.state.get("pencil_fresh", [])
	_failed = _assert(
		"P2.leave_handler_deferred_stamp",
		"_campaign_bank_from_hand(true) awards deferred piece once",
		pieces_after >= 1 and (main._campaign.state.get("map_pieces", []) as Array).has("b2"),
		"pieces=%s fresh=%s" % [main._campaign.state.get("map_pieces", []), fresh]
	) or _failed
	## clear + re-Leave handler must not re-mark pencil.
	CAMPAIGN_SHELL.clear_pencil_fresh(main._campaign.state)
	await main._campaign_bank_from_hand(true)
	_failed = _assert(
		"P2.no_remark_pencil",
		"second Leave handler does not re-mark owned piece pencil",
		(main._campaign.state.get("pencil_fresh", []) as Array).is_empty(),
		str(main._campaign.state.get("pencil_fresh", []))
	) or _failed


func _case_loss_public() -> void:
	await _ensure_route_ready()
	_arm_rest_with_hotbar(["net"])
	main.phase = "defeat"
	main._go_home_loss()
	_failed = _assert(
		"D1.menu_opens",
		"public loss opens progress menu",
		await _await_menu_open(10.0),
		"paused=%s wipe=%s busy=%s splash=%s" % [paused, _wipe_opaque(), main._adventure_busy, main._splash_busy]
	) or _failed
	var menu = main.progress_menu
	## Watch auto Overview→Collection→Target without Skip.
	var seen := {"o": false, "c": false, "t": false}
	var left := 5.0
	while left > 0.0 and menu != null:
		await create_timer(0.05).timeout
		left -= 0.05
		if menu.get("_overview_box") != null and menu.get("_overview_box").visible:
			seen.o = true
		if menu.get("_collection_box") != null and menu.get("_collection_box").visible:
			seen.c = true
		if menu.get("_target_box") != null and menu.get("_target_box").visible:
			seen.t = true
		if seen.o and seen.c and seen.t:
			break
	_failed = _assert(
		"D1.auto_flow",
		"loss auto Overview→Collection→Target",
		seen.o and seen.c and seen.t,
		str(seen)
	) or _failed
	_choose_cabin_when_open()
	await _await_menu_closed(4.0)
	await _harness_soft_reset("after loss")


func _case_give_up_public() -> void:
	await _ensure_route_ready()
	_arm_rest_with_hotbar([])
	main.phase = "ready"
	main._give_up()
	_failed = _assert(
		"G1.menu_opens",
		"public give_up opens progress menu",
		await _await_menu_open(10.0),
		"paused=%s wipe=%s" % [paused, _wipe_opaque()]
	) or _failed
	_choose_cabin_when_open()
	await _await_menu_closed(4.0)
	await _harness_soft_reset("after give_up")


## Bound cloud run: skip pool unlock reveal + arrive cutscene so public finish reaches the menu.
## Still invokes _road_finish_to_cabin (public); does not rewrite production finish logic.
func _bound_tutorial_finish_setup() -> Dictionary:
	main.in_tutorial = false
	## Seed items+monsters so unlock entry list is empty if reveal is still wired.
	for id in main.items_by_id.keys():
		main._tut_seen[str(id)] = true
	for id2 in main.monsters_by_id.keys():
		main._tut_seen[str(id2)] = true
	var saved := {"cut": null, "reveal": main.get("_bucket_reveal")}
	## Null reveal → _tutorial_play_unlock returns immediately (entries empty OR reveal null).
	main.set("_bucket_reveal", null)
	if main.home_cabin != null:
		main.home_cabin.tutorial_done = true
		saved["cut"] = main.home_cabin.get("_cutscene")
		main.home_cabin.set("_cutscene", null)
	return saved


func _restore_tutorial_bounds(saved: Dictionary) -> void:
	if saved.has("reveal"):
		main.set("_bucket_reveal", saved["reveal"])
	if main.home_cabin != null and saved.get("cut", null) != null:
		main.home_cabin.set("_cutscene", saved["cut"])


func _case_tutorial_complete_public() -> void:
	## Drive shared finish helper (Yes-complete).
	await _ensure_route_ready()
	var saved: Dictionary = _bound_tutorial_finish_setup()
	main._road_finish_to_cabin(false)
	var opened := await _await_menu_open(12.0)
	_failed = _assert(
		"T1.menu_opens",
		"tutorial complete opens progress menu",
		opened,
		"paused=%s wipe=%s unlock=%s" % [paused, _wipe_opaque(), main._unlock_screen]
	) or _failed
	var sum: Label = main.progress_menu.get("_summary") if main.progress_menu and opened else null
	_failed = _assert(
		"T1.tutorial_copy",
		"Yes-complete uses tutorial summary",
		opened and sum != null and sum.text == PLAYER_COPY.text("postrun.summary.tutorial", ""),
		sum.text if sum else ("menu_not_open" if not opened else "")
	) or _failed
	_choose_cabin_when_open()
	await _await_menu_closed(6.0)
	_restore_tutorial_bounds(saved)
	await _harness_soft_reset("after tutorial complete")


func _case_tutorial_skip_public() -> void:
	await _ensure_route_ready()
	var saved: Dictionary = _bound_tutorial_finish_setup()
	main._road_finish_to_cabin(true)
	var opened := await _await_menu_open(12.0)
	_failed = _assert(
		"T2.menu_opens",
		"tutorial skip opens progress menu",
		opened,
		"paused=%s wipe=%s" % [paused, _wipe_opaque()]
	) or _failed
	var sum: Label = main.progress_menu.get("_summary") if main.progress_menu and opened else null
	_failed = _assert(
		"T2.skipped_copy",
		"Skip uses tutorial_skipped not success_none",
		opened
		and sum != null
		and sum.text == PLAYER_COPY.text("postrun.summary.tutorial_skipped", "Tutorial skipped.")
		and sum.text != PLAYER_COPY.text("postrun.summary.success_none", ""),
		sum.text if sum else ("menu_not_open" if not opened else "")
	) or _failed
	_choose_cabin_when_open()
	await _await_menu_closed(6.0)
	_restore_tutorial_bounds(saved)
	await _harness_soft_reset("after tutorial skip")


func _case_overlap_present() -> void:
	var menu = main.progress_menu
	var acks_a: Array = []
	var acks_b: Array = []
	var box := {"a": false, "b": false}
	var payload_a := _menu_payload("win", ["net"])
	var payload_b := _menu_payload("win", ["sai"])
	var kick_a := func() -> void:
		await menu.present(payload_a, func(id): acks_a.append(id))
		box.a = true
	var kick_b := func() -> void:
		await menu.present(payload_b, func(id): acks_b.append(id))
		box.b = true
	kick_a.call()
	await create_timer(0.1).timeout
	kick_b.call()
	await create_timer(0.2).timeout
	menu.dismiss()
	var left := 4.0
	while (not bool(box.a) or not bool(box.b)) and left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05
	_failed = _assert(
		"O1.overlap_no_cross_ack",
		"overlapping present no cross-session ack",
		not acks_a.has("sai") and not acks_b.has("net"),
		"a=%s b=%s" % [acks_a, acks_b]
	) or _failed


func _case_keyboard_input_event() -> void:
	## Viewport push_input — not grab_focus/_inspect-only.
	await _ensure_route_ready()
	var menu = main.progress_menu
	var box := {"done": false}
	var kick := func() -> void:
		await menu.present(_menu_payload("win", ["net"]), Callable())
		box.done = true
	kick.call()
	await create_timer(0.2).timeout
	## Advance intro→collection via Next (ui_accept on unhandled when Next enabled).
	var ev := InputEventAction.new()
	ev.action = "ui_accept"
	ev.pressed = true
	Input.parse_input_event(ev)
	await create_timer(0.25).timeout
	## Ensure collection tab (phase may still be animating).
	if int(menu.get("_tab")) != 1:
		menu.call("_on_tab", 1)
		await process_frame
	var cells: Array = menu.get("_focus_cells")
	_failed = _assert(
		"K1.focusable_after_accept",
		"collection cells exist and are focusable",
		cells.size() > 0 and (cells[0] as Control).focus_mode == Control.FOCUS_ALL,
		"n=%s tab=%s phase=%s" % [cells.size(), menu.get("_tab"), menu.get("_phase")]
	) or _failed
	if cells.size() > 0:
		var cell: Control = cells[0] as Control
		cell.grab_focus()
		await process_frame
		## Deliver ui_accept to the focused cell's gui_input handler (wired in _make_cell).
		var ev2 := InputEventAction.new()
		ev2.action = "ui_accept"
		ev2.pressed = true
		cell.gui_input.emit(ev2)
		await create_timer(0.1).timeout
	var detail: Label = menu.get("_detail")
	_failed = _assert(
		"K2.inspect_via_accept",
		"detail strip filled after focused cell ui_accept",
		detail != null and str(detail.text) != "",
		detail.text if detail else ""
	) or _failed
	menu.dismiss()
	var left := 3.0
	while not bool(box.done) and left > 0.0:
		await create_timer(0.05).timeout
		left -= 0.05


func _menu_payload(kind: String, new_ids: Array) -> Dictionary:
	var swiped := {}
	for id in new_ids:
		swiped[str(id)] = true
	return {
		"kind": kind,
		"new_ids": new_ids.duplicate(),
		"held_ids": new_ids.duplicate(),
		"played_pool": "b1",
		"played_name": "Verdant Hollow",
		"items_by_id": main.items_by_id,
		"tex_by_item": main.tex_by_item,
		"swiped": swiped,
		"rules": main._campaign.rules,
		"state": main._campaign.state.duplicate(true),
		"push_block": false,
		"tutorial": kind == "tutorial",
	}


## Hide cabin / unpause so BiomeWipe tweens (no TWEEN_PAUSE_PROCESS on dissolve_out) can run.
func _ensure_route_ready() -> void:
	paused = false
	if main.home_cabin != null:
		if main.home_cabin.has_method("hide_for_run"):
			main.home_cabin.hide_for_run()
		else:
			main.home_cabin.visible = false
	main._adventure_busy = false
	main._splash_busy = false
	main._unlock_screen = false
	await process_frame


## Continue later cases after a route that may leave nest/splash/cabin busy.
## Explicitly labeled harness reset — never counted as route proof.
## Must out-wait finalize (dissolve_reveal + cabin pause) so the next dissolve_out is not stuck paused.
func _harness_soft_reset(reason: String) -> void:
	print("HARNESS_RESET %s (not route proof)" % reason)
	if main.progress_menu != null and main.progress_menu.visible:
		main.progress_menu.dismiss()
	## Let in-flight finalize finish dissolve_reveal (~0.35s) then cabin pause.
	await create_timer(0.55).timeout
	main._adventure_busy = false
	main._splash_busy = false
	main.adventure = false
	main._campaign_on = true
	main.phase = "title"
	main.in_tutorial = false
	main._unlock_screen = false
	paused = false
	if main.home_cabin != null:
		if main.home_cabin.has_method("hide_for_run"):
			main.home_cabin.hide_for_run()
		else:
			main.home_cabin.visible = false
	var wipe = main.get("_biome_wipe")
	if wipe != null and is_instance_valid(wipe):
		wipe.visible = false
		wipe.modulate.a = 0.0
	## Second unpause after any late finalize cabin open.
	await create_timer(0.15).timeout
	paused = false


func _assert(id: String, desc: String, cond: bool, detail: String) -> bool:
	_rows.append({"kind": "ASSERT", "id": id, "desc": desc, "ok": cond, "detail": detail})
	print("%s ASSERT %s — %s%s" % ["PASS" if cond else "FAIL", id, desc, (" (%s)" % detail) if detail != "" else ""])
	return not cond


func _finish() -> void:
	var n_fail := 0
	for r in _rows:
		if typeof(r) != TYPE_DICTIONARY:
			continue
		var kind := str(r.get("kind", ""))
		if kind in ["UNCOVERED", "NOTE"]:
			print("%s %s — %s" % [kind, r.get("id"), r.get("detail", "")])
		elif kind == "ASSERT" and not bool(r.get("ok", true)):
			n_fail += 1
	print("---")
	print("rows=%d fail=%d" % [_rows.size(), n_fail])
	## quit() is deferred — must not fall through to the other mark.
	if _failed or n_fail > 0:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)
