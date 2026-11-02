extends Button
## H3-B2 cream Take arc under the wheel exterior.
## One click target for end-combat / Take net damage.
## Split ~1/3 | divider | ~2/3. Left = Block pip only (blank when 0).
## Right = locked player-copy Take / Safe + damage burst.
##
## Sweep is LEFT → RIGHT in screen space. Godot angles grow counterclockwise
## with +Y down, so the bottom-left is a larger angle than the bottom-right.
## Parameter t=0 is the visual left tip; t=1 is the visual right tip.
##
## Ends are ovular disk caps (same stack as move_arrow `_draw_tail`).
## Take word + burst follow the arc curvature (not flat horizontal).

const BODY_W := 48.0
const SPLIT_T := 0.34
## Bottom-centered sweep (radians). Nudged under the prior 1.42 so rounded
## end caps stay clear of move-arrow tails (selftest allows ~1.0–1.7).
const SWEEP := 1.32
## Gap from gold rim to the inner edge of this arc.
const RIM_GAP_DEFAULT := 4.0

var guide_c: Vector2 = Vector2.ZERO
var guide_r: float = 180.0
## Gap from rim to the inner edge of this arc.
var rim_gap: float = RIM_GAP_DEFAULT
var block_n: int = 0
var take_n: int = 0
var take_word: String = "Take"
var show_burst: bool = true
var burst_tex: Texture2D
var burst_pip: String = ""
var block_tex: Texture2D
var word_font: Font
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


func set_guide(c_local: Vector2, radius: float, gap: float = -1.0) -> void:
	guide_c = c_local
	guide_r = radius
	if gap >= 0.0:
		rim_gap = gap
	queue_redraw()


func set_combat(block_amt: int, net_take: int, word: String, burst: Texture2D, pip: String, blk_tex: Texture2D, font: Font) -> void:
	block_n = maxi(block_amt, 0)
	take_n = maxi(net_take, 0)
	take_word = word
	burst_tex = burst
	burst_pip = pip
	block_tex = blk_tex
	word_font = font
	show_burst = burst != null and net_take >= 0
	queue_redraw()


func inner_radius() -> float:
	return guide_r + rim_gap


func outer_radius() -> float:
	return inner_radius() + BODY_W


## Top of the Take arc in local space (y of the inner edge at bottom).
func top_y_local() -> float:
	return guide_c.y + inner_radius()


func block_pip_global() -> Vector2:
	var mid: Vector2 = _chord_point(SPLIT_T * 0.5)
	var xf: Transform2D = get_global_transform()
	return xf * mid


func arc_global_rect() -> Rect2:
	if guide_r < 8.0:
		return Rect2()
	var pts: PackedVector2Array = _band_outline()
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
	## Cap discs stick past the square radial cuts by ~BODY_W/2.
	return Rect2(mn, mx - mn).grow(BODY_W * 0.5)


func _has_point(point: Vector2) -> bool:
	if guide_r < 8.0:
		return false
	var cap_r: float = BODY_W * 0.5 + 2.0
	if point.distance_to(_chord_point(0.0)) <= cap_r:
		return true
	if point.distance_to(_chord_point(1.0)) <= cap_r:
		return true
	var d: float = point.distance_to(guide_c)
	var inn: float = inner_radius()
	var out: float = outer_radius()
	if d < inn - 2.0 or d > out + 2.0:
		return false
	var ang: float = (point - guide_c).angle()
	var span: Vector2 = _arc_span()
	var a0: float = span.x
	var a1: float = span.x + span.y
	var lo: float = minf(a0, a1)
	var hi: float = maxf(a0, a1)
	if ang < lo - 0.01 or ang > hi + 0.01:
		return false
	return true


func _arc_span() -> Vector2:
	## Start at visual LEFT (larger angle past six-o'clock), sweep toward
	## visual RIGHT (decreasing angle). t=0 left, t=1 right.
	var a0: float = PI * 0.5 + SWEEP * 0.5
	return Vector2(a0, -SWEEP)


## Chord width of the outer rim at the current guide (for layout spacers).
func outer_chord_width() -> float:
	return 2.0 * outer_radius() * sin(SWEEP * 0.5)


func _chord_point(t: float) -> Vector2:
	var span: Vector2 = _arc_span()
	var ang: float = span.x + span.y * clampf(t, 0.0, 1.0)
	var rad: float = (inner_radius() + outer_radius()) * 0.5
	return guide_c + Vector2.from_angle(ang) * rad


func _band_mid_radius() -> float:
	return (inner_radius() + outer_radius()) * 0.5


func _band_outline() -> PackedVector2Array:
	var span: Vector2 = _arc_span()
	var inn: float = inner_radius()
	var out: float = outer_radius()
	var pts := PackedVector2Array()
	var n := 24
	for i in n + 1:
		var t: float = float(i) / float(n)
		pts.append(guide_c + Vector2.from_angle(span.x + span.y * t) * out)
	for i in n + 1:
		var t: float = 1.0 - float(i) / float(n)
		pts.append(guide_c + Vector2.from_angle(span.x + span.y * t) * inn)
	## Cap discs: sample extremities so hit/layout rects cover the rounded ends.
	var cap_r: float = BODY_W * 0.5
	for t_end in [0.0, 1.0]:
		var c: Vector2 = _chord_point(t_end)
		pts.append(c + Vector2(cap_r, 0.0))
		pts.append(c + Vector2(-cap_r, 0.0))
		pts.append(c + Vector2(0.0, cap_r))
		pts.append(c + Vector2(0.0, -cap_r))
	return pts


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


func _draw() -> void:
	if guide_r < 8.0:
		return
	var live: bool = not disabled
	var hot: bool = live and is_hovered()
	var press := Vector2(0, 2) if live and _down else Vector2.ZERO
	var pal: Dictionary = _palette(live, hot)
	_draw_band(pal, press)
	_draw_end_caps(pal, press)
	_draw_divider(pal, press)
	if block_n > 0:
		_draw_block_pip(press)
	_draw_take_side(press)


func _draw_band(pal: Dictionary, press: Vector2) -> void:
	var span: Vector2 = _arc_span()
	var inn: float = inner_radius()
	var out: float = outer_radius()
	var bands: Array = [
		[0.00, pal["ink"]],
		[0.08, pal["wood"]],
		[0.16, pal["hi"]],
		[0.24, pal["trim"]],
		[0.32, pal["face"]],
		[0.78, pal["face"]],
		[0.86, pal["shade"]],
		[0.93, pal["lip"]],
		[0.97, pal["deep"]],
		[1.00, pal["ink"]],
	]
	var n := 28
	var outer_pts: Array = []
	var inner_pts: Array = []
	for i in n + 1:
		var t: float = float(i) / float(n)
		var ang: float = span.x + span.y * t
		var dir: Vector2 = Vector2.from_angle(ang)
		outer_pts.append(guide_c + dir * out + press)
		inner_pts.append(guide_c + dir * inn + press)
	for b in bands.size() - 1:
		var t0: float = float(bands[b][0])
		var t1: float = float(bands[b + 1][0])
		var col: Color = bands[b][1] as Color
		for i in n:
			var a0: Vector2 = (outer_pts[i] as Vector2).lerp(inner_pts[i], t0)
			var a1: Vector2 = (outer_pts[i + 1] as Vector2).lerp(inner_pts[i + 1], t0)
			var b0: Vector2 = (outer_pts[i] as Vector2).lerp(inner_pts[i], t1)
			var b1: Vector2 = (outer_pts[i + 1] as Vector2).lerp(inner_pts[i + 1], t1)
			draw_colored_polygon(PackedVector2Array([a0, a1, b1, b0]), col)


func _draw_end_caps(pal: Dictionary, press: Vector2) -> void:
	## Ovular tips matching move_arrow `_draw_tail` disk caps (no trim bead).
	var half: float = BODY_W * 0.5
	for t_end in [0.0, 1.0]:
		var c: Vector2 = _chord_point(t_end) + press
		var away: Vector2 = c - guide_c
		if away.length_squared() < 0.001:
			away = Vector2.DOWN
		else:
			away = away.normalized()
		draw_circle(c, half + 2.0, pal["ink"])
		draw_circle(c, half - 1.0, pal["wood"])
		draw_circle(c, half - 4.0, pal["face"])
		draw_arc(c, half - 2.0, away.angle() - 0.7, away.angle() + 0.7, 10, pal["hi"], 2.0, not OS.has_feature("web"))


func _draw_divider(pal: Dictionary, press: Vector2) -> void:
	var span: Vector2 = _arc_span()
	var ang: float = span.x + span.y * SPLIT_T
	var dir: Vector2 = Vector2.from_angle(ang)
	var a: Vector2 = guide_c + dir * (inner_radius() + 3.0) + press
	var b: Vector2 = guide_c + dir * (outer_radius() - 3.0) + press
	draw_line(a, b, pal["ink"], 2.0, not OS.has_feature("web"))
	draw_line(a, b, Color("3a2a1c", 0.85), 1.0, not OS.has_feature("web"))


func _draw_arc_text(font: Font, txt: String, fs: int, center_ang: float, r: float, fill: Color, outline: Color) -> void:
	if font == null or txt == "":
		return
	var advances: PackedFloat32Array = PackedFloat32Array()
	var total := 0.0
	for i in txt.length():
		var ch: String = txt.substr(i, 1)
		var w: float = font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		advances.append(w)
		total += w
	var s: float = -total * 0.5
	## span.y is negative (left→right): larger angle = visual left.
	## a = center_ang - arc_s / r keeps left chars at higher angles.
	for i in txt.length():
		var w: float = advances[i]
		var a: float = center_ang - (s + w * 0.5) / r
		var p: Vector2 = guide_c + Vector2.from_angle(a) * r
		draw_set_transform(p, a - PI * 0.5, Vector2.ONE)
		var ch: String = txt.substr(i, 1)
		var local := Vector2(-w * 0.5, float(fs) * 0.32)
		for ox in range(-2, 3):
			for oy in range(-2, 3):
				if ox == 0 and oy == 0:
					continue
				draw_char(font, local + Vector2(ox, oy), ch, fs, outline)
		draw_char(font, local, ch, fs, fill)
		s += w
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_block_pip(press: Vector2) -> void:
	## Center of the left third (t = SPLIT_T * 0.5), rotated to the arc.
	var span: Vector2 = _arc_span()
	var t_mid: float = SPLIT_T * 0.5
	var ang: float = span.x + span.y * t_mid
	var at: Vector2 = _chord_point(t_mid) + press
	var tex: Texture2D = block_tex
	if tex == null:
		return
	var sz := Vector2(tex.get_width(), tex.get_height())
	draw_set_transform(at, ang - PI * 0.5, Vector2.ONE)
	draw_texture(tex, -sz * 0.5)
	var font: Font = word_font if word_font != null else ThemeDB.fallback_font
	if font == null:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	var txt: String = str(block_n)
	var fs := 22
	var tsz: Vector2 = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p: Vector2 = Vector2(-tsz.x * 0.5, fs * 0.36)
	var ink := Color("100e0c")
	var col := Color("f0e6d8")
	for ox in range(-2, 3):
		for oy in range(-2, 3):
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_take_side(press: Vector2) -> void:
	var mid_t: float = SPLIT_T + (1.0 - SPLIT_T) * 0.5
	var span: Vector2 = _arc_span()
	var mid_ang: float = span.x + span.y * mid_t
	var r: float = _band_mid_radius()
	## Press shifts the guide for content so the arc body and labels stay locked.
	var saved_c: Vector2 = guide_c
	guide_c = guide_c + press
	var font: Font = word_font if word_font != null else ThemeDB.fallback_font
	if font == null:
		font = ThemeDB.fallback_font
	var fs := 32
	var word: String = take_word
	var text_w := 0.0
	if font != null and word != "":
		text_w = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var icon_w := 0.0
	var icon_h := 0.0
	if show_burst and burst_tex != null:
		icon_w = float(burst_tex.get_width())
		icon_h = float(burst_tex.get_height())
	var gap := 8.0
	var total: float = text_w + (gap + icon_w if icon_w > 0.0 else 0.0)
	## Arc-length offsets from the Take-third mid (left→right). Angle = mid - s/r.
	var word_off: float = -total * 0.5 + text_w * 0.5
	var burst_off: float = total * 0.5 - icon_w * 0.5
	if font != null and word != "":
		var ink := Color("6a1212") if take_n > 0 else Color("1c120c")
		var word_ang: float = mid_ang - word_off / r
		_draw_arc_text(font, word, fs, word_ang, r, ink, Color("100e0c"))
	if show_burst and burst_tex != null:
		var burst_ang: float = mid_ang - burst_off / r
		var bp: Vector2 = guide_c + Vector2.from_angle(burst_ang) * r
		draw_set_transform(bp, burst_ang - PI * 0.5, Vector2.ONE)
		draw_texture(burst_tex, Vector2(-icon_w * 0.5, -icon_h * 0.5))
		_draw_hit_num(font, Vector2.ZERO, str(take_n))
		if burst_pip != "" and font != null:
			var pip_fs := 16
			var origin := Vector2(-icon_w * 0.5, -icon_h * 0.5)
			draw_string(font, origin + Vector2(icon_w - 2.0, 14.0), burst_pip, HORIZONTAL_ALIGNMENT_LEFT, -1, pip_fs, Color("100e0c"))
			draw_string(font, origin + Vector2(icon_w, 12.0), burst_pip, HORIZONTAL_ALIGNMENT_LEFT, -1, pip_fs, Color("f0e6d8"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	guide_c = saved_c


func _draw_hit_num(font: Font, pos: Vector2, txt: String) -> void:
	if font == null or txt == "":
		return
	var fs := 22
	var tsz := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p := pos + Vector2(-tsz.x * 0.5, fs * 0.36)
	var ink := Color("100e0c")
	var col := Color("f0e6d8")
	for ox in [-2, 0, 2]:
		for oy in [-2, 0, 2]:
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)
	draw_string(font, p, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
