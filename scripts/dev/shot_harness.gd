extends Node
## Editor-only audit captures. Main loads this only when `_authoring()`.

const OUT_DIR := "res://design/audit-shots/cursor"
const SAVE_PATH := "user://home_cabin.json"
const SACK_OWNED := ["throwing_knife", "shield"]
const SACK_NEW := ["net", "lantern", "caltrops", "dagger", "longbow"]
const W := 1680
const H := 1040

var main
var finished: bool = false
var running: bool = false
var status: String = ""
var notes: Array = []

var _save_text: String = ""
var _stamp_was: bool = false


func setup(p_main) -> void:
	main = p_main
	name = "ShotHarness"
	process_mode = Node.PROCESS_MODE_ALWAYS


func begin() -> String:
	if main == null or not main._authoring():
		return "blocked: not authoring"
	if running:
		return "already running"
	running = true
	finished = false
	notes.clear()
	status = "starting"
	var kick := get_tree().create_timer(0.0, true, false, true)
	kick.timeout.connect(_run, CONNECT_ONE_SHOT)
	return "started"


func _run() -> void:
	var abs_dir: String = ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	_log_progress("run start")
	_snapshot_save()
	if main._copy_stamp:
		_stamp_was = main._copy_stamp.visible
		main._copy_stamp.visible = false

	await _shot_rope("18_rope_exit_belly1.png", 1, "sign visible, nothing else open")
	await _shot_rope_peek("19_rope_exit_sack_peek.png")
	await _shot_caught("20_caught_sheet.png")
	_skip("21a_win_homecoming_dump.png", "Live homecoming still uses hero_drop_sack then the chair. Items do not pop out of the sack.")
	_skip("21b_win_homecoming_fly.png", "NEW items do not fly to the cabinet yet. Only a scale burst on a rebuilt mount exists.")
	await _shot_loss("22_loss_homecoming.png")
	await _shot_intro()
	await _shot_keyring("14_keyring_midbeat.png")
	await _shot_rope("24_rope_exit_belly3.png", 3, "later belly headline")

	_restore_all()
	if main._copy_stamp:
		main._copy_stamp.visible = _stamp_was
	running = false
	finished = true
	status = "done"


func _shot_rope(filename: String, cleared: int, extra: String) -> void:
	status = filename
	_reset_between()
	_plant_sack()
	main.adventure = true
	main.phase = "rest"
	main.dungeons_cleared = cleared
	main.in_tutorial = false
	_stow_cabin()
	_hide_chrome(false)
	if main.play_field:
		main.play_field.visible = false
	get_tree().paused = false
	if main.rope_exit == null:
		_skip(filename, "rope_exit node missing")
		return
	main.rope_exit.z_index = 200
	main.rope_exit.open_exit(cleared)
	await _wait(0.45)
	main.rope_exit.modulate.a = 1.0
	if not main.rope_exit.visible:
		_skip(filename, "rope_exit did not stay visible")
		return
	await _capture(filename, "phase=rest, dungeons_cleared=%s, rope_exit.open_exit(%s), HUD stowed, %s" % [cleared, cleared, extra])
	main.rope_exit.z_index = 80
	if main.play_field:
		main.play_field.visible = true


func _shot_rope_peek(filename: String) -> void:
	status = filename
	_reset_between()
	_plant_sack()
	main.adventure = true
	main.phase = "rest"
	main.dungeons_cleared = 1
	main.in_tutorial = false
	_stow_cabin()
	_hide_chrome(false)
	if main.play_field:
		main.play_field.visible = false
	get_tree().paused = false
	if main.rope_exit == null or main.sack_peek == null:
		_skip(filename, "rope_exit or sack_peek missing")
		return
	main.rope_exit.z_index = 200
	main.rope_exit.open_exit(1)
	await _wait(0.4)
	main.rope_exit.modulate.a = 1.0
	main._open_sack_peek()
	main.sack_peek.z_index = 210
	await _wait(0.45)
	if not main.sack_peek.visible:
		_skip(filename, "sack peek did not open")
		return
	await _capture(filename, "same rest/rope_exit as Belly 1, HUD stowed, then sack_peek.open_peek() with 5 new ids")
	main.rope_exit.z_index = 80
	main.sack_peek.z_index = 81
	if main.play_field:
		main.play_field.visible = true


func _shot_caught(filename: String) -> void:
	status = filename
	_reset_between()
	_stow_cabin()
	if main.rope_exit:
		main.rope_exit.hide_exit()
	if main.sack_peek and main.sack_peek.visible:
		main.sack_peek.close()
	_hide_chrome(true)
	get_tree().paused = false
	main.adventure = true
	main.in_tutorial = false
	main.phase = "defeat"
	main.dungeons_cleared = 1
	main._undo_stack = [{"shot": true}]
	main._undo_inflight = false
	main._refresh()
	if main.home_cabin and main.home_cabin.visible:
		main.home_cabin.visible = false
		main._sync_overlay()
	if main.overlay:
		main.overlay.z_index = 200
	await _wait(0.2)
	if main.overlay == null or not main.overlay.visible:
		_skip(filename, "Caught overlay did not show")
		return
	if main.overlay_undo and not main.overlay_undo.visible:
		_skip(filename, "Undo was not visible on the Caught sheet")
		return
	await _capture(filename, "phase=defeat after stowing the cabin, planted one undo snapshot, overlay_btn=defeat.home")
	if main.overlay:
		main.overlay.z_index = 80


func _shot_loss(filename: String) -> void:
	status = filename
	_reset_between()
	_hide_chrome(false)
	main.hotbar.clear()
	var cabin = main.home_cabin
	if cabin == null:
		_skip(filename, "home_cabin missing")
		return
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = true
	cabin.stop_story()
	main._open_home_cabin(true, "loss", [], [])
	cabin._arrive_skip = 2
	var ok: bool = await _until(func() -> bool:
		return cabin.visible and not cabin._arriving and cabin._int_root.visible and not cabin._sack.visible
	, 8.0)
	if not ok:
		_skip(filename, "loss arrival never settled to interior with the sack hidden")
		return
	await _wait(0.25)
	await _capture(filename, "open_cabin walk-in kind=loss, empty hotbar, skip to chair; sack hidden on settle")


func _shot_intro() -> void:
	status = "13a_intro_panel1.png"
	_reset_between()
	var cabin = main.home_cabin
	if cabin == null or cabin._cutscene == null:
		_skip("13a_intro_panel1.png", "cabin or cutscene missing")
		_skip("13b_intro_panel3.png", "cabin or cutscene missing")
		return
	cabin.intro_seen = false
	cabin.nib_first_done = true
	_hide_chrome(false)
	var kick := get_tree().create_timer(0.0, true, false, true)
	kick.timeout.connect(cabin.play_intro.bind(false), CONNECT_ONE_SHOT)
	var started: bool = await _until(func() -> bool:
		return cabin._cutscene != null and cabin._cutscene.is_playing()
	, 3.0)
	if not started:
		_skip("13a_intro_panel1.png", "intro cutscene did not start")
		_skip("13b_intro_panel3.png", "intro cutscene did not start")
		return
	cabin._cutscene.set_held(true)
	await _wait(0.8)
	if cabin._cutscene.panel_index != 0:
		_skip("13a_intro_panel1.png", "intro was not on panel 1 (index 0)")
	else:
		await _capture("13a_intro_panel1.png", "play_intro(), hold cutscene on panel 0 after rain/type-in")
	cabin._cutscene._show_panel(2, true)
	cabin._cutscene.set_held(true)
	await _wait(0.7)
	if cabin._cutscene.panel_index != 2:
		_skip("13b_intro_panel3.png", "could not hold intro panel 3 (index 2)")
	else:
		await _capture("13b_intro_panel3.png", "same intro, _show_panel(2, true) then hold")
	cabin._cutscene.abort()
	cabin.stop_story()


func _shot_keyring(filename: String) -> void:
	status = filename
	_reset_between()
	var cabin = main.home_cabin
	if cabin == null:
		_skip(filename, "home_cabin missing")
		return
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.tutorial_done = true
	cabin.key_ring_seen = false
	cabin.rooms_unlocked = ["main"]
	_hide_chrome(false)
	cabin.visible = true
	cabin._refresh_rooms()
	var kick := get_tree().create_timer(0.0, true, false, true)
	kick.timeout.connect(cabin.play_key_ring, CONNECT_ONE_SHOT)
	var cut_on: bool = await _until(func() -> bool:
		return cabin._cutscene != null and cabin._cutscene.is_playing()
	, 4.0)
	if cut_on:
		cabin._cutscene.abort()
	var unlocking: bool = await _until(func() -> bool:
		return _find_anim(cabin, "u") != null
	, 8.0)
	if not unlocking:
		_skip(filename, "side-door unlock sprite never appeared after skipping the key-ring panel")
		cabin.visible = false
		cabin.stop_story()
		return
	await _wait(0.18)
	await _capture(filename, "play_key_ring(), abort the panel, wait for doors/side_door_unlock while Nib is at the hall door")
	cabin.visible = false
	cabin.stop_story()
	await _wait(0.4)


func _plant_sack() -> void:
	var cabin = main.home_cabin
	main.hotbar.clear()
	var ids: Array = []
	ids.append_array(SACK_OWNED)
	ids.append_array(SACK_NEW)
	for id in ids:
		var it: Dictionary = main._make_item(str(id))
		if it.is_empty():
			continue
		main.hotbar.append(it)
	if cabin == null:
		return
	for id2 in SACK_OWNED:
		cabin.swiped[str(id2)] = true
		cabin.seen[str(id2)] = true
	for id3 in SACK_NEW:
		cabin.swiped.erase(str(id3))


func _stow_cabin() -> void:
	var cabin = main.home_cabin
	if cabin == null:
		return
	cabin.intro_seen = true
	cabin.nib_first_done = true
	cabin.stop_story()
	if cabin._cutscene and cabin._cutscene.is_playing():
		cabin._cutscene.abort()
	cabin.hide_for_run()
	cabin.visible = false


func _hide_chrome(keep_overlay: bool) -> void:
	var nodes: Array = [
		main.tut, main.speech_box, main.inspect, main.face_box, main.fly_tip,
		main.log_btn, main.log_label, main._copy_stamp, main._courier,
		main.settings_ui, main.combat_stage,
	]
	for n in nodes:
		if n:
			n.visible = false
	if main.overlay and not keep_overlay:
		main.overlay.visible = false
	if main.overlay_tools_row:
		main.overlay_tools_row.visible = false
	if main.overlay_latest:
		main.overlay_latest.visible = false
	if main.overlay_dev:
		main.overlay_dev.visible = false
	if main.overlay_roster:
		main.overlay_roster.visible = false
	if main.overlay_script:
		main.overlay_script.visible = false
	if main.home_cabin and main.home_cabin._editor_strip:
		main.home_cabin._editor_strip.visible = false


func _reset_between() -> void:
	_restore_disk()
	if main.home_cabin:
		main.home_cabin.stop_story()
		if main.home_cabin._cutscene and main.home_cabin._cutscene.is_playing():
			main.home_cabin._cutscene.abort()
		main.home_cabin._load_save()
	if main.sack_peek and main.sack_peek.visible:
		main.sack_peek.close()
	if main.rope_exit:
		main.rope_exit.hide_exit()
		main.rope_exit.z_index = 80
	if main.settings_ui and main.settings_ui.visible and main.settings_ui.has_method("close_menu"):
		main.settings_ui.close_menu()
	if main.play_field:
		main.play_field.visible = true
	main.in_tutorial = false
	main._undo_stack.clear()
	main._undo_inflight = false


func _snapshot_save() -> void:
	_save_text = ""
	if FileAccess.file_exists(SAVE_PATH):
		var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if f:
			_save_text = f.get_as_text()


func _restore_disk() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(_save_text)


func _restore_all() -> void:
	_restore_disk()
	if main.home_cabin:
		main.home_cabin.stop_story()
		main.home_cabin._load_save()
		main.home_cabin.hide_for_run()
	if main.rope_exit:
		main.rope_exit.hide_exit()
	if main.sack_peek and main.sack_peek.visible:
		main.sack_peek.close()
	main.hotbar.clear()
	main.phase = "title"
	main.adventure = false
	main.dungeons_cleared = 0
	main._undo_stack.clear()
	if main.play_field:
		main.play_field.visible = true
	if main.overlay:
		main.overlay.z_index = 80
	if main.home_cabin and main.home_cabin._editor_strip and main._authoring():
		main.home_cabin._editor_strip.visible = true
	main._refresh()


func _capture(filename: String, how: String) -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var tex: ViewportTexture = main.get_viewport().get_texture()
	if tex == null:
		_skip(filename, "viewport texture missing")
		return
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		_skip(filename, "viewport image empty")
		return
	if img.get_width() != W or img.get_height() != H:
		img.resize(W, H, Image.INTERPOLATE_NEAREST)
	var abs_path: String = ProjectSettings.globalize_path(OUT_DIR).path_join(filename)
	var err: Error = img.save_png(abs_path)
	if err != OK:
		_skip(filename, "save_png failed (%s)" % err)
		return
	notes.append({"file": filename, "status": "ok", "how": how})


func _skip(filename: String, why: String) -> void:
	notes.append({"file": filename, "status": "skip", "how": why})
	_log_progress("skip %s: %s" % [filename, why])


func _log_progress(line: String) -> void:
	var path: String = ProjectSettings.globalize_path(OUT_DIR).path_join("_harness.log")
	var prev := ""
	if FileAccess.file_exists(path):
		prev = FileAccess.get_file_as_string(path)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(prev + line + "\n")
	print("SHOT_HARNESS: ", line)


func _wait(sec: float) -> void:
	if sec <= 0.0:
		await get_tree().process_frame
		return
	await get_tree().create_timer(sec, true, false, true).timeout


func _until(pred: Callable, timeout: float) -> bool:
	var t := 0.0
	while t < timeout:
		if pred.call():
			return true
		await _wait(0.05)
		t += 0.05
	return false


func _find_anim(node: Node, anim: String) -> AnimatedSprite2D:
	if node is AnimatedSprite2D:
		var spr: AnimatedSprite2D = node
		if spr.is_playing() and spr.animation == anim:
			return spr
	for child in node.get_children():
		var found: AnimatedSprite2D = _find_anim(child, anim)
		if found:
			return found
	return null
