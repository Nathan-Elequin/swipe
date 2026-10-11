extends VBoxContainer
## Victory or defeat column plate.

const COPY := preload("res://scripts/player_copy.gd")
const GOLD := Color("FFD84A")
const TORCH := Color("F09A34")
const SOOT := Color("1A120E")
const PARCHMENT := Color("E9D3A1")
const DIM := Color("A88C66")
const ATK := Color("D5443B")
const EDGE := Color("7A4E2B")

signal again_pressed

var kind: String = "victory"
var btn_again: Button
var _title: Label
var _sub: Label
var _font_px: Font
var _font_vt: Font
var _nib: TextureRect
var _hearts: HBoxContainer
var _spark: CPUParticles2D
var _win_played: bool = false


func setup(p_kind: String) -> void:
	kind = p_kind
	_font_px = load("res://assets/ui/fonts/PixelifySans-Bold.ttf")
	_font_vt = load("res://assets/ui/fonts/VT323-Regular.ttf")
	theme = load("res://themes/swipe_theme.tres")
	add_theme_constant_override("separation", 30)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font_px != null:
		_title.add_theme_font_override("font", _font_px)
	_title.add_theme_font_size_override("font_size", 72 if kind == "victory" else 84)
	if kind == "victory":
		_title.add_theme_color_override("font_color", GOLD)
		_title.add_theme_color_override("font_shadow_color", TORCH)
		_title.add_theme_constant_override("shadow_offset_y", 6)
	else:
		_title.add_theme_color_override("font_color", ATK)
	add_child(_title)
	_sub = Label.new()
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font_vt != null:
		_sub.add_theme_font_override("font", _font_vt)
	_sub.add_theme_font_size_override("font_size", 34)
	_sub.add_theme_color_override("font_color", PARCHMENT if kind == "victory" else DIM)
	add_child(_sub)
	if kind == "victory":
		_nib = TextureRect.new()
		_nib.custom_minimum_size = Vector2(160, 160)
		_nib.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_nib.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_nib.texture_filter = TEXTURE_FILTER_NEAREST
		_nib.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		_nib.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var smug: Texture2D = load("res://assets/sprites/nib/nib_smug.png")
		if smug != null:
			_nib.texture = smug
		add_child(_nib)
		_spark = CPUParticles2D.new()
		_spark.emitting = false
		_spark.one_shot = true
		_spark.explosiveness = 1.0
		_spark.amount = 16
		_spark.lifetime = 0.55
		_spark.direction = Vector2(0, -1)
		_spark.spread = 180.0
		_spark.initial_velocity_min = 40.0
		_spark.initial_velocity_max = 120.0
		_spark.gravity = Vector2(0, 180)
		_spark.scale_amount_min = 4.0
		_spark.scale_amount_max = 8.0
		_spark.color = GOLD
		var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(GOLD)
		_spark.texture = ImageTexture.create_from_image(img)
		_spark.z_index = 8
		add_child(_spark)
	else:
		_hearts = HBoxContainer.new()
		_hearts.alignment = BoxContainer.ALIGNMENT_CENTER
		_hearts.add_theme_constant_override("separation", 12)
		_hearts.modulate = Color(1, 1, 1, 0.6)
		_hearts.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_hearts)
		var empty: Texture2D = load("res://assets/icons/heart_empty.png")
		for _i in 3:
			var h := TextureRect.new()
			h.custom_minimum_size = Vector2(60, 60)
			h.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			h.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			h.texture_filter = TEXTURE_FILTER_NEAREST
			h.texture = empty
			h.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_hearts.add_child(h)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(spacer)
	btn_again = Button.new()
	btn_again.custom_minimum_size = Vector2(0, 88 if kind == "victory" else 84)
	btn_again.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_again.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_px != null:
		btn_again.add_theme_font_override("font", _font_px)
	btn_again.add_theme_font_size_override("font_size", 48 if kind == "victory" else 44)
	if kind == "victory":
		btn_again.add_theme_color_override("font_color", SOOT)
		var n := StyleBoxFlat.new()
		n.bg_color = GOLD
		n.border_color = TORCH
		n.set_border_width_all(5)
		btn_again.add_theme_stylebox_override("normal", n)
	else:
		btn_again.add_theme_color_override("font_color", GOLD)
		btn_again.add_theme_color_override("font_hover_color", GOLD)
		btn_again.add_theme_color_override("font_pressed_color", GOLD)
		btn_again.add_theme_color_override("font_focus_color", GOLD)
		var o := StyleBoxFlat.new()
		o.bg_color = Color(0, 0, 0, 0)
		o.border_color = GOLD
		o.set_border_width_all(5)
		btn_again.add_theme_stylebox_override("normal", o)
		btn_again.add_theme_stylebox_override("hover", o)
		btn_again.add_theme_stylebox_override("pressed", o)
		btn_again.add_theme_stylebox_override("focus", o)
	btn_again.pressed.connect(func() -> void: again_pressed.emit())
	add_child(btn_again)
	refresh_copy()


func refresh_copy() -> void:
	if kind == "victory":
		_title.text = COPY.need("title.win")
		_sub.text = COPY.need("title.win_sub")
	else:
		_title.text = COPY.need("title.lose")
		_sub.text = COPY.need("title.lose_sub")
	if btn_again:
		btn_again.text = COPY.need("title.again")


func grab_again() -> void:
	if btn_again:
		btn_again.grab_focus()


func reset_win_intro() -> void:
	_win_played = false
	if _title and kind == "victory":
		_title.scale = Vector2.ONE
		_title.modulate.a = 1.0
	if _spark:
		_spark.emitting = false


func play_win_intro(loot_n: int) -> void:
	if kind != "victory" or _win_played:
		return
	_win_played = true
	if _title:
		_title.pivot_offset = Vector2(_title.size.x * 0.5, _title.size.y * 0.5)
		_title.scale = Vector2(0.85, 0.85)
		_title.modulate.a = 0.0
	var delay: float = 0.08 * float(maxi(loot_n - 1, 0)) + 0.28
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_callback(_pop_title)


func _pop_title() -> void:
	if _title == null:
		return
	_title.pivot_offset = Vector2(_title.size.x * 0.5, _title.size.y * 0.5)
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(_title, "scale", Vector2.ONE, 0.18)
	tw.parallel().tween_property(_title, "modulate:a", 1.0, 0.12)
	if _spark:
		_spark.position = _title.position + Vector2(_title.size.x * 0.5, 24.0)
		_spark.restart()
		_spark.emitting = true
