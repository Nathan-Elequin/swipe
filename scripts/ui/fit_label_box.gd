extends Control
class_name FitLabelBox
## Nine-patch frame plus a padded Label. Shrinks to min size, then wraps on word
## boundaries only, then ellipsizes. Uses the project's theme font — never a custom face.
@warning_ignore_start("native_method_override")

const COPY := preload("res://scripts/player_copy.gd")
const SCENE_PATH := "res://scenes/ui/FitLabelBox.tscn"
const WORD_BREAK := TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE

static var _scene: PackedScene

@export var copy_key: String = ""
@export var padding: int = 12
@export var min_font_size: int = 16
@export var max_font_size: int = 32
@export var max_lines: int = 2
@export var show_frame: bool = false
@export var frame_texture: Texture2D
@export var patch_margin_left: int = 12
@export var patch_margin_top: int = 12
@export var patch_margin_right: int = 12
@export var patch_margin_bottom: int = 12
@export var font_color: Color = Color("f4ede3")
@export var grow_to_text: bool = false
@export var max_width: float = 420.0

var fill_vars: Dictionary = {}
var horizontal_alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT:
	set(v):
		horizontal_alignment = v
		if _label:
			_label.horizontal_alignment = v
var vertical_alignment: VerticalAlignment = VERTICAL_ALIGNMENT_CENTER:
	set(v):
		vertical_alignment = v
		if _label:
			_label.vertical_alignment = v
var text: String = "":
	get:
		return _label.text if _label else _plain
	set(v):
		_plain = str(v)
		_from_copy = false
		if _label:
			_label.text = _plain
		fit()
var autowrap_mode: TextServer.AutowrapMode = TextServer.AUTOWRAP_WORD_SMART:
	set(v):
		autowrap_mode = v
var visible_characters: int = -1:
	get:
		return _label.visible_characters if _label else _visible_chars
	set(v):
		_visible_chars = v
		_ensure()
		if _label:
			_label.visible_characters = v

var last_fit: Dictionary = {}

var _label: Label
var _frame: NinePatchRect
var _plain: String = ""
var _from_copy: bool = false
var _fitting: bool = false
var _visible_chars: int = -1


static func theme_font(from: Control = null) -> Font:
	if from:
		var named: Font = from.get_theme_font("font")
		if named:
			return named
		var def: Font = from.get_theme_default_font()
		if def:
			return def
	return ThemeDB.fallback_font


static func pixel_font() -> Font:
	return theme_font()


static func make() -> FitLabelBox:
	if _scene == null and ResourceLoader.exists(SCENE_PATH):
		_scene = load(SCENE_PATH) as PackedScene
	if _scene:
		return _scene.instantiate() as FitLabelBox
	return FitLabelBox.new()


static func even_size(n: int) -> int:
	var s: int = maxi(1, n)
	if s % 2 != 0:
		s -= 1
	return maxi(1, s)


static func measure(font: Font, src: String, font_px: int, wrap_w: float, wrap: bool) -> Vector2:
	if font == null or src == "":
		return Vector2.ZERO
	if wrap and wrap_w > 0.0:
		return font.get_multiline_string_size(
			src, HORIZONTAL_ALIGNMENT_LEFT, wrap_w, font_px, -1, WORD_BREAK
		)
	return font.get_string_size(src, HORIZONTAL_ALIGNMENT_LEFT, -1, font_px)


static func line_count(font: Font, src: String, font_px: int, wrap_w: float) -> int:
	if font == null or src == "":
		return 0
	var h: float = maxf(1.0, font.get_height(font_px))
	var sz: Vector2 = font.get_multiline_string_size(
		src, HORIZONTAL_ALIGNMENT_LEFT, wrap_w, font_px, -1, WORD_BREAK
	)
	return maxi(1, int(ceili(sz.y / h)))


## Shrink at max size down to min (word wrap only). If it still cannot fit, ellipsis.
static func plan(font: Font, src: String, box: Vector2, max_px: int, min_px: int, lines: int = 2) -> Dictionary:
	var out := {"size": min_px, "wrap": true, "ellipsis": false, "fits": false}
	if font == null:
		return out
	var lo: int = maxi(1, min_px)
	var hi: int = maxi(lo, max_px)
	if hi % 2 != lo % 2:
		hi -= 1
	var step := 2
	var wrap_w: float = maxf(1.0, box.x)
	var s: int = hi
	while s >= lo:
		var one: Vector2 = measure(font, src, s, -1.0, false)
		if one.x <= box.x + 0.5 and one.y <= box.y + 0.5:
			return {"size": s, "wrap": false, "ellipsis": false, "fits": true}
		var wrapped: Vector2 = measure(font, src, s, wrap_w, true)
		var n: int = line_count(font, src, s, wrap_w)
		if n <= lines and wrapped.x <= box.x + 0.5 and wrapped.y <= box.y + 0.5:
			return {"size": s, "wrap": true, "ellipsis": false, "fits": true}
		s -= step
	return {"size": lo, "wrap": true, "ellipsis": true, "fits": false}


static func apply_plan(lab: Label, box: Vector2, max_px: int, min_px: int, lines: int = 2) -> Dictionary:
	if lab == null:
		return {}
	var font: Font = theme_font(lab)
	if lab.has_theme_font_override("font"):
		lab.remove_theme_font_override("font")
	lab.clip_text = true
	lab.max_lines_visible = lines
	var p: Dictionary = plan(font, lab.text, box, max_px, min_px, lines)
	var sz: int = int(p.get("size", min_px))
	lab.add_theme_font_size_override("font_size", sz)
	if bool(p.get("wrap", false)):
		lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		lab.autowrap_mode = TextServer.AUTOWRAP_OFF
	if bool(p.get("ellipsis", false)):
		lab.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	else:
		lab.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	lab.set_meta("fit_min", min_px)
	lab.set_meta("fit_plan", p)
	return p


static func fit_button(b: Button, max_px: int = 22, min_px: int = 16) -> Dictionary:
	if b == null:
		return {}
	if b.has_theme_font_override("font"):
		b.remove_theme_font_override("font")
	b.clip_text = true
	var inner: Vector2 = b.size
	if inner.x < 2.0:
		inner = b.custom_minimum_size
	var sb: StyleBox = b.get_theme_stylebox("normal")
	if sb:
		inner.x = maxf(8.0, inner.x - sb.get_margin(SIDE_LEFT) - sb.get_margin(SIDE_RIGHT))
		inner.y = maxf(8.0, inner.y - sb.get_margin(SIDE_TOP) - sb.get_margin(SIDE_BOTTOM))
	var font: Font = theme_font(b)
	var p: Dictionary = plan(font, b.text, inner, max_px, min_px, 2)
	var sz: int = int(p.get("size", min_px))
	b.add_theme_font_size_override("font_size", sz)
	if bool(p.get("wrap", false)):
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	else:
		b.autowrap_mode = TextServer.AUTOWRAP_OFF
	if bool(p.get("ellipsis", false)):
		b.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	else:
		b.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	b.set_meta("fit_min", min_px)
	b.set_meta("fit_plan", p)
	return p


static func dress_label(lab: Label, max_px: int = 16, min_px: int = 16) -> void:
	if lab == null:
		return
	apply_plan(lab, lab.size if lab.size.x > 1.0 else lab.custom_minimum_size, max_px, min_px, 2)


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure()
	_sync_frame()
	_apply_source()
	fit()
	resized.connect(fit)


func _ensure() -> void:
	_frame = get_node_or_null("Frame") as NinePatchRect
	if _frame == null:
		_frame = NinePatchRect.new()
		_frame.name = "Frame"
		_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_frame)
		move_child(_frame, 0)
	_label = get_node_or_null("Label") as Label
	if _label == null:
		_label = Label.new()
		_label.name = "Label"
		_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_label)
	_label.clip_text = true
	_label.vertical_alignment = vertical_alignment
	_label.horizontal_alignment = horizontal_alignment
	_label.visible_characters = _visible_chars
	if _label.has_theme_font_override("font"):
		_label.remove_theme_font_override("font")
	_label.add_theme_color_override("font_color", font_color)


func _sync_frame() -> void:
	if _frame == null:
		return
	_frame.visible = show_frame and frame_texture != null
	_frame.texture = frame_texture
	_frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_frame.patch_margin_left = patch_margin_left
	_frame.patch_margin_top = patch_margin_top
	_frame.patch_margin_right = patch_margin_right
	_frame.patch_margin_bottom = patch_margin_bottom


func _inner_rect() -> Rect2:
	var pad: float = float(maxi(0, padding))
	var r := Rect2(Vector2(pad, pad), size - Vector2(pad * 2.0, pad * 2.0))
	if r.size.x < 4.0:
		r.size.x = 4.0
	if r.size.y < 4.0:
		r.size.y = 4.0
	return r


func _apply_source() -> void:
	if copy_key != "":
		_from_copy = true
		if fill_vars.is_empty():
			_plain = COPY.text(copy_key, "")
		else:
			_plain = COPY.fill(copy_key, fill_vars, "")
	if _label:
		_label.text = _plain


func set_copy(key: String, vars: Dictionary = {}) -> void:
	copy_key = key
	fill_vars = vars.duplicate()
	_from_copy = true
	_apply_source()
	fit()


func set_plain(src: String) -> void:
	text = src


func set_outline(color: Color, px: int) -> void:
	_ensure()
	if _label:
		_label.add_theme_color_override("font_outline_color", color)
		_label.add_theme_constant_override("outline_size", px)


func fit() -> void:
	if _fitting:
		return
	_ensure()
	_fitting = true
	_sync_frame()
	if _label == null:
		_fitting = false
		return
	if _from_copy:
		_apply_source()
	_label.add_theme_color_override("font_color", font_color)
	_label.horizontal_alignment = horizontal_alignment
	_label.vertical_alignment = vertical_alignment
	if grow_to_text:
		_grow_then_fit()
	var pad: float = float(maxi(0, padding))
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.offset_left = pad
	_label.offset_top = pad
	_label.offset_right = -pad
	_label.offset_bottom = -pad
	var inner: Rect2 = _inner_rect()
	last_fit = apply_plan(_label, inner.size, max_font_size, min_font_size, max_lines)
	set_meta("fit_min", min_font_size)
	set_meta("fit_plan", last_fit)
	_fitting = false


func _grow_then_fit() -> void:
	var font: Font = theme_font(_label)
	var cap: float = max_width if max_width > 0.0 else 420.0
	var pad: float = float(padding) * 2.0
	var sz: Vector2 = measure(font, _label.text, max_font_size, -1.0, false)
	var w: float = minf(cap, sz.x + pad + 8.0)
	var h: float = maxf(sz.y + pad, float(max_font_size) + pad)
	if sz.x + pad > cap:
		h = maxf(h, float(max_font_size) * 2.4 + pad)
	size = Vector2(w, h)
	custom_minimum_size = size
