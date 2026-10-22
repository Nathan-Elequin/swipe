extends Control
## Gold arc on Shuriken. Up and to the right, matching a counter-clockwise step from the bottom of the wheel.

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 2
	resized.connect(queue_redraw)
	call_deferred("queue_redraw")


func _draw() -> void:
	var box := size
	if box.x < 8.0 or box.y < 8.0:
		box = Vector2(48, 48)
	var center := box * 0.5
	var radius := minf(box.x, box.y) * 0.42
	var pts := PackedVector2Array()
	var a_from := PI * 0.85
	var a_to := -PI * 0.35
	for i in 9:
		var a := lerpf(a_from, a_to, float(i) / 8.0)
		pts.append(center + Vector2.from_angle(a) * radius)
	draw_polyline(pts, Color("100e0c"), 4.0, false)
	draw_polyline(pts, Color("FFD84A"), 2.0, false)
	var tip := pts[pts.size() - 1]
	var prev := pts[pts.size() - 2]
	var dir := (tip - prev).normalized()
	var side := Vector2(-dir.y, dir.x)
	draw_colored_polygon(PackedVector2Array([tip + dir * 7.0, tip - dir * 3.0 + side * 5.0, tip - dir * 3.0 - side * 5.0]), Color("100e0c"))
	draw_colored_polygon(PackedVector2Array([tip + dir * 5.0, tip - dir * 1.5 + side * 3.2, tip - dir * 1.5 - side * 3.2]), Color("FFD84A"))
