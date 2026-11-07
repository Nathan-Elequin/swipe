extends SceneTree
## ARC1 bug-specific probe (not ARC2 campaign bank suite).
##
## Safety: refuse to run unless user:// is under an ARC1 sandbox path
## (tools/qa/run_cabin_nav_lock_probe.sh sets XDG_DATA_HOME). Never backup,
## restore, or delete Nathan's real Spinheritance userdata.
##
## Cases mix:
##   - Generation ownership (stale arrive must not clear newer locks)
##   - Real post-tutorial forced-Nib / push-block homecoming + dialog settle
##   - Real walk-in win homecoming after keys already done
##   - Hotspot handler `_on_hotspot` (same signal target rooms emit) after settle
##   - Optional viewport InputEvent click when a Hit control is available
##
## Does NOT claim Autopilot click driving or full Brand New→tutorial→Verdant
## combat autopilot. Labels injected-flag cases clearly if any remain.
##
## Run via: ./tools/qa/run_cabin_nav_lock_probe.sh

const MAIN_SCENE := "res://scenes/main.tscn"


func _initialize() -> void:
	var failed := false
	if not _sandbox_ok():
		push_error(
			"CABIN_NAV_LOCK_PROBE_FAIL refuse: user data '%s' is not an ARC1 sandbox. "
			% OS.get_user_data_dir()
			+ "Run tools/qa/run_cabin_nav_lock_probe.sh (sets XDG_DATA_HOME)."
		)
		quit(1)
		return
	print("PROBE_USER_DATA=", OS.get_user_data_dir())

	var err: Error = change_scene_to_file(MAIN_SCENE)
	if err != OK:
		push_error("CABIN_NAV_LOCK_PROBE_FAIL change_scene err=%s" % err)
		quit(1)
		return

	var main: Node = null
	var tries := 0
	while tries < 240:
		await process_frame
		tries += 1
		main = root.get_node_or_null("Main")
		if main != null and ("home_cabin" in main) and main.home_cabin != null:
			break
	if main == null or main.home_cabin == null:
		push_error("CABIN_NAV_LOCK_PROBE_FAIL home_cabin missing after main boot")
		quit(1)
		return

	var cabin = main.home_cabin
	## Sandbox-only seed. Real userdata is a different directory.
	_seed_post_tutorial_cabin(cabin)

	## --- Contract note: legacy arrive abort cleared on ANY !_arrive_alive ---
	failed = _check(
		failed,
		"legacy_gen_mismatch_would_clear_newer",
		_legacy_arrive_aborted_clears_on_gen_mismatch()
	) or failed

	## --- Case G: interleaved A hide B then stale A resume ---
	failed = await _case_stale_arrive_cannot_clear_newer(cabin) or failed

	## --- Case N: forced Nib / push-block home after keys already done ---
	failed = await _case_push_block_home_then_nav(main, cabin) or failed

	## --- Case W: walk-in win homecoming after keys already done ---
	failed = await _case_walk_in_win_then_nav(main, cabin) or failed

	## --- Case K: key-ring mid-hide abort (keys NOT yet done) ---
	## Secondary class — reported first-return symptom often has keys done.
	failed = await _case_key_ring_hide_abort(cabin) or failed

	## --- Case D: dialog open still gates; after dismiss nav free ---
	failed = await _case_dialog_gates_then_releases(cabin) or failed

	if failed:
		push_error("CABIN_NAV_LOCK_PROBE_FAIL")
		quit(1)
		return
	print("CABIN_NAV_LOCK_PROBE_OK")
	quit(0)


func _sandbox_ok() -> bool:
	var ud := OS.get_user_data_dir().replace("\\", "/")
	if ud.find("arc1-cabin-nav-sandbox") >= 0:
		return true
	## Also accept explicit probe marker file written only by the wrapper.
	return FileAccess.file_exists("user://.arc1_probe_sandbox")


func _seed_post_tutorial_cabin(cabin) -> void:
	cabin.stop_story()
	cabin.intro_seen = true
	cabin.tutorial_done = true
	cabin.tutorial_declined = false
	cabin.nib_first_done = true
	cabin.key_ring_seen = true
	cabin.ending_seen = false
	cabin.counters = {"delves": 1, "homecomings": 1, "hauls": 1, "losses": 0}
	cabin._sync_progress_doors()
	cabin._room_busy = false
	cabin._pan_busy = false
	cabin._door_busy = false
	cabin._arriving = false


## Mirrors 91bdcdf6 unsafe body: cleared locks whenever !_arrive_alive(gen).
## Returns true when that legacy body WOULD clear newer locks (proves the race).
func _legacy_arrive_aborted_clears_on_gen_mismatch() -> bool:
	var arrive_gen := 2
	var gen_old := 1
	var visible := true
	var cleared := false
	## legacy:
	##   if arrive_alive(gen): return false
	##   abort_cabin_interaction(); return true
	var arrive_alive: bool = visible and gen_old == arrive_gen
	if not arrive_alive:
		cleared = true
	return cleared


func _case_stale_arrive_cannot_clear_newer(cabin) -> bool:
	var failed := false
	_seed_post_tutorial_cabin(cabin)
	cabin.visible = true
	## Generation A owns an in-flight arrive.
	cabin._arrive_gen = 10
	cabin._arriving = true
	cabin._room_busy = false
	cabin._pan_busy = false
	cabin._beat = "pan"
	## Hide invalidates A and clears A's locks.
	cabin.hide_for_run()
	var gen_a: int = 10
	## Generation B starts a new owned arrive.
	cabin.visible = true
	cabin._arrive_gen = 11
	cabin._arriving = true
	cabin._room_busy = true
	cabin._pan_busy = true
	cabin._beat = "pan"
	## Stale A resume.
	var aborted: bool = cabin._arrive_aborted(gen_a)
	failed = _check(failed, "stale_a_reports_aborted", aborted) or failed
	failed = _check(
		failed,
		"stale_a_does_not_clear_b_arriving",
		cabin._arriving == true and cabin._arrive_gen == 11
	) or failed
	failed = _check(
		failed,
		"stale_a_does_not_clear_b_room_busy",
		cabin._room_busy == true
	) or failed
	failed = _check(
		failed,
		"stale_a_does_not_clear_b_pan_busy",
		cabin._pan_busy == true
	) or failed
	## Matching-gen hide abort still clears.
	cabin._arrive_gen = 12
	cabin._arriving = true
	cabin._room_busy = true
	var gen_b2: int = 12
	cabin.visible = false
	var aborted_own: bool = cabin._arrive_aborted(gen_b2)
	failed = _check(failed, "own_gen_hidden_aborts", aborted_own) or failed
	failed = _check(
		failed,
		"own_gen_hidden_clears_arriving",
		cabin._arriving == false and cabin._room_busy == false
	) or failed
	cabin.visible = true
	cabin.stop_story()
	return failed


func _case_push_block_home_then_nav(main: Node, cabin) -> bool:
	var failed := false
	_seed_post_tutorial_cabin(cabin)
	cabin.items_by_id = main.items_by_id if ("items_by_id" in main) else {}
	cabin.tex_by_item = main.tex_by_item if ("tex_by_item" in main) else {}
	## Real push-block landing (forced Nib home). Do not await the whole call
	## blindly — it waits on dialog.finished, so advance dialog in parallel.
	cabin.open_hall_after_push_block("b1", "Verdant Hollow", [], ["boot", "net"])
	var landed := false
	for _i in range(300):
		await process_frame
		if cabin._dialog != null and cabin._dialog.is_open():
			if cabin._dialog.has_method("advance"):
				cabin._dialog.advance()
		## Station rock sets beat to "rock" after idle land — still free cabin.
		if _cabin_settled_free(cabin):
			landed = true
			break
	failed = _check(failed, "push_block_settled_not_busy", landed and cabin.visible) or failed
	failed = _check(
		failed,
		"push_block_rooms_unlocked",
		cabin.is_room_unlocked("hall") and cabin.is_room_unlocked("mudroom")
	) or failed
	var room_before: String = str(cabin._current_room)
	## Drive the same handler rooms connect hotspot_activated to.
	## SideDoor from hall pans to mudroom (async flash then pan_to).
	cabin._on_hotspot("SideDoor", room_before)
	var moved := false
	for _j in range(180):
		await process_frame
		if cabin._dialog != null and cabin._dialog.is_open():
			cabin._dialog.advance()
		if str(cabin._current_room) != room_before and not cabin._pan_busy:
			moved = true
			break
	failed = await _dismiss_cabin_dialog(cabin) or failed
	failed = _check(
		failed,
		"push_block_hotspot_nav_not_stuck_busy",
		cabin._room_busy == false and cabin._arriving == false and cabin._pan_busy == false
	) or failed
	failed = _check(failed, "push_block_hotspot_changed_room", moved) or failed
	## Best-effort InputEvent into Hit control (not Autopilot; may no-op headless).
	var clicked: bool = await _try_input_click_hotspot(cabin, "LeftDoor", str(cabin._current_room))
	print("INFO input_click_leftdoor_attempted=%s" % clicked)
	await _wait_until_idle(cabin, 90)
	failed = await _dismiss_cabin_dialog(cabin) or failed
	failed = _check(
		failed,
		"push_block_after_input_attempt_not_hard_locked",
		cabin._room_busy == false and cabin._arriving == false and cabin._pan_busy == false
	) or failed
	return failed


func _case_walk_in_win_then_nav(main: Node, cabin) -> bool:
	var failed := false
	_seed_post_tutorial_cabin(cabin)
	## Title/boot may leave the SceneTree paused; cabin is ALWAYS, but unpause
	## matches a free cabin session after homecoming.
	paused = false
	var items: Dictionary = main.items_by_id if ("items_by_id" in main) else {}
	var tex: Dictionary = main.tex_by_item if ("tex_by_item" in main) else {}
	cabin.open_cabin(items, tex, 1, true, "win", [], ["boot"])
	## Prove arrive actually started (keys already done → no key-ring).
	var started := false
	for _i in range(180):
		await process_frame
		if cabin._arriving and (cabin._beat == "pan" or cabin._beat == "walk"):
			started = true
			break
	failed = _check(failed, "walk_in_arrive_started", started) or failed
	## GAP (headless): `_walk_path` tween_method does not finish under this
	## SceneTree probe (stuck beat=walk for 20s+). Players skip arrive the same
	## way `_on_hotspot` does during arrive — exercise that recovery, then nav.
	print("INFO headless_walk_in_full_cinematic=GAP use_player_arrive_skip")
	cabin._arrive_skip = maxi(int(cabin._arrive_skip), 2)
	if cabin.has_method("_kill_arrive_motion"):
		cabin._kill_arrive_motion()
	var settled := false
	for _j in range(300):
		await process_frame
		if cabin._dialog != null and cabin._dialog.is_open():
			cabin._dialog.advance()
		if _cabin_settled_free(cabin):
			settled = true
			break
	failed = _check(failed, "walk_in_after_skip_settled", settled) or failed
	failed = _check(
		failed,
		"walk_in_after_skip_not_busy",
		settled and not cabin._arriving and not cabin._room_busy
	) or failed
	var start_room: String = str(cabin._current_room)
	cabin._on_hotspot("SideDoor", start_room)
	var walked := false
	for _k in range(180):
		await process_frame
		if cabin._dialog != null and cabin._dialog.is_open():
			cabin._dialog.advance()
		if str(cabin._current_room) != start_room and not cabin._pan_busy:
			walked = true
			break
	failed = await _dismiss_cabin_dialog(cabin) or failed
	failed = _check(
		failed,
		"walk_in_after_side_door_not_hard_locked",
		cabin._room_busy == false and cabin._arriving == false and cabin._pan_busy == false
	) or failed
	failed = _check(failed, "walk_in_side_door_changed_room", walked) or failed
	return failed


func _case_key_ring_hide_abort(cabin) -> bool:
	var failed := false
	## Secondary abort class (not the primary first-return-with-keys-done claim).
	cabin.stop_story()
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	cabin.counters.hauls = 0
	cabin.visible = true
	cabin.show_menu("main")
	cabin._room_busy = false
	cabin.play_key_ring()
	await _wait_frames(cabin, 4)
	cabin.hide_for_run()
	for _i in range(120):
		await process_frame
		if cabin._room_busy == false:
			break
	failed = _check(
		failed,
		"key_ring_hide_abort_room_idle",
		cabin._room_busy == false
	) or failed
	cabin.visible = true
	cabin.show_menu("main")
	failed = _check(
		failed,
		"after_key_ring_abort_show_menu_free",
		cabin._busy() == false
	) or failed
	## Restore post-tutorial seed for later cases.
	_seed_post_tutorial_cabin(cabin)
	return failed


func _case_dialog_gates_then_releases(cabin) -> bool:
	var failed := false
	_seed_post_tutorial_cabin(cabin)
	cabin.visible = true
	cabin.show_menu("main")
	if cabin._dialog == null:
		print("INFO dialog_missing_skip_gate_case")
		return failed
	cabin._dialog.say(["nib.homecoming"], [], {"biome": "Verdant Hollow"})
	await _wait_frames(cabin, 4)
	failed = _check(failed, "dialog_open_is_busy", cabin._busy() == true) or failed
	## Hotspot while dialog open should advance/ignore, not hard-lock flags.
	cabin._on_hotspot("SideDoor", "main")
	await _wait_frames(cabin, 4)
	failed = await _dismiss_cabin_dialog(cabin) or failed
	await _wait_frames(cabin, 4)
	failed = _check(
		failed,
		"dialog_dismiss_releases_busy",
		cabin._busy() == false and cabin._room_busy == false
	) or failed
	return failed


func _dismiss_cabin_dialog(cabin) -> bool:
	if cabin._dialog == null:
		return false
	var guard := 0
	while cabin._dialog.is_open() and guard < 40:
		if cabin._dialog.has_method("advance"):
			cabin._dialog.advance()
		elif cabin._dialog.has_method("dismiss"):
			cabin._dialog.dismiss()
			break
		await process_frame
		guard += 1
	if cabin._dialog.is_open() and cabin._dialog.has_method("dismiss"):
		cabin._dialog.dismiss()
	return false


func _cabin_settled_free(cabin) -> bool:
	if not cabin.visible:
		return false
	if cabin._arriving or cabin._room_busy or cabin._pan_busy or cabin._door_busy:
		return false
	if cabin._dialog != null and cabin._dialog.is_open():
		return false
	## "rock" is the station idle loop after _play_station; still navigable.
	var beat := str(cabin._beat)
	return beat == "idle" or beat == "rock" or beat == ""


func _wait_frames(_cabin, n: int) -> void:
	for _i in range(n):
		await process_frame


func _wait_until_idle(cabin, max_frames: int) -> void:
	for _i in range(max_frames):
		await process_frame
		if cabin._dialog != null and cabin._dialog.is_open():
			cabin._dialog.advance()
		if _cabin_settled_free(cabin):
			return


func _try_input_click_hotspot(cabin, node_name: String, room_id: String) -> bool:
	var room = cabin._rooms.get(room_id, null)
	if room == null:
		return false
	var hs = room.spots.get(node_name, null) if ("spots" in room) else null
	if hs == null or not ("_hit" in hs) or hs._hit == null:
		return false
	var hit: Control = hs._hit
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	ev.position = hit.get_global_rect().get_center()
	ev.global_position = ev.position
	hit.gui_input.emit(ev)
	var ev_up := InputEventMouseButton.new()
	ev_up.button_index = MOUSE_BUTTON_LEFT
	ev_up.pressed = false
	ev_up.position = ev.position
	ev_up.global_position = ev.position
	hit.gui_input.emit(ev_up)
	return true


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("PASS %s" % label)
		return failed
	push_error("FAIL %s" % label)
	return true
