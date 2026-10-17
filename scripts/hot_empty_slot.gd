extends Control
## Empty challenge-hand seat. Dotted card outline so the 5x2 grid still reads.

const CARD_W := 118.0
const CARD_H := 162.0


func _ready() -> void:
	custom_minimum_size = Vector2(CARD_W, CARD_H)
	size_flags_horizontal = Control.SIZE_FILL
	size_flags_vertical = Control.SIZE_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	var r := Rect2(Vector2(5, 5), size - Vector2(10, 10))
	draw_rect(r, Color("c4a574", 0.07), true)
	var ink := Color("e8c36a", 0.88)
	var step := 8.0
	var rad := 1.7
	_dot_edge(r.position, r.position + Vector2(r.size.x, 0.0), ink, step, rad)
	_dot_edge(r.position + Vector2(r.size.x, 0.0), r.position + r.size, ink, step, rad)
	_dot_edge(r.position + r.size, r.position + Vector2(0.0, r.size.y), ink, step, rad)
	_dot_edge(r.position + Vector2(0.0, r.size.y), r.position, ink, step, rad)


func _dot_edge(from: Vector2, to: Vector2, ink: Color, step: float, rad: float) -> void:
	var span: Vector2 = to - from
	var dist: float = span.length()
	if dist < 1.0:
		return
	var n: int = maxi(2, int(round(dist / step)))
	for i in n + 1:
		var t: float = float(i) / float(n)
		draw_circle(from.lerp(to, t), rad, ink)
