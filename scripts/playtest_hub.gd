extends ColorRect
## Framed title hub (approved study B): quiet #15120f, cabin vignette LEFT, live title/menu RIGHT.
## Copy bindings unchanged. Continue visibility still follows actual save availability.

signal brand_new
signal middle_progress
signal continue_save
signal feedback_wanted

const COPY := preload("res://scripts/player_copy.gd")
const TRIANGLE_SCRIPT := preload("res://scripts/ui/title_framed_triangle.gd")

const CABIN_PATH := "res://assets/ui/title/cabin-vignette-native.png"
const FONT_TITLE_PATH := "res://assets/ui/fonts/eb_garamond/EBGaramond-SemiBold.ttf"
const FONT_ACTION_PATH := "res://assets/ui/fonts/open_sans/OpenSans-SemiBold.ttf"
const FONT_HELPER_PATH := "res://assets/ui/fonts/open_sans/OpenSans-Regular.ttf"
const THEME_PATH := "res://themes/title_framed.tres"

const COL_BG := Color("15120f")
const COL_TITLE := Color("f0e2c6")
const COL_ACTION := Color("e1d4bd")
const COL_HELPER := Color("b6a78e")
const COL_SELECTED_FILL := Color("30261a")
const COL_SELECTED_TITLE := Color("ffe3a5")
const COL_SELECTED_HELPER := Color("d1b88d")
const COL_CURSOR := Color("efc36e")
const COL_FRAME := Color("685039")
const COL_FRAME_INSET := Color("241c15")
const COL_SHADOW := Color("100e0b")
const COL_FOCUS_OUTLINE := Color("f7d58c")
const COL_PRESSED_FILL := Color("241c15")
const COL_DISABLED := Color("8f8575")

const BASE_W := 1680.0
const BASE_H := 1040.0
## B composition (baseline coords).
const FRAME_RECT := Rect2(162, 300, 688, 448)
const IMAGE_RECT := Rect2(166, 304, 680, 440)
const TITLE_RECT := Rect2(926, 284, 590, 90)
const MENU_X := 926.0
const MENU_W := 460.0
const ROW_H := 90.0
const ROW_YS := [414.0, 504.0, 594.0]
const FEEDBACK_POS := Vector2(966, 712)
const NATIVE_CABIN := Vector2(340, 220)
const DISPLAY_CABIN := Vector2(680, 440)

var _stage: Control
var _frame_shadow: ColorRect
var _frame_border: ColorRect
var _frame_inset: ColorRect
var _cabin: TextureRect
var _title: Label
var _btn_new: Button
var _btn_mid: Button
var _btn_continue: Button
var _btn_feedback: Button
var _rows: Array = []
var _font_title: Font
var _font_action: Font
var _font_helper: Font
var _layout_mode: String = "b"
var _built: bool = false


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = COL_BG
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 125
	visible = false
	name = "playtest_hub"
	_load_fonts()
	if ResourceLoader.exists(THEME_PATH):
		theme = load(THEME_PATH)
	_build()
	_built = true
	resized.connect(_on_resized)


func open_hub(can_continue: bool, _see_through: bool = false) -> void:
	## Framed B owns the screen; quiet opaque ground (see_through kept for call-site compat).
	color = COL_BG
	if _btn_continue:
		_btn_continue.visible = can_continue
	visible = true
	move_to_front()
	_layout()
	_wire_focus_loop()
	call_deferred("_focus_default")


func close_hub() -> void:
	visible = false


func _on_resized() -> void:
	if visible and _built:
		_layout()
		_wire_focus_loop()


func _load_fonts() -> void:
	if ResourceLoader.exists(FONT_TITLE_PATH):
		_font_title = load(FONT_TITLE_PATH) as Font
	if ResourceLoader.exists(FONT_ACTION_PATH):
		_font_action = load(FONT_ACTION_PATH) as Font
	if ResourceLoader.exists(FONT_HELPER_PATH):
		_font_helper = load(FONT_HELPER_PATH) as Font
	if _font_title == null or _font_action == null or _font_helper == null:
		push_warning("playtest_hub: framed title fonts missing — check assets/ui/fonts (OFL EB Garamond / Open Sans)")


func _build() -> void:
	_stage = Control.new()
	_stage.name = "FramedStage"
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)

	_frame_shadow = ColorRect.new()
	_frame_shadow.name = "FrameShadow"
	_frame_shadow.color = COL_SHADOW
	_frame_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_frame_shadow)

	_frame_border = ColorRect.new()
	_frame_border.name = "FrameBorder"
	_frame_border.color = COL_FRAME
	_frame_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_frame_border)

	_frame_inset = ColorRect.new()
	_frame_inset.name = "FrameInset"
	_frame_inset.color = COL_FRAME_INSET
	_frame_inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(_frame_inset)

	_cabin = TextureRect.new()
	_cabin.name = "CabinVignette"
	_cabin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cabin.stretch_mode = TextureRect.STRETCH_KEEP
	_cabin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_cabin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(CABIN_PATH):
		_cabin.texture = load(CABIN_PATH)
	_stage.add_child(_cabin)

	_title = Label.new()
	_title.name = "GameTitle"
	## Decorative wordmark only (approved B). Not a player-copy action string; do not invent a tagline.
	_title.text = "Spinheritance"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.add_theme_color_override("font_color", COL_TITLE)
	_title.add_theme_font_size_override("font_size", 80)
	_title.add_theme_constant_override("outline_size", 0)
	if _font_title:
		_title.add_theme_font_override("font", _font_title)
	_stage.add_child(_title)

	_btn_new = _make_action_row(
		"BrandNew",
		COPY.text("playtest.brand_new", "Brand New"),
		COPY.text("playtest.brand_new_blurb", "Start from scratch."),
		func() -> void: brand_new.emit()
	)
	_btn_mid = _make_action_row(
		"MiddleProgress",
		COPY.text("playtest.middle", "Middle Progress"),
		COPY.text("playtest.middle_blurb", "A few dungeons in."),
		func() -> void: middle_progress.emit()
	)
	_btn_continue = _make_action_row(
		"Continue",
		COPY.text("playtest.continue", "Continue"),
		COPY.text("playtest.continue_blurb", "Last save."),
		func() -> void: continue_save.emit()
	)
	_btn_feedback = _make_feedback(
		COPY.text("playtest.feedback", "Feedback"),
		func() -> void: feedback_wanted.emit()
	)
	_rows = [_btn_new, _btn_mid, _btn_continue]


func _make_action_row(p_name: String, action: String, helper: String, cb: Callable) -> Button:
	var b := Button.new()
	b.name = p_name
	b.text = ""
	b.focus_mode = Control.FOCUS_ALL
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size = Vector2(MENU_W, ROW_H)
	b.clip_contents = true
	_apply_row_styles(b, false, false)
	b.pressed.connect(cb)
	b.focus_entered.connect(_on_row_state.bind(b))
	b.focus_exited.connect(_on_row_state.bind(b))
	b.mouse_entered.connect(_on_row_state.bind(b))
	b.mouse_exited.connect(_on_row_state.bind(b))
	b.button_down.connect(_on_row_state.bind(b))
	b.button_up.connect(_on_row_state.bind(b))

	var tri := Control.new()
	tri.set_script(TRIANGLE_SCRIPT)
	tri.name = "CursorTriangle"
	tri.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tri.visible = false
	b.add_child(tri)

	var col := VBoxContainer.new()
	col.name = "Copy"
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 4)
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.offset_left = 40.0
	col.offset_right = -24.0
	col.offset_top = 14.0
	col.offset_bottom = -12.0
	b.add_child(col)

	var a := Label.new()
	a.name = "Action"
	a.text = action
	a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	a.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	a.add_theme_color_override("font_color", COL_ACTION)
	a.add_theme_font_size_override("font_size", 28)
	a.add_theme_constant_override("outline_size", 0)
	if _font_action:
		a.add_theme_font_override("font", _font_action)
	col.add_child(a)

	var h := Label.new()
	h.name = "Helper"
	h.text = helper
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	h.add_theme_color_override("font_color", COL_HELPER)
	h.add_theme_font_size_override("font_size", 18)
	h.add_theme_constant_override("outline_size", 0)
	if _font_helper:
		h.add_theme_font_override("font", _font_helper)
	col.add_child(h)

	_stage.add_child(b)
	return b


func _make_feedback(label: String, cb: Callable) -> Button:
	var b := Button.new()
	b.name = "Feedback"
	b.text = label
	b.flat = true
	b.focus_mode = Control.FOCUS_ALL
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size = Vector2(160, 38)
	b.add_theme_color_override("font_color", COL_HELPER)
	b.add_theme_color_override("font_hover_color", COL_SELECTED_TITLE)
	b.add_theme_color_override("font_pressed_color", COL_SELECTED_HELPER)
	b.add_theme_color_override("font_focus_color", COL_SELECTED_TITLE)
	b.add_theme_font_size_override("font_size", 22)
	b.add_theme_constant_override("outline_size", 0)
	if _font_helper:
		b.add_theme_font_override("font", _font_helper)
	var empty := StyleBoxEmpty.new()
	b.add_theme_stylebox_override("normal", empty)
	b.add_theme_stylebox_override("hover", empty)
	b.add_theme_stylebox_override("pressed", empty)
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color(0, 0, 0, 0)
	focus.draw_center = false
	focus.border_color = COL_FOCUS_OUTLINE
	focus.set_border_width_all(2)
	focus.set_expand_margin_all(4)
	b.add_theme_stylebox_override("focus", focus)
	b.pressed.connect(cb)
	_stage.add_child(b)
	return b


func _apply_row_styles(b: Button, selected: bool, pressed: bool) -> void:
	var fill := Color(0, 0, 0, 0)
	if pressed:
		fill = COL_PRESSED_FILL
	elif selected:
		fill = COL_SELECTED_FILL
	var normal := StyleBoxFlat.new()
	normal.bg_color = fill
	normal.draw_center = selected or pressed
	normal.set_corner_radius_all(0)
	normal.set_border_width_all(0)
	if selected or pressed:
		normal.border_width_left = 3
		normal.border_color = COL_CURSOR
		normal.content_margin_left = 37
	else:
		normal.content_margin_left = 40
	normal.content_margin_right = 24
	normal.content_margin_top = 14
	normal.content_margin_bottom = 12
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", normal)
	b.add_theme_stylebox_override("pressed", normal)
	var focus := normal.duplicate() as StyleBoxFlat
	## Focus-visible outline sits outside the fill; keep row size stable (no layout jump).
	focus.border_color = COL_FOCUS_OUTLINE
	focus.set_border_width_all(0)
	focus.border_width_left = 3 if (selected or pressed) else 0
	if selected or pressed:
		focus.border_color = COL_CURSOR
	b.add_theme_stylebox_override("focus", focus)
	## Separate outline via modulate-free child would move layout; draw expand on a clone used only when focused.
	if b.has_focus():
		var outline := StyleBoxFlat.new()
		outline.bg_color = fill
		outline.draw_center = selected or pressed
		outline.set_corner_radius_all(0)
		outline.border_color = COL_FOCUS_OUTLINE
		outline.set_border_width_all(2)
		outline.set_expand_margin_all(4)
		if selected or pressed:
			## Keep gold stripe under outline by layering left edge via content only.
			outline.border_width_left = 3
			outline.border_color = COL_FOCUS_OUTLINE
		outline.content_margin_left = 37 if (selected or pressed) else 40
		outline.content_margin_right = 24
		outline.content_margin_top = 14
		outline.content_margin_bottom = 12
		b.add_theme_stylebox_override("focus", outline)


func _on_row_state(b: Button) -> void:
	if b == null or not is_instance_valid(b):
		return
	var selected: bool = b.has_focus() or b.is_hovered()
	var pressed: bool = b.button_pressed
	if b.disabled:
		selected = false
		pressed = false
	_apply_row_styles(b, selected, pressed)
	var tri := b.get_node_or_null("CursorTriangle")
	if tri:
		tri.visible = selected and not b.disabled
		if tri.has_method("set_active"):
			tri.call("set_active", selected and not b.disabled)
	var action := b.get_node_or_null("Copy/Action") as Label
	var helper := b.get_node_or_null("Copy/Helper") as Label
	if b.disabled:
		if action:
			action.add_theme_color_override("font_color", COL_DISABLED)
		if helper:
			helper.add_theme_color_override("font_color", COL_DISABLED)
		return
	if action:
		action.add_theme_color_override("font_color", COL_SELECTED_TITLE if selected else COL_ACTION)
	if helper:
		helper.add_theme_color_override("font_color", COL_SELECTED_HELPER if selected else COL_HELPER)


func _focus_default() -> void:
	if _btn_new and _btn_new.visible and not _btn_new.disabled:
		_btn_new.grab_focus()
		_on_row_state(_btn_new)


func _wire_focus_loop() -> void:
	var chain: Array = []
	for b in [_btn_new, _btn_mid, _btn_continue, _btn_feedback]:
		if b != null and b.visible and not b.disabled:
			chain.append(b)
	var n: int = chain.size()
	if n == 0:
		return
	for i in n:
		var cur: Control = chain[i]
		var nxt: Control = chain[(i + 1) % n]
		var prv: Control = chain[(i - 1 + n) % n]
		cur.focus_neighbor_bottom = cur.get_path_to(nxt)
		cur.focus_neighbor_top = cur.get_path_to(prv)
		cur.focus_next = cur.get_path_to(nxt)
		cur.focus_previous = cur.get_path_to(prv)


func _layout() -> void:
	if _stage == null:
		return
	var vp: Vector2 = size
	if vp.x < 8.0 or vp.y < 8.0:
		vp = Vector2(BASE_W, BASE_H)
	## Keep B when the baseline composition fits with readable helpers; else compact A reflow.
	var need_w := 1516.0 - 162.0 + 80.0
	var need_h := 758.0 - 284.0 + 120.0
	var can_b: bool = vp.x >= need_w and vp.y >= 720.0 and vp.x >= 1280.0
	if can_b and vp.y >= 800.0:
		_layout_mode = "b"
		_layout_b(vp)
	elif can_b:
		## 16:9-ish tall enough: still B, centered with quiet surround.
		_layout_mode = "b"
		_layout_b(vp)
	else:
		_layout_mode = "a"
		_layout_a_compact(vp)


func _layout_b(vp: Vector2) -> void:
	## Center the B composition as one unit; aspect expansion adds quiet surround only.
	var comp_pos := Vector2(162, 284)
	var comp_size := Vector2(1516 - 162, 758 - 284)
	var ox: float = floor((vp.x - BASE_W) * 0.5)
	var oy: float = floor((vp.y - BASE_H) * 0.5)
	## If viewport smaller than baseline but still "B-capable", nudge inward without nonuniform art scale.
	if vp.x < BASE_W:
		ox = floor((vp.x - comp_size.x) * 0.5) - comp_pos.x
	if vp.y < BASE_H:
		oy = floor((vp.y - comp_size.y) * 0.5) - comp_pos.y
	_stage.set_anchors_and_offsets_preset(PRESET_TOP_LEFT)
	_stage.position = Vector2.ZERO
	_stage.size = vp

	_place_frame(Vector2(ox, oy))
	_title.visible = true
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_title.add_theme_font_size_override("font_size", 80)
	_title.position = Vector2(TITLE_RECT.position.x + ox, TITLE_RECT.position.y + oy)
	_title.size = TITLE_RECT.size

	var ys := ROW_YS
	for i in _rows.size():
		var b: Button = _rows[i]
		b.custom_minimum_size = Vector2(MENU_W, ROW_H)
		b.position = Vector2(MENU_X + ox, ys[i] + oy)
		b.size = Vector2(MENU_W, ROW_H)
		_set_row_type_sizes(b, 28, 18)
		_place_triangle(b, 16, 26, 8, 12)
	_btn_feedback.position = Vector2(FEEDBACK_POS.x + ox, FEEDBACK_POS.y + oy)
	_btn_feedback.add_theme_font_size_override("font_size", 22)
	_btn_feedback.size = Vector2(200, 38)


func _layout_a_compact(vp: Vector2) -> void:
	## Small-window deliberate vertical reflow (study A-like). Exact 1× art, readable type.
	_layout_mode = "a"
	_stage.position = Vector2.ZERO
	_stage.size = vp
	var cabin_disp := NATIVE_CABIN ## 1×, no nonuniform scale
	var frame_w: float = cabin_disp.x + 8.0
	var frame_h: float = cabin_disp.y + 8.0
	var cx: float = floor((vp.x - frame_w) * 0.5)
	var top: float = 48.0
	_frame_shadow.position = Vector2(cx, top + 12)
	_frame_shadow.size = Vector2(frame_w, frame_h)
	_frame_border.position = Vector2(cx, top)
	_frame_border.size = Vector2(frame_w, frame_h)
	_frame_inset.position = Vector2(cx + 2, top + 2)
	_frame_inset.size = Vector2(frame_w - 4, frame_h - 4)
	_cabin.position = Vector2(cx + 4, top + 4)
	_cabin.size = cabin_disp

	var menu_w: float = minf(440.0, vp.x - 80.0)
	var mx: float = floor((vp.x - menu_w) * 0.5)
	var ty: float = top + frame_h + 24.0
	_title.add_theme_font_size_override("font_size", 64)
	_title.position = Vector2(mx, ty)
	_title.size = Vector2(menu_w, 72)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var row_h: float = 64.0
	var y0: float = ty + 80.0
	for i in _rows.size():
		var b: Button = _rows[i]
		b.custom_minimum_size = Vector2(menu_w, row_h)
		b.position = Vector2(mx, y0 + i * (row_h + 12.0))
		b.size = Vector2(menu_w, row_h)
		_set_row_type_sizes(b, 22, 16)
		_place_triangle(b, 16, 20, 8, 12)
		## Center copy inset for A.
		var copy := b.get_node_or_null("Copy") as Control
		if copy:
			copy.offset_left = 40.0
	_btn_feedback.position = Vector2(floor((vp.x - 160.0) * 0.5), y0 + 3.0 * (row_h + 12.0) + 16.0)
	_btn_feedback.add_theme_font_size_override("font_size", 21)
	_btn_feedback.size = Vector2(160, 36)


func _place_frame(origin: Vector2) -> void:
	## 2px border + 2px inset; 12px solid downward shadow. Inner image exact 2× nearest 680×440.
	var fr := FRAME_RECT
	var ir := IMAGE_RECT
	_frame_shadow.position = Vector2(fr.position.x + origin.x, fr.position.y + origin.y + 12.0)
	_frame_shadow.size = fr.size
	_frame_border.position = fr.position + origin
	_frame_border.size = fr.size
	_frame_inset.position = Vector2(fr.position.x + 2.0, fr.position.y + 2.0) + origin
	_frame_inset.size = Vector2(fr.size.x - 4.0, fr.size.y - 4.0)
	_cabin.position = ir.position + origin
	_cabin.size = DISPLAY_CABIN
	_cabin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cabin.stretch_mode = TextureRect.STRETCH_SCALE
	_cabin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _set_row_type_sizes(b: Button, action_px: int, helper_px: int) -> void:
	var action := b.get_node_or_null("Copy/Action") as Label
	var helper := b.get_node_or_null("Copy/Helper") as Label
	if action:
		action.add_theme_font_size_override("font_size", action_px)
	if helper:
		helper.add_theme_font_size_override("font_size", helper_px)


func _place_triangle(b: Button, left: float, top: float, w: float, h: float) -> void:
	var tri := b.get_node_or_null("CursorTriangle") as Control
	if tri == null:
		return
	tri.position = Vector2(left, top)
	tri.size = Vector2(w, h)
	tri.custom_minimum_size = Vector2(w, h)
