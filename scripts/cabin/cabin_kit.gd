extends Object
class_name CabinKit
## Shared 4x helpers for cabin rooms and overlays. No player-facing strings here.

const COPY := preload("res://scripts/player_copy.gd")
const PX := 4.0
const INK := Color("3a2414")
const CREAM := Color("f0e6d8")
const TITLE_CREAM := Color("fff3d6")
const WOOD := Color("5a3a24")
const MODE_RED := Color("5e1c18")
const MUTED := Color("a8946c")
const MUTED_INK := Color("6e5434")
const FOOT := Color("7a6a48")
const SCRIM := Color("100e0c")
const ROOM_W := 1680.0
const ROOM_H := 1040.0
const HOME := "res://assets/dungeon/home/"
const UI := "res://assets/ui/"
const ROOM_ORDER: Array[String] = ["mudroom", "main", "hall", "study", "workshop", "loft"]
## Shared talk-bar metrics. Intro captions and cabin Nib lines use the same numbers.
const DIALOG_SAFE := 32.0
## Cabin talk sits above the playtest Feedback pill (16px margin + ~48px button).
const DIALOG_SAFE_CABIN := 72.0
const DIALOG_PAD := 16.0
const DIALOG_GAP := 12.0
const DIALOG_PROMPT_H := 56.0
const DIALOG_FONT := 34
const DIALOG_PATCH_NATIVE := 12.0
const BUBBLE_PATCH_NATIVE := 8.0
const BUBBLE_FONT := 26
const BUBBLE_MAX_W_NATIVE := 140.0


static func px(n: float) -> float:
	return n * PX


static func pt(x: float, y: float) -> Vector2:
	return Vector2(x, y) * PX


static func rect4(a: Array) -> Rect2:
	if a.size() < 4:
		return Rect2()
	return Rect2(float(a[0]) * PX, float(a[1]) * PX, float(a[2]) * PX, float(a[3]) * PX)


static func vec2(a: Array) -> Vector2:
	if a.size() < 2:
		return Vector2.ZERO
	return Vector2(float(a[0]) * PX, float(a[1]) * PX)


static func load_tex(rel: String) -> Texture2D:
	var path: String = rel
	if not path.ends_with(".png"):
		path += ".png"
	var full: String = HOME + path
	if not ResourceLoader.exists(full):
		return null
	return load(full) as Texture2D


static func ui_tex(rel: String) -> Texture2D:
	var path: String = rel
	if path.begins_with("res://"):
		if ResourceLoader.exists(path):
			return load(path) as Texture2D
		return null
	if not path.ends_with(".png"):
		path += ".png"
	if path.begins_with("assets/"):
		var abs_path := "res://" + path
		if ResourceLoader.exists(abs_path):
			return load(abs_path) as Texture2D
		return null
	var full: String = UI + path
	if not ResourceLoader.exists(full):
		return null
	return load(full) as Texture2D


static func load_layout(path: String) -> Dictionary:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {}
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


static func layout_el(layout: Dictionary, id: String) -> Dictionary:
	for e in layout.get("elements", []):
		if typeof(e) == TYPE_DICTIONARY and str(e.get("id", "")) == id:
			return e
	return {}


static func layout_child(el: Dictionary, id: String) -> Dictionary:
	for c in el.get("children", []):
		if typeof(c) == TYPE_DICTIONARY and str(c.get("id", "")) == id:
			return c
	return {}


static func rect_px(a: Array) -> Rect2:
	if a.size() < 4:
		return Rect2()
	return Rect2(float(a[0]), float(a[1]), float(a[2]), float(a[3]))


static func apply_rect(c: Control, r: Rect2, z: int = 0) -> void:
	if c == null:
		return
	c.position = r.position
	c.size = r.size
	c.z_index = z


static func scrim(alpha: float = 0.75, z: int = 50) -> ColorRect:
	var c := ColorRect.new()
	c.name = "Scrim"
	c.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var col := SCRIM
	col.a = alpha
	c.color = col
	c.mouse_filter = Control.MOUSE_FILTER_STOP
	c.z_index = z
	return c


static func ui_nine(rel: String, l: int, t: int, r: int, b: int) -> NinePatchRect:
	var n := NinePatchRect.new()
	n.texture = ui_tex(rel)
	n.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	n.patch_margin_left = l
	n.patch_margin_top = t
	n.patch_margin_right = r
	n.patch_margin_bottom = b
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return n


static func tex_style(rel: String, l: int, t: int, r: int, b: int) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = ui_tex(rel)
	sb.texture_margin_left = float(l)
	sb.texture_margin_top = float(t)
	sb.texture_margin_right = float(r)
	sb.texture_margin_bottom = float(b)
	sb.content_margin_left = float(l)
	sb.content_margin_top = float(t)
	sb.content_margin_right = float(r)
	sb.content_margin_bottom = float(b)
	return sb


static func fit_label(
	key: String,
	r: Rect2,
	max_px: int,
	min_px: int,
	lines: int,
	color: Color,
	align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT,
	valign: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER,
	z: int = 65
) -> FitLabelBox:
	var l: FitLabelBox = FitLabelBox.make()
	l.show_frame = false
	l.padding = 0
	l.max_font_size = max_px
	l.min_font_size = min_px
	l.max_lines = lines
	l.font_color = color
	l.horizontal_alignment = align
	l.vertical_alignment = valign
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if key != "":
		l.set_copy(key)
	apply_rect(l, r, z)
	return l


static func plank(r: Rect2, z: int = 20, primary: bool = false) -> FitButton:
	var b := FitButton.new()
	b.max_font_size = 40
	b.min_font_size = 24
	b.text = ""
	b.focus_mode = Control.FOCUS_ALL if primary else Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var prefix: String = "button/btn_plank_primary_" if primary else "button/btn_plank_"
	b.add_theme_stylebox_override("normal", tex_style(prefix + "normal.png", 16, 16, 16, 20))
	b.add_theme_stylebox_override("hover", tex_style(prefix + "hover.png", 16, 16, 16, 20))
	b.add_theme_stylebox_override("pressed", tex_style(prefix + "pressed.png", 16, 16, 16, 20))
	b.add_theme_stylebox_override("disabled", tex_style(prefix + "disabled.png", 16, 16, 16, 20))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", INK)
	b.add_theme_color_override("font_hover_color", INK)
	b.add_theme_color_override("font_pressed_color", INK)
	b.add_theme_color_override("font_disabled_color", WOOD)
	apply_rect(b, r, z)
	return b


static func dev_plank(r: Rect2, z: int = 90) -> FitButton:
	var b := FitButton.new()
	b.max_font_size = 24
	b.min_font_size = 16
	b.text = ""
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_stylebox_override("normal", tex_style("button/btn_dev_normal.png", 16, 12, 12, 12))
	b.add_theme_stylebox_override("hover", tex_style("button/btn_dev_hover.png", 16, 12, 12, 12))
	b.add_theme_stylebox_override("pressed", tex_style("button/btn_dev_pressed.png", 16, 12, 12, 12))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", CREAM)
	b.add_theme_color_override("font_hover_color", CREAM)
	b.add_theme_color_override("font_pressed_color", CREAM)
	apply_rect(b, r, z)
	return b


static func route_card_style(state: String) -> StyleBoxTexture:
	return tex_style("map/route_card_%s_9.png" % state, 24, 24, 24, 24)


static func tex_rect(rel: String, origin_native: Vector2, size_native: Vector2, z: int = 0) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = load_tex(rel)
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.position = origin_native * PX
	tr.size = size_native * PX
	tr.z_index = z
	return tr


static func nine(rel: String, margins_native: Vector2 = Vector2(12, 12)) -> NinePatchRect:
	var n := NinePatchRect.new()
	n.texture = load_tex(rel)
	n.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	n.patch_margin_left = int(margins_native.x * PX)
	n.patch_margin_right = int(margins_native.x * PX)
	n.patch_margin_top = int(margins_native.y * PX)
	n.patch_margin_bottom = int(margins_native.y * PX)
	n.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return n


static func frames(rels: Array, anim: String, fps: float, loop: bool) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for rel in rels:
		var tex: Texture2D = load_tex(str(rel))
		if tex:
			sf.add_frame(anim, tex)
	return sf


static func anim_sprite(rels: Array, anim: String, fps: float, loop: bool, origin_native: Vector2) -> AnimatedSprite2D:
	var sp := AnimatedSprite2D.new()
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp.centered = false
	sp.position = origin_native * PX
	sp.sprite_frames = frames(rels, anim, fps, loop)
	sp.z_index = 4
	return sp


static func copy_text(key: String) -> String:
	return COPY.text(key, "")


static func fill_text(key: String, vars: Dictionary) -> String:
	return COPY.fill(key, vars, "")


static func named(s: String) -> String:
	return COPY.apply_names(s)


## Full-width caption bar: same geometry for the intro stills and Nib's cabin talk box.
static func dialog_bar(view: Vector2, extra_h: float = 0.0, safe_bottom: float = -1.0) -> Dictionary:
	var bust_sz := Vector2(32, 32) * PX
	var safe := DIALOG_SAFE
	var bot: float = safe_bottom if safe_bottom >= 0.0 else safe
	var bar_h: float = DIALOG_PAD + bust_sz.y + DIALOG_GAP + DIALOG_PROMPT_H + DIALOG_PAD + extra_h
	var max_h: float = maxf(bar_h, view.y - safe - bot)
	bar_h = minf(bar_h, max_h)
	var bar_y: float = clampf(
		view.y - bot - bar_h,
		safe,
		maxf(safe, view.y - bot - bar_h)
	)
	var bar := Rect2(safe, bar_y, maxf(8.0, view.x - safe * 2.0), bar_h)
	var inner := Rect2(
		Vector2(DIALOG_PAD, DIALOG_PAD),
		bar.size - Vector2(DIALOG_PAD * 2.0, DIALOG_PAD * 2.0)
	)
	return {
		"bar": bar,
		"inner": inner,
		"bust_sz": bust_sz,
		"prompt_h": DIALOG_PROMPT_H,
		"gap": DIALOG_GAP,
	}


## Size a parchment nine-slice to its line so the gold frame never sits on the glyphs.
static func fit_bubble(box: NinePatchRect, lab: FitLabelBox, src: String, font_px: int = BUBBLE_FONT, patch_native: float = BUBBLE_PATCH_NATIVE) -> Vector2:
	if box == null or lab == null:
		return Vector2.ZERO
	var t: String = src.strip_edges()
	var patch: float = patch_native * PX
	box.patch_margin_left = int(patch)
	box.patch_margin_right = int(patch)
	box.patch_margin_top = int(patch)
	box.patch_margin_bottom = int(patch)
	lab.set_plain(t)
	lab.max_font_size = font_px
	lab.min_font_size = 16
	lab.max_lines = 2
	lab.padding = 0
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var font: Font = FitLabelBox.theme_font(lab)
	var max_inner: float = maxf(48.0, BUBBLE_MAX_W_NATIVE * PX - patch * 2.0)
	var one: Vector2 = FitLabelBox.measure(font, t, font_px, -1.0, false)
	var wrap: bool = one.x + 8.0 > max_inner
	var inner_w: float = max_inner if wrap else clampf(one.x + 8.0, 48.0, max_inner)
	var inner_h: float = maxf(float(font_px) * 1.25, one.y)
	if wrap:
		var multi: Vector2 = FitLabelBox.measure(font, t, font_px, inner_w, true)
		inner_h = maxf(inner_h, multi.y)
	var air: float = 8.0
	var sz := Vector2(inner_w + patch * 2.0, inner_h + patch * 2.0 + air)
	sz.x = maxf(sz.x, patch * 2.0 + 24.0)
	sz.y = maxf(sz.y, patch * 2.0 + inner_h)
	box.size = sz
	lab.set_anchors_preset(Control.PRESET_TOP_LEFT)
	lab.position = Vector2(patch, patch)
	lab.size = Vector2(inner_w, sz.y - patch * 2.0)
	lab.fit()
	return sz


## Keep a control on screen and above another rect (the talk box) if they would overlap.
static func place_bubble(sz: Vector2, want: Vector2, view: Vector2, avoid: Rect2 = Rect2()) -> Vector2:
	var pos := Vector2(want.x - sz.x * 0.5, want.y - sz.y)
	var m: float = 8.0
	pos.x = clampf(pos.x, m, maxf(m, view.x - sz.x - m))
	pos.y = clampf(pos.y, m, maxf(m, view.y - sz.y - m))
	if avoid.size.x > 4.0 and Rect2(pos, sz).intersects(avoid):
		pos.y = maxf(m, avoid.position.y - sz.y - m)
	return pos


static func label(key: String, font_px: int, color: Color = CREAM, autowrap: bool = false) -> FitLabelBox:
	var l: FitLabelBox = FitLabelBox.make()
	l.show_frame = false
	l.padding = 0
	l.max_font_size = font_px
	l.min_font_size = 12 if font_px <= 16 else 16
	l.font_color = color
	l.copy_key = key
	l.set_copy(key)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if autowrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func raw_label(text: String, font_px: int, color: Color = CREAM, autowrap: bool = false) -> FitLabelBox:
	var l: FitLabelBox = FitLabelBox.make()
	l.show_frame = false
	l.padding = 0
	l.max_font_size = font_px
	l.min_font_size = 12 if font_px <= 16 else 16
	l.font_color = color
	l.set_plain(text)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if autowrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


static func framed(key: String, font_px: int, rel: String, margins_native: Vector2, color: Color = INK, autowrap: bool = false) -> FitLabelBox:
	var l: FitLabelBox = label(key, font_px, color, autowrap)
	l.show_frame = true
	l.frame_texture = load_tex(rel)
	l.patch_margin_left = int(margins_native.x * PX)
	l.patch_margin_right = int(margins_native.x * PX)
	l.patch_margin_top = int(margins_native.y * PX)
	l.patch_margin_bottom = int(margins_native.y * PX)
	l.padding = maxi(int(margins_native.x * PX), int(margins_native.y * PX))
	return l


static func choice_tag(key: String, size_native: Vector2 = Vector2(80, 16)) -> Button:
	var b := FitButton.new()
	b.max_font_size = 22
	b.min_font_size = 16
	b.text = copy_text(key)
	_style_tag(b, size_native, 22)
	return b


static func step_tag(text: String, size_native: Vector2 = Vector2(14, 12)) -> Button:
	var b := FitButton.new()
	b.max_font_size = 20
	b.min_font_size = 12
	b.text = text
	b.custom_minimum_size = size_native * PX
	b.size = size_native * PX
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", INK)
	b.add_theme_color_override("font_hover_color", INK)
	b.add_theme_color_override("font_pressed_color", INK)
	b.add_theme_stylebox_override("normal", _step_sb("ui/choice_tag_idle.png"))
	b.add_theme_stylebox_override("hover", _step_sb("ui/choice_tag_hover.png"))
	b.add_theme_stylebox_override("pressed", _step_sb("ui/choice_tag_press.png"))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.focus_mode = Control.FOCUS_NONE
	return b


static func _style_tag(b: Button, size_native: Vector2, font_px: int) -> void:
	b.custom_minimum_size = size_native * PX
	b.size = size_native * PX
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", font_px)
	b.add_theme_color_override("font_color", INK)
	b.add_theme_color_override("font_hover_color", INK)
	b.add_theme_color_override("font_pressed_color", INK)
	b.add_theme_stylebox_override("normal", _choice_sb("ui/choice_tag_idle.png"))
	b.add_theme_stylebox_override("hover", _choice_sb("ui/choice_tag_hover.png"))
	b.add_theme_stylebox_override("pressed", _choice_sb("ui/choice_tag_press.png"))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.focus_mode = Control.FOCUS_NONE


static func _choice_sb(rel: String) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load_tex(rel)
	sb.texture_margin_left = 8.0 * PX
	sb.texture_margin_right = 8.0 * PX
	sb.texture_margin_top = 4.0 * PX
	sb.texture_margin_bottom = 4.0 * PX
	sb.content_margin_left = 10.0 * PX
	sb.content_margin_right = 10.0 * PX
	sb.content_margin_top = 4.0 * PX
	sb.content_margin_bottom = 4.0 * PX
	return sb


static func _step_sb(rel: String) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load_tex(rel)
	sb.texture_margin_left = 4.0 * PX
	sb.texture_margin_right = 4.0 * PX
	sb.texture_margin_top = 3.0 * PX
	sb.texture_margin_bottom = 3.0 * PX
	sb.content_margin_left = 2.0 * PX
	sb.content_margin_right = 2.0 * PX
	sb.content_margin_top = 1.0 * PX
	sb.content_margin_bottom = 1.0 * PX
	return sb


static func veil() -> TextureRect:
	var v := TextureRect.new()
	v.name = "Veil"
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.texture = load_tex("ui/overlay_vignette.png")
	v.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	v.stretch_mode = TextureRect.STRETCH_SCALE
	v.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	v.mouse_filter = Control.MOUSE_FILTER_STOP
	return v


static func cue(sfx, id: StringName) -> void:
	if sfx and sfx.has_method("play_event"):
		sfx.play_event(id)


static func home_tex_style(rel: String, l: int, t: int, r: int, b: int) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = load_tex(rel)
	if sb.texture == null:
		return null
	sb.texture_margin_left = float(l)
	sb.texture_margin_top = float(t)
	sb.texture_margin_right = float(r)
	sb.texture_margin_bottom = float(b)
	sb.content_margin_left = float(l)
	sb.content_margin_top = float(t)
	sb.content_margin_right = float(r)
	sb.content_margin_bottom = float(b)
	return sb


## HSlider chrome from home/ui slider PNGs. No-op when textures are missing.
static func apply_hslider(sl: HSlider) -> void:
	if sl == null:
		return
	var track: StyleBoxTexture = home_tex_style("ui/slider_track_9.png", int(4.0 * PX), 0, int(4.0 * PX), 0)
	if track == null:
		return
	sl.add_theme_stylebox_override("slider", track)
	var fill: StyleBoxTexture = home_tex_style("ui/slider_fill_9.png", int(4.0 * PX), 0, int(4.0 * PX), 0)
	if fill:
		sl.add_theme_stylebox_override("grabber_area", fill)
		sl.add_theme_stylebox_override("grabber_area_highlight", fill)
	var grab: Texture2D = load_tex("ui/slider_grabber.png")
	if grab:
		sl.add_theme_icon_override("grabber", grab)
	var grab_h: Texture2D = load_tex("ui/slider_grabber_hover.png")
	if grab_h:
		sl.add_theme_icon_override("grabber_highlight", grab_h)


## One-shot frame swap on a TextureRect / Sprite2D. Falls back silently if frames missing.
static func play_tex_frames(node: CanvasItem, rels: Array, ms_each: Array, hold_last_ms: float = 0.0) -> void:
	if node == null or rels.is_empty():
		return
	var first: Texture2D = load_tex(str(rels[0]))
	if first == null:
		return
	_set_node_tex(node, first)
	for i in rels.size():
		var tex: Texture2D = load_tex(str(rels[i]))
		if tex:
			_set_node_tex(node, tex)
		var ms: float = float(ms_each[i]) if i < ms_each.size() else 80.0
		await node.get_tree().create_timer(ms / 1000.0, true, true, true).timeout
	if hold_last_ms > 0.0:
		await node.get_tree().create_timer(hold_last_ms / 1000.0, true, true, true).timeout


static func _set_node_tex(node: CanvasItem, tex: Texture2D) -> void:
	if node is TextureRect:
		(node as TextureRect).texture = tex
	elif node is Sprite2D:
		(node as Sprite2D).texture = tex
	elif node is AnimatedSprite2D:
		pass


static func room_index(id: String) -> int:
	return ROOM_ORDER.find(id)


static func eval_visible(expr: String, cabin) -> bool:
	var e: String = expr.strip_edges()
	if e == "":
		return true
	if e == "geode_on_mantel":
		return bool(cabin.geode_on_mantel)
	if e == "ending_seen and not drawer_opened":
		return bool(cabin.ending_seen) and not bool(cabin.drawer_opened)
	if e == "ending_seen":
		return bool(cabin.ending_seen)
	return true
