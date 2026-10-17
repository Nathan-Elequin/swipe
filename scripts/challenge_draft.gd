extends PanelContainer
## Pick-one-of-two. Sits to the right of the wheel. Does not dim the board.

signal chosen(uid: int)
signal hovered_item(it: Dictionary, card: Control)
signal unhovered_item

const UX := preload("res://scripts/ux_style.gd")

var _title: Label
var _sub: Label
var _row: HBoxContainer
var _hint: Label
var left_it: Dictionary = {}
var right_it: Dictionary = {}
var _busy: bool = false


func setup() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = false
	z_index = 20
	custom_minimum_size = Vector2(508, 0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1a1410f2")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 12
	add_theme_stylebox_override("panel", sb)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	col.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(col)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_font_size_override("font_size", 20)
	_title.add_theme_color_override("font_color", Color("e8c36a"))
	_title.add_theme_color_override("font_outline_color", Color("100e0c"))
	_title.add_theme_constant_override("outline_size", 4)
	col.add_child(_title)
	_sub = Label.new()
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_sub.add_theme_font_size_override("font_size", 14)
	_sub.add_theme_color_override("font_color", Color("d8cbb8"))
	_sub.add_theme_color_override("font_outline_color", Color("100e0c"))
	_sub.add_theme_constant_override("outline_size", 3)
	col.add_child(_sub)
	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.add_theme_constant_override("separation", 12)
	col.add_child(_row)
	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.add_theme_font_size_override("font_size", 13)
	_hint.add_theme_color_override("font_color", Color("c4a574"))
	_hint.text = "Pick one. Hover to read it."
	col.add_child(_hint)


func present(title: String, sub: String, a: Control, b: Control, ia: Dictionary, ib: Dictionary) -> void:
	_title.text = title
	_sub.text = sub
	left_it = ia
	right_it = ib
	_busy = false
	for c in _row.get_children():
		_row.remove_child(c)
		c.queue_free()
	_mount(a, ia)
	_mount(b, ib)
	visible = true


func draft_cards() -> Array:
	var out: Array = []
	if _row == null:
		return out
	for c in _row.get_children():
		out.append(c)
	return out


func hide_draft() -> void:
	visible = false
	left_it = {}
	right_it = {}
	for c in _row.get_children():
		_row.remove_child(c)
		c.queue_free()


func _mount(card: Control, it: Dictionary) -> void:
	if card == null:
		return
	_row.add_child(card)
	if card.has_signal("picked"):
		card.picked.connect(func() -> void:
			if _busy:
				return
			_busy = true
			chosen.emit(int(it.get("uid", 0)))
		)
	if card.has_signal("hovered"):
		card.hovered.connect(func() -> void:
			hovered_item.emit(it, card)
		)
	if card.has_signal("unhovered"):
		card.unhovered.connect(func() -> void:
			unhovered_item.emit()
		)
