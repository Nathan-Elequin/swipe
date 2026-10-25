extends PanelContainer
## Named card. Icon + live number. Shift shows the hover equation in the number slot.

signal picked
signal hovered
signal unhovered
signal edit_wanted
signal passed_swipe

const COPY := preload("res://scripts/player_copy.gd")
const PLAYTEST_FLAG := preload("res://scripts/playtest_flag.gd")
const RANK_SHIMMER := preload("res://scripts/rank_shimmer.gd")
const CARD_W := 147.5
const CARD_H := 120.0
const SHOW_W := 236.0
const SHOW_H := 340.0

var uid: int = 0
var card_id: String = ""
var spent: bool = false
var kind: String = "ATK"

var _num: Label
var _ghost: Label
var _eq: RichTextLabel
var _mark: TextureRect
var _atk_pip: TextureRect
var _atk_pip_on: bool = false
var _icon: TextureRect
var _title
var _rank: Label
var _fill: Color
var _rim: Color
var _tier: int = 1
var _num_col: Color = Color.WHITE
var _shown: String = ""
var _lift: Tween
var _formula: String = ""
var _formula_on: bool = false
var _glow: bool = false
var _glow_t: float = 0.0
var _rim_glow: bool = true
var _hot: bool = false
var _showcase: bool = false
var _pass_swipe: bool = false
var _ability: RichTextLabel
var _col: VBoxContainer
var _num_host: Control
var _steal_tex: Texture2D
var _press_from: Vector2 = Vector2.ZERO
var _holding: bool = false
var _echo_mark: TextureRect
var _stone: TextureRect
var _playable: bool = false
var _guarding: bool = false
var _hatch: Control
var _lock_shade: Control
var _aura: bool = false
var _log_focus: bool = false
var _plus: TextureRect
var _ban: TextureRect
var _used: Label
var _danger: bool = false
var _bag_stamp: TextureRect
var _or: RichTextLabel
var _choice_badge: Label
var _cabinet_badge: Label
var _sai_fx: AnimatedSprite2D
var _marble_fx: AnimatedSprite2D
var _sparkle: AnimatedSprite2D
var _shimmer_mat: ShaderMaterial
var _shimmer_clock: float = 0.0
var _sai_busy: bool = false
var _marble_busy: bool = false
var _pending_live: String = ""
var _armed: bool = false
var _armed_lab: Label
var _no_effect: bool = false
var _sparkle_t: float = 0.0
var _desat: float = 0.0
var _sink_tw: Tween
var _petrified: bool = false
var _petrify_dummy: bool = false
var _petrify_spins: int = 0
var _petrify_creep: float = 0.0:
	set(v):
		_petrify_creep = v
		_apply_petrify_creep_uniform()
		queue_redraw()
var _shatter: AnimatedSprite2D
var _petrify_mat: ShaderMaterial
var _pip_flash: float = 0.0


func _apply_petrify_creep_uniform() -> void:
	# Shader lives on the icon TextureRect so TEXTURE is the item art, not the panel.
	if _icon != null and _icon.material is ShaderMaterial:
		(_icon.material as ShaderMaterial).set_shader_parameter("creep", _petrify_creep)
	elif material is ShaderMaterial:
		(material as ShaderMaterial).set_shader_parameter("creep", _petrify_creep)


func setup(
	p_uid: int,
	p_id: String,
	number_text: String,
	icon: Texture2D,
	fill: Color,
	rim: Color,
	title: String = "",
	num_col: Color = Color.WHITE,
	p_kind: String = "ATK",
	mark: Texture2D = null
) -> void:
	uid = p_uid
	card_id = p_id
	kind = p_kind
	_fill = fill
	_rim = rim
	_num_col = num_col
	_tier = 1
	tooltip_text = ""
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = Vector2(CARD_W, CARD_H)
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	clip_contents = false
	texture_filter = TEXTURE_FILTER_NEAREST
	_apply_style(false)
	mouse_entered.connect(_on_in)
	mouse_exited.connect(_on_out)
	gui_input.connect(_on_gui)

	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 4)
	pad.add_theme_constant_override("margin_right", 4)
	pad.add_theme_constant_override("margin_top", 3)
	pad.add_theme_constant_override("margin_bottom", 3)
	add_child(pad)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 1)
	pad.add_child(col)
	_col = col

	_rank = Label.new()
	_rank.visible = false
	_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rank.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_rank.max_lines_visible = 2
	_rank.custom_minimum_size = Vector2(CARD_W - 14.0, 0)
	_rank.add_theme_font_size_override("font_size", 12)
	_rank.add_theme_color_override("font_color", Color("c4a574"))
	_rank.add_theme_color_override("font_outline_color", Color("100e0c"))
	_rank.add_theme_constant_override("outline_size", 3)
	_rank.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_title = FitLabelBox.make()
	_title.show_frame = false
	_title.padding = 0
	_title.max_font_size = 14
	_title.min_font_size = 10
	_title.set_plain(title)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.custom_minimum_size = Vector2(CARD_W - 14.0, 22)
	_title.font_color = Color("f0e6d8")
	_title.set_outline(Color("100e0c"), 3)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_title)
	col.add_child(_rank)

	_icon = TextureRect.new()
	_icon.texture = icon
	_icon.custom_minimum_size = Vector2(48, 48)
	_icon.texture_filter = TEXTURE_FILTER_NEAREST
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_icon)
	if p_id == "shuriken":
		var arc := preload("res://scripts/move_arc_icon.gd").new()
		arc.name = "MoveArc"
		_icon.add_child(arc)

	var num_host := Control.new()
	num_host.custom_minimum_size = Vector2(CARD_W - 14.0, 32)
	num_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(num_host)
	_num_host = num_host

	_mark = TextureRect.new()
	_mark.texture = mark
	_mark.visible = mark != null and (number_text == "" or (p_kind == "DEFEAT" and number_text.is_valid_int()))
	_mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mark.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_layout_mark(number_text)
	num_host.add_child(_mark)

	_ghost = Label.new()
	_ghost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ghost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ghost.add_theme_font_size_override("font_size", 26)
	_ghost.add_theme_color_override("font_color", _num_col)
	_ghost.add_theme_color_override("font_outline_color", Color("100e0c"))
	_ghost.add_theme_constant_override("outline_size", 3)
	_ghost.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ghost.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ghost.modulate.a = 0.0
	num_host.add_child(_ghost)

	_num = Label.new()
	_num.text = number_text
	_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_num.add_theme_font_size_override("font_size", 26)
	_num.add_theme_color_override("font_color", _num_col)
	_num.add_theme_color_override("font_outline_color", Color("100e0c"))
	_num.add_theme_constant_override("outline_size", 3)
	_num.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	num_host.add_child(_num)

	_atk_pip = TextureRect.new()
	_atk_pip.name = "AtkPip"
	_atk_pip.visible = false
	_atk_pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_atk_pip.texture_filter = TEXTURE_FILTER_NEAREST
	_atk_pip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_atk_pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists("res://assets/ui/icons/atk_burst_single_s24_2x.png"):
		_atk_pip.texture = load("res://assets/ui/icons/atk_burst_single_s24_2x.png")
	elif ResourceLoader.exists("res://assets/ui/icons/atk_burst_18.png"):
		_atk_pip.texture = load("res://assets/ui/icons/atk_burst_18.png")
	num_host.add_child(_atk_pip)

	_or = RichTextLabel.new()
	_or.bbcode_enabled = true
	_or.scroll_active = false
	_or.fit_content = true
	_or.autowrap_mode = TextServer.AUTOWRAP_OFF
	_or.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_or.add_theme_font_size_override("normal_font_size", 22)
	_or.add_theme_color_override("default_color", Color("f0e6d8"))
	_or.add_theme_color_override("font_outline_color", Color("100e0c"))
	_or.add_theme_constant_override("outline_size", 3)
	_or.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_or.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_or.visible = false
	num_host.add_child(_or)

	_plus = TextureRect.new()
	_plus.visible = false
	_plus.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_plus.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_plus.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plus.texture_filter = TEXTURE_FILTER_NEAREST
	_plus.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_plus.offset_left = 4
	_plus.offset_top = -22
	_plus.offset_right = 24
	_plus.offset_bottom = -2
	num_host.add_child(_plus)

	_ban = TextureRect.new()
	_ban.visible = false
	_ban.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ban.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_ban.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ban.texture_filter = TEXTURE_FILTER_NEAREST
	_ban.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_ban.offset_left = -24
	_ban.offset_top = -22
	_ban.offset_right = -4
	_ban.offset_bottom = -2
	num_host.add_child(_ban)

	_eq = RichTextLabel.new()
	_eq.bbcode_enabled = true
	_eq.fit_content = true
	_eq.scroll_active = false
	_eq.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_eq.add_theme_font_size_override("normal_font_size", 11)
	_eq.add_theme_font_size_override("bold_font_size", 11)
	_eq.add_theme_color_override("default_color", Color("f0e6d8"))
	_eq.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_eq.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_eq.visible = false
	num_host.add_child(_eq)

	_ability = RichTextLabel.new()
	_ability.bbcode_enabled = true
	_ability.fit_content = true
	_ability.scroll_active = false
	_ability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ability.add_theme_font_size_override("normal_font_size", 15)
	_ability.add_theme_font_size_override("bold_font_size", 15)
	_ability.add_theme_color_override("default_color", Color("f0e6d8"))
	_ability.custom_minimum_size = Vector2(196, 0)
	_ability.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ability.visible = false
	_ability.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(_ability)
	_used = Label.new()
	_used.text = COPY.text("combat.used", "USED")
	_used.visible = false
	_used.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_used.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_used.add_theme_font_size_override("font_size", 18)
	_used.add_theme_color_override("font_color", Color("f0e6d8"))
	_used.add_theme_color_override("font_outline_color", Color("100e0c"))
	_used.add_theme_constant_override("outline_size", 6)
	_used.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_used.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_used)
	set_live(number_text, "", true)
	_sync_hatch()
	_sync_lock_shade()
	_bind_rank_fx()
	set_process(true)


func _sync_hatch() -> void:
	var on: bool = card_id == "spider_egg"
	if not on:
		if _hatch != null:
			_hatch.visible = false
		return
	if _hatch == null:
		_hatch = Control.new()
		_hatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_hatch.clip_contents = true
		_hatch.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
		_hatch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_hatch.draw.connect(_draw_egg_hatch)
		_hatch.resized.connect(_hatch.queue_redraw)
		add_child(_hatch)
		move_child(_hatch, 0)
	_hatch.visible = true
	_hatch.queue_redraw()


func _draw_egg_hatch() -> void:
	if _hatch == null:
		return
	var w: float = _hatch.size.x
	var h: float = _hatch.size.y
	if w < 2.0 or h < 2.0:
		return
	_hatch.draw_rect(Rect2(0, 0, w, h * 0.42), Color(1, 1, 1, 0.06))
	_hatch.draw_rect(Rect2(0, h * 0.58, w, h * 0.42), Color(0, 0, 0, 0.28))
	var ink := Color(0.92, 0.78, 0.72, 0.18)
	var x: float = -h
	while x < w + h:
		_hatch.draw_line(Vector2(x, h), Vector2(x + h * 0.65, 0.0), ink, 1.0)
		x += 6.0


func _sync_lock_shade() -> void:
	# Petrify uses its own stone look; keep the hatch off so creep/shatter read.
	var locked: bool = (not _showcase) and (spent or not _playable) and not _guarding and not (_petrified and not _petrify_dummy)
	if not locked:
		if _lock_shade != null:
			_lock_shade.visible = false
		return
	if _lock_shade == null:
		_lock_shade = Control.new()
		_lock_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_lock_shade.clip_contents = true
		_lock_shade.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
		_lock_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_lock_shade.draw.connect(_draw_lock_shade)
		_lock_shade.resized.connect(func() -> void:
			if _lock_shade != null:
				_lock_shade.queue_redraw()
		)
		add_child(_lock_shade)
	_lock_shade.visible = true
	if _used != null:
		move_child(_used, get_child_count() - 1)
	_lock_shade.queue_redraw()


func _draw_lock_shade() -> void:
	if _lock_shade == null:
		return
	var w: float = _lock_shade.size.x
	var h: float = _lock_shade.size.y
	if w < 2.0 or h < 2.0:
		return
	_lock_shade.draw_rect(Rect2(0, 0, w, h), Color(0.07, 0.05, 0.04, 0.16))
	var ink := Color(0.10, 0.08, 0.07, 0.32)
	var x: float = -h
	while x < w + h:
		_lock_shade.draw_line(Vector2(x, h), Vector2(x + h * 0.58, 0.0), ink, 1.5)
		x += 8.0
	var dust := Color(0.96, 0.90, 0.80, 0.08)
	x = -h
	while x < w + h:
		_lock_shade.draw_line(Vector2(x, 0.0), Vector2(x + h * 0.58, h), dust, 1.0)
		x += 12.0


func set_icon(tex: Texture2D) -> void:
	if _icon == null:
		return
	if _sai_busy or _marble_busy:
		return
	_icon.texture = tex


func set_bag_stamp(tex: Texture2D) -> void:
	if tex == null:
		if _bag_stamp:
			_bag_stamp.visible = false
		return
	if _bag_stamp == null:
		_bag_stamp = TextureRect.new()
		_bag_stamp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_bag_stamp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_bag_stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_bag_stamp.texture_filter = TEXTURE_FILTER_NEAREST
		_bag_stamp.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		_bag_stamp.offset_left = -36
		_bag_stamp.offset_top = -36
		_bag_stamp.offset_right = -2
		_bag_stamp.offset_bottom = -2
		if _icon:
			_icon.add_child(_bag_stamp)
		else:
			add_child(_bag_stamp)
	_bag_stamp.texture = tex
	_bag_stamp.visible = true


func set_echo_mark(tex: Texture2D) -> void:
	if _echo_mark == null:
		_echo_mark = TextureRect.new()
		_echo_mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_echo_mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_echo_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_echo_mark.texture_filter = TEXTURE_FILTER_NEAREST
		_echo_mark.custom_minimum_size = Vector2(32, 32)
		_echo_mark.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		_echo_mark.offset_left = -36
		_echo_mark.offset_top = 4
		_echo_mark.offset_right = -4
		_echo_mark.offset_bottom = 36
		add_child(_echo_mark)
	_echo_mark.texture = tex
	_echo_mark.visible = tex != null
	_echo_mark.modulate = Color(1, 1, 1, 0.42)


func set_num_color(c: Color) -> void:
	_num_col = c
	if _num:
		_num.add_theme_color_override("font_color", c)
	if _ghost:
		_ghost.add_theme_color_override("font_color", c)


func set_petrified(on: bool, dummy: bool = false, spins_left: int = 0, animate: bool = true) -> void:
	_ensure_stone()
	_ensure_petrify_shader()
	_petrified = on
	_petrify_dummy = dummy
	_petrify_spins = maxi(0, spins_left)
	if not on:
		_stone.visible = false
		material = null
		if _icon != null:
			_icon.material = null
			_icon.modulate = Color.WHITE
		_petrify_creep = 0.0
		if not _petrify_dummy:
			modulate = Color.WHITE
		_sync_lock_shade()
		queue_redraw()
		return
	if dummy:
		# Bushido dummy overlay — static stone, no creep/shatter.
		material = null
		if _icon != null:
			_icon.material = null
		_stone.visible = true
		_stone.modulate = Color(0.82, 0.78, 0.70, 0.55)
		modulate = Color.WHITE
		_petrify_creep = 1.0
		_sync_lock_shade()
		queue_redraw()
		return
	# Real petrify: creep shader on the icon; stone TextureRect only over the icon.
	_stone.visible = false
	material = null
	if animate:
		if _icon != null and _petrify_mat != null:
			_icon.material = _petrify_mat
		_petrify_creep = 0.0
		modulate = Color.WHITE
		if _icon != null:
			_icon.modulate = Color.WHITE
		var tw := create_tween()
		tw.set_trans(Tween.TRANS_SINE)
		tw.set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(self, "_petrify_creep", 1.0, 0.36)
		tw.parallel().tween_property(self, "modulate", Color(0.58, 0.56, 0.52, 1.0), 0.36)
		await tw.finished
		_petrify_creep = 1.0
		# Keep stone TextureRect hidden for real petrify — the PNG's dither reads as a
		# transparency checker when stretched over the icon. Shader holds the final look.
		_stone.visible = false
		_sync_lock_shade()
		queue_redraw()
	else:
		if _icon != null and _petrify_mat != null:
			_icon.material = _petrify_mat
		_petrify_creep = 1.0
		modulate = Color(0.58, 0.56, 0.52, 1.0)
		_stone.visible = false
		_sync_lock_shade()
		queue_redraw()


func petrify_tick(spins_left: int) -> void:
	_petrify_spins = maxi(0, spins_left)
	_pip_flash = 1.0
	queue_redraw()
	var tw := create_tween()
	tw.tween_property(self, "_pip_flash", 0.0, 0.10)
	# Three shard particles at the cracked pip.
	for i in 3:
		var spark := ColorRect.new()
		spark.color = Color("c9b9a8")
		spark.size = Vector2(3, 3)
		spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		spark.position = Vector2(size.x - 18.0 + float(i) * 2.0, 6.0 + float(i))
		add_child(spark)
		var st := create_tween()
		st.tween_property(spark, "position", spark.position + Vector2(randf_range(-8, 8), 14.0), 0.12)
		st.parallel().tween_property(spark, "modulate:a", 0.0, 0.12)
		st.finished.connect(spark.queue_free, CONNECT_ONE_SHOT)
	await tw.finished
	if _petrify_spins <= 0 and _petrified and not _petrify_dummy:
		await petrify_shatter()


func petrify_shatter() -> void:
	if _petrify_dummy:
		return
	_ensure_shatter()
	_stone.visible = false
	material = null
	if _icon != null:
		_icon.material = null
	_shatter.visible = true
	_shatter.position = size * 0.5
	if _shatter.sprite_frames != null and _shatter.sprite_frames.get_frame_count("shatter") > 0:
		_shatter.play("shatter")
	var fall := create_tween()
	fall.tween_property(_shatter, "position", _shatter.position + Vector2(0, 40), 0.25)
	fall.parallel().tween_property(_shatter, "modulate:a", 0.0, 0.25)
	var fade := create_tween()
	fade.tween_property(self, "modulate", Color.WHITE, 0.15)
	if _icon != null:
		fade.parallel().tween_property(_icon, "modulate", Color.WHITE, 0.15)
	await fall.finished
	_shatter.visible = false
	_shatter.modulate.a = 1.0
	_petrified = false
	_petrify_spins = 0
	_petrify_creep = 0.0
	queue_redraw()


func _ensure_stone() -> void:
	if _stone != null:
		return
	_stone = TextureRect.new()
	_stone.name = "PetrifyStone"
	_stone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Cover the icon only — full-card stretch read as a checker + white number strip.
	_stone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stone.stretch_mode = TextureRect.STRETCH_SCALE
	_stone.texture_filter = TEXTURE_FILTER_NEAREST
	_stone.texture = load("res://assets/dungeon/ui/petrify_stone.png") as Texture2D
	_stone.visible = false
	_stone.modulate = Color(0.86, 0.82, 0.74, 0.42)
	if _icon != null:
		_icon.add_child(_stone)
	else:
		add_child(_stone)


func _ensure_petrify_shader() -> void:
	if _petrify_mat != null:
		return
	var sh: Shader = load("res://shaders/petrify.gdshader") as Shader
	if sh == null:
		return
	_petrify_mat = ShaderMaterial.new()
	_petrify_mat.shader = sh
	var stone: Texture2D = load("res://assets/dungeon/ui/petrify_stone.png") as Texture2D
	if stone != null:
		_petrify_mat.set_shader_parameter("stone_tex", stone)
	_petrify_mat.set_shader_parameter("creep", 0.0)


func _ensure_shatter() -> void:
	if _shatter != null:
		return
	_shatter = AnimatedSprite2D.new()
	_shatter.name = "ShatterFx"
	_shatter.centered = true
	_shatter.scale = Vector2(4, 4)
	_shatter.texture_filter = TEXTURE_FILTER_NEAREST
	_shatter.visible = false
	var frames := SpriteFrames.new()
	frames.add_animation("shatter")
	frames.set_animation_speed("shatter", 20.0)
	frames.set_animation_loop("shatter", false)
	for i in 5:
		var p := "res://assets/ui/anim/petrify_shatter_f%s.png" % i
		if ResourceLoader.exists(p):
			frames.add_frame("shatter", load(p) as Texture2D)
	_shatter.sprite_frames = frames
	add_child(_shatter)


func set_title(text: String) -> void:
	if _title == null:
		return
	_title.text = COPY.apply_names(text)


func set_ability_bb(bb: String) -> void:
	if _ability == null:
		return
	var raw: String = COPY.apply_names(bb.strip_edges())
	_ability.text = "[center]%s[/center]" % raw
	_ability.visible = _showcase and raw != ""


func set_steal_cursor(tex: Texture2D) -> void:
	_steal_tex = tex


func drop_steal_cursor() -> void:
	if _steal_tex != null:
		Input.set_custom_mouse_cursor(null)


func set_pass_swipe(on: bool) -> void:
	_pass_swipe = on


func set_showcase(on: bool) -> void:
	_showcase = on
	_pass_swipe = on
	custom_minimum_size = Vector2(SHOW_W, SHOW_H) if on else Vector2(CARD_W, CARD_H)
	if _title:
		_title.max_font_size = 22 if on else 14
		_title.custom_minimum_size = Vector2(196 if on else CARD_W - 14.0, 48 if on else 38)
		_title.max_lines = 2
		_title.fit()
	if _rank:
		_rank.visible = false
		_rank.add_theme_font_size_override("font_size", 15 if on else 12)
		_rank.custom_minimum_size = Vector2(196 if on else CARD_W - 14.0, 0)
	if _icon:
		_icon.custom_minimum_size = Vector2(128, 128) if on else Vector2(64, 64)
	if _num_host:
		_num_host.custom_minimum_size = Vector2(196, 58) if on else Vector2(CARD_W - 14.0, 44)
	if _num:
		_num.add_theme_font_size_override("font_size", 48 if on else 32)
	if _ghost:
		_ghost.add_theme_font_size_override("font_size", 48 if on else 32)
	if _eq:
		_eq.add_theme_font_size_override("normal_font_size", 16 if on else 11)
		_eq.add_theme_font_size_override("bold_font_size", 16 if on else 11)
	if _ability:
		_ability.add_theme_font_size_override("normal_font_size", 15 if on else 13)
		_ability.add_theme_font_size_override("bold_font_size", 15 if on else 13)
		_ability.visible = on and _ability.text.strip_edges() != "" and _ability.text != "[center][/center]"
	_sync_lock_shade()
	_apply_style(_hot)


func set_live(number_text: String, _note: String = "", can_use: bool = true) -> void:
	if _num == null:
		return
	var or_bits: PackedStringArray = _or_parts(number_text)
	var wordy: bool = number_text.length() > 2 and not number_text.is_valid_int()
	var face: int = 48 if _showcase else 32
	_num.add_theme_font_size_override("font_size", 18 if wordy else face)
	if _ghost:
		_ghost.add_theme_font_size_override("font_size", 18 if wordy else face)
	if _sai_busy and number_text != "" and number_text != _shown:
		_pending_live = number_text
		_playable = can_use and not spent
		if _used != null:
			_used.visible = spent
		_sync_lock_shade()
		return
	if or_bits.size() == 2:
		_shown = number_text
		_num.visible = false
		_num.text = number_text
		if _ghost:
			_ghost.visible = false
		if _or:
			_or.visible = not _formula_on
			_or.text = "[center][color=#e06c75]%s[/color] OR [color=#6bb3d9]%s[/color][/center]" % [or_bits[0], or_bits[1]]
	elif not _formula_on:
		if _or:
			_or.visible = false
		if _ghost:
			_ghost.visible = true
		_num.visible = number_text != ""
		if number_text != "" and number_text != _shown and _shown != "":
			_dissolve(_shown, number_text)
		else:
			_num.text = number_text
			_shown = number_text
	else:
		_shown = number_text
		_num.text = number_text
		if _or:
			_or.visible = false
	if _glow or _aura or _log_focus or _danger:
		pass
	elif spent:
		modulate = Color(0.86, 0.84, 0.80, 1.0)
	else:
		modulate = Color.WHITE
	_playable = can_use and not spent
	if _used != null:
		_used.visible = spent
	_sync_lock_shade()
	if _mark != null and not _formula_on:
		var beside: bool = kind == "DEFEAT" and number_text.is_valid_int()
		_mark.visible = _mark.texture != null and (number_text == "" or beside)
		_mark.modulate.a = 0.95
		_layout_mark(number_text)
	_layout_atk_pip()


func _or_parts(number_text: String) -> PackedStringArray:
	var bits: PackedStringArray = number_text.split(" OR ", false)
	if bits.size() != 2:
		return PackedStringArray()
	if not str(bits[0]).is_valid_int() or not str(bits[1]).is_valid_int():
		return PackedStringArray()
	return bits


func set_rank(text: String) -> void:
	if _rank == null:
		return
	_rank.text = text
	_rank.visible = false


func set_choice_badge(text: String) -> void:
	var shown: String = text.strip_edges()
	if shown == "":
		if _choice_badge:
			_choice_badge.visible = false
		return
	var lab: Label = _ensure_corner_badge(true)
	lab.text = shown
	lab.visible = true
	var font: Font = lab.get_theme_font("font")
	if font == null:
		font = ThemeDB.fallback_font
	var w: float = 36.0
	if font:
		w = font.get_string_size(shown, HORIZONTAL_ALIGNMENT_LEFT, -1, 11).x
	var face_w: float = SHOW_W if _showcase else CARD_W
	lab.position = Vector2(maxf(4.0, face_w - w - 8.0), 2.0)


func set_cabinet_badge(on: bool, label: String, tip: String = "") -> void:
	if not on:
		if _cabinet_badge:
			_cabinet_badge.visible = false
		return
	var lab: Label = _ensure_corner_badge(false)
	lab.text = label
	lab.tooltip_text = tip
	lab.visible = true
	lab.position = Vector2(4.0, (SHOW_H if _showcase else CARD_H) - 16.0)


func _ensure_corner_badge(choice: bool) -> Label:
	var existing: Label = _choice_badge if choice else _cabinet_badge
	if existing != null:
		return existing
	var lab := Label.new()
	lab.mouse_filter = Control.MOUSE_FILTER_STOP
	lab.add_theme_font_size_override("font_size", 11)
	lab.add_theme_color_override("font_color", Color("f8f2ea"))
	lab.add_theme_color_override("font_outline_color", Color("100e0c"))
	lab.add_theme_constant_override("outline_size", 4)
	lab.z_index = 8
	lab.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT and _playable:
			picked.emit()
			lab.accept_event()
	)
	add_child(lab)
	if choice:
		_choice_badge = lab
	else:
		_cabinet_badge = lab
	return lab


func set_palette(fill: Color, metal: Color, tier: int = 1) -> void:
	_fill = fill
	_rim = metal
	_tier = maxi(1, tier)
	_apply_style(_hot)
	_tick_shimmer()


func _tier_shine() -> Color:
	if _tier >= 3:
		return Color("ffe6a8")
	if _tier == 2:
		return Color("f4f7fb")
	return Color("d4894e")


func _want_process() -> bool:
	return true


func set_atk_pip(on: bool) -> void:
	_atk_pip_on = on and kind == "ATK"
	_layout_atk_pip()


func _layout_atk_pip() -> void:
	if _atk_pip == null or _num == null or _num_host == null:
		return
	var show: bool = _atk_pip_on and _atk_pip.texture != null and not _formula_on and _num.visible and _num.text.strip_edges() != "" and _num.text != "—" and (_or == null or not _or.visible)
	_atk_pip.visible = show
	_num.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_num.offset_left = 0.0
	_num.offset_top = 0.0
	_num.offset_right = 0.0
	_num.offset_bottom = 0.0
	_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if not show:
		_num.add_theme_color_override("font_color", _num_col)
		_num.add_theme_constant_override("outline_size", 3)
		return
	_num.add_theme_font_size_override("font_size", 22)
	_num.add_theme_color_override("font_color", Color("f0e6d8"))
	_num.add_theme_color_override("font_outline_color", Color("100e0c"))
	_num.add_theme_constant_override("outline_size", 2)
	if _ghost:
		_ghost.add_theme_font_size_override("font_size", 22)
		_ghost.add_theme_color_override("font_color", Color("f0e6d8"))
		_ghost.add_theme_constant_override("outline_size", 2)
	var host_w: float = _num_host.size.x
	var host_h: float = _num_host.size.y
	if host_w < 8.0:
		host_w = CARD_W - 14.0
	if host_h < 8.0:
		host_h = 32.0
	var icon := 48.0
	if _atk_pip.texture != null:
		icon = float(_atk_pip.texture.get_width())
	var left: float = (host_w - icon) * 0.5
	var top: float = (host_h - icon) * 0.5
	_atk_pip.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_atk_pip.offset_left = left
	_atk_pip.offset_top = top
	_atk_pip.offset_right = left + icon
	_atk_pip.offset_bottom = top + icon
	_atk_pip.z_index = 0
	_num.z_index = 1


func _layout_mark(number_text: String) -> void:
	if _mark == null:
		return
	var beside: bool = kind == "DEFEAT" and number_text.is_valid_int()
	if beside:
		_mark.offset_left = -40
		_mark.offset_top = -16
		_mark.offset_right = -8
		_mark.offset_bottom = 16
	else:
		_mark.offset_left = -18
		_mark.offset_top = -18
		_mark.offset_right = 18
		_mark.offset_bottom = 18


func set_rim_glow(on: bool) -> void:
	_rim_glow = on
	_apply_style(_hot)


func set_draft_glow(on: bool) -> void:
	_glow = on
	set_process(_want_process())
	if not on and not _playable and not _aura and not _danger:
		_glow_t = 0.0
		if not spent:
			modulate = Color.WHITE
	_apply_style(_hot)


func set_log_focus(on: bool) -> void:
	_log_focus = on
	set_process(_want_process())
	if not on and not _glow and not _playable and not _aura and not _danger:
		_glow_t = 0.0
		if not spent:
			modulate = Color.WHITE
	_apply_style(_hot)


func set_aura(on: bool) -> void:
	_aura = on
	set_process(_want_process())
	if not on and not _glow and not _playable and not _log_focus and not _danger:
		_glow_t = 0.0
		if not spent:
			modulate = Color.WHITE
	_apply_style(_hot)


func set_danger(on: bool) -> void:
	_danger = on
	set_process(_want_process())
	if not on and not _glow and not _playable and not _aura and not _log_focus:
		_glow_t = 0.0
		if not spent:
			modulate = Color.WHITE
	_apply_style(_hot)


func set_passive_icons(plus_tex: Texture2D, ban_tex: Texture2D, on: bool) -> void:
	if _plus != null:
		_plus.texture = plus_tex
		_plus.visible = on and plus_tex != null and not _formula_on
		_plus.modulate = Color("e07a7a")
	if _ban != null:
		_ban.texture = ban_tex
		_ban.visible = on and ban_tex != null and not _formula_on
		_ban.modulate = Color("e8c36a")


func set_guarding(on: bool) -> void:
	_guarding = on
	_sync_lock_shade()
	_tween_sink(not _playable and not spent and not _guarding)
	_tick_shimmer()


func set_playable(on: bool) -> void:
	_playable = on and not spent
	set_process(true)
	_sync_lock_shade()
	_apply_style(_hot)
	_tween_sink(not _playable and not spent and not _guarding)
	_tick_shimmer()


func _process(delta: float) -> void:
	_shimmer_clock += delta
	if _glow or _aura or _log_focus or _danger or _hot:
		_glow_t += delta
		_apply_style(_hot)
	_tick_shimmer()
	_tick_breathe()
	_tick_sparkle(delta)
	_place_fx()


func set_formula(bb: String) -> void:
	_formula = bb


func show_formula(on: bool) -> void:
	_formula_on = on and _formula != ""
	if _eq == null:
		return
	_eq.text = "[center]%s[/center]" % _formula
	_eq.visible = _formula_on
	var or_on: bool = _or_parts(_shown).size() == 2
	_num.visible = not _formula_on and _shown != "" and not or_on
	if _or:
		_or.visible = not _formula_on and or_on
	if _plus != null:
		_plus.visible = (not _formula_on) and _plus.texture != null
	if _ban != null:
		_ban.visible = (not _formula_on) and _ban.texture != null
	_ghost.visible = not _formula_on
	if _mark != null:
		var beside: bool = kind == "DEFEAT" and _shown.is_valid_int()
		_mark.visible = (not _formula_on) and _mark.texture != null and (_shown == "" or beside)
	_layout_atk_pip()


func _dissolve(old_s: String, new_s: String) -> void:
	_ghost.text = old_s
	_ghost.position = Vector2.ZERO
	_ghost.scale = Vector2.ONE
	_ghost.modulate = Color(1, 1, 1, 1)
	_num.text = new_s
	_num.modulate = Color(1, 1, 1, 0)
	_shown = new_s
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(_ghost, "modulate:a", 0.0, 0.2)
	tw.tween_property(_ghost, "position:y", -18.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_ghost, "scale", Vector2(1.18, 1.18), 0.2)
	tw.tween_property(_num, "modulate:a", 1.0, 0.18).set_delay(0.05)


func toss(slow: bool = false) -> void:
	var start: Vector2 = global_position
	var host: Node = get_tree().root
	reparent(host, true)
	global_position = start
	z_index = 80
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_meta("tossing", true)
	var dur: float = 1.15 if slow else 0.5
	var tw := create_tween()
	tw.set_parallel(true)
	var side: float = 1.0 if randf() > 0.5 else -1.0
	tw.tween_property(self, "global_position", start + Vector2(side * 260.0, -210.0), dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "rotation", side * 1.35, dur)
	tw.tween_property(self, "modulate:a", 0.0, dur)
	tw.finished.connect(queue_free, CONNECT_ONE_SHOT)
	await tw.finished
	if is_instance_valid(self):
		queue_free()


func bounce() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.12, 1.12), 0.08)
	tw.tween_property(self, "scale", Vector2.ONE, 0.12)


func play_transform() -> void:
	pivot_offset = size * 0.5
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(0.12, 1.22), 0.10)
	tw.parallel().tween_property(self, "modulate", Color(0.72, 0.28, 1.0), 0.10)
	tw.tween_property(self, "scale", Vector2(1.18, 1.18), 0.12)
	tw.parallel().tween_property(self, "modulate", Color(1.0, 0.92, 0.55), 0.12)
	tw.tween_property(self, "scale", Vector2.ONE, 0.10)
	tw.parallel().tween_property(self, "modulate", Color.WHITE, 0.10)


func _apply_style(hot: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = _fill.lightened(0.10) if hot else _fill
	var metal: Color = _rim.lightened(0.18) if hot else _rim
	var pulse := 0.0
	if _glow:
		var period: float = 1.45 if _tier <= 1 else (1.05 if _tier == 2 else 0.72)
		pulse = 0.50 + 0.50 * absf(sin(_glow_t * TAU / period))
		metal = _rim.lerp(_tier_shine(), 0.20 + pulse * 0.55)
		sb.bg_color = _fill.lightened(0.04 if hot else 0.0)
		modulate = Color.WHITE
	elif _danger and not spent:
		pulse = 0.40 + 0.60 * absf(sin(_glow_t * TAU / 0.45))
		var blood := Color("c41e1e")
		metal = metal.lerp(blood, 0.55 + pulse * 0.45)
		sb.bg_color = sb.bg_color.lerp(blood.darkened(0.15), pulse * 0.42)
		modulate = Color.WHITE.lerp(Color("ff6a4a"), pulse * 0.55)
	elif _aura and not spent:
		pulse = 0.45 + 0.55 * absf(sin(_glow_t * TAU / 0.9))
		var ember := Color("e07a3d")
		metal = metal.lerp(ember, 0.50 + pulse * 0.50)
		sb.bg_color = sb.bg_color.lerp(ember.darkened(0.25), pulse * 0.28)
		modulate = Color.WHITE.lerp(Color("ffc48a"), pulse * 0.32)
		if _plus != null and _plus.visible:
			_plus.modulate = Color("e07a7a").lerp(Color.WHITE, pulse * 0.55)
		if _ban != null and _ban.visible:
			_ban.modulate = Color("e8c36a").lerp(Color.WHITE, pulse * 0.55)
	elif _log_focus:
		pulse = 0.55 + 0.45 * absf(sin(_glow_t * TAU / 0.8))
		var gold := Color("fff0c0")
		metal = metal.lerp(gold, 0.55 + pulse * 0.45)
		sb.bg_color = sb.bg_color.lerp(gold.darkened(0.45), pulse * 0.28)
		modulate = Color.WHITE.lerp(Color("ffe6a8"), pulse * 0.42)
	elif _playable and not spent and _hot:
		pulse = 0.35 + 0.35 * absf(sin(_glow_t * TAU / 1.6))
		metal = metal.lerp(Color("e8c36a"), pulse * 0.45)
		sb.bg_color = sb.bg_color.lightened(pulse * 0.08)
	sb.border_color = metal
	var bw: int = 3
	if _tier == 2:
		bw = 4
	elif _tier >= 3:
		bw = 5
	if hot:
		bw += 1
	if _glow:
		bw += int(pulse * float(_tier))
	elif _aura or _log_focus or _danger:
		bw += int(pulse * 2.0)
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(8 if _showcase else 6)
	if _showcase:
		bw += 1
	if _glow:
		sb.shadow_color = Color(metal.r, metal.g, metal.b, 0.42 + pulse * (0.18 + 0.12 * float(_tier)))
		sb.shadow_size = (6 if _tier <= 1 else (12 if _tier == 2 else 20)) + int(pulse * (4 + _tier * 6)) + (4 if _showcase else 0)
	else:
		sb.shadow_color = Color(metal.r, metal.g, metal.b, (0.55 if _tier >= 3 else 0.32) + pulse * 0.35)
		sb.shadow_size = (10 if _tier >= 3 else (6 if _tier == 2 else 4)) + int(pulse * 8.0) + (6 if _showcase else 0)
	sb.shadow_offset = Vector2.ZERO
	if not _rim_glow:
		sb.shadow_size = 0
		sb.shadow_color = Color(0, 0, 0, 0)
	if _showcase:
		sb.content_margin_left = 6
		sb.content_margin_right = 6
		sb.content_margin_top = 8
		sb.content_margin_bottom = 6
	else:
		sb.content_margin_left = 4
		sb.content_margin_right = 4
		sb.content_margin_top = 3
		sb.content_margin_bottom = 3
	add_theme_stylebox_override("panel", sb)
	queue_redraw()


func _draw() -> void:
	if _glow:
		var period: float = 1.45 if _tier <= 1 else (1.05 if _tier == 2 else 0.72)
		var pulse: float = 0.50 + 0.50 * absf(sin(_glow_t * TAU / period))
		var pad: float = 3.0 + float(_tier) * 4.0 + pulse * (2.0 + float(_tier) * 2.5)
		var ring_col: Color = _rim.lerp(_tier_shine(), 0.25 + pulse * 0.50)
		var ring := StyleBoxFlat.new()
		ring.draw_center = false
		ring.bg_color = Color(0, 0, 0, 0)
		ring.border_color = Color(ring_col.r, ring_col.g, ring_col.b, 0.70 + pulse * 0.25)
		ring.set_border_width_all(2 + _tier)
		ring.set_corner_radius_all(12 if _showcase else 9)
		ring.shadow_color = Color(ring_col.r, ring_col.g, ring_col.b, 0.40 + pulse * 0.28)
		ring.shadow_size = 4 + _tier * 5 + int(pulse * (3 + _tier * 3))
		ring.shadow_offset = Vector2.ZERO
		ring.draw(get_canvas_item(), Rect2(Vector2(-pad, -pad), size + Vector2(pad, pad) * 2.0))
	# Basilisk gaze countdown pips (top-right, 12px each).
	if _petrified and not _petrify_dummy and _petrify_spins > 0:
		var base := Vector2(size.x - 14.0, 10.0)
		for i in 3:
			var on: bool = i < _petrify_spins
			var p: Vector2 = base + Vector2(float(i) * -14.0, 0.0)
			var col := Color("c9b9a8") if on else Color("100e0c", 0.45)
			if on and i == _petrify_spins - 1 and _pip_flash > 0.05:
				col = col.lerp(Color.WHITE, _pip_flash)
			draw_circle(p, 6.0, Color("100e0c", 0.85))
			draw_circle(p, 4.5 if on else 3.0, col)
	if card_id == "jar_o_grease" and not spent:
		var foot := Vector2(16.0, 16.0)
		draw_circle(foot, 7.0, Color("100e0c", 0.9))
		draw_arc(foot, 5.0, 0.4, PI - 0.2, 10, Color("f0e6d8"), 1.6, true)
		draw_line(foot + Vector2(-3, 2), foot + Vector2(4, 3), Color("f0e6d8"), 1.4, true)


func _on_in() -> void:
	_hot = true
	_apply_style(true)
	_force_glint()
	pivot_offset = size * 0.5
	if spent:
		return
	if _lift != null:
		_lift.kill()
	_lift = create_tween()
	_lift.tween_property(self, "scale", Vector2(1.10, 1.10) if _showcase else Vector2(1.07, 1.07), 0.1)
	if _steal_tex != null:
		Input.set_custom_mouse_cursor(_steal_tex, Input.CURSOR_ARROW, Vector2(6, 4))
	hovered.emit()


func _on_out() -> void:
	_hot = false
	_holding = false
	_apply_style(false)
	if _lift != null:
		_lift.kill()
	_lift = create_tween()
	_lift.tween_property(self, "scale", Vector2.ONE, 0.1)
	if _steal_tex != null:
		Input.set_custom_mouse_cursor(null)
	unhovered.emit()


func _on_gui(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if OS.has_feature("editor") or PLAYTEST_FLAG.on():
				edit_wanted.emit()
			return
		if spent:
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		if event.pressed:
			_holding = true
			_press_from = event.global_position
			accept_event()
			return
		if not _holding:
			return
		_holding = false
		var delta: Vector2 = event.global_position - _press_from
		if _pass_swipe and delta.x < -78.0 and absf(delta.y) < 140.0:
			passed_swipe.emit()
		else:
			picked.emit()
		accept_event()


func sai_busy() -> bool:
	return _sai_busy


func marble_busy() -> bool:
	return _marble_busy


func set_sai_static(pair: bool) -> void:
	_sai_busy = false
	var path: String = "res://assets/dungeon/anim/sai_pair.png" if pair else "res://assets/dungeon/anim/sai_single.png"
	if ResourceLoader.exists(path) and _icon != null:
		_icon.texture = load(path) as Texture2D
		_icon.modulate.a = 1.0
	if _sai_fx != null:
		_sai_fx.visible = false
		_sai_fx.stop()


func play_sai(old_n: int, new_n: int) -> void:
	if has_meta("tossing"):
		set_sai_static(new_n == 4)
		return
	if _sai_busy or old_n == new_n:
		return
	_sai_busy = true
	clip_contents = false
	_ensure_sai_fx()
	if _icon:
		_icon.modulate.a = 0.0
	_sai_fx.visible = true
	if old_n == 4:
		_sai_fx.play_backwards("split")
	else:
		_sai_fx.play("split")
	await get_tree().create_timer(0.12).timeout
	if not is_instance_valid(self):
		return
	if _pending_live != "":
		var nxt: String = _pending_live
		_pending_live = ""
		_sai_busy = false
		set_live(nxt, "", _playable)
		_sai_busy = true
	await get_tree().create_timer(0.24).timeout
	if not is_instance_valid(self):
		return
	_sai_busy = false
	set_sai_static(new_n == 4)
	bounce()


func start_marble_idle(cats_eye: bool = false) -> void:
	if _marble_busy:
		return
	_ensure_marble_fx()
	var anim: String = "cat_idle" if cats_eye else "idle"
	if _marble_fx.sprite_frames == null or not _marble_fx.sprite_frames.has_animation(anim):
		anim = "idle"
	_marble_fx.visible = true
	_marble_fx.play(anim)
	if _icon:
		_icon.modulate.a = 0.0


func play_marble(is_atk: bool) -> void:
	if has_meta("tossing"):
		return
	_marble_busy = true
	_ensure_marble_fx()
	if _icon:
		_icon.modulate.a = 0.0
	_marble_fx.visible = true
	var swirl: String = "swirl"
	if _marble_fx.sprite_frames.has_animation("cat_swirl") and _marble_fx.animation.begins_with("cat"):
		swirl = "cat_swirl"
	if _marble_fx.sprite_frames.has_animation(swirl):
		_marble_fx.play(swirl)
		await get_tree().create_timer(0.24).timeout
	if not is_instance_valid(self):
		return
	var hold: String = "red" if is_atk else "blue"
	if _marble_fx.sprite_frames.has_animation(hold):
		_marble_fx.play(hold)
	pivot_offset = size * 0.5
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.25, 1.25), 0.06)
	tw.tween_property(self, "scale", Vector2.ONE, 0.06)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(self):
		_marble_busy = false


func marble_grow(_n: int) -> void:
	if _icon == null:
		return
	_icon.pivot_offset = _icon.size * 0.5
	var tw := create_tween()
	tw.tween_property(_icon, "scale", Vector2(1.15, 1.15), 0.08)
	tw.tween_property(_icon, "scale", Vector2.ONE, 0.08)
	if _marble_fx != null:
		tw.parallel().tween_property(_marble_fx, "scale", Vector2(2.3, 2.3), 0.08)
		tw.tween_property(_marble_fx, "scale", Vector2(2, 2), 0.08)
	var old_rim: Color = _rim
	_rim = Color.WHITE
	_apply_style(_hot)
	await get_tree().create_timer(0.16).timeout
	if is_instance_valid(self):
		_rim = old_rim
		_apply_style(_hot)


func marble_roll_in(from_global: Vector2, delay: float) -> void:
	if from_global == Vector2.ZERO:
		return
	var dest: Vector2 = global_position
	var host: Node = get_parent()
	var idx: int = get_index()
	reparent(get_tree().root, true)
	global_position = from_global - size * 0.5
	rotation = 0.85
	modulate.a = 0.25
	var tw := create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(self, "global_position", dest, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "rotation", 0.0, 0.22)
	tw.parallel().tween_property(self, "modulate:a", 1.0, 0.18)
	await tw.finished
	if not is_instance_valid(self):
		return
	if host != null and is_instance_valid(host):
		reparent(host, true)
		if idx >= 0 and idx < host.get_child_count():
			host.move_child(self, idx)
	rotation = 0.0
	modulate.a = 1.0


func set_armed(on: bool, label_key: String = "") -> void:
	_armed = on
	if _armed_lab == null:
		_armed_lab = Label.new()
		_armed_lab.name = "ArmedChip"
		_armed_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_armed_lab.add_theme_font_size_override("font_size", 11)
		_armed_lab.add_theme_color_override("font_color", Color("ffe6a8"))
		_armed_lab.add_theme_color_override("font_outline_color", Color("100e0c"))
		_armed_lab.add_theme_constant_override("outline_size", 3)
		_armed_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_armed_lab.set_anchors_preset(Control.PRESET_TOP_WIDE)
		_armed_lab.offset_top = 2
		_armed_lab.offset_bottom = 18
		add_child(_armed_lab)
	if on and label_key != "":
		_armed_lab.text = COPY.text(label_key, "Loaded" if label_key == "status.sling_loaded" else "")
		_armed_lab.visible = _armed_lab.text != ""
		if label_key == "status.sling_loaded":
			tooltip_text = COPY.text("status.sling_loaded_tip", "Loaded: your next Attack can hit any monster.")
	else:
		_armed_lab.visible = false
		if tooltip_text.begins_with("Loaded"):
			tooltip_text = ""
	_tick_shimmer()


func set_no_effect(on: bool) -> void:
	_no_effect = on
	set_petrified(on, true)
	if _stone != null and on:
		_stone.modulate = Color(0.82, 0.78, 0.70, 0.6)


func _bind_rank_fx() -> void:
	_shimmer_mat = RANK_SHIMMER.make_mat(_tier, uid, Vector2(CARD_W, CARD_H))
	material = _shimmer_mat
	_tick_shimmer()


func _tick_shimmer() -> void:
	if _shimmer_mat == null:
		return
	var desat: float = _desat
	if not _playable and not spent and not _showcase and not _guarding:
		desat = 0.6
	RANK_SHIMMER.apply(_shimmer_mat, _tier, uid, desat, 1.0 if _armed else 0.0, _shimmer_clock, size if size.x > 8.0 else Vector2(CARD_W, CARD_H))


func _force_glint() -> void:
	_shimmer_clock = -RANK_SHIMMER.phase_of(uid, _tier)
	_tick_shimmer()


func _tween_sink(sink: bool) -> void:
	var target: Color = Color(0.70, 0.70, 0.70, 1.0) if sink else Color.WHITE
	if spent:
		target = Color(0.86, 0.84, 0.80, 1.0)
	if _glow or _aura or _log_focus or _danger:
		return
	if _stone != null and _stone.visible:
		return
	if _sink_tw != null and is_instance_valid(_sink_tw):
		_sink_tw.kill()
	_sink_tw = create_tween()
	_sink_tw.tween_property(self, "modulate", target, 0.16)
	_desat = 0.6 if sink else 0.0


func _tick_breathe() -> void:
	if _showcase or _hot or spent or not _playable or _sai_busy or _marble_busy:
		return
	pivot_offset = size * 0.5
	var s: float = 1.0 + 0.015 * sin(_shimmer_clock * TAU * 0.5)
	scale = Vector2(s, s)


func _tick_sparkle(delta: float) -> void:
	if _tier < 3 or spent or _showcase:
		if _sparkle != null:
			_sparkle.visible = false
		return
	_ensure_sparkle()
	_sparkle_t += delta
	if _sparkle.is_playing():
		return
	if _sparkle_t < 1.2:
		return
	_sparkle_t = 0.0
	var pad := Vector2(18, 18)
	_sparkle.position = Vector2(
		pad.x + randf() * maxf(8.0, size.x - pad.x * 2.0),
		pad.y + randf() * maxf(8.0, size.y - pad.y * 2.0)
	)
	_sparkle.visible = true
	_sparkle.play("spark")


func _place_fx() -> void:
	var mid: Vector2 = _icon_center()
	if _sai_fx != null:
		_sai_fx.position = mid
	if _marble_fx != null:
		_marble_fx.position = mid


func _icon_center() -> Vector2:
	if _icon == null:
		return size * 0.5
	return _icon.position + _icon.size * 0.5


func _ensure_sai_fx() -> void:
	if _sai_fx != null:
		return
	_sai_fx = AnimatedSprite2D.new()
	_sai_fx.name = "SaiFx"
	_sai_fx.centered = true
	_sai_fx.scale = Vector2(2, 2)
	_sai_fx.texture_filter = TEXTURE_FILTER_NEAREST
	_sai_fx.visible = false
	_sai_fx.sprite_frames = _sai_frames()
	add_child(_sai_fx)


func _ensure_marble_fx() -> void:
	if _marble_fx != null:
		return
	_marble_fx = AnimatedSprite2D.new()
	_marble_fx.name = "MarbleFx"
	_marble_fx.centered = true
	_marble_fx.scale = Vector2(2, 2)
	_marble_fx.texture_filter = TEXTURE_FILTER_NEAREST
	_marble_fx.visible = false
	_marble_fx.sprite_frames = _marble_frames()
	add_child(_marble_fx)


func _ensure_sparkle() -> void:
	if _sparkle != null:
		return
	_sparkle = AnimatedSprite2D.new()
	_sparkle.name = "Sparkle"
	_sparkle.centered = true
	_sparkle.scale = Vector2(4, 4)
	_sparkle.texture_filter = TEXTURE_FILTER_NEAREST
	_sparkle.visible = false
	_sparkle.z_index = 4
	_sparkle.sprite_frames = _sparkle_frames()
	add_child(_sparkle)


func _sai_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.add_animation("split")
	sf.set_animation_speed("split", 1.0 / 0.045)
	sf.set_animation_loop("split", false)
	for i in range(8):
		var t := _anim_tex("res://assets/dungeon/anim/sai_split_f%d.png" % i)
		if t:
			sf.add_frame("split", t)
	return sf


func _marble_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_loop(sf, "idle", "res://assets/dungeon/anim/marble_idle_f%d.png", 4, 1.0 / 0.18)
	_add_loop(sf, "cat_idle", "res://assets/dungeon/anim/marble_cat_idle_f%d.png", 4, 1.0 / 0.18)
	_add_once(sf, "swirl", "res://assets/dungeon/anim/marble_swirl_f%d.png", 6, 1.0 / 0.04)
	_add_still(sf, "red", "res://assets/dungeon/anim/marble_red.png")
	_add_still(sf, "blue", "res://assets/dungeon/anim/marble_blue.png")
	return sf


func _sparkle_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_once(sf, "spark", "res://assets/ui/anim/deadly_sparkle_f%d.png", 4, 1.0 / 0.08)
	return sf


func _add_loop(sf: SpriteFrames, anim: String, pattern: String, n: int, fps: float) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, true)
	for i in range(n):
		var t := _anim_tex(pattern % i)
		if t:
			sf.add_frame(anim, t)


func _add_once(sf: SpriteFrames, anim: String, pattern: String, n: int, fps: float) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, false)
	for i in range(n):
		var t := _anim_tex(pattern % i)
		if t:
			sf.add_frame(anim, t)


func _add_still(sf: SpriteFrames, anim: String, path: String) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, 1.0)
	sf.set_animation_loop(anim, false)
	var t := _anim_tex(path)
	if t:
		sf.add_frame(anim, t)


func _anim_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null
