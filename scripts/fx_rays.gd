extends Object
## Traveling ripples along a line from origin to destination.


static func draw(c: CanvasItem, a: Vector2, b: Vector2, col: Color, t: float, hot: bool = false) -> void:
	var span: Vector2 = b - a
	var dist: float = span.length()
	if dist < 4.0:
		return
	var dir: Vector2 = span / dist
	var tan := Vector2(-dir.y, dir.x)
	var base := Color(col.r, col.g, col.b, col.a * (0.55 if hot else 0.32))
	var glow := Color(col.r, col.g, col.b, col.a * (0.22 if hot else 0.10))
	var w: float = 2.8 if hot else 1.6
	c.draw_line(a, b, glow, w + 5.0, true)
	c.draw_line(a, b, base, w, true)
	var waves: int = 3 if hot else 2
	for i in waves:
		var u: float = fposmod(t * 0.55 + float(i) / float(waves), 1.0)
		var p: Vector2 = a.lerp(b, u)
		var fade: float = sin(u * PI)
		var r: float = lerpf(5.0, 13.0 if hot else 9.0, fade)
		var ring := Color(col.r, col.g, col.b, col.a * fade * (0.95 if hot else 0.70))
		c.draw_arc(p, r, 0.0, TAU, 20, ring, 2.0 if hot else 1.5, true)
		c.draw_line(p - tan * r * 0.85, p + tan * r * 0.85, Color(ring.r, ring.g, ring.b, ring.a * 0.65), 1.4, true)
	c.draw_circle(a, 3.2 if hot else 2.2, Color(col.r, col.g, col.b, col.a * 0.8))
