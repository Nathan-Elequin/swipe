extends PanelContainer
## Pick-one-of-two. Sits to the right of the wheel. Does not dim the board.

signal chosen(uid: int)
signal hovered_item(it: Dictionary, card: Control)
signal unhovered_item
signal reroll_wanted

const UX := preload("res://scripts/ux_style.gd")
const COPY := preload("res://scripts/player_copy.gd")

var _title
var _sub
var _final
var _row: HBoxContainer
var _pips: HBoxContainer
var _hint
var _final_t: float = 0.0
var _aura_t: float = 0.0
var _tier: int = 1
var _loot_left: int = 0
var _loot_total: int = 0
var _sack: Texture2D
var left_it: Dictionary = {}
var right_it: Dictionary = {}
var _busy: bool = false
var _reroll: Button


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
	_title.custom_minimum_size = Vector2.ZERO
	_title.visible = false
	col.add_child(_title)
	_sub = FitLabelBox.make()
	_sub.show_frame = false
	_sub.padding = 0
	_sub.max_font_size = 14
	_sub.min_font_size = 12
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.font_color = Color("d8cbb8")
	_sub.set_outline(Color("100e0c"), 3)
	_sub.custom_minimum_size = Vector2.ZERO
	_sub.visible = false
	col.add_child(_sub)
	_final = FitLabelBox.make()
	_final.show_frame = false
	_final.padding = 0
	_final.max_font_size = 22
	_final.min_font_size = 16
	_final.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_final.font_color = Color("e8c36a")
	_final.set_outline(Color("100e0c"), 4)
	_final.custom_minimum_size = Vector2(480, 26)
	_final.visible = false
	col.add_child(_final)
	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.add_theme_constant_override("separation", 10)
	col.add_child(_row)
	_pips = HBoxContainer.new()
	_pips.alignment = BoxContainer.ALIGNMENT_CENTER
	_pips.add_theme_constant_override("separation", 6)
	_pips.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_pips)
	if ResourceLoader.exists("res://assets/dungeon/home/loot_sack_dropped.png"):
		_sack = load("res://assets/dungeon/home/loot_sack_dropped.png") as Texture2D
	elif ResourceLoader.exists("res://assets/dungeon/items/bag_of_holding.png"):
		_sack = load("res://assets/dungeon/items/bag_of_holding.png") as Texture2D
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
	_reroll = Button.new()
	_reroll.visible = false
	_reroll.text = "Reroll"
	_reroll.custom_minimum_size = Vector2(220, 36)
	_reroll.pressed.connect(func() -> void:
		if not _busy:
			reroll_wanted.emit()
	)
	col.add_child(_reroll)
	_skin_panel(1)


func present(_title_text: String, _sub_text: String, a: Control, b: Control, ia: Dictionary, ib: Dictionary) -> void:
	if _title:
		_title.visible = false
		_title.text = ""
	if _sub:
		_sub.visible = false
		_sub.text = ""
	left_it = ia
	right_it = ib
	_busy = false
	var t: int = int(ia.get("pack_tier", ia.get("tier", 1)))
	if t < 1:
		t = int(ib.get("pack_tier", ib.get("tier", 1)))
	_tier = maxi(1, t)
	_skin_panel(_tier)
	for c in _row.get_children():
		_row.remove_child(c)
		c.queue_free()
	_mount(a, ia)
	if b != null:
		var rule := PickRule.new()
		rule.ink = _metal(_tier)
		_row.add_child(rule)
	_mount(b, ib)
	visible = true
	_aura_t = 0.0
	set_process(true)


func set_loot_pips(remaining: int, total: int) -> void:
	_loot_left = maxi(0, remaining)
	_loot_total = maxi(_loot_left, total)
	if _pips == null:
		return
	for c in _pips.get_children():
		_pips.remove_child(c)
		c.queue_free()
	if _loot_total <= 0:
		_pips.visible = false
		return
	_pips.visible = true
	var show_n: int = mini(_loot_total, 12)
	for i in show_n:
		var pic := TextureRect.new()
		pic.custom_minimum_size = Vector2(28, 28)
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.texture_filter = TEXTURE_FILTER_NEAREST
		pic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pic.texture = _sack
		if i >= _loot_left:
			pic.modulate = Color(0.35, 0.32, 0.28, 0.55)
		_pips.add_child(pic)


func set_reroll(on: bool, label: String) -> void:
	if _reroll == null:
		return
	_reroll.visible = on
	_reroll.text = label


func set_final_item(on: bool) -> void:
	if _final == null:
		return
	_final.visible = on
	if on:
		_final.text = COPY.text("challenge.final_item", "Final Item")
		_final_t = 0.0
		set_process(true)
	else:
		_final.modulate = Color.WHITE


func _process(delta: float) -> void:
	if not visible:
		set_process(false)
		return
	_aura_t += delta
	_skin_panel(_tier)
	if _final == null or not _final.visible:
		return
	_final_t += delta * 6.0
	var pulse: float = 0.72 + 0.28 * (0.5 + 0.5 * sin(_final_t))
	_final.modulate = Color(1.0, pulse, 0.45, 1.0)


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
	var breath: float = 0.5 + 0.5 * sin(_aura_t * 2.4)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(2)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 14
	sb.content_margin_bottom = 12
	sb.shadow_color = Color(metal.r, metal.g, metal.b, 0.34 + breath * 0.22)
	sb.shadow_size = 14 + int(breath * 8.0)
	sb.shadow_offset = Vector2.ZERO
	add_theme_stylebox_override("panel", sb)
	if _row:
		for c in _row.get_children():
			if c is PickRule:
				(c as PickRule).ink = metal
				c.queue_redraw()
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


func pick_card_id(id: String) -> bool:
	if _busy or not visible:
		return false
	var want: String = id.strip_edges()
	for it in [left_it, right_it]:
		if str(it.get("card_id", "")) != want:
			continue
		_busy = true
		chosen.emit(int(it.get("uid", 0)))
		return true
	return false


func hide_draft() -> void:
	visible = false
	scale = Vector2.ONE
	left_it = {}
	right_it = {}
	set_reroll(false, "")
	set_final_item(false)
	set_loot_pips(0, 0)
	set_process(false)
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


class PickRule extends Control:
	var ink: Color = Color("f0e6d8")

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(22, 0)
		size_flags_vertical = Control.SIZE_EXPAND_FILL

	func _draw() -> void:
		var x: float = size.x * 0.5
		var top := Vector2(x, 2.0)
		var bot := Vector2(x, maxf(8.0, size.y - 2.0))
		draw_line(top, bot, Color("100e0c"), 12.0, true)
		draw_line(top, bot, ink, 6.0, true)
