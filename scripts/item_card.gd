extends PanelContainer
## Named card. Icon + live number. Shift shows the hover equation in the number slot.

signal picked
signal hovered
signal unhovered
signal edit_wanted
signal passed_swipe

const UX := preload("res://scripts/ux_style.gd")
const UI := preload("res://scripts/ui_palette.gd")
const HOVER_PANEL := preload("res://scripts/hover_panel.gd")
const COPY := preload("res://scripts/player_copy.gd")

const CARD_W := 140.0
const CARD_H := 210.0
const COMPACT_W := 124.0
const GATE_W := 136.0
const GATE_H := 192.0
const SHOW_W := 236.0
const SHOW_H := 400.0
const TITLE_H := 26.0
const ICON_H := 64.0
const NUM_H := 36.0
const FORMULA_H := 54.0
const WORD_H := 96.0
const FORMULA_W := 116.0
const OAK := Color("3B2618")
const WEAK_METAL := Color("B8733A")
const TOUGH_METAL := Color("C9CED6")
const DEADLY_METAL := Color("FFD84A")
const ATK_RED := Color("E86A62")
const BLK_BLUE := Color("4FA3D9")
const HEAL_GREEN := Color("7BC950")
const KO_PLUM := Color("C080E0")
const PARCHMENT := Color("E9D3A1")
const SOOT := Color("1A120E")

var uid: int = 0
var card_id: String = ""
var spent: bool = false
var kind: String = "ATK"

var _num: Label
var _ghost: Label
var _eq: RichTextLabel
var _mark: TextureRect
var _icon: TextureRect
var _title: Label
var _rank: Label
var _fill: Color
var _rim: Color
var _tier: int = 1
var _num_col: Color = Color.WHITE
var _shown: String = ""
var _lift: Tween
var _formula: String = ""
var _formula_on: bool = false
var _glow: bool = false
var _glow_t: float = 0.0
var _hot: bool = false
var _showcase: bool = false
var _ability: RichTextLabel
var _col: VBoxContainer
var _num_host: Control
var _steal_tex: Texture2D
var _press_from: Vector2 = Vector2.ZERO
var _holding: bool = false
var _echo_mark: TextureRect
var _loss: TextureRect
var _stone: TextureRect
var _playable: bool = false
var _spent_lab: Label
var _ability_bb: String = ""
var _stat: Control
var _stat_lab: RichTextLabel
var _val_row: Control
var _can_use: bool = true
var _deny: Control
var _tag: Label
var _compact: bool = false
var _gate_fit: bool = false
var _rest_y: float = 0.0
var _formula_box: Control
var _gap_icon: Control
var _gap_num: Control
var _gap_formula: Control


func setup(
	p_uid: int,
	p_id: String,
	number_text: String,
	icon: Texture2D,
	fill: Color,
	rim: Color,
	title: String = "",
	num_col: Color = Color.WHITE,
	p_kind: String = "ATK",
	mark: Texture2D = null
) -> void:
	uid = p_uid
	card_id = p_id
	kind = p_kind
	_fill = fill
	_rim = rim
	_num_col = num_col
	_tier = 1
	tooltip_text = ""
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(CARD_W, CARD_H)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	clip_contents = true
	texture_filter = TEXTURE_FILTER_NEAREST
	theme = load("res://themes/swipe_theme.tres")
	_apply_style(false)
	mouse_entered.connect(_on_in)
	mouse_exited.connect(_on_out)
	gui_input.connect(_on_gui)

	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 8)
	pad.add_theme_constant_override("margin_right", 8)
	pad.add_theme_constant_override("margin_top", 8)
	pad.add_theme_constant_override("margin_bottom", 8)
	add_child(pad)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_BEGIN
	col.add_theme_constant_override("separation", 0)
	pad.add_child(col)
	_col = col

	_rank = Label.new()
	_rank.visible = false
	_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rank.autowrap_mode = TextServer.AUTOWRAP_WORD
	_rank.max_lines_visible = 2
	_rank.custom_minimum_size = Vector2(104, 0)
	UI.apply_tag(_rank, Color("c4a574"), UI.SIZE_TAG)
	_rank.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_title = Label.new()
	_title.text = title
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_OFF
	_title.max_lines_visible = 1
	_title.clip_text = true
	_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_title.custom_minimum_size = Vector2(104, TITLE_H)
	UI.apply_name(_title, PARCHMENT, UI.SIZE_MIN)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_title)
	col.add_child(_rank)

	_ability = RichTextLabel.new()
	_ability.bbcode_enabled = true
	_ability.fit_content = true
	_ability.scroll_active = false
	_ability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI.apply_rich(_ability, "body", PARCHMENT)
	_ability.add_theme_constant_override("line_separation", 3)
	_ability.custom_minimum_size = Vector2(104, 0)
	_ability.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ability.visible = false
	_ability.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	col.add_child(_ability)

	_gap_icon = _spacer(4)
	col.add_child(_gap_icon)

	_icon = TextureRect.new()
	_icon.texture = icon
	_icon.custom_minimum_size = Vector2(64, ICON_H)
	_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_icon.texture_filter = TEXTURE_FILTER_NEAREST
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_icon)

	_gap_num = _spacer(4)
	col.add_child(_gap_num)

	var num_host := Control.new()
	num_host.custom_minimum_size = Vector2(104, NUM_H)
	num_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(num_host)
	_num_host = num_host

	_mark = TextureRect.new()
	_mark.texture = mark
	_mark.visible = false
	_mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mark.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	num_host.add_child(_mark)

	_ghost = Label.new()
	_ghost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ghost.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	UI.apply_number(_ghost, _num_col, UI.SIZE_NUMBER)
	_ghost.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.modulate.a = 0.0
	num_host.add_child(_ghost)

	var val_row := HBoxContainer.new()
	val_row.alignment = BoxContainer.ALIGNMENT_CENTER
	val_row.add_theme_constant_override("separation", 6)
	val_row.set_anchors_preset(Control.PRESET_TOP_WIDE)
	val_row.offset_left = 0
	val_row.offset_top = 0
	val_row.offset_right = 0
	val_row.offset_bottom = 36
	val_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	num_host.add_child(val_row)
	_val_row = val_row

	_num = Label.new()
	_num.text = number_text
	_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_num.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	UI.apply_number(_num, _num_col, UI.SIZE_NUMBER)
	_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	val_row.add_child(_num)

	_tag = Label.new()
	_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tag.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	UI.apply_tag(_tag, PARCHMENT, UI.SIZE_TAG)
	_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	val_row.add_child(_tag)

	_gap_formula = _spacer(6)
	col.add_child(_gap_formula)

	_formula_box = Control.new()
	_formula_box.custom_minimum_size = Vector2(FORMULA_W, FORMULA_H)
	_formula_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_formula_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_formula_box.clip_contents = true
	col.add_child(_formula_box)

	_eq = RichTextLabel.new()
	_eq.bbcode_enabled = true
	_eq.fit_content = false
	_eq.scroll_active = false
	_eq.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI.apply_rich(_eq, "formula", PARCHMENT)
	_eq.add_theme_constant_override("line_separation", 0)
	_eq.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_eq.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_eq.visible = false
	_formula_box.add_child(_eq)
	_shown = number_text
	_rank.visible = false
	_apply_face(number_text)
	_layout_hand_budget()

	_spent_lab = Label.new()
	_spent_lab.text = COPY.need("hand.spent")
	_spent_lab.visible = false
	_spent_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_spent_lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	UI.apply_tag(_spent_lab, PARCHMENT, UI.SIZE_TAG)
	_spent_lab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_spent_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_spent_lab.rotation = -0.28
	num_host.add_child(_spent_lab)

	_deny = DenyPaint.new()
	_deny.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_deny.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_deny.visible = false
	add_child(_deny)


func set_echo_mark(tex: Texture2D) -> void:
	if _echo_mark == null:
		_echo_mark = TextureRect.new()
		_echo_mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_echo_mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_echo_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_echo_mark.texture_filter = TEXTURE_FILTER_NEAREST
		_echo_mark.custom_minimum_size = Vector2(28, 28)
		_echo_mark.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		_echo_mark.offset_left = -32
		_echo_mark.offset_top = 4
		_echo_mark.offset_right = -4
		_echo_mark.offset_bottom = 32
		add_child(_echo_mark)
	_echo_mark.texture = tex
	_echo_mark.visible = tex != null
	_echo_mark.modulate = Color(1, 1, 1, 0.82)


func set_loss_icon(tex: Texture2D) -> void:
	if _loss == null:
		_loss = TextureRect.new()
		_loss.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_loss.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_loss.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_loss.texture_filter = TEXTURE_FILTER_NEAREST
		_loss.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
		_loss.offset_left = 8
		_loss.offset_top = -12
		_loss.offset_right = 32
		_loss.offset_bottom = 12
		if _num_host != null:
			_num_host.add_child(_loss)
		else:
			add_child(_loss)
	_loss.texture = tex
	_loss.visible = tex != null and not _formula_on
	_loss.modulate = Color(UX.HP)


func set_petrified(on: bool) -> void:
	if _stone == null:
		_stone = TextureRect.new()
		_stone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_stone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_stone.stretch_mode = TextureRect.STRETCH_SCALE
		_stone.texture_filter = TEXTURE_FILTER_NEAREST
		_stone.texture = load("res://assets/dungeon/ui/petrify_stone.png") as Texture2D
		_stone.modulate = Color(0.82, 0.78, 0.70, 0.78)
		add_child(_stone)
	_stone.visible = on
	_sync_face()


func set_title(text: String) -> void:
	if _title == null:
		return
	_title.text = text


func set_ability_bb(bb: String) -> void:
	_ability_bb = bb.strip_edges()
	if _ability == null:
		return
	_ability.text = _ability_bb
	_sync_inspect_face()


func set_steal_cursor(tex: Texture2D) -> void:
	_steal_tex = tex


func drop_steal_cursor() -> void:
	if _steal_tex != null:
		Input.set_custom_mouse_cursor(null)


func set_showcase(on: bool) -> void:
	_showcase = on
	clip_contents = not on
	custom_minimum_size = Vector2(SHOW_W, SHOW_H) if on else Vector2(COMPACT_W if _compact else CARD_W, CARD_H)
	if _col:
		_col.add_theme_constant_override("separation", 6 if on else 1)
	if _title:
		UI.apply_name(_title, PARCHMENT, UI.SIZE_MIN)
		_title.custom_minimum_size = Vector2(196 if on else 104, 32 if on else TITLE_H)
		_title.max_lines_visible = 2 if on else 1
		_title.autowrap_mode = TextServer.AUTOWRAP_WORD if on else TextServer.AUTOWRAP_OFF
		_title.clip_text = not on
	if _rank:
		_rank.visible = false
		UI.apply_tag(_rank, Color("c4a574"), UI.SIZE_TAG)
		_rank.custom_minimum_size = Vector2(196 if on else 104, 0)
	if _icon:
		_icon.custom_minimum_size = Vector2(96, 96) if on else Vector2(64, ICON_H)
	if _num_host:
		_num_host.custom_minimum_size = Vector2(196, 44) if on else Vector2(104, NUM_H)
	if _num:
		UI.apply_number(_num, _num_col, UI.SIZE_NUMBER)
	if _ghost:
		UI.apply_number(_ghost, _num_col, UI.SIZE_NUMBER)
	if _eq:
		UI.apply_rich(_eq, "body", PARCHMENT)
	if _ability:
		_ability.custom_minimum_size = Vector2(196 if on else 104, 0)
		UI.apply_rich(_ability, "body", PARCHMENT)
	_layout_showcase()
	_sync_inspect_face()
	_apply_style(_hot)
	_sync_face()


func set_stat_look(look: Dictionary) -> void:
	if _stat != null:
		_stat.queue_free()
		_stat = null
	if _stat_lab != null:
		_stat_lab.queue_free()
		_stat_lab = null
	if not _showcase or _num_host == null or look.is_empty():
		_sync_inspect_face()
		return
	var kind: String = str(look.get("stat_kind", ""))
	var bb: String = str(look.get("stat_bb", "")).strip_edges()
	if bb != "" and kind == "":
		_stat_lab = RichTextLabel.new()
		_stat_lab.bbcode_enabled = true
		_stat_lab.fit_content = true
		_stat_lab.scroll_active = false
		_stat_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		UI.apply_rich(_stat_lab, "number", PARCHMENT)
		_stat_lab.text = "[center]%s[/center]" % bb
		_stat_lab.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_stat_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_num_host.add_child(_stat_lab)
	elif kind != "":
		_stat = HOVER_PANEL.stat_badge(look)
		_stat.custom_minimum_size = Vector2(0, 52)
		_stat.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_num_host.add_child(_stat)
	_sync_inspect_face()


func set_kind(p_kind: String) -> void:
	kind = p_kind
	_apply_face(_shown)
	_layout_hand_budget()
	_sync_inspect_face()


func set_compact(on: bool) -> void:
	_compact = on
	if _showcase:
		return
	_lock_hand_size()


func set_gate_fit(on: bool) -> void:
	_gate_fit = on
	_compact = on or _compact
	if _showcase:
		return
	_lock_hand_size()
	_layout_hand_budget()


func _spacer(h: float) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, h)
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return s


func _tier_metal_color() -> Color:
	if _tier >= 3:
		return DEADLY_METAL
	if _tier == 2:
		return TOUGH_METAL
	return WEAK_METAL


func _face_of(number_text: String) -> Dictionary:
	if kind == "DEFEAT" or kind == "FANGS" or kind == "KO":
		return {"num": COPY.need("hand.tag.ko"), "tag": "", "col": KO_PLUM}
	var tag := ""
	var col: Color = PARCHMENT
	if kind == "ATK":
		tag = COPY.need("hand.tag.atk")
		col = ATK_RED
	elif kind == "BLK":
		tag = COPY.need("hand.tag.blk")
		col = BLK_BLUE
	elif kind == "HEAL":
		tag = COPY.need("hand.tag.heal")
		col = HEAL_GREEN
	var shown: String = number_text.strip_edges()
	if shown == "—" or shown == "–" or shown == "-" or shown.to_upper() == "X":
		shown = "?"
	if shown == "" and tag == "":
		shown = ""
	elif shown == "":
		shown = "?"
	return {"num": shown, "tag": tag, "col": col}


func _apply_face(number_text: String) -> void:
	var face: Dictionary = _face_of(number_text)
	if _num:
		var ntxt: String = str(face.get("num", ""))
		_num.text = ntxt
		UI.apply_number(_num, face.get("col", PARCHMENT), UI.SIZE_NUMBER)
		_num.visible = true
	if _tag:
		_tag.text = str(face.get("tag", ""))
		UI.apply_tag(_tag, face.get("col", PARCHMENT), UI.SIZE_TAG)
		_tag.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		_tag.max_lines_visible = 3
		_tag.custom_minimum_size = Vector2(70, 0)
		_tag.visible = str(face.get("tag", "")).strip_edges() != ""
	if _mark:
		_mark.visible = false


func set_live(number_text: String, _note: String = "", can_use: bool = true) -> void:
	if _num == null:
		return
	_can_use = can_use
	_shown = number_text
	_apply_face(number_text)
	if _spent_lab:
		_spent_lab.visible = spent
	if _mark != null:
		_mark.visible = false
	if _loss != null:
		_loss.visible = _loss.texture != null and not _formula_on
	_sync_face()
	_sync_inspect_face()


func set_rank(_text: String) -> void:
	if _rank == null:
		return
	_rank.visible = false


func set_palette(fill: Color, metal: Color, tier: int = 1) -> void:
	_fill = fill
	_rim = metal
	_tier = maxi(1, tier)
	_apply_style(_hot)


func set_draft_glow(on: bool) -> void:
	_glow = on
	set_process(on or _playable)
	if not on and not _playable:
		_glow_t = 0.0
	_apply_style(_hot)
	_sync_face()


func set_playable(on: bool) -> void:
	_playable = on
	set_process(_glow or _playable)
	_apply_style(_hot)
	_sync_face()


func _process(delta: float) -> void:
	if not _glow and not _playable:
		return
	_glow_t += delta
	_apply_style(_hot)


func set_formula(bb: String) -> void:
	_formula = bb


func show_formula(on: bool) -> void:
	_formula_on = on and _formula != ""
	if not _showcase:
		_lock_hand_size()
	_sync_inspect_face()


func _hand_size() -> Vector2:
	if _gate_fit:
		return Vector2(GATE_W, GATE_H)
	return Vector2(COMPACT_W if _compact else CARD_W, CARD_H)


func _lock_hand_size() -> void:
	var sz: Vector2 = _hand_size()
	custom_minimum_size = sz
	size = sz
	clip_contents = true
	update_minimum_size()


func _get_minimum_size() -> Vector2:
	if _showcase:
		return Vector2(SHOW_W, SHOW_H)
	return _hand_size()


func _layout_showcase() -> void:
	if _col == null or _title == null or _icon == null or _num_host == null or _ability == null:
		return
	if _showcase:
		_col.move_child(_icon, _title.get_index() + 1)
		_col.move_child(_num_host, _icon.get_index() + 1)
		_col.move_child(_ability, _num_host.get_index() + 1)
		if _formula_box:
			_formula_box.visible = false
		if _gap_icon:
			_gap_icon.visible = false
		if _gap_num:
			_gap_num.visible = false
		if _gap_formula:
			_gap_formula.visible = false
	else:
		if _rank != null:
			_col.move_child(_rank, _title.get_index() + 1)
			_col.move_child(_ability, _rank.get_index() + 1)
		else:
			_col.move_child(_ability, _title.get_index() + 1)
		if _gap_icon:
			_col.move_child(_gap_icon, _ability.get_index() + 1)
			_col.move_child(_icon, _gap_icon.get_index() + 1)
		else:
			_col.move_child(_icon, _ability.get_index() + 1)
		if _gap_num:
			_col.move_child(_gap_num, _icon.get_index() + 1)
			_col.move_child(_num_host, _gap_num.get_index() + 1)
		else:
			_col.move_child(_num_host, _icon.get_index() + 1)
		if _gap_formula and _formula_box:
			_col.move_child(_gap_formula, _num_host.get_index() + 1)
			_col.move_child(_formula_box, _gap_formula.get_index() + 1)
		_layout_hand_budget()


func _is_word_card() -> bool:
	var k: String = kind.to_upper()
	if k == "SMOKE" or k == "CHAOS" or k == "SKIP":
		return true
	if UX.is_stat_kind(k):
		return false
	var shown: String = _shown.strip_edges()
	return shown == "" or shown == "?" or shown.to_upper() == "X"


func _layout_hand_budget() -> void:
	if _showcase:
		return
	var word: bool = _is_word_card()
	var inner_w: float = _hand_size().x - 16.0
	var title_h: float = 22.0 if _gate_fit else TITLE_H
	var icon_h: float = 52.0 if _gate_fit else ICON_H
	var num_h: float = 28.0 if _gate_fit else NUM_H
	var formula_h: float = 40.0 if _gate_fit else FORMULA_H
	var word_h: float = 72.0 if _gate_fit else WORD_H
	if _title:
		_title.custom_minimum_size = Vector2(inner_w, title_h)
	if _icon:
		_icon.custom_minimum_size = Vector2(icon_h, icon_h)
	if _gap_icon:
		_gap_icon.visible = true
		_gap_icon.custom_minimum_size = Vector2(0, 2 if _gate_fit else 4)
	if _gap_num:
		_gap_num.visible = true
		_gap_num.custom_minimum_size = Vector2(0, 2 if _gate_fit else 4)
	if _num_host:
		_num_host.visible = not word
		_num_host.custom_minimum_size = Vector2(inner_w, 0.0 if word else num_h)
	if _gap_formula:
		_gap_formula.visible = not word
		_gap_formula.custom_minimum_size = Vector2(0, 0.0 if word else (4.0 if _gate_fit else 6.0))
	if _formula_box:
		_formula_box.visible = true
		_formula_box.custom_minimum_size = Vector2(minf(FORMULA_W, inner_w), word_h if word else formula_h)


func _sync_inspect_face() -> void:
	if _ability != null:
		_ability.text = _ability_bb
		_ability.visible = _showcase and _ability_bb != ""
	if _icon != null:
		_icon.visible = true
	if not _showcase:
		_layout_hand_budget()
	if _val_row != null:
		_val_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var word: bool = _is_word_card()
	var formula_txt: String = _pretty_formula(_formula)
	if word and formula_txt.strip_edges() == "" and _ability_bb.strip_edges() != "":
		formula_txt = _ability_bb
	if _eq != null:
		if _showcase:
			_eq.visible = false
		elif _formula_on:
			var box_h: float = (72.0 if _gate_fit else WORD_H) if word else (40.0 if _gate_fit else FORMULA_H)
			var box_w: float = minf(FORMULA_W, _hand_size().x - 16.0)
			var sizes: Array = [15, 14, 13, 12, 11] if word else [13, 12, 11]
			var max_lines: int = 4 if word else 3
			_fit_formula(_eq, formula_txt, Vector2(box_w, box_h), sizes, max_lines)
			_eq.visible = formula_txt.strip_edges() != ""
		else:
			_eq.text = ""
			_eq.visible = false
	var show_stat: bool = _showcase and not _formula_on
	if _stat != null:
		_stat.visible = show_stat
	if _stat_lab != null:
		_stat_lab.visible = show_stat
	var badge: bool = _showcase and (_stat != null or _stat_lab != null)
	if _num != null:
		_num.visible = not badge and not word and _shown != ""
	if _tag != null:
		_tag.visible = not badge and not word and str(_tag.text).strip_edges() != ""
	if _ghost != null:
		_ghost.visible = not _formula_on and not badge and not word
	if _mark != null:
		_mark.visible = (not _formula_on) and not badge and not word and _mark.texture != null and _shown == ""
	if _loss != null:
		_loss.visible = (not _formula_on) and not badge and not word and _loss.texture != null
	if not _showcase:
		_lock_hand_size()


func _fit_formula(rtl: RichTextLabel, bb: String, box: Vector2, sizes: Array, max_lines: int) -> void:
	var font: Font = UI.font_regular()
	var plain: String = _plain_formula(bb)
	var chosen: int = int(sizes[sizes.size() - 1])
	var shown: String = plain
	for fs in sizes:
		var use: int = int(fs)
		if font != null:
			var sz: Vector2 = font.get_multiline_string_size(plain, HORIZONTAL_ALIGNMENT_CENTER, box.x, use)
			var lines: int = _wrap_line_count(font, plain, box.x, use)
			if sz.y <= box.y + 0.5 and lines <= max_lines:
				chosen = use
				shown = plain
				break
		chosen = use
	if font != null:
		var sz2: Vector2 = font.get_multiline_string_size(shown, HORIZONTAL_ALIGNMENT_CENTER, box.x, chosen)
		var lines2: int = _wrap_line_count(font, shown, box.x, chosen)
		while (sz2.y > box.y + 0.5 or lines2 > max_lines) and shown.length() > 1:
			shown = shown.substr(0, shown.length() - 1).strip_edges()
			if shown.ends_with("\n"):
				shown = shown.substr(0, shown.length() - 1).strip_edges()
			shown += "…"
			sz2 = font.get_multiline_string_size(shown, HORIZONTAL_ALIGNMENT_CENTER, box.x, chosen)
			lines2 = _wrap_line_count(font, shown, box.x, chosen)
	rtl.text = "[center]%s[/center]" % shown
	rtl.add_theme_font_override("normal_font", font)
	rtl.add_theme_font_size_override("normal_font_size", chosen)
	rtl.add_theme_font_size_override("bold_font_size", chosen)
	rtl.add_theme_color_override("default_color", PARCHMENT)
	rtl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rtl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


func _plain_formula(bb: String) -> String:
	var t: String = _pretty_formula(bb)
	var out := ""
	var i := 0
	while i < t.length():
		if t[i] == "[":
			var close: int = t.find("]", i)
			if close >= 0:
				i = close + 1
				continue
		out += t[i]
		i += 1
	return out.strip_edges()


func _wrap_line_count(font: Font, text: String, width: float, fs: int) -> int:
	if text == "":
		return 0
	var n := 0
	for line in text.split("\n"):
		var w: float = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		n += maxi(1, int(ceili(w / maxf(width, 1.0))))
	return n


func _dissolve(old_s: String, new_s: String) -> void:
	_ghost.text = old_s
	_ghost.position = Vector2.ZERO
	_ghost.scale = Vector2.ONE
	_ghost.modulate = Color(1, 1, 1, 1)
	_num.text = new_s
	_num.modulate = Color(1, 1, 1, 0)
	_shown = new_s
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_ghost, "modulate:a", 0.0, 0.2)
	tw.tween_property(_ghost, "position:y", -18.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_ghost, "scale", Vector2(1.18, 1.18), 0.2)
	tw.tween_property(_num, "modulate:a", 1.0, 0.18).set_delay(0.05)


func toss() -> void:
	var start: Vector2 = global_position
	var host: Node = get_tree().root
	reparent(host, true)
	global_position = start
	z_index = 80
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tw := create_tween()
	tw.set_parallel(true)
	var side: float = 1.0 if randf() > 0.5 else -1.0
	tw.tween_property(self, "global_position", start + Vector2(side * 260.0, -210.0), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "rotation", side * 1.35, 0.5)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	await tw.finished
	queue_free()


func bounce() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.12, 1.12), 0.08)
	tw.tween_property(self, "scale", Vector2.ONE, 0.12)


func _pretty_formula(bb: String) -> String:
	return UX.pretty_formula(bb)


func _apply_style(hot: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = _fill if _fill.a > 0.08 else OAK
	var metal: Color = _tier_metal_color()
	if hot:
		sb.border_color = DEADLY_METAL
		sb.set_border_width_all(6)
		sb.shadow_color = Color(DEADLY_METAL.r, DEADLY_METAL.g, DEADLY_METAL.b, 0.9)
		sb.shadow_size = 4
	else:
		sb.border_color = metal
		sb.set_border_width_all(6)
		sb.shadow_size = 0
	if _glow and not spent:
		var pulse := 0.50 + 0.50 * absf(sin(_glow_t * TAU / 0.9))
		sb.border_color = Color(DEADLY_METAL.r, DEADLY_METAL.g, DEADLY_METAL.b, 0.4 + pulse * 0.6)
	sb.set_corner_radius_all(0)
	sb.content_margin_left = 0
	sb.content_margin_right = 0
	sb.content_margin_top = 0
	sb.content_margin_bottom = 0
	add_theme_stylebox_override("panel", sb)


func _on_in() -> void:
	_hot = true
	_apply_style(true)
	pivot_offset = size * 0.5
	if spent or not _can_use:
		hovered.emit()
		return
	if _lift != null:
		_lift.kill()
	_lift = create_tween()
	if not _showcase:
		_lift.tween_property(self, "position:y", _rest_y - 18.0, 0.1)
	else:
		_lift.tween_property(self, "scale", Vector2(1.10, 1.10), 0.1)
	if _steal_tex != null:
		Input.set_custom_mouse_cursor(_steal_tex, Input.CURSOR_ARROW, Vector2(6, 4))
	hovered.emit()


func _on_out() -> void:
	_hot = false
	_holding = false
	_apply_style(false)
	if _lift != null:
		_lift.kill()
	_lift = create_tween()
	if not _showcase:
		_lift.tween_property(self, "position:y", _rest_y, 0.1)
	else:
		_lift.tween_property(self, "scale", Vector2.ONE, 0.1)
	if _steal_tex != null:
		Input.set_custom_mouse_cursor(null)
	unhovered.emit()


func _on_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if OS.has_feature("editor"):
				edit_wanted.emit()
			return
		if spent:
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if event.pressed:
			_holding = true
			_press_from = event.global_position
			accept_event()
			return
		if not _holding:
			return
		_holding = false
		var delta: Vector2 = event.global_position - _press_from
		if _showcase and delta.x < -78.0 and absf(delta.y) < 140.0:
			passed_swipe.emit()
		else:
			picked.emit()
		accept_event()


func _sync_face() -> void:
	var stone_on: bool = _stone != null and _stone.visible
	if _deny != null:
		_deny.visible = false
	if stone_on:
		modulate = Color(0.58, 0.56, 0.52, 1.0)
		return
	if _glow and _can_use and not spent:
		return
	if spent:
		modulate = Color(1, 1, 1, 0.38)
		return
	if not _can_use:
		modulate = Color(1, 1, 1, 0.60)
		return
	modulate = Color.WHITE


class DenyPaint extends Control:
	func _ready() -> void:
		mouse_filter = MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)

	func _draw() -> void:
		if size.x < 8.0 or size.y < 8.0:
			return
		var pad := 14.0
		var a := Vector2(pad, pad)
		var b := Vector2(size.x - pad, size.y - pad)
		var c := Vector2(size.x - pad, pad)
		var d := Vector2(pad, size.y - pad)
		draw_line(a, b, Color("100e0c", 0.82), 7.0, true)
		draw_line(c, d, Color("100e0c", 0.82), 7.0, true)
		draw_line(a, b, Color("f0e6d8", 0.88), 3.5, true)
		draw_line(c, d, Color("f0e6d8", 0.88), 3.5, true)
