extends Control
## Short name pills that appear, hold, and dissolve. Tail aims at the source. Ripple runs to the target.

const FX_RAYS := preload("res://scripts/fx_rays.gd")

var _q: Array = []
var _draining: bool = false
var _life: float = 0.0:
	set(v):
		_life = v
		queue_redraw()
var _clock: float = 0.0
var _text: String = ""
var _from: Vector2 = Vector2.ZERO
var _to: Vector2 = Vector2.ZERO
var _has_to: bool = false

const IN := 0.10
const HOLD := 0.30
const OUT := 0.16


func setup() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 98
	top_level = true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = TEXTURE_FILTER_NEAREST
	set_process(true)


func _process(delta: float) -> void:
	if _text == "":
		return
	_clock += delta
	queue_redraw()


func play(text: String, from: Vector2, to: Vector2 = Vector2.INF) -> void:
	var line: String = text.strip_edges()
	if line == "":
		return
	var ticket := {"text": line, "from": from, "to": to, "done": false}
	_q.append(ticket)
	if not _draining:
		await _drain()
	else:
		while is_instance_valid(self) and not bool(ticket.get("done", false)):
			await get_tree().process_frame


func _drain() -> void:
	_draining = true
	while not _q.is_empty():
		var t: Dictionary = _q.pop_front()
		await _show(t)
		t["done"] = true
	_draining = false


func _show(t: Dictionary) -> void:
	_text = str(t.get("text", ""))
	_from = t.get("from", Vector2.ZERO)
	var dest: Vector2 = t.get("to", Vector2.INF)
	_has_to = dest.x < 100000.0
	_to = dest
	_life = 0.0
	_clock = 0.0
	var tw := create_tween()
	tw.tween_property(self, "_life", 1.0, IN).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(HOLD)
	tw.tween_property(self, "_life", 0.0, OUT).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw.finished
	_text = ""
	_has_to = false
	queue_redraw()


func _draw() -> void:
	if _text == "" or _life <= 0.01:
		return
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var fs := 16
	var pad := Vector2(16.0, 8.0)
	var tsz: Vector2 = font.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var cap_sz := Vector2(maxf(tsz.x + pad.x * 2.0, 48.0), maxf(tsz.y + pad.y * 2.0, 28.0))
	var origin: Vector2 = _local(_from)
	var a: float = clampf(_life, 0.0, 1.0)
	var dest_l: Vector2 = _local(_to) if _has_to else origin
	if _has_to and origin.distance_to(dest_l) > 10.0:
		var ray_col := Color("e8c36a")
		ray_col.a = 0.85 * a
		FX_RAYS.draw(self, origin, dest_l, ray_col, _clock, true)
		_draw_pulse(dest_l, a)
	var pos: Vector2 = _place_capsule(origin, cap_sz)
	var scale: float = lerpf(0.82, 1.0, a)
	var fill := Color(0.08, 0.06, 0.05, 0.92 * a)
	var edge := Color("e8c36a")
	edge.a = a
	var ink := Color("f0e6d8")
	ink.a = a
	var mid: Vector2 = pos + cap_sz * 0.5
	var drawn := Rect2(mid - cap_sz * 0.5 * scale, cap_sz * scale)
	var tail: PackedVector2Array = _tail_pts(drawn, drawn.size.y * 0.5, origin)
	if tail.size() == 3:
		var sh := PackedVector2Array()
		for p in tail:
			sh.append(p + Vector2(2, 3))
		draw_colored_polygon(sh, Color(0.08, 0.05, 0.03, 0.28 * a))
		draw_colored_polygon(tail, fill)
	_draw_capsule(drawn, fill, edge)
	if tail.size() == 3:
		draw_line(tail[0], tail[2], edge, 1.8, true)
		draw_line(tail[1], tail[2], edge, 1.8, true)
	var tp: Vector2 = drawn.get_center() + Vector2(-tsz.x * 0.5, fs * 0.36)
	var outline := Color(0.06, 0.05, 0.04, a)
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_string(font, tp + Vector2(ox, oy), _text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, outline)
	draw_string(font, tp, _text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)


func _place_capsule(origin: Vector2, cap_sz: Vector2) -> Vector2:
	var vp: Vector2 = size
	var pos := Vector2(origin.x - cap_sz.x * 0.5, origin.y - cap_sz.y - 22.0)
	if pos.y < 8.0:
		pos.y = origin.y - cap_sz.y * 0.5
		pos.x = origin.x + 26.0
		if pos.x + cap_sz.x > vp.x - 8.0:
			pos.x = origin.x - cap_sz.x - 26.0
	pos.x = clampf(pos.x, 8.0, maxf(8.0, vp.x - cap_sz.x - 8.0))
	pos.y = clampf(pos.y, 8.0, maxf(8.0, vp.y - cap_sz.y - 8.0))
	return pos


func _local(p: Vector2) -> Vector2:
	return get_global_transform().affine_inverse() * p


func _tail_pts(r: Rect2, rad: float, mouth: Vector2) -> PackedVector2Array:
	if r.grow(-10.0).has_point(mouth):
		return PackedVector2Array()
	var c: Vector2 = r.get_center()
	var dir: Vector2 = mouth - c
	if dir.length() < 2.0:
		return PackedVector2Array()
	dir = dir.normalized()
	var attach: Vector2 = _ray_hit_round(c, dir, r, rad)
	var tan: Vector2 = Vector2(-dir.y, dir.x)
	var a: Vector2 = attach + tan * 11.0 - dir * 6.0
	var b: Vector2 = attach - tan * 11.0 - dir * 6.0
	var tip: Vector2 = mouth - dir * 3.0
	return PackedVector2Array([a, b, tip])


func _ray_hit_round(origin: Vector2, dir: Vector2, r: Rect2, rad: float) -> Vector2:
	var lo := 0.0
	var hi: float = r.size.length()
	for _i in 16:
		var mid: float = (lo + hi) * 0.5
		if _inside_round(origin + dir * mid, r, rad):
			lo = mid
		else:
			hi = mid
	return origin + dir * lo


func _inside_round(p: Vector2, r: Rect2, rad: float) -> bool:
	var rr: float = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	var c: Vector2 = r.get_center()
	var h: Vector2 = r.size * 0.5
	var d := Vector2(absf(p.x - c.x), absf(p.y - c.y))
	var q: Vector2 = d - h + Vector2(rr, rr)
	if q.x <= 0.0 and d.y <= h.y:
		return true
	if q.y <= 0.0 and d.x <= h.x:
		return true
	return Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0)).length_squared() <= rr * rr


func _draw_pulse(p: Vector2, life: float) -> void:
	var r: float = lerpf(10.0, 26.0, 1.0 - life)
	var col := Color("e8c36a")
	col.a = 0.18 + 0.55 * life
	draw_arc(p, r, 0.0, TAU, 28, col, 2.4, true)
	draw_circle(p, 4.0, Color(col.r, col.g, col.b, 0.35 * life))


func _draw_capsule(rect: Rect2, fill: Color, edge: Color) -> void:
	var rr: float = rect.size.y * 0.5
	var y: float = rect.position.y + rr
	var x0: float = rect.position.x + rr
	var x1: float = rect.position.x + rect.size.x - rr
	draw_circle(Vector2(x0, y), rr, fill)
	draw_circle(Vector2(x1, y), rr, fill)
	draw_rect(Rect2(x0, rect.position.y, maxf(0.0, x1 - x0), rect.size.y), fill, true)
	draw_arc(Vector2(x0, y), rr, PI * 0.5, PI * 1.5, 12, edge, 1.8, true)
	draw_arc(Vector2(x1, y), rr, -PI * 0.5, PI * 0.5, 12, edge, 1.8, true)
	draw_line(Vector2(x0, rect.position.y), Vector2(x1, rect.position.y), edge, 1.8, true)
	draw_line(Vector2(x0, rect.position.y + rect.size.y), Vector2(x1, rect.position.y + rect.size.y), edge, 1.8, true)
