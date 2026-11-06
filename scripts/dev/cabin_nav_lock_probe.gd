extends SceneTree
## ARC1 bug-specific probe (not the ARC2 campaign bank suite).
## Proves first-return cabin navigation hard-lock class:
##   play_key_ring early-exit / hide abort leaves _room_busy (or _pan_busy /
##   _arriving) sticky, then show_menu re-enters idle without clearing →
##   _busy() blocks every door hotspot.
## Does NOT claim Autopilot click driving. Boots main.tscn once for a real
## HomeCabin instance, then drives flags + public methods only.
##
## Run:
##   GODOT=... godot --headless --path . --script res://scripts/dev/cabin_nav_lock_probe.gd
##
## Exit 0 + CABIN_NAV_LOCK_PROBE_OK means the lock class is fixed.
## Exit 1 prints CABIN_NAV_LOCK_PROBE_FAIL with the blocking predicate.

const MAIN_SCENE := "res://scenes/main.tscn"
const SAVE_BACKUP := "user://home_cabin.json.arc1_probe_bak"
const SAVE_PATH := "user://home_cabin.json"


func _initialize() -> void:
	var failed := false
	_backup_save()
	var err: Error = change_scene_to_file(MAIN_SCENE)
	if err != OK:
		push_error("CABIN_NAV_LOCK_PROBE_FAIL change_scene err=%s" % err)
		_restore_save()
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
	if main == null or not ("home_cabin" in main) or main.home_cabin == null:
		push_error("CABIN_NAV_LOCK_PROBE_FAIL home_cabin missing after main boot")
		_restore_save()
		quit(1)
		return
	var cabin = main.home_cabin
	## Isolate from the player's real cabin save for this probe.
	if cabin.has_method("clear_to_fresh_save"):
		cabin.clear_to_fresh_save()
	cabin.intro_seen = true
	cabin.tutorial_done = true
	cabin.nib_first_done = true
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	cabin.counters = {"delves": 0, "homecomings": 0, "hauls": 1, "losses": 0}
	cabin.stop_story()

	## --- Case 1: sticky _room_busy after key-ring abort class + show_menu ---
	## Mirrors play_key_ring setting _room_busy then early-returning on
	## not-visible / hide_for_run without clearing, then title overlay
	## calling show_menu() when cabin was kept marked visible.
	cabin._room_busy = true
	cabin._arriving = false
	cabin._pan_busy = false
	cabin.visible = true
	cabin.show_menu("main")
	failed = _check(
		failed,
		"show_menu_clears_sticky_room_busy",
		cabin._room_busy == false and cabin._busy() == false
	) or failed
	failed = _check(
		failed,
		"hotspot_side_door_not_busy_blocked",
		not cabin._busy()
	) or failed

	## --- Case 2: hide_for_run must abort sticky room/arrive/pan flags ---
	cabin._room_busy = true
	cabin._arriving = true
	cabin._pan_busy = true
	cabin._door_busy = true
	cabin.hide_for_run()
	failed = _check(
		failed,
		"hide_for_run_clears_sticky_busy",
		cabin._room_busy == false
		and cabin._arriving == false
		and cabin._pan_busy == false
		and cabin._door_busy == false
	) or failed

	## --- Case 3: play_key_ring early-exit on hide must not leave room busy ---
	cabin.stop_story()
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	cabin.visible = true
	cabin.show_menu("main")
	cabin._room_busy = false
	## Kick key ring, then hide mid-flight (same abort signal the early returns watch).
	cabin.play_key_ring()
	await process_frame
	await process_frame
	cabin.hide_for_run()
	## Allow awaits inside play_key_ring to observe not-visible / abort.
	for _i in range(90):
		await process_frame
		if cabin._room_busy == false and cabin.key_ring_seen == false:
			## Either aborted clean or still running; keep waiting briefly.
			pass
		if cabin._beat == "idle" or cabin._beat == "" or not cabin.visible:
			if cabin._room_busy == false:
				break
	failed = _check(
		failed,
		"key_ring_abort_leaves_room_idle",
		cabin._room_busy == false
	) or failed
	## Re-enter idle cabin the way title overlay can (show_menu, not open_cabin).
	cabin.visible = true
	cabin.show_menu("main")
	failed = _check(
		failed,
		"after_key_ring_abort_nav_free",
		cabin._busy() == false and cabin._room_busy == false
	) or failed

	## --- Case 4: rooms unlocked after first haul still navigable when idle ---
	cabin.counters.hauls = 1
	cabin._sync_progress_doors()
	failed = _check(
		failed,
		"hall_unlocked_after_haul",
		cabin.is_room_unlocked("hall") and cabin.is_room_unlocked("mudroom")
	) or failed
	failed = _check(
		failed,
		"idle_not_busy_for_launch_path",
		cabin._busy() == false
	) or failed

	_restore_save()
	if failed:
		push_error("CABIN_NAV_LOCK_PROBE_FAIL")
		quit(1)
		return
	print("CABIN_NAV_LOCK_PROBE_OK")
	quit(0)


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("PASS %s" % label)
		return failed
	push_error("FAIL %s" % label)
	return true


func _backup_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var data := FileAccess.get_file_as_string(SAVE_PATH)
		var f := FileAccess.open(SAVE_BACKUP, FileAccess.WRITE)
		if f:
			f.store_string(data)
			f.close()


func _restore_save() -> void:
	if FileAccess.file_exists(SAVE_BACKUP):
		var data := FileAccess.get_file_as_string(SAVE_BACKUP)
		var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		if f:
			f.store_string(data)
			f.close()
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_BACKUP))
	elif FileAccess.file_exists(SAVE_PATH):
		## Probe may have overwritten; delete only if we had no backup (fresh).
		pass
