extends Button
## Quarter-arc move control. It follows the outside of the wheel.
## Painted with the same face, lip, and outline as the Take button.
## The moves count sits in a foot outline at the bottom of the pair, not on Take.

const BODY_W := 30.0
const PlaytestUx := preload("res://scripts/playtest_ux.gd")

var pointing: int = 1
var guide_c: Vector2 = Vector2.ZERO
var guide_r: float = 180.0
var moves_n: int = 0
var show_count: bool = false
var _down: bool = false


func _ready() -> void:
	text = ""
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var empty := StyleBoxEmpty.new()
	add_theme_stylebox_override("normal", empty)
	add_theme_stylebox_override("hover", empty)
	add_theme_stylebox_override("pressed", empty)
	add_theme_stylebox_override("focus", empty)
	add_theme_stylebox_override("disabled", empty)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	button_down.connect(_set_down.bind(true))
	button_up.connect(_set_down.bind(false))


func _set_down(on: bool) -> void:
	_down = on
	queue_redraw()


func set_guide(c_local: Vector2, radius: float, n: int, show_n: bool) -> void:
	guide_c = c_local
	guide_r = radius
	moves_n = n
	show_count = show_n
	queue_redraw()


func _arc_span() -> Vector2:
	var off: float = PlaytestUx.move_arrow_start_offset()
	var a0: float = PI * 0.5 - float(pointing) * off
	var sweep: float = -float(pointing) * (PI * 0.28)
	return Vector2(a0, sweep)


func arc_global_rect() -> Rect2:
	if guide_r < 8.0:
		return Rect2()
	var pts: PackedVector2Array = _arc_pts()
	var mn := Vector2(1.0e9, 1.0e9)
	var mx := Vector2(-1.0e9, -1.0e9)
	var xf: Transform2D = get_global_transform()
	for p in pts:
		var g: Vector2 = xf * p
		mn.x = minf(mn.x, g.x)
		mn.y = minf(mn.y, g.y)
		mx.x = maxf(mx.x, g.x)
		mx.y = maxf(mx.y, g.y)
	if mx.x < mn.x:
		return Rect2()
	return Rect2(mn, mx - mn).grow(18.0)


func _arc_pts() -> PackedVector2Array:
	var span: Vector2 = _arc_span()
	var rad: float = guide_r + PlaytestUx.move_arrow_outer_pad()
	var pts := PackedVector2Array()
	for i in 28:
		var t: float = float(i) / 27.0
		pts.append(guide_c + Vector2.from_angle(span.x + span.y * t) * rad)
	return pts


func _has_point(point: Vector2) -> bool:
	if guide_r < 8.0:
		return false
	var pts: PackedVector2Array = _arc_pts()
	var best: float = 1.0e9
	for i in pts.size() - 1:
		best = minf(best, _dist_seg(point, pts[i], pts[i + 1]))
	var tip: Vector2 = _head_tip(pts)
	best = minf(best, point.distance_to(tip))
	return best <= 18.0 + BODY_W * 0.5


func _dist_seg(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab: Vector2 = b - a
	var den: float = ab.length_squared()
	if den < 0.001:
		return p.distance_to(a)
	var t: float = clampf((p - a).dot(ab) / den, 0.0, 1.0)
	return p.distance_to(a + ab * t)


func _draw() -> void:
	if guide_r < 8.0:
		return
	var live: bool = not disabled
	var hot: bool = live and is_hovered()
	var pts: PackedVector2Array = _arc_pts()
	var press := Vector2(0, 2) if live and _down else Vector2.ZERO
	if press != Vector2.ZERO:
		var shifted := PackedVector2Array()
		for p in pts:
			shifted.append(p + press)
		pts = shifted
	_draw_tail(pts[0], pts[1], live, hot)
	_draw_shaft(pts, live, hot)
	_draw_head(pts, live, hot)
	if show_count and pointing < 0:
		var foot_at: Vector2 = guide_c + Vector2.from_angle(PI * 0.5 + 0.72) * (guide_r + PlaytestUx.move_arrow_outer_pad() + 8.0)
		_draw_foot_count(foot_at, live)


func _palette(live: bool, hot: bool) -> Dictionary:
	if not live:
		return {
			"ink": Color("100e0c"),
			"wood": Color("5c564c"),
			"hi": Color("9a9286"),
			"trim": Color("6a6258"),
			"face": Color("8a8274"),
			"shade": Color("6e675c"),
			"lip": Color("4a4640"),
			"deep": Color("3a3834"),
		}
	var face := Color("d9c79c")
	var hi := Color("f0e6d0")
	var shade := Color("b8a47a")
	if hot and not _down:
		face = Color(minf(face.r * 1.12, 1.0), minf(face.g * 1.10, 1.0), minf(face.b * 1.06, 1.0))
		hi = Color(minf(hi.r * 1.06, 1.0), minf(hi.g * 1.05, 1.0), minf(hi.b * 1.02, 1.0))
	if _down:
		face = face.darkened(0.06)
		hi = face
	return {
		"ink": Color("100e0c"),
		"wood": Color("7a5232"),
		"hi": hi,
		"trim": Color("b08a3c"),
		"face": face,
		"shade": shade,
		"lip": Color("5a3a22"),
		"deep": Color("3a2416"),
	}


func _ends(pts: PackedVector2Array) -> Dictionary:
	var n: int = pts.size()
	var dirs: Array = []
	var aways: Array = []
	for i in n:
		var prev: Vector2 = pts[maxi(i - 1, 0)]
		var nxt: Vector2 = pts[mini(i + 1, n - 1)]
		var dir: Vector2 = nxt - prev
		if dir.length_squared() < 0.001:
			dir = Vector2.RIGHT
		else:
			dir = dir.normalized()
		var away: Vector2 = pts[i] - guide_c
		if away.length_squared() < 0.001:
			away = Vector2(-dir.y, dir.x)
		else:
			away = away.normalized()
		dirs.append(dir)
		aways.append(away)
	return {"dir": dirs, "away": aways}


func _draw_shaft(pts: PackedVector2Array, live: bool, hot: bool) -> void:
	var pal: Dictionary = _palette(live, hot)
	var bands: Array = [
		[0.00, pal["ink"]],
		[0.08, pal["wood"]],
		[0.16, pal["hi"]],
		[0.24, pal["trim"]],
		[0.32, pal["face"]],
		[0.74, pal["face"]],
		[0.84, pal["shade"]],
		[0.92, pal["lip"]],
		[0.97, pal["deep"]],
		[1.00, pal["ink"]],
	]
	var ends: Dictionary = _ends(pts)
	var aways: Array = ends["away"]
	var half: float = BODY_W * 0.5
	var n: int = pts.size()
	var outer: Array = []
	var inner: Array = []
	for i in n:
		outer.append(pts[i] + (aways[i] as Vector2) * half)
		inner.append(pts[i] - (aways[i] as Vector2) * half)
	for b in bands.size() - 1:
		var t0: float = float(bands[b][0])
		var t1: float = float(bands[b + 1][0])
		var col: Color = bands[b][1] as Color
		for i in n - 1:
			var a0: Vector2 = (outer[i] as Vector2).lerp(inner[i], t0)
			var a1: Vector2 = (outer[i + 1] as Vector2).lerp(inner[i + 1], t0)
			var b0: Vector2 = (outer[i] as Vector2).lerp(inner[i], t1)
			var b1: Vector2 = (outer[i + 1] as Vector2).lerp(inner[i + 1], t1)
			draw_colored_polygon(PackedVector2Array([a0, a1, b1, b0]), col)


func _draw_tail(tip: Vector2, nxt: Vector2, live: bool, hot: bool) -> void:
	var pal: Dictionary = _palette(live, hot)
	var back: Vector2 = tip - nxt
	if back.length_squared() < 0.001:
		back = Vector2.LEFT
	else:
		back = back.normalized()
	var away: Vector2 = tip - guide_c
	if away.length_squared() < 0.001:
		away = Vector2(-back.y, back.x)
	else:
		away = away.normalized()
	var half: float = BODY_W * 0.5
	_disk(tip, half + 2.0, pal["ink"])
	_disk(tip, half - 1.0, pal["wood"])
	_disk(tip, half - 4.0, pal["face"])
	draw_arc(tip, half - 2.0, away.angle() - 0.7, away.angle() + 0.7, 10, pal["hi"], 2.0, not OS.has_feature("web"))
	draw_circle(tip + back * (half * 0.35), 3.0, pal["trim"])
	draw_circle(tip + back * (half * 0.35), 1.5, pal["hi"])


func _disk(c: Vector2, rad: float, col: Color) -> void:
	if rad <= 0.5:
		return
	draw_circle(c, rad, col)


func _head_tip(pts: PackedVector2Array) -> Vector2:
	var tip: Vector2 = pts[pts.size() - 1]
	var prev: Vector2 = pts[pts.size() - 2]
	var dir: Vector2 = tip - prev
	if dir.length_squared() < 0.001:
		dir = Vector2.RIGHT
	else:
		dir = dir.normalized()
	return tip + dir * (BODY_W * 0.95)


func _draw_head(pts: PackedVector2Array, live: bool, hot: bool) -> void:
	var pal: Dictionary = _palette(live, hot)
	var tip: Vector2 = pts[pts.size() - 1]
	var prev: Vector2 = pts[pts.size() - 2]
	var dir: Vector2 = tip - prev
	if dir.length_squared() < 0.001:
		dir = Vector2.RIGHT
	else:
		dir = dir.normalized()
	var away: Vector2 = tip - guide_c
	if away.length_squared() < 0.001:
		away = Vector2(-dir.y, dir.x)
	else:
		away = away.normalized()
	var nose: Vector2 = tip + dir * (BODY_W * 0.95)
	var flare: float = BODY_W * 0.78
	var back: float = BODY_W * 0.22
	var base_out: Vector2 = tip - dir * back + away * flare
	var base_in: Vector2 = tip - dir * back - away * flare
	_tri(base_out, nose, base_in, pal["ink"], 4.0)
	var face_out: Vector2 = tip - dir * (back * 0.2) + away * (flare - 4.0)
	var face_in: Vector2 = tip - dir * (back * 0.2) - away * (flare - 4.0)
	var face_nose: Vector2 = tip + dir * (BODY_W * 0.72)
	draw_colored_polygon(PackedVector2Array([face_out, face_nose, face_in]), pal["face"])
	var aa: bool = not OS.has_feature("web")
	draw_line(face_out, face_nose, pal["hi"], 2.0, aa)
	draw_line(face_nose, face_in, pal["deep"], 3.0, aa)
	draw_line(face_out.lerp(face_nose, 0.18), face_in.lerp(face_nose, 0.18), pal["trim"], 2.0, aa)
	draw_line(base_out, nose, pal["wood"], 2.0, aa)


func _tri(a: Vector2, b: Vector2, c: Vector2, col: Color, grow: float) -> void:
	var mid: Vector2 = (a + b + c) / 3.0
	var pa: Vector2 = a + (a - mid).normalized() * grow
	var pb: Vector2 = b + (b - mid).normalized() * grow
	var pc: Vector2 = c + (c - mid).normalized() * grow
	draw_colored_polygon(PackedVector2Array([pa, pb, pc]), col)


func _draw_foot_count(pos: Vector2, live: bool) -> void:
	var r := 36.0
	var shadow := Color(0.04, 0.03, 0.02, 0.62 if live else 0.35)
	draw_circle(pos + Vector2(5, 7), r, shadow)
	draw_circle(pos + Vector2(5, 7), r * 0.72, shadow)
	var gold := Color("FFD84A") if live else Color("6a5f52")
	var ink := Color("100e0c")
	draw_circle(pos, r + 3.0, ink)
	draw_circle(pos, r, gold)
	draw_circle(pos, r - 5.0, Color("1a120e"))
	draw_arc(pos, r - 1.0, 0.0, TAU, 32, Color("fff3d6") if live else Color("8a7d6a"), 2.0, not OS.has_feature("web"))
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var txt: String = str(maxi(moves_n, 0))
	var fs := 32
	var tsz: Vector2 = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p: Vector2 = pos + Vector2(-tsz.x * 0.5, fs * 0.32)
	for ox in range(-2, 3):
		for oy in range(-2, 3):
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("fff8e8") if live else Color("c5cdd8"))
