extends VBoxContainer
## Column plate for placement: door, monster, hint.

const COPY := preload("res://scripts/player_copy.gd")

const VOID := Color("0B0706")
const EDGE := Color("7A4E2B")
const TORCH := Color("F09A34")
const DIM := Color("A88C66")

var door: Control
var owner_plate
var hint: Label
var _font_vt: Font


func _ready() -> void:
	_font_vt = load("res://assets/ui/fonts/VT323-Regular.ttf")
	add_theme_constant_override("separation", 24)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_build()


func _build() -> void:
	door = Control.new()
	door.custom_minimum_size = Vector2(300, 200)
	door.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	door.mouse_filter = Control.MOUSE_FILTER_IGNORE
	door.draw.connect(_draw_door)
	add_child(door)

	var plate_scn: PackedScene = load("res://scenes/ui/owner_plate.tscn")
	if plate_scn != null:
		owner_plate = plate_scn.instantiate()
	else:
		owner_plate = load("res://scripts/owner_plate.gd").new()
	add_child(owner_plate)

	hint = Label.new()
	hint.text = COPY.need("door.seat_hint")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font_vt != null:
		hint.add_theme_font_override("font", _font_vt)
	hint.add_theme_font_size_override("font_size", 28)
	hint.add_theme_color_override("font_color", DIM)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)


func show_pending(m: Dictionary, tex: Texture2D) -> void:
	visible = true
	if owner_plate != null and owner_plate.has_method("show_monster"):
		owner_plate.show_monster(m, tex)
	if hint:
		hint.text = COPY.need("door.seat_hint")
	if door:
		door.queue_redraw()


func door_mouth_global() -> Vector2:
	if door == null:
		return Vector2(1236, 190)
	return door.global_position + Vector2(door.size.x * 0.5, door.size.y - 8.0)


func _draw_door() -> void:
	if door == null:
		return
	var r := Rect2(Vector2.ZERO, door.size)
	var c: Vector2 = Vector2(r.size.x * 0.5, r.size.y)
	var rad: float = r.size.x * 0.5
	var pts := PackedVector2Array()
	pts.append(Vector2(0, r.size.y))
	for k in 16:
		var a: float = PI + float(k) / 16.0 * PI
		pts.append(Vector2(c.x + cos(a) * rad, c.y + sin(a) * rad))
	pts.append(Vector2(r.size.x, r.size.y))
	door.draw_colored_polygon(pts, VOID)
	for k in 16:
		var a0: float = PI + float(k) / 16.0 * PI
		var a1: float = PI + float(k + 1) / 16.0 * PI
		var p0: Vector2 = Vector2(c.x + cos(a0) * rad, c.y + sin(a0) * rad)
		var p1: Vector2 = Vector2(c.x + cos(a1) * rad, c.y + sin(a1) * rad)
		door.draw_line(p0, p1, EDGE, 8.0, false)
	var glow := Color(TORCH.r, TORCH.g, TORCH.b, 0.28)
	door.draw_circle(Vector2(c.x, r.size.y - 10.0), 36.0, glow)
