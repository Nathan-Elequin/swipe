extends Control
## Left-hand drawer close-up. Geode + note.

signal closed
signal take_geode
signal open_note

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0

var cabin
var extra: Dictionary = {}
var _box: TextureRect
var _glow: AnimatedSprite2D
var _geode: TextureRect
var _take: Button
var _close: Button


func setup(p_cabin, p_extra: Dictionary) -> void:
	cabin = p_cabin
	extra = p_extra
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var v := KIT.veil()
	v.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			close()
	)
	add_child(v)
	var origin: Array = extra.get("overlay_origins", {}).get("overlays/drawer_close.png", [90, 50])
	_box = KIT.tex_rect("overlays/drawer_close.png", Vector2(float(origin[0]), float(origin[1])), Vector2(240, 160), 0)
	_box.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_box)
	var title := KIT.label("drawer.title", 28, KIT.CREAM)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, (float(origin[1]) - 14.0) * PX)
	title.size = Vector2(1680, 36)
	add_child(title)
	var gp: Array = extra.get("drawer_geode_glow", [47, 56])
	_glow = KIT.anim_sprite(
		["overlays/lucky_geode_glow_f0.png", "overlays/lucky_geode_glow_f1.png", "overlays/lucky_geode_glow_f2.png", "overlays/lucky_geode_glow_f1.png"],
		"g", 1000.0 / 220.0, true, Vector2.ZERO
	)
	_glow.position = _box.position + Vector2(float(gp[0]), float(gp[1])) * PX
	add_child(_glow)
	if _glow.sprite_frames:
		_glow.play("g")
	var gpos: Array = extra.get("drawer_geode", [52, 60])
	_geode = KIT.tex_rect("overlays/lucky_geode_big.png", Vector2.ZERO, Vector2(24, 24), 3)
	_geode.position = _box.position + Vector2(float(gpos[0]), float(gpos[1])) * PX
	_geode.mouse_filter = Control.MOUSE_FILTER_STOP
	_geode.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_geode.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			_take_it()
	)
	add_child(_geode)
	var np: Array = extra.get("drawer_note", [156, 26])
	var note := KIT.tex_rect("overlays/drawer_note.png", Vector2.ZERO, Vector2(40, 28), 3)
	note.position = _box.position + Vector2(float(np[0]), float(np[1])) * PX
	note.mouse_filter = Control.MOUSE_FILTER_STOP
	note.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	note.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			open_note.emit()
	)
	add_child(note)
	_take = KIT.choice_tag("drawer.take", Vector2(92, 16))
	_take.position = KIT.pt(126, 216)
	_take.z_index = 2
	_take.pressed.connect(_take_it)
	add_child(_take)
	_close = KIT.choice_tag("drawer.close", Vector2(72, 16))
	_close.position = KIT.pt(222, 216)
	_close.z_index = 2
	_close.pressed.connect(close)
	add_child(_close)


func open_drawer() -> void:
	visible = true
	var gone: bool = cabin != null and bool(cabin.geode_on_mantel)
	_geode.visible = not gone
	_glow.visible = not gone
	_take.visible = not gone
	_close.position = KIT.pt(174 if gone else 222, 216)
	_box.modulate.a = 0.0
	_box.position.y += 12.0 * PX
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_box, "modulate:a", 1.0, 0.22)
	tw.parallel().tween_property(_box, "position:y", _box.position.y - 12.0 * PX, 0.22)


func _take_it() -> void:
	KIT.cue(cabin.sfx if cabin else null, &"cabin.geode_chime")
	take_geode.emit()
	close()


func close() -> void:
	if not visible:
		return
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	visible = false
	closed.emit()
