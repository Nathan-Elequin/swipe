extends Control
## Will close-up. First open breaks the seal.

signal closed

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0

var cabin
var extra: Dictionary = {}
var _scroll: TextureRect
var _seal: TextureRect
var _body: RichTextLabel


func setup(p_cabin, p_extra: Dictionary) -> void:
	cabin = p_cabin
	extra = p_extra
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	var v := KIT.veil()
	v.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			_on_click()
	)
	add_child(v)
	var origin: Array = extra.get("overlay_origins", {}).get("overlays/will_close.png", [80, 20])
	_scroll = KIT.tex_rect("overlays/will_close.png", Vector2(float(origin[0]), float(origin[1])), Vector2(260, 220), 0)
	_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	_scroll.pivot_offset = Vector2(_scroll.size.x * 0.5, 0)
	add_child(_scroll)
	var title := KIT.label("will.title", 28, KIT.INK, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = _scroll.position + Vector2(20, 8) * PX
	title.size = Vector2(220, 28) * PX
	add_child(title)
	var box: Array = extra.get("will_text", [40, 34, 180, 150])
	_body = RichTextLabel.new()
	_body.fit_content = false
	_body.scroll_active = true
	_body.position = _scroll.position + Vector2(float(box[0]), float(box[1])) * PX
	_body.size = Vector2(float(box[2]), float(box[3])) * PX
	_body.add_theme_font_size_override("normal_font_size", 20)
	_body.add_theme_color_override("default_color", KIT.INK)
	add_child(_body)
	var sign := KIT.label("will.sign", 18, KIT.INK)
	sign.position = _scroll.position + Vector2(40, 170) * PX
	sign.size = Vector2(180, 16) * PX
	add_child(sign)
	var wit := KIT.label("will.witness", 16, KIT.MUTED)
	wit.position = sign.position + Vector2(0, 20)
	wit.size = Vector2(180, 16) * PX
	add_child(wit)
	var se: Array = extra.get("will_seal", [112, 186])
	_seal = KIT.tex_rect("overlays/wax_seal.png", Vector2.ZERO, Vector2(36, 36), 2)
	_seal.position = _scroll.position + Vector2(float(se[0]), float(se[1])) * PX
	add_child(_seal)
	var close_b: Button = KIT.choice_tag("will.close", Vector2(80, 16))
	close_b.position = KIT.pt(170, 234)
	close_b.z_index = 2
	close_b.pressed.connect(close)
	add_child(close_b)


func open_will() -> void:
	visible = true
	_body.text = "\n\n".join([
		KIT.copy_text("will.p1"),
		KIT.copy_text("will.p2"),
		KIT.copy_text("will.p3"),
		KIT.copy_text("will.p4"),
		KIT.copy_text("will.p5"),
	])
	var read: bool = cabin != null and bool(cabin.will_read)
	_seal.texture = KIT.load_tex("overlays/wax_seal_broken.png" if read else "overlays/wax_seal.png")
	_scroll.scale = Vector2(1, 0.1)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_scroll, "scale", Vector2.ONE, 0.35)
	KIT.cue(cabin.sfx if cabin else null, &"cabin.scroll")


func _on_click() -> void:
	if cabin and not cabin.will_read:
		cabin.will_read = true
		cabin._save()
		_seal.texture = KIT.load_tex("overlays/wax_seal_broken.png")
		KIT.cue(cabin.sfx if cabin else null, &"cabin.seal_stamp")
		return
	close()


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()
