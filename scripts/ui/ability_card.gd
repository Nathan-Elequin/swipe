extends Control
## Hover / facing ability plate. 9-slice, 72px tall. Jam strings only.

const COPY := preload("res://scripts/player_copy.gd")

const INK := Color("f0e6d8")
const OUTLINE := Color("100e0c")
const GOLD := Color("e8c36a")
const RIGHT_PANEL_X := 1260.0
const CARD_H := 72.0
const BODY_W := 300.0

var call_txt: String = ""
var body_txt: String = ""
var icon: Texture2D
var ink: Color = INK
var _inner_w: float = 160.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 48
	visible = false


func set_content(call_s: String, body_s: String, tex: Texture2D, col: Color, silenced: bool) -> void:
	if silenced:
		call_txt = COPY.text("status.silenced", "Silenced")
	else:
		call_txt = call_s.strip_edges()
	body_txt = body_s.strip_edges()
	icon = tex
	ink = col
	_measure()
	queue_redraw()


func _font() -> Font:
	var f: Font = get_theme_default_font()
	if f == null:
		f = ThemeDB.fallback_font
	return f


func _measure() -> void:
	var font: Font = _font()
	var call_w: float = 0.0
	if font != null and call_txt != "":
		call_w = font.get_string_size(call_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
	var body_w: float = 0.0
	if font != null and body_txt != "":
		body_w = minf(BODY_W, font.get_multiline_string_size(body_txt, HORIZONTAL_ALIGNMENT_LEFT, BODY_W, 13, 2).x)
	var icon_w: float = 40.0 if icon != null else 0.0
	_inner_w = maxf(call_w + icon_w + 12.0, body_w)
	custom_minimum_size = Vector2(_inner_w + 40.0, CARD_H)
	size = custom_minimum_size


func place_from_tag(tag_global: Rect2, dir: Vector2, hub_global: Vector2) -> void:
	_measure()
	var w: float = size.x
	var h: float = size.y
	var view: Rect2 = get_viewport().get_visible_rect()
	var screen_mid: float = view.get_center().x if view.size.x > 1.0 else hub_global.x
	var tag_mid: Vector2 = tag_global.get_center()
	# Top/bottom seats go left or right, away from the screen centre.
	var go_right: bool = tag_mid.x < screen_mid
	if absf(dir.x) >= absf(dir.y) and dir.length() >= 0.01:
		go_right = dir.x >= 0.0
	var pos := Vector2.ZERO
	if go_right:
		pos = Vector2(tag_global.end.x + 12.0, tag_mid.y - h * 0.5)
	else:
		pos = Vector2(tag_global.position.x - 12.0 - w, tag_mid.y - h * 0.5)
	if pos.x + w > RIGHT_PANEL_X - 4.0:
		pos.x = tag_global.position.x - 12.0 - w
		go_right = false
	if pos.x < view.position.x + 8.0:
		pos.x = tag_global.end.x + 12.0
		go_right = true
	# Keep off the tag itself (bottom-seat cards were landing on the slice).
	var card := Rect2(pos, Vector2(w, h))
	if card.intersects(tag_global.grow(8.0)):
		if go_right:
			pos.x = tag_global.end.x + 12.0
		else:
			pos.x = tag_global.position.x - 12.0 - w
	pos.x = clampf(pos.x, view.position.x + 8.0, minf(view.end.x - w - 8.0, RIGHT_PANEL_X - w - 4.0))
	pos.y = clampf(pos.y, view.position.y + 8.0, view.end.y - h - 8.0)
	global_position = pos
	visible = true
	queue_redraw()


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var tex: Texture2D = null
	if ResourceLoader.exists("res://assets/ui/wheel/name_tag.png"):
		tex = load("res://assets/ui/wheel/name_tag.png") as Texture2D
	if tex != null:
		_nine(tex, r, 5.0, 15.0)
	else:
		draw_rect(r, Color("1c1814"), true)
		draw_rect(r, GOLD, false, 2.0)
	var font: Font = _font()
	if font == null:
		return
	var x: float = 16.0
	var y1: float = 22.0
	if icon != null:
		draw_texture_rect(icon, Rect2(Vector2(x, 10.0), Vector2(20, 20)), false)
		x += 28.0
	_stroke_string(font, Vector2(x, y1 + font.get_ascent(16)), call_txt, 16, ink)
	if body_txt != "":
		var p := Vector2(16.0, 40.0 + font.get_ascent(13))
		for ox in [-1, 0, 1]:
			for oy in [-1, 0, 1]:
				if ox == 0 and oy == 0:
					continue
				draw_multiline_string(font, p + Vector2(ox, oy), body_txt, HORIZONTAL_ALIGNMENT_LEFT, BODY_W, 13, 2, OUTLINE)
		draw_multiline_string(font, p, body_txt, HORIZONTAL_ALIGNMENT_LEFT, BODY_W, 13, 2, INK)


func _stroke_string(font: Font, pos: Vector2, text: String, fs: int, col: Color) -> void:
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_string(font, pos + Vector2(ox, oy), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, OUTLINE)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _nine(tex: Texture2D, dest: Rect2, src_m: float, dst_m: float) -> void:
	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	var sx: Array[float] = [0.0, src_m, tw - src_m, tw]
	var sy: Array[float] = [0.0, src_m, th - src_m, th]
	var dx: Array[float] = [dest.position.x, dest.position.x + dst_m, dest.end.x - dst_m, dest.end.x]
	var dy: Array[float] = [dest.position.y, dest.position.y + dst_m, dest.end.y - dst_m, dest.end.y]
	for iy in 3:
		for ix in 3:
			var src := Rect2(sx[ix], sy[iy], sx[ix + 1] - sx[ix], sy[iy + 1] - sy[iy])
			var dst := Rect2(dx[ix], dy[iy], dx[ix + 1] - dx[ix], dy[iy + 1] - dy[iy])
			if src.size.x < 0.5 or src.size.y < 0.5 or dst.size.x < 0.5 or dst.size.y < 0.5:
				continue
			draw_texture_rect_region(tex, dst, src)
