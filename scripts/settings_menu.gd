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
signal playtest_path_pressed(kind: String)
signal bucket_progress_pressed
signal go_deeper_pressed
signal victory_code_pressed
signal sparkles_toggled(on: bool)
signal invert_scroll_toggled(on: bool)
signal reduce_motion_toggled(on: bool)

const COPY := preload("res://scripts/player_copy.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const SETTINGS_PANEL := preload("res://scripts/ui/settings_panel.gd")
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
var _btn_go_deeper: Button
var _btn_victory_code: Button
var _btn_dev: Button
var _btn_fresh: Button
var _btn_complete: Button
var _btn_path_quick: Button
var _btn_path_deeper: Button
var _btn_path_big: Button
var _btn_buckets: Button
var _btn_sparkles: Button
var sparkles_on: bool = true
var invert_scroll: bool = false
var reduce_motion: bool = false
var show_go_deeper: bool = false
var show_victory_code: bool = false
var _btn_invert: Button
var _btn_reduce: Button
var _btn_dev_back: Button
var _confirm: Control
var _in_run: bool = true
var _board: Control
var _keep_paused: bool = false
var _board_y: float = 40.0 * PX
var _page: String = "main"
var _settings_panel = null

## Board art is 800x720. The cream plaque is the top-center strip (x 240–563, y 0–58).
const _TITLE_POS := Vector2(240, 2)
const _TITLE_SIZE := Vector2(324, 54)
## Inner wood, inside the frame. Buttons and the Master bar stay in this band.
const _CONTENT_TOP := 88.0
const _CONTENT_BOTTOM := 664.0
const _ROW_H := 64.0
const _ROW_GAP := 12.0
const _BTN_X := 144.0
const _BOARD_W := 800.0


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

	_title = KIT.label("pause.settings", 32, KIT.INK)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.max_lines = 1
	_title.position = _TITLE_POS
	_title.size = _TITLE_SIZE
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

	_btn_go_deeper = KIT.choice_tag("pause.go_deeper", Vector2(128, 16))
	_btn_go_deeper.pressed.connect(_on_go_deeper)
	_board.add_child(_btn_go_deeper)
	_hook_hover(_btn_go_deeper)

	_btn_victory_code = KIT.choice_tag("pause.victory_code", Vector2(128, 16))
	_btn_victory_code.pressed.connect(_on_victory_code)
	_board.add_child(_btn_victory_code)
	_hook_hover(_btn_victory_code)

	## Shared SettingsPanel (3 toggles + Sound Settings page) — same type as title Settings.
	## Toggle copy keys (also applied inside SettingsPanel.apply_toggle_labels):
	## settings.sparkles.on / settings.sparkles.off
	## settings.invert_scroll.on / settings.invert_scroll.off
	## settings.reduce_motion.on / settings.reduce_motion.off
	## settings.sound / settings.back
	_settings_panel = SETTINGS_PANEL.new()
	_settings_panel.setup(audio, false)
	_settings_panel.sparkles_toggled.connect(func(on: bool) -> void:
		sparkles_on = on
		sparkles_toggled.emit(on)
	)
	_settings_panel.invert_scroll_toggled.connect(func(on: bool) -> void:
		invert_scroll = on
		invert_scroll_toggled.emit(on)
	)
	_settings_panel.reduce_motion_toggled.connect(func(on: bool) -> void:
		reduce_motion = on
		reduce_motion_toggled.emit(on)
	)
	_settings_panel.page_changed.connect(func(_p: String) -> void:
		apply_copy()
		_layout_buttons()
	)
	_board.add_child(_settings_panel)
	## Aliases so existing layout/copy paths keep working.
	_btn_sparkles = _settings_panel._btn_sparkles
	_btn_invert = _settings_panel._btn_invert
	_btn_reduce = _settings_panel._btn_reduce
	_master = _settings_panel.volume_slider("Master")

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
		_btn_path_quick = KIT.choice_tag("pause.resume", Vector2(160, 16))
		_btn_path_quick.text = "Complete Quick Path"
		_btn_path_quick.pressed.connect(_on_path.bind("quick"))
		_btn_path_quick.visible = false
		_board.add_child(_btn_path_quick)
		_hook_hover(_btn_path_quick)
		_btn_path_deeper = KIT.choice_tag("pause.resume", Vector2(160, 16))
		_btn_path_deeper.text = "Complete Deeper Path"
		_btn_path_deeper.pressed.connect(_on_path.bind("deeper"))
		_btn_path_deeper.visible = false
		_board.add_child(_btn_path_deeper)
		_hook_hover(_btn_path_deeper)
		_btn_path_big = KIT.choice_tag("pause.resume", Vector2(160, 16))
		_btn_path_big.text = "Complete Big Path"
		_btn_path_big.pressed.connect(_on_path.bind("big"))
		_btn_path_big.visible = false
		_board.add_child(_btn_path_big)
		_hook_hover(_btn_path_big)
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
		elif _settings_panel != null and _settings_panel.has_method("page") and str(_settings_panel.page()) == "sound":
			_title.text = COPY.text("settings.sound", "Sound Settings")
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
	if _btn_go_deeper:
		_btn_go_deeper.text = COPY.text("pause.go_deeper", "Go deeper")
	if _btn_victory_code:
		_btn_victory_code.text = COPY.text("pause.victory_code", "My victory code")
	if _btn_dev:
		_btn_dev.text = "Developer Mode"
	if _btn_fresh:
		_btn_fresh.text = "Fresh Save"
	if _btn_complete:
		_btn_complete.text = "One Hundred Percent Complete"
	if _btn_path_quick:
		_btn_path_quick.text = "Complete Quick Path"
	if _btn_path_deeper:
		_btn_path_deeper.text = "Complete Deeper Path"
	if _btn_path_big:
		_btn_path_big.text = "Complete Big Path"
	if _btn_buckets:
		_btn_buckets.text = "Bucket Progress"
	if _btn_dev_back:
		_btn_dev_back.text = "Back"


func _layout_buttons() -> void:
	var on_dev: bool = _page == "developer"
	var on_sound: bool = (not on_dev) and _settings_panel != null and _settings_panel.has_method("page") and str(_settings_panel.page()) == "sound"
	if _btn_resume:
		_btn_resume.visible = not on_dev and not on_sound
	if _btn_peek:
		_btn_peek.visible = false
	if _btn_give_up:
		_btn_give_up.visible = (not on_dev) and (not on_sound) and _in_run
	if _btn_go_deeper:
		_btn_go_deeper.visible = (not on_dev) and (not on_sound) and show_go_deeper
	if _btn_victory_code:
		_btn_victory_code.visible = (not on_dev) and (not on_sound) and show_victory_code
	if _settings_panel:
		_settings_panel.visible = not on_dev
		_settings_panel.sparkles_on = sparkles_on
		_settings_panel.invert_scroll = invert_scroll
		_settings_panel.reduce_motion = reduce_motion
		_settings_panel.apply_toggle_labels()
	if _btn_sparkles:
		_btn_sparkles.visible = (not on_dev) and (not on_sound)
	if _btn_invert:
		_btn_invert.visible = (not on_dev) and (not on_sound)
	if _btn_reduce:
		_btn_reduce.visible = (not on_dev) and (not on_sound)
	if _btn_quit:
		_btn_quit.visible = (not on_dev) and (not on_sound) and not OS.has_feature("web")
	if _btn_dev:
		_btn_dev.visible = not on_dev and not on_sound
	if _btn_fresh:
		_btn_fresh.visible = on_dev
	if _btn_complete:
		_btn_complete.visible = on_dev
	if _btn_path_quick:
		_btn_path_quick.visible = on_dev
	if _btn_path_deeper:
		_btn_path_deeper.visible = on_dev
	if _btn_path_big:
		_btn_path_big.visible = on_dev
	if _btn_buckets:
		_btn_buckets.visible = false
	if _btn_dev_back:
		_btn_dev_back.visible = on_dev
	if _master:
		_master.visible = on_sound
	var shown: Array = []
	var buttons: Array = [_btn_resume, _btn_go_deeper, _btn_victory_code, _btn_give_up, _btn_quit, _btn_dev] if not on_dev else [_btn_fresh, _btn_path_quick, _btn_path_deeper, _btn_path_big, _btn_complete, _btn_dev_back]
	for b in buttons:
		if b == null or not b.visible or b.get_parent() != _board:
			continue
		shown.append(b)
	var panel_rows: int = 0
	if _settings_panel != null and _settings_panel.visible:
		if _settings_panel.has_method("visible_row_count"):
			panel_rows = int(_settings_panel.visible_row_count())
		else:
			panel_rows = 4
		if on_sound:
			panel_rows += 1
	var row_count: int = shown.size() + panel_rows
	var gap: float = 4.0 if panel_rows > 0 else _ROW_GAP
	var row_h: float = 52.0 if panel_rows > 0 else _ROW_H
	var avail: float = _CONTENT_BOTTOM - _CONTENT_TOP
	var block: float = 0.0
	if row_count > 0:
		block = float(row_count) * row_h + float(maxi(row_count - 1, 0)) * gap
		if block > avail:
			gap = 0.0
			if row_count > 1:
				gap = maxf(0.0, (avail - float(row_count) * row_h) / float(row_count - 1))
			block = float(row_count) * row_h + float(maxi(row_count - 1, 0)) * gap
			if block > avail:
				gap = 0.0
				row_h = maxf(40.0, avail / float(row_count))
				block = float(row_count) * row_h
	var y: float = _CONTENT_TOP + maxf(0.0, (avail - block) * 0.5)
	var tag_w: float = 128.0 * PX
	for b2 in shown:
		var wide: bool = on_dev and b2 != _btn_dev_back
		var w: float = (160.0 * PX) if wide else tag_w
		b2.custom_minimum_size = Vector2(w, row_h)
		b2.size = Vector2(w, row_h)
		var x: float = (_BOARD_W - w) * 0.5 if wide else _BTN_X
		b2.position = Vector2(x, y)
		y += row_h + gap
	if _settings_panel != null and _settings_panel.visible:
		_settings_panel.position = Vector2((_BOARD_W - 512.0) * 0.5, y)
		if _settings_panel.has_method("layout_rows"):
			_settings_panel.layout_rows(row_h, gap)
		elif _settings_panel._rows:
			_settings_panel._rows.add_theme_constant_override("separation", int(gap))
			for child in _settings_panel._rows.get_children():
				if child is Control:
					(child as Control).custom_minimum_size = Vector2(512.0, row_h)
					(child as Control).size = Vector2(512.0, row_h)


func _set_page(page: String) -> void:
	_page = page
	apply_copy()
	_layout_buttons()


func _add_slider(host: Node, which: String, label: String) -> VolumeSlider:
	var sl := VolumeSlider.new()
	sl.setup(which, label)
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
	if _settings_panel and _settings_panel.has_method("show_page"):
		_settings_panel.show_page("main", false)
	if _confirm:
		_confirm.visible = false
	_layout_buttons()
	apply_copy()
	if _audio:
		_sfx_ready = false
		if _settings_panel and _settings_panel.has_method("sync_from_audio"):
			_settings_panel._audio = _audio
			_settings_panel.sync_from_audio()
		elif _master:
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
	if _settings_panel and _settings_panel.has_method("show_page"):
		_settings_panel.show_page("main", false)
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


func settings_panel_node():
	return _settings_panel


func open_sound_page() -> void:
	if _settings_panel and _settings_panel.has_method("show_page"):
		_settings_panel.show_page("sound")
		apply_copy()
		_layout_buttons()


func _on_sparkles() -> void:
	sparkles_on = not sparkles_on
	if _settings_panel:
		_settings_panel.sparkles_on = sparkles_on
		_settings_panel.apply_toggle_labels()
	sparkles_toggled.emit(sparkles_on)


func _on_invert_scroll() -> void:
	invert_scroll = not invert_scroll
	if _settings_panel:
		_settings_panel.invert_scroll = invert_scroll
		_settings_panel.apply_toggle_labels()
	invert_scroll_toggled.emit(invert_scroll)


func _on_reduce_motion() -> void:
	reduce_motion = not reduce_motion
	if _settings_panel:
		_settings_panel.reduce_motion = reduce_motion
		_settings_panel.apply_toggle_labels()
	reduce_motion_toggled.emit(reduce_motion)


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


func _on_go_deeper() -> void:
	if _audio:
		_audio.play("click", -8.0)
	close_menu()
	go_deeper_pressed.emit()


func _on_victory_code() -> void:
	if _audio:
		_audio.play("click", -8.0)
	close_menu()
	victory_code_pressed.emit()


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


func _on_path(kind: String) -> void:
	if _audio:
		_audio.play("confirm", -8.0)
	playtest_path_pressed.emit(kind)


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
		elif _settings_panel != null and _settings_panel.has_method("page") and str(_settings_panel.page()) == "sound":
			_settings_panel.show_page("main")
		else:
			close_menu()
		get_viewport().set_input_as_handled()
