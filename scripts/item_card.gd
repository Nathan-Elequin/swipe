extends PanelContainer
## Named card. Icon + live number. Shift shows the hover equation in the number slot.

signal picked
signal hovered
signal unhovered
signal edit_wanted
signal passed_swipe
## Legacy Look C tag click (unused by Look H overlay). Kept so old connects stay safe.
signal mode_option_picked(opt: Dictionary)

const COPY := preload("res://scripts/player_copy.gd")
const PLAYTEST_FLAG := preload("res://scripts/playtest_flag.gd")
const RANK_SHIMMER := preload("res://scripts/rank_shimmer.gd")
const FX_BUDGET := preload("res://scripts/combat_fx_budget.gd")
## H3-B2: bigger 2×5 hotbar (reclaims old standalone Take row).
const CARD_W := 172.0
const CARD_H := 148.0
const SHOW_W := 236.0
const SHOW_H := 340.0
## Idle stack retune (2026-11-02 Nathan F5 after #297). On the 172×148 plate:
## title ~+50% vs post-#297 idle (font 14→21, title_h 16→24), sprite stays 58
## but nudged lower (IDLE_SPRITE_NUDGE) to close the gap above effect icons,
## face glyphs ~+20% (36→43) still vertically centered in the leftover band.
## Brand New / uncollected draft_glow shine is OFF (matte plates; aura kit stays).
const IDLE_CONTENT_MARGIN_TOP := 1
const IDLE_PAD_TOP := 1
const IDLE_TITLE_H := 24.0
const IDLE_TITLE_FONT_MAX := 21
const IDLE_TITLE_FONT_MIN := 15
const IDLE_ICON := 58.0
## Extra px under the title so the sprite sits closer to the face band.
const IDLE_SPRITE_NUDGE := 4
const IDLE_FACE_HOST_MIN_H := 46.0

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
var _curse: bool = false
## Phantom Dark Matter: full black curse veil — identity hidden, still clickable.
var _shrouded: bool = false
var _shroud_anim: bool = false
var _shroud_haze: Control
var _shroud_mark: Label
var _tier: int = 1
var _num_col: Color = Color.WHITE
var _shown: String = ""
var _edge_on: bool = false
var _edge_old: String = ""
var _edge_new: String = ""
var _pulse_tw: Tween
var _legal_known: bool = false
var _legal_now: bool = false
var _lift: Tween
var _formula: String = ""
var _formula_on: bool = false
var _glow: bool = false
var _glow_t: float = 0.0
var _style_wait: float = 0.0
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
var _chrome: Control
## Direction A aura kit (design/visual/SCREEN-hotbar-aura-kit.md).
## Priority when painting rings: Petrify/Unplayable > WARN > CHOICE > READY.
const AURA_OFF := ""
const AURA_READY := "ready"
const AURA_WARN := "warn"
const AURA_CHOICE := "choice"
const COL_READY := Color("F2A93B")
const COL_WARN := Color("E8553E")
const COL_CHOICE := Color("7CC8F0")
const COL_LINK := Color("8E72F2")
const COL_HEX_GOOD := Color("5FD3A0")
const COL_TOLL_LETHAL := Color("C41E1E")
const COL_GARGOYLE := Color("B9A58A")
const COL_BASILISK := Color("9DB86E")
const COL_UNPLAYABLE := Color("8A8F96")
var _aura: bool = false
var _aura_role: String = AURA_OFF
var _toss_pick: bool = false
## Merchant is offering to replace this item. Hover draws gold rising marks.
var _upgrade_offer: bool = false
var _log_focus: bool = false
var _plus: TextureRect
var _ban: TextureRect
var _used: Label
var _danger: bool = false
var _hex_good: bool = false
var _bag_stamp: TextureRect
var _source_stamp: TextureRect
var _duration_band: TextureRect
var _decay_overlay: Control
var _decay_pip: TextureRect
var _decay_chain: TextureRect
var _warn_chip: Label
var _gaze_mark: TextureRect
var _gaze_warn: bool = false
var _decay_link: bool = false
var _decay_warn: bool = false
var _decay_solo: bool = false
## -1 = chain on left edge toward partner, +1 = right edge. 0 = hide chain.
var _decay_chain_side: int = 0
var _gaze_entry: bool = false
var _petrify_source: String = "" # "" | "gargoyle" | "basilisk"
var _aura_pulse_tw: Tween
var _or: RichTextLabel
var _choice_badge: Label
var _cabinet_badge: Label
var _beggar_on: bool = false
var _beggar_lab: Label
var _beggar_icon: TextureRect
var _beggar_flash: float = 0.0
var _beggar_punch: Tween
var _hp_cost: HBoxContainer
var _face: Control
var _glyph_rows: Array = []
var _sai_fx: AnimatedSprite2D
var _marble_fx: AnimatedSprite2D
var _sparkle: AnimatedSprite2D
## Draft pick stamps (assets/ui/draft/). Overlay only — not the gate door.
var _draft_stamp_fx: AnimatedSprite2D
var _recycle_return_fx: AnimatedSprite2D
var _shimmer_mat: ShaderMaterial
var _shimmer_clock: float = 0.0
var _sai_busy: bool = false
var _marble_busy: bool = false
var _pending_live: String = ""
var _armed: bool = false
var _armed_lab: Label
var _cancel_pick: bool = false
## Look H mode choose: park the cancel X at the top-right corner (mock H1/H2).
var _cancel_corner: bool = false
var _selector_dim: bool = false
var _cancel_x: TextureRect
var _cancel_disc: ColorRect
var _selector_veil: Control
## Look C in-chrome tags — cleared always under Look H; stubs keep old calls safe.
var _mode_tag_box: VBoxContainer
var _mode_tag_rows: Array = []
var _mode_tags_on: bool = false
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
var _waiting_entry: bool = false
var _wait_base_y: float = 0.0


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
	pad.add_theme_constant_override("margin_top", IDLE_PAD_TOP)
	pad.add_theme_constant_override("margin_bottom", 3)
	add_child(pad)
	var col := VBoxContainer.new()
	## Top-align so title sits near the plate edge; face host expands below the sprite.
	col.alignment = BoxContainer.ALIGNMENT_BEGIN
	col.add_theme_constant_override("separation", 1)
	pad.add_child(col)
	_col = col
	# Overlays live under `pad` so PanelContainer does not stretch them to the
	# full card (that was the giant G / giant Beggar portrait).
	_chrome = Control.new()
	_chrome.name = "Chrome"
	_chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(_chrome)

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
	_title.max_font_size = IDLE_TITLE_FONT_MAX
	_title.min_font_size = IDLE_TITLE_FONT_MIN
	_title.set_plain(title)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.custom_minimum_size = Vector2(CARD_W - 14.0, IDLE_TITLE_H)
	_title.font_color = Color("f0e6d8")
	_title.set_outline(Color("100e0c"), 3)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_title)
	col.add_child(_rank)

	## Nudge sprite slightly lower without changing sprite size (closes idle gap above face).
	if IDLE_SPRITE_NUDGE > 0:
		var sprite_gap := Control.new()
		sprite_gap.name = "SpriteNudge"
		sprite_gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sprite_gap.custom_minimum_size = Vector2(0, IDLE_SPRITE_NUDGE)
		col.add_child(sprite_gap)

	_icon = TextureRect.new()
	_icon.texture = icon
	_icon.custom_minimum_size = Vector2(IDLE_ICON, IDLE_ICON)
	_icon.texture_filter = TEXTURE_FILTER_NEAREST
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_icon)
	if p_id == "shuriken" or p_id == "swift_sneaks":
		var arc := preload("res://scripts/move_arc_icon.gd").new()
		arc.name = "MoveArc"
		_icon.add_child(arc)

	var num_host := Control.new()
	num_host.custom_minimum_size = Vector2(CARD_W - 14.0, IDLE_FACE_HOST_MIN_H)
	num_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	_overlay_host().add_child(_used)
	_face = preload("res://scripts/item_face.gd").new()
	_face.name = "Face"
	_face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_face.visible = false
	## Explicit mode — do not infer offer from host height (idle host now expands).
	if _face.has_method("set_offer_mode"):
		_face.set_offer_mode(false)
	num_host.add_child(_face)
	set_live(number_text, "", true)
	_sync_hatch()
	_sync_lock_shade()
	_bind_rank_fx()
	set_process(true)


func _overlay_host() -> Control:
	if _chrome != null:
		return _chrome
	return self


func _sync_hatch() -> void:
	# Spider Egg keeps its soft hatch; Unplayable / Petrify use the shared 8px diagonal.
	var egg: bool = card_id == "spider_egg"
	var unplayable_hatch: bool = (not _showcase) and not _selector_dim and (
		spent
		or (_petrified and not _petrify_dummy)
		or ((not _playable) and not _toss_pick and not _guarding and not _petrify_dummy)
	)
	var on: bool = egg or unplayable_hatch
	if not on:
		if _hatch != null:
			_hatch.visible = false
		return
	if _hatch == null:
		# Clipper must be a parent Control: clip_contents clips children, not this node's own draw.
		_hatch = Control.new()
		_hatch.name = "UnplayableHatch"
		_hatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_hatch.z_index = 12
		_hatch.clip_contents = true
		_hatch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_overlay_host().add_child(_hatch)
		var drawer := Control.new()
		drawer.name = "HatchDraw"
		drawer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		drawer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		drawer.draw.connect(_draw_card_hatch)
		drawer.resized.connect(drawer.queue_redraw)
		_hatch.add_child(drawer)
	_hatch.visible = true
	var drawer_n: Node = _hatch.get_node_or_null("HatchDraw")
	if drawer_n is Control:
		(drawer_n as Control).queue_redraw()


func _draw_card_hatch() -> void:
	if _hatch == null:
		return
	var drawer: Control = _hatch.get_node_or_null("HatchDraw") as Control
	if drawer == null:
		drawer = _hatch
	var w: float = drawer.size.x
	var h: float = drawer.size.y
	if w < 2.0 or h < 2.0:
		return
	if card_id == "spider_egg" and not (_petrified and not _petrify_dummy) and not spent:
		drawer.draw_rect(Rect2(0, 0, w, h * 0.42), Color(1, 1, 1, 0.06))
		drawer.draw_rect(Rect2(0, h * 0.58, w, h * 0.42), Color(0, 0, 0, 0.28))
		var egg_ink := Color(0.92, 0.78, 0.72, 0.18)
		var ex: float = -h
		while ex < w + h:
			drawer.draw_line(Vector2(ex, h), Vector2(ex + h * 0.65, 0.0), egg_ink, 1.0)
			ex += 6.0
		return
	# Direction A Unplayable / Petrify: grey wash + 8px diagonal hatch.
	drawer.draw_rect(Rect2(0, 0, w, h), Color(COL_UNPLAYABLE.r, COL_UNPLAYABLE.g, COL_UNPLAYABLE.b, 0.22))
	var ink := Color(0.10, 0.08, 0.07, 0.36)
	var x: float = -h
	while x < w + h:
		drawer.draw_line(Vector2(x, h), Vector2(x + h * 0.58, 0.0), ink, 1.5)
		x += 8.0


func _sync_lock_shade() -> void:
	# Hatch covers Unplayable + Petrify now; lock shade stays as a light wash for spent/grey only.
	# Selector dim uses its own veil — do not stack the 12% unplayable wash.
	if _selector_dim:
		if _lock_shade != null:
			_lock_shade.visible = false
		_sync_hatch()
		_sync_selector_veil()
		return
	if _selector_veil != null:
		_selector_veil.visible = false
	var locked: bool = (not _showcase) and (spent or not _playable) and not _guarding and not (_petrified and not _petrify_dummy)
	_sync_hatch()
	if not locked:
		if _lock_shade != null:
			_lock_shade.visible = false
		return
	if _lock_shade == null:
		_lock_shade = Control.new()
		_lock_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_lock_shade.z_index = 11
		_lock_shade.clip_contents = true
		_lock_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_lock_shade.draw.connect(_draw_lock_shade)
		_lock_shade.resized.connect(func() -> void:
			if _lock_shade != null:
				_lock_shade.queue_redraw()
		)
		_overlay_host().add_child(_lock_shade)
	_lock_shade.visible = true
	if _used != null:
		var used_host: Node = _used.get_parent()
		if used_host != null:
			used_host.move_child(_used, used_host.get_child_count() - 1)
	_lock_shade.queue_redraw()


func _draw_lock_shade() -> void:
	if _lock_shade == null:
		return
	var w: float = _lock_shade.size.x
	var h: float = _lock_shade.size.y
	if w < 2.0 or h < 2.0:
		return
	# Soft wash only — diagonal hatch lives on `_hatch` so Petrify shares Unplayable language.
	_lock_shade.draw_rect(Rect2(0, 0, w, h), Color(0.07, 0.05, 0.04, 0.12))


func set_icon(tex: Texture2D) -> void:
	if _icon == null:
		return
	if _sai_busy or _marble_busy:
		return
	_icon.texture = tex


func set_gaze_mark(tex: Texture2D, on: bool) -> void:
	## Entry Gaze eye glyph — centered on the top edge (Phase A).
	_gaze_entry = on and not (_petrified and _petrify_source == "basilisk")
	if not on or tex == null:
		if _gaze_mark:
			_gaze_mark.visible = false
		queue_redraw()
		return
	if _gaze_mark == null:
		_gaze_mark = TextureRect.new()
		_gaze_mark.name = "BasiliskGaze"
		_gaze_mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_gaze_mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_gaze_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_gaze_mark.texture_filter = TEXTURE_FILTER_NEAREST
		_gaze_mark.z_index = 8
		_gaze_mark.set_anchors_preset(Control.PRESET_CENTER_TOP)
		_gaze_mark.offset_left = -12
		_gaze_mark.offset_top = -6
		_gaze_mark.offset_right = 12
		_gaze_mark.offset_bottom = 18
		_overlay_host().add_child(_gaze_mark)
	_gaze_mark.texture = tex
	_gaze_mark.visible = _gaze_entry
	queue_redraw()


func set_gaze_warn(on: bool) -> void:
	_gaze_warn = on
	if on:
		set_aura_role(AURA_WARN)
		_set_warn_chip("Will be Petrified.")
	else:
		_clear_warn_chip_if("Will be Petrified.")
		if _aura_role == AURA_WARN and not _decay_warn and not _beggar_on:
			# Caller re-applies READY/CHOICE/off after clearing.
			pass
	queue_redraw()


func set_decay_link(on: bool, chain_side: int = -1) -> void:
	## LINK pair idle: thin violet ring + TL pip + chain toward partner.
	## chain_side: -1 left edge, +1 right edge, 0 no chain glyph.
	_decay_link = on
	if on:
		_decay_solo = false
		_decay_chain_side = chain_side if chain_side != 0 else -1
	else:
		_decay_chain_side = 0
	_ensure_decay_pip()
	_ensure_decay_chain()
	_sync_decay_markers()
	_apply_style(_hot)
	queue_redraw()


func set_decay_solo(on: bool) -> void:
	## Solo Decay mark: TL pip + thin violet rim only — never a purple wash.
	_decay_solo = on
	if on:
		_decay_link = false
		_decay_chain_side = 0
	_ensure_decay_pip()
	_ensure_decay_chain()
	_sync_decay_markers()
	_apply_style(_hot)
	queue_redraw()


func set_decay_warn(on: bool) -> void:
	_decay_warn = on
	if on:
		set_aura_role(AURA_WARN)
		_set_warn_chip("Will be discarded.")
	else:
		_clear_warn_chip_if("Will be discarded.")
	_sync_decay_markers()
	queue_redraw()


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
			_overlay_host().add_child(_bag_stamp)
	_bag_stamp.texture = tex
	_bag_stamp.visible = true


func set_source_stamp(source: String) -> void:
	## Keep the source id for rims / shatter. Do not draw the letter G/B stamps —
	## Petrify reads as Unplayable hatch + stone, not a giant monogram.
	_petrify_source = source
	if _source_stamp:
		_source_stamp.visible = false
	if _duration_band:
		_duration_band.visible = false
	if source == "basilisk" and _gaze_mark != null:
		_gaze_mark.visible = false
		_gaze_entry = false
	queue_redraw()


func _ensure_source_stamp() -> void:
	if _source_stamp != null:
		return
	_source_stamp = TextureRect.new()
	_source_stamp.name = "SourceStamp"
	_source_stamp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_source_stamp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_source_stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_source_stamp.texture_filter = TEXTURE_FILTER_NEAREST
	_source_stamp.z_index = 10
	_source_stamp.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_source_stamp.offset_left = -36
	_source_stamp.offset_top = -36
	_source_stamp.offset_right = -2
	_source_stamp.offset_bottom = -2
	_overlay_host().add_child(_source_stamp)


func _ensure_duration_band() -> void:
	if _duration_band != null:
		return
	_duration_band = TextureRect.new()
	_duration_band.name = "DurationBand"
	_duration_band.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_duration_band.stretch_mode = TextureRect.STRETCH_SCALE
	_duration_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_duration_band.texture_filter = TEXTURE_FILTER_NEAREST
	_duration_band.z_index = 7
	_duration_band.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_duration_band.offset_left = 4
	_duration_band.offset_top = 2
	_duration_band.offset_right = -4
	_duration_band.offset_bottom = 10
	_duration_band.visible = false
	_overlay_host().add_child(_duration_band)


func _ensure_decay_overlay() -> void:
	## PanelContainer stretches direct TextureRect children to fill the card.
	## Host pip/chain on a plain Control so anchors/size stick (tiny TL diamond + edge chain).
	if _decay_overlay != null:
		return
	_decay_overlay = Control.new()
	_decay_overlay.name = "DecayOverlay"
	_decay_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_decay_overlay.clip_contents = false
	_decay_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_decay_overlay.z_index = 8
	add_child(_decay_overlay)
	if not resized.is_connected(_place_decay_chain):
		resized.connect(_place_decay_chain)


func _ensure_decay_pip() -> void:
	if _decay_pip != null:
		return
	_ensure_decay_overlay()
	_decay_pip = TextureRect.new()
	_decay_pip.name = "DecayPip"
	_decay_pip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_decay_pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_decay_pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_decay_pip.texture_filter = TEXTURE_FILTER_NEAREST
	_decay_pip.z_index = 9
	_decay_pip.custom_minimum_size = Vector2(12, 12)
	_decay_pip.modulate = Color(1, 1, 1, 0.9)
	_decay_pip.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_decay_pip.offset_left = 2
	_decay_pip.offset_top = 2
	_decay_pip.offset_right = 14
	_decay_pip.offset_bottom = 14
	if ResourceLoader.exists("res://assets/ui/aura/decay_pip.png"):
		_decay_pip.texture = load("res://assets/ui/aura/decay_pip.png") as Texture2D
	_decay_pip.visible = false
	_decay_overlay.add_child(_decay_pip)


func _ensure_decay_chain() -> void:
	if _decay_chain != null:
		return
	_ensure_decay_overlay()
	_decay_chain = TextureRect.new()
	_decay_chain.name = "DecayChain"
	_decay_chain.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_decay_chain.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_decay_chain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_decay_chain.texture_filter = TEXTURE_FILTER_NEAREST
	_decay_chain.z_index = 8
	_decay_chain.custom_minimum_size = Vector2(24, 12)
	if ResourceLoader.exists("res://assets/ui/aura/decay_chain.png"):
		_decay_chain.texture = load("res://assets/ui/aura/decay_chain.png") as Texture2D
	_decay_chain.visible = false
	_decay_overlay.add_child(_decay_chain)


func _sync_decay_markers() -> void:
	var show_pip: bool = (_decay_link or _decay_solo or _decay_warn) and not spent
	if _decay_pip != null:
		_decay_pip.visible = show_pip
	var show_chain: bool = (_decay_link or _decay_warn) and not _decay_solo and not spent and _decay_chain_side != 0
	if _decay_chain != null:
		_decay_chain.visible = show_chain
		if show_chain:
			_place_decay_chain()


func _place_decay_chain() -> void:
	## 24×12 link glyph, mid-edge toward partner — half off the plate, not over icon center.
	if _decay_chain == null:
		return
	var w: float = 24.0
	var h: float = 12.0
	var sx: float = size.x if size.x > 1.0 else CARD_W
	var sy: float = size.y if size.y > 1.0 else CARD_H
	var cy: float = sy * 0.5
	_decay_chain.size = Vector2(w, h)
	if _decay_chain_side >= 1:
		_decay_chain.position = Vector2(sx - w * 0.5, cy - h * 0.5)
	else:
		_decay_chain.position = Vector2(-w * 0.5, cy - h * 0.5)


func _set_warn_chip(text: String) -> void:
	if _warn_chip == null:
		_warn_chip = Label.new()
		_warn_chip.name = "WarnChip"
		_warn_chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_warn_chip.add_theme_font_size_override("font_size", 10)
		_warn_chip.add_theme_color_override("font_color", Color("f0e6d8"))
		_warn_chip.add_theme_color_override("font_outline_color", Color("100e0c"))
		_warn_chip.add_theme_constant_override("outline_size", 3)
		_warn_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_warn_chip.z_index = 12
		_warn_chip.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		_warn_chip.offset_top = -18
		_warn_chip.offset_bottom = -2
		_overlay_host().add_child(_warn_chip)
	_warn_chip.text = text
	_warn_chip.visible = text != ""


func _clear_warn_chip_if(text: String) -> void:
	if _warn_chip != null and _warn_chip.text == text:
		_warn_chip.visible = false
		_warn_chip.text = ""


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
		_overlay_host().add_child(_echo_mark)
	_echo_mark.texture = tex
	_echo_mark.visible = tex != null
	_echo_mark.modulate = Color(1, 1, 1, 0.42)


func set_num_color(c: Color) -> void:
	_num_col = c
	if _num:
		_num.add_theme_color_override("font_color", c)
	if _ghost:
		_ghost.add_theme_color_override("font_color", c)


func set_petrified(on: bool, dummy: bool = false, spins_left: int = 0, animate: bool = true, source: String = "") -> void:
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
		set_source_stamp("")
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
		set_source_stamp("")
		_sync_lock_shade()
		queue_redraw()
		return
	# Real petrify: stone grain on the art + Unplayable hatch + grey. No letter stamp.
	material = null
	var src: String = source
	if src == "":
		src = _petrify_source if _petrify_source != "" else "gargoyle"
	set_source_stamp(src)
	set_aura_role(AURA_OFF)
	_show_stone_overlay(true)
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
		_show_stone_overlay(true)
		modulate = Color(0.58, 0.56, 0.52, 1.0)
		_sync_lock_shade()
		queue_redraw()
	else:
		if _icon != null and _petrify_mat != null:
			_icon.material = _petrify_mat
		_petrify_creep = 1.0
		modulate = Color(0.58, 0.56, 0.52, 1.0)
		_show_stone_overlay(true)
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
	set_source_stamp("")
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
	# Brief READY flash on free (Direction A Phase D).
	set_aura_role(AURA_READY)
	await fall.finished
	_shatter.visible = false
	_shatter.modulate.a = 1.0
	_petrified = false
	_petrify_spins = 0
	_petrify_creep = 0.0
	set_aura_role(AURA_OFF)
	_sync_lock_shade()
	queue_redraw()


func _draw_solid_ring(col: Color, width: float, pulse: float) -> void:
	var pad: float = 4.0 + pulse * 3.0
	var ring := StyleBoxFlat.new()
	ring.draw_center = false
	ring.bg_color = Color(0, 0, 0, 0)
	ring.border_color = Color(col.r, col.g, col.b, 0.82 + pulse * 0.18)
	ring.set_border_width_all(int(round(width)))
	ring.set_corner_radius_all(10 if _showcase else 8)
	ring.shadow_color = Color(col.r, col.g, col.b, 0.35 + pulse * 0.30)
	ring.shadow_size = 6 + int(pulse * 10.0)
	ring.shadow_offset = Vector2.ZERO
	ring.draw(get_canvas_item(), Rect2(Vector2(-pad, -pad), size + Vector2(pad, pad) * 2.0))


func _draw_link_ring(col: Color) -> void:
	## LINK / Decay — thin violet ring (~2px), CHOICE weight, no READY glow shadow.
	var pad: float = 3.0
	var ring := StyleBoxFlat.new()
	ring.draw_center = false
	ring.bg_color = Color(0, 0, 0, 0)
	ring.border_color = Color(col.r, col.g, col.b, 0.92)
	ring.set_border_width_all(2)
	ring.set_corner_radius_all(10 if _showcase else 8)
	ring.shadow_size = 0
	ring.shadow_color = Color(0, 0, 0, 0)
	ring.draw(get_canvas_item(), Rect2(Vector2(-pad, -pad), size + Vector2(pad, pad) * 2.0))


func _draw_double_ring(col: Color) -> void:
	var pad_outer: float = 5.0
	var outer := StyleBoxFlat.new()
	outer.draw_center = false
	outer.bg_color = Color(0, 0, 0, 0)
	outer.border_color = Color(col.r, col.g, col.b, 0.92)
	outer.set_border_width_all(2)
	outer.set_corner_radius_all(10 if _showcase else 8)
	outer.shadow_size = 0
	outer.draw(get_canvas_item(), Rect2(Vector2(-pad_outer, -pad_outer), size + Vector2(pad_outer, pad_outer) * 2.0))
	var pad_inner: float = 1.0
	var inner := StyleBoxFlat.new()
	inner.draw_center = false
	inner.bg_color = Color(0, 0, 0, 0)
	inner.border_color = Color(col.r, col.g, col.b, 0.75)
	inner.set_border_width_all(1)
	inner.set_corner_radius_all(8 if _showcase else 6)
	inner.shadow_size = 0
	inner.draw(get_canvas_item(), Rect2(Vector2(-pad_inner, -pad_inner), size + Vector2(pad_inner, pad_inner) * 2.0))


func _draw_dashed_ring(col: Color, width: float, _pulse: float) -> void:
	## Static dashed WARNING / Basilisk scale rim — no pulse.
	var pad: float = 4.0
	var rect := Rect2(Vector2(-pad, -pad), size + Vector2(pad, pad) * 2.0)
	var dash: float = 7.0
	var gap: float = 5.0
	var pts: PackedVector2Array = PackedVector2Array([
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
		rect.position,
	])
	for i in range(pts.size() - 1):
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		var length: float = a.distance_to(b)
		if length < 1.0:
			continue
		var dir: Vector2 = (b - a) / length
		var t: float = 0.0
		var draw_on: bool = true
		while t < length:
			var seg: float = minf(dash if draw_on else gap, length - t)
			if draw_on:
				draw_line(a + dir * t, a + dir * (t + seg), col, width)
			t += seg
			draw_on = not draw_on


func _ensure_stone() -> void:
	if _stone != null:
		return
	_stone = TextureRect.new()
	_stone.name = "PetrifyStone"
	_stone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Cover the icon only — full-card stretch read as a checker + white number strip.
	_stone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_stone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_stone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_stone.texture_filter = TEXTURE_FILTER_NEAREST
	_stone.texture = load("res://assets/dungeon/ui/petrify_stone.png") as Texture2D
	_stone.visible = false
	_stone.modulate = Color(0.86, 0.82, 0.74, 0.88)
	if _icon != null:
		_icon.add_child(_stone)
	else:
		_overlay_host().add_child(_stone)


func _show_stone_overlay(on: bool) -> void:
	_ensure_stone()
	if _stone == null:
		return
	_stone.visible = on
	# Grain over the icon only. Cover-aspect avoids the old dither-as-checker look.
	_stone.modulate = Color(0.78, 0.74, 0.66, 0.88) if on else Color(0.86, 0.82, 0.74, 0.42)


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
		_title.max_font_size = 22 if on else IDLE_TITLE_FONT_MAX
		_title.min_font_size = 12 if on else IDLE_TITLE_FONT_MIN
		_title.custom_minimum_size = Vector2(196 if on else CARD_W - 14.0, 48 if on else IDLE_TITLE_H)
		_title.max_lines = 2
		_title.fit()
	## Hide the idle-only sprite nudge in showcase; restore it when back to hotbar.
	if _col != null:
		var nudge_n: Node = _col.get_node_or_null("SpriteNudge")
		if nudge_n != null and nudge_n is Control:
			(nudge_n as Control).visible = not on
			(nudge_n as Control).custom_minimum_size = Vector2.ZERO if on else Vector2(0, IDLE_SPRITE_NUDGE)
	if _rank:
		_rank.visible = false
		_rank.add_theme_font_size_override("font_size", 15 if on else 12)
		_rank.custom_minimum_size = Vector2(196 if on else CARD_W - 14.0, 0)
	if _icon:
		_icon.custom_minimum_size = Vector2(128, 128) if on else Vector2(IDLE_ICON, IDLE_ICON)
	if _num_host:
		_num_host.custom_minimum_size = Vector2(196, 58) if on else Vector2(CARD_W - 14.0, IDLE_FACE_HOST_MIN_H)
		_num_host.size_flags_vertical = Control.SIZE_SHRINK_CENTER if on else Control.SIZE_EXPAND_FILL
	if _col != null:
		_col.alignment = BoxContainer.ALIGNMENT_CENTER if on else BoxContainer.ALIGNMENT_BEGIN
	if _face != null and _face.has_method("set_offer_mode"):
		_face.set_offer_mode(on)
		## Rebuild so hotbar 43px vs offer 48px sticks after a mode flip.
		if not _glyph_rows.is_empty() and _face.has_method("set_rows"):
			_face.set_rows(_glyph_rows)
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
	var prev_shown: String = _shown
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
			_ghost.visible = not _mode_tags_on
		_num.visible = number_text != "" and not _mode_tags_on
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
	if not _showcase and prev_shown != "" and number_text != "" and number_text != prev_shown:
		_edge_on = true
		_edge_old = prev_shown
		_edge_new = number_text
	if _mode_tags_on:
		_num.visible = false
		if _ghost:
			_ghost.visible = false
		if _or:
			_or.visible = false
	if _selector_dim:
		modulate = Color(0.38, 0.36, 0.34, 1.0)
	elif _glow or _aura or _log_focus or _danger:
		pass
	elif _petrified and not _petrify_dummy:
		modulate = Color(0.58, 0.56, 0.52, 1.0)
	elif spent:
		modulate = Color(0.86, 0.84, 0.80, 1.0)
	else:
		modulate = Color.WHITE
	_playable = can_use and not spent
	if _used != null:
		_used.visible = spent
	_sync_lock_shade()
	if _mark != null and not _formula_on:
		var beside: bool = _mark_sits_beside(number_text)
		_mark.visible = (not _mode_tags_on) and _mark.texture != null and (number_text == "" or beside)
		_mark.modulate.a = 0.95
		_layout_mark(number_text)
	_layout_atk_pip()
	_apply_glyph_vis()
	if _shrouded:
		_sync_shroud_vis()


func set_glyphs(rows: Array) -> void:
	_glyph_rows = rows
	if _face != null and _face.has_method("set_rows"):
		_face.set_rows(rows)
	_apply_glyph_vis()
	if _shrouded:
		_sync_shroud_vis()


func _apply_glyph_vis() -> void:
	var on := not _glyph_rows.is_empty() and not _formula_on and not _mode_tags_on and not _shrouded
	if _face != null:
		_face.visible = on
	if not on:
		return
	if _num:
		_num.visible = false
	if _or:
		_or.visible = false
	if _ghost:
		_ghost.visible = false
	if _atk_pip:
		_atk_pip.visible = false
	if _mark:
		_mark.visible = false


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


func set_hp_cost(text: String) -> void:
	var shown: String = text.strip_edges()
	if shown == "":
		if _hp_cost:
			_hp_cost.visible = false
		return
	if _hp_cost == null:
		_hp_cost = HBoxContainer.new()
		_hp_cost.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_hp_cost.add_theme_constant_override("separation", 2)
		_hp_cost.z_index = 6
		var heart := TextureRect.new()
		heart.custom_minimum_size = Vector2(16, 16)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.texture_filter = TEXTURE_FILTER_NEAREST
		heart.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if ResourceLoader.exists("res://assets/icons/heart.svg"):
			heart.texture = load("res://assets/icons/heart.svg")
		_hp_cost.add_child(heart)
		var lab := Label.new()
		lab.name = "Cost"
		lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lab.add_theme_font_size_override("font_size", 16)
		lab.add_theme_color_override("font_color", Color("e8a0a0"))
		lab.add_theme_color_override("font_outline_color", Color("100e0c"))
		lab.add_theme_constant_override("outline_size", 4)
		_hp_cost.add_child(lab)
		_overlay_host().add_child(_hp_cost)
	var cost: Label = _hp_cost.get_node_or_null("Cost") as Label
	if cost:
		cost.text = shown
	_hp_cost.visible = true
	var face_w: float = SHOW_W if _showcase else CARD_W
	var face_h: float = SHOW_H if _showcase else CARD_H
	_hp_cost.position = Vector2(maxf(4.0, face_w - 58.0), face_h - 34.0)


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
	var face_h: float = SHOW_H if _showcase else CARD_H
	## Net: park the 1/2/3 chip in the bottom-right face corner so it stays
	## clear of the centered burst (and of New! on the bottom-left). Knife
	## keeps the short top-right chip above its dual face glyphs.
	if card_id == "net" and not _showcase:
		lab.position = Vector2(maxf(4.0, face_w - w - 10.0), face_h - 20.0)
	else:
		lab.position = Vector2(maxf(4.0, face_w - w - 8.0), 2.0)


func set_beggar_mark(on: bool, tex: Texture2D = null) -> void:
	_beggar_on = on
	if on:
		var lab := _ensure_beggar_label()
		lab.visible = false
		if tex != null and _beggar_icon != null:
			_beggar_icon.texture = tex
		if _beggar_icon:
			_beggar_icon.visible = true
			_beggar_icon.tooltip_text = "When you Spin the Beggar, this Item will be Discarded"
		# Direction A: thin WARNING outline (not the old overloaded ember).
		if _aura_role != AURA_WARN:
			set_aura_role(AURA_WARN)
		_place_beggar_label()
	elif _beggar_lab != null:
		_beggar_lab.visible = false
		if _beggar_icon:
			_beggar_icon.visible = false
	queue_redraw()


func play_beggar_pick() -> void:
	set_beggar_mark(true)
	_beggar_flash = 1.0
	pivot_offset = size * 0.5
	scale = Vector2(1.2, 1.2)
	if _beggar_punch != null:
		_beggar_punch.kill()
	_beggar_punch = create_tween()
	_beggar_punch.tween_property(self, "scale", Vector2.ONE, 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	queue_redraw()


func _ensure_beggar_label() -> Label:
	if _beggar_lab != null:
		return _beggar_lab
	if _beggar_icon == null:
		_beggar_icon = TextureRect.new()
		_beggar_icon.name = "BeggarIcon"
		_beggar_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_beggar_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_beggar_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_beggar_icon.texture_filter = TEXTURE_FILTER_NEAREST
		_beggar_icon.z_index = 16
		# ~1/8 of the hotbar card, pinned top-right. Never grow to the portrait.
		_beggar_icon.custom_minimum_size = Vector2(18, 18)
		_beggar_icon.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		_beggar_icon.offset_left = -20
		_beggar_icon.offset_top = 2
		_beggar_icon.offset_right = -2
		_beggar_icon.offset_bottom = 20
		for path in [
			"res://assets/dungeon/anim/facing/beggar_facing_idle_f0.png",
			"res://assets/dungeon/anim/wheel/beggar_wheel_base.png",
			"res://assets/dungeon/extra/beggar.png",
		]:
			if ResourceLoader.exists(path):
				_beggar_icon.texture = load(path) as Texture2D
				break
		_overlay_host().add_child(_beggar_icon)
		if not resized.is_connected(_place_beggar_label):
			resized.connect(_place_beggar_label)
	var lab := Label.new()
	lab.name = "BeggarMark"
	lab.text = "Beggar"
	lab.tooltip_text = "When you Spin the Beggar, this Item will be Discarded"
	lab.mouse_filter = Control.MOUSE_FILTER_STOP
	lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lab.add_theme_font_size_override("font_size", 13)
	lab.add_theme_color_override("font_color", Color("ffb24a"))
	lab.add_theme_color_override("font_outline_color", Color("100e0c"))
	lab.add_theme_constant_override("outline_size", 5)
	lab.z_index = 8
	lab.custom_minimum_size = Vector2(80, 18)
	lab.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT and _playable:
			picked.emit()
			lab.accept_event()
	)
	_overlay_host().add_child(lab)
	_beggar_lab = lab
	_place_beggar_label()
	return lab


func _place_beggar_label() -> void:
	if _beggar_icon != null:
		_beggar_icon.anchor_left = 1.0
		_beggar_icon.anchor_top = 0.0
		_beggar_icon.anchor_right = 1.0
		_beggar_icon.anchor_bottom = 0.0
		_beggar_icon.offset_left = -20.0
		_beggar_icon.offset_top = 2.0
		_beggar_icon.offset_right = -2.0
		_beggar_icon.offset_bottom = 20.0
		_beggar_icon.size = Vector2(18, 18)
	if _beggar_lab == null:
		return
	_beggar_lab.visible = false


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
	_overlay_host().add_child(lab)
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


func set_curse(on: bool) -> void:
	_curse = on
	_apply_style(_hot)
	queue_redraw()


func set_shroud(on: bool) -> void:
	_shrouded = on
	_shroud_anim = false
	_ensure_shroud_haze()
	if _shroud_haze != null:
		_shroud_haze.visible = on
		_shroud_haze.modulate = Color.WHITE
	if _shroud_mark != null:
		_shroud_mark.visible = on
		_shroud_mark.modulate = Color.WHITE
	_sync_shroud_vis()
	queue_redraw()


## 0 = the real card, 1 = the full curse veil. Used while Dark Matter closes over a card.
func set_shroud_cover(amount: float) -> void:
	var t := clampf(amount, 0.0, 1.0)
	if t >= 0.98:
		set_shroud(true)
		return
	_shroud_anim = true
	_ensure_shroud_haze()
	if _shroud_haze != null:
		_shroud_haze.visible = true
		_shroud_haze.modulate = Color(1, 1, 1, t)
	if _shroud_mark != null:
		var mark_a := clampf((t - 0.45) / 0.55, 0.0, 1.0)
		_shroud_mark.visible = mark_a > 0.05
		_shroud_mark.modulate = Color(1, 1, 1, mark_a)
	var hide := 1.0 - t
	if _title != null:
		_title.modulate = Color(1, 1, 1, hide)
	if _icon != null and not _petrified:
		_icon.modulate = Color(hide, hide, hide, hide)
	if _face != null:
		_face.modulate = Color(1, 1, 1, hide)


## 0 = still veiled, 1 = the item underneath is showing. Dark Matter click peel.
func set_shroud_peel(open_amount: float) -> void:
	var t := clampf(open_amount, 0.0, 1.0)
	if t <= 0.02:
		set_shroud(true)
		return
	if t >= 0.98:
		_shroud_anim = false
		set_shroud(false)
		return
	_shroud_anim = true
	_shrouded = true
	_ensure_shroud_haze()
	if _shroud_haze != null:
		_shroud_haze.visible = true
		_shroud_haze.modulate = Color(1, 1, 1, 1.0 - t)
	if _shroud_mark != null:
		_shroud_mark.visible = true
		_shroud_mark.modulate = Color(1, 1, 1, 1.0 - t)
	if _title != null:
		_title.visible = true
		_title.modulate = Color(1, 1, 1, t)
	if _icon != null and not _petrified:
		_icon.visible = true
		_icon.modulate = Color(1, 1, 1, t)
	if _face != null:
		_face.visible = true
		_face.modulate = Color(1, 1, 1, t)
	if _num != null:
		_num.visible = true
		_num.modulate = Color(1, 1, 1, t)


func is_shrouded() -> bool:
	return _shrouded


func _ensure_shroud_haze() -> void:
	if _shroud_haze != null and is_instance_valid(_shroud_haze):
		return
	## Solid black veil + drawn wisps so the card is fully unidentifiable as a curse.
	_shroud_haze = Control.new()
	_shroud_haze.name = "ShroudHaze"
	_shroud_haze.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shroud_haze.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shroud_haze.visible = false
	_shroud_haze.z_index = 14
	_shroud_haze.clip_contents = true
	_shroud_haze.draw.connect(_draw_shroud_veil)
	_shroud_haze.resized.connect(func() -> void:
		if _shroud_haze != null:
			_shroud_haze.queue_redraw()
	)
	_overlay_host().add_child(_shroud_haze)
	_shroud_mark = Label.new()
	_shroud_mark.name = "ShroudMark"
	_shroud_mark.text = "?"
	_shroud_mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_shroud_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_shroud_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shroud_mark.add_theme_font_size_override("font_size", 42)
	_shroud_mark.add_theme_color_override("font_color", Color(0.55, 0.48, 0.58, 0.92))
	_shroud_mark.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.06, 1.0))
	_shroud_mark.add_theme_constant_override("outline_size", 6)
	_shroud_mark.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_shroud_mark.visible = false
	_shroud_mark.z_index = 15
	_overlay_host().add_child(_shroud_mark)


func _draw_shroud_veil() -> void:
	if _shroud_haze == null:
		return
	var w: float = _shroud_haze.size.x
	var h: float = _shroud_haze.size.y
	if w < 2.0 or h < 2.0:
		return
	## Full cover — no art / title / numbers peek through.
	_shroud_haze.draw_rect(Rect2(0, 0, w, h), Color(0.02, 0.01, 0.04, 1.0))
	## Soft void wisps so it reads as Shrouded, not a blank plate.
	var ink := Color(0.18, 0.12, 0.22, 0.55)
	var cx: float = w * 0.5
	var cy: float = h * 0.52
	for i in 5:
		var r: float = 10.0 + float(i) * 9.0
		var a0: float = 0.35 + float(i) * 0.55
		_shroud_haze.draw_arc(Vector2(cx, cy), r, a0, a0 + PI * 1.15, 18, ink, 2.2, true)
	var rim := Color(0.08, 0.05, 0.12, 0.85)
	_shroud_haze.draw_rect(Rect2(1.0, 1.0, w - 2.0, h - 2.0), rim, false, 2.0)


func _sync_shroud_vis() -> void:
	## Hide every identity cue while shrouded; restore on clear via next paint/set_live.
	if _shroud_anim:
		return
	if not _shrouded:
		if _title != null:
			_title.modulate = Color.WHITE
		if _icon != null and not _petrified:
			_icon.modulate = Color.WHITE
		if _face != null:
			_face.modulate = Color.WHITE
		return
	if _title != null:
		_title.modulate = Color(1, 1, 1, 0)
	if _rank != null:
		_rank.visible = false
	if _icon != null:
		_icon.modulate = Color(0, 0, 0, 0)
	if _face != null:
		_face.modulate = Color(1, 1, 1, 0)
		_face.visible = false
	if _num != null:
		_num.visible = false
	if _ghost != null:
		_ghost.visible = false
	if _or != null:
		_or.visible = false
	if _eq != null:
		_eq.visible = false
	if _mark != null:
		_mark.visible = false
	if _atk_pip != null:
		_atk_pip.visible = false
	if _plus != null:
		_plus.visible = false
	if _ban != null:
		_ban.visible = false
	if _ability != null:
		_ability.visible = false
	if _hp_cost != null:
		_hp_cost.visible = false
	if _echo_mark != null:
		_echo_mark.visible = false
	if _cabinet_badge != null:
		_cabinet_badge.visible = false
	if _choice_badge != null:
		_choice_badge.visible = false
	if _beggar_icon != null:
		_beggar_icon.visible = false
	if _warn_chip != null:
		_warn_chip.visible = false
	if _bag_stamp != null:
		_bag_stamp.visible = false
	if _source_stamp != null:
		_source_stamp.visible = false
	if _formula_on:
		_formula_on = false


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
		host_h = IDLE_FACE_HOST_MIN_H
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


func _mark_sits_beside(number_text: String) -> bool:
	var shown: String = number_text.strip_edges()
	if shown == "" or shown == "—" or shown == "-":
		return false
	return kind == "DEFEAT" or kind == "HP" or kind == "BLK" or kind == "FLEE"


func _layout_mark(number_text: String) -> void:
	if _mark == null:
		return
	var beside: bool = _mark_sits_beside(number_text)
	## Idle marks track the +50% face glyph scale when glyphs are off (petrify countdown, etc.).
	var s: float = 1.5 if not _showcase else 1.0
	if beside:
		_mark.offset_left = -40.0 * s
		_mark.offset_top = -16.0 * s
		_mark.offset_right = -8.0 * s
		_mark.offset_bottom = 16.0 * s
	else:
		_mark.offset_left = -18.0 * s
		_mark.offset_top = -18.0 * s
		_mark.offset_right = 18.0 * s
		_mark.offset_bottom = 18.0 * s


func set_rim_glow(on: bool) -> void:
	_rim_glow = on
	_apply_style(_hot)


func set_draft_glow(on: bool) -> void:
	## Gate / door offer may still pass true (THE SHINY). Hotbar Brand New /
	## uncollected callers must pass false — matte plates, no pulse/halo.
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
	## Compat shim — overloaded ember becomes READY role.
	set_aura_role(AURA_READY if on else AURA_OFF)


func set_aura_role(role: String) -> void:
	## READY / WARN / CHOICE / "" — one aura at a time (caller applies priority).
	var next: String = role.strip_edges().to_lower()
	if next != AURA_READY and next != AURA_WARN and next != AURA_CHOICE:
		next = AURA_OFF
	_aura_role = next
	_aura = next == AURA_READY
	if next == AURA_READY:
		_start_ready_pulse()
	else:
		_stop_ready_pulse()
	set_process(_want_process())
	if next == AURA_OFF and not _glow and not _playable and not _log_focus and not _danger and not _toss_pick:
		_glow_t = 0.0
		if not spent and not _petrified and not _selector_dim:
			modulate = Color.WHITE
	_apply_style(_hot)
	queue_redraw()


func _start_ready_pulse() -> void:
	if _aura_pulse_tw != null and is_instance_valid(_aura_pulse_tw):
		return
	_glow_t = 0.0


func _stop_ready_pulse() -> void:
	if _aura_pulse_tw != null and is_instance_valid(_aura_pulse_tw):
		_aura_pulse_tw.kill()
		_aura_pulse_tw = null


func set_upgrade_offer(on: bool) -> void:
	_upgrade_offer = on
	set_process(true)
	if not on and _hot:
		_apply_style(true)
	queue_redraw()


func set_toss_pick(on: bool) -> void:
	_toss_pick = on
	if on:
		_playable = true
		# Migrate toss-pick toward CHOICE language (Direction A).
		if _aura_role != AURA_WARN:
			set_aura_role(AURA_CHOICE)
	set_process(_want_process())
	if not on and not _glow and not _playable and not _aura and not _log_focus and not _danger:
		_glow_t = 0.0
		if not spent:
			modulate = Color.WHITE
	_apply_style(_hot)


func set_waiting_entry(on: bool) -> void:
	if on:
		if not _waiting_entry:
			_wait_base_y = position.y
		_waiting_entry = true
		z_index = 22
		pivot_offset = size * 0.5
	else:
		if _waiting_entry:
			position.y = _wait_base_y
			rotation = 0.0
		_waiting_entry = false
		z_index = 0
		if not _hot and not _playable:
			scale = Vector2.ONE
	set_process(_want_process())
	queue_redraw()


## Full-hand offer: sit at `at` and bob until the player throws something away.
## Repeat calls with the same anchor leave the bob alone.
func park_waiting(at: Vector2, sz: Vector2) -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	anchor_right = 0.0
	anchor_bottom = 0.0
	size = sz
	pivot_offset = sz * 0.5
	var same: bool = _waiting_entry and absf(position.x - at.x) < 0.5 and absf(_wait_base_y - at.y) < 0.5
	if not same:
		position = at
		_wait_base_y = at.y
		rotation = 0.0
	_waiting_entry = true
	z_index = 22
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process(_want_process())
	queue_redraw()


func set_danger(on: bool) -> void:
	## Toll at 1, and Spinning Top at 6 (next Spin Discards it). Hex uses mint instead.
	_danger = on
	if on:
		_hex_good = false
	set_process(_want_process())
	if not on and not _glow and not _playable and not _aura and not _log_focus:
		_glow_t = 0.0
		if not spent:
			modulate = Color.WHITE
	_apply_style(_hot)


func set_hex_good(on: bool) -> void:
	## Hex@1 mint payoff — never shares Toll's crimson.
	_hex_good = on
	if on:
		_danger = false
		set_num_color(COL_HEX_GOOD)
	set_process(_want_process())
	_apply_style(_hot)
	queue_redraw()


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
	_tween_sink(not _playable and not spent and not _guarding and not _selector_dim)
	_tick_shimmer()


func set_playable(on: bool) -> void:
	_playable = on and (not spent or _toss_pick)
	set_process(true)
	_sync_lock_shade()
	_apply_style(_hot)
	_tween_sink(not _playable and not spent and not _guarding and not _selector_dim)
	_tick_shimmer()


func set_cancel_pick(on: bool) -> void:
	_cancel_pick = on
	if not on:
		_cancel_corner = false
	_ensure_cancel_mark()
	_place_cancel_mark()
	if _cancel_disc != null:
		_cancel_disc.visible = on
	if _cancel_x != null:
		_cancel_x.visible = on
	queue_redraw()


func set_cancel_corner(on: bool) -> void:
	## Top-right X while Look H mode panel is open (starter seat only).
	_cancel_corner = on and _cancel_pick
	_place_cancel_mark()
	queue_redraw()


func set_selector_dim(on: bool) -> void:
	_selector_dim = on
	_sync_selector_veil()
	if on:
		modulate = Color(0.38, 0.36, 0.34, 1.0)
	elif not spent and not _petrified:
		modulate = Color.WHITE
	_sync_hatch()
	_tween_sink(not _playable and not spent and not _guarding and not _selector_dim)
	_apply_style(_hot)
	_sync_selector_veil()
	queue_redraw()


func _sync_selector_veil() -> void:
	if not _selector_dim or _showcase:
		if _selector_veil != null:
			_selector_veil.visible = false
		return
	if _selector_veil == null:
		_selector_veil = Control.new()
		_selector_veil.name = "SelectorVeil"
		_selector_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_selector_veil.z_index = 18
		_selector_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_selector_veil.draw.connect(_draw_selector_veil)
		_selector_veil.resized.connect(func() -> void:
			if _selector_veil != null:
				_selector_veil.queue_redraw()
		)
		_overlay_host().add_child(_selector_veil)
	_selector_veil.visible = true
	_selector_veil.queue_redraw()


func _draw_selector_veil() -> void:
	if _selector_veil == null:
		return
	var w: float = _selector_veil.size.x
	var h: float = _selector_veil.size.y
	if w < 2.0 or h < 2.0:
		return
	## Dark wash + edge vignette so the legal cards are the only full-bright seats.
	_selector_veil.draw_rect(Rect2(0, 0, w, h), Color(0.05, 0.04, 0.03, 0.58))
	var inset := Rect2(6.0, 6.0, maxf(w - 12.0, 2.0), maxf(h - 12.0, 2.0))
	_selector_veil.draw_rect(inset, Color(0.05, 0.04, 0.03, 0.12))
	var band := 18.0
	_selector_veil.draw_rect(Rect2(0, 0, w, band), Color(0.04, 0.03, 0.02, 0.22))
	_selector_veil.draw_rect(Rect2(0, h - band, w, band), Color(0.04, 0.03, 0.02, 0.22))
	_selector_veil.draw_rect(Rect2(0, 0, band, h), Color(0.04, 0.03, 0.02, 0.16))
	_selector_veil.draw_rect(Rect2(w - band, 0, band, h), Color(0.04, 0.03, 0.02, 0.16))


## Look H superseded in-chrome tags. Always clear; ignore `rows`.
func set_mode_tags(_rows: Array = []) -> void:
	_mode_tag_rows.clear()
	_mode_tags_on = false
	if _mode_tag_box != null:
		for child in _mode_tag_box.get_children():
			_mode_tag_box.remove_child(child)
			child.queue_free()
		_mode_tag_box.visible = false
		_mode_tag_box.custom_minimum_size = Vector2.ZERO
	if _icon != null and not _showcase:
		_icon.custom_minimum_size = Vector2(IDLE_ICON, IDLE_ICON)
	if _num_host != null and not _showcase:
		_num_host.visible = true
		_num_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_num_host.custom_minimum_size = Vector2(CARD_W - 14.0, IDLE_FACE_HOST_MIN_H)
	_place_cancel_mark()
	queue_redraw()


func _ensure_cancel_mark() -> void:
	if _cancel_disc != null and _cancel_x != null:
		return
	var host: Control = _overlay_host()
	_cancel_disc = ColorRect.new()
	_cancel_disc.name = "CancelDisc"
	_cancel_disc.color = Color("100e0c", 0.72)
	_cancel_disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cancel_disc.z_index = 24
	_cancel_disc.visible = false
	host.add_child(_cancel_disc)
	_cancel_x = TextureRect.new()
	_cancel_x.name = "CancelX"
	_cancel_x.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cancel_x.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_cancel_x.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cancel_x.texture_filter = TEXTURE_FILTER_NEAREST
	_cancel_x.z_index = 25
	var x_path := "res://assets/ui/map/map_close_x_normal.png"
	if ResourceLoader.exists(x_path):
		_cancel_x.texture = load(x_path) as Texture2D
	_cancel_x.visible = false
	host.add_child(_cancel_x)
	_place_cancel_mark()
	if not resized.is_connected(_place_cancel_mark):
		resized.connect(_place_cancel_mark)


func _place_cancel_mark() -> void:
	if _cancel_disc == null or _cancel_x == null:
		return
	## Look H mode choose: X top-right on the starter. Hand pick / wheel: centered.
	if _cancel_corner and not _showcase:
		_cancel_disc.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		_cancel_disc.offset_left = -28.0
		_cancel_disc.offset_top = 4.0
		_cancel_disc.offset_right = -4.0
		_cancel_disc.offset_bottom = 28.0
		_cancel_x.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		_cancel_x.offset_left = -26.0
		_cancel_x.offset_top = 6.0
		_cancel_x.offset_right = -6.0
		_cancel_x.offset_bottom = 26.0
	else:
		_cancel_disc.set_anchors_preset(Control.PRESET_CENTER)
		_cancel_disc.offset_left = -22.0
		_cancel_disc.offset_top = -22.0
		_cancel_disc.offset_right = 22.0
		_cancel_disc.offset_bottom = 22.0
		_cancel_x.set_anchors_preset(Control.PRESET_CENTER)
		_cancel_x.offset_left = -20.0
		_cancel_x.offset_top = -20.0
		_cancel_x.offset_right = 20.0
		_cancel_x.offset_bottom = 20.0


func _process(delta: float) -> void:
	if _beggar_flash > 0.0:
		_beggar_flash = maxf(0.0, _beggar_flash - delta * 1.6)
		queue_redraw()
	_shimmer_clock += delta
	if _waiting_entry:
		_tick_waiting_hover()
	# Attack/slash heavy: pause shimmer, breathe, and sparkle so the hotbar
	# does not compete with the banner. Active sai/marble item FX still tick.
	if FX_BUDGET.hold_low_priority_idles() and not _sai_busy and not _marble_busy and _beggar_flash <= 0.0 and not _waiting_entry:
		return
	if _glow or _aura or _aura_role != AURA_OFF or _log_focus or _danger or _hex_good or _hot or _toss_pick or _upgrade_offer or _gaze_warn or _decay_warn or _decay_link or _decay_solo or _gaze_entry:
		_glow_t += delta
		_style_wait -= delta
		if _style_wait <= 0.0:
			_style_wait = 0.05
			_apply_style(_hot)
	_tick_shimmer()
	_tick_breathe()
	_tick_sparkle(delta)
	_place_fx()


func set_formula(bb: String) -> void:
	_formula = bb


func show_formula(on: bool) -> void:
	## Shrouded cards never show Shift equation — that would identify them.
	if _shrouded:
		_formula_on = false
		if _eq != null:
			_eq.visible = false
		_sync_shroud_vis()
		return
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
	_apply_glyph_vis()


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


func take_value_edge() -> Dictionary:
	if not _edge_on:
		return {}
	_edge_on = false
	return {"old": _edge_old, "new": _edge_new}


func mark_became_legal(now: bool) -> bool:
	if not _legal_known:
		_legal_known = true
		_legal_now = now
		return false
	var rose: bool = now and not _legal_now
	_legal_now = now
	return rose


func play_update_pulse(tone: String, delay: float = 0.0) -> void:
	## Shared hotbar reaction: tint, lift, settle. Toll is larger.
	if _showcase or _shrouded or _waiting_entry or _selector_dim:
		return
	if _pulse_tw != null and is_instance_valid(_pulse_tw):
		_pulse_tw.kill()
	var tw := create_tween()
	_pulse_tw = tw
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_callback(_run_update_pulse.bind(tone))


func _run_update_pulse(tone: String) -> void:
	if not is_instance_valid(self) or _showcase or _shrouded or _waiting_entry:
		return
	var lift := 6.0
	var pop := 1.06
	var up := 0.06
	var down := 0.08
	var tint := Color(0.62, 0.82, 1.0)
	match tone:
		"bad":
			tint = Color(1.0, 0.55, 0.55)
		"mint":
			tint = Color(0.70, 0.96, 0.82)
		"light":
			tint = Color(0.70, 0.96, 0.82)
			lift = 3.0
			pop = 1.03
		"toll":
			tint = Color(0.86, 0.22, 0.22)
			lift = 12.0
			pop = 1.14
			up = 0.08
			down = 0.12
		_:
			tint = Color(0.62, 0.82, 1.0)
	var base := position
	var old_pivot := pivot_offset
	pivot_offset = size * 0.5
	var tw := create_tween()
	_pulse_tw = tw
	tw.tween_property(self, "position", base + Vector2(0, -lift), up).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2(pop, pop), up).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "modulate", tint, up * 0.45)
	tw.tween_property(self, "position", base, down).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(self, "scale", Vector2.ONE, down).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(self, "modulate", Color.WHITE, down)
	tw.finished.connect(_end_update_pulse.bind(old_pivot), CONNECT_ONE_SHOT)


func _end_update_pulse(old_pivot: Vector2) -> void:
	if not is_instance_valid(self):
		return
	pivot_offset = old_pivot
	scale = Vector2.ONE
	if _selector_dim:
		modulate = Color(0.38, 0.36, 0.34, 1.0)
	elif _petrified and not _petrify_dummy:
		modulate = Color(0.58, 0.56, 0.52, 1.0)
	elif spent:
		modulate = Color(0.86, 0.84, 0.80, 1.0)
	else:
		modulate = Color.WHITE


func bounce() -> void:
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.12, 1.12), 0.08)
	tw.tween_property(self, "scale", Vector2.ONE, 0.12)


func play_draft_pick_seal() -> void:
	## Wax press on a chosen draft card, then hold the still seal.
	_ensure_draft_stamp_fx()
	_draft_stamp_fx.visible = true
	_draft_stamp_fx.play("press")
	_place_draft_fx()
	if not _draft_stamp_fx.animation_finished.is_connected(_on_draft_press_done):
		_draft_stamp_fx.animation_finished.connect(_on_draft_press_done, CONNECT_ONE_SHOT)


func show_draft_leftbehind() -> void:
	## Grey X on a leftover draft card (the ones not taken).
	_ensure_draft_stamp_fx()
	_draft_stamp_fx.visible = true
	_draft_stamp_fx.play("left")
	_place_draft_fx()


func play_recycle_return() -> void:
	## Tiny card sliding left — Recycler copy coming back onto the hotbar.
	_ensure_recycle_return_fx()
	_recycle_return_fx.visible = true
	_recycle_return_fx.play("return")
	_place_draft_fx()
	if not _recycle_return_fx.animation_finished.is_connected(_on_recycle_return_done):
		_recycle_return_fx.animation_finished.connect(_on_recycle_return_done, CONNECT_ONE_SHOT)


func clear_draft_stamp() -> void:
	if _draft_stamp_fx:
		_draft_stamp_fx.visible = false
		_draft_stamp_fx.stop()
	if _recycle_return_fx:
		_recycle_return_fx.visible = false
		_recycle_return_fx.stop()


func _on_draft_press_done() -> void:
	if _draft_stamp_fx == null or not is_instance_valid(_draft_stamp_fx):
		return
	_draft_stamp_fx.play("seal")


func _on_recycle_return_done() -> void:
	if _recycle_return_fx == null or not is_instance_valid(_recycle_return_fx):
		return
	_recycle_return_fx.visible = false


func _ensure_draft_stamp_fx() -> void:
	if _draft_stamp_fx != null:
		return
	_draft_stamp_fx = AnimatedSprite2D.new()
	_draft_stamp_fx.name = "DraftStampFx"
	_draft_stamp_fx.centered = true
	_draft_stamp_fx.texture_filter = TEXTURE_FILTER_NEAREST
	_draft_stamp_fx.z_index = 12
	_draft_stamp_fx.visible = false
	_draft_stamp_fx.sprite_frames = _draft_stamp_frames()
	add_child(_draft_stamp_fx)
	if not resized.is_connected(_place_draft_fx):
		resized.connect(_place_draft_fx)


func _ensure_recycle_return_fx() -> void:
	if _recycle_return_fx != null:
		return
	_recycle_return_fx = AnimatedSprite2D.new()
	_recycle_return_fx.name = "RecycleReturnFx"
	_recycle_return_fx.centered = true
	_recycle_return_fx.texture_filter = TEXTURE_FILTER_NEAREST
	_recycle_return_fx.z_index = 13
	_recycle_return_fx.visible = false
	_recycle_return_fx.sprite_frames = _recycle_return_frames()
	add_child(_recycle_return_fx)
	if not resized.is_connected(_place_draft_fx):
		resized.connect(_place_draft_fx)


func _place_draft_fx() -> void:
	var sc: float = 4.0 if _showcase else 2.0
	var half: float = 8.0 * sc
	if _draft_stamp_fx != null:
		_draft_stamp_fx.scale = Vector2(sc, sc)
		var anim: String = _draft_stamp_fx.animation
		if anim == "left":
			_draft_stamp_fx.position = size * 0.5
		else:
			_draft_stamp_fx.position = Vector2(size.x - half - 6.0, size.y - half - 6.0)
	if _recycle_return_fx != null:
		_recycle_return_fx.scale = Vector2(sc, sc)
		_recycle_return_fx.position = size * 0.5


func _draft_stamp_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_once(sf, "press", "res://assets/ui/draft/pick_seal_press_f%d.png", 4, 1.0 / 0.08)
	_add_still(sf, "seal", "res://assets/ui/draft/pick_seal.png")
	_add_still(sf, "left", "res://assets/ui/draft/draft_leftbehind.png")
	return sf


func _recycle_return_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_once(sf, "return", "res://assets/ui/draft/recycle_return_f%d.png", 4, 1.0 / 0.08)
	return sf


func play_recycle_tick() -> void:
	## Louder countdown punch when Recycler decrements on a discard.
	## Bigger than bounce(); bumps the live number so 5→4→3→2 reads clearly.
	pivot_offset = size * 0.5
	z_index = 42
	var face: int = 48 if _showcase else 32
	if _num != null and _num.visible:
		_num.add_theme_font_size_override("font_size", 56 if _showcase else 52)
		_num.add_theme_constant_override("outline_size", 8)
		_num.add_theme_color_override("font_outline_color", Color("100e0c"))
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.28, 1.28), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:
		if _num != null and _num.visible:
			_num.add_theme_font_size_override("font_size", face)
			_num.add_theme_constant_override("outline_size", 4)
	)
	tw.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void:
		z_index = 0
	)


func play_toll_zero() -> void:
	pivot_offset = size * 0.5
	z_index = 90
	if _num:
		_num.visible = true
		_num.modulate = Color.WHITE
		_num.text = "1"
		_shown = "1"
		_num.add_theme_font_size_override("font_size", 56)
		_num.add_theme_color_override("font_color", Color("f3e6ff"))
		_num.add_theme_color_override("font_outline_color", Color("3a1460"))
		_num.add_theme_constant_override("outline_size", 6)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.42, 1.42), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished
	if _num:
		_dissolve("1", "0")
		_num.add_theme_font_size_override("font_size", 64)
		_num.add_theme_color_override("font_color", Color("d4a0ff"))
	_spawn_toll_burst()
	tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate", Color(0.78, 0.42, 1.0), 0.10)
	tw.tween_property(self, "scale", Vector2(1.55, 1.55), 0.16)
	await tw.finished
	tw = create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "modulate", Color.WHITE, 0.22)
	tw.tween_property(self, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw.finished
	z_index = 0
	if _num:
		_num.add_theme_font_size_override("font_size", 26)
		_num.add_theme_color_override("font_color", _num_col)
		_num.add_theme_color_override("font_outline_color", Color("100e0c"))
		_num.add_theme_constant_override("outline_size", 3)


func _spawn_toll_burst() -> void:
	var host: Control = Control.new()
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.z_index = 20
	add_child(host)
	for i in range(3):
		var ring := ColorRect.new()
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.color = Color(0.55, 0.18, 0.92, 0.55 - i * 0.12)
		var pad := 8.0 + float(i) * 10.0
		ring.size = size + Vector2(pad * 2.0, pad * 2.0)
		ring.position = Vector2(-pad, -pad)
		ring.pivot_offset = ring.size * 0.5
		host.add_child(ring)
		var tw := ring.create_tween()
		tw.set_parallel(true)
		tw.tween_property(ring, "scale", Vector2(2.4 + i * 0.35, 2.4 + i * 0.35), 0.42).set_delay(i * 0.05)
		tw.tween_property(ring, "modulate:a", 0.0, 0.42).set_delay(i * 0.05)
	var fade := host.create_tween()
	fade.tween_interval(0.55)
	fade.tween_callback(host.queue_free)


func play_transform() -> void:
	await play_flip_transform()


## Horizontal card flip. `on_mid` runs while the card is edge-on so the back
## can already be the new item.
func play_flip_transform(on_mid: Callable = Callable()) -> void:
	if has_meta("tossing"):
		if on_mid.is_valid():
			on_mid.call()
		return
	pivot_offset = size * 0.5
	z_index = 48
	var tw := create_tween()
	tw.tween_property(self, "scale:x", 0.0, 0.16).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tw.finished
	if on_mid.is_valid():
		on_mid.call()
	if not is_instance_valid(self):
		return
	pivot_offset = size * 0.5
	tw = create_tween()
	tw.tween_property(self, "scale:x", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tw.finished
	if not is_instance_valid(self):
		return
	scale = Vector2.ONE
	modulate = Color.WHITE
	z_index = 0


func adopt_identity(p_id: String, title: String, icon: Texture2D, p_kind: String, mark: Texture2D) -> void:
	_sai_busy = false
	_marble_busy = false
	_pending_live = ""
	_shown = ""
	if _marble_fx != null:
		_marble_fx.visible = false
		_marble_fx.stop()
	if _sai_fx != null:
		_sai_fx.visible = false
		_sai_fx.stop()
	card_id = p_id
	kind = p_kind
	if _icon:
		_icon.modulate.a = 1.0
		_icon.texture = icon
		var arc: Node = _icon.get_node_or_null("MoveArc")
		var want_arc: bool = p_id == "shuriken" or p_id == "swift_sneaks"
		if want_arc and arc == null:
			var move_arc := preload("res://scripts/move_arc_icon.gd").new()
			move_arc.name = "MoveArc"
			_icon.add_child(move_arc)
		elif not want_arc and arc != null:
			arc.queue_free()
	set_title(title)
	if _mark != null:
		_mark.texture = mark


func _apply_style(hot: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.bg_color = _fill.lightened(0.10) if hot else _fill
	var metal: Color = _rim.lightened(0.18) if hot else _rim
	if _curse:
		metal = Color("100e0c")
		sb.bg_color = Color("241014")
	var pulse := 0.0
	if _glow:
		var period: float = 1.45 if _tier <= 1 else (1.05 if _tier == 2 else 0.72)
		pulse = 0.50 + 0.50 * absf(sin(_glow_t * TAU / period))
		metal = _rim.lerp(_tier_shine(), 0.20 + pulse * 0.55)
		sb.bg_color = _fill.lightened(0.04 if hot else 0.0)
		modulate = Color.WHITE
	elif _hex_good and not spent:
		# Hex@1 mint face — good countdown, never red.
		pulse = 0.35 + 0.25 * absf(sin(_glow_t * TAU / 1.6))
		metal = metal.lerp(COL_HEX_GOOD, 0.55 + pulse * 0.35)
		sb.bg_color = sb.bg_color.lerp(COL_HEX_GOOD.darkened(0.45), pulse * 0.22)
		modulate = Color.WHITE
	elif _upgrade_offer and not spent:
		## Merchant replace: gold plate, stronger while the pointer is on the card.
		var gold := Color("FFD84A")
		pulse = 0.35 + 0.25 * absf(sin(_glow_t * TAU / 1.3))
		if hot:
			pulse = 0.55 + 0.45 * absf(sin(_glow_t * TAU / 0.7))
		metal = metal.lerp(gold, (0.42 if not hot else 0.82) + pulse * 0.12)
		sb.bg_color = sb.bg_color.lerp(gold.darkened(0.42), (0.10 if not hot else 0.22) + pulse * 0.08)
		modulate = Color.WHITE.lerp(Color("fff1b0"), pulse * (0.18 if not hot else 0.45))
	elif _toss_pick and not spent:
		# CHOICE language (was gold toss glow). Incoming overflow must match seated cards.
		pulse = 0.0
		metal = metal.lerp(COL_CHOICE, 0.72)
		sb.bg_color = sb.bg_color.lerp(COL_CHOICE.darkened(0.45), 0.12)
		modulate = Color.WHITE
	elif _danger and not spent:
		# Toll at 1, and Spinning Top the Spin before it is Discarded.
		pulse = 0.40 + 0.60 * absf(sin(_glow_t * TAU / 0.45))
		var blood := COL_TOLL_LETHAL
		metal = metal.lerp(blood, 0.55 + pulse * 0.45)
		sb.bg_color = sb.bg_color.lerp(blood.darkened(0.15), pulse * 0.42)
		modulate = Color.WHITE.lerp(Color("ff6a4a"), pulse * 0.55)
	elif _aura_role == AURA_READY and not spent:
		# READY #F2A93B solid pulse (~1.6s).
		pulse = 0.45 + 0.55 * absf(sin(_glow_t * TAU / 1.6))
		metal = metal.lerp(COL_READY, 0.50 + pulse * 0.50)
		sb.bg_color = sb.bg_color.lerp(COL_READY.darkened(0.25), pulse * 0.22)
		modulate = Color.WHITE.lerp(Color("ffd89a"), pulse * 0.28)
		if _plus != null and _plus.visible:
			_plus.modulate = Color("e07a7a").lerp(Color.WHITE, pulse * 0.55)
		if _ban != null and _ban.visible:
			_ban.modulate = Color("e8c36a").lerp(Color.WHITE, pulse * 0.55)
	elif (_decay_link or _decay_solo) and not spent and _aura_role != AURA_WARN:
		# Subtle plate border tint only — icon art must stay readable (Doop LINK).
		metal = metal.lerp(COL_LINK, 0.28)
		modulate = Color.WHITE
	elif _log_focus:
		pulse = 0.55 + 0.45 * absf(sin(_glow_t * TAU / 0.8))
		var gold := Color("fff0c0")
		metal = metal.lerp(gold, 0.55 + pulse * 0.45)
		sb.bg_color = sb.bg_color.lerp(gold.darkened(0.45), pulse * 0.28)
		modulate = Color.WHITE.lerp(Color("ffe6a8"), pulse * 0.42)
	elif _hot and not spent:
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
	elif _aura_role == AURA_READY or _log_focus or _danger or _toss_pick or _hex_good:
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
	elif (_decay_link or _decay_solo) and not spent and _aura_role != AURA_WARN:
		# LINK stays thin — no purple plate halo (READY keeps its pulse shadow).
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
		sb.content_margin_top = IDLE_CONTENT_MARGIN_TOP
		sb.content_margin_bottom = 3
	add_theme_stylebox_override("panel", sb)
	if _selector_dim and not spent and not _petrified:
		modulate = Color(0.38, 0.36, 0.34, 1.0)
	_sync_decay_markers()
	queue_redraw()


func _draw() -> void:
	if _curse:
		_draw_dashed_ring(Color("100e0c"), 3.0, 0.35)
	## Shroud emphasis sits on top of the curse rim — void rim so it is not "just a dark card".
	if _shrouded:
		_draw_dashed_ring(Color(0.22, 0.14, 0.30, 0.95), 2.5, 0.55)
	if _beggar_on:
		# Thin WARNING dashed outline (Direction A) — flash still punches the mark.
		var flash: float = clampf(_beggar_flash, 0.0, 1.0)
		_draw_dashed_ring(COL_WARN.lerp(Color("ffe08a"), flash * 0.35), 2.0 + flash * 1.5, 0.0)
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
	# Aura kit rings — Petrify/Unplayable suppress outer roles.
	var show_aura: bool = not spent and not (_petrified and not _petrify_dummy)
	if show_aura and (_gaze_warn or _decay_warn or _aura_role == AURA_WARN):
		_draw_dashed_ring(COL_WARN, 3.0, 0.0)
	elif show_aura and _upgrade_offer:
		var up_pulse: float = 0.35 + 0.65 * absf(sin(_glow_t * TAU / 1.1))
		_draw_double_ring(Color("FFD84A"))
		if _hot:
			_draw_upgrade_chevrons(up_pulse)
	elif show_aura and (_aura_role == AURA_CHOICE or _toss_pick):
		_draw_double_ring(COL_CHOICE)
	elif show_aura and _aura_role == AURA_READY:
		var pulse_r: float = 0.45 + 0.55 * absf(sin(_glow_t * TAU / 1.6))
		_draw_solid_ring(COL_READY, 3.0, pulse_r)
	elif show_aura and (_decay_link or _decay_solo):
		_draw_link_ring(COL_LINK)
	elif show_aura and _gaze_entry:
		# Phase A: thin Basilisk rim on gazed eligible items.
		_draw_solid_ring(COL_BASILISK, 2.0, 0.0)
	if _petrified and not _petrify_dummy and _petrify_source == "basilisk":
		# Dotted scale rim while Basilisk stone holds.
		_draw_dashed_ring(COL_BASILISK, 2.5, 1.0)
	# Legacy Basilisk spin countdown pips (petrify_n) — kept for hydra/legacy callers.
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
	if card_id == "swift_sneaks" and not spent:
		var foot := Vector2(16.0, 16.0)
		draw_circle(foot, 7.0, Color("100e0c", 0.9))
		draw_arc(foot, 5.0, 0.4, PI - 0.2, 10, Color("f0e6d8"), 1.6, true)
		draw_line(foot + Vector2(-3, 2), foot + Vector2(4, 3), Color("f0e6d8"), 1.4, true)


func _draw_upgrade_chevrons(pulse: float) -> void:
	## Gold marks climb over the picture. They stay inside the card so the hover plate cannot hide them.
	var gold := Color("FFD84A")
	var ink := Color("100e0c")
	var cx: float = size.x * 0.5
	var travel: float = fposmod(_glow_t * 0.85, 1.0)
	for i in 3:
		var phase: float = fposmod(travel + float(i) * 0.33, 1.0)
		var y: float = 78.0 - phase * 40.0
		var fade: float = sin(phase * PI) * (0.65 + pulse * 0.35)
		var w: float = 16.0
		var tip := Vector2(cx, y)
		var left := Vector2(cx - w, y + 12.0)
		var right := Vector2(cx + w, y + 12.0)
		draw_line(left, tip, Color(ink.r, ink.g, ink.b, fade), 5.0, true)
		draw_line(tip, right, Color(ink.r, ink.g, ink.b, fade), 5.0, true)
		var col := Color(gold.r, gold.g, gold.b, fade)
		draw_line(left, tip, col, 2.5, true)
		draw_line(tip, right, col, 2.5, true)


func _on_in() -> void:
	_hot = true
	_apply_style(true)
	_force_glint()
	pivot_offset = size * 0.5
	hovered.emit()
	if spent and not _toss_pick:
		return
	if _lift != null:
		_lift.kill()
	_lift = create_tween()
	var lift_scale := Vector2(1.12, 1.12) if _upgrade_offer else (Vector2(1.10, 1.10) if _showcase else Vector2(1.07, 1.07))
	_lift.tween_property(self, "scale", lift_scale, 0.1)
	if _steal_tex != null:
		Input.set_custom_mouse_cursor(_steal_tex, Input.CURSOR_ARROW, Vector2(6, 4))


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
		if spent and not _toss_pick:
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


func set_shuriken_facing(points_left: bool) -> void:
	if _icon != null:
		_icon.flip_h = points_left
		var arc: Node = _icon.get_node_or_null("MoveArc")
		if arc != null and arc.has_method("set_points_left"):
			arc.set_points_left(points_left)


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


func stop_marble_idle() -> void:
	if _marble_fx == null or not _marble_fx.visible:
		return
	_marble_fx.visible = false
	_marble_fx.stop()
	if _icon:
		_icon.modulate.a = 1.0


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
	# Fly a ghost owned by this card (top_level). Parenting to the tree root
	# left marbles stranded over the hotbar when the card was rebuilt.
	var dest: Vector2 = global_position + size * 0.5
	var ghost := AnimatedSprite2D.new()
	ghost.name = "MarbleRoll"
	ghost.centered = true
	ghost.texture_filter = TEXTURE_FILTER_NEAREST
	ghost.scale = Vector2(2, 2)
	ghost.z_index = 40
	ghost.z_as_relative = false
	ghost.top_level = true
	ghost.sprite_frames = _marble_frames()
	if ghost.sprite_frames.has_animation("idle"):
		ghost.play("idle")
	add_child(ghost)
	ghost.global_position = from_global
	ghost.rotation = 0.85
	ghost.modulate.a = 0.25
	var tw := ghost.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(ghost, "global_position", dest, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(ghost, "rotation", 0.0, 0.22)
	tw.parallel().tween_property(ghost, "modulate:a", 1.0, 0.18)
	tw.finished.connect(ghost.queue_free, CONNECT_ONE_SHOT)
	await tw.finished


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
		_overlay_host().add_child(_armed_lab)
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
	if not _playable and not _toss_pick and not spent and not _showcase and not _guarding:
		desat = 0.6
	RANK_SHIMMER.apply(_shimmer_mat, _tier, uid, desat, 1.0 if _armed else 0.0, _shimmer_clock, size if size.x > 8.0 else Vector2(CARD_W, CARD_H))


func _force_glint() -> void:
	_shimmer_clock = -RANK_SHIMMER.phase_of(uid, _tier)
	_tick_shimmer()


func _tween_sink(sink: bool) -> void:
	if _selector_dim:
		return
	var target: Color = Color(0.70, 0.70, 0.70, 1.0) if sink else Color.WHITE
	if spent:
		target = Color(0.86, 0.84, 0.80, 1.0)
	if _glow or _aura or _log_focus or _danger or _toss_pick:
		return
	if _petrified and not _petrify_dummy:
		return
	if _stone != null and _stone.visible:
		return
	if _sink_tw != null and is_instance_valid(_sink_tw):
		_sink_tw.kill()
	_sink_tw = create_tween()
	_sink_tw.tween_property(self, "modulate", target, 0.16)
	_desat = 0.6 if sink else 0.0


func _tick_waiting_hover() -> void:
	pivot_offset = size * 0.5
	var bob: float = sin(_shimmer_clock * TAU * 0.85) * 7.0
	position.y = _wait_base_y + bob
	rotation = sin(_shimmer_clock * TAU * 0.42) * 0.05
	var s: float = 1.06 + 0.02 * sin(_shimmer_clock * TAU * 0.85)
	scale = Vector2(s, s)


func _tick_breathe() -> void:
	if _waiting_entry or _showcase or _hot or spent or not _playable or _sai_busy or _marble_busy:
		return
	pivot_offset = size * 0.5
	var s: float = 1.0 + 0.015 * sin(_shimmer_clock * TAU * 0.5)
	s = snappedf(s, 0.005)
	if is_equal_approx(scale.x, s):
		return
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
	_place_fx()


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
