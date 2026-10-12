extends PanelContainer
## Shared monster plate for placement, fight, and inspect. Scene: owner_plate.tscn.

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")
const UI := preload("res://scripts/ui_palette.gd")

const VOID := Color("0B0706")
const INSET := Color("4A2F1F")
const EDGE := Color("7A4E2B")
const PARCHMENT := Color("E9D3A1")
const DIM := Color("A88C66")
const ATK_GOLD := Color("FFD84A")
const HP_RED := Color("E86A62")
const SOOT := Color("1A120E")
const WEAK := Color("B8733A")
const TOUGH := Color("C9CED6")
const DEADLY := Color("FFD84A")

var _well: TextureRect
var _name: Label
var _pill: Label
var _atk: Label
var _atk_tag: Label
var _hp: Label
var _hp_tag: Label
var _ability: Label
var _call_slot: VBoxContainer
var _font_sk: Font


func _ready() -> void:
	_font_sk = UI.font_silk()
	theme = load("res://themes/swipe_theme.tres")
	custom_minimum_size = Vector2(480, 0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST
	_build()


func _build() -> void:
	add_theme_stylebox_override("panel", UX.plate_inset(0))

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(top)

	var well_box := PanelContainer.new()
	well_box.custom_minimum_size = Vector2(140, 140)
	well_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var well_sb := StyleBoxFlat.new()
	well_sb.bg_color = VOID
	well_sb.border_color = EDGE
	well_sb.set_border_width_all(4)
	well_box.add_theme_stylebox_override("panel", well_sb)
	top.add_child(well_box)
	_well = TextureRect.new()
	_well.custom_minimum_size = Vector2(128, 128)
	_well.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_well.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_well.texture_filter = TEXTURE_FILTER_NEAREST
	_well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	well_box.add_child(_well)

	var meta := VBoxContainer.new()
	meta.add_theme_constant_override("separation", 6)
	meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(meta)

	_name = Label.new()
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI.apply_name(_name, PARCHMENT, UI.SIZE_NAME)
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meta.add_child(_name)

	_pill = Label.new()
	_pill.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_sk != null:
		_pill.add_theme_font_override("font", _font_sk)
	_pill.add_theme_font_size_override("font_size", 15)
	_pill.add_theme_color_override("font_color", SOOT)
	_pill.add_theme_constant_override("outline_size", 0)
	_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meta.add_child(_pill)

	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 18)
	stats.mouse_filter = Control.MOUSE_FILTER_IGNORE
	meta.add_child(stats)
	_atk = _stat_num(ATK_GOLD)
	_atk_tag = _stat_tag("ATK")
	_hp = _stat_num(HP_RED)
	_hp_tag = _stat_tag("HP")
	stats.add_child(_atk)
	stats.add_child(_atk_tag)
	stats.add_child(_hp)
	stats.add_child(_hp_tag)

	_call_slot = VBoxContainer.new()
	_call_slot.alignment = BoxContainer.ALIGNMENT_CENTER
	_call_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_call_slot)
	_ability = Label.new()
	_ability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ability.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.apply_body(_ability, PARCHMENT, UI.SIZE_BODY)
	_ability.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_ability)


func _stat_num(col: Color) -> Label:
	var l := Label.new()
	UI.apply_number(l, col, UI.SIZE_NUMBER)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _stat_tag(text: String) -> Label:
	var l := Label.new()
	l.text = text
	UI.apply_tag(l, UI.DIM, UI.SIZE_TAG)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return l


func show_monster(m: Dictionary, tex: Texture2D = null) -> void:
	visible = true
	var t: int = int(m.get("pack_tier", m.get("tier", 1)))
	var metal: Color = WEAK
	if t >= 3:
		metal = DEADLY
	elif t == 2:
		metal = TOUGH
	add_theme_stylebox_override("panel", UX.plate_inset(t))

	var pill_sb := StyleBoxFlat.new()
	pill_sb.bg_color = metal
	pill_sb.border_color = SOOT
	pill_sb.set_border_width_all(3)
	pill_sb.content_margin_left = 12
	pill_sb.content_margin_right = 12
	pill_sb.content_margin_top = 4
	pill_sb.content_margin_bottom = 4
	_pill.add_theme_stylebox_override("normal", pill_sb)
	_pill.text = COPY.tier_name(t)

	_name.text = str(m.get("name", ""))
	_atk.text = str(int(m.get("atk", 0)))
	_hp.text = str(int(m.get("hp", 0)))
	if _call_slot != null:
		for c in _call_slot.get_children():
			_call_slot.remove_child(c)
			c.queue_free()
		var call_n: String = str(m.get("call_name", m.get("call", ""))).strip_edges()
		if call_n != "":
			_call_slot.add_child(UX.call_capsule(call_n, str(m.get("call_hex", ""))))
	var body: String = str(m.get("ability", "")).strip_edges()
	if body == "":
		body = str(m.get("explainer", "")).strip_edges()
	if body == "":
		body = str(m.get("special_text", "")).strip_edges()
	_ability.text = body
	_ability.visible = body != ""
	_well.texture = tex
	_well.modulate = Color.WHITE


func set_hp(n: int) -> void:
	if _hp:
		_hp.text = str(n)


func set_desaturated(on: bool) -> void:
	if _well:
		_well.modulate = Color(0.45, 0.42, 0.40) if on else Color.WHITE
