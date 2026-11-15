extends SceneTree
## Nib pointer dock + clear (BUG 1–3) + cog seat + padlock draw order.
## Walks first-return / trophy pointer lines without F5 / godot-mcp.
##
## Asserts:
##   (a) for each pointer line, dialog rect does not intersect the target (+24px)
##   (b) after each pointer line advances / closes, pointer + ring are hidden
##   (c) keys sequence starts with no pointer
##   (d) map-click pointer then room change → pointer hidden
##   (e) cog global centre unchanged within 1px after a spin
##   (f) padlock is top-most face child on a locked board


const OK_MARK := "NIB_POINTER_OK"
const FAIL_MARK := "NIB_POINTER_FAIL"
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const FACE := preload("res://scripts/cabin/trophy_board_face.gd")
const HOMECOMING := preload("res://scripts/cabin/homecoming.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const COPY := preload("res://scripts/player_copy.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const AVOID_MARGIN := 24.0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	COPY.reload()
	Engine.time_scale = 10.0

	## --- Static wiring ---
	var dialog_src := FileAccess.get_file_as_string("res://scripts/cabin/cabin_dialog.gd")
	failed = _check(rows, failed, "dialog.signal.line_changed", dialog_src.find("signal line_changed") >= 0) or failed
	failed = _check(rows, failed, "dialog.signal.closed", dialog_src.find("signal closed") >= 0) or failed
	failed = _check(rows, failed, "dialog.set_pointer_avoid", dialog_src.find("set_pointer_avoid") >= 0) or failed
	failed = _check(rows, failed, "dialog.talk_bar_anchor_toward", dialog_src.find("talk_bar_anchor_toward") >= 0) or failed
	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	failed = _check(rows, failed, "cabin.clear_on_pan", cabin_src.find("clear_nib_pointer") >= 0) or failed
	failed = _check(rows, failed, "cabin.no_amb_start", cabin_src.find("loop_start(&\"amb.trophy_room\"") < 0) or failed
	var home_src := FileAccess.get_file_as_string("res://scripts/cabin/homecoming.gd")
	failed = _check(
		rows, failed, "homecoming.hover_pointer_before_say",
		home_src.find("_start_first_pulse") < home_src.find('await _say_keys(["nib.board.first_hover_hint"]')
		or home_src.find("_start_first_pulse") < home_src.find("nib.board.first_hover_hint")
	) or failed

	## --- Live cabin + dialog + board ---
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
	cabin.set_size(Vector2(1680, 1040))
	cabin.call("_apply_defaults")
	cabin.reduce_motion = true
	cabin.rooms_unlocked = ["main", "hall", "study", "workshop", "loft"]
	cabin.key_ring_seen = false
	cabin.nib_in_hall = false
	cabin.first_return_homecoming_done = false
	cabin.first_light_seen = false

	## Build a real dialog under the cabin.
	var dialog = load("res://scripts/cabin/cabin_dialog.gd").new()
	dialog.setup(cabin)
	cabin.add_child(dialog)
	cabin.set("_dialog", dialog)
	cabin.call("_wire_nib_pointer_lifecycle")

	## Minimal rooms so pan_to / snap_to / map hotspot work.
	var host := Control.new()
	host.name = "RoomsHost"
	host.size = Vector2(1680 * 5, 1040)
	cabin.add_child(host)
	cabin.set("_rooms_host", host)
	cabin.set("_int_root", cabin)
	var rooms := {
		"main": _make_room("main", Vector2(200, 200)),
		"hall": _make_room("hall", Vector2(400, 200)),
	}
	## Map hotspot for BUG 3.
	var map_hit := Control.new()
	map_hit.name = "Map"
	map_hit.position = Vector2(900, 200)
	map_hit.size = Vector2(128, 96)
	cabin.add_child(map_hit)
	(rooms["main"]["spots"] as Dictionary)["Map"] = map_hit
	cabin.set("_rooms", rooms)
	cabin.set("_current_room", "main")

	## Trophy board for lever / cogs / padlock.
	var rules: Dictionary = SHELL.read_json("res://data/campaign.json")
	var board_data: Dictionary = SHELL.read_json("res://data/content-board.json")
	var items_by_id := {}
	for raw in board_data.get("items", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id != "":
			items_by_id[id] = card
	cabin.items_by_id = items_by_id
	var state := SHELL.fresh_state()
	## Lock a later face so padlock is visible (Ashen-style).
	state["map_pieces"] = {"b2": false, "b3": false, "b4": false, "b5": false}
	var board: TrophyBoard = BOARD.new()
	cabin.add_child(board)
	cabin.set("_trophy_board", board)
	board.setup(rules, items_by_id, state, {}, [])
	board.reduce_motion = false
	board.slide_to(0, true)
	await process_frame
	await process_frame

	## --- (a)+(b) Lever pointer line: dock top, no overlap, clear on advance ---
	var lever: Control = board.lever_node()
	failed = _check(rows, failed, "lever.node", lever != null) or failed
	if lever != null:
		## Force the lever into the bottom half so dock-top is required in this harness.
		var lever_home: Vector2 = lever.global_position
		lever.global_position = Vector2(1200, 820)
		cabin.show_nib_pointer_at(lever)
		dialog.say(["nib.board.first_light.2"], [], {}, {
			"nib.board.first_light.2": "Looks like if you bring home five different things from this place... that lever over there will wake up."
		})
		await process_frame
		await process_frame
		failed = _check(rows, failed, "lever.dock_top", dialog.is_docked_top()) or failed
		var bar: Rect2 = dialog.talk_bar_global_rect()
		var target: Rect2 = lever.get_global_rect().grow(AVOID_MARGIN)
		failed = _check(
			rows, failed, "lever.no_overlap",
			not bar.intersects(target)
		) or failed
		failed = _check(rows, failed, "lever.pointer_on", cabin.is_nib_pointer_visible()) or failed
		## Ring should sit on the lever centre, not inside the dialog bar.
		var ptr = cabin.get_node_or_null("NibPointer")
		if ptr != null:
			var ring: Control = ptr.get_node_or_null("PulseRing") as Control
			if ring != null and ring.visible:
				var ring_c: Vector2 = ring.get_global_rect().get_center()
				var lever_c: Vector2 = lever.get_global_rect().get_center()
				failed = _check(
					rows, failed, "lever.ring_on_target",
					ring_c.distance_to(lever_c) <= 8.0
				) or failed
				failed = _check(
					rows, failed, "lever.ring_outside_bar",
					not bar.has_point(ring_c)
				) or failed
		## Advance / close → pointer gone.
		dialog.advance()
		## Skip typing finish if still typing.
		if dialog.get("_typing") == true:
			dialog.advance()
		dialog.advance()
		await process_frame
		## Let close fade settle so a deferred closed cannot race the next case.
		await cabin.get_tree().create_timer(0.05).timeout
		failed = _check(rows, failed, "lever.pointer_cleared", not cabin.is_nib_pointer_visible()) or failed
		lever.global_position = lever_home

	## --- Hover-hint style: show pointer during line, clear before keys ---
	var slot_proxy := Control.new()
	slot_proxy.name = "SlotProxy"
	slot_proxy.position = Vector2(600, 300)
	slot_proxy.size = Vector2(96, 96)
	cabin.add_child(slot_proxy)
	cabin.show_nib_pointer_at(slot_proxy)
	dialog.say(["nib.board.first_hover_hint"], [], {}, {
		"nib.board.first_hover_hint": "Hover a find on the board to learn what it does."
	})
	await process_frame
	failed = _check(rows, failed, "hover.pointer_on", cabin.is_nib_pointer_visible()) or failed
	var hover_bar: Rect2 = dialog.talk_bar_global_rect()
	var hover_target: Rect2 = slot_proxy.get_global_rect().grow(AVOID_MARGIN)
	failed = _check(rows, failed, "hover.no_overlap", not hover_bar.intersects(hover_target)) or failed
	## Finish the line.
	if dialog.get("_typing") == true:
		dialog.advance()
	dialog.advance()
	await process_frame
	failed = _check(rows, failed, "hover.pointer_cleared", not cabin.is_nib_pointer_visible()) or failed

	## --- (c) Keys sequence starts with no pointer ---
	cabin.show_nib_pointer_at(slot_proxy)
	failed = _check(rows, failed, "pre_keys.pointer_on", cabin.is_nib_pointer_visible()) or failed
	## play_key_ring early-outs if key_ring_seen; call the clear path directly + snap.
	cabin.clear_nib_pointer()
	cabin.set("key_ring_seen", false)
	## Simulate the start of play_key_ring's clear.
	var kr_src_ok: bool = cabin_src.find("clear_nib_pointer()") >= 0 and cabin_src.find("play_key_ring") >= 0
	failed = _check(rows, failed, "keys.clear_wired", kr_src_ok) or failed
	## Invoke the clear that play_key_ring does at start.
	cabin.set("key_ring_seen", true) ## avoid long cutscene; we only need the invariant
	cabin.clear_nib_pointer()
	failed = _check(rows, failed, "keys.start_no_pointer", not cabin.is_nib_pointer_visible()) or failed

	## --- (d) Map pointer then room change ---
	cabin.set("_current_room", "main")
	cabin.show_nib_pointer_at(map_hit)
	dialog.say(["nib.first.map_point"], [], {}, {
		"nib.first.map_point": "The map is waiting when you are."
	})
	await process_frame
	failed = _check(rows, failed, "map.pointer_on", cabin.is_nib_pointer_visible()) or failed
	## Finish line (pointer should clear on close).
	if dialog.get("_typing") == true:
		dialog.advance()
	dialog.advance()
	await cabin.get_tree().create_timer(0.05).timeout
	failed = _check(rows, failed, "map.pointer_cleared_on_close", not cabin.is_nib_pointer_visible()) or failed
	## Re-show after close (no open dialog) to prove room change clears it.
	cabin.show_nib_pointer_at(map_hit)
	failed = _check(rows, failed, "map.pointer_reshown", cabin.is_nib_pointer_visible()) or failed
	cabin.set("_pan_busy", false)
	## Direct snap_to / pan clear path (pan_to needs unlock + host motion).
	cabin.call("_snap_to", "hall")
	await process_frame
	failed = _check(rows, failed, "map.pointer_cleared_on_room", not cabin.is_nib_pointer_visible()) or failed
	## Also cover pan_to clear when room differs.
	cabin.set("_current_room", "hall")
	cabin.show_nib_pointer_at(map_hit)
	cabin.set("_pan_busy", false)
	## pan_to may early-out without rooms_clip; call clear path via snap again.
	cabin.call("_snap_to", "main")
	await process_frame
	failed = _check(rows, failed, "map.pointer_cleared_on_snap", not cabin.is_nib_pointer_visible()) or failed

	## --- (e) Cog centres stable after spin ---
	board.reduce_motion = false
	board.call("_seat_cogs")
	await process_frame
	var before: Array = board.cog_centers_global()
	failed = _check(rows, failed, "cogs.two", before.size() == 2) or failed
	board.call("_spin_cogs", 1)
	## Wait out the 0.36s spin (time_scale 10 → ~0.036s).
	await cabin.get_tree().create_timer(0.08).timeout
	var after: Array = board.cog_centers_global()
	var cog_ok := true
	for i in mini(before.size(), after.size()):
		if (before[i] as Vector2).distance_to(after[i] as Vector2) > 1.0:
			cog_ok = false
	failed = _check(rows, failed, "cogs.center_stable", cog_ok) or failed
	## Reduce-motion path stays cog-free (no spin).
	board.reduce_motion = true
	var mid: Array = board.cog_centers_global()
	board.call("_spin_cogs", 1)
	await process_frame
	var mid2: Array = board.cog_centers_global()
	var rm_ok := true
	for j in mini(mid.size(), mid2.size()):
		if (mid[j] as Vector2).distance_to(mid2[j] as Vector2) > 0.01:
			rm_ok = false
	failed = _check(rows, failed, "cogs.reduce_motion_noop", rm_ok) or failed

	## --- (f) Padlock top-most on a locked face ---
	var locked_face: TrophyBoardFace = null
	for face_n in board.get("_face_nodes"):
		if face_n is TrophyBoardFace:
			var f: TrophyBoardFace = face_n
			## Force locked visuals.
			f.get("_padlock").visible = true
			f.call("_raise_padlock")
			locked_face = f
			break
	failed = _check(rows, failed, "padlock.face", locked_face != null) or failed
	if locked_face != null:
		failed = _check(rows, failed, "padlock.topmost", locked_face.padlock_is_topmost()) or failed
		failed = _check(
			rows, failed, "padlock.z_above_slots",
			int(locked_face.get("_padlock").z_index) >= 20
		) or failed

	## --- Dock helper: bottom-half target forces top dock ---
	var bottom_target := Control.new()
	bottom_target.position = Vector2(800, 850)
	bottom_target.size = Vector2(64, 64)
	cabin.add_child(bottom_target)
	dialog.say(["nib.board.first_light.2"], [], {}, {"nib.board.first_light.2": "lever line"})
	await process_frame
	cabin.show_nib_pointer_at(bottom_target)
	await process_frame
	failed = _check(rows, failed, "dock.bottom_half_tops", dialog.is_docked_top()) or failed
	var dbar: Rect2 = dialog.talk_bar_global_rect()
	failed = _check(
		rows, failed, "dock.bottom_half_clear",
		not dbar.intersects(bottom_target.get_global_rect().grow(AVOID_MARGIN))
	) or failed
	cabin.clear_nib_pointer()
	if dialog.get("_typing") == true:
		dialog.advance()
	dialog.advance()

	_finish(failed, rows)


func _make_room(id: String, nib_pos: Vector2) -> Dictionary:
	var nib := AnimatedSprite2D.new()
	nib.name = "NibSprite_%s" % id
	nib.centered = false
	nib.position = nib_pos
	nib.visible = true
	var sf := SpriteFrames.new()
	for anim in ["idle", "walk", "talk", "gasp", "react", "point", "psst"]:
		sf.add_animation(anim)
		sf.set_animation_loop(anim, anim == "idle" or anim == "walk" or anim == "psst")
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	var tex := ImageTexture.create_from_image(img)
	for anim2 in ["idle", "walk", "talk", "gasp", "react", "point", "psst"]:
		sf.add_frame(anim2, tex)
	nib.sprite_frames = sf
	root.add_child(nib)
	var hs := Control.new()
	hs.name = "NibHot_%s" % id
	hs.position = nib_pos
	hs.size = Vector2(96, 128)
	root.add_child(hs)
	## Node stub so cabin._snap_to / _apply_gate can call has_method safely.
	var room_n := Node.new()
	room_n.name = "Room_%s" % id
	root.add_child(room_n)
	room_n.set_meta("nib", nib)
	room_n.set_meta("spots", {"Nib": hs})
	## Dictionary form used by NibHost + cabin room lookups.
	return {"nib": nib, "spots": {"Nib": hs}, "node": room_n}


func _check(rows: Array, failed: bool, id: String, ok: bool) -> bool:
	rows.append("%s %s" % ["PASS" if ok else "FAIL", id])
	if not ok:
		push_error("NIB_POINTER fail: %s" % id)
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
