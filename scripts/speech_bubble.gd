extends Control
## Comic balloon: sits up-right of the speaker, tail joins the oval and points at the sprite.

const UX := preload("res://scripts/ux_style.gd")

var _mouth: Vector2 = Vector2.ZERO
var _text: String = ""
var _rim: Color = Color("c4a574")
var _ink: Color = Color("1c120c")
var _paper: Color = Color("f7ecda")
var _font_sz := 21
var _rad := 28.0
var _body: RichTextLabel


func setup() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 96
	top_level = true
	visible = false
	texture_filter = TEXTURE_FILTER_NEAREST
	_body = RichTextLabel.new()
	_body.bbcode_enabled = true
	_body.fit_content = true
	_body.scroll_active = false
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_theme_font_size_override("normal_font_size", _font_sz)
	_body.add_theme_font_size_override("bold_font_size", _font_sz)
	_body.add_theme_constant_override("line_separation", 4)
	_body.add_theme_color_override("default_color", _ink)
	UX.ink_on_paper(_body, 1)
	add_child(_body)


func present(mouth_global: Vector2, text: String, look: Dictionary = {}, prefer_left: bool = false, keep_left_of: float = -1.0) -> void:
	_text = text.strip_edges()
	if _text == "":
		hide_speech()
		return
	_mouth = mouth_global
	_rim = look.get("metal", Color("c4a574"))
	if _body == null:
		setup()
	_body.text = _text
	var wrap := 260.0
	_body.size = Vector2(wrap, 8.0)
	var h: float = maxf(float(_body.get_content_height()), 28.0)
	size = Vector2(maxf(wrap + 48.0, 200.0), maxf(h + 40.0, 72.0))
	_body.position = Vector2(22.0, 16.0)
	_body.size = Vector2(size.x - 44.0, h)
	global_position = _place_left() if prefer_left else _place_up_right()
	if keep_left_of > 0.0:
		global_position.x = minf(global_position.x, keep_left_of - size.x - 10.0)
		global_position.x = maxf(8.0, global_position.x)
	visible = true
	queue_redraw()


func hide_speech() -> void:
	visible = false
	_text = ""
	if _body != null:
		_body.text = ""


func _place_left() -> Vector2:
	var vp: Vector2 = get_viewport_rect().size
	var pos := Vector2(_mouth.x - size.x - 16.0, _mouth.y - size.y * 0.65)
	pos.x = clampf(pos.x, 8.0, maxf(8.0, vp.x - size.x - 8.0))
	pos.y = clampf(pos.y, 8.0, maxf(8.0, vp.y - size.y - 8.0))
	return pos


func _place_up_right() -> Vector2:
	var vp: Vector2 = get_viewport_rect().size
	var pos := Vector2(_mouth.x + 18.0, _mouth.y - size.y - 12.0)
	if pos.x + size.x > vp.x - 10.0:
		pos.x = _mouth.x - size.x - 14.0
	if pos.y < 8.0:
		pos.y = 8.0
	pos.x = clampf(pos.x, 8.0, maxf(8.0, vp.x - size.x - 8.0))
	pos.y = clampf(pos.y, 8.0, maxf(8.0, vp.y - size.y - 8.0))
	return pos


func _draw() -> void:
	if _text == "" or not visible:
		return
	var r := Rect2(Vector2.ZERO, size)
	var local_mouth: Vector2 = _mouth - global_position
	var shadow := Color(0.08, 0.05, 0.03, 0.32)
	_fill_round(Rect2(Vector2(3, 5), size), _rad, shadow)
	var tail: PackedVector2Array = _tail_pts(r, _rad, local_mouth)
	if tail.size() == 3:
		var sh := PackedVector2Array()
		for p in tail:
			sh.append(p + Vector2(3, 5))
		draw_colored_polygon(sh, shadow)
		draw_colored_polygon(tail, _paper)
	_fill_round(r, _rad, _paper)
	_stroke_round(r, _rad, _rim, 2.6)
	if tail.size() == 3:
		draw_line(tail[0], tail[2], _rim, 2.6, true)
		draw_line(tail[1], tail[2], _rim, 2.6, true)


func _tail_pts(r: Rect2, rad: float, mouth: Vector2) -> PackedVector2Array:
	if r.grow(-14.0).has_point(mouth):
		return PackedVector2Array()
	var c: Vector2 = r.get_center()
	var dir: Vector2 = mouth - c
	if dir.length() < 2.0:
		return PackedVector2Array()
	dir = dir.normalized()
	var attach: Vector2 = _ray_hit_round(c, dir, r, rad)
	var tan: Vector2 = Vector2(-dir.y, dir.x)
	var a: Vector2 = attach + tan * 17.0 - dir * 8.0
	var b: Vector2 = attach - tan * 17.0 - dir * 8.0
	var tip: Vector2 = mouth - dir * 4.0
	return PackedVector2Array([a, b, tip])


func _ray_hit_round(origin: Vector2, dir: Vector2, r: Rect2, rad: float) -> Vector2:
	var lo := 0.0
	var hi: float = r.size.length()
	for _i in 18:
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
	var corner := Vector2(maxf(q.x, 0.0), maxf(q.y, 0.0))
	return corner.length_squared() <= rr * rr


func _fill_round(r: Rect2, rad: float, col: Color) -> void:
	var rr: float = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	draw_rect(Rect2(r.position + Vector2(rr, 0.0), Vector2(r.size.x - rr * 2.0, r.size.y)), col)
	draw_rect(Rect2(r.position + Vector2(0.0, rr), Vector2(r.size.x, r.size.y - rr * 2.0)), col)
	draw_circle(r.position + Vector2(rr, rr), rr, col)
	draw_circle(Vector2(r.end.x - rr, r.position.y + rr), rr, col)
	draw_circle(Vector2(r.position.x + rr, r.end.y - rr), rr, col)
	draw_circle(r.end - Vector2(rr, rr), rr, col)


func _stroke_round(r: Rect2, rad: float, col: Color, w: float) -> void:
	var rr: float = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	draw_line(Vector2(r.position.x + rr, r.position.y), Vector2(r.end.x - rr, r.position.y), col, w, true)
	draw_line(Vector2(r.position.x + rr, r.end.y), Vector2(r.end.x - rr, r.end.y), col, w, true)
	draw_line(Vector2(r.position.x, r.position.y + rr), Vector2(r.position.x, r.end.y - rr), col, w, true)
	draw_line(Vector2(r.end.x, r.position.y + rr), Vector2(r.end.x, r.end.y - rr), col, w, true)
	draw_arc(r.position + Vector2(rr, rr), rr, PI, PI * 1.5, 14, col, w, true)
	draw_arc(Vector2(r.end.x - rr, r.position.y + rr), rr, -PI * 0.5, 0.0, 14, col, w, true)
	draw_arc(r.end - Vector2(rr, rr), rr, 0.0, PI * 0.5, 14, col, w, true)
	draw_arc(Vector2(r.position.x + rr, r.end.y - rr), rr, PI * 0.5, PI, 14, col, w, true)
