extends Control
## Shared settings panel. Main page: 3 toggles + Sound Settings. Sound page: 5 volume sliders.
## Used by Esc pause and title Settings. Toggle labels use settings.*.on/off copy keys.

signal closed
signal sparkles_toggled(on: bool)
signal invert_scroll_toggled(on: bool)
signal reduce_motion_toggled(on: bool)
signal back_pressed
signal page_changed(page: String)

const COPY := preload("res://scripts/player_copy.gd")
const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0

const ROW_W := 512.0
const ROW_H := 64.0
const ROW_SEP := 8.0

var _audio
var _sfx_ready: bool = false
var sparkles_on: bool = true
var invert_scroll: bool = false
var reduce_motion: bool = false

var _btn_sparkles: Button
var _btn_invert: Button
var _btn_reduce: Button
var _btn_sound: Button
var _sliders: Dictionary = {} ## which -> VolumeSlider
var _btn_back: Button
var _rows: VBoxContainer
var show_back: bool = true
var _page: String = "main"
var _custom_back_pos: bool = false


func setup(audio, p_show_back: bool = true) -> void:
	_audio = audio
	show_back = p_show_back
	name = "SettingsPanel"
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	sync_from_audio()
	apply_toggle_labels()


func _build() -> void:
	_rows = VBoxContainer.new()
	_rows.name = "Rows"
	_rows.position = Vector2.ZERO
	_rows.custom_minimum_size = Vector2(ROW_W, 0)
	_rows.add_theme_constant_override("separation", int(ROW_SEP))
	_rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rows)

	_btn_sparkles = KIT.choice_tag("pause.resume", Vector2(128, 16))
	_btn_sparkles.custom_minimum_size = Vector2(ROW_W, ROW_H)
	_btn_sparkles.size = Vector2(ROW_W, ROW_H)
	_btn_sparkles.text = COPY.text("settings.sparkles.on", "Item sparkles: on")
	_btn_sparkles.pressed.connect(_on_sparkles)
	_rows.add_child(_btn_sparkles)
	_hook_hover(_btn_sparkles)

	_btn_invert = KIT.choice_tag("pause.resume", Vector2(128, 16))
	_btn_invert.custom_minimum_size = Vector2(ROW_W, ROW_H)
	_btn_invert.size = Vector2(ROW_W, ROW_H)
	_btn_invert.text = COPY.text("settings.invert_scroll.off", "Invert scroll: off")
	_btn_invert.pressed.connect(_on_invert)
	_rows.add_child(_btn_invert)
	_hook_hover(_btn_invert)

	_btn_reduce = KIT.choice_tag("pause.resume", Vector2(128, 16))
	_btn_reduce.custom_minimum_size = Vector2(ROW_W, ROW_H)
	_btn_reduce.size = Vector2(ROW_W, ROW_H)
	_btn_reduce.text = COPY.text("settings.reduce_motion.off", "Reduce motion: off")
	_btn_reduce.pressed.connect(_on_reduce)
	_rows.add_child(_btn_reduce)
	_hook_hover(_btn_reduce)

	_btn_sound = KIT.choice_tag("settings.sound", Vector2(128, 16))
	_btn_sound.custom_minimum_size = Vector2(ROW_W, ROW_H)
	_btn_sound.size = Vector2(ROW_W, ROW_H)
	_btn_sound.text = COPY.text("settings.sound", "Sound Settings")
	_btn_sound.pressed.connect(_on_sound)
	_rows.add_child(_btn_sound)
	_hook_hover(_btn_sound)

	for pair in [
		["Master", "pause.master"],
		["Music", "pause.music"],
		["Ambience", "pause.ambience"],
		["SFX", "pause.sound"],
		["UI", "pause.ui"],
	]:
		var which: String = pair[0]
		var key: String = pair[1]
		var label := COPY.text(key, which)
		var sl := VolumeSlider.new()
		sl.setup(which, label)
		sl.value_changed.connect(_on_slider.bind(which))
		_rows.add_child(sl)
		_sliders[which] = sl
		_hook_hover(sl)

	_btn_back = KIT.choice_tag("settings.back", Vector2(88, 16))
	_btn_back.text = COPY.text("settings.back", "Back")
	_btn_back.custom_minimum_size = Vector2(352, 64)
	_btn_back.size = Vector2(352, 64)
	_btn_back.pressed.connect(_on_back)
	add_child(_btn_back)
	_hook_hover(_btn_back)
	_apply_page()


func page() -> String:
	return _page


func visible_row_count() -> int:
	if _rows == null:
		return 0
	var n := 0
	for child in _rows.get_children():
		if child is Control and (child as Control).visible:
			n += 1
	return n


func show_page(p_page: String, emit_change: bool = true) -> void:
	var next: String = "sound" if p_page == "sound" else "main"
	if _page == next:
		_apply_page()
		return
	_page = next
	_apply_page()
	if emit_change:
		page_changed.emit(_page)


func _apply_page() -> void:
	var on_sound: bool = _page == "sound"
	if _btn_sparkles:
		_btn_sparkles.visible = not on_sound
	if _btn_invert:
		_btn_invert.visible = not on_sound
	if _btn_reduce:
		_btn_reduce.visible = not on_sound
	if _btn_sound:
		_btn_sound.visible = not on_sound
	for sl in _sliders.values():
		if sl is Control:
			(sl as Control).visible = on_sound
	if _btn_back:
		_btn_back.visible = on_sound or show_back
		_layout_back()


func _layout_back() -> void:
	if _btn_back == null or _custom_back_pos:
		return
	var n: int = visible_row_count()
	var y: float = float(n) * ROW_H + float(maxi(n, 0)) * ROW_SEP + 24.0
	if n <= 0:
		y = 24.0
	_btn_back.position = Vector2((ROW_W - 352.0) * 0.5, y)


func set_back_position(pos: Vector2) -> void:
	_custom_back_pos = true
	if _btn_back:
		_btn_back.position = pos


func layout_rows(row_h: float, gap: float) -> void:
	if _rows:
		_rows.add_theme_constant_override("separation", int(gap))
		for child in _rows.get_children():
			if child is Control and (child as Control).visible:
				(child as Control).custom_minimum_size = Vector2(ROW_W, row_h)
				(child as Control).size = Vector2(ROW_W, row_h)
	if _btn_back and _btn_back.visible and not _custom_back_pos:
		var n: int = visible_row_count()
		_btn_back.custom_minimum_size = Vector2(352.0, row_h)
		_btn_back.size = Vector2(352.0, row_h)
		_btn_back.position = Vector2((ROW_W - 352.0) * 0.5, float(n) * (row_h + gap))


func sync_from_audio() -> void:
	if _audio == null:
		return
	_sfx_ready = false
	_set_slider("Master", float(_audio.master_lin) if "master_lin" in _audio else 1.0)
	_set_slider("Music", float(_audio.music_lin) if "music_lin" in _audio else 1.0)
	_set_slider("Ambience", float(_audio.ambience_lin) if "ambience_lin" in _audio else 1.0)
	_set_slider("SFX", float(_audio.sfx_lin) if "sfx_lin" in _audio else 1.0)
	_set_slider("UI", float(_audio.ui_lin) if "ui_lin" in _audio else 1.0)
	_sfx_ready = true


func _set_slider(which: String, lin: float) -> void:
	var sl: VolumeSlider = _sliders.get(which) as VolumeSlider
	if sl:
		sl.set_linear(lin)


func volume_slider(which: String) -> VolumeSlider:
	return _sliders.get(which) as VolumeSlider


func toggle_buttons() -> Array:
	return [_btn_sparkles, _btn_invert, _btn_reduce]


func apply_toggle_labels() -> void:
	if _btn_sparkles:
		_btn_sparkles.text = COPY.text(
			"settings.sparkles.on" if sparkles_on else "settings.sparkles.off",
			"Item sparkles: on" if sparkles_on else "Item sparkles: off"
		)
	if _btn_invert:
		_btn_invert.text = COPY.text(
			"settings.invert_scroll.on" if invert_scroll else "settings.invert_scroll.off",
			"Invert scroll: on" if invert_scroll else "Invert scroll: off"
		)
	if _btn_reduce:
		_btn_reduce.text = COPY.text(
			"settings.reduce_motion.on" if reduce_motion else "settings.reduce_motion.off",
			"Reduce motion: on" if reduce_motion else "Reduce motion: off"
		)
	if _btn_sound:
		_btn_sound.text = COPY.text("settings.sound", "Sound Settings")


func _hook_hover(ctrl: Control) -> void:
	if ctrl == null:
		return
	ctrl.mouse_entered.connect(func() -> void:
		if _audio and _sfx_ready and _audio.has_method("play_event"):
			_audio.play_event(&"ui.hover_menu")
	)


func _on_slider(value: float, which: String) -> void:
	if _audio == null:
		return
	var lin: float = value / 100.0
	match which:
		"Master":
			if _audio.has_method("set_master"):
				_audio.set_master(lin)
		"Music":
			if _audio.has_method("set_music"):
				_audio.set_music(lin)
		"Ambience":
			if _audio.has_method("set_ambience"):
				_audio.set_ambience(lin)
			if _sfx_ready and _audio.has_method("play_event"):
				_audio.play_event(&"ui.slider_tick", {"bus": "Ambience"})
		"SFX":
			if _audio.has_method("set_sfx"):
				_audio.set_sfx(lin)
			if _sfx_ready and _audio.has_method("play_event"):
				_audio.play_event(&"ui.slider_tick", {"bus": "SFX"})
		"UI":
			if _audio.has_method("set_ui"):
				_audio.set_ui(lin)
			if _sfx_ready and _audio.has_method("play_event"):
				_audio.play_event(&"ui.slider_tick", {"bus": "UI"})


func _on_sparkles() -> void:
	sparkles_on = not sparkles_on
	apply_toggle_labels()
	sparkles_toggled.emit(sparkles_on)


func _on_invert() -> void:
	invert_scroll = not invert_scroll
	apply_toggle_labels()
	invert_scroll_toggled.emit(invert_scroll)


func _on_reduce() -> void:
	reduce_motion = not reduce_motion
	apply_toggle_labels()
	reduce_motion_toggled.emit(reduce_motion)


func _on_sound() -> void:
	if _audio and _audio.has_method("play_event"):
		_audio.play_event(&"ui.menu_open")
	show_page("sound")


func _on_back() -> void:
	if _audio and _audio.has_method("play_event"):
		_audio.play_event(&"ui.resume")
	if _page == "sound":
		show_page("main")
		return
	back_pressed.emit()
	closed.emit()
