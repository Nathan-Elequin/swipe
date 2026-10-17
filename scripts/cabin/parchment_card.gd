extends Control
## Shared dialog-box card for Brag-o-Meter, Patents, and loft letters.

signal closed

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0

var _box: NinePatchRect
var _title
var _body: RichTextLabel
var _close: Button


func setup() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = false
	z_index = 6
	var v := KIT.veil()
	v.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			close()
	)
	add_child(v)
	_box = KIT.nine("ui/dialog_box_9.png", Vector2(12, 12))
	_box.size = KIT.pt(200, 150)
	_box.position = KIT.pt(110, 55)
	_box.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_box)
	_title = KIT.raw_label("", 30, KIT.INK)
	_title.position = Vector2(16, 12) * PX
	_title.size = Vector2(168, 24) * PX
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(_title)
	_body = RichTextLabel.new()
	_body.fit_content = true
	_body.scroll_active = true
	_body.bbcode_enabled = false
	_body.position = Vector2(16, 40) * PX
	_body.size = Vector2(168, 80) * PX
	_body.add_theme_font_size_override("normal_font_size", 22)
	_body.add_theme_color_override("default_color", KIT.INK)
	_box.add_child(_body)
	_close = KIT.choice_tag("cabin.brag.close", Vector2(80, 16))
	_close.position = Vector2(60, 126) * PX
	_close.pressed.connect(close)
	_box.add_child(_close)


func open_card(title_key: String, body_text: String, close_key: String) -> void:
	_title.text = KIT.copy_text(title_key)
	_body.text = body_text
	_close.text = KIT.copy_text(close_key)
	visible = true
	_box.scale = Vector2(0.9, 0.9)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_box, "scale", Vector2.ONE, 0.15)


func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()
