extends PanelContainer
class_name HubCueCapsule
## Oval cue over the Take row, as wide as the hotbar.

signal finished

var _label: FitLabelBox
var _tween: Tween
var _brief: bool = false
var _reason: String = ""
var _text: String = ""
var _style: StyleBoxFlat


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 40
	z_as_relative = true
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	visible = false
	modulate.a = 0.0
	_style = StyleBoxFlat.new()
	_style.bg_color = Color(0.0, 0.0, 0.0, 0.82)
	_style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	_style.shadow_size = 10
	_style.shadow_offset = Vector2(0, 5)
	_style.content_margin_left = 28
	_style.content_margin_right = 28
	_style.content_margin_top = 10
	_style.content_margin_bottom = 10
	_style.set_corner_radius_all(40)
	add_theme_stylebox_override("panel", _style)
	_label = FitLabelBox.make()
	_label.show_frame = false
	_label.padding = 0
	_label.max_font_size = 22
	_label.min_font_size = 16
	_label.max_lines = 2
	_label.grow_to_text = false
	_label.font_color = Color("f0e6d8")
	_label.set_outline(Color("100e0c"), 3)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_label)


func brief_active() -> bool:
	return _brief and visible


func show_hold(msg: String, reason: String) -> void:
	var line: String = msg.strip_edges()
	if line == "":
		return
	if not _brief and _reason == reason and _text == line and visible:
		return
	_kill_tween()
	_brief = false
	_reason = reason
	_text = line
	_label.set_plain(line)
	visible = true
	modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.12)


func show_brief(msg: String) -> void:
	var line: String = msg.strip_edges()
	if line == "":
		return
	_kill_tween()
	_brief = true
	_reason = "brief"
	_text = line
	_label.set_plain(line)
	visible = true
	modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.12)
	_tween.tween_interval(1.0)
	_tween.tween_property(self, "modulate:a", 0.0, 0.28)
	_tween.finished.connect(_on_brief_done)


func clear_hold() -> void:
	if _brief:
		return
	if not visible:
		_reason = ""
		_text = ""
		return
	_fade_out()


func hide_now() -> void:
	_kill_tween()
	_brief = false
	_reason = ""
	_text = ""
	visible = false
	modulate.a = 0.0


func apply_pill() -> void:
	if _style == null:
		return
	var r: int = int(round(size.y * 0.5))
	_style.set_corner_radius_all(maxi(r, 24))


func _fade_out() -> void:
	_kill_tween()
	_brief = false
	_reason = ""
	_text = ""
	if not visible:
		return
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.18)
	_tween.finished.connect(func() -> void:
		visible = false
		finished.emit()
	)


func _on_brief_done() -> void:
	_brief = false
	_reason = ""
	_text = ""
	visible = false
	finished.emit()


func _kill_tween() -> void:
	if _tween != null and is_instance_valid(_tween):
		_tween.kill()
	_tween = null
