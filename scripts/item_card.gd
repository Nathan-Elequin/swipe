extends PanelContainer
## Named card. Icon + live number. Shift shows the hover equation in the number slot.

signal picked
signal hovered
signal unhovered
signal edit_wanted
signal passed_swipe

const CARD_W := 118.0
const CARD_H := 162.0
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
var _icon: TextureRect
var _title: Label
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
var _hot: bool = false
var _showcase: bool = false
var _ability: RichTextLabel
var _col: VBoxContainer
var _num_host: Control
var _steal_tex: Texture2D
var _press_from: Vector2 = Vector2.ZERO
var _holding: bool = false
var _echo_mark: TextureRect
var _stone: TextureRect
var _playable: bool = false
var _hatch: Control
var _aura: bool = false
var _log_focus: bool = false
var _plus: TextureRect
var _ban: TextureRect


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
	pad.add_theme_constant_override("margin_left", 6)
	pad.add_theme_constant_override("margin_right", 6)
	pad.add_theme_constant_override("margin_top", 5)
	pad.add_theme_constant_override("margin_bottom", 5)
	add_child(pad)
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 1)
	pad.add_child(col)
	_col = col

	_rank = Label.new()
	_rank.visible = false
	_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rank.autowrap_mode = TextServer.AUTOWRAP_WORD
	_rank.max_lines_visible = 2
	_rank.custom_minimum_size = Vector2(104, 0)
	_rank.add_theme_font_size_override("font_size", 12)
	_rank.add_theme_color_override("font_color", Color("c4a574"))
	_rank.add_theme_color_override("font_outline_color", Color("100e0c"))
	_rank.add_theme_constant_override("outline_size", 3)
	_rank.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_title = Label.new()
	_title.text = title
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD
	_title.max_lines_visible = 2
	_title.custom_minimum_size = Vector2(104, 38)
	_title.add_theme_font_size_override("font_size", 14)
	_title.add_theme_color_override("font_color", Color("f0e6d8"))
	_title.add_theme_color_override("font_outline_color", Color("100e0c"))
	_title.add_theme_constant_override("outline_size", 3)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_title)
	col.add_child(_rank)

	_icon = TextureRect.new()
	_icon.texture = icon
	_icon.custom_minimum_size = Vector2(64, 64)
	_icon.texture_filter = TEXTURE_FILTER_NEAREST
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_icon)

	var num_host := Control.new()
	num_host.custom_minimum_size = Vector2(104, 44)
	num_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(num_host)
	_num_host = num_host

	_mark = TextureRect.new()
	_mark.texture = mark
	_mark.visible = mark != null and number_text == ""
	_mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mark.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_mark.offset_left = -18
	_mark.offset_top = -18
	_mark.offset_right = 18
	_mark.offset_bottom = 18
	num_host.add_child(_mark)

	_ghost = Label.new()
	_ghost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ghost.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ghost.add_theme_font_size_override("font_size", 32)
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
	_num.add_theme_font_size_override("font_size", 32)
	_num.add_theme_color_override("font_color", _num_col)
	_num.add_theme_color_override("font_outline_color", Color("100e0c"))
	_num.add_theme_constant_override("outline_size", 3)
	_num.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_num.mouse_filter = Control.MOUSE_FILTER_IGNORE
	num_host.add_child(_num)

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
	_eq.add_theme_font_size_override("normal_font_size", 13)
	_eq.add_theme_font_size_override("bold_font_size", 13)
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
	_shown = number_text
	_sync_hatch()


func _sync_hatch() -> void:
	var on: bool = card_id == "spider_egg"
	if not on:
		if _hatch != null:
			_hatch.visible = false
		return
	if _hatch == null:
		_hatch = Control.new()
		_hatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	_echo_mark.modulate = Color(1, 1, 1, 0.82)


func set_petrified(on: bool) -> void:
	if _stone == null:
		_stone = TextureRect.new()
		_stone.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_stone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_stone.stretch_mode = TextureRect.STRETCH_SCALE
		_stone.texture_filter = TEXTURE_FILTER_NEAREST
		_stone.texture = load("res://assets/dungeon/ui/petrify_stone.png") as Texture2D
		_stone.modulate = Color(0.82, 0.78, 0.70, 0.78)
		add_child(_stone)
	_stone.visible = on
	modulate = Color(0.58, 0.56, 0.52, 1.0) if on else Color.WHITE


func set_title(text: String) -> void:
	if _title == null:
		return
	_title.text = text


func set_ability_bb(bb: String) -> void:
	if _ability == null:
		return
	var raw: String = bb.strip_edges()
	_ability.text = "[center]%s[/center]" % raw
	_ability.visible = _showcase and raw != ""


func set_steal_cursor(tex: Texture2D) -> void:
	_steal_tex = tex


func drop_steal_cursor() -> void:
	if _steal_tex != null:
		Input.set_custom_mouse_cursor(null)


func set_showcase(on: bool) -> void:
	_showcase = on
	custom_minimum_size = Vector2(SHOW_W, SHOW_H) if on else Vector2(CARD_W, CARD_H)
	if _title:
		_title.add_theme_font_size_override("font_size", 22 if on else 14)
		_title.custom_minimum_size = Vector2(196 if on else 104, 48 if on else 38)
		_title.max_lines_visible = 2
	if _rank:
		_rank.visible = false
		_rank.add_theme_font_size_override("font_size", 15 if on else 12)
		_rank.custom_minimum_size = Vector2(196 if on else 104, 0)
	if _icon:
		_icon.custom_minimum_size = Vector2(128, 128) if on else Vector2(64, 64)
	if _num_host:
		_num_host.custom_minimum_size = Vector2(196, 58) if on else Vector2(104, 44)
	if _num:
		_num.add_theme_font_size_override("font_size", 48 if on else 32)
	if _ghost:
		_ghost.add_theme_font_size_override("font_size", 48 if on else 32)
	if _eq:
		_eq.add_theme_font_size_override("normal_font_size", 16 if on else 13)
		_eq.add_theme_font_size_override("bold_font_size", 16 if on else 13)
	if _ability:
		_ability.add_theme_font_size_override("normal_font_size", 15 if on else 13)
		_ability.add_theme_font_size_override("bold_font_size", 15 if on else 13)
		_ability.visible = on and _ability.text.strip_edges() != "" and _ability.text != "[center][/center]"
	_apply_style(_hot)


func set_live(number_text: String, _note: String = "", can_use: bool = true) -> void:
	if _num == null:
		return
	var wordy: bool = number_text.length() > 2 and not number_text.is_valid_int()
	_num.add_theme_font_size_override("font_size", 18 if wordy else 32)
	if not _formula_on:
		_num.visible = number_text != ""
		if number_text != "" and number_text != _shown and _shown != "":
			_dissolve(_shown, number_text)
		else:
			_num.text = number_text
			_shown = number_text
	else:
		_shown = number_text
		_num.text = number_text
	if _glow or _aura or _log_focus:
		pass
	elif spent:
		modulate = Color(0.42, 0.40, 0.40, 0.55)
	elif not can_use:
		modulate = Color(0.72, 0.70, 0.68, 0.62)
	else:
		modulate = Color.WHITE
	if _mark != null and not _formula_on:
		_mark.visible = _mark.texture != null and number_text == ""
		_mark.modulate.a = 0.95


func set_rank(text: String) -> void:
	if _rank == null:
		return
	_rank.text = text
	_rank.visible = text.strip_edges() != ""


func set_palette(fill: Color, metal: Color, tier: int = 1) -> void:
	_fill = fill
	_rim = metal
	_tier = maxi(1, tier)
	_apply_style(_hot)


func set_draft_glow(on: bool) -> void:
	_glow = on
	set_process(on or _playable or _aura or _log_focus)
	if not on and not _playable and not _aura:
		_glow_t = 0.0
		if not spent:
			modulate = Color.WHITE
	_apply_style(_hot)


func set_log_focus(on: bool) -> void:
	_log_focus = on
	set_process(_glow or _playable or _aura or _log_focus)
	if not on and not _glow and not _playable and not _aura:
		_glow_t = 0.0
		if not spent:
			modulate = Color.WHITE
	_apply_style(_hot)


func set_aura(on: bool) -> void:
	_aura = on
	set_process(_glow or _playable or _aura or _log_focus)
	if not on and not _glow and not _playable and not _log_focus:
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


func set_playable(on: bool) -> void:
	_playable = on
	set_process(_glow or _playable or _aura or _log_focus)
	if not on and not _glow and not _aura and not _log_focus and not spent:
		modulate = Color.WHITE
	_apply_style(_hot)


func _process(delta: float) -> void:
	if not _glow and not _playable and not _aura and not _log_focus:
		return
	_glow_t += delta
	_apply_style(_hot)


func set_formula(bb: String) -> void:
	_formula = bb


func show_formula(on: bool) -> void:
	_formula_on = on and _formula != ""
	if _eq == null:
		return
	_eq.text = "[center]%s[/center]" % _formula
	_eq.visible = _formula_on
	_num.visible = not _formula_on and _shown != ""
	if _plus != null:
		_plus.visible = (not _formula_on) and _plus.texture != null
	if _ban != null:
		_ban.visible = (not _formula_on) and _ban.texture != null
	_ghost.visible = not _formula_on
	if _mark != null:
		_mark.visible = (not _formula_on) and _mark.texture != null and _shown == ""


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


func toss() -> void:
	var start: Vector2 = global_position
	var host: Node = get_tree().root
	reparent(host, true)
	global_position = start
	z_index = 80
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_meta("tossing", true)
	var tw := create_tween()
	tw.set_parallel(true)
	var side: float = 1.0 if randf() > 0.5 else -1.0
	tw.tween_property(self, "global_position", start + Vector2(side * 260.0, -210.0), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "rotation", side * 1.35, 0.5)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	tw.finished.connect(queue_free, CONNECT_ONE_SHOT)
	await tw.finished
	if is_instance_valid(self):
		queue_free()


func bounce() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.12, 1.12), 0.08)
	tw.tween_property(self, "scale", Vector2.ONE, 0.12)


func _apply_style(hot: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = _fill.lightened(0.10) if hot else _fill
	var metal: Color = _rim.lightened(0.18) if hot else _rim
	var pulse := 0.0
	if _glow:
		pulse = 0.50 + 0.50 * absf(sin(_glow_t * TAU / 1.2))
		var gold := Color("e8c36a")
		metal = metal.lerp(gold, 0.45 + pulse * 0.55)
		sb.bg_color = sb.bg_color.lerp(gold.darkened(0.35), pulse * 0.22)
		modulate = Color.WHITE.lerp(Color("ffe6a8"), pulse * 0.38)
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
	elif _playable and not spent:
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
	if _glow or _aura or _log_focus:
		bw += int(pulse * 2.0)
	sb.set_border_width_all(bw)
	sb.set_corner_radius_all(8 if _showcase else 6)
	if _showcase:
		bw += 1
	sb.shadow_color = Color(metal.r, metal.g, metal.b, (0.55 if _tier >= 3 else 0.32) + pulse * 0.35)
	sb.shadow_size = (10 if _tier >= 3 else (6 if _tier == 2 else 4)) + int(pulse * 8.0) + (6 if _showcase else 0)
	sb.shadow_offset = Vector2.ZERO
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 8
	sb.content_margin_bottom = 6
	add_theme_stylebox_override("panel", sb)


func _on_in() -> void:
	_hot = true
	_apply_style(true)
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
			if OS.has_feature("editor"):
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
		if _showcase and delta.x < -78.0 and absf(delta.y) < 140.0:
			passed_swipe.emit()
		else:
			picked.emit()
		accept_event()
