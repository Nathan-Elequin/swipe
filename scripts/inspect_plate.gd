extends PanelContainer
## Column inspect plate. Same API as hover_panel for the inspect slot only.

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")
const UI := preload("res://scripts/ui_palette.gd")

signal edit_pressed(kind: String, card_id: String)

const VOID := Color("0B0706")
const INSET := Color("4A2F1F")
const EDGE := Color("7A4E2B")
const PARCHMENT := Color("E9D3A1")
const DIM := Color("A88C66")
const SOOT := Color("1A120E")
const ATK := Color("E86A62")
const BLK := Color("4FA3D9")
const HEAL := Color("7BC950")
const KO := Color("C080E0")
const WEAK := Color("B8733A")
const TOUGH := Color("C9CED6")
const DEADLY := Color("FFD84A")

var accept_clicks: bool = true
var edit_kind: String = ""
var edit_id: String = ""
var _owner
var _title: Label
var _well: TextureRect
var _name: Label
var _pill: Label
var _value: Label
var _tag: Label
var _ability: Label
var _shift: Label
var _item_box: VBoxContainer
var _font_sk: Font


func _ready() -> void:
	_font_sk = UI.font_silk()
	theme = load("res://themes/swipe_theme.tres")
	custom_minimum_size = Vector2(480, 0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_filter = TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	gui_input.connect(_on_gui)
	_build()
	hide_plate()


func _build() -> void:
	add_theme_stylebox_override("panel", UX.plate_inset(0))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	_title = Label.new()
	_title.text = COPY.need("inspect.title")
	if _font_sk != null:
		_title.add_theme_font_override("font", _font_sk)
	_title.add_theme_font_size_override("font_size", 14)
	_title.add_theme_color_override("font_color", DIM)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_title)
	_item_box = VBoxContainer.new()
	_item_box.add_theme_constant_override("separation", 10)
	_item_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_item_box)
	var well_box := PanelContainer.new()
	well_box.custom_minimum_size = Vector2(150, 150)
	well_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var well_sb := StyleBoxFlat.new()
	well_sb.bg_color = VOID
	well_sb.border_color = EDGE
	well_sb.set_border_width_all(4)
	well_box.add_theme_stylebox_override("panel", well_sb)
	_item_box.add_child(well_box)
	_well = TextureRect.new()
	_well.custom_minimum_size = Vector2(140, 140)
	_well.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_well.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_well.texture_filter = TEXTURE_FILTER_NEAREST
	_well.mouse_filter = Control.MOUSE_FILTER_IGNORE
	well_box.add_child(_well)
	_name = Label.new()
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UI.apply_name(_name, PARCHMENT, UI.SIZE_NAME)
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_box.add_child(_name)
	_pill = Label.new()
	_pill.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_sk != null:
		_pill.add_theme_font_override("font", _font_sk)
	_pill.add_theme_font_size_override("font_size", 15)
	_pill.add_theme_color_override("font_color", SOOT)
	_pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_box.add_child(_pill)
	var val_row := HBoxContainer.new()
	val_row.alignment = BoxContainer.ALIGNMENT_CENTER
	val_row.add_theme_constant_override("separation", 10)
	val_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_box.add_child(val_row)
	_value = Label.new()
	UI.apply_number(_value, PARCHMENT, UI.SIZE_NUMBER)
	_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	val_row.add_child(_value)
	_tag = Label.new()
	UI.apply_tag(_tag, UI.DIM, UI.SIZE_TAG)
	_tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	val_row.add_child(_tag)
	_ability = Label.new()
	_ability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ability.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.apply_body(_ability, PARCHMENT, UI.SIZE_BODY)
	_ability.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_box.add_child(_ability)
	_shift = Label.new()
	_shift.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_shift.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UI.apply_body(_shift, DIM, UI.SIZE_BODY)
	_shift.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_item_box.add_child(_shift)
	var plate_scn: PackedScene = load("res://scenes/ui/owner_plate.tscn")
	if plate_scn != null:
		_owner = plate_scn.instantiate()
		_owner.visible = false
		col.add_child(_owner)


func show_placeholder() -> void:
	show_text(COPY.need("inspect.title"), COPY.need("inspect.idle"))


func show_text(title: String, body: String, extra: String = "") -> void:
	show_rule(title, "", extra, body)


func show_rule(
	title: String,
	_value_line: String,
	equation: String,
	body: String,
	_warn: String = "",
	portrait: Texture2D = null,
	p_kind: String = "",
	p_id: String = "",
	look: Dictionary = {}
) -> void:
	edit_kind = p_kind
	edit_id = p_id
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP if accept_clicks and p_id != "" else Control.MOUSE_FILTER_IGNORE
	var t: int = int(look.get("tier", look.get("pack_tier", 1)))
	_set_border(t)
	if p_kind == "monster" and _owner != null:
		_item_box.visible = false
		_title.visible = true
		_title.text = COPY.need("inspect.title")
		_owner.visible = true
		var m := {
			"name": title,
			"ability": body,
			"atk": int(look.get("atk", 0)),
			"hp": int(look.get("hp", 0)),
			"pack_tier": t,
			"card_id": p_id,
		}
		if look.has("atk"):
			m["atk"] = int(look["atk"])
		if look.has("hp"):
			m["hp"] = int(look["hp"])
		_owner.show_monster(m, portrait)
		return
	if _owner:
		_owner.visible = false
	_item_box.visible = true
	_title.visible = true
	_title.text = COPY.need("inspect.title")
	_name.text = title
	_well.texture = portrait
	_pill.text = COPY.tier_name(t)
	_style_pill(_metal(t))
	_set_stat(look)
	_ability.text = _strip_bb(body)
	_shift.text = equation if equation != "" else ""
	_shift.visible = equation != ""


func hide_plate() -> void:
	visible = false
	edit_kind = ""
	edit_id = ""
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _set_stat(look: Dictionary) -> void:
	var kind: String = str(look.get("stat_kind", ""))
	var shown: String = str(look.get("stat_shown", ""))
	var n: int = int(look.get("stat_n", 0))
	var col := PARCHMENT
	var tag := ""
	if kind == "ATK":
		col = ATK
		tag = COPY.need("hand.tag.atk")
		if shown == "":
			shown = str(n)
	elif kind == "BLK":
		col = BLK
		tag = COPY.need("hand.tag.blk")
		if shown == "":
			shown = str(n)
	elif kind == "HEAL":
		col = HEAL
		tag = COPY.need("hand.tag.heal")
		if shown == "":
			shown = str(n)
	elif kind == "BOTH":
		col = ATK
		shown = "%s / %s" % [int(look.get("stat_atk", 0)), int(look.get("stat_blk", 0))]
		tag = "%s/%s" % [COPY.need("hand.tag.atk"), COPY.need("hand.tag.blk")]
	elif kind == "DEFEAT" or kind == "FANGS" or kind == "KO":
		col = KO
		shown = COPY.need("hand.tag.ko")
		tag = ""
	elif shown == "" or shown == "—":
		shown = "?"
	_value.text = shown
	_value.add_theme_color_override("font_color", col)
	_tag.text = tag
	_tag.visible = tag != ""


func _metal(t: int) -> Color:
	if t >= 3:
		return DEADLY
	if t == 2:
		return TOUGH
	return WEAK


func _set_border(t: int) -> void:
	add_theme_stylebox_override("panel", UX.plate_inset(t))


func _style_pill(metal: Color) -> void:
	var pill_sb := StyleBoxFlat.new()
	pill_sb.bg_color = metal
	pill_sb.border_color = SOOT
	pill_sb.set_border_width_all(3)
	pill_sb.content_margin_left = 12
	pill_sb.content_margin_right = 12
	pill_sb.content_margin_top = 4
	pill_sb.content_margin_bottom = 4
	_pill.add_theme_stylebox_override("normal", pill_sb)
	_pill.visible = _pill.text != ""


func _strip_bb(s: String) -> String:
	var out := s
	var re := RegEx.new()
	re.compile("\\[.*?\\]")
	return re.sub(out, "", true).strip_edges()


func _on_gui(event: InputEvent) -> void:
	if not accept_clicks or edit_id == "":
		return
	if not OS.has_feature("editor"):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		edit_pressed.emit(edit_kind, edit_id)
		accept_event()
