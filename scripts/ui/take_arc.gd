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
## Ends are square radial cuts (no oval disk caps).
## Take word + burst follow the arc curvature (not flat horizontal).
## Band hugs the Block pip and take-damage burst; icons scale to ICON_MAX.
## Outer ink + inner highlight bevel; short engraved ticks at the square corners.

const BODY_W := 53.0
## Max native draw size for Block pip and take-damage burst (fits inside BODY_W).
const ICON_MAX := 40.0
## Extra outer radius on hover so the rim reads as a thicker / slightly larger band.
const HOVER_GROW := 3.0
## Bevel stroke widths (px). Outer ink sits on the rim; highlight sits just inside.
const BEVEL_INK := 2.5
const BEVEL_HI := 1.6
const SPLIT_T := 0.34
## Bottom-centered sweep (radians). 60% of the prior 1.32 (about 40% narrower)
## so the band sits tighter under the wheel. Half-sweep stays inside the
## move-arrow start (0.88). Selftest allows ~0.74–0.86.
const SWEEP := 0.792
## Gap from gold rim to the inner edge of this arc.
const RIM_GAP_DEFAULT := 10.0
## Content sits on the band midline. Keep at 0 so scaled icons do not spill.
const CONTENT_OUTWARD := 0.0

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
var mystery_take: bool = false
var _down: bool = false


func _ready() -> void:
	text = ""
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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


func set_combat(block_amt: int, net_take: int, word: String, burst: Texture2D, pip: String, blk_tex: Texture2D, font: Font, mystery: bool = false) -> void:
	block_n = maxi(block_amt, 0)
	take_n = maxi(net_take, 0)
	take_word = word
	burst_tex = burst
	burst_pip = pip
	block_tex = blk_tex
	word_font = font
	mystery_take = mystery
	show_burst = burst != null and (mystery or net_take >= 0)
	queue_redraw()


func inner_radius() -> float:
	return guide_r + rim_gap


func outer_radius() -> float:
	return inner_radius() + BODY_W


## Top of the Take arc in local space (y of the inner edge at bottom).
func top_y_local() -> float:
	return guide_c.y + inner_radius()


## Inner edge of the Take band, toward the wheel, so a beam can stop
## before the word and the damage icon.
func threat_line_end_global() -> Vector2:
	var span: Vector2 = _arc_span()
	var mid_t: float = SPLIT_T + (1.0 - SPLIT_T) * 0.5
	var ang: float = span.x + span.y * mid_t
	var p: Vector2 = guide_c + Vector2.from_angle(ang) * inner_radius()
	return get_global_transform() * p


## Screen point of the Take damage burst (the number on the right third).
func take_burst_global() -> Vector2:
	var mid_t: float = SPLIT_T + (1.0 - SPLIT_T) * 0.5
	var span: Vector2 = _arc_span()
	var mid_ang: float = span.x + span.y * mid_t
	var r: float = maxf(_content_radius(), 1.0)
	var font: Font = word_font if word_font != null else ThemeDB.fallback_font
	var text_w := 0.0
	if font != null and take_word != "":
		text_w = font.get_string_size(take_word, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	var icon_w := 0.0
	if show_burst and burst_tex != null:
		icon_w = _fitted_icon_size(burst_tex).x
	var total: float = text_w + (6.0 + icon_w if icon_w > 0.0 else 0.0)
	var burst_off: float = total * 0.5 - icon_w * 0.5
	var burst_ang: float = mid_ang - burst_off / r
	if icon_w <= 0.0:
		burst_ang = mid_ang
	var bp: Vector2 = guide_c + Vector2.from_angle(burst_ang) * r
	return get_global_transform() * bp


func block_pip_global() -> Vector2:
	var span: Vector2 = _arc_span()
	var ang: float = span.x + span.y * (SPLIT_T * 0.5)
	var mid: Vector2 = guide_c + Vector2.from_angle(ang) * _content_radius()
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
	## Hover grow + press offset. Square ends — no cap-disc padding.
	return Rect2(mn, mx - mn).grow(HOVER_GROW + 4.0)


func _has_point(point: Vector2) -> bool:
	if guide_r < 8.0:
		return false
	var d: float = point.distance_to(guide_c)
	var inn: float = inner_radius()
	var out: float = outer_radius()
	if d < inn - 2.0 or d > out + HOVER_GROW + 2.0:
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
	return pts


func _fitted_icon_size(tex: Texture2D) -> Vector2:
	if tex == null:
		return Vector2.ZERO
	var sz := Vector2(float(tex.get_width()), float(tex.get_height()))
	var longest: float = maxf(sz.x, sz.y)
	if longest <= 0.001:
		return sz
	var s: float = minf(1.0, ICON_MAX / longest)
	return sz * s


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
	var trim := Color("b08a3c")
	var wood := Color("7a5232")
	if hot and not _down:
		face = Color("f8f0d0")
		hi = Color("fffaf0")
		shade = Color("e2d09a")
		trim = Color("f0cc5c")
		wood = Color("d49a4c")
	if _down:
		face = face.darkened(0.10)
		hi = face
		trim = trim.darkened(0.08)
		wood = wood.darkened(0.08)
	return {
		"ink": Color("100e0c"),
		"wood": wood,
		"hi": hi,
		"trim": trim,
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
	var grow := 0.0
	var rim_extra := 0.0
	if live and hot and not _down:
		grow = HOVER_GROW
		rim_extra = 0.05
	elif live and _down:
		rim_extra = 0.04
	_draw_band(pal, press, grow, rim_extra)
	_draw_bevel(pal, press, grow)
	_draw_corner_ticks(pal, press, grow)
	_draw_divider(pal, press, grow)
	if block_n > 0:
		_draw_block_pip(press)
	_draw_take_side(press)


func _draw_band(pal: Dictionary, press: Vector2, grow: float = 0.0, rim_extra: float = 0.0) -> void:
	var span: Vector2 = _arc_span()
	var inn: float = inner_radius() - grow * 0.35
	var out: float = outer_radius() + grow
	var ink_in: float = 0.05 + rim_extra
	var wood_in: float = 0.10 + rim_extra
	var hi_in: float = 0.16 + rim_extra
	var face_out: float = 0.84 - rim_extra
	var bands: Array = [
		[0.00, pal["ink"]],
		[ink_in, pal["wood"]],
		[wood_in, pal["hi"]],
		[hi_in, pal["face"]],
		[face_out, pal["face"]],
		[0.90, pal["shade"]],
		[0.95, pal["lip"]],
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


func _rim_pts(rad: float, press: Vector2) -> PackedVector2Array:
	var span: Vector2 = _arc_span()
	var pts := PackedVector2Array()
	var n := 28
	for i in n + 1:
		var t: float = float(i) / float(n)
		var ang: float = span.x + span.y * t
		pts.append(guide_c + Vector2.from_angle(ang) * rad + press)
	return pts


func _end_inward_tang(t_end: float) -> Vector2:
	var span: Vector2 = _arc_span()
	var ang: float = span.x + span.y * t_end
	var dir: Vector2 = Vector2.from_angle(ang)
	## +t follows span.y. Interior from t=0 is +t; from t=1 is −t.
	var side: float = 1.0 if t_end < 0.5 else -1.0
	var ccw := Vector2(-dir.y, dir.x)
	var tang: Vector2 = ccw * span.y * side
	if tang.length_squared() < 0.0001:
		return Vector2.RIGHT
	return tang.normalized()


func _draw_bevel(pal: Dictionary, press: Vector2, grow: float = 0.0) -> void:
	## 2-tone metal rim: outer ink, gold just inside, inner cream highlight.
	var aa: bool = not OS.has_feature("web")
	var inn: float = inner_radius() - grow * 0.35
	var out: float = outer_radius() + grow
	var outer_pts: PackedVector2Array = _rim_pts(out, press)
	var gold_pts: PackedVector2Array = _rim_pts(out - BEVEL_INK - 0.4, press)
	var inner_pts: PackedVector2Array = _rim_pts(inn, press)
	var inner_hi: PackedVector2Array = _rim_pts(inn + BEVEL_HI + 0.4, press)
	draw_polyline(outer_pts, pal["ink"], BEVEL_INK, aa)
	draw_polyline(gold_pts, pal["trim"], 1.5, aa)
	draw_polyline(inner_pts, pal["hi"], BEVEL_HI, aa)
	draw_polyline(inner_hi, pal["wood"], 1.1, aa)
	var span: Vector2 = _arc_span()
	for t_end in [0.0, 1.0]:
		var ang: float = span.x + span.y * t_end
		var dir: Vector2 = Vector2.from_angle(ang)
		var a: Vector2 = guide_c + dir * inn + press
		var b: Vector2 = guide_c + dir * out + press
		draw_line(a, b, pal["ink"], BEVEL_INK, aa)
		var tang: Vector2 = _end_inward_tang(t_end)
		draw_line(a + tang * 2.0, b + tang * 2.0, pal["hi"], 1.4, aa)
		draw_line(a + tang * 3.2, b + tang * 3.2, pal["trim"], 1.0, aa)


func _draw_corner_ticks(pal: Dictionary, press: Vector2, grow: float = 0.0) -> void:
	## Short engraved L at each square corner. Stays on the rim, off the pip / Take word.
	var aa: bool = not OS.has_feature("web")
	var inn: float = inner_radius() - grow * 0.35
	var out: float = outer_radius() + grow
	var span: Vector2 = _arc_span()
	var tick := 4.5
	for t_end in [0.0, 1.0]:
		var ang: float = span.x + span.y * t_end
		var dir: Vector2 = Vector2.from_angle(ang)
		var tang: Vector2 = _end_inward_tang(t_end)
		for rad in [inn + 1.2, out - 1.2]:
			var p: Vector2 = guide_c + dir * rad + press
			## Along the square cut toward the cream (not off the band).
			var along_end: Vector2 = dir * (-2.8 if rad > (inn + out) * 0.5 else 2.8)
			draw_line(p, p + tang * tick, pal["ink"], 1.6, aa)
			draw_line(p, p + along_end, pal["ink"], 1.6, aa)
			draw_line(p + tang * 0.8 + along_end.normalized() * 0.8, p + tang * (tick - 0.6), pal["hi"], 1.0, aa)


func _draw_divider(pal: Dictionary, press: Vector2, grow: float = 0.0) -> void:
	var span: Vector2 = _arc_span()
	var ang: float = span.x + span.y * SPLIT_T
	var dir: Vector2 = Vector2.from_angle(ang)
	var inn: float = inner_radius() - grow * 0.35
	var out: float = outer_radius() + grow
	var a: Vector2 = guide_c + dir * (inn + 5.0) + press
	var b: Vector2 = guide_c + dir * (out - 5.0) + press
	var aa: bool = not OS.has_feature("web")
	## Engraved split: ink groove with a cream highlight on the Take side.
	## Take is to the right of the split (t > SPLIT_T), same +t as from the left end.
	var toward_take: Vector2 = Vector2(-dir.y, dir.x) * signf(span.y)
	if toward_take.length_squared() > 0.0001:
		toward_take = toward_take.normalized()
	draw_line(a, b, pal["ink"], 2.2, aa)
	draw_line(a + toward_take * 1.6, b + toward_take * 1.6, pal["hi"], 1.2, aa)
	draw_line(a - toward_take * 1.2, b - toward_take * 1.2, pal["lip"], 1.0, aa)


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


func _content_radius() -> float:
	## Mid-band plus a small outward bias so letters/burst clear the rim.
	return _band_mid_radius() + CONTENT_OUTWARD


func _draw_block_pip(press: Vector2) -> void:
	## Center of the left third (t = SPLIT_T * 0.5), rotated to the arc.
	var span: Vector2 = _arc_span()
	var t_mid: float = SPLIT_T * 0.5
	var ang: float = span.x + span.y * t_mid
	var rad: float = _content_radius()
	var at: Vector2 = guide_c + Vector2.from_angle(ang) * rad + press
	var tex: Texture2D = block_tex
	if tex == null:
		return
	var sz: Vector2 = _fitted_icon_size(tex)
	draw_set_transform(at, ang - PI * 0.5, Vector2.ONE)
	draw_texture_rect(tex, Rect2(-sz * 0.5, sz), false)
	var font: Font = word_font if word_font != null else ThemeDB.fallback_font
	if font == null:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	var txt: String = str(block_n)
	var fs := 18
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
	var r: float = _content_radius()
	## Press shifts the guide for content so the arc body and labels stay locked.
	var saved_c: Vector2 = guide_c
	guide_c = guide_c + press
	var font: Font = word_font if word_font != null else ThemeDB.fallback_font
	if font == null:
		font = ThemeDB.fallback_font
	var fs := 24
	var word: String = take_word
	var text_w := 0.0
	if font != null and word != "":
		text_w = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var icon_w := 0.0
	var icon_h := 0.0
	if show_burst and burst_tex != null:
		var isz: Vector2 = _fitted_icon_size(burst_tex)
		icon_w = isz.x
		icon_h = isz.y
	var gap := 6.0
	var total: float = text_w + (gap + icon_w if icon_w > 0.0 else 0.0)
	## Arc-length offsets from the Take-third mid (left→right). Angle = mid - s/r.
	var word_off: float = -total * 0.5 + text_w * 0.5
	var burst_off: float = total * 0.5 - icon_w * 0.5
	if font != null and word != "":
		## Safe is dark-on-tan and disappears into the band and the green behind it.
		## Cream letters, dark edge. Take keeps the red ink and gets a cream edge.
		var ink := Color("6a1212") if mystery_take or take_n > 0 else Color("f7f1e4")
		var edge := Color("f4ede3") if mystery_take or take_n > 0 else Color("100e0c")
		var word_ang: float = mid_ang - word_off / r
		_draw_arc_text(font, word, fs, word_ang, r, ink, edge)
	if show_burst and burst_tex != null:
		var burst_ang: float = mid_ang - burst_off / r
		var bp: Vector2 = guide_c + Vector2.from_angle(burst_ang) * r
		draw_set_transform(bp, burst_ang - PI * 0.5, Vector2.ONE)
		draw_texture_rect(burst_tex, Rect2(Vector2(-icon_w * 0.5, -icon_h * 0.5), Vector2(icon_w, icon_h)), false)
		_draw_hit_num(font, Vector2.ZERO, "?" if mystery_take else str(take_n))
		if burst_pip != "" and font != null:
			var pip_fs := 13
			var origin := Vector2(-icon_w * 0.5, -icon_h * 0.5)
			draw_string(font, origin + Vector2(icon_w - 2.0, 12.0), burst_pip, HORIZONTAL_ALIGNMENT_LEFT, -1, pip_fs, Color("100e0c"))
			draw_string(font, origin + Vector2(icon_w, 10.0), burst_pip, HORIZONTAL_ALIGNMENT_LEFT, -1, pip_fs, Color("f0e6d8"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	guide_c = saved_c


func _draw_hit_num(font: Font, pos: Vector2, txt: String) -> void:
	if font == null or txt == "":
		return
	var fs := 18
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
