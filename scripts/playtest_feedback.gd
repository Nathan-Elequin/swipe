extends ColorRect
## F2 / bottom-right / right-click comment box. Send posts a GitHub Issue via the Worker.

signal send_wanted(note: String, card_kind: String, card_id: String)
signal tier_wanted
signal closed

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")

var _title: Label
var _attach: Label
var _edit: TextEdit
var _status: Label
var _card_kind: String = ""
var _card_id: String = ""
var _card_name: String = ""
var _busy: bool = false
var _demo: bool = false
var _send: Button
var _tier: Button
var _close: Button
var _panel: PanelContainer
var _wrap: CenterContainer


func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	color = Color("100e0ce8")
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 130
	visible = false
	name = "playtest_feedback"
	_wrap = CenterContainer.new()
	_wrap.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_wrap)
	var wrap := _wrap
	_panel = PanelContainer.new()
	var panel := _panel
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1c140e")
	sb.border_color = Color("e8c36a")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(12)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 22
	sb.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", sb)
	wrap.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	col.custom_minimum_size = Vector2(640, 0)
	panel.add_child(col)
	var head := Control.new()
	head.custom_minimum_size = Vector2(584, 40)
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(head)
	_title = Label.new()
	_title.text = COPY.text("playtest.feedback", "Feedback")
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 28)
	_title.add_theme_color_override("font_color", Color("e8c36a"))
	_title.add_theme_color_override("font_outline_color", Color("100e0c"))
	_title.add_theme_constant_override("outline_size", 3)
	_title.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(_title)
	_tier = Button.new()
	_tier.text = COPY.text("playtest.make_tier_list", "Make An Item/Monster Tier List")
	_tier.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tier.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UX.dress_small_button(_tier, 210)
	_tier.pressed.connect(_on_tier)
	_tier.anchor_left = 1.0
	_tier.anchor_top = 0.0
	_tier.anchor_right = 1.0
	_tier.anchor_bottom = 0.0
	_tier.offset_left = -210.0
	_tier.offset_top = 0.0
	_tier.offset_right = 0.0
	_tier.offset_bottom = 36.0
	head.add_child(_tier)
	var hint := Label.new()
	hint.text = COPY.text("playtest.f2_hint", "F2 also opens this.")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color("c4a574"))
	col.add_child(hint)
	_attach = Label.new()
	_attach.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_attach.add_theme_font_size_override("font_size", 16)
	_attach.add_theme_color_override("font_color", Color("f0e6d8"))
	_attach.visible = false
	col.add_child(_attach)
	_edit = TextEdit.new()
	_edit.custom_minimum_size = Vector2(580, 180)
	_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_edit.placeholder_text = COPY.text("playtest.comment_placeholder", "What happened?")
	_edit.add_theme_font_size_override("font_size", 16)
	_edit.add_theme_color_override("font_color", Color("f4ede3"))
	col.add_child(_edit)
	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.add_theme_font_size_override("font_size", 14)
	_status.add_theme_color_override("font_color", Color("8dcb8d"))
	_status.custom_minimum_size = Vector2(580, 0)
	col.add_child(_status)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	col.add_child(row)
	_send = _btn(COPY.text("playtest.send", "Send"), func() -> void: _on_send())
	_close = _btn(COPY.text("playtest.close", "Close"), func() -> void: close_box())
	row.add_child(_send)
	row.add_child(_close)


func send_button() -> Control:
	return _send


func panel() -> Control:
	return _panel


func set_demo(on: bool) -> void:
	_demo = on
	mouse_filter = Control.MOUSE_FILTER_IGNORE if on else Control.MOUSE_FILTER_STOP
	if _edit:
		_edit.editable = not on
		_edit.focus_mode = Control.FOCUS_NONE if on else Control.FOCUS_ALL
	if _send:
		_send.disabled = on
	if _tier:
		_tier.disabled = on
	if _close:
		_close.disabled = on


func open_box(kind: String = "", card_id: String = "", card_name: String = "") -> void:
	_card_kind = kind
	_card_id = card_id
	_card_name = card_name
	_busy = false
	_status.text = ""
	_edit.text = ""
	if card_name != "" or card_id != "":
		_attach.visible = true
		_attach.text = card_name if card_name != "" else card_id
	else:
		_attach.visible = false
		_attach.text = ""
	visible = true
	move_to_front()
	if not _demo and _edit:
		_edit.grab_focus()


func show_again() -> void:
	visible = true
	move_to_front()
	if _edit:
		_edit.grab_focus()


func close_box() -> void:
	if _demo:
		return
	visible = false
	closed.emit()


func force_close() -> void:
	set_demo(false)
	visible = false


func show_result(ok: bool, detail: String) -> void:
	_busy = false
	_status.add_theme_color_override("font_color", Color("8dcb8d") if ok else Color("e07a3d"))
	_status.text = detail
	if ok:
		_edit.text = ""


func _on_tier() -> void:
	if _demo:
		return
	tier_wanted.emit()


func _on_send() -> void:
	if _demo or _busy:
		return
	_busy = true
	_status.text = ""
	send_wanted.emit(_edit.text, _card_kind, _card_id)


func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	UX.dress_title_button(b, 180)
	b.pressed.connect(cb)
	return b
