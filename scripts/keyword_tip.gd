extends PanelContainer
## Gold follow-tooltip for a keyword hover. Same chrome as the fight log hint.

var _lab: Label


func setup() -> void:
	visible = false
	z_index = 140
	top_level = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("100e0cf5")
	hsb.border_color = Color("e8c36a")
	hsb.set_border_width_all(2)
	hsb.set_corner_radius_all(14)
	hsb.content_margin_left = 14
	hsb.content_margin_right = 14
	hsb.content_margin_top = 8
	hsb.content_margin_bottom = 8
	hsb.shadow_color = Color(0.06, 0.04, 0.03, 0.55)
	hsb.shadow_size = 8
	add_theme_stylebox_override("panel", hsb)
	_lab = Label.new()
	_lab.add_theme_font_size_override("font_size", 15)
	_lab.add_theme_color_override("font_color", Color("f0e6d8"))
	_lab.add_theme_color_override("font_outline_color", Color("100e0c"))
	_lab.add_theme_constant_override("outline_size", 3)
	_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lab.custom_minimum_size = Vector2(240, 0)
	_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_lab)
	set_process(false)


func show_def(msg: String) -> void:
	if _lab == null:
		return
	var t: String = msg.strip_edges()
	if t == "":
		hide_def()
		return
	_lab.text = t
	visible = true
	reset_size()
	set_process(true)
	_follow()


func hide_def() -> void:
	visible = false
	set_process(false)


func _process(_delta: float) -> void:
	if not visible:
		set_process(false)
		return
	_follow()


func _follow() -> void:
	reset_size()
	var sz: Vector2 = get_combined_minimum_size()
	var pos: Vector2 = get_global_mouse_position() + Vector2(16.0, 18.0)
	var vp: Vector2 = get_viewport_rect().size
	pos.x = clampf(pos.x, 8.0, maxf(8.0, vp.x - sz.x - 8.0))
	pos.y = clampf(pos.y, 8.0, maxf(8.0, vp.y - sz.y - 8.0))
	global_position = pos
	size = sz
