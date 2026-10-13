extends ColorRect
## Escape overlay: volumes + the same start options as the title screen.

signal closed
signal quit_pressed
signal mode_picked(mode: String)
signal roster_pressed
signal script_pressed

const COPY := preload("res://scripts/player_copy.gd")

var _master: HSlider
var _music: HSlider
var _sfx: HSlider
var _audio
var _sfx_ready: bool = false
var _title: Label
var _hint: Label
var _play: Label
var _btn_resume: Button
var _btn_quit: Button
var _btn_how: Button
var _btn_dive: Button
var _btn_begin: Button
var _btn_adventure: Button


func setup(audio) -> void:
	_audio = audio
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	set_anchors_preset(PRESET_FULL_RECT)
	color = Color("100e0ce8")
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 120
	gui_input.connect(_on_dim_input)

	var center := CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("1c1814")
	sb.border_color = Color("c4a574")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(16)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 22
	sb.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	col.custom_minimum_size = Vector2(460, 0)
	panel.add_child(col)

	_title = Label.new()
	_title.text = "Settings"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 32)
	_title.add_theme_color_override("font_color", Color("c4a574"))
	col.add_child(_title)

	_master = _add_slider(col, "Master")
	_music = _add_slider(col, "Music")
	_sfx = _add_slider(col, "SFX")

	_hint = Label.new()
	_hint.text = "Escape resumes. Start over without closing the game."
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	_hint.add_theme_font_size_override("font_size", 14)
	_hint.add_theme_color_override("font_color", Color("9a8b78"))
	col.add_child(_hint)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	col.add_child(row)
	_btn_resume = _btn("Resume", Color("3a3220"), Color("e8c36a"), _on_resume, 140)
	_btn_quit = _btn("Quit", Color("3a2020"), Color("e07a7a"), _on_quit, 140)
	row.add_child(_btn_resume)
	if not OS.has_feature("web"):
		row.add_child(_btn_quit)

	_play = Label.new()
	_play.text = "Start over"
	_play.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_play.add_theme_font_size_override("font_size", 16)
	_play.add_theme_color_override("font_color", Color("c4a574"))
	col.add_child(_play)

	var modes := HBoxContainer.new()
	modes.alignment = BoxContainer.ALIGNMENT_CENTER
	modes.add_theme_constant_override("separation", 10)
	col.add_child(modes)
	_btn_how = _btn("How to Play", Color("3a2820"), Color("e8c36a"), _pick.bind("tutorial"), 132)
	_btn_dive = _btn("Dive In", Color("2a2622"), Color("c4a574"), _pick.bind("dive"), 110)
	_btn_begin = _btn("Begin", Color("2a2622"), Color("6a5f52"), _pick.bind("begin"), 100)
	modes.add_child(_btn_how)
	modes.add_child(_btn_dive)
	modes.add_child(_btn_begin)
	var adv_row := HBoxContainer.new()
	adv_row.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(adv_row)
	_btn_adventure = _btn("Adventure Mode", Color("3a2820"), Color("e8c36a"), _pick.bind("adventure"), 200)
	adv_row.add_child(_btn_adventure)

	if OS.has_feature("editor"):
		var latest_row := HBoxContainer.new()
		latest_row.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_child(latest_row)
		latest_row.add_child(_btn("Play Latest", Color("3a3220"), Color("e8c36a"), _pick.bind("latest"), 200))
		var dev_row := HBoxContainer.new()
		dev_row.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_child(dev_row)
		dev_row.add_child(_btn("Developer Test", Color("1c1814"), Color("8a8178"), _pick.bind("dev"), 200))
		dev_row.add_child(_btn("Roster", Color("3a2820"), Color("c4a574"), _on_roster, 120))
		dev_row.add_child(_btn("Script", Color("3a2820"), Color("c4a574"), _on_script, 110))
	apply_copy()


func apply_copy() -> void:
	if _title:
		_title.text = COPY.text("pause.settings", "Settings")
	if _hint:
		_hint.text = COPY.text("pause.hint", "Escape resumes. Start over without closing the game.")
	if _btn_resume:
		_btn_resume.text = COPY.text("pause.resume", "Resume")
	if _btn_quit:
		_btn_quit.text = COPY.text("pause.quit", "Quit")
	if _play:
		_play.text = COPY.text("pause.start_over", "Start over")
	if _btn_how:
		_btn_how.text = COPY.text("title.how_to_play", "How to Play")
	if _btn_dive:
		_btn_dive.text = COPY.text("title.dive_in", "Dive In")
	if _btn_begin:
		_btn_begin.text = COPY.text("title.begin", "Begin")
	if _btn_adventure:
		_btn_adventure.text = COPY.text("title.adventure", "Adventure Mode")


func _add_slider(host: VBoxContainer, label: String) -> HSlider:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 4)
	var lab := Label.new()
	lab.text = label
	lab.add_theme_font_size_override("font_size", 16)
	lab.add_theme_color_override("font_color", Color("f0e6d8"))
	wrap.add_child(lab)
	var sl := HSlider.new()
	sl.min_value = 0
	sl.max_value = 100
	sl.step = 1
	sl.custom_minimum_size = Vector2(360, 28)
	sl.value_changed.connect(_on_slider.bind(label))
	wrap.add_child(sl)
	host.add_child(wrap)
	return sl


func _btn(text: String, fill: Color, rim: Color, cb: Callable, width: float = 140) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(width, 44)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", Color("f0e6d8"))
	var n := StyleBoxFlat.new()
	n.bg_color = fill
	n.border_color = rim
	n.set_border_width_all(2)
	n.set_corner_radius_all(999)
	n.content_margin_left = 14
	n.content_margin_right = 14
	n.content_margin_top = 8
	n.content_margin_bottom = 8
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate()
	(h as StyleBoxFlat).bg_color = fill.lightened(0.16)
	b.add_theme_stylebox_override("hover", h)
	b.pressed.connect(cb)
	return b


func open_menu() -> void:
	if _audio:
		_sfx_ready = false
		_master.value = _audio.master_lin * 100.0
		_music.value = _audio.music_lin * 100.0
		_sfx.value = _audio.sfx_lin * 100.0
		_sfx_ready = true
	visible = true
	get_tree().paused = true


func close_menu() -> void:
	visible = false
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
		"SFX":
			_audio.set_sfx(lin)
			if _sfx_ready:
				_audio.play("click", -10.0)


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
		if event.position.x < 0:
			close_menu()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()
