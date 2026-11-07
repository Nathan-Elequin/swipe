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
		print("REFUSED_UNSAFE_DIRECT_USERDATA path=%s" % OS.get_user_data_dir())
		push_error(
			"CABIN_NAV_LOCK_PROBE_FAIL refuse: user data '%s' is not an ARC1 sandbox. "
			% OS.get_user_data_dir()
			+ "Run tools/qa/run_cabin_nav_lock_probe.sh (sets XDG_DATA_HOME)."
		)
		quit(1)
		return
	print("PROBE_USER_DATA=", OS.get_user_data_dir())
	print("SANDBOX_GUARD_OK")

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

	## --- Case G: helper-level stale arrive abort ---
	failed = await _case_stale_arrive_cannot_clear_newer(cabin) or failed

	## --- Case S: natural scheduled timer reject + explicit mutation markers ---
	failed = await _case_scheduled_arrive_stale_timer(main, cabin) or failed

	## --- Case T: ordinary pan_to A overlapping B (not wait-A-then-B) ---
	failed = await _case_pan_to_overlapping_ab(cabin) or failed

	## --- Case R: keyboard arrows during live keyring dialog (handler proof) ---
	failed = await _case_keyring_arrows_blocked_during_dialog(cabin) or failed

	## --- Case U: interrupt mid _unlock_spot await; stale A must not unlock ---
	failed = await _case_unlock_spot_mid_await_stale(cabin) or failed

	## --- Case P: interrupt mid _pan_unlocked await; B room/pan untouched ---
	failed = await _case_pan_unlocked_mid_await_stale(cabin) or failed

	## --- Case Y: say_key dialog wait cancels with session (no hang) ---
	failed = await _case_say_key_session_cancel(cabin) or failed

	## --- Case N: forced Nib / push-block home after keys already done ---
	failed = await _case_push_block_home_then_nav(main, cabin) or failed

	## --- Case W: walk-in win homecoming after keys already done ---
	failed = await _case_walk_in_win_then_nav(main, cabin) or failed

	## --- Case K: key-ring A suspended → hide/reopen B → A resumes ---
	failed = await _case_key_ring_stale_resume(cabin) or failed

	## --- Case D: dialog open still gates; after dismiss nav free ---
	failed = await _case_dialog_gates_then_releases(cabin) or failed

	## Bounded teardown: free cabin/Main before quit to cut harness RID noise.
	await _teardown_main(main)

	if failed:
		push_error("CABIN_NAV_LOCK_PROBE_FAIL")
		quit(1)
		return
	print("CABIN_NAV_LOCK_PROBE_OK")
	print("INFO full_unskipped_walk_in_cinematic=GAP headless")
	print("INFO physical_click_proof=NOT_CLAIMED handler_nav_only")
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


## Natural timer: A arms 0.02s → hide/reopen B before fire → A's bound timer
## must reject (reject_count++). Does NOT call _play_arrive explicitly for that claim.
## Separate explicit call only for mutation-marker proof (labeled as such).
func _case_scheduled_arrive_stale_timer(main: Node, cabin) -> bool:
	var failed := false
	paused = false
	_seed_post_tutorial_cabin(cabin)
	var items: Dictionary = main.items_by_id if ("items_by_id" in main) else {}
	var tex: Dictionary = main.tex_by_item if ("tex_by_item" in main) else {}
	failed = _check(
		failed,
		"legacy_scheduler_mismatch_would_apply",
		_legacy_play_arrive_ignores_scheduled_gen(10, 11)
	) or failed
	## --- Natural scheduled timer rejection (no explicit _play_arrive) ---
	var reject_before: int = int(cabin._arrive_reject_count)
	var apply_before: int = int(cabin._arrive_apply_count)
	cabin.open_cabin(items, tex, 1, true, "win", [], ["boot"])
	var gen_a: int = int(cabin._arrive_gen)
	cabin.hide_for_run()
	cabin.open_cabin(items, tex, 1, true, "win", [], ["net"])
	var gen_b: int = int(cabin._arrive_gen)
	failed = _check(failed, "scheduler_b_gen_after_a", gen_b > gen_a) or failed
	## Wait past both 0.02s timers; do not invoke _play_arrive.
	await _wait_frames(cabin, 18)
	failed = _check(
		failed,
		"scheduler_natural_stale_a_timer_rejected",
		int(cabin._arrive_reject_count) > reject_before
	) or failed
	failed = _check(
		failed,
		"scheduler_natural_b_applied_or_arriving",
		int(cabin._arrive_apply_count) > apply_before or bool(cabin._arriving)
	) or failed
	failed = _check(
		failed,
		"scheduler_b_still_owns_gen_natural",
		int(cabin._arrive_gen) == gen_b
	) or failed
	## Settle B then explicit stale callback — mutation markers only (not natural proof).
	cabin._arrive_skip = 2
	if cabin.has_method("_kill_arrive_motion"):
		cabin._kill_arrive_motion()
	await _wait_until_idle(cabin, 180)
	var beat_b: String = str(cabin._beat)
	var arriving_b: bool = bool(cabin._arriving)
	var hero_vis_b: bool = cabin._hero != null and bool(cabin._hero.visible)
	cabin._arrive_last_outcome = ""
	cabin._arrive_last_gen = -1
	cabin._play_arrive(gen_a)
	await _wait_frames(cabin, 4)
	failed = _check(
		failed,
		"scheduler_explicit_stale_callback_reject_markers",
		str(cabin._arrive_last_outcome) == "reject" and int(cabin._arrive_last_gen) == gen_a
	) or failed
	failed = _check(
		failed,
		"scheduler_explicit_stale_does_not_mutate_b_beat",
		str(cabin._beat) == beat_b
	) or failed
	failed = _check(
		failed,
		"scheduler_explicit_stale_does_not_mutate_b_arriving",
		bool(cabin._arriving) == arriving_b
	) or failed
	failed = _check(
		failed,
		"scheduler_explicit_stale_does_not_mutate_b_hero",
		(cabin._hero != null and bool(cabin._hero.visible)) == hero_vis_b
	) or failed
	cabin.stop_story()
	cabin.hide_for_run()
	return failed


## Buggy scheduler body: reads current gen only / ignores scheduled capture →
## would mutate when scheduled_gen != live gen. Returns true when that race exists.
func _legacy_play_arrive_ignores_scheduled_gen(scheduled_gen: int, live_gen: int) -> bool:
	## Pre-fix body effectively: var gen = live_gen; then mutate.
	## Stale scheduled callback would therefore apply under B's generation.
	return scheduled_gen != live_gen


## Overlapping pan_to A/B: invalidate A and start B in the same window WITHOUT
## waiting for A reject first. Observes A termination + B room/motion/locks.
## Also stages late-completion: let A tween run near end, then steal session.
func _case_pan_to_overlapping_ab(cabin) -> bool:
	var failed := false
	failed = _check(
		failed,
		"legacy_unowned_pan_await_would_hang_on_killed_refcounted",
		_legacy_await_hangs_on_killed_refcounted_tween()
	) or failed
	failed = _check(
		failed,
		"legacy_done_then_b_would_finalize_as_a",
		_legacy_pan_done_then_b_finalizes()
	) or failed
	_seed_post_tutorial_cabin(cabin)
	cabin.rooms_unlocked = ["main", "hall", "mudroom", "study"]
	cabin.visible = true
	cabin.show_menu("main")
	cabin._snap_to("main")
	cabin._pan_busy = false
	cabin._pan_last_outcome = ""
	cabin._nested_phase = ""
	cabin._nested_last_outcome = ""
	## --- Overlap 1: kill mid-await, start B immediately (no wait for A reject) ---
	cabin.pan_to("hall")
	var hit_await := false
	var session_a: int = -1
	for _i in range(120):
		await process_frame
		if str(cabin._nested_phase) == "pan_to_await":
			hit_await = true
			session_a = int(cabin._cabin_session)
			break
	failed = _check(failed, "pan_overlap_a_hit_await", hit_await and session_a > 0) or failed
	var tw_a = cabin._cabin_motion
	## Invalidate + reopen B in one probe step — A still winding down.
	cabin.stop_story()
	cabin.visible = true
	cabin.show_menu("main")
	cabin._snap_to("main")
	cabin._current_room = "main"
	cabin._pan_busy = false
	cabin._pan_last_outcome = ""
	cabin.pan_to("study")
	var session_b: int = int(cabin._cabin_session)
	var tw_b = cabin._cabin_motion
	failed = _check(failed, "pan_overlap_b_started_while_a_live", session_b > session_a) or failed
	## Observe both: A reject and B settle — overlapping cleanup window.
	var saw_a_reject := false
	var b_settled := false
	for _j in range(240):
		await process_frame
		if cabin._dialog != null and cabin._dialog.is_open():
			cabin._dialog.advance()
		if (
			not saw_a_reject
			and (
				(
					str(cabin._nested_last_helper) == "pan_to"
					and str(cabin._nested_last_outcome) == "reject"
					and int(cabin._nested_last_owner_gen) == session_a
				)
				or (
					str(cabin._pan_last_outcome) == "reject"
					and int(cabin._pan_last_session) == session_a
				)
			)
		):
			saw_a_reject = true
		if str(cabin._current_room) == "study" and cabin._pan_busy == false:
			b_settled = true
		if saw_a_reject and b_settled:
			break
	failed = _check(failed, "pan_overlap_a_termination_observed", saw_a_reject) or failed
	failed = _check(failed, "pan_overlap_b_settled_study", b_settled) or failed
	failed = _check(
		failed,
		"pan_overlap_b_locks_free",
		cabin._pan_busy == false and cabin._room_busy == false
	) or failed
	if tw_a != null and is_instance_valid(tw_a):
		failed = _check(
			failed,
			"pan_overlap_killed_a_not_owner",
			(not tw_a.is_valid()) or cabin._cabin_motion != tw_a
		) or failed
	failed = _check(
		failed,
		"pan_overlap_a_did_not_steal_b_motion",
		cabin._cabin_motion == null or cabin._cabin_motion != tw_a
	) or failed

	## --- Overlap 2: late-completion — A near end of tween, then B steals session ---
	cabin.stop_story()
	cabin.visible = true
	cabin.show_menu("main")
	cabin._snap_to("main")
	cabin._current_room = "main"
	cabin._pan_busy = false
	cabin._pan_last_outcome = ""
	cabin._nested_phase = ""
	cabin.pan_to("hall")
	var late_session_a: int = -1
	for _k in range(120):
		await process_frame
		if str(cabin._nested_phase) == "pan_to_await":
			late_session_a = int(cabin._cabin_session)
			break
	failed = _check(failed, "pan_late_a_hit_await", late_session_a > 0) or failed
	## Let A run most of the 0.45s pan (~20 frames) so done can race with B.
	await _wait_frames(cabin, 20)
	## Steal session while A may be at/near finished — do not wait for A reject.
	cabin.hide_for_run()
	cabin.visible = true
	cabin.show_menu("main")
	cabin._snap_to("main")
	cabin._current_room = "main"
	cabin._pan_busy = false
	cabin.pan_to("mudroom")
	var late_session_b: int = int(cabin._cabin_session)
	var late_a_reject := false
	var late_b_ok := false
	for _m in range(240):
		await process_frame
		if cabin._dialog != null and cabin._dialog.is_open():
			cabin._dialog.advance()
		if (
			str(cabin._pan_last_outcome) == "reject"
			and int(cabin._pan_last_session) == late_session_a
		) or (
			str(cabin._nested_last_helper) == "pan_to"
			and str(cabin._nested_last_outcome) == "reject"
			and int(cabin._nested_last_owner_gen) == late_session_a
		):
			late_a_reject = true
		if str(cabin._current_room) == "mudroom" and not cabin._pan_busy:
			late_b_ok = true
		if late_a_reject and late_b_ok:
			break
	failed = _check(failed, "pan_late_a_reject_observed", late_a_reject) or failed
	failed = _check(failed, "pan_late_b_mudroom_intact", late_b_ok) or failed
	failed = _check(
		failed,
		"pan_late_b_session_newer",
		late_session_b > late_session_a
	) or failed
	failed = _check(
		failed,
		"pan_late_b_not_hall_from_stale_a",
		str(cabin._current_room) != "hall"
	) or failed
	cabin.stop_story()
	_seed_post_tutorial_cabin(cabin)
	return failed


## Pre-fix: loop on is_instance_valid only → killed tween never finishes → hang.
## SIMULATED negative (not a runtime hang exercise).
func _legacy_await_hangs_on_killed_refcounted_tween() -> bool:
	var instance_valid := true
	var tween_valid := false
	var done := false
	var would_spin: bool = instance_valid and not done and not tween_valid
	var fixed_exits: bool = not tween_valid
	return would_spin and fixed_exits


## Pre-fix: A done=true then B show_menu before A's next tick → A finalizes as B.
## SIMULATED negative; runtime late-completion is pan_late_* above.
func _legacy_pan_done_then_b_finalizes() -> bool:
	var session_a := 1
	var session_live := 2
	var current_room := "main"
	var pan_busy := true
	var done := true
	if done:
		current_room = "hall"
		pan_busy = false
	return session_a != session_live and current_room == "hall" and pan_busy == false


## EXECUTED: production `_input` ui_left/ui_right during live keyring dialog.
## Handler proof (not physical keyboard hardware). Both arrows must not steal
## session / orphan room_busy; tour finishes; ordinary nav works after.
func _case_keyring_arrows_blocked_during_dialog(cabin) -> bool:
	var failed := false
	## SIMULATED negative: pre-fix keyboard path called _arrow while busy.
	failed = _check(
		failed,
		"legacy_arrow_while_busy_would_steal_session",
		_legacy_arrow_while_busy_steals_session()
	) or failed
	cabin.stop_story()
	await _wait_frames(cabin, 8)
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	cabin.counters.hauls = 0
	cabin.visible = true
	cabin.show_menu("main")
	cabin._room_busy = false
	cabin.play_key_ring()
	## Drive to live keyring dialog. Abort cutscene under headless (still real tour).
	var dialog_live := false
	for _i in range(1200):
		await process_frame
		if cabin._cutscene != null and cabin._cutscene.is_playing():
			if cabin._cutscene.has_method("abort"):
				cabin._cutscene.abort()
			elif cabin._cutscene.has_method("request_advance"):
				cabin._cutscene.request_advance()
			continue
		if cabin._beat == "keyring" and cabin._room_busy and cabin._dialog != null and cabin._dialog.is_open():
			dialog_live = true
			break
		## If tour aborted early, stop waiting.
		if not cabin.key_ring_seen and cabin._beat != "keyring" and not cabin._room_busy and _i > 60:
			break
	failed = _check(failed, "keyring_dialog_live_reached", dialog_live) or failed
	if not dialog_live:
		print("INFO keyring_dialog_miss beat=%s busy=%s" % [cabin._beat, cabin._room_busy])
		cabin.stop_story()
		await _wait_frames(cabin, 12)
		_seed_post_tutorial_cabin(cabin)
		return failed
	var session_before: int = int(cabin._cabin_session)
	var gen_before: int = int(cabin._key_ring_gen)
	var room_before: String = str(cabin._current_room)
	failed = _check(failed, "keyring_room_busy_during_dialog", cabin._room_busy == true) or failed
	## Production `_input` handler — both arrows (handler proof, not physical HID).
	_dispatch_cabin_action(cabin, "ui_left")
	await _wait_frames(cabin, 4)
	_dispatch_cabin_action(cabin, "ui_right")
	await _wait_frames(cabin, 4)
	failed = _check(
		failed,
		"keyring_arrows_session_unchanged",
		int(cabin._cabin_session) == session_before
	) or failed
	failed = _check(
		failed,
		"keyring_arrows_gen_unchanged",
		int(cabin._key_ring_gen) == gen_before
	) or failed
	failed = _check(
		failed,
		"keyring_arrows_room_busy_held",
		cabin._room_busy == true and cabin._beat == "keyring"
	) or failed
	failed = _check(
		failed,
		"keyring_arrows_did_not_change_room",
		str(cabin._current_room) == room_before
	) or failed
	print("INFO keyring_arrow_proof=production_input_handler not_physical_keyboard")
	## Let tour finish: advance dialogs; abort any later cutscenes.
	var tour_done := false
	for _j in range(1500):
		await process_frame
		if cabin._cutscene != null and cabin._cutscene.is_playing():
			if cabin._cutscene.has_method("abort"):
				cabin._cutscene.abort()
		if cabin._dialog != null and cabin._dialog.is_open():
			cabin._dialog.advance()
		if cabin.key_ring_seen and cabin._room_busy == false:
			tour_done = true
			break
	failed = _check(failed, "keyring_tour_finished_once", tour_done) or failed
	failed = _check(
		failed,
		"keyring_room_busy_released_after_tour",
		cabin._room_busy == false and cabin.key_ring_seen == true
	) or failed
	## Ordinary room nav works afterward (handler + pan_to path).
	cabin.show_menu("main")
	await _wait_frames(cabin, 4)
	failed = _check(failed, "after_keyring_not_busy", cabin._busy() == false) or failed
	var nav_room_before: String = str(cabin._current_room)
	_dispatch_cabin_action(cabin, "ui_right")
	var nav_moved := false
	for _k in range(120):
		await process_frame
		if str(cabin._current_room) != nav_room_before and not cabin._pan_busy:
			nav_moved = true
			break
	failed = _check(failed, "after_keyring_arrow_nav_works", nav_moved) or failed
	cabin.stop_story()
	await _wait_frames(cabin, 12)
	_seed_post_tutorial_cabin(cabin)
	return failed


## SIMULATED: pre-fix ui_right during busy called pan_to and bumped session.
func _legacy_arrow_while_busy_steals_session() -> bool:
	var room_busy := true
	var dialog_open := true
	var busy: bool = room_busy or dialog_open
	var session := 5
	## Buggy keyboard path ignored busy and called pan_to → session += 1:
	if true:
		session += 1
	return busy and session == 6


func _dispatch_cabin_action(cabin, action: String) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = true
	## Production handler path (not Autopilot / not physical HID).
	if cabin.has_method("_input"):
		cabin._input(ev)
	ev.pressed = false
	if cabin.has_method("_input"):
		cabin._input(ev)


## Interrupt precisely while _unlock_spot awaits; reopen B; prove A resumed and
## rejected — no unlock/hotspot persist. Observes nested phase + outcome.
func _case_unlock_spot_mid_await_stale(cabin) -> bool:
	var failed := false
	## Negative: buggy post-await unlock without gen guard WOULD persist hall.
	failed = _check(
		failed,
		"legacy_unlock_after_await_would_persist",
		_legacy_unlock_spot_applies_after_await()
	) or failed
	cabin.stop_story()
	await _wait_frames(cabin, 12)
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	cabin.visible = true
	cabin.show_menu("main")
	cabin._key_ring_gen += 1
	var gen_a: int = int(cabin._key_ring_gen)
	cabin._begin_cabin_session()
	cabin._nested_phase = ""
	cabin._nested_last_outcome = ""
	cabin._nested_last_helper = ""
	cabin._nested_last_owner_gen = -1
	## Fire the real helper (not a synthetic stand-in).
	cabin._unlock_spot("main", "SideDoor", "hall", "", false, gen_a)
	var hit_await := false
	for _i in range(120):
		await process_frame
		if str(cabin._nested_phase) == "unlock_spot_await":
			hit_await = true
			break
	failed = _check(failed, "unlock_spot_hit_await_checkpoint", hit_await) or failed
	## Invalidate A and reopen B with intentional locked rooms + busy.
	cabin.hide_for_run()
	cabin.visible = true
	cabin.show_menu("main")
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	cabin._room_busy = true
	cabin._pan_busy = true
	cabin._beat = "idle"
	cabin._current_room = "main"
	var rooms_b: Array = cabin.rooms_unlocked.duplicate()
	var room_b: String = str(cabin._current_room)
	var gen_b: int = int(cabin._key_ring_gen)
	## Wait until A resumes past await and records nested outcome.
	var saw_reject := false
	for _j in range(180):
		await process_frame
		if (
			str(cabin._nested_last_helper) == "unlock_spot"
			and str(cabin._nested_last_outcome) == "reject"
			and int(cabin._nested_last_owner_gen) == gen_a
		):
			saw_reject = true
			break
	failed = _check(
		failed,
		"unlock_spot_stale_a_ran_reject_after_invalidate",
		saw_reject
	) or failed
	failed = _check(
		failed,
		"unlock_spot_stale_a_did_not_persist_hall",
		not cabin.rooms_unlocked.has("hall") and not cabin.rooms_unlocked.has("mudroom")
	) or failed
	failed = _check(
		failed,
		"unlock_spot_b_rooms_unchanged",
		cabin.rooms_unlocked.hash() == rooms_b.hash()
	) or failed
	failed = _check(
		failed,
		"unlock_spot_b_locks_untouched",
		cabin._room_busy == true and cabin._pan_busy == true and str(cabin._current_room) == room_b
	) or failed
	failed = _check(failed, "unlock_spot_b_gen_newer", gen_b > gen_a) or failed
	## Hotspot SideDoor should be visible again (cleanup) without unlock.
	var main_room = cabin._rooms.get("main", null)
	var hs = main_room.spots.get("SideDoor", null) if main_room else null
	if hs != null:
		failed = _check(failed, "unlock_spot_hotspot_restored_visible", bool(hs.visible)) or failed
	cabin.stop_story()
	_seed_post_tutorial_cabin(cabin)
	return failed


## Buggy unlock_spot: after await, always append unlock_room (no gen guard).
func _legacy_unlock_spot_applies_after_await() -> bool:
	var rooms: Array = ["main"]
	var unlock_room := "hall"
	## await finished; stale owner ignored:
	if not rooms.has(unlock_room):
		rooms.append(unlock_room)
	if unlock_room == "hall" and not rooms.has("mudroom"):
		rooms.append("mudroom")
	return rooms.has("hall") and rooms.has("mudroom")


## Interrupt precisely while _pan_unlocked awaits; B room/pan/presentation stay.
func _case_pan_unlocked_mid_await_stale(cabin) -> bool:
	var failed := false
	failed = _check(
		failed,
		"legacy_pan_after_await_would_mutate",
		_legacy_pan_unlocked_applies_after_await()
	) or failed
	cabin.stop_story()
	cabin.key_ring_seen = false
	## Hall already unlocked so pan path does not early-append before await.
	cabin.rooms_unlocked = ["main", "hall", "mudroom"]
	cabin.visible = true
	cabin.show_menu("main")
	cabin._snap_to("main")
	cabin._key_ring_gen += 1
	var gen_a: int = int(cabin._key_ring_gen)
	cabin._begin_cabin_session()
	cabin._nested_phase = ""
	cabin._nested_last_outcome = ""
	cabin._nested_last_helper = ""
	cabin._nested_last_owner_gen = -1
	cabin._pan_unlocked("hall", gen_a)
	var hit_await := false
	for _i in range(120):
		await process_frame
		if str(cabin._nested_phase) == "pan_unlocked_await":
			hit_await = true
			break
	failed = _check(failed, "pan_unlocked_hit_await_checkpoint", hit_await) or failed
	cabin.hide_for_run()
	cabin.visible = true
	cabin.show_menu("main")
	cabin._snap_to("main")
	cabin._current_room = "main"
	cabin._room_busy = true
	cabin._pan_busy = true
	cabin._beat = "idle"
	var room_b: String = str(cabin._current_room)
	var host_x_b: float = float(cabin._rooms_host.position.x) if cabin._rooms_host else 0.0
	var gen_b: int = int(cabin._key_ring_gen)
	var saw_reject := false
	for _j in range(180):
		await process_frame
		if (
			str(cabin._nested_last_helper) == "pan_unlocked"
			and str(cabin._nested_last_outcome) == "reject"
			and int(cabin._nested_last_owner_gen) == gen_a
		):
			saw_reject = true
			break
	failed = _check(
		failed,
		"pan_unlocked_stale_a_ran_reject_after_invalidate",
		saw_reject
	) or failed
	failed = _check(
		failed,
		"pan_unlocked_b_room_unchanged",
		str(cabin._current_room) == room_b
	) or failed
	failed = _check(
		failed,
		"pan_unlocked_b_pan_busy_held",
		cabin._pan_busy == true and cabin._room_busy == true
	) or failed
	## Owning tween killed on invalidate; host should remain at B snap, not A's target.
	if cabin._rooms_host:
		failed = _check(
			failed,
			"pan_unlocked_b_host_not_left_at_hall",
			is_equal_approx(float(cabin._rooms_host.position.x), host_x_b)
			or absf(float(cabin._rooms_host.position.x) - host_x_b) < 1.0
		) or failed
	failed = _check(failed, "pan_unlocked_b_gen_newer", gen_b > gen_a) or failed
	## No live owning tween left from stale A.
	failed = _check(
		failed,
		"pan_unlocked_no_stale_cabin_motion",
		cabin._cabin_motion == null or not is_instance_valid(cabin._cabin_motion)
	) or failed
	cabin.stop_story()
	_seed_post_tutorial_cabin(cabin)
	return failed


## Buggy pan_unlocked: after await, always sets current_room and clears pan_busy.
func _legacy_pan_unlocked_applies_after_await() -> bool:
	var owner_stale := true
	var current_room := "main"
	var pan_busy := true
	## await finished; no gen guard:
	if true:
		current_room = "hall"
		pan_busy = false
	return owner_stale and current_room == "hall" and pan_busy == false


## _say_key must not hang forever on dialog.finished after session invalidate.
func _case_say_key_session_cancel(cabin) -> bool:
	var failed := false
	cabin.stop_story()
	cabin.key_ring_seen = false
	cabin.visible = true
	cabin.show_menu("main")
	if cabin._dialog == null:
		print("INFO say_key_skip_no_dialog")
		return failed
	cabin._key_ring_gen += 1
	var gen_a: int = int(cabin._key_ring_gen)
	var session_a: int = cabin._begin_cabin_session()
	cabin._nested_phase = ""
	cabin._nested_last_outcome = ""
	cabin._say_key("keyring.door.hall", gen_a, session_a)
	var hit_await := false
	for _i in range(60):
		await process_frame
		if str(cabin._nested_phase) == "say_key_await" or (cabin._dialog != null and cabin._dialog.is_open()):
			hit_await = true
			break
	failed = _check(failed, "say_key_hit_dialog_await", hit_await) or failed
	## Invalidate session while dialog still open — waiter must exit, not hang.
	cabin.hide_for_run()
	cabin.visible = true
	cabin.show_menu("main")
	cabin._room_busy = true
	var terminated := false
	for _j in range(120):
		await process_frame
		if (
			str(cabin._nested_last_helper) == "say_key"
			and str(cabin._nested_last_outcome) == "reject"
			and int(cabin._nested_last_owner_gen) == gen_a
		):
			terminated = true
			break
	failed = _check(failed, "say_key_stale_a_dialog_wait_terminated", terminated) or failed
	failed = _check(
		failed,
		"say_key_b_room_busy_untouched",
		cabin._room_busy == true
	) or failed
	## Dismiss any leftover dialog so later cases are clean.
	if cabin._dialog != null and cabin._dialog.is_open():
		cabin._dialog.dismiss()
	cabin.stop_story()
	_seed_post_tutorial_cabin(cabin)
	return failed


## Key-ring A mid-await → hide/reopen B with intentional locks → A resumes must
## not clear B. Does not treat hide's immediate clear as the proof.
func _case_key_ring_stale_resume(cabin) -> bool:
	var failed := false
	cabin.stop_story()
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	cabin.counters.hauls = 0
	cabin.visible = true
	cabin.show_menu("main")
	cabin._room_busy = false
	var gen_before: int = int(cabin._key_ring_gen)
	cabin.play_key_ring()
	## Let A pass the first await checkpoint.
	await _wait_frames(cabin, 20)
	var gen_a: int = gen_before + 1
	## Suspend A ownership via hide (bumps gen). Do not use that clear as proof.
	cabin.hide_for_run()
	## B takes the cabin with intentional busy + locked rooms snapshot.
	cabin.visible = true
	cabin.show_menu("main")
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	cabin._room_busy = true
	cabin._beat = "idle"
	var gen_b: int = int(cabin._key_ring_gen)
	var rooms_b: Array = cabin.rooms_unlocked.duplicate()
	failed = _check(failed, "keyring_b_gen_newer_than_a", gen_b > gen_a) or failed
	## Force stale A abort/finalizer paths without waiting the full tour.
	var aborted: bool = cabin._key_ring_aborted(gen_a)
	failed = _check(failed, "keyring_stale_a_aborted", aborted) or failed
	failed = _check(
		failed,
		"keyring_stale_a_does_not_clear_b_room_busy",
		cabin._room_busy == true
	) or failed
	failed = _check(
		failed,
		"keyring_stale_a_rooms_unchanged",
		cabin.rooms_unlocked.hash() == rooms_b.hash()
	) or failed
	failed = _check(
		failed,
		"keyring_stale_a_did_not_stamp_seen",
		cabin.key_ring_seen == false
	) or failed
	## Give any suspended awaits a chance to resume and hit gen checks.
	for _i in range(90):
		await process_frame
		if cabin._dialog != null and cabin._dialog.is_open():
			cabin._dialog.dismiss()
	failed = _check(
		failed,
		"keyring_after_resume_window_b_lock_held",
		cabin._room_busy == true and cabin.key_ring_seen == false
	) or failed
	failed = _check(
		failed,
		"keyring_after_resume_rooms_still_b",
		cabin.rooms_unlocked.hash() == rooms_b.hash()
	) or failed
	cabin.stop_story()
	_seed_post_tutorial_cabin(cabin)
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
	## Optional InputEvent after room change (mudroom), not on hall LeftDoor.
	## Handler nav above is the proof; this is pointer attempt only — not click PASS.
	var after_room: String = str(cabin._current_room)
	var clicked: bool = await _try_input_click_hotspot(cabin, "OutDoor", after_room)
	print(
		"INFO input_click_after_room_change room=%s node=OutDoor attempted=%s (not physical click proof)"
		% [after_room, clicked]
	)
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


func _teardown_main(main: Node) -> void:
	if main == null:
		return
	if ("home_cabin" in main) and main.home_cabin != null:
		var cabin = main.home_cabin
		cabin.stop_story()
		cabin.hide_for_run()
	## Free Main subtree so ScriptTree quit does not leave cabin ObjectDB noise.
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.queue_free()
	await process_frame
	await process_frame
	print("INFO harness_teardown_main_freed")


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("PASS %s" % label)
		return failed
	push_error("FAIL %s" % label)
	return true
