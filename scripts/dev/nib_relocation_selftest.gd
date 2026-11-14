extends SceneTree
## Package E — Nib relocation, reduce-motion wiring, shake guard.


const OK_MARK := "NIB_RELOCATION_OK"
const FAIL_MARK := "NIB_RELOCATION_FAIL"
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const HOMECOMING := preload("res://scripts/cabin/homecoming.gd")
const SEQ := preload("res://scripts/cabin/board_sequences.gd")
const NIB_HOST := preload("res://scripts/cabin/nib_host.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const COPY := preload("res://scripts/player_copy.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	COPY.reload()
	Engine.time_scale = 8.0

	failed = _check(rows, failed, "copy.move.1", COPY.text("nib.board.move.1", "") != "") or failed
	failed = _check(rows, failed, "copy.move.2", COPY.text("nib.board.move.2", "").find("watch") >= 0) or failed
	var sfx_map: Dictionary = SHELL.read_json("res://data/sfx-map.json")
	var cues: Dictionary = sfx_map.get("cues", {}) if typeof(sfx_map.get("cues", {})) == TYPE_DICTIONARY else {}
	for id in [
		"amb.trophy_room", "nib.react", "board.slide", "board.poof", "board.whoosh",
		"board.satchel_in", "board.light_chime", "board.light_chime_1", "board.light_chime_5",
		"board.lever_clunk", "board.rumble",
		"sting.portal_open", "sting.shortcut", "board.path_draw", "board.fog_clear",
		"board.badge_pop",
	]:
		failed = _check(rows, failed, "cue.%s" % id, cues.has(id)) or failed
	## Reel #503: amb file is real (not fire-loop alias).
	var amb: Dictionary = cues.get("amb.trophy_room", {})
	var amb_files: Array = amb.get("files", []) if typeof(amb) == TYPE_DICTIONARY else []
	failed = _check(
		rows, failed, "cue.amb.trophy_file",
		amb_files.has("amb_trophy_room")
	) or failed

	var CabinScr = load("res://scripts/home_cabin.gd")
	failed = _check(rows, failed, "cabin_loads", CabinScr != null) or failed
	if CabinScr == null:
		_finish(failed, rows)
		return
	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.call("_apply_defaults")
	cabin.rooms_unlocked = ["main", "hall"]
	cabin.key_ring_seen = true
	cabin.nib_in_hall = false
	cabin.reduce_motion = false

	var host := Control.new()
	host.size = Vector2(1680, 1040)
	root.add_child(host)

	var rooms := {
		"main": _make_room("main", Vector2(216, 172) * 4.0),
		"hall": _make_room("hall", Vector2(386, 172) * 4.0),
	}
	(rooms["hall"]["nib"] as CanvasItem).visible = false
	(rooms["hall"]["spots"]["Nib"] as CanvasItem).visible = false
	cabin.set("_rooms", rooms)
	cabin.set("_current_room", "hall")
	cabin.set("_int_root", host)
	cabin.set("_cabin_session", 1)

	failed = _check(rows, failed, "fresh.host_main", NIB_HOST.room_id(cabin) == "main") or failed
	failed = _check(rows, failed, "fresh.main_visible", (rooms["main"]["nib"] as CanvasItem).visible == true) or failed
	failed = _check(rows, failed, "fresh.hall_hidden", (rooms["hall"]["nib"] as CanvasItem).visible == false) or failed

	## Simulate successful relocate commit (walk/dialog covered by source asserts).
	cabin.nib_in_hall = true
	(rooms["hall"]["nib"] as Node2D).position = Vector2(386, 172) * 4.0
	NIB_HOST.apply_visibility(cabin)
	failed = _check(rows, failed, "reloc.flag", cabin.nib_in_hall == true) or failed
	failed = _check(rows, failed, "reloc.host_hall", NIB_HOST.room_id(cabin) == "hall") or failed
	failed = _check(rows, failed, "reloc.main_hidden", (rooms["main"]["nib"] as CanvasItem).visible == false) or failed
	failed = _check(rows, failed, "reloc.hall_visible", (rooms["hall"]["nib"] as CanvasItem).visible == true) or failed
	failed = _check(
		rows, failed, "reloc.idle_x",
		absf((rooms["hall"]["nib"] as Node2D).position.x - 386.0 * 4.0) < 2.0
	) or failed

	## Round-trip visibility when flag flips.
	cabin.nib_in_hall = false
	NIB_HOST.apply_visibility(cabin)
	failed = _check(rows, failed, "flag_off.hall_hidden", (rooms["hall"]["nib"] as CanvasItem).visible == false) or failed
	cabin.nib_in_hall = true
	NIB_HOST.apply_visibility(cabin)
	failed = _check(rows, failed, "flag_on.hall_shown", (rooms["hall"]["nib"] as CanvasItem).visible == true) or failed

	## Reduce motion forwards.
	var board: Node = BOARD.new()
	host.add_child(board)
	board.reduce_motion = false
	cabin.set("_trophy_board", board)
	var seq: Node = SEQ.new()
	root.add_child(seq)
	seq.setup(cabin, board, null, null, null)
	seq.reduce_motion = false
	cabin.set("_board_sequences", seq)
	cabin.set_reduce_motion(true)
	failed = _check(rows, failed, "rm.cabin", cabin.reduce_motion == true) or failed
	failed = _check(rows, failed, "rm.board", board.reduce_motion == true) or failed
	failed = _check(rows, failed, "rm.seq", seq.reduce_motion == true) or failed
	failed = _check(
		rows, failed, "rm.homecoming_read",
		HOMECOMING._read_reduce_motion(cabin, board) == true
	) or failed

	## Rumble: reduce_motion must not create shake.
	seq.reduce_motion = true
	seq.last_shake_created = false
	await seq._play_rumble()
	failed = _check(rows, failed, "rm.no_shake", seq.last_shake_created == false) or failed
	seq.reduce_motion = false
	seq.last_shake_created = false
	await seq._play_rumble()
	failed = _check(rows, failed, "full.shake_flag", seq.last_shake_created == true) or failed

	board.reduce_motion = true
	board.slide_to(0, true)
	failed = _check(rows, failed, "board.slide_instant_ok", true) or failed

	var settings_src := FileAccess.get_file_as_string("res://scripts/settings_menu.gd")
	failed = _check(rows, failed, "settings.reduce_signal", settings_src.find("reduce_motion_toggled") >= 0) or failed
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	failed = _check(rows, failed, "main.reduce_wire", main_src.find("_on_reduce_motion_toggled") >= 0) or failed
	var home_src := FileAccess.get_file_as_string("res://scripts/cabin/homecoming.gd")
	## Primary chime is board.light_chime_N (#503); cabin.shelf_chime may remain as fallback only.
	failed = _check(
		rows, failed, "homecoming.light_chime_index",
		home_src.find("board.light_chime_%d") >= 0
	) or failed
	failed = _check(
		rows, failed, "homecoming.no_cabin_primary",
		home_src.find('_cue("cabin.') < 0
	) or failed
	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	failed = _check(rows, failed, "cabin.nib_host", cabin_src.find("nib_host.gd") >= 0) or failed
	failed = _check(rows, failed, "cabin.relocate", cabin_src.find("_relocate_nib_to_hall") >= 0) or failed
	failed = _check(rows, failed, "cabin.catchup", cabin_src.find("_maybe_catchup_nib_hall") >= 0) or failed
	failed = _check(rows, failed, "cabin.amb", cabin_src.find("amb.trophy_room") >= 0) or failed
	failed = _check(
		rows, failed, "cabin.amb.loop_start",
		cabin_src.find("loop_start(&\"amb.trophy_room\"") >= 0
		or cabin_src.find('loop_start(&"amb.trophy_room"') >= 0
	) or failed
	failed = _check(
		rows, failed, "cabin.amb.loop_stop",
		cabin_src.find("loop_stop(&\"amb.trophy_room\"") >= 0
		or cabin_src.find('loop_stop(&"amb.trophy_room"') >= 0
	) or failed
	var seq_src := FileAccess.get_file_as_string("res://scripts/cabin/board_sequences.gd")
	failed = _check(
		rows, failed, "seq.no_manual_rumble_duck",
		seq_src.find("duck_music(-8)") < 0
	) or failed
	var hall_src := FileAccess.get_file_as_string("res://scripts/cabin/room_hall.gd")
	failed = _check(rows, failed, "hall.nib_sprite", hall_src.find("NibSprite") >= 0) or failed
	var board_src := FileAccess.get_file_as_string("res://scripts/cabin/trophy_board.gd")
	failed = _check(rows, failed, "board.pip_blink", board_src.find("_make_new_pip") >= 0) or failed
	failed = _check(rows, failed, "board.fade_slide", board_src.find("cross-fade") >= 0 or board_src.find("cross_fade") >= 0 or board_src.find("0.15") >= 0) or failed

	_finish(failed, rows)


func _make_room(id: String, nib_pos: Vector2) -> Dictionary:
	var nib := AnimatedSprite2D.new()
	nib.name = "NibSprite_%s" % id
	nib.centered = false
	nib.position = nib_pos
	nib.visible = true
	var sf := SpriteFrames.new()
	for anim in ["idle", "walk", "talk", "gasp", "react"]:
		sf.add_animation(anim)
		sf.set_animation_loop(anim, anim == "idle" or anim == "walk")
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var tex := ImageTexture.create_from_image(img)
	for anim2 in ["idle", "walk", "talk", "gasp", "react"]:
		sf.add_frame(anim2, tex)
	nib.sprite_frames = sf
	root.add_child(nib)
	var hs := Control.new()
	hs.name = "NibHot_%s" % id
	hs.position = nib_pos
	hs.size = Vector2(96, 128)
	hs.visible = true
	root.add_child(hs)
	return {"nib": nib, "spots": {"Nib": hs}}


func _check(rows: Array, failed: bool, id: String, ok: bool) -> bool:
	rows.append("%s %s" % ["PASS" if ok else "FAIL", id])
	if not ok:
		push_error("NIB_RELOCATION fail: %s" % id)
	return failed or not ok


func _finish(failed: bool, rows: Array) -> void:
	Engine.time_scale = 1.0
	for r in rows:
		print(r)
	if failed:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)
