extends Button
## Curved gold arrow flanking Take: arcs up and out. No player-facing words.

var pointing: int = 1


func _ready() -> void:
	text = ""
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(80, 68)
	var empty := StyleBoxEmpty.new()
	add_theme_stylebox_override("normal", empty)
	add_theme_stylebox_override("hover", empty)
	add_theme_stylebox_override("pressed", empty)
	add_theme_stylebox_override("focus", empty)
	add_theme_stylebox_override("disabled", empty)


func _draw() -> void:
	var c: Vector2 = size * 0.5
	var live: bool = not disabled
	var gold := Color("FFD84A") if live else Color("6a5f52")
	var ink := Color("100e0c", 1.0 if live else 0.55)
	if live and is_hovered():
		gold = Color("fff3d6")
	var s: float = 1.12 if live and is_hovered() else 1.0
	var p0: Vector2 = c + Vector2(-float(pointing) * 6.0 * s, 24.0 * s)
	var p1: Vector2 = c + Vector2(-float(pointing) * 30.0 * s, -2.0 * s)
	var p2: Vector2 = c + Vector2(float(pointing) * 22.0 * s, -22.0 * s)
	var pts := PackedVector2Array()
	for i in 12:
		var t: float = float(i) / 11.0
		var a: Vector2 = p0.lerp(p1, t)
		var b: Vector2 = p1.lerp(p2, t)
		pts.append(a.lerp(b, t))
	draw_polyline(pts, ink, 9.0, false)
	draw_polyline(pts, gold, 5.0, false)
	var tip: Vector2 = pts[pts.size() - 1]
	var prev: Vector2 = pts[pts.size() - 2]
	var dir: Vector2 = (tip - prev).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var head := PackedVector2Array([
		tip + dir * 5.0,
		tip - dir * 12.0 + perp * 10.0,
		tip - dir * 12.0 - perp * 10.0,
	])
	draw_colored_polygon(head, ink)
	var inner := PackedVector2Array([
		tip + dir * 1.0,
		tip - dir * 8.0 + perp * 6.0,
		tip - dir * 8.0 - perp * 6.0,
	])
	draw_colored_polygon(inner, gold)
