extends PanelContainer
## Pick-one-of-two. Sits to the right of the wheel. Does not dim the board.

signal chosen(uid: int)
signal hovered_item(it: Dictionary, card: Control)
signal unhovered_item

const UX := preload("res://scripts/ux_style.gd")
const COPY := preload("res://scripts/player_copy.gd")

var _title
var _sub
var _row: HBoxContainer
var _hint
var left_it: Dictionary = {}
var right_it: Dictionary = {}
var _busy: bool = false


func setup() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = false
	z_index = 20
	custom_minimum_size = Vector2(508, 0)
	_skin_panel(1)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	col.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	add_child(col)
	_title = FitLabelBox.make()
	_title.show_frame = false
	_title.padding = 0
	_title.max_font_size = 20
	_title.min_font_size = 16
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.font_color = Color("e8c36a")
	_title.set_outline(Color("100e0c"), 4)
	_title.custom_minimum_size = Vector2(480, 28)
	col.add_child(_title)
	_sub = FitLabelBox.make()
	_sub.show_frame = false
	_sub.padding = 0
	_sub.max_font_size = 14
	_sub.min_font_size = 12
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.font_color = Color("d8cbb8")
	_sub.set_outline(Color("100e0c"), 3)
	_sub.custom_minimum_size = Vector2(480, 22)
	col.add_child(_sub)
	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.add_theme_constant_override("separation", 22)
	col.add_child(_row)
	_hint = FitLabelBox.make()
	_hint.show_frame = false
	_hint.padding = 0
	_hint.max_font_size = 13
	_hint.min_font_size = 12
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.font_color = Color("c4a574")
	_hint.set_copy("challenge.pick_hover")
	_hint.custom_minimum_size = Vector2(480, 20)
	col.add_child(_hint)
	_skin_panel(1)


func present(title: String, sub: String, a: Control, b: Control, ia: Dictionary, ib: Dictionary) -> void:
	_title.text = title
	_sub.text = sub
	left_it = ia
	right_it = ib
	_busy = false
	var t: int = int(ia.get("pack_tier", ia.get("tier", 1)))
	if t < 1:
		t = int(ib.get("pack_tier", ib.get("tier", 1)))
	_skin_panel(maxi(1, t))
	for c in _row.get_children():
		_row.remove_child(c)
		c.queue_free()
	_mount(a, ia)
	_mount(b, ib)
	visible = true


func _metal(tier: int) -> Color:
	if tier >= 3:
		return Color("e8c36a")
	if tier == 2:
		return Color("c5cdd8")
	return Color("c08050")


func _skin_panel(tier: int) -> void:
	var metal: Color = _metal(tier)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1a1410f2")
	sb.border_color = metal
	sb.set_border_width_all(2 if tier <= 1 else (3 if tier == 2 else 4))
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 12
	sb.shadow_color = Color(metal.r, metal.g, metal.b, 0.28 if tier <= 1 else (0.40 if tier == 2 else 0.55))
	sb.shadow_size = 4 if tier <= 1 else (8 if tier == 2 else 14)
	add_theme_stylebox_override("panel", sb)
	if _title:
		_title.font_color = metal.lightened(0.12)
	if _hint:
		_hint.font_color = metal


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
