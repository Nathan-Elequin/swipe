extends Control
class_name CommitmentTierGlyph
## Tiny placeholder pictograph for commitment tiers (door / crystal / abyss eye).

var tier: int = 1


func _draw() -> void:
	var c := Color("e8c36a")
	var r := size
	var cx := r.x * 0.5
	var cy := r.y * 0.5
	match tier:
		1:
			draw_rect(Rect2(cx - 10, cy - 14, 20, 28), c, false, 2.0)
			draw_circle(Vector2(cx + 5, cy + 2), 2.0, c)
		2:
			var pts := PackedVector2Array([
				Vector2(cx, cy - 14),
				Vector2(cx + 10, cy),
				Vector2(cx, cy + 14),
				Vector2(cx - 10, cy),
			])
			draw_polyline(pts + PackedVector2Array([pts[0]]), c, 2.0, true)
		_:
			draw_arc(Vector2(cx, cy), 12.0, 0.0, TAU, 24, c, 2.0, true)
			draw_circle(Vector2(cx, cy), 4.0, c)
