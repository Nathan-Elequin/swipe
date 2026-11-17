extends ColorRect
## Playtest commitment OFF-RAMP feedback panel (slice 3).
## Quick / deeper milestones only. Big victory screen is slice 4.

signal send_wanted(payload: Dictionary)
signal action_wanted(action: String) ## keep | deeper | done | skip

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")
const C := preload("res://scripts/playtest_commitment.gd")

const COL_BG := Color("100e0ce8")
const COL_PANEL := Color("1a1410f5")
const COL_BORDER := Color("e8c36a")
const COL_TITLE := Color("e8c36a")
const COL_BODY := Color("f4ede3")
const COL_MUTED := Color("b6a78e")
const COL_OK := Color("8dcb8d")
const COL_ERR := Color("e07a3d")
const COL_RATE_ON := Color("f7d58c")
const COL_RATE_OFF := Color("30261a")

const PANEL_W := 720.0

var _milestone: String = ""
var _tier: int = C.TIER_NONE
var _ctx: Dictionary = {}
var _rating: int = 0
var _busy: bool = false
var _mode: String = "form" ## form | thanks

var _wrap: CenterContainer
var _panel: PanelContainer
var _form: VBoxContainer
var _thanks: VBoxContainer
var _header: Label
var _line: Label
var _rating_row: HBoxContainer
var _rate_btns: Array = []
var _q_labels: Array = []
var _q_edits: Array = []
var _else_edit: TextEdit
var _status: Label
var _btn_send: Button
var _btn_keep: Button
var _btn_deeper: Button
var _btn_done: Button
var _btn_skip: Button
var _btn_thanks_ok: Button
var _thanks_body: Label
var _thanks_carrot: Label
var _arm: float = 0.0


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = COL_BG
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 142
	visible = false
	name = "playtest_offramp"
	add_to_group("playtest_offramp")
	add_to_group("playtest_feedback") ## blocks F2 / Space / M via PlaytestUx.feedback_open
	_build()


func open_offramp(milestone: String, context: Dictionary = {}) -> void:
	_milestone = str(milestone).strip_edges().to_lower()
	if _milestone != C.M_QUICK and _milestone != C.M_DEEPER:
		## Big is slice 4 — never open this panel for it.
		return
	_ctx = context.duplicate(true) if typeof(context) == TYPE_DICTIONARY else {}
	_tier = clampi(int(_ctx.get("tier", C.TIER_NONE)), C.TIER_NONE, C.TIER_BIG)
	_rating = 0
	_busy = false
	_mode = "form"
	_arm = 0.2
	_status.text = ""
	_status.add_theme_color_override("font_color", COL_OK)
	_apply_copy()
	_paint_rating()
	_clear_edits()
	_form.visible = true
	_thanks.visible = false
	_btn_deeper.visible = _tier < C.TIER_BIG
	_btn_send.disabled = false
	visible = true
	move_to_front()


func close_panel() -> void:
	visible = false
	_busy = false
	_mode = "form"


func show_result(ok: bool, detail: String) -> void:
	_busy = false
	_status.add_theme_color_override("font_color", COL_OK if ok else COL_ERR)
	_status.text = detail
	if ok:
		_btn_send.disabled = true


func show_thanks() -> void:
	_mode = "thanks"
	_form.visible = false
	_thanks.visible = true
	_thanks_body.text = COPY.text(
		"playtest.offramp.thanks",
		"Thank you. Seriously. You can close the tab anytime, and your progress stays in this browser."
	)
	_thanks_carrot.text = COPY.text(
		"playtest.tier.carrot",
		"Reach the Shadow Abyss and you'll help me design part of this game. You can always go deeper later."
	)
	move_to_front()


func current_milestone() -> String:
	return _milestone


func is_form() -> bool:
	return visible and _mode == "form"


## Payload shape used by Send (selftest + live). Keeps typed answers even on retry.
func build_payload() -> Dictionary:
	var answers := {}
	var keys: Array = _question_keys(_milestone)
	for i in range(mini(keys.size(), _q_edits.size())):
		var edit: TextEdit = _q_edits[i]
		var text := edit.text.strip_edges() if edit else ""
		if text != "":
			answers[str(keys[i])] = text
	var else_text := _else_edit.text.strip_edges() if _else_edit else ""
	var note := _compose_note(answers, else_text)
	return {
		"type": "offramp",
		"kind": "offramp",
		"title": "offramp %s" % _milestone,
		"note": note,
		"milestone": _milestone,
		"tier": _tier,
		"rating": _rating,
		"answers": answers,
		"else": else_text,
		"anon_id": str(_ctx.get("anon_id", "")),
		"build_id": str(_ctx.get("build_id", "")),
		"run_count": int(_ctx.get("run_count", 0)),
		"biomes_unlocked": int(_ctx.get("biomes_unlocked", 0)),
		"cabinet_count": int(_ctx.get("cabinet_count", 0)),
		"play_seconds": int(_ctx.get("play_seconds", -1)),
	}


## Source-contract helpers for selftests.
static func shows_for_milestone(milestone: String) -> bool:
	var id := str(milestone).strip_edges().to_lower()
	return id == C.M_QUICK or id == C.M_DEEPER


static func payload_shape_ok(payload: Dictionary) -> bool:
	if str(payload.get("type", "")) != "offramp":
		return false
	if str(payload.get("kind", "")) != "offramp":
		return false
	if not shows_for_milestone(str(payload.get("milestone", ""))):
		return false
	if not payload.has("tier") or not payload.has("rating"):
		return false
	if typeof(payload.get("answers", null)) != TYPE_DICTIONARY:
		return false
	if not payload.has("else"):
		return false
	for k in ["anon_id", "build_id", "run_count", "biomes_unlocked", "cabinet_count"]:
		if not payload.has(k):
			return false
	return true


func _build() -> void:
	_wrap = CenterContainer.new()
	_wrap.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_wrap)

	_panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_PANEL
	sb.border_color = COL_BORDER
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	_panel.add_theme_stylebox_override("panel", sb)
	_panel.custom_minimum_size = Vector2(PANEL_W, 0)
	_wrap.add_child(_panel)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(root)

	_form = VBoxContainer.new()
	_form.add_theme_constant_override("separation", 10)
	_form.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_form)

	var head_row := HBoxContainer.new()
	head_row.add_theme_constant_override("separation", 12)
	_form.add_child(head_row)

	_header = Label.new()
	_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_header.add_theme_font_size_override("font_size", 28)
	_header.add_theme_color_override("font_color", COL_TITLE)
	_header.add_theme_color_override("font_outline_color", Color("100e0c"))
	_header.add_theme_constant_override("outline_size", 3)
	head_row.add_child(_header)

	_btn_skip = _chrome_btn(COPY.text("playtest.offramp.skip", "Skip"), func() -> void: _emit_action("skip"), 96)
	head_row.add_child(_btn_skip)

	_line = Label.new()
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.add_theme_font_size_override("font_size", 15)
	_line.add_theme_color_override("font_color", COL_BODY)
	_form.add_child(_line)

	var rate_lab := Label.new()
	rate_lab.name = "RatingLabel"
	rate_lab.add_theme_font_size_override("font_size", 16)
	rate_lab.add_theme_color_override("font_color", COL_TITLE)
	rate_lab.text = COPY.text("playtest.offramp.rating", "How fun was it?")
	_form.add_child(rate_lab)

	_rating_row = HBoxContainer.new()
	_rating_row.add_theme_constant_override("separation", 8)
	_form.add_child(_rating_row)
	_rate_btns.clear()
	for n in range(1, 6):
		var b := Button.new()
		b.text = str(n)
		b.custom_minimum_size = Vector2(48, 40)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.focus_mode = Control.FOCUS_ALL
		b.pressed.connect(_on_rate.bind(n))
		_rating_row.add_child(b)
		_rate_btns.append(b)

	_q_labels.clear()
	_q_edits.clear()
	for i in 4:
		var ql := Label.new()
		ql.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ql.add_theme_font_size_override("font_size", 14)
		ql.add_theme_color_override("font_color", COL_MUTED)
		_form.add_child(ql)
		_q_labels.append(ql)
		var qe := TextEdit.new()
		qe.custom_minimum_size = Vector2(PANEL_W - 48, 52)
		qe.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		qe.scroll_fit_content_height = true
		qe.add_theme_font_size_override("font_size", 14)
		qe.add_theme_color_override("font_color", COL_BODY)
		_form.add_child(qe)
		_q_edits.append(qe)

	var else_lab := Label.new()
	else_lab.name = "ElseLabel"
	else_lab.text = COPY.text("playtest.offramp.else", "Anything else?")
	else_lab.add_theme_font_size_override("font_size", 14)
	else_lab.add_theme_color_override("font_color", COL_MUTED)
	_form.add_child(else_lab)

	_else_edit = TextEdit.new()
	_else_edit.custom_minimum_size = Vector2(PANEL_W - 48, 64)
	_else_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_else_edit.add_theme_font_size_override("font_size", 14)
	_else_edit.add_theme_color_override("font_color", COL_BODY)
	_form.add_child(_else_edit)

	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", COL_OK)
	_form.add_child(_status)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	_form.add_child(actions)

	_btn_send = _chrome_btn(COPY.text("playtest.offramp.send", "Send"), func() -> void: _on_send(), 120)
	_btn_keep = _chrome_btn(COPY.text("playtest.offramp.keep", "Keep playing"), func() -> void: _emit_action("keep"), 150)
	_btn_deeper = _chrome_btn(COPY.text("playtest.offramp.deeper", "Go deeper"), func() -> void: _emit_action("deeper"), 140)
	_btn_done = _chrome_btn(COPY.text("playtest.offramp.done", "I'm done for now"), func() -> void: _emit_action("done"), 180)
	actions.add_child(_btn_send)
	actions.add_child(_btn_keep)
	actions.add_child(_btn_deeper)
	actions.add_child(_btn_done)

	_thanks = VBoxContainer.new()
	_thanks.add_theme_constant_override("separation", 14)
	_thanks.visible = false
	_thanks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_thanks)

	_thanks_body = Label.new()
	_thanks_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_thanks_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_thanks_body.add_theme_font_size_override("font_size", 20)
	_thanks_body.add_theme_color_override("font_color", COL_BODY)
	_thanks_body.custom_minimum_size = Vector2(PANEL_W - 48, 0)
	_thanks.add_child(_thanks_body)

	_thanks_carrot = Label.new()
	_thanks_carrot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_thanks_carrot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_thanks_carrot.add_theme_font_size_override("font_size", 15)
	_thanks_carrot.add_theme_color_override("font_color", COL_MUTED)
	_thanks_carrot.custom_minimum_size = Vector2(PANEL_W - 48, 0)
	_thanks.add_child(_thanks_carrot)

	var thanks_row := HBoxContainer.new()
	thanks_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_thanks.add_child(thanks_row)
	_btn_thanks_ok = _chrome_btn(COPY.text("playtest.offramp.keep", "Keep playing"), func() -> void: _emit_action("keep"), 160)
	thanks_row.add_child(_btn_thanks_ok)


func _chrome_btn(label: String, cb: Callable, width: float) -> Button:
	var b := Button.new()
	b.text = label
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UX.dress_small_button(b, width)
	b.pressed.connect(cb)
	return b


func _apply_copy() -> void:
	var prefix := "playtest.offramp.%s" % _milestone
	if _milestone == C.M_DEEPER:
		_header.text = COPY.text("%s.header" % prefix, "You reached the Crystal Cavern!")
		_line.text = COPY.text(
			"%s.line" % prefix,
			"You've seen the game open up. Now I can ask about the deeper stuff. Everything is optional."
		)
	else:
		_header.text = COPY.text("%s.header" % prefix, "You finished your first run!")
		_line.text = COPY.text(
			"%s.line" % prefix,
			"Thanks for playing this far. A few quick thoughts would help me a ton. Everything is optional."
		)
	var prompts: Array = _question_fallbacks(_milestone)
	var keys: Array = _question_keys(_milestone)
	for i in range(4):
		var key := str(keys[i]) if i < keys.size() else ""
		var fb := str(prompts[i]) if i < prompts.size() else ""
		(_q_labels[i] as Label).text = COPY.text(key, fb)
	_btn_send.text = COPY.text("playtest.offramp.send", "Send")
	_btn_keep.text = COPY.text("playtest.offramp.keep", "Keep playing")
	_btn_deeper.text = COPY.text("playtest.offramp.deeper", "Go deeper")
	_btn_done.text = COPY.text("playtest.offramp.done", "I'm done for now")
	_btn_skip.text = COPY.text("playtest.offramp.skip", "Skip")
	var rate_lab: Label = _form.find_child("RatingLabel", true, false) as Label
	if rate_lab:
		rate_lab.text = COPY.text("playtest.offramp.rating", "How fun was it?")
	var else_lab: Label = _form.find_child("ElseLabel", true, false) as Label
	if else_lab:
		else_lab.text = COPY.text("playtest.offramp.else", "Anything else?")


func _question_keys(milestone: String) -> Array:
	var id := str(milestone).strip_edges().to_lower()
	if id != C.M_QUICK and id != C.M_DEEPER:
		id = C.M_QUICK
	return [
		"playtest.offramp.%s.q1" % id,
		"playtest.offramp.%s.q2" % id,
		"playtest.offramp.%s.q3" % id,
		"playtest.offramp.%s.q4" % id,
	]


func _question_fallbacks(milestone: String) -> Array:
	if str(milestone) == C.M_DEEPER:
		return [
			"How did unlocking new items and the Crystal Cavern feel?",
			"Did the story in the background land, or get in the way?",
			"Did any items or monsters feel too strong or too weak?",
			"What would make you want to play another run?",
		]
	return [
		"What was the most fun moment?",
		"What confused you or needed more explaining?",
		"What did you expect to see that wasn't there?",
		"What do you want more of?",
	]


func _clear_edits() -> void:
	for edit in _q_edits:
		(edit as TextEdit).text = ""
	if _else_edit:
		_else_edit.text = ""


func _paint_rating() -> void:
	for i in range(_rate_btns.size()):
		var b: Button = _rate_btns[i]
		var on: bool = (i + 1) == _rating
		var sb := StyleBoxFlat.new()
		sb.bg_color = COL_RATE_ON if on else COL_RATE_OFF
		sb.border_color = COL_BORDER
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 8
		sb.content_margin_right = 8
		sb.content_margin_top = 4
		sb.content_margin_bottom = 4
		b.add_theme_stylebox_override("normal", sb)
		b.add_theme_stylebox_override("hover", sb)
		b.add_theme_stylebox_override("pressed", sb)
		b.add_theme_color_override("font_color", Color("100e0c") if on else COL_BODY)


func _on_rate(n: int) -> void:
	_rating = clampi(n, 1, 5)
	_paint_rating()


func _on_send() -> void:
	if _busy or _mode != "form":
		return
	_busy = true
	_status.text = ""
	send_wanted.emit(build_payload())


func _emit_action(action: String) -> void:
	if _arm > 0.0 and action == "skip":
		return
	if _busy and action == "send":
		return
	action_wanted.emit(str(action))


func _compose_note(answers: Dictionary, else_text: String) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Off-ramp (%s) rating=%s" % [_milestone, str(_rating) if _rating > 0 else "—"])
	for k in answers.keys():
		lines.append("%s: %s" % [k, answers[k]])
	if else_text != "":
		lines.append("else: %s" % else_text)
	return "\n".join(lines)


func _process(delta: float) -> void:
	if not visible:
		return
	if _arm > 0.0:
		_arm -= delta


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if _mode == "thanks":
			_emit_action("keep")
		else:
			_emit_action("skip")
		get_viewport().set_input_as_handled()
