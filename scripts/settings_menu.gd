extends ColorRect
## Escape overlay: volumes + the same start options as the title screen.

signal closed
signal quit_pressed
signal mode_picked(mode: String)
signal roster_pressed
signal script_pressed

const COPY := preload("res://scripts/player_copy.gd")
const UX := preload("res://scripts/ux_style.gd")

const SOOT := Color("1A120E")
const OAK := Color("3B2618")
const EDGE := Color("7A4E2B")
const GOLD := Color("FFD84A")
const PARCHMENT := Color("E9D3A1")
const DIM := Color("A88C66")
const VOID := Color("0B0706")
const TORCH := Color("F09A34")

var _master: HSlider
var _music: HSlider
var _sfx: HSlider
var _lab_master: Label
var _lab_music: Label
var _lab_sfx: Label
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
var _font_px: Font
var _font_vt: Font


func setup(audio) -> void:
	_audio = audio
	_font_px = load("res://assets/ui/fonts/PixelifySans-Bold.ttf")
	_font_vt = load("res://assets/ui/fonts/VT323-Regular.ttf")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	set_anchors_preset(PRESET_FULL_RECT)
	color = Color(SOOT, 0.72)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 120
	gui_input.connect(_on_dim_input)

	var panel := PanelContainer.new()
	panel.position = Vector2(520, 120)
	panel.custom_minimum_size = Vector2(640, 800)
	var sb: StyleBoxTexture = UX.oak_panel(false, 34.0)
	sb.content_margin_top = 44
	sb.content_margin_bottom = 44
	panel.add_theme_stylebox_override("panel", sb)
	add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 18)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(col)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_px != null:
		_title.add_theme_font_override("font", _font_px)
	_title.add_theme_font_size_override("font_size", 54)
	_title.add_theme_color_override("font_color", GOLD)
	col.add_child(_title)

	_master = _add_slider(col, "Master")
	_music = _add_slider(col, "Music")
	_sfx = _add_slider(col, "SFX")

	_hint = Label.new()
	_hint.visible = false
	col.add_child(_hint)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	col.add_child(row)
	_btn_resume = _gold_btn("", _on_resume)
	_btn_resume.custom_minimum_size = Vector2(0, 72)
	_btn_resume.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _font_px != null:
		_btn_resume.add_theme_font_override("font", _font_px)
	_btn_resume.add_theme_font_size_override("font_size", 38)
	row.add_child(_btn_resume)
	_btn_quit = _oak_btn("", _on_quit, Vector2(180, 72), 28)
	if not OS.has_feature("web"):
		row.add_child(_btn_quit)

	_play = Label.new()
	_play.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_vt != null:
		_play.add_theme_font_override("font", _font_vt)
	_play.add_theme_font_size_override("font_size", 22)
	_play.add_theme_color_override("font_color", DIM)
	col.add_child(_play)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	col.add_child(grid)
	_btn_how = _oak_btn("", _pick.bind("tutorial"), Vector2(0, 56), 28)
	_btn_dive = _oak_btn("", _pick.bind("dive"), Vector2(0, 56), 28)
	_btn_begin = _oak_btn("", _pick.bind("begin"), Vector2(0, 56), 28)
	_btn_adventure = _oak_btn("", _pick.bind("adventure"), Vector2(0, 56), 28)
	for b in [_btn_how, _btn_dive, _btn_begin, _btn_adventure]:
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(b)

	if OS.has_feature("editor"):
		var dev_row := HBoxContainer.new()
		dev_row.alignment = BoxContainer.ALIGNMENT_CENTER
		dev_row.add_theme_constant_override("separation", 10)
		col.add_child(dev_row)
		dev_row.add_child(_oak_btn("Developer Test", _pick.bind("dev"), Vector2(200, 44), 20))
		dev_row.add_child(_oak_btn("Roster", _on_roster, Vector2(120, 44), 20))
		dev_row.add_child(_oak_btn("Script", _on_script, Vector2(110, 44), 20))
	apply_copy()


func apply_copy() -> void:
	if _title:
		_title.text = COPY.need("pause.settings")
	if _lab_master:
		_lab_master.text = COPY.need("pause.master")
	if _lab_music:
		_lab_music.text = COPY.need("pause.music")
	if _lab_sfx:
		_lab_sfx.text = COPY.need("pause.sound")
	if _hint:
		_hint.text = COPY.text("pause.hint", "")
	if _btn_resume:
		_btn_resume.text = COPY.need("pause.resume")
	if _btn_quit:
		_btn_quit.text = COPY.need("pause.quit")
	if _play:
		_play.text = COPY.need("pause.start_over")
	if _btn_how:
		_btn_how.text = COPY.need("title.how_to_play")
	if _btn_dive:
		_btn_dive.text = COPY.need("title.dive_in")
	if _btn_begin:
		_btn_begin.text = COPY.need("title.begin")
	if _btn_adventure:
		_btn_adventure.text = COPY.need("title.adventure")


func _add_slider(host: VBoxContainer, which: String) -> HSlider:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 6)
	var lab := Label.new()
	if _font_vt != null:
		lab.add_theme_font_override("font", _font_vt)
	lab.add_theme_font_size_override("font_size", 28)
	lab.add_theme_color_override("font_color", DIM)
	wrap.add_child(lab)
	match which:
		"Master":
			_lab_master = lab
		"Music":
			_lab_music = lab
		"SFX":
			_lab_sfx = lab
	var sl := HSlider.new()
	sl.min_value = 0
	sl.max_value = 100
	sl.step = 1
	sl.custom_minimum_size = Vector2(0, 30)
	var track := StyleBoxFlat.new()
	track.bg_color = VOID
	track.border_color = EDGE
	track.set_border_width_all(3)
	track.content_margin_top = 6
	track.content_margin_bottom = 6
	sl.add_theme_stylebox_override("slider", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = TORCH
	sl.add_theme_stylebox_override("grabber_area", fill)
	sl.add_theme_stylebox_override("grabber_area_highlight", fill)
	sl.value_changed.connect(_on_slider.bind(which))
	wrap.add_child(sl)
	host.add_child(wrap)
	return sl


func _gold_btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.theme_type_variation = "ButtonGold"
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_color_override("font_color", SOOT)
	var n := StyleBoxFlat.new()
	n.bg_color = GOLD
	n.border_color = SOOT
	n.set_border_width_all(4)
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate() as StyleBoxFlat
	h.bg_color = Color("FFE27A")
	b.add_theme_stylebox_override("hover", h)
	b.pressed.connect(cb)
	return b


func _oak_btn(text: String, cb: Callable, mins: Vector2, fs: int) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = mins
	b.theme_type_variation = "ButtonOak"
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if _font_px != null:
		b.add_theme_font_override("font", _font_px)
	b.add_theme_font_size_override("font_size", fs)
	b.add_theme_color_override("font_color", PARCHMENT)
	var n := StyleBoxFlat.new()
	n.bg_color = Color(0, 0, 0, 0)
	n.border_color = EDGE
	n.set_border_width_all(4)
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate() as StyleBoxFlat
	h.border_color = GOLD
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
	if _btn_resume:
		_btn_resume.grab_focus()
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
		if event.position.x < 520 or event.position.x > 1160 or event.position.y < 120 or event.position.y > 920:
			close_menu()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()
