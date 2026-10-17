class_name BucketAlertBar
extends VBoxContainer
## One-line bucket count/tier warning. Starts collapsed. Click to list.

var open: bool = false

var _toggle: Button
var _scroll: ScrollContainer
var _details: Label
var _n: int = 0
var _ok: bool = true
var _ok_text: String = ""


func _init() -> void:
	add_theme_constant_override("separation", 2)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_toggle = Button.new()
	_toggle.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_toggle.custom_minimum_size = Vector2(0, 24)
	_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_toggle.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_toggle.add_theme_font_size_override("font_size", 12)
	_toggle.pressed.connect(_on_toggle)
	_toggle.focus_mode = Control.FOCUS_NONE
	add_child(_toggle)
	_scroll = ScrollContainer.new()
	_scroll.visible = false
	_scroll.custom_minimum_size = Vector2(0, 88)
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	add_child(_scroll)
	_details = Label.new()
	_details.autowrap_mode = TextServer.AUTOWRAP_OFF
	_details.add_theme_font_size_override("font_size", 12)
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_details)
	visible = false


func set_message(msg: String, ok_text: String = "") -> void:
	_ok_text = ok_text
	var trimmed: String = msg.strip_edges()
	_ok = trimmed == ""
	if _ok:
		_n = 0
		_details.text = ok_text
		_scroll.visible = false
		if ok_text == "":
			visible = false
			return
		visible = true
		_toggle.text = "  Counts match."
		_toggle.disabled = true
		_toggle.mouse_default_cursor_shape = Control.CURSOR_ARROW
		_toggle.tooltip_text = ok_text
		_skin(false)
		return
	var lines: PackedStringArray = trimmed.split("\n")
	_n = lines.size()
	visible = true
	_details.text = trimmed
	_toggle.disabled = false
	_toggle.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_toggle.tooltip_text = trimmed
	_scroll.visible = open
	_sync_caption()
	_skin(true)


func _on_toggle() -> void:
	if _ok:
		return
	open = not open
	_scroll.visible = open
	_sync_caption()


func _sync_caption() -> void:
	var arrow: String = "▾" if open else "▸"
	var noun: String = "problem" if _n == 1 else "problems"
	_toggle.text = "  %s  %s bucket %s" % [arrow, _n, noun]


func _skin(bad: bool) -> void:
	var n := StyleBoxFlat.new()
	n.set_corner_radius_all(6)
	n.content_margin_left = 8
	n.content_margin_right = 8
	n.content_margin_top = 3
	n.content_margin_bottom = 3
	if bad:
		n.bg_color = Color("f8d0c8")
		n.border_color = Color("8b1e1e")
		n.set_border_width_all(1)
		_toggle.add_theme_color_override("font_color", Color("8b1e1e"))
		_details.add_theme_color_override("font_color", Color("8b1e1e"))
	else:
		n.bg_color = Color("d8e8d0")
		n.border_color = Color("3d6b3d")
		n.set_border_width_all(1)
		_toggle.add_theme_color_override("font_color", Color("3d6b3d"))
	_toggle.add_theme_stylebox_override("normal", n)
	var h: StyleBoxFlat = n.duplicate()
	h.bg_color = n.bg_color.lightened(0.08)
	_toggle.add_theme_stylebox_override("hover", h)
	_toggle.add_theme_stylebox_override("pressed", h)
	_toggle.add_theme_stylebox_override("disabled", n)
