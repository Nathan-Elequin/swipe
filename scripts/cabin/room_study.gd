extends "res://scripts/cabin/cabin_room.gd"
## Study: journal, will, left-hand drawer.

var drawer_glint: AnimatedSprite2D


func _build_special() -> void:
	var flames: Array = extra.get("anchors", {}).get("study", {}).get("flame", [])
	for f in flames:
		if f is Array and f.size() >= 2:
			_candle(Vector2(float(f[0]), float(f[1])))
	drawer_glint = KIT.anim_sprite(
		["fx/drawer_glint_f0.png", "fx/drawer_glint_f1.png", "fx/drawer_glint_f2.png", "fx/drawer_glint_f3.png", "fx/drawer_glint_f4.png"],
		"g", 1000.0 / 70.0, false, Vector2(211, 163)
	)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	drawer_glint.material = mat
	drawer_glint.z_index = 4
	add_child(drawer_glint)
	drawer_glint.visible = false
	drawer_glint.animation_finished.connect(_glint_wait)


func _glint_wait() -> void:
	if not drawer_glint.visible:
		return
	var t := get_tree().create_timer(randf_range(2.5, 4.0), true, true, true)
	t.timeout.connect(func() -> void:
		if drawer_glint.visible and drawer_glint.sprite_frames:
			drawer_glint.play("g")
	, CONNECT_ONE_SHOT)


func _refresh_doors() -> void:
	var shop_open: bool = cabin != null and cabin.is_room_unlocked("workshop")
	var side = spots.get("SideDoor", null)
	if side is CabinHotspot:
		side.tag_key = "cabin.hot.door_workshop" if shop_open else "cabin.hot.door_locked"
		side.set_locked(not shop_open, KIT.load_tex("doors/side_door_locked.png"))
		if shop_open:
			side.set_idle_tex(KIT.load_tex("doors/side_door_closed.png"))
	var dr = spots.get("Drawer", null)
	if dr is CabinHotspot and cabin:
		if not cabin.ending_seen:
			dr.tag_key = "cabin.hot.drawer"
			dr.set_idle_tex(KIT.load_tex("props/desk_drawer.png"))
			drawer_glint.visible = false
		elif not cabin.drawer_opened:
			dr.tag_key = "cabin.hot.drawer_ajar"
			dr.set_idle_tex(KIT.load_tex("props/desk_drawer_ajar.png"))
			drawer_glint.visible = true
			if drawer_glint.sprite_frames and not drawer_glint.is_playing():
				drawer_glint.play("g")
		else:
			dr.tag_key = "cabin.hot.drawer_open"
			dr.set_idle_tex(KIT.load_tex("props/desk_drawer.png"))
			drawer_glint.visible = false
	var j = spots.get("Journal", null)
	if j is CabinHotspot and cabin and cabin.has_method("journal_has_unread"):
		if cabin.journal_has_unread():
			j.set_idle_tex(KIT.load_tex("props/journal_new.png"))
		else:
			j.set_idle_tex(KIT.load_tex("props/journal.png"))
