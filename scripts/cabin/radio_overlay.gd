extends Control
## Settings as the Snatchwick Melodeon. Knobs call the existing audio setters.

signal closed

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0
const KNOB_KEYS := ["pause.master", "pause.music", "pause.ambience", "pause.sound", "pause.ui"]
const BEDS := ["cabin", "station_inn", "station_rag", "station_harp"]

var cabin
var extra: Dictionary = {}
var audio
var _body: TextureRect
var _knobs: Array = []
var _minus: Array = []
var _plus: Array = []
var _needle: TextureRect
var _station_lab
var _static_gen: int = 0
var _knob_hover: Dictionary = {}


func setup(p_cabin, p_extra: Dictionary, p_audio) -> void:
	cabin = p_cabin
	extra = p_extra
	audio = p_audio
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 20
	visible = false
	var v := KIT.veil()
	v.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			close()
	)
	add_child(v)
	var origin: Array = extra.get("overlay_origins", {}).get("overlays/radio_close.png", [60, 30])
	_body = KIT.tex_rect("overlays/radio_close.png", Vector2(float(origin[0]), float(origin[1])), Vector2(300, 200), 0)
	_body.mouse_filter = Control.MOUSE_FILTER_STOP
	_body.z_index = 1
	add_child(_body)
	var title := KIT.label("radio.title", 32, KIT.CREAM)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, (float(origin[1]) - 14.0) * PX)
	title.size = Vector2(1680, 40)
	title.z_index = 4
	add_child(title)
	var gloria := KIT.anim_sprite(
		["overlays/gloria_f0.png", "overlays/gloria_f1.png", "overlays/gloria_f2.png", "overlays/gloria_f3.png"],
		"g", 1000.0 / 180.0, true, Vector2.ZERO
	)
	var tube: Array = extra.get("radio_tube", [138, 14, 24, 34])
	gloria.position = _body.position + Vector2(float(tube[0]), float(tube[1])) * PX
	add_child(gloria)
	if gloria.sprite_frames:
		gloria.play("g")
	var centres: Array = extra.get("radio_knobs", [])
	var tip_keys := {1: "radio.tip.music", 2: "radio.tip.ambiance", 3: "radio.tip.sfx"}
	for i in centres.size():
		if i == 4:
			continue
		var c: Array = centres[i]
		var kn := TextureRect.new()
		kn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		kn.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		kn.position = _body.position + Vector2(float(c[0]) - 12.0, float(c[1]) - 12.0) * PX
		kn.size = Vector2(24, 24) * PX
		kn.z_index = 2
		kn.mouse_filter = Control.MOUSE_FILTER_STOP
		kn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var idx: int = i
		kn.gui_input.connect(func(ev: InputEvent) -> void:
			_knob_input(idx, ev)
		)
		kn.mouse_entered.connect(func() -> void:
			_knob_hover[idx] = true
			_refresh_knob(idx)
			if tip_keys.has(idx) and cabin:
				cabin.show_hover_tag(str(tip_keys[idx]), kn, {})
		)
		kn.mouse_exited.connect(func() -> void:
			_knob_hover[idx] = false
			_refresh_knob(idx)
			if cabin:
				cabin.hide_hover_tag()
		)
		add_child(kn)
		_knobs.append(kn)
		var mid_x: float = kn.position.x + 12.0 * PX
		var row_y: float = kn.position.y + 25.0 * PX
		var minus_b: Button = KIT.step_tag("−")
		minus_b.position = Vector2(mid_x - 16.0 * PX, row_y)
		minus_b.z_index = 3
		minus_b.pressed.connect(func() -> void:
			_nudge(idx, -1.0)
		)
		add_child(minus_b)
		_minus.append(minus_b)
		var plus_b: Button = KIT.step_tag("+")
		plus_b.position = Vector2(mid_x + 2.0 * PX, row_y)
		plus_b.z_index = 3
		plus_b.pressed.connect(func() -> void:
			_nudge(idx, 1.0)
		)
		add_child(plus_b)
		_plus.append(plus_b)
		var lab := KIT.label(KNOB_KEYS[i], 16, KIT.CREAM)
		lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lab.position = Vector2(mid_x - 64.0, row_y + 13.0 * PX)
		lab.size = Vector2(160, 40)
		lab.z_index = 4
		lab.clip_contents = false
		add_child(lab)
		lab.fit()
	_needle = KIT.tex_rect("overlays/radio_needle.png", Vector2.ZERO, Vector2(4, 16), 2)
	add_child(_needle)
	_station_lab = KIT.label("radio.station.0", 28, KIT.TITLE_CREAM)
	_station_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_station_lab.position = _body.position + Vector2(66, 100) * PX
	_station_lab.size = Vector2(168, 32) * PX
	_station_lab.z_index = 4
	add_child(_station_lab)
	var cap := KIT.label("radio.station", 16, KIT.MUTED)
	cap.position = _station_lab.position + Vector2(0, 28)
	cap.size = Vector2(168, 20) * PX
	cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cap.z_index = 4
	add_child(cap)
	var sk := Control.new()
	var skc: Array = extra.get("station_knob", [262, 84])
	sk.position = _body.position + Vector2(float(skc[0]) - 12.0, float(skc[1]) - 12.0) * PX
	sk.size = Vector2(24, 24) * PX
	sk.mouse_filter = Control.MOUSE_FILTER_STOP
	sk.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	sk.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			_next_station()
	)
	add_child(sk)
	var dial := Control.new()
	var dr: Array = extra.get("station_dial", [66, 70, 168, 26])
	dial.position = _body.position + Vector2(float(dr[0]), float(dr[1])) * PX
	dial.size = Vector2(float(dr[2]), float(dr[3])) * PX
	dial.mouse_filter = Control.MOUSE_FILTER_STOP
	dial.z_index = 2
	dial.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			_next_station()
	)
	add_child(dial)
	var close_b: Button = KIT.choice_tag("radio.close", Vector2(80, 16))
	close_b.position = KIT.pt(180, 216)
	close_b.z_index = 2
	close_b.pressed.connect(close)
	add_child(close_b)


func open_radio() -> void:
	visible = true
	_refresh()
	_hum_static(-34.0, 0.25)
	KIT.cue(cabin.sfx if cabin else null, &"cabin.radio_on")


func close() -> void:
	if not visible:
		return
	stop_static()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.click")
	visible = false
	closed.emit()


func stop_static() -> void:
	_static_gen += 1
	if cabin and cabin.sfx and cabin.sfx.has_method("loop_stop"):
		cabin.sfx.loop_stop(&"amb.radio_static", 0.3)


func _vol(i: int) -> float:
	if audio == null:
		return 1.0
	match i:
		0:
			return float(audio.master_lin)
		1:
			return float(audio.music_lin)
		2:
			return float(audio.ambience_lin)
		3:
			return float(audio.sfx_lin)
		4:
			return float(audio.ui_lin)
	return 1.0


func _set_vol(i: int, v: float) -> void:
	v = clampf(v, 0.0, 1.0)
	if audio == null:
		return
	match i:
		0:
			audio.set_master(v)
		1:
			audio.set_music(v)
		2:
			audio.set_ambience(v)
		3:
			audio.set_sfx(v)
			audio.set_ui(v)
		4:
			audio.set_sfx(v)
			audio.set_ui(v)
	KIT.cue(cabin.sfx if cabin else null, &"cabin.radio_knob")
	KIT.cue(cabin.sfx if cabin else null, &"ui.slider_tick")
	_refresh_knob(i)


func _refresh() -> void:
	for i in _knobs.size():
		_refresh_knob(i)
	_place_needle()
	var st: int = int(cabin.radio_station) if cabin else 0
	_station_lab.text = KIT.copy_text("radio.station.%d" % st)


func _refresh_knob(i: int) -> void:
	var frame: int = clampi(int(round(_vol(i) * 8.0)), 0, 8)
	var hovered: bool = bool(_knob_hover.get(i, false))
	var rel: String = "overlays/radio_knob_hover_f%d.png" % frame if hovered else "overlays/radio_knob_f%d.png" % frame
	var tex: Texture2D = KIT.load_tex(rel)
	if tex == null and hovered:
		tex = KIT.load_tex("overlays/radio_knob_f%d.png" % frame)
	(_knobs[i] as TextureRect).texture = tex
	var v: float = _vol(i)
	if i < _minus.size():
		(_minus[i] as Button).disabled = v <= 0.001
	if i < _plus.size():
		(_plus[i] as Button).disabled = v >= 0.999


func _nudge(i: int, dir: float) -> void:
	var step: float = 1.0 / 32.0 if Input.is_key_pressed(KEY_SHIFT) else 1.0 / 8.0
	_set_vol(i, _vol(i) + dir * step)


func _place_needle() -> void:
	var dr: Array = extra.get("station_dial", [66, 70, 168, 26])
	var st: int = int(cabin.radio_station) if cabin else 0
	var x: float = float(dr[0]) + 6.0 + float(st) * (float(dr[2]) - 12.0) / 3.0
	_needle.position = _body.position + Vector2(x, float(dr[1])) * PX


func _knob_input(i: int, ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_WHEEL_UP:
			_nudge(i, 1.0)
		elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_nudge(i, -1.0)


func _hum_static(db: float, fade_s: float) -> void:
	_static_gen += 1
	if cabin and cabin.sfx and cabin.sfx.has_method("loop_start"):
		cabin.sfx.loop_start(&"amb.radio_static", fade_s, db)


func _burst_static() -> void:
	_hum_static(-18.0, 0.05)
	var gen: int = _static_gen
	get_tree().create_timer(0.6).timeout.connect(func() -> void:
		if gen != _static_gen or not visible:
			return
		_hum_static(-34.0, 0.3)
	)


func _next_station() -> void:
	if cabin == null:
		return
	cabin.radio_station = (int(cabin.radio_station) + 1) % 4
	cabin._save()
	KIT.cue(cabin.sfx if cabin else null, &"cabin.radio_tune")
	_burst_static()
	_place_needle()
	_station_lab.text = KIT.copy_text("radio.station.%d" % cabin.radio_station)
	if cabin.sfx and cabin.sfx.has_method("music_to"):
		cabin.sfx.music_to(StringName(BEDS[cabin.radio_station]), 0.6)
