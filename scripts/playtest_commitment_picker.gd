extends ColorRect
## Playtest commitment picker — Living trophy room card visuals.
## Keeps chosen/cancelled signals, open_picker/close_picker, card_icon_center.

signal chosen(tier: int, upgrade: bool)
signal cancelled

const COPY := preload("res://scripts/player_copy.gd")
const C := preload("res://scripts/playtest_commitment.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")

const FONT_TITLE := "res://assets/ui/fonts/eb_garamond/EBGaramond-SemiBold.ttf"
const FONT_SEMI := "res://assets/ui/fonts/open_sans/OpenSans-SemiBold.ttf"
const FONT_REG := "res://assets/ui/fonts/open_sans/OpenSans-Regular.ttf"

const COL_BG := Color("100e0c")
const COL_BORDER := Color("6b5235")
const COL_BORDER_HOVER := Color("e8c36a")
const COL_BORDER_PRESS := Color("ffe0a1")
const COL_TITLE := Color("e8c36a")
const COL_BODY := Color("f4ede3")
const COL_MUTED := Color("b6a78e")
const COL_DIM := Color(0.45, 0.4, 0.35, 1.0)

var _upgrade: bool = false
var _min_enabled: int = C.TIER_QUICK
var _current_tier: int = C.TIER_NONE
var _reached: Dictionary = {}
var _focus_i: int = 0
var _busy: bool = false
var _cards: Array = []
var _card_nodes: Array = []
var _title: Label
var _back: Button
var _arm: float = 0.0
var _audio = null
var reduce_motion: bool = false
var _base_ys: Dictionary = {}


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = COL_BG
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 140
	visible = false
	name = "playtest_commitment_picker"
	_build()


func open_picker(mode: String = "choose", current_tier: int = C.TIER_NONE, reached: Dictionary = {}) -> void:
	_upgrade = str(mode) == "upgrade"
	_current_tier = clampi(int(current_tier), C.TIER_NONE, C.TIER_BIG)
	_reached = reached.duplicate(true) if typeof(reached) == TYPE_DICTIONARY else {}
	_min_enabled = (_current_tier + 1) if _upgrade else C.TIER_QUICK
	_busy = false
	_arm = 0.2
	_focus_i = _default_focus()
	_refresh_cards()
	visible = true
	move_to_front()
	call_deferred("_grab_focus_card")


func close_picker() -> void:
	visible = false
	_busy = false


func card_global_rect(tier: int) -> Rect2:
	for n in _card_nodes:
		if int(n.get_meta("tier", 0)) == tier:
			return n.get_global_rect()
	return Rect2()


func card_icon_center(tier: int) -> Vector2:
	var r: Rect2 = card_global_rect(tier)
	if r.size.x < 4.0:
		return get_viewport_rect().size * 0.5
	## GoalMark centre roughly at card-local (181+39, 290+39).
	return r.position + Vector2(220.0, 329.0)


func _default_focus() -> int:
	for i in range(_cards.size()):
		if _tier_enabled(int(_cards[i].get("tier", 0))):
			return i
	return 0


func _font(path: String) -> Font:
	if ResourceLoader.exists(path):
		return load(path) as Font
	return ThemeDB.fallback_font


func _tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null


func _build() -> void:
	## Backdrop
	var bg := TextureRect.new()
	bg.texture = _tex("res://assets/ui/biome_splash/bg_verdant.png")
	bg.texture_filter = TEXTURE_FILTER_NEAREST
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP
	bg.position = Vector2(0, 0)
	bg.size = Vector2(1680, 832)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var floor_c := ColorRect.new()
	floor_c.color = Color("0b0908")
	floor_c.position = Vector2(0, 832)
	floor_c.size = Vector2(1680, 208)
	floor_c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(floor_c)
	var dim := ColorRect.new()
	dim.color = Color(0.043, 0.035, 0.031, 0.68)
	dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)

	_title = Label.new()
	_title.position = Vector2(80, 46)
	_title.size = Vector2(1520, 72)
	_title.add_theme_font_override("font", _font(FONT_TITLE))
	_title.add_theme_font_size_override("font_size", 64)
	_title.add_theme_color_override("font_color", COL_BODY)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title)

	_cards = [
		{
			"tier": C.TIER_QUICK,
			"id": "quick",
			"slug": "verdant",
			"splash": "verdant",
			"monster": "goblin",
			"native": 48,
			"scale": 5.0,
			"title_key": "playtest.tier.quick.title",
			"biome_key": "playtest.tier.quick.biome",
			"goal_key": "playtest.tier.quick.goal",
			"time_key": "playtest.tier.quick.time",
			"line_key": "playtest.tier.quick.line",
			"pick_key": "picker.pick.quick",
		},
		{
			"tier": C.TIER_DEEPER,
			"id": "deeper",
			"slug": "crystal",
			"splash": "crystal",
			"monster": "gargoyle",
			"native": 48,
			"scale": 5.0,
			"title_key": "playtest.tier.deeper.title",
			"biome_key": "playtest.tier.deeper.biome",
			"goal_key": "playtest.tier.deeper.goal",
			"time_key": "playtest.tier.deeper.time",
			"line_key": "playtest.tier.deeper.line",
			"pick_key": "picker.pick.deeper",
		},
		{
			"tier": C.TIER_BIG,
			"id": "big",
			"slug": "shadow",
			"splash": "shadow",
			"monster": "lich",
			"native": 64,
			"scale": 4.0,
			"title_key": "playtest.tier.big.title",
			"biome_key": "playtest.tier.big.biome",
			"goal_key": "playtest.tier.big.goal",
			"time_key": "playtest.tier.big.time",
			"line_key": "playtest.tier.big.line",
			"pick_key": "picker.pick.big",
		},
	]
	_card_nodes.clear()
	for i in range(_cards.size()):
		var card: PanelContainer = _make_card(_cards[i], i)
		add_child(card)
		_card_nodes.append(card)
		_base_ys[card] = card.position.y

	_back = Button.new()
	_back.name = "Back"
	_back.flat = true
	_back.focus_mode = Control.FOCUS_ALL
	_back.position = Vector2(56, 830)
	_back.size = Vector2(250, 32)
	_back.add_theme_font_override("font", _font(FONT_REG))
	_back.add_theme_font_size_override("font_size", 18)
	_back.add_theme_color_override("font_color", COL_MUTED)
	_back.add_theme_color_override("font_hover_color", COL_BODY)
	_back.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_back.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	_back.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_back.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_back.text = COPY.text("picker.back", "Back")
	_back.pressed.connect(func() -> void:
		if _upgrade:
			close_picker()
			cancelled.emit()
	)
	add_child(_back)


func _make_card(spec: Dictionary, index: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.position = Vector2(124 + 500 * index, 206)
	card.custom_minimum_size = Vector2(440, 586)
	card.size = Vector2(440, 586)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.focus_mode = Control.FOCUS_ALL
	card.set_meta("tier", int(spec.get("tier", 0)))
	card.set_meta("spec", spec)
	card.set_meta("id", str(spec.get("id", "")))
	card.pivot_offset = Vector2(220, 293)
	card.gui_input.connect(_on_card_gui.bind(card))
	card.focus_entered.connect(func() -> void:
		_focus_i = _index_of_card(card)
		_paint_focus()
	)
	card.mouse_entered.connect(func() -> void:
		if _busy:
			return
		if _tier_enabled(int(card.get_meta("tier", 0))):
			_focus_i = _index_of_card(card)
			_paint_focus()
	)
	card.mouse_exited.connect(func() -> void:
		_reset_card_hover(card)
	)

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("100e0c")
	sb.border_color = COL_BORDER
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(0)
	sb.shadow_color = Color("080706")
	sb.shadow_size = 0
	sb.shadow_offset = Vector2(0, 10)
	sb.content_margin_left = 0
	sb.content_margin_right = 0
	sb.content_margin_top = 0
	sb.content_margin_bottom = 0
	card.add_theme_stylebox_override("panel", sb)
	card.set_meta("style", sb)

	var root := Control.new()
	root.custom_minimum_size = Vector2(440, 586)
	root.size = Vector2(440, 586)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.clip_contents = true
	card.add_child(root)

	var art := TextureRect.new()
	art.name = "Art"
	art.texture = _tex("res://assets/ui/biome_splash/bg_%s.png" % str(spec.get("splash", "verdant")))
	art.texture_filter = TEXTURE_FILTER_NEAREST
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.position = Vector2(-204, 0)
	art.size = Vector2(840, 416)
	## Dim deep splash under the vignette (SCREEN-title §3 + batch2 picker art).
	art.modulate = Color(0.42, 0.38, 0.34, 1.0)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(art)

	## Native 200×112 vignette shown at 2× = 400×224; side margin 20 px; bottom ≤ y 240.
	var vignette := TextureRect.new()
	vignette.name = "Vignette"
	vignette.texture = _tex("res://assets/ui/title/picker/card_vignette_%s.png" % str(spec.get("id", "quick")))
	vignette.texture_filter = TEXTURE_FILTER_NEAREST
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.position = Vector2(20, 12)
	vignette.size = Vector2(400, 224)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(vignette)

	var fade := TextureRect.new()
	fade.name = "Fade"
	fade.position = Vector2(0, 240)
	fade.size = Vector2(432, 346)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var grad := GradientTexture2D.new()
	grad.width = 4
	grad.height = 64
	grad.fill_from = Vector2(0.5, 0.0)
	grad.fill_to = Vector2(0.5, 1.0)
	var g := Gradient.new()
	g.colors = PackedColorArray([Color(0.0627, 0.0549, 0.0471, 0.0), Color("100e0c")])
	g.offsets = PackedFloat32Array([0.0, 0.24])
	grad.gradient = g
	fade.texture = grad
	fade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fade.stretch_mode = TextureRect.STRETCH_SCALE
	## LINEAR for gradient only is fine; documented exception is intro preview.
	root.add_child(fade)

	var spr := AnimatedSprite2D.new()
	spr.name = "Presenter"
	spr.centered = true
	spr.position = Vector2(220, 166)
	spr.scale = Vector2(float(spec.get("scale", 5.0)), float(spec.get("scale", 5.0)))
	spr.texture_filter = TEXTURE_FILTER_NEAREST
	spr.sprite_frames = _presenter_frames(str(spec.get("monster", "goblin")))
	spr.animation = &"idle"
	spr.frame = 0
	spr.pause()
	root.add_child(spr)
	card.set_meta("presenter", spr)

	var ring := TextureRect.new()
	ring.name = "GoalMark"
	ring.texture = _tex("res://assets/ui/title/goal/goal_ring_%s.png" % str(spec.get("id", "quick")))
	ring.texture_filter = TEXTURE_FILTER_NEAREST
	ring.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ring.stretch_mode = TextureRect.STRETCH_SCALE
	ring.position = Vector2(181, 290)
	ring.size = Vector2(78, 78)
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(ring)

	var title := Label.new()
	title.name = "Title"
	title.position = Vector2(30, 386)
	title.size = Vector2(380, 40)
	title.add_theme_font_override("font", _font(FONT_TITLE))
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", COL_TITLE)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(title)

	var biome := Label.new()
	biome.name = "Biome"
	biome.position = Vector2(30, 432)
	biome.size = Vector2(380, 28)
	biome.add_theme_font_override("font", _font(FONT_SEMI))
	biome.add_theme_font_size_override("font_size", 21)
	biome.add_theme_color_override("font_color", COL_BODY)
	biome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(biome)

	## Short goal (includes time). Longer .line text is the card tooltip.
	var goal := Label.new()
	goal.name = "Goal"
	goal.position = Vector2(30, 470)
	goal.size = Vector2(380, 40)
	goal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal.max_lines_visible = 2
	goal.add_theme_font_override("font", _font(FONT_REG))
	goal.add_theme_font_size_override("font_size", 18)
	goal.add_theme_color_override("font_color", COL_MUTED)
	goal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(goal)
	var line := Label.new()
	line.name = "Line"
	line.visible = false
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(line)

	var pick := KIT.choice_tag(str(spec.get("pick_key", "picker.pick.quick")), Vector2(88, 14))
	pick.name = "Pick"
	pick.position = Vector2(44, 518)
	pick.focus_mode = Control.FOCUS_ALL
	pick.text = COPY.text(str(spec.get("pick_key", "")), "Pick")
	pick.pressed.connect(func() -> void:
		_focus_i = _index_of_card(card)
		_confirm_focus()
	)
	root.add_child(pick)

	return card


func _presenter_frames(monster: String) -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.add_animation(&"idle")
	sf.add_animation(&"present")
	sf.set_animation_speed(&"idle", 4.0)
	sf.set_animation_loop(&"idle", true)
	sf.set_animation_speed(&"present", 10.0)
	sf.set_animation_loop(&"present", false)
	for f in range(4):
		var p := "res://assets/dungeon/anim/facing/%s_facing_idle_f%d.png" % [monster, f]
		var t := _tex(p)
		if t:
			sf.add_frame(&"idle", t)
	var have_present := true
	for f in range(4):
		var pp := "res://assets/ui/title/presenters/%s_present_f%d.png" % [monster, f]
		var pt := _tex(pp)
		if pt == null:
			have_present = false
			break
		sf.add_frame(&"present", pt)
	if not have_present:
		sf.clear(&"present")
		sf.set_animation_speed(&"present", 8.0)
		for f in range(sf.get_frame_count(&"idle")):
			sf.add_frame(&"present", sf.get_frame_texture(&"idle", f))
	return sf


func _refresh_cards() -> void:
	if _title:
		var key := "playtest.tier.upgrade_title" if _upgrade else "playtest.tier.choose_title"
		_title.text = COPY.text(key, "")
	if _back:
		_back.visible = _upgrade
	for i in range(_card_nodes.size()):
		var card: PanelContainer = _card_nodes[i]
		var spec: Dictionary = _cards[i]
		var tier: int = int(spec.get("tier", 0))
		var enabled: bool = _tier_enabled(tier)
		var title_l: Label = card.find_child("Title", true, false) as Label
		var biome_l: Label = card.find_child("Biome", true, false) as Label
		var goal_l: Label = card.find_child("Goal", true, false) as Label
		var line_l: Label = card.find_child("Line", true, false) as Label
		var pick_b: Button = card.find_child("Pick", true, false) as Button
		var title_txt := COPY.text(str(spec.get("title_key", "")), "")
		var bk := "biome.name.%s" % str(spec.get("slug", "verdant"))
		var biome_txt := COPY.text(bk, "")
		if biome_txt == "" and str(spec.get("biome_key", "")) != "":
			biome_txt = COPY.text(str(spec.get("biome_key", "")), "")
		var goal_txt := COPY.text(str(spec.get("goal_key", "")), "")
		var line_txt := COPY.text(str(spec.get("line_key", "")), "")
		if title_l:
			title_l.text = title_txt
		if biome_l:
			biome_l.text = biome_txt
		if goal_l:
			goal_l.text = goal_txt
		if line_l:
			line_l.text = COPY.text(str(spec.get("time_key", "")), "")
		if pick_b:
			pick_b.text = COPY.text(str(spec.get("pick_key", "")), "Pick")
			pick_b.disabled = not enabled
		## Longer .line copy lives on the card tooltip (hover / focus).
		card.tooltip_text = line_txt
		card.modulate = Color.WHITE if enabled else COL_DIM
		card.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW
	_paint_focus()


func _tier_enabled(tier: int) -> bool:
	return tier >= _min_enabled and tier <= C.TIER_BIG


func _index_of_card(card: Control) -> int:
	for i in range(_card_nodes.size()):
		if _card_nodes[i] == card:
			return i
	return 0


func _paint_focus() -> void:
	for i in range(_card_nodes.size()):
		var card: PanelContainer = _card_nodes[i]
		var sb: StyleBoxFlat = card.get_meta("style") as StyleBoxFlat
		if sb == null:
			continue
		var tier: int = int(card.get_meta("tier", 0))
		var enabled: bool = _tier_enabled(tier)
		var focused: bool = enabled and i == _focus_i
		sb.border_color = COL_BORDER_HOVER if focused else COL_BORDER
		card.add_theme_stylebox_override("panel", sb)
		var base_y: float = float(_base_ys.get(card, card.position.y))
		var spr: AnimatedSprite2D = card.get_meta("presenter") as AnimatedSprite2D
		if focused and not reduce_motion:
			if absf(card.position.y - (base_y - 8.0)) > 0.5:
				var tw := create_tween().bind_node(self)
				tw.tween_property(card, "position:y", base_y - 8.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			if spr:
				spr.play(&"idle")
			if _audio and _audio.has_method("play_event"):
				_audio.play_event(&"ui.picker_hover", {"goal": str(card.get_meta("id", ""))})
		else:
			card.position.y = base_y
			if spr:
				spr.pause()
				spr.frame = 0
				spr.animation = &"idle"


func _reset_card_hover(card: Control) -> void:
	if _index_of_card(card) == _focus_i:
		return
	var base_y: float = float(_base_ys.get(card, card.position.y))
	card.position.y = base_y
	var spr: AnimatedSprite2D = card.get_meta("presenter") as AnimatedSprite2D
	if spr:
		spr.pause()
		spr.frame = 0


func _grab_focus_card() -> void:
	if _focus_i >= 0 and _focus_i < _card_nodes.size():
		var card: Control = _card_nodes[_focus_i]
		if card.focus_mode != Control.FOCUS_NONE:
			card.grab_focus()


func _process(delta: float) -> void:
	if not visible:
		return
	if _arm > 0.0:
		_arm -= delta


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _busy:
		return
	if event.is_action_pressed("ui_cancel") and _upgrade:
		close_picker()
		cancelled.emit()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
		_move_focus(-1)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		_move_focus(1)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept"):
		_confirm_focus()
		get_viewport().set_input_as_handled()


func _move_focus(dir: int) -> void:
	if _card_nodes.is_empty():
		return
	var i := _focus_i
	for _n in range(_card_nodes.size()):
		i = (i + dir) % _card_nodes.size()
		if i < 0:
			i = _card_nodes.size() - 1
		var tier: int = int(_card_nodes[i].get_meta("tier", 0))
		if _tier_enabled(tier):
			_focus_i = i
			_paint_focus()
			_grab_focus_card()
			return


func _on_card_gui(event: InputEvent, card: Control) -> void:
	if _busy or _arm > 0.0:
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var tier: int = int(card.get_meta("tier", 0))
	if not _tier_enabled(tier):
		return
	_focus_i = _index_of_card(card)
	_paint_focus()
	_confirm_focus()


func _confirm_focus() -> void:
	if _busy or _focus_i < 0 or _focus_i >= _card_nodes.size():
		return
	var tier: int = int(_card_nodes[_focus_i].get_meta("tier", 0))
	if not _tier_enabled(tier):
		return
	_busy = true
	var card: Control = _card_nodes[_focus_i]
	var sb: StyleBoxFlat = card.get_meta("style") as StyleBoxFlat
	if sb:
		sb.border_color = COL_BORDER_PRESS
		card.add_theme_stylebox_override("panel", sb)
	if not reduce_motion:
		var base_y: float = float(_base_ys.get(card, card.position.y))
		var tw := create_tween().bind_node(self)
		tw.tween_property(card, "position:y", base_y + 4.0, 0.08)
		tw.tween_property(card, "position:y", base_y - 8.0, 0.08)
		var spr: AnimatedSprite2D = card.get_meta("presenter") as AnimatedSprite2D
		if spr:
			spr.play(&"present")
	if _audio and _audio.has_method("play_event"):
		_audio.play_event(&"ui.picker_confirm")
	chosen.emit(tier, _upgrade)


## Source contract helpers for selftests.
static func shows_only_when_tier_none(tier: int) -> bool:
	return tier == C.TIER_NONE


static func upgrade_disables_lower(current_tier: int, candidate: int) -> bool:
	return candidate <= current_tier
