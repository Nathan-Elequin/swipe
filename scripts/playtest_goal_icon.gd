extends Control
## Persistent playtest goal chip (slice 2). Top-left pictograph + progress hint + hover tip.
## Slice 4: done-BIG click reopens the compact victory-code card.
## Lives on CanvasLayer 220 so intro, teaser, hub, dialog, and combat never cover it.

signal victory_code_wanted

const COPY := preload("res://scripts/player_copy.gd")
const C := preload("res://scripts/playtest_commitment.gd")
const GLYPH := preload("res://scripts/commitment_tier_glyph.gd")

const SIZE := Vector2(56, 64)
const COL_GOLD := Color("e8c36a")
const COL_INK := Color("100e0c")
const COL_PANEL := Color("1a1410f5")
const COL_BODY := Color("f4ede3")

var _tier: int = C.TIER_NONE
var _done: bool = false
var _progress: String = ""
var _offramp_shown_big: bool = false
var _panel: PanelContainer
var _glyph: Control
var _hint: Label
var _tip: PanelContainer
var _tip_body: Label
var _hover: bool = false


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
	_place_tip(true)


func hide_tip() -> void:
	_hover = false
	if _tip:
		_tip.visible = false


func _build() -> void:
	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_PANEL
	sb.border_color = COL_GOLD
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	_panel.add_theme_stylebox_override("panel", sb)
	add_child(_panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(col)

	_glyph = GLYPH.new()
	_glyph.custom_minimum_size = Vector2(40, 32)
	_glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_glyph)

	_hint = Label.new()
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 12)
	_hint.add_theme_color_override("font_color", COL_GOLD)
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_hint)

	_tip = PanelContainer.new()
	_tip.visible = false
	_tip.z_index = 2
	_tip.top_level = true
	_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tsb := StyleBoxFlat.new()
	tsb.bg_color = COL_PANEL
	tsb.border_color = COL_GOLD
	tsb.set_border_width_all(2)
	tsb.set_corner_radius_all(8)
	tsb.content_margin_left = 12
	tsb.content_margin_right = 12
	tsb.content_margin_top = 8
	tsb.content_margin_bottom = 8
	_tip.add_theme_stylebox_override("panel", tsb)
	add_child(_tip)
	_tip_body = Label.new()
	_tip_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tip_body.custom_minimum_size = Vector2(280, 0)
	_tip_body.add_theme_font_size_override("font_size", 14)
	_tip_body.add_theme_color_override("font_color", COL_BODY)
	_tip_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tip.add_child(_tip_body)

	mouse_entered.connect(func() -> void:
		_hover = true
		_place_tip(true)
	)
	mouse_exited.connect(func() -> void:
		_hover = false
		_tip.visible = false
	)
	gui_input.connect(_on_gui_input)


func _refresh() -> void:
	if _glyph != null:
		_glyph.set("tier", _tier)
		_glyph.queue_redraw()
	if _hint:
		_hint.text = _progress
	if _tip_body:
		_tip_body.text = _tip_text()
	if _hover:
		_place_tip(true)


func _tip_text() -> String:
	if _done and _tier >= C.TIER_BIG and _offramp_shown_big:
		return COPY.text(
			"playtest.goal.done_big",
			"Shadow Abyss reached! Click for your victory code."
		)
	if _done:
		return COPY.text("playtest.goal.done", "Goal complete! Keep playing, or go deeper from the pause menu.")
	match _tier:
		C.TIER_QUICK:
			return COPY.text("playtest.goal.quick", "Goal: Finish your first solo run and come home.")
		C.TIER_DEEPER:
			return COPY.text("playtest.goal.deeper", "Goal: Pull the Verdant Hollow lever and finish a run in the Crystal Cavern.")
		C.TIER_BIG:
			return COPY.text("playtest.goal.big", "Goal: Finish a run that reaches the Shadow Abyss.")
	return ""


func _on_gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if not (_done and _tier >= C.TIER_BIG and _offramp_shown_big):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		victory_code_wanted.emit()
		accept_event()


func _place_tip(show: bool) -> void:
	if _tip == null or _tip_body == null:
		return
	_tip_body.text = _tip_text()
	_tip.visible = show and visible and _tier > C.TIER_NONE
	if not _tip.visible:
		return
	_tip.reset_size()
	var tip_sz: Vector2 = _tip.get_combined_minimum_size()
	_tip.size = tip_sz
	var anchor: Vector2 = global_position + Vector2(size.x + 8.0, 0.0)
	var vp: Vector2 = get_viewport_rect().size
	anchor.x = minf(anchor.x, vp.x - tip_sz.x - 16.0)
	anchor.y = clampf(anchor.y, 16.0, maxf(16.0, vp.y - tip_sz.y - 16.0))
	_tip.global_position = anchor

