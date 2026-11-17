extends Control
## Persistent playtest goal ring + progress ticker (Living trophy room visuals).
## Keeps apply_state / victory_code_wanted / tip keys. Lives on CanvasLayer 220.

signal victory_code_wanted

const COPY := preload("res://scripts/player_copy.gd")
const C := preload("res://scripts/playtest_commitment.gd")
const BIOME := preload("res://scripts/ui/biome_progress.gd")

const SIZE := Vector2(78, 78)
const COL_GOLD := Color("e8c36a")
const COL_PANEL := Color("1a1410f5")
const COL_BODY := Color("f4ede3")
const FONT_SEMI := "res://assets/ui/fonts/open_sans/OpenSans-SemiBold.ttf"

var _tier: int = C.TIER_NONE
var _done: bool = false
var _progress: String = ""
var _offramp_shown_big: bool = false
var _ring: TextureRect
var _tip: PanelContainer
var _tip_body: Label
var _ticker: PanelContainer
var _ticker_icons: Array = []
var _ticker_pcts: Array = []
var _hover: bool = false
var _grace_left: float = 0.0
var _twinkle: AnimatedSprite2D
var _pulse_t: float = 0.0
var reduce_motion: bool = false
var _audio = null
var _last_ticker_sfx_ms: int = -999999


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	name = "playtest_goal_icon"
	z_index = 1
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = SIZE
	size = SIZE
	set_anchors_preset(PRESET_TOP_LEFT)
	offset_left = 16
	offset_top = 16
	offset_right = 16 + SIZE.x
	offset_bottom = 16 + SIZE.y
	_build()


func apply_state(
	tier: int,
	reached_quick: bool,
	reached_deeper: bool,
	reached_big: bool,
	offramp_shown_big: bool = false
) -> void:
	_tier = clampi(int(tier), C.TIER_NONE, C.TIER_BIG)
	_offramp_shown_big = bool(offramp_shown_big)
	match _tier:
		C.TIER_QUICK:
			_done = reached_quick
			_progress = "✓" if _done else "·"
		C.TIER_DEEPER:
			_done = reached_deeper
			_progress = "✓" if _done else "·"
		C.TIER_BIG:
			_done = reached_big
			_progress = "✓" if _done else "·"
		_:
			_done = false
			_progress = ""
	visible = _tier > C.TIER_NONE
	_refresh()


func icon_global_center() -> Vector2:
	return global_position + size * 0.5


func show_tip_for_shot() -> void:
	_hover = true
	_grace_left = 0.0
	## Instant final pose for screenshots / selftests (no open tween).
	if _ticker:
		_ticker.visible = visible and _tier > C.TIER_NONE
		_ticker.modulate.a = 1.0
		_ticker.position = Vector2(100, 14)
		_ticker.size = Vector2(436, 100)
	_place_tip(true)


func hide_tip() -> void:
	_hover = false
	if _tip:
		_tip.visible = false
	if _ticker:
		_ticker.visible = false


func set_progress_snapshot(p: Dictionary) -> void:
	_paint_ticker(p)


func _build() -> void:
	_ring = TextureRect.new()
	_ring.name = "GoalRing"
	_ring.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_ring.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_ring.stretch_mode = TextureRect.STRETCH_SCALE
	_ring.texture_filter = TEXTURE_FILTER_NEAREST
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_ring)

	_twinkle = AnimatedSprite2D.new()
	_twinkle.name = "Twinkle"
	_twinkle.centered = false
	_twinkle.position = Vector2(20 * 3, 3 * 3) ## native (20,3) at 3x ≈ ring-local
	_twinkle.scale = Vector2(3, 3)
	_twinkle.visible = false
	_twinkle.texture_filter = TEXTURE_FILTER_NEAREST
	var sf := SpriteFrames.new()
	sf.add_animation(&"loop")
	sf.set_animation_speed(&"loop", 12.0)
	sf.set_animation_loop(&"loop", true)
	for f in range(4):
		var path := "res://assets/ui/trophy_board/twinkle_f%d.png" % f
		if ResourceLoader.exists(path):
			sf.add_frame(&"loop", load(path) as Texture2D)
	_twinkle.sprite_frames = sf
	add_child(_twinkle)

	_ticker = PanelContainer.new()
	_ticker.name = "ProgressTicker"
	_ticker.visible = false
	_ticker.z_index = 2
	_ticker.top_level = true
	_ticker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ticker.position = Vector2(100, 14)
	_ticker.size = Vector2(436, 100)
	_ticker.custom_minimum_size = Vector2(436, 100)
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = COL_PANEL
	tsb.border_color = COL_GOLD
	tsb.set_border_width_all(2)
	tsb.set_corner_radius_all(8)
	tsb.content_margin_left = 18
	tsb.content_margin_right = 18
	tsb.content_margin_top = 14
	tsb.content_margin_bottom = 14
	_ticker.add_theme_stylebox_override("panel", tsb)
	add_child(_ticker)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ticker.add_child(hbox)
	var font := load(FONT_SEMI) as Font if ResourceLoader.exists(FONT_SEMI) else ThemeDB.fallback_font
	for i in range(5):
		var wrap := Control.new()
		wrap.custom_minimum_size = Vector2(72, 72)
		wrap.size = Vector2(72, 72)
		wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.add_child(wrap)
		var icon := TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_SCALE
		icon.texture_filter = TEXTURE_FILTER_NEAREST
		icon.position = Vector2.ZERO
		icon.size = Vector2(72, 72)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrap.add_child(icon)
		_ticker_icons.append(icon)
		var pct := Label.new()
		pct.position = Vector2(16, 46)
		pct.size = Vector2(40, 14)
		pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pct.add_theme_font_override("font", font)
		pct.add_theme_font_size_override("font_size", 13)
		pct.add_theme_color_override("font_color", COL_GOLD)
		pct.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pct.visible = false
		wrap.add_child(pct)
		_ticker_pcts.append(pct)

	_tip = PanelContainer.new()
	_tip.visible = false
	_tip.z_index = 2
	_tip.top_level = true
	_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tip_sb := StyleBoxFlat.new()
	tip_sb.bg_color = COL_PANEL
	tip_sb.border_color = COL_GOLD
	tip_sb.set_border_width_all(2)
	tip_sb.set_corner_radius_all(8)
	tip_sb.content_margin_left = 12
	tip_sb.content_margin_right = 12
	tip_sb.content_margin_top = 8
	tip_sb.content_margin_bottom = 8
	_tip.add_theme_stylebox_override("panel", tip_sb)
	add_child(_tip)
	_tip_body = Label.new()
	_tip_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip_body.custom_minimum_size = Vector2(412, 0)
	_tip_body.add_theme_font_size_override("font_size", 14)
	_tip_body.add_theme_color_override("font_color", COL_BODY)
	_tip_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tip.add_child(_tip_body)

	mouse_entered.connect(func() -> void:
		_hover = true
		_grace_left = 0.0
		_place_ticker(true)
		_place_tip(true)
	)
	mouse_exited.connect(func() -> void:
		_hover = false
		_grace_left = 0.12
	)
	gui_input.connect(_on_gui_input)
	_paint_ticker(BIOME.snapshot())


func _refresh() -> void:
	if _ring:
		_ring.texture = _ring_tex_for(_tier)
	var show_twinkle := _done and _tier > C.TIER_NONE and not reduce_motion
	if _twinkle:
		_twinkle.visible = show_twinkle
		if show_twinkle:
			_twinkle.play(&"loop")
		else:
			_twinkle.pause()
			_twinkle.frame = 0
	if _tip_body:
		_tip_body.text = _tip_text()
	if _hover:
		_place_ticker(true)
		_place_tip(true)


func _ring_tex_for(tier: int) -> Texture2D:
	var stem := ""
	match tier:
		C.TIER_QUICK:
			stem = "quick"
		C.TIER_DEEPER:
			stem = "deeper"
		C.TIER_BIG:
			stem = "big"
		_:
			return null
	var path := "res://assets/ui/title/goal/goal_ring_%s.png" % stem
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _paint_ticker(p: Dictionary) -> void:
	var slugs: Array = BIOME.SLUGS
	for i in range(mini(5, slugs.size())):
		var slug: String = str(slugs[i])
		var row: Dictionary = p.get(slug, {"state": &"gray", "pct": 0})
		if typeof(row) != TYPE_DICTIONARY:
			row = {"state": &"gray", "pct": 0}
		var state := StringName(str(row.get("state", "gray")))
		var pct := int(row.get("pct", 0))
		var full := BIOME.full_slug(slug)
		var stem := "gray"
		match state:
			&"cleared":
				stem = "cleared"
			&"entered":
				stem = "entered"
			_:
				stem = "gray"
		var path := "res://assets/ui/title/progress/biome_%s_%s.png" % [full, stem]
		if i < _ticker_icons.size() and ResourceLoader.exists(path):
			_ticker_icons[i].texture = load(path) as Texture2D
			_ticker_icons[i].expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			_ticker_icons[i].size = Vector2(72, 72)
		if i < _ticker_pcts.size():
			var show_pct := state == &"entered"
			_ticker_pcts[i].visible = show_pct
			if show_pct:
				_ticker_pcts[i].text = "%d%%" % pct


func _tip_text() -> String:
	if _done and _tier >= C.TIER_BIG and _offramp_shown_big:
		return COPY.text(
			"playtest.goal.done_big",
			"playtest.goal.done_big"
		)
	if _done:
		return COPY.text("playtest.goal.done", "playtest.goal.done")
	match _tier:
		C.TIER_QUICK:
			return COPY.text("playtest.goal.quick", "playtest.goal.quick")
		C.TIER_DEEPER:
			return COPY.text("playtest.goal.deeper", "playtest.goal.deeper")
		C.TIER_BIG:
			return COPY.text("playtest.goal.big", "playtest.goal.big")
	return ""


func _on_gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if not (_done and _tier >= C.TIER_BIG and _offramp_shown_big):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		victory_code_wanted.emit()
		accept_event()


func _place_ticker(show: bool) -> void:
	if _ticker == null:
		return
	var was := _ticker.visible
	_ticker.visible = show and visible and _tier > C.TIER_NONE
	_ticker.position = Vector2(100, 14)
	_ticker.size = Vector2(436, 100)
	## Keep inside x≤560, y≤120.
	if _ticker.position.x + _ticker.size.x > 560.0:
		_ticker.position.x = 560.0 - _ticker.size.x
	if _ticker.position.y + _ticker.size.y > 120.0:
		_ticker.position.y = maxf(0.0, 120.0 - _ticker.size.y)
	if _ticker.visible and not was:
		var now := Time.get_ticks_msec()
		if now - _last_ticker_sfx_ms >= 500:
			_last_ticker_sfx_ms = now
			if _audio and _audio.has_method("play_event"):
				_audio.play_event(&"ui.ticker_open")
		if not reduce_motion:
			_ticker.modulate.a = 0.0
			_ticker.position.y = 8
			var tw := create_tween().bind_node(self)
			tw.tween_property(_ticker, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.parallel().tween_property(_ticker, "position:y", 14.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _place_tip(show: bool) -> void:
	if _tip == null or _tip_body == null:
		return
	_tip_body.text = _tip_text()
	_tip.visible = show and visible and _tier > C.TIER_NONE
	if not _tip.visible:
		return
	_tip.reset_size()
	var tip_sz: Vector2 = _tip.get_combined_minimum_size()
	_tip.size = Vector2(436, maxf(tip_sz.y, 40.0))
	## Under the ticker: (100,122), width 436.
	_tip.position = Vector2(100, 122)


func _process(delta: float) -> void:
	if _grace_left > 0.0 and not _hover:
		_grace_left -= delta
		if _grace_left <= 0.0:
			if _ticker:
				_ticker.visible = false
			if _tip:
				_tip.visible = false
	if _done and _ring and visible and not reduce_motion:
		_pulse_t += delta
		var a: float = 1.0 + 0.15 * (0.5 + 0.5 * sin(_pulse_t * (TAU / 1.6)))
		_ring.modulate = Color(a, a, a, 1.0)
	elif _ring:
		_ring.modulate = Color.WHITE
