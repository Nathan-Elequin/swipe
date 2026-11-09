extends Node2D
## Straight Shot telegraph. While a Huntsman is adding his Attack to the
## current Take number, a gold beam runs from his seat, through the wheel
## hub, to the Take damage burst. The slash loop plays on his wheel seat.
## The bright head loops. Each arrival emits pulse_hit.

signal pulse_hit

const TRAVEL_S := 1.15
const GOLD := Color("FFD84A")
const CORE := Color("fff8e8")
const AMBER := Color("c45a12")

var _on: bool = false
var _polys: Array = []
var _burst: Vector2 = Vector2.ZERO
var _u: float = 0.0


func _ready() -> void:
	top_level = true
	z_as_relative = false
	z_index = 24
	visible = false


func is_showing() -> bool:
	return _on


## froms: seat points. hub: wheel center. burst: Take damage icon.
## Returns true the frame the link turns on.
func set_links(froms: Array, hub: Vector2, burst: Vector2) -> bool:
	var was := _on
	_burst = burst
	_polys.clear()
	for origin_v in froms:
		var origin: Vector2 = origin_v
		var poly := PackedVector2Array()
		poly.append(origin)
		poly.append(hub)
		poly.append(burst)
		_polys.append(poly)
	_on = not _polys.is_empty()
	visible = _on
	if _on and not was:
		_u = 0.0
	queue_redraw()
	return _on and not was


func clear_link() -> void:
	if not _on and _polys.is_empty():
		visible = false
		return
	_on = false
	_polys.clear()
	visible = false
	queue_redraw()


func _process(delta: float) -> void:
	if not _on:
		return
	var prev := _u
	_u = fposmod(_u + delta / TRAVEL_S, 1.0)
	if _u < prev:
		pulse_hit.emit()
	queue_redraw()


func _draw() -> void:
	if not _on:
		return
	var glow_a: float = 0.35 + 0.15 * sin(_u * TAU)
	for poly_v in _polys:
		var poly: PackedVector2Array = poly_v
		if poly.size() < 2:
			continue
		draw_polyline(poly, Color(AMBER, glow_a + 0.25), 22.0, false)
		draw_polyline(poly, Color(GOLD, 0.95), 8.0, false)
		draw_polyline(poly, Color(CORE, 1.0), 2.0, false)
		var head: PackedVector2Array = _slice(poly, maxf(_u - 0.16, 0.0), _u)
		if head.size() >= 2:
			draw_polyline(head, Color(CORE, 1.0), 10.0, false)
			draw_polyline(head, GOLD, 4.0, false)
		var tip: Vector2 = _at(poly, _u)
		var prev_p: Vector2 = _at(poly, maxf(_u - 0.04, 0.0))
		var dir: Vector2 = tip - prev_p
		if dir.length() > 0.5:
			var tan := Vector2(-dir.y, dir.x).normalized()
			draw_line(tip - tan * 14.0, tip + tan * 14.0, Color(CORE, 0.85), 2.0, false)
		var origin: Vector2 = poly[0]
		draw_arc(origin, 10.0 + 8.0 * _u, 0.0, TAU, 16, Color(GOLD, 0.55 * (1.0 - _u)), 2.0, false)
	var ring: float = 8.0 + 18.0 * _u
	draw_arc(_burst, ring, 0.0, TAU, 20, Color(GOLD, 0.45 * (1.0 - _u)), 2.0, false)


func _slice(poly: PackedVector2Array, u0: float, u1: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	out.append(_at(poly, u0))
	var metrics: Dictionary = _metrics(poly)
	var lens: PackedFloat32Array = metrics["lens"]
	var total: float = float(metrics["total"])
	var d0: float = u0 * total
	var d1: float = u1 * total
	for i in range(1, poly.size() - 1):
		var d: float = float(lens[i])
		if d > d0 and d < d1:
			out.append(poly[i])
	out.append(_at(poly, u1))
	return out


func _at(poly: PackedVector2Array, u: float) -> Vector2:
	var metrics: Dictionary = _metrics(poly)
	var lens: PackedFloat32Array = metrics["lens"]
	var total: float = float(metrics["total"])
	var dist: float = clampf(u, 0.0, 1.0) * total
	for i in range(1, poly.size()):
		var a: float = float(lens[i - 1])
		var b: float = float(lens[i])
		if dist <= b or i == poly.size() - 1:
			var span: float = maxf(b - a, 0.001)
			return poly[i - 1].lerp(poly[i], clampf((dist - a) / span, 0.0, 1.0))
	return poly[poly.size() - 1]


func _metrics(poly: PackedVector2Array) -> Dictionary:
	var lens := PackedFloat32Array()
	var total := 0.0
	lens.append(0.0)
	for i in range(1, poly.size()):
		total += poly[i - 1].distance_to(poly[i])
		lens.append(total)
	return {"lens": lens, "total": maxf(total, 1.0)}
