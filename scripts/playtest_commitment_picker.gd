extends ColorRect
## Playtest commitment tier picker (slice 2 — UI).
## First pick after intro (tier == 0), or upgrade-only from pause "Go deeper".

signal chosen(tier: int, upgrade: bool)
signal cancelled

const COPY := preload("res://scripts/player_copy.gd")
const C := preload("res://scripts/playtest_commitment.gd")
const GLYPH := preload("res://scripts/commitment_tier_glyph.gd")

const CARD_W := 280.0
const CARD_H := 260.0
const CARD_GAP := 20.0
const EDGE := 24.0

const COL_BG := Color("100e0c")
const COL_PANEL := Color("1a1410f5")
const COL_BORDER := Color("e8c36a")
const COL_TITLE := Color("e8c36a")
const COL_BODY := Color("f4ede3")
const COL_MUTED := Color("b6a78e")
const COL_HOVER := Color("30261a")
const COL_FOCUS := Color("f7d58c")
const COL_DIM := Color(0.45, 0.4, 0.35, 1.0)
const COL_CHECK := Color("8DCB8D")

var _upgrade: bool = false
var _min_enabled: int = C.TIER_QUICK
var _current_tier: int = C.TIER_NONE
var _reached: Dictionary = {}
var _focus_i: int = 0
var _busy: bool = false
var _cards: Array = []
var _card_nodes: Array = []
var _title: Label
var _carrot: Label
var _notice: Label
var _row: HBoxContainer
var _arm: float = 0.0


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = COL_BG
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 140
	visible = false
	name = "playtest_commitment_picker"
	_build()


## mode "choose" = first pick; "upgrade" = only tiers above current_tier.
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
	return r.position + Vector2(r.size.x * 0.5, 48.0)


func _default_focus() -> int:
	for i in range(_cards.size()):
		if _tier_enabled(int(_cards[i].get("tier", 0))):
			return i
	return 0


func _build() -> void:
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	root.offset_left = EDGE
	root.offset_right = -EDGE
	root.offset_top = EDGE
	root.offset_bottom = -EDGE
	root.alignment = BoxContainer.ALIGNMENT_CENTER
	root.add_theme_constant_override("separation", 18)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 36)
	_title.add_theme_color_override("font_color", COL_TITLE)
	_title.add_theme_color_override("font_outline_color", Color("100e0c"))
	_title.add_theme_constant_override("outline_size", 3)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_title)

	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_row.add_theme_constant_override("separation", int(CARD_GAP))
	_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_row)

	_cards = [
		{
			"tier": C.TIER_QUICK,
			"id": "quick",
			"title_key": "playtest.tier.quick.title",
			"title_fb": "Finish your first run",
			"line_key": "playtest.tier.quick.line",
			"line_fb": "Learn the ropes with my tutorial, then take one run on your own. Tell me what clicked and what didn't.",
			"time_key": "playtest.tier.quick.time",
			"time_fb": "About 15 minutes",
		},
		{
			"tier": C.TIER_DEEPER,
			"id": "deeper",
			"title_key": "playtest.tier.deeper.title",
			"title_fb": "Reach the Crystal Cavern",
			"line_key": "playtest.tier.deeper.line",
			"line_fb": "Escape Verdant Hollow with five unique items and pull the lever. This is where the game opens up and you start to feel real mastery.",
			"time_key": "playtest.tier.deeper.time",
			"time_fb": "Usually about an hour",
		},
		{
			"tier": C.TIER_BIG,
			"id": "big",
			"title_key": "playtest.tier.big.title",
			"title_fb": "Reach the Shadow Abyss",
			"line_key": "playtest.tier.big.line",
			"line_fb": "Make it to the Shadow Abyss and you get a victory code, a spot in my Discord, and we'll design a new monster or item for the game together.",
			"time_key": "playtest.tier.big.time",
			"time_fb": "Several hours",
		},
	]
	_card_nodes.clear()
	for spec in _cards:
		var card: PanelContainer = _make_card(spec)
		_row.add_child(card)
		_card_nodes.append(card)

	_carrot = Label.new()
	_carrot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_carrot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_carrot.add_theme_font_size_override("font_size", 15)
	_carrot.add_theme_color_override("font_color", COL_MUTED)
	_carrot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_carrot)

	_notice = Label.new()
	_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice.add_theme_font_size_override("font_size", 12)
	_notice.add_theme_color_override("font_color", Color("8a8178"))
	_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_notice)


func _make_card(spec: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(CARD_W, CARD_H)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.focus_mode = Control.FOCUS_ALL
	card.set_meta("tier", int(spec.get("tier", 0)))
	card.set_meta("spec", spec)
	card.pivot_offset = Vector2(CARD_W * 0.5, CARD_H * 0.5)
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

	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_PANEL
	sb.border_color = COL_BORDER
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	card.add_theme_stylebox_override("panel", sb)
	card.set_meta("style", sb)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(col)

	var icon := _make_tier_icon(int(spec.get("tier", 0)))
	icon.name = "TierIcon"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(icon)

	var title := Label.new()
	title.name = "Title"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", COL_TITLE)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(title)

	var line := Label.new()
	line.name = "Line"
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.size_flags_vertical = Control.SIZE_EXPAND_FILL
	line.add_theme_font_size_override("font_size", 14)
	line.add_theme_color_override("font_color", COL_BODY)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(line)

	var time := Label.new()
	time.name = "Time"
	time.add_theme_font_size_override("font_size", 13)
	time.add_theme_color_override("font_color", COL_MUTED)
	time.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(time)

	var status := Label.new()
	status.name = "Status"
	status.add_theme_font_size_override("font_size", 13)
	status.add_theme_color_override("font_color", COL_CHECK)
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(status)

	return card


func _make_tier_icon(tier: int) -> Control:
	var wrap := Control.new()
	wrap.custom_minimum_size = Vector2(48, 40)
	var draw: Control = GLYPH.new()
	draw.set("tier", tier)
	draw.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	draw.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(draw)
	return wrap


func _refresh_cards() -> void:
	if _title:
		_title.text = COPY.text(
			"playtest.tier.upgrade_title" if _upgrade else "playtest.tier.choose_title",
			"Go deeper" if _upgrade else "How far do you want to go?"
		)
	if _carrot:
		_carrot.text = COPY.text(
			"playtest.tier.carrot",
			"Reach the Shadow Abyss and you'll help me design part of this game. You can always go deeper later."
		)
	if _notice:
		var telem := COPY.text("playtest.tier.notice.telemetry", "I collect anonymous play data to improve the game.")
		var save := COPY.text("playtest.tier.notice.save", "Your progress lives in this browser. Clearing site data resets it.")
		_notice.text = "%s  ·  %s" % [telem, save]
	for i in range(_card_nodes.size()):
		var card: PanelContainer = _card_nodes[i]
		var spec: Dictionary = _cards[i]
		var tier: int = int(spec.get("tier", 0))
		var enabled: bool = _tier_enabled(tier)
		var done: bool = bool(_reached.get(_milestone_id(tier), false))
		var title_l: Label = _find_label(card, "Title")
		var line_l: Label = _find_label(card, "Line")
		var time_l: Label = _find_label(card, "Time")
		var status_l: Label = _find_label(card, "Status")
		if title_l:
			title_l.text = COPY.text(str(spec.get("title_key", "")), str(spec.get("title_fb", "")))
		if line_l:
			line_l.text = COPY.text(str(spec.get("line_key", "")), str(spec.get("line_fb", "")))
		if time_l:
			time_l.text = COPY.text(str(spec.get("time_key", "")), str(spec.get("time_fb", "")))
		if status_l:
			if done:
				status_l.text = COPY.text("playtest.tier.done_check", "✓ Done")
				status_l.visible = true
			elif _upgrade and not enabled:
				status_l.text = COPY.text("playtest.tier.current_mark", "Current")
				status_l.visible = tier == _current_tier
			else:
				status_l.visible = false
		card.modulate = Color.WHITE if enabled else COL_DIM
		card.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if enabled else Control.CURSOR_ARROW
		card.mouse_filter = Control.MOUSE_FILTER_STOP
	_paint_focus()


func _find_label(card: Node, nm: String) -> Label:
	for c in card.get_children():
		var found := c.find_child(nm, true, false)
		if found is Label:
			return found
	return null


func _milestone_id(tier: int) -> String:
	match tier:
		C.TIER_QUICK:
			return C.M_QUICK
		C.TIER_DEEPER:
			return C.M_DEEPER
		C.TIER_BIG:
			return C.M_BIG
	return ""


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
		sb.bg_color = COL_HOVER if focused else COL_PANEL
		sb.border_color = COL_FOCUS if focused else COL_BORDER
		sb.set_border_width_all(3 if focused else 2)
		card.add_theme_stylebox_override("panel", sb)


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
	_blip_selected(_card_nodes[_focus_i])
	chosen.emit(tier, _upgrade)


func _blip_selected(card: Control) -> void:
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(card, "scale", Vector2(1.06, 1.06), 0.12)
	tw.tween_property(card, "scale", Vector2.ONE, 0.18)


## Source contract helpers for selftests.
static func shows_only_when_tier_none(tier: int) -> bool:
	return tier == C.TIER_NONE


static func upgrade_disables_lower(current_tier: int, candidate: int) -> bool:
	return candidate <= current_tier
