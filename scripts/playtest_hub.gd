extends ColorRect
## Boot menu for the playtest export. Brand New / Middle Progress / Continue / Feedback.

signal brand_new
signal middle_progress
signal continue_save
signal feedback_wanted

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")

const LOGO_PATH := "res://assets/dungeon/title/logo.png"

var _continue_box: VBoxContainer
var _col: VBoxContainer
var _hub_title: Control
var _logo: TextureRect
var _tag: Control


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = Color("100e0cf2")
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 125
	visible = false
	name = "playtest_hub"
	var wrap := CenterContainer.new()
	wrap.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(wrap)
	_col = VBoxContainer.new()
	_col.alignment = BoxContainer.ALIGNMENT_CENTER
	_col.add_theme_constant_override("separation", 18)
	_col.custom_minimum_size = Vector2(720, 0)
	wrap.add_child(_col)
	_logo = TextureRect.new()
	_logo.name = "title_logo"
	_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_logo.custom_minimum_size = Vector2(720, 160)
	_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_logo.visible = false
	if ResourceLoader.exists(LOGO_PATH):
		_logo.texture = load(LOGO_PATH)
	_col.add_child(_logo)
	_tag = _plain(COPY.text("title.tagline", "Where there's a will, there's a slay."), 28, Color("f4ede3"), 48)
	_tag.name = "title_tagline"
	_tag.visible = false
	_hub_title = _plain(COPY.text("playtest.hub_title", "Playtest"), 48, Color("e8c36a"), 56)
	_hub_title.name = "hub_title"
	_col.add_child(_action(
		COPY.text("playtest.brand_new", "Brand New"),
		COPY.text("playtest.brand_new_blurb", "Playtest as if you're starting the game for the first time."),
		func() -> void: brand_new.emit()
	))
	_col.add_child(_action(
		COPY.text("playtest.middle", "Middle Progress"),
		COPY.text("playtest.middle_blurb", "You've completed a few dungeons and unlocked a few items."),
		func() -> void: middle_progress.emit()
	))
	_continue_box = _action(
		COPY.text("playtest.continue", "Continue"),
		COPY.text("playtest.continue_blurb", "Keep the playtest save from last time."),
		func() -> void: continue_save.emit()
	)
	_col.add_child(_continue_box)
	_col.add_child(_make_button(COPY.text("playtest.feedback", "Feedback"), func() -> void: feedback_wanted.emit()))


func open_hub(can_continue: bool, see_through: bool = false) -> void:
	if _continue_box:
		_continue_box.visible = can_continue
	var on_title: bool = see_through and _logo != null and _logo.texture != null
	if _logo:
		_logo.visible = on_title
	if _tag:
		_tag.visible = on_title
	if _hub_title:
		_hub_title.visible = not on_title
	color = Color("100e0c99") if see_through else Color("100e0cf2")
	visible = true
	move_to_front()


func close_hub() -> void:
	visible = false


func _plain(text: String, size_px: int, col: Color, height: int) -> Control:
	var lab = FitLabelBox.make()
	lab.show_frame = false
	lab.padding = 0
	lab.max_font_size = size_px
	lab.min_font_size = 13
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.custom_minimum_size = Vector2(720, height)
	lab.font_color = col
	lab.set_plain(text)
	_col.add_child(lab)
	return lab


func _action(title: String, blurb: String, cb: Callable) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(_make_button(title, cb))
	var lab = FitLabelBox.make()
	lab.show_frame = false
	lab.padding = 0
	lab.max_font_size = 16
	lab.min_font_size = 13
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.custom_minimum_size = Vector2(680, 36)
	lab.font_color = Color("c9b9a8")
	lab.set_plain(blurb)
	box.add_child(lab)
	return box


func _make_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UX.dress_title_button(b, 280)
	b.pressed.connect(cb)
	return b
