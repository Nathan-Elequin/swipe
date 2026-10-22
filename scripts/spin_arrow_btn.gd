extends BaseButton
## Curved walk arrow that sits beside Take. Left curves up-left; right curves up-right.

var arc_left: bool = true


func _ready() -> void:
	custom_minimum_size = Vector2(124, 116)
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	size_flags_vertical = Control.SIZE_SHRINK_END
	toggle_mode = false
	action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)
	resized.connect(queue_redraw)
	visibility_changed.connect(queue_redraw)


func _draw() -> void:
	if size.x < 8.0 or size.y < 8.0:
		return
	var pts := _arc_points()
	if pts.size() < 3:
		return
	var ink := Color("100e0c")
	var gold := Color("e8c36a")
	var hot := Color("f4d78a")
	var dim := Color(0.55, 0.48, 0.36, 0.42)
	var col := gold
	var thick := 11.0
	if disabled:
		col = dim
		ink.a = 0.45
		thick = 9.0
	elif is_pressed():
		col = gold.darkened(0.12)
		thick = 11.5
	elif is_hovered():
		col = hot
		thick = 13.0
	var shift := Vector2(0, 2) if is_pressed() and not disabled else Vector2.ZERO
	if shift != Vector2.ZERO:
		var moved := PackedVector2Array()
		for p in pts:
			moved.append(p + shift)
		pts = moved
	draw_polyline(pts, ink, thick + 7.0, true)
	draw_polyline(pts, col, thick, true)
	_draw_head(pts, col, ink, thick)


func _arc_points() -> PackedVector2Array:
	var w: float = size.x
	var h: float = size.y
	var p0: Vector2
	var p1: Vector2
	var p2: Vector2
	var p3: Vector2
	if arc_left:
		p0 = Vector2(w * 0.92, h * 0.78)
		p1 = Vector2(w * 0.42, h * 0.92)
		p2 = Vector2(w * 0.08, h * 0.48)
		p3 = Vector2(w * 0.18, h * 0.07)
	else:
		p0 = Vector2(w * 0.08, h * 0.78)
		p1 = Vector2(w * 0.58, h * 0.92)
		p2 = Vector2(w * 0.92, h * 0.48)
		p3 = Vector2(w * 0.82, h * 0.07)
	var pts := PackedVector2Array()
	var n := 22
	for i in n:
		var t: float = float(i) / float(n - 1)
		pts.append(_cubic(p0, p1, p2, p3, t))
	return pts


func _cubic(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return (u * u * u * p0) + (3.0 * u * u * t * p1) + (3.0 * u * t * t * p2) + (t * t * t * p3)


func _draw_head(pts: PackedVector2Array, col: Color, ink: Color, thick: float) -> void:
	var tip: Vector2 = pts[pts.size() - 1]
	var prev: Vector2 = pts[maxi(0, pts.size() - 4)]
	var dir: Vector2 = tip - prev
	if dir.length_squared() < 0.0001:
		dir = Vector2(-0.55, -0.84) if arc_left else Vector2(0.55, -0.84)
	dir = dir.normalized()
	var perp := Vector2(-dir.y, dir.x)
	var head: float = 22.0 + thick * 0.45
	var p1: Vector2 = tip + dir * 6.0
	var p2: Vector2 = tip - dir * (head * 0.28) + perp * (head * 0.58)
	var p3: Vector2 = tip - dir * (head * 0.28) - perp * (head * 0.58)
	draw_colored_polygon(PackedVector2Array([p1, p2, p3]), ink)
	var inset := 3.5
	var mid: Vector2 = (p2 + p3) * 0.5
	var i1: Vector2 = p1 + (mid - p1).normalized() * inset * 0.2
	var i2: Vector2 = p2 + (p1 - p2).normalized() * inset
	var i3: Vector2 = p3 + (p1 - p3).normalized() * inset
	draw_colored_polygon(PackedVector2Array([i1, i2, i3]), col)
