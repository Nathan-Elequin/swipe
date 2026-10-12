extends Control
## Direction A title: ghost wheel, logo, Play, secondary row.

signal how_pressed
signal dive_pressed
signal begin_pressed
signal adventure_pressed
signal dev_pressed
signal roster_pressed
signal script_pressed
signal log_pressed

const COPY := preload("res://scripts/player_copy.gd")
const GOLD := Color("FFD84A")
const TORCH := Color("F09A34")
const SOOT := Color("1A120E")
const PARCHMENT := Color("E9D3A1")
const EDGE := Color("7A4E2B")
const DIM := Color("A88C66")

var btn_play: Button
var btn_log: Button
var _log_on: bool = false
var _font_px: Font
var _font_vt: Font
var _art


func setup(p_art = null) -> void:
	_art = p_art
	_font_px = load("res://assets/ui/fonts/PixelifySans-Bold.ttf")
	_font_vt = load("res://assets/ui/fonts/VT323-Regular.ttf")
	theme = load("res://themes/swipe_theme.tres")
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = TEXTURE_FILTER_NEAREST
	z_index = 80
	_build()


func _build() -> void:
	var glow := ColorRect.new()
	glow.set_anchors_preset(PRESET_FULL_RECT)
	glow.color = Color(0.10, 0.07, 0.05, 0.0)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)
	var wheel := Control.new()
	wheel.position = Vector2(540, 50)
	wheel.size = Vector2(600, 600)
	wheel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wheel.modulate = Color(1, 1, 1, 0.35)
	wheel.draw.connect(func() -> void:
		var c := Vector2(300, 300)
		wheel.draw_circle(c, 300, Color("3B2618"))
		wheel.draw_arc(c, 300, 0, TAU, 64, Color("7A4E2B"), 8.0, true)
		for i in 8:
			var ang: float = deg_to_rad(-90.0 + 45.0 * float(i))
			wheel.draw_line(c + Vector2.from_angle(ang) * 88.0, c + Vector2.from_angle(ang) * 300.0, Color("7A4E2B"), 4.0, true)
		wheel.draw_circle(c, 88, Color("140D0A"))
		wheel.draw_arc(c, 88, 0, TAU, 32, Color("7A4E2B"), 6.0, true)
	)
	add_child(wheel)
	var bait := TextureRect.new()
	bait.position = Vector2(800, 96)
	bait.size = Vector2(80, 80)
	bait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bait.texture_filter = TEXTURE_FILTER_NEAREST
	bait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _art != null and _art.has_method("item_tex"):
		bait.texture = _art.item_tex("healing_potion")
	add_child(bait)

	var col := VBoxContainer.new()
	col.position = Vector2(480, 220)
	col.size = Vector2(720, 620)
	col.add_theme_constant_override("separation", 26)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(col)

	var logo := Label.new()
	logo.text = COPY.need("title.overlay")
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_px != null:
		logo.add_theme_font_override("font", _font_px)
	logo.add_theme_font_size_override("font_size", 170)
	logo.add_theme_color_override("font_color", GOLD)
	logo.add_theme_color_override("font_shadow_color", TORCH)
	logo.add_theme_constant_override("shadow_offset_x", 0)
	logo.add_theme_constant_override("shadow_offset_y", 8)
	logo.add_theme_color_override("font_outline_color", Color("3A2414"))
	logo.add_theme_constant_override("outline_size", 14)
	col.add_child(logo)

	var sub := Label.new()
	sub.text = COPY.need("title.sub")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font_vt != null:
		sub.add_theme_font_override("font", _font_vt)
	sub.add_theme_font_size_override("font_size", 38)
	sub.add_theme_color_override("font_color", PARCHMENT)
	col.add_child(sub)

	btn_play = _gold(COPY.need("title.begin"), begin_pressed, Vector2(380, 96), 56)
	col.add_child(btn_play)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(row)
	row.add_child(_oak(COPY.need("title.how_to_play"), how_pressed, Vector2(240, 58), 30))
	row.add_child(_oak(COPY.need("title.dive_in"), dive_pressed, Vector2(240, 58), 30))
	row.add_child(_oak(COPY.need("title.adventure"), adventure_pressed, Vector2(240, 58), 30))

	if OS.has_feature("editor"):
		var tools := HBoxContainer.new()
		tools.alignment = BoxContainer.ALIGNMENT_CENTER
		tools.add_theme_constant_override("separation", 12)
		col.add_child(tools)
		tools.add_child(_oak("Developer Test", dev_pressed, Vector2(200, 44), 20))
		tools.add_child(_oak("Roster", roster_pressed, Vector2(120, 44), 20))
		tools.add_child(_oak("Script", script_pressed, Vector2(110, 44), 20))
		btn_log = _oak("Event log: off", log_pressed, Vector2(200, 44), 20)
		tools.add_child(btn_log)

	var nib := TextureRect.new()
	nib.position = Vector2(1380, 820)
	nib.size = Vector2(128, 128)
	nib.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nib.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	nib.texture_filter = TEXTURE_FILTER_NEAREST
	nib.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _art != null and _art.has_method("nib_portrait"):
		nib.texture = _art.nib_portrait()
	add_child(nib)


func grab_play() -> void:
	if btn_play:
		btn_play.grab_focus()


func set_log_on(on: bool) -> void:
	_log_on = on
	if btn_log:
		btn_log.text = "Event log: on" if on else "Event log: off"


func _gold(text: String, sig: Signal, mins: Vector2, fs: int) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = mins
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_px != null:
		b.add_theme_font_override("font", _font_px)
	b.add_theme_font_size_override("font_size", fs)
	b.add_theme_color_override("font_color", SOOT)
	var n := StyleBoxFlat.new()
	n.bg_color = GOLD
	n.border_color = TORCH
	n.set_border_width_all(6)
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate() as StyleBoxFlat
	h.bg_color = Color("FFE27A")
	b.add_theme_stylebox_override("hover", h)
	b.pressed.connect(func() -> void: sig.emit())
	return b


func _oak(text: String, sig: Signal, mins: Vector2, fs: int) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = mins
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_px != null:
		b.add_theme_font_override("font", _font_px)
	b.add_theme_font_size_override("font_size", fs)
	b.add_theme_color_override("font_color", PARCHMENT)
	var n := StyleBoxFlat.new()
	n.bg_color = Color(0, 0, 0, 0)
	n.border_color = EDGE
	n.set_border_width_all(4)
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate() as StyleBoxFlat
	h.border_color = GOLD
	b.add_theme_stylebox_override("hover", h)
	b.pressed.connect(func() -> void: sig.emit())
	return b
