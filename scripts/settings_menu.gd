extends ColorRect
## Escape overlay: Master volume plus Resume / Peek / Give up / Quit.

signal closed
signal quit_pressed
signal mode_picked(mode: String)
signal roster_pressed
signal script_pressed
signal peek_pressed
signal give_up_confirmed
signal fresh_save_pressed
signal complete_save_pressed
signal bucket_progress_pressed
signal sparkles_toggled(on: bool)
signal invert_scroll_toggled(on: bool)

const COPY := preload("res://scripts/player_copy.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0

var _master: VolumeSlider
var _audio
var _sfx_ready: bool = false
var _title
var _hint: Label
var _play: Label
var _btn_resume: Button
var _btn_quit: Button
var _btn_how: Button
var _btn_dive: Button
var _btn_begin: Button
var _btn_adventure: Button
var _btn_home: Button
var _btn_peek: Button
var _btn_give_up: Button
var _btn_dev: Button
var _btn_fresh: Button
var _btn_complete: Button
var _btn_buckets: Button
var _btn_sparkles: Button
var sparkles_on: bool = true
var invert_scroll: bool = false
var _btn_invert: Button
var _btn_dev_back: Button
var _confirm: Control
var _in_run: bool = true
var _board: Control
var _keep_paused: bool = false
var _board_y: float = 40.0 * PX
var _page: String = "main"
var _sl_wrap: VBoxContainer


func setup(audio) -> void:
	_audio = audio
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	color = Color(0, 0, 0, 0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 120

	var veil := KIT.veil()
	veil.gui_input.connect(_on_dim_input)
	add_child(veil)

	_board = TextureRect.new()
	_board.texture = KIT.load_tex("overlays/pause_board.png")
	_board.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_board.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_board.stretch_mode = TextureRect.STRETCH_KEEP
	_board.mouse_filter = Control.MOUSE_FILTER_STOP
	_board.position = Vector2(110, 40) * PX
	_board.size = Vector2(200, 180) * PX
	_board.z_index = 1
	add_child(_board)

	_title = KIT.label("pause.settings", 36, KIT.INK)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.position = Vector2(0, 6) * PX
	_title.size = Vector2(200, 20) * PX
	_title.set_outline(Color("fff3d6"), 5)
	_board.add_child(_title)

	_hint = Label.new()
	_hint.visible = false
	_board.add_child(_hint)

	_btn_resume = KIT.choice_tag("pause.resume", Vector2(128, 16))
	_btn_resume.pressed.connect(_on_resume)
	_board.add_child(_btn_resume)
	_hook_hover(_btn_resume)

	_btn_peek = KIT.choice_tag("pause.peek", Vector2(128, 16))
	_btn_peek.pressed.connect(_on_peek)
	_board.add_child(_btn_peek)
	_hook_hover(_btn_peek)

	_btn_give_up = KIT.choice_tag("pause.give_up", Vector2(128, 16))
	_btn_give_up.pressed.connect(_on_give_up)
	_board.add_child(_btn_give_up)
	_hook_hover(_btn_give_up)

	_btn_sparkles = KIT.choice_tag("pause.resume", Vector2(128, 16))
	_btn_sparkles.text = "Item sparkles: on"
	_btn_sparkles.pressed.connect(_on_sparkles)
	_board.add_child(_btn_sparkles)
	_hook_hover(_btn_sparkles)

	_btn_invert = KIT.choice_tag("pause.resume", Vector2(128, 16))
	_btn_invert.text = "Invert scroll: off"
	_btn_invert.pressed.connect(_on_invert_scroll)
	_board.add_child(_btn_invert)
	_hook_hover(_btn_invert)

	_btn_quit = KIT.choice_tag("pause.quit", Vector2(128, 16))
	_btn_quit.pressed.connect(_on_quit)
	if not OS.has_feature("web"):
		_board.add_child(_btn_quit)
		_hook_hover(_btn_quit)
	else:
		_btn_quit.visible = false

	if DevFlag.on():
		_btn_dev = KIT.choice_tag("pause.resume", Vector2(128, 16))
		_btn_dev.text = "Developer Mode"
		_btn_dev.pressed.connect(_on_developer)
		_board.add_child(_btn_dev)
		_hook_hover(_btn_dev)
		_btn_fresh = KIT.choice_tag("pause.resume", Vector2(152, 16))
		_btn_fresh.text = "Fresh Save"
		_btn_fresh.pressed.connect(_on_fresh)
		_btn_fresh.visible = false
		_board.add_child(_btn_fresh)
		_hook_hover(_btn_fresh)
		_btn_complete = KIT.choice_tag("pause.resume", Vector2(160, 16))
		_btn_complete.text = "One Hundred Percent Complete"
		_btn_complete.pressed.connect(_on_complete)
		_btn_complete.visible = false
		_board.add_child(_btn_complete)
		_hook_hover(_btn_complete)
		_btn_buckets = KIT.choice_tag("pause.resume", Vector2(152, 16))
		_btn_buckets.text = "Bucket Progress"
		_btn_buckets.pressed.connect(_on_buckets)
		_btn_buckets.visible = false
		_board.add_child(_btn_buckets)
		_hook_hover(_btn_buckets)
		_btn_dev_back = KIT.choice_tag("pause.resume", Vector2(128, 16))
		_btn_dev_back.text = "Back"
		_btn_dev_back.pressed.connect(_on_dev_back)
		_btn_dev_back.visible = false
		_board.add_child(_btn_dev_back)
		_hook_hover(_btn_dev_back)

	_sl_wrap = VBoxContainer.new()
	_sl_wrap.position = Vector2(24, 132) * PX
	_sl_wrap.size = Vector2(152, 44) * PX
	_board.add_child(_sl_wrap)
	_master = _add_slider(_sl_wrap, "Master", COPY.text("pause.master", ""))

	_confirm = PanelContainer.new()
	_confirm.visible = false
	_confirm.z_index = 3
	_confirm.position = Vector2(12, 28) * PX
	_confirm.size = Vector2(176, 124) * PX
	var confirm_sb := StyleBoxFlat.new()
	confirm_sb.bg_color = Color("100e0ce8")
	confirm_sb.border_color = Color("e8c36a")
	confirm_sb.set_border_width_all(2)
	confirm_sb.set_corner_radius_all(8)
	confirm_sb.content_margin_left = 16
	confirm_sb.content_margin_right = 16
	confirm_sb.content_margin_top = 12
	confirm_sb.content_margin_bottom = 12
	_confirm.add_theme_stylebox_override("panel", confirm_sb)
	_board.add_child(_confirm)
	var ask := VBoxContainer.new()
	ask.add_theme_constant_override("separation", 10)
	_confirm.add_child(ask)
	var ask_l := KIT.label("pause.give_up_ask", 20, KIT.INK, true)
	ask.add_child(ask_l)
	var yes := KIT.choice_tag("pause.give_up_yes", Vector2(120, 16))
	yes.pressed.connect(_on_give_up_yes)
	ask.add_child(yes)
	_hook_hover(yes)
	var no := KIT.choice_tag("pause.give_up_no", Vector2(120, 16))
	no.pressed.connect(_on_give_up_no)
	ask.add_child(no)
	_hook_hover(no)

	if DevFlag.on():
		var latest_row := HBoxContainer.new()
		latest_row.position = Vector2(24, 1000)
		latest_row.add_theme_constant_override("separation", 10)
		add_child(latest_row)
		latest_row.add_child(_btn("Play Latest", Color("3a3220"), Color("e8c36a"), _pick.bind("latest"), 160))
		latest_row.add_child(_btn("Developer Test", Color("1c1814"), Color("8a8178"), _pick.bind("dev"), 180))
		latest_row.add_child(_btn("Roster", Color("3a2820"), Color("c4a574"), _on_roster, 110))
		latest_row.add_child(_btn("Script", Color("3a2820"), Color("c4a574"), _on_script, 110))
	_layout_buttons()
	apply_copy()


func apply_copy() -> void:
	if _title:
		if _page == "developer":
			_title.text = "Developer Mode"
		else:
			_title.text = COPY.text("pause.settings", "Settings")
	if _hint:
		_hint.text = COPY.text("pause.hint", "")
	if _btn_resume:
		_btn_resume.text = COPY.text("pause.resume", "Resume")
	if _btn_quit:
		_btn_quit.text = COPY.text("pause.quit", "Quit")
	if _btn_peek:
		_btn_peek.text = COPY.text("pause.peek", "")
	if _btn_give_up:
		_btn_give_up.text = COPY.text("pause.give_up", "")
	if _btn_dev:
		_btn_dev.text = "Developer Mode"
	if _btn_fresh:
		_btn_fresh.text = "Fresh Save"
	if _btn_complete:
		_btn_complete.text = "One Hundred Percent Complete"
	if _btn_buckets:
		_btn_buckets.text = "Bucket Progress"
	if _btn_dev_back:
		_btn_dev_back.text = "Back"


func _layout_buttons() -> void:
	var on_dev: bool = _page == "developer"
	if _btn_resume:
		_btn_resume.visible = not on_dev
	if _btn_peek:
		_btn_peek.visible = false
	if _btn_give_up:
		_btn_give_up.visible = (not on_dev) and _in_run
	if _btn_sparkles:
		_btn_sparkles.visible = not on_dev
		_btn_sparkles.text = "Item sparkles: on" if sparkles_on else "Item sparkles: off"
	if _btn_invert:
		_btn_invert.visible = not on_dev
		_btn_invert.text = "Invert scroll: on" if invert_scroll else "Invert scroll: off"
	if _btn_quit:
		_btn_quit.visible = (not on_dev) and not OS.has_feature("web")
	if _btn_dev:
		_btn_dev.visible = not on_dev
	if _btn_fresh:
		_btn_fresh.visible = on_dev
	if _btn_complete:
		_btn_complete.visible = on_dev
	if _btn_buckets:
		_btn_buckets.visible = on_dev
	if _btn_dev_back:
		_btn_dev_back.visible = on_dev
	if _sl_wrap:
		_sl_wrap.visible = not on_dev
	var shown: Array = []
	var buttons: Array = [_btn_resume, _btn_sparkles, _btn_invert, _btn_give_up, _btn_quit, _btn_dev] if not on_dev else [_btn_fresh, _btn_complete, _btn_buckets, _btn_dev_back]
	for b in buttons:
		if b == null or not b.visible or b.get_parent() != _board:
			continue
		shown.append(b)
	var row_h: float = 26.0
	var block: float = float(shown.size()) * row_h
	var y: float = 46.0 + maxf(0.0, (88.0 - block) * 0.5)
	for b2 in shown:
		var wide: bool = on_dev and b2 != _btn_dev_back
		b2.position = Vector2(24.0 if wide else 36.0, y) * PX
		y += row_h
	if _sl_wrap and _sl_wrap.visible:
		_sl_wrap.position = Vector2(24, 132) * PX


func _set_page(page: String) -> void:
	_page = page
	apply_copy()
	_layout_buttons()


func _add_slider(host: VBoxContainer, which: String, label: String) -> VolumeSlider:
	var sl := VolumeSlider.new()
	sl.setup(which, label)
	if sl.slider:
		KIT.apply_hslider(sl.slider)
	sl.value_changed.connect(_on_slider.bind(which))
	host.add_child(sl)
	return sl


func _btn(text: String, fill: Color, rim: Color, cb: Callable, width: float = 140) -> Button:
	var b := FitButton.new()
	b.max_font_size = 16
	b.min_font_size = 12
	b.text = text
	b.custom_minimum_size = Vector2(width, 36)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	var n := StyleBoxFlat.new()
	n.bg_color = fill
	n.border_color = rim
	n.set_border_width_all(2)
	n.set_corner_radius_all(999)
	n.content_margin_left = 14
	n.content_margin_right = 14
	n.content_margin_top = 6
	n.content_margin_bottom = 6
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate()
	(h as StyleBoxFlat).bg_color = fill.lightened(0.16)
	b.add_theme_stylebox_override("hover", h)
	b.pressed.connect(cb)
	_hook_hover(b)
	return b


func _hook_hover(b: Button) -> void:
	b.mouse_entered.connect(func() -> void:
		if _audio and _audio.has_method("play_event"):
			_audio.play_event(&"ui.hover_menu")
	)


func open_menu(in_run: bool = true) -> void:
	_in_run = in_run
	_keep_paused = get_tree().paused
	_page = "main"
	if _confirm:
		_confirm.visible = false
	_layout_buttons()
	apply_copy()
	if _audio:
		_sfx_ready = false
		if _master:
			_master.set_linear(_audio.master_lin)
		_sfx_ready = true
		if _audio.has_method("on_pause"):
			_audio.on_pause(true)
		if _audio.has_method("play_event"):
			_audio.play_event(&"ui.menu_open")
	visible = true
	move_to_front()
	get_tree().paused = true
	if _board:
		_board.position.y = -180.0 * PX
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.set_trans(Tween.TRANS_BACK)
		tw.set_ease(Tween.EASE_OUT)
		tw.tween_property(_board, "position:y", _board_y, 0.22)


func close_menu() -> void:
	if _audio and _audio.has_method("play_event"):
		_audio.play_event(&"ui.resume")
	elif _audio:
		_audio.play("click", -10.0)
	if _audio and _audio.has_method("on_pause"):
		_audio.on_pause(false)
	_page = "main"
	visible = false
	if not _keep_paused:
		get_tree().paused = false
	closed.emit()


func _on_slider(value: float, which: String) -> void:
	if _audio == null:
		return
	var lin: float = value / 100.0
	match which:
		"Master":
			_audio.set_master(lin)
		"Music":
			_audio.set_music(lin)
		"Ambience":
			_audio.set_ambience(lin)
			if _sfx_ready and _audio.has_method("play_event"):
				_audio.play_event(&"ui.slider_tick", {"bus": "Ambience"})
		"SFX":
			_audio.set_sfx(lin)
			if _sfx_ready and _audio.has_method("play_event"):
				_audio.play_event(&"ui.slider_tick", {"bus": "SFX"})
		"UI":
			_audio.set_ui(lin)
			if _sfx_ready and _audio.has_method("play_event"):
				_audio.play_event(&"ui.slider_tick", {"bus": "UI"})


func _on_sparkles() -> void:
	sparkles_on = not sparkles_on
	if _btn_sparkles:
		_btn_sparkles.text = "Item sparkles: on" if sparkles_on else "Item sparkles: off"
	sparkles_toggled.emit(sparkles_on)


func _on_invert_scroll() -> void:
	invert_scroll = not invert_scroll
	if _btn_invert:
		_btn_invert.text = "Invert scroll: on" if invert_scroll else "Invert scroll: off"
	invert_scroll_toggled.emit(invert_scroll)


func _on_resume() -> void:
	if _audio:
		_audio.play("click", -8.0)
	close_menu()


func _pick(mode: String) -> void:
	if _audio:
		_audio.play("confirm", -8.0)
	close_menu()
	mode_picked.emit(mode)


func _on_roster() -> void:
	if _audio:
		_audio.play("book", -10.0)
	visible = false
	roster_pressed.emit()


func _on_script() -> void:
	if _audio:
		_audio.play("book", -10.0)
	visible = false
	script_pressed.emit()


func _on_quit() -> void:
	get_tree().paused = false
	quit_pressed.emit()
	get_tree().quit()


func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		close_menu()


func _on_peek() -> void:
	peek_pressed.emit()


func _on_give_up() -> void:
	if _confirm:
		_confirm.visible = true


func _on_give_up_yes() -> void:
	_confirm.visible = false
	close_menu()
	give_up_confirmed.emit()


func _on_give_up_no() -> void:
	if _confirm:
		_confirm.visible = false


func _on_developer() -> void:
	if _audio:
		_audio.play("click", -8.0)
	_set_page("developer")


func _on_dev_back() -> void:
	if _audio:
		_audio.play("click", -10.0)
	_set_page("main")


func _on_fresh() -> void:
	if _audio:
		_audio.play("confirm", -8.0)
	fresh_save_pressed.emit()


func _on_complete() -> void:
	if _audio:
		_audio.play("confirm", -8.0)
	complete_save_pressed.emit()


func _on_buckets() -> void:
	if _audio:
		_audio.play("book", -10.0)
	bucket_progress_pressed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if _master != null and _master.slider != null and _master.slider.has_focus():
		if event is InputEventKey and event.pressed:
			return
	if event.is_action_pressed("ui_cancel"):
		if _confirm and _confirm.visible:
			_confirm.visible = false
		elif _page == "developer":
			_set_page("main")
		else:
			close_menu()
		get_viewport().set_input_as_handled()
