extends VBoxContainer
## Column fight plate: monster + resolve button.

const COPY := preload("res://scripts/player_copy.gd")

var owner_plate
var btn_resolve: Button
var _font_px: Font


func _ready() -> void:
	_font_px = load("res://assets/ui/fonts/PixelifySans-Bold.ttf")
	add_theme_constant_override("separation", 30)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var plate_scn: PackedScene = load("res://scenes/ui/owner_plate.tscn")
	if plate_scn != null:
		owner_plate = plate_scn.instantiate()
	add_child(owner_plate)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(spacer)
	btn_resolve = Button.new()
	btn_resolve.custom_minimum_size = Vector2(0, 80)
	btn_resolve.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_resolve.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_px != null:
		btn_resolve.add_theme_font_override("font", _font_px)
	btn_resolve.add_theme_font_size_override("font_size", 40)
	add_child(btn_resolve)
	_style_danger()


func show_owner(m: Dictionary, tex: Texture2D) -> void:
	visible = true
	if owner_plate != null and owner_plate.has_method("show_monster"):
		owner_plate.show_monster(m, tex)


func set_resolve(text: String, danger: bool, disabled: bool) -> void:
	if btn_resolve == null:
		return
	btn_resolve.text = text
	btn_resolve.disabled = disabled
	if danger:
		_style_danger()
	else:
		btn_resolve.theme_type_variation = "ButtonGold"
		btn_resolve.add_theme_color_override("font_color", Color("1A120E"))


func _style_danger() -> void:
	if btn_resolve == null:
		return
	btn_resolve.theme_type_variation = "ButtonDanger"
	btn_resolve.add_theme_color_override("font_color", Color("D5443B"))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = Color("D5443B")
	sb.set_border_width_all(5)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	btn_resolve.add_theme_stylebox_override("normal", sb)
	var hov := sb.duplicate() as StyleBoxFlat
	hov.border_color = Color("FFD84A")
	btn_resolve.add_theme_stylebox_override("hover", hov)
