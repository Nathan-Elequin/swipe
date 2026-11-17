extends ColorRect
## Playtest BIG-tier victory screen (slice 4).
## Celebratory code card + the same rating / prompts / Send as the offramp.
## Compact re-view mode: code + Copy + Discord only.

signal send_wanted(payload: Dictionary)
signal action_wanted(action: String) ## keep | done | skip | close_code
signal copy_wanted(code: String)
signal discord_wanted(url: String)

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")
const C := preload("res://scripts/playtest_commitment.gd")
const VC := preload("res://scripts/playtest_victory_code.gd")
const LINKS_PATH := "res://data/playtest-links.json"

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
const COL_CODE_BG := Color("100e0c")

const PANEL_W := 760.0

var _mode: String = "full" ## full | thanks | code
var _code: String = ""
var _ctx: Dictionary = {}
var _rating: int = 0
var _busy: bool = false
var _arm: float = 0.0
var _discord_url: String = ""
var _contact_email: String = ""

var _wrap: CenterContainer
var _panel: PanelContainer
var _scroll: ScrollContainer
var _full: VBoxContainer
var _thanks: VBoxContainer
var _code_card: VBoxContainer
var _title: Label
var _line: Label
var _code_label: Label
var _code_compact: Label
var _instructions: Label
var _btn_copy: Button
var _btn_copy_compact: Button
var _btn_discord: Button
var _btn_discord_compact: Button
var _email_lab: Label
var _rating_row: HBoxContainer
var _rate_btns: Array = []
var _q_labels: Array = []
var _q_edits: Array = []
var _else_edit: TextEdit
var _status: Label
var _btn_send: Button
var _btn_keep: Button
var _btn_done: Button
var _btn_skip: Button
var _btn_thanks_ok: Button
var _btn_code_close: Button
var _thanks_body: Label
var _fx_host: Control


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = COL_BG
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 143
	visible = false
	name = "playtest_victory"
	add_to_group("playtest_victory")
	add_to_group("playtest_feedback") ## blocks F2 / Space / M
	add_to_group("playtest_offramp") ## same hotkey gate as offramp
	_load_links()
	_build()


func open_victory(code: String, context: Dictionary = {}) -> void:
	_code = VC.normalize(code)
	if _code == "":
		_code = str(code).strip_edges().to_upper()
	_ctx = context.duplicate(true) if typeof(context) == TYPE_DICTIONARY else {}
	_rating = 0
	_busy = false
	_mode = "full"
	_arm = 0.25
	_status.text = ""
	_status.add_theme_color_override("font_color", COL_OK)
	_load_links()
	_apply_copy()
	_paint_rating()
	_clear_edits()
	_code_label.text = _code
	_full.visible = true
	_thanks.visible = false
	_code_card.visible = false
	_btn_send.disabled = false
	_refresh_discord_buttons()
	_refresh_email()
	visible = true
	move_to_front()
	_burst_fx()


func open_code_card(code: String, context: Dictionary = {}) -> void:
	_code = VC.normalize(code)
	if _code == "":
		_code = str(code).strip_edges().to_upper()
	_ctx = context.duplicate(true) if typeof(context) == TYPE_DICTIONARY else {}
	_busy = false
	_mode = "code"
	_arm = 0.15
	_load_links()
	_code_compact.text = _code
	_apply_code_card_copy()
	_refresh_discord_buttons()
	_full.visible = false
	_thanks.visible = false
	_code_card.visible = true
	visible = true
	move_to_front()


func close_panel() -> void:
	visible = false
	_busy = false
	_mode = "full"
	_stop_fx()


func show_result(ok: bool, detail: String) -> void:
	_busy = false
	_status.add_theme_color_override("font_color", COL_OK if ok else COL_ERR)
	_status.text = detail
	if ok:
		_btn_send.disabled = true


func show_thanks() -> void:
	_mode = "thanks"
	_full.visible = false
	_code_card.visible = false
	_thanks.visible = true
	_thanks_body.text = COPY.text(
		"playtest.offramp.thanks",
		"Thank you. Seriously. You can close the tab anytime, and your progress stays in this browser."
	)
	move_to_front()


func current_milestone() -> String:
	return C.M_BIG


func current_code() -> String:
	return _code


func is_form() -> bool:
	return visible and _mode == "full"


func is_code_card() -> bool:
	return visible and _mode == "code"


func build_payload() -> Dictionary:
	var answers := {}
	var keys: Array = _question_keys()
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
		"title": "offramp big",
		"note": note,
		"milestone": C.M_BIG,
		"tier": int(_ctx.get("tier", C.TIER_BIG)),
		"rating": _rating,
		"answers": answers,
		"else": else_text,
		"victory_code": _code,
		"anon_id": str(_ctx.get("anon_id", "")),
		"build_id": str(_ctx.get("build_id", "")),
		"run_count": int(_ctx.get("run_count", 0)),
		"biomes_unlocked": int(_ctx.get("biomes_unlocked", 0)),
		"cabinet_count": int(_ctx.get("cabinet_count", 0)),
		"play_seconds": int(_ctx.get("play_seconds", -1)),
	}


static func payload_shape_ok(payload: Dictionary) -> bool:
	if str(payload.get("type", "")) != "offramp":
		return false
	if str(payload.get("kind", "")) != "offramp":
		return false
	if str(payload.get("milestone", "")) != C.M_BIG:
		return false
	if str(payload.get("victory_code", "")).strip_edges() == "":
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


static func load_discord_url() -> String:
	var d: Dictionary = _read_links()
	return str(d.get("discord_url", "")).strip_edges()


static func load_contact_email() -> String:
	var d: Dictionary = _read_links()
	return str(d.get("contact_email", "")).strip_edges()


static func discord_enabled(url: String = "") -> bool:
	var u := url.strip_edges() if url != "" else load_discord_url()
	return u != ""


func copy_code_to_clipboard() -> void:
	var body := _code
	if body == "":
		return
	DisplayServer.clipboard_set(body)
	if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
		## Best-effort web clipboard; DisplayServer often works too.
		var lit := JSON.stringify(body)
		JavaScriptBridge.eval(
			"(function(){try{if(navigator.clipboard&&navigator.clipboard.writeText){navigator.clipboard.writeText(%s);}else{var t=document.createElement('textarea');t.value=%s;document.body.appendChild(t);t.select();document.execCommand('copy');document.body.removeChild(t);}}catch(e){}})();" % [lit, lit],
			true
		)
	copy_wanted.emit(body)
	if _mode == "full" and _status:
		_status.add_theme_color_override("font_color", COL_OK)
		_status.text = COPY.text("playtest.victory.copied", "Copied!")


func open_discord() -> void:
	_load_links()
	if _discord_url == "":
		return
	discord_wanted.emit(_discord_url)
	if OS.has_feature("web") and ClassDB.class_exists("JavaScriptBridge"):
		var lit := JSON.stringify(_discord_url)
		JavaScriptBridge.eval(
			"(function(){try{window.open(%s,'_blank','noopener');}catch(e){}})();" % lit,
			true
		)
	else:
		OS.shell_open(_discord_url)


## --- build -------------------------------------------------------------------

func _build() -> void:
	_wrap = CenterContainer.new()
	_wrap.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_wrap)

	_fx_host = Control.new()
	_fx_host.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_fx_host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx_host.z_index = 1
	add_child(_fx_host)

	_panel = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_PANEL
	sb.border_color = COL_BORDER
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(10)
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

	_scroll = ScrollContainer.new()
	_scroll.custom_minimum_size = Vector2(PANEL_W - 8, 640)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_scroll)

	var scroll_body := VBoxContainer.new()
	scroll_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_body.add_theme_constant_override("separation", 10)
	_scroll.add_child(scroll_body)

	_full = VBoxContainer.new()
	_full.add_theme_constant_override("separation", 10)
	_full.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_body.add_child(_full)

	var head_row := HBoxContainer.new()
	head_row.add_theme_constant_override("separation", 12)
	_full.add_child(head_row)

	_title = Label.new()
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_font_size_override("font_size", 32)
	_title.add_theme_color_override("font_color", COL_TITLE)
	_title.add_theme_color_override("font_outline_color", Color("100e0c"))
	_title.add_theme_constant_override("outline_size", 4)
	head_row.add_child(_title)

	_btn_skip = _chrome_btn(COPY.text("playtest.offramp.skip", "Skip"), func() -> void: _emit_action("skip"), 96)
	head_row.add_child(_btn_skip)

	_line = Label.new()
	_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_line.add_theme_font_size_override("font_size", 16)
	_line.add_theme_color_override("font_color", COL_BODY)
	_full.add_child(_line)

	var code_frame := PanelContainer.new()
	var csb := StyleBoxFlat.new()
	csb.bg_color = COL_CODE_BG
	csb.border_color = COL_BORDER
	csb.set_border_width_all(2)
	csb.set_corner_radius_all(8)
	csb.content_margin_left = 16
	csb.content_margin_right = 16
	csb.content_margin_top = 14
	csb.content_margin_bottom = 14
	code_frame.add_theme_stylebox_override("panel", csb)
	_full.add_child(code_frame)

	var code_col := VBoxContainer.new()
	code_col.add_theme_constant_override("separation", 8)
	code_frame.add_child(code_col)

	var code_cap := Label.new()
	code_cap.text = COPY.text("playtest.victory.code_label", "VICTORY CODE")
	code_cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_cap.add_theme_font_size_override("font_size", 14)
	code_cap.add_theme_color_override("font_color", COL_MUTED)
	code_col.add_child(code_cap)

	_code_label = Label.new()
	_code_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_code_label.add_theme_font_size_override("font_size", 36)
	_code_label.add_theme_color_override("font_color", COL_TITLE)
	_code_label.add_theme_color_override("font_outline_color", Color("100e0c"))
	_code_label.add_theme_constant_override("outline_size", 3)
	code_col.add_child(_code_label)

	_instructions = Label.new()
	_instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_instructions.add_theme_font_size_override("font_size", 14)
	_instructions.add_theme_color_override("font_color", COL_BODY)
	_full.add_child(_instructions)

	var code_actions := HBoxContainer.new()
	code_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	code_actions.add_theme_constant_override("separation", 12)
	_full.add_child(code_actions)
	_btn_copy = _chrome_btn(COPY.text("playtest.victory.copy", "Copy code"), func() -> void: copy_code_to_clipboard(), 150)
	_btn_discord = _chrome_btn(COPY.text("playtest.victory.discord", "Join the Discord"), func() -> void: open_discord(), 190)
	code_actions.add_child(_btn_copy)
	code_actions.add_child(_btn_discord)

	_email_lab = Label.new()
	_email_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_email_lab.add_theme_font_size_override("font_size", 13)
	_email_lab.add_theme_color_override("font_color", COL_MUTED)
	_email_lab.visible = false
	_full.add_child(_email_lab)

	var rate_lab := Label.new()
	rate_lab.name = "RatingLabel"
	rate_lab.add_theme_font_size_override("font_size", 16)
	rate_lab.add_theme_color_override("font_color", COL_TITLE)
	rate_lab.text = COPY.text("playtest.offramp.rating", "How fun was it?")
	_full.add_child(rate_lab)

	_rating_row = HBoxContainer.new()
	_rating_row.add_theme_constant_override("separation", 8)
	_full.add_child(_rating_row)
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
		_full.add_child(ql)
		_q_labels.append(ql)
		var qe := TextEdit.new()
		qe.custom_minimum_size = Vector2(PANEL_W - 56, 52)
		qe.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		qe.scroll_fit_content_height = true
		qe.add_theme_font_size_override("font_size", 14)
		qe.add_theme_color_override("font_color", COL_BODY)
		_full.add_child(qe)
		_q_edits.append(qe)

	var else_lab := Label.new()
	else_lab.name = "ElseLabel"
	else_lab.text = COPY.text("playtest.offramp.else", "Anything else?")
	else_lab.add_theme_font_size_override("font_size", 14)
	else_lab.add_theme_color_override("font_color", COL_MUTED)
	_full.add_child(else_lab)

	_else_edit = TextEdit.new()
	_else_edit.custom_minimum_size = Vector2(PANEL_W - 56, 64)
	_else_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_else_edit.add_theme_font_size_override("font_size", 14)
	_else_edit.add_theme_color_override("font_color", COL_BODY)
	_full.add_child(_else_edit)

	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", COL_OK)
	_full.add_child(_status)

	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	_full.add_child(actions)
	_btn_send = _chrome_btn(COPY.text("playtest.offramp.send", "Send"), func() -> void: _on_send(), 120)
	_btn_keep = _chrome_btn(COPY.text("playtest.offramp.keep", "Keep playing"), func() -> void: _emit_action("keep"), 150)
	_btn_done = _chrome_btn(COPY.text("playtest.offramp.done", "I'm done for now"), func() -> void: _emit_action("done"), 180)
	actions.add_child(_btn_send)
	actions.add_child(_btn_keep)
	actions.add_child(_btn_done)

	## Thanks (reuse slice-3 card feel; no carrot / Go deeper).
	_thanks = VBoxContainer.new()
	_thanks.add_theme_constant_override("separation", 14)
	_thanks.visible = false
	_thanks.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll_body.add_child(_thanks)

	_thanks_body = Label.new()
	_thanks_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_thanks_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_thanks_body.add_theme_font_size_override("font_size", 20)
	_thanks_body.add_theme_color_override("font_color", COL_BODY)
	_thanks_body.custom_minimum_size = Vector2(PANEL_W - 48, 0)
	_thanks.add_child(_thanks_body)

	var thanks_row := HBoxContainer.new()
	thanks_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_thanks.add_child(thanks_row)
	_btn_thanks_ok = _chrome_btn(COPY.text("playtest.offramp.keep", "Keep playing"), func() -> void: _emit_action("keep"), 160)
	thanks_row.add_child(_btn_thanks_ok)

	## Compact re-view card.
	_code_card = VBoxContainer.new()
	_code_card.add_theme_constant_override("separation", 12)
	_code_card.visible = false
	_code_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll_body.add_child(_code_card)

	var cc_title := Label.new()
	cc_title.name = "CodeCardTitle"
	cc_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cc_title.add_theme_font_size_override("font_size", 24)
	cc_title.add_theme_color_override("font_color", COL_TITLE)
	cc_title.text = COPY.text("playtest.victory.code_card_title", "Your victory code")
	_code_card.add_child(cc_title)

	_code_compact = Label.new()
	_code_compact.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_code_compact.add_theme_font_size_override("font_size", 32)
	_code_compact.add_theme_color_override("font_color", COL_TITLE)
	_code_card.add_child(_code_compact)

	var cc_actions := HBoxContainer.new()
	cc_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	cc_actions.add_theme_constant_override("separation", 12)
	_code_card.add_child(cc_actions)
	_btn_copy_compact = _chrome_btn(COPY.text("playtest.victory.copy", "Copy code"), func() -> void: copy_code_to_clipboard(), 150)
	_btn_discord_compact = _chrome_btn(COPY.text("playtest.victory.discord", "Join the Discord"), func() -> void: open_discord(), 190)
	_btn_code_close = _chrome_btn(COPY.text("playtest.victory.close", "Close"), func() -> void: _emit_action("close_code"), 120)
	cc_actions.add_child(_btn_copy_compact)
	cc_actions.add_child(_btn_discord_compact)
	cc_actions.add_child(_btn_code_close)


func _chrome_btn(label: String, cb: Callable, width: float) -> Button:
	var b := Button.new()
	b.text = label
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UX.dress_small_button(b, width)
	b.pressed.connect(cb)
	return b


func _apply_copy() -> void:
	_title.text = COPY.text("playtest.victory.title", "You reached the Shadow Abyss!")
	_line.text = COPY.text(
		"playtest.victory.line",
		"You made it further than almost anyone. I meant what I said: let's design a monster or item for this game together."
	)
	_instructions.text = COPY.text(
		"playtest.victory.instructions",
		"Screenshot this screen and post it in my Discord to claim your spot."
	)
	var prompts: Array = _question_fallbacks()
	var keys: Array = _question_keys()
	for i in range(4):
		var key := str(keys[i]) if i < keys.size() else ""
		var fb := str(prompts[i]) if i < prompts.size() else ""
		(_q_labels[i] as Label).text = COPY.text(key, fb)
	_btn_send.text = COPY.text("playtest.offramp.send", "Send")
	_btn_keep.text = COPY.text("playtest.offramp.keep", "Keep playing")
	_btn_done.text = COPY.text("playtest.offramp.done", "I'm done for now")
	_btn_skip.text = COPY.text("playtest.offramp.skip", "Skip")
	_btn_copy.text = COPY.text("playtest.victory.copy", "Copy code")
	var rate_lab: Label = _full.find_child("RatingLabel", true, false) as Label
	if rate_lab:
		rate_lab.text = COPY.text("playtest.offramp.rating", "How fun was it?")
	var else_lab: Label = _full.find_child("ElseLabel", true, false) as Label
	if else_lab:
		else_lab.text = COPY.text("playtest.offramp.else", "Anything else?")
	_refresh_discord_buttons()


func _apply_code_card_copy() -> void:
	var t: Label = _code_card.find_child("CodeCardTitle", true, false) as Label
	if t:
		t.text = COPY.text("playtest.victory.code_card_title", "Your victory code")
	_btn_copy_compact.text = COPY.text("playtest.victory.copy", "Copy code")
	_btn_code_close.text = COPY.text("playtest.victory.close", "Close")
	_refresh_discord_buttons()


func _question_keys() -> Array:
	return [
		"playtest.offramp.big.q1",
		"playtest.offramp.big.q2",
		"playtest.offramp.big.q3",
		"playtest.offramp.big.q4",
	]


func _question_fallbacks() -> Array:
	return [
		"What kept you playing this long?",
		"What feels off balance this deep in?",
		"What's your go-to strategy?",
		"Pitch me a monster or item.",
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
	if _busy or _mode != "full":
		return
	_busy = true
	_status.text = ""
	send_wanted.emit(build_payload())


func _emit_action(action: String) -> void:
	if _arm > 0.0 and (action == "skip" or action == "close_code"):
		return
	action_wanted.emit(str(action))


func _compose_note(answers: Dictionary, else_text: String) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("Off-ramp (big) rating=%s code=%s" % [str(_rating) if _rating > 0 else "—", _code])
	for k in answers.keys():
		lines.append("%s: %s" % [k, answers[k]])
	if else_text != "":
		lines.append("else: %s" % else_text)
	return "\n".join(lines)


func _load_links() -> void:
	var d: Dictionary = _read_links()
	_discord_url = str(d.get("discord_url", "")).strip_edges()
	_contact_email = str(d.get("contact_email", "")).strip_edges()


static func _read_links() -> Dictionary:
	if not FileAccess.file_exists(LINKS_PATH):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LINKS_PATH))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _refresh_discord_buttons() -> void:
	var has_url: bool = _discord_url != ""
	for b in [_btn_discord, _btn_discord_compact]:
		if b == null:
			continue
		if has_url:
			b.disabled = false
			b.text = COPY.text("playtest.victory.discord", "Join the Discord")
		else:
			b.disabled = true
			b.text = COPY.text("playtest.victory.discord_soon", "Discord link coming soon")


func _refresh_email() -> void:
	if _email_lab == null:
		return
	if _contact_email == "":
		_email_lab.visible = false
		_email_lab.text = ""
	else:
		_email_lab.visible = true
		_email_lab.text = COPY.text("playtest.victory.email", "Or email: {email}").replace("{email}", _contact_email)


func _burst_fx() -> void:
	_stop_fx()
	## Simple gold spark rain — no new art dependency.
	for i in 28:
		var spark := ColorRect.new()
		spark.color = COL_TITLE if i % 3 != 0 else Color("f4ede3")
		spark.size = Vector2(4 + (i % 3) * 2, 4 + (i % 2) * 2)
		spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		spark.position = Vector2(80.0 + (i * 53) % 1520, -20.0 - (i % 7) * 12.0)
		_fx_host.add_child(spark)
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		var land_y: float = 200.0 + (i * 37) % 600
		tw.tween_property(spark, "position:y", land_y, 0.9 + (i % 5) * 0.08)
		tw.parallel().tween_property(spark, "modulate:a", 0.0, 1.1)
		tw.tween_callback(spark.queue_free)


func _stop_fx() -> void:
	if _fx_host == null:
		return
	for c in _fx_host.get_children():
		c.queue_free()


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
		elif _mode == "code":
			_emit_action("close_code")
		else:
			_emit_action("skip")
		get_viewport().set_input_as_handled()
