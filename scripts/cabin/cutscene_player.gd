extends Control
## Intro and ending player. Key-ring panel uses the same frame. Copy keys only.

signal finished(skipped: bool)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const TEXT_RESERVE := preload("res://scripts/ui/text_reserve.gd")
const PX := 4.0
const CPS := 40.0
const FADE_S := 0.35
const SKIP_FADE_S := 0.3

var cabin
var playing: bool = false
var replay: bool = false
var skippable: bool = true
var kind: String = ""
var panel_index: int = 0

var _black: ColorRect
var _frame: TextureRect
var _panel_a: TextureRect
var _panel_b: TextureRect
var _fx: Control
var _rain: AnimatedSprite2D
var _drip: ColorRect
var _caption
var _bust: TextureRect
var _deed
## Intro will panel: live title + signature on the painted scroll (copy keys will.title / will.sign).
var _will_title
var _will_sign
var _skip: Button
var _autoplay: Button
var _next
var _bar: Control
var _bar_bg: Panel
var _glints: Array = []
var _panels: Array = []
var _line_i: int = 0
var _full: String = ""
var _shown: int = 0
var _typing: bool = false
var _acc: float = 0.0
var _hold: float = 0.0
var _elapsed: float = 0.0
var _web_wait: bool = false
var _audio_started: bool = false
var _busy_fade: bool = false
var _drip_t: float = 0.0
var _bust_t: float = 0.0
var _knock_done: bool = false
var _stamp_done: bool = false
var _motion: Tween
var _built: bool = false
var _held: bool = false


func setup(p_cabin) -> void:
	cabin = p_cabin
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 8
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()


func is_playing() -> bool:
	return playing


func play(p_kind: String, opts: Dictionary = {}) -> void:
	kind = p_kind
	replay = bool(opts.get("replay", false))
	skippable = kind != "keyring"
	playing = true
	visible = true
	if _bar:
		_bar.visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_audio_started = false
	_busy_fade = false
	# Itch already consumed a click to launch the iframe; waiting again hid
	# captions and made the first in-game click skip the still instead of reading it.
	_web_wait = false
	_panels = _make_panels(kind)
	panel_index = 0
	_skip.visible = skippable
	_sync_autoplay_btn()
	_black.modulate.a = 1.0
	_panel_b.modulate.a = 0.0
	_start_audio()
	_show_panel(0, true)
	set_process(true)


func request_advance() -> void:
	_advance()


func skip() -> void:
	if not playing:
		return
	if not skippable:
		_advance()
		return
	_busy_fade = true
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_black, "modulate:a", 1.0, SKIP_FADE_S)
	tw.tween_callback(func() -> void:
		_finish(true)
	)


func set_held(on: bool) -> void:
	_held = on
	set_process(playing and not _held)
	if _motion:
		if on:
			_motion.pause()
		else:
			_motion.play()


func abort() -> void:
	if not playing:
		return
	if _motion:
		_motion.kill()
		_motion = null
	_held = false
	_finish(true)


func _build() -> void:
	if _built:
		return
	_built = true
	_black = ColorRect.new()
	_black.color = Color("100e0c")
	_black.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_black)
	_frame = KIT.tex_rect("cutscenes/panel_frame.png", Vector2(42, 32), Vector2(336, 196), 4)
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_panel_a = TextureRect.new()
	_panel_a.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_panel_a.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_panel_a.stretch_mode = TextureRect.STRETCH_KEEP
	_panel_a.position = KIT.pt(50, 40)
	_panel_a.size = Vector2(320, 180) * PX
	_panel_a.pivot_offset = _panel_a.size * 0.5
	_panel_a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel_a.z_index = 1
	add_child(_panel_a)
	_panel_b = _panel_a.duplicate() as TextureRect
	_panel_b.modulate.a = 0.0
	_panel_b.z_index = 2
	add_child(_panel_b)
	# Native scroll coords from cutscenes/intro_p3.png (320x180 at 4x): title above the double rule, name on the signature rule.
	_will_title = KIT.fit_label("will.title", Rect2(KIT.pt(108, 22), KIT.pt(132, 28)), 34, 18, 2, KIT.INK, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_BOTTOM, 0)
	_will_title.visible = false
	_panel_a.add_child(_will_title)
	_will_sign = KIT.fit_label("will.sign", Rect2(KIT.pt(110, 136), KIT.pt(80, 11)), 28, 16, 1, KIT.INK, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_BOTTOM, 0)
	_will_sign.visible = false
	_panel_a.add_child(_will_sign)
	_fx = Control.new()
	_fx.name = "CutsceneFx"
	_fx.position = _panel_a.position
	_fx.size = _panel_a.size
	_fx.clip_contents = true
	_fx.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fx.z_index = 3
	_fx.z_as_relative = true
	_fx.set_meta("fx", true)
	add_child(_fx)
	_rain = KIT.anim_sprite(
		["cutscenes/rain_f0.png", "cutscenes/rain_f1.png", "cutscenes/rain_f2.png"],
		"r", 1000.0 / 90.0, true, Vector2.ZERO
	)
	_rain.visible = false
	_track_fx(_rain)
	_fx.add_child(_rain)
	_drip = ColorRect.new()
	_drip.color = Color("8cbc48")
	_drip.size = Vector2(2, 8)
	_drip.visible = false
	_drip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_track_fx(_drip)
	_fx.add_child(_drip)
	_bar = Control.new()
	_bar.name = "DialogBar"
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.clip_contents = true
	_bar.z_index = 6
	add_child(_bar)
	_bar_bg = Panel.new()
	_bar_bg.name = "DialogPanel"
	_bar_bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bar_sb := StyleBoxFlat.new()
	bar_sb.bg_color = Color("16110d")
	bar_sb.border_color = Color("3a3228")
	bar_sb.set_border_width_all(2)
	bar_sb.set_corner_radius_all(4)
	_bar_bg.add_theme_stylebox_override("panel", bar_sb)
	_bar.add_child(_bar_bg)
	_bust = TextureRect.new()
	_bust.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_bust.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bust.stretch_mode = TextureRect.STRETCH_KEEP
	_bust.size = Vector2(32, 32) * PX
	_bust.visible = false
	_bust.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.add_child(_bust)
	_caption = KIT.raw_label("", KIT.DIALOG_FONT, KIT.CREAM, true)
	_caption.max_lines = 3
	_caption.min_font_size = 16
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_caption.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_bar.add_child(_caption)
	_next = KIT.label("intro.next", 24, KIT.MUTED)
	_next.max_lines = 1
	_next.min_font_size = 16
	_next.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_next.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_next.visible = false
	_bar.add_child(_next)
	_layout_dialog()
	_deed = KIT.label("ending.deed", 34, KIT.INK)
	_deed.position = Vector2(200, 180)
	_deed.size = Vector2(1280, 48)
	_deed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_deed.visible = false
	_deed.z_index = 6
	add_child(_deed)
	_skip = Button.new()
	_skip.text = KIT.copy_text("intro.skip")
	_skip.flat = true
	_skip.size = KIT.pt(24, 14)
	_skip.position = Vector2(KIT.ROOM_W - 32.0 - _skip.size.x, 32.0)
	_skip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_skip.add_theme_font_size_override("font_size", 20)
	_skip.add_theme_color_override("font_color", KIT.MUTED)
	_skip.add_theme_color_override("font_hover_color", KIT.CREAM)
	_skip.z_index = 7
	_skip.pressed.connect(skip)
	add_child(_skip)
	_autoplay = Button.new()
	_autoplay.flat = true
	_autoplay.size = KIT.pt(48, 14)
	_autoplay.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_autoplay.add_theme_font_size_override("font_size", 20)
	_autoplay.add_theme_color_override("font_color", KIT.MUTED)
	_autoplay.add_theme_color_override("font_hover_color", KIT.CREAM)
	_autoplay.z_index = 7
	_autoplay.pressed.connect(_toggle_autoplay)
	add_child(_autoplay)
	_sync_autoplay_btn()
	gui_input.connect(_on_gui)


func _layout_dialog() -> void:
	var view := Vector2(KIT.ROOM_W, KIT.ROOM_H)
	if is_inside_tree():
		view = get_viewport_rect().size
	var L: Dictionary = KIT.dialog_bar(view)
	var bar: Rect2 = L["bar"]
	var inner: Rect2 = L["inner"]
	var bust_sz: Vector2 = L["bust_sz"]
	var prompt_h: float = float(L["prompt_h"])
	var gap: float = float(L["gap"])
	_bar.position = bar.position
	_bar.size = bar.size
	var text_x := inner.position.x
	var text_w := inner.size.x
	if _bust.visible:
		_bust.position = inner.position
		_bust.size = bust_sz
		text_x = inner.position.x + bust_sz.x + gap
		text_w = inner.size.x - bust_sz.x - gap
		_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var text_h := inner.size.y - prompt_h - gap
	_caption.position = Vector2(text_x, inner.position.y)
	_caption.size = Vector2(text_w, maxf(8.0, text_h))
	_caption.max_lines = 3
	_caption.max_font_size = KIT.DIALOG_FONT
	_caption.fit()
	var next_w := minf(420.0, text_w)
	_next.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_caption.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_next.position = Vector2(inner.end.x - next_w, inner.end.y - prompt_h)
	_next.size = Vector2(next_w, prompt_h)
	_next.fit()
	TEXT_RESERVE.settle(_bar)
	_caption.fit()
	_next.fit()
	_sync_fx_clip()


func _make_panels(p_kind: String) -> Array:
	if p_kind == "ending":
		return [
			{"tex": "cutscenes/ending_p1.png", "lines": [{"key": "ending.p1", "nib": false}], "hold": 6.0, "fx": "glint", "motion": "pan_x", "sting": "cabin.ending_start"},
			{"tex": "cutscenes/ending_p2.png", "lines": [{"key": "ending.p2", "nib": false}], "hold": 6.0, "fx": "", "motion": "", "stamp": true},
			{"tex": "cutscenes/ending_p3.png", "lines": [{"key": "ending.p3", "nib": false}, {"key": "ending.p4", "nib": false}, {"key": "ending.nib", "nib": true}], "hold": 7.0, "fx": "deed", "motion": "", "sting": "sting.ending"},
		]
	if p_kind == "keyring":
		return [
			{"tex": "cutscenes/keyring_p1.png", "lines": [{"key": "keyring.1", "nib": true}, {"key": "keyring.2", "nib": true}], "hold": 8.0, "fx": "", "motion": ""},
		]
	return [
		{"tex": "cutscenes/intro_p1.png", "lines": [{"key": "intro.p1", "nib": false}], "hold": 6.0, "fx": "rain_window", "motion": "push_in"},
		{"tex": "cutscenes/intro_p2.png", "lines": [{"key": "intro.p2", "nib": false}, {"key": "intro.p2_nib", "nib": true}], "hold": 6.0, "fx": "rain_full", "motion": "", "knock": true},
		{"tex": "cutscenes/intro_p3.png", "lines": [{"key": "intro.p3", "nib": false}, {"key": "intro.p3_nib", "nib": true}], "hold": 7.0, "fx": "", "motion": "nudge_up", "sting": "sting.intro", "will_text": true},
		{"tex": "cutscenes/intro_p4.png", "lines": [{"key": "intro.p4", "nib": false}], "hold": 5.0, "fx": "", "motion": "pan_x"},
		{"tex": "cutscenes/intro_p5.png", "lines": [{"key": "intro.p5_nib", "nib": true}], "hold": 6.0, "fx": "", "motion": ""},
	]


func _start_audio() -> void:
	if _audio_started:
		return
	_audio_started = true
	if kind == "intro":
		KIT.cue(cabin.sfx if cabin else null, &"cabin.intro_start")
	elif kind == "ending":
		KIT.cue(cabin.sfx if cabin else null, &"cabin.ending_start")
	elif kind == "keyring":
		KIT.cue(cabin.sfx if cabin else null, &"cabin.key_jingle")
		KIT.cue(cabin.sfx if cabin else null, &"cabin.panel")


func _show_panel(i: int, instant: bool) -> void:
	if i < 0 or i >= _panels.size():
		_finish(false)
		return
	panel_index = i
	var spec: Dictionary = _panels[i]
	_line_i = 0
	_elapsed = 0.0
	_hold = float(spec.get("hold", 6.0))
	_knock_done = false
	_stamp_done = false
	_drip_t = 0.0
	_clear_glints()
	_deed.visible = str(spec.get("fx", "")) == "deed"
	var tex: Texture2D = KIT.load_tex(str(spec.get("tex", "")))
	if instant:
		_panel_a.texture = tex
		_panel_a.position = KIT.pt(50, 40)
		_panel_a.scale = Vector2.ONE
		_panel_b.modulate.a = 0.0
		_apply_fx(spec)
		_start_motion(spec)
		_start_line()
		return
	KIT.cue(cabin.sfx if cabin else null, &"cabin.panel")
	_will_title.visible = false
	_will_sign.visible = false
	_panel_b.texture = tex
	_panel_b.position = KIT.pt(50, 40)
	_panel_b.scale = Vector2.ONE
	_panel_b.modulate.a = 0.0
	_busy_fade = true
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_panel_b, "modulate:a", 1.0, FADE_S)
	tw.tween_callback(func() -> void:
		_panel_a.texture = tex
		_panel_a.position = KIT.pt(50, 40)
		_panel_a.scale = Vector2.ONE
		_panel_b.modulate.a = 0.0
		_busy_fade = false
		_apply_fx(spec)
		_start_motion(spec)
		_start_line()
	)


func _apply_fx(spec: Dictionary) -> void:
	var fx: String = str(spec.get("fx", ""))
	var will_on: bool = bool(spec.get("will_text", false))
	_will_title.visible = will_on
	_will_sign.visible = will_on
	_rain.visible = fx.begins_with("rain")
	_drip.visible = fx == "rain_window"
	if fx == "rain_window":
		_rain.position = Vector2(210, 30) * PX
		if _rain.sprite_frames:
			_rain.play("r")
	elif fx == "rain_full":
		_rain.position = Vector2.ZERO
		if _rain.sprite_frames:
			_rain.play("r")
	if fx == "glint":
		_spawn_glints()
	_sync_fx_clip()
	var sting: String = str(spec.get("sting", ""))
	if sting != "" and sting != "cabin.ending_start":
		KIT.cue(cabin.sfx if cabin else null, StringName(sting))
	if sting == "cabin.ending_start" and not _audio_started:
		_start_audio()


func _start_motion(spec: Dictionary) -> void:
	if _motion:
		_motion.kill()
		_motion = null
	_panel_a.position = KIT.pt(50, 40)
	_panel_a.scale = Vector2.ONE
	var motion: String = str(spec.get("motion", ""))
	var hold: float = float(spec.get("hold", 6.0))
	if motion == "":
		return
	_motion = create_tween()
	_motion.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_motion.set_trans(Tween.TRANS_SINE)
	_motion.set_ease(Tween.EASE_IN_OUT)
	match motion:
		"push_in":
			_motion.tween_property(_panel_a, "scale", Vector2(1.03, 1.03), hold)
		"nudge_up":
			_motion.tween_property(_panel_a, "position:y", _panel_a.position.y - 4.0 * PX, hold)
		"pan_x":
			_motion.tween_property(_panel_a, "position:x", _panel_a.position.x - 6.0 * PX, hold)


func _start_line() -> void:
	var spec: Dictionary = _panels[panel_index]
	var lines: Array = spec.get("lines", [])
	if _line_i >= lines.size():
		_typing = false
		_next.visible = true
		return
	var line: Dictionary = lines[_line_i]
	_full = KIT.copy_text(str(line.get("key", "")))
	_shown = 0
	_acc = 0.0
	_typing = _full != ""
	_caption.text = _full
	_caption.visible_characters = 0 if _typing else -1
	_next.visible = _web_wait
	var is_nib: bool = bool(line.get("nib", false))
	_bust.visible = is_nib
	if is_nib:
		_bust.texture = KIT.load_tex("nib/nib_bust_f0.png")
		if not _web_wait and cabin and cabin.sfx and cabin.sfx.has_method("speak"):
			cabin.sfx.speak(&"nib", _full)
	_layout_dialog()
	if _web_wait:
		_typing = false
		_caption.visible_characters = 0


func _advance() -> void:
	if not playing or _busy_fade:
		return
	if _web_wait:
		_web_wait = false
		_start_audio()
		_typing = _full != ""
		_next.visible = false
		return
	if _typing:
		_shown = _full.length()
		_caption.visible_characters = _shown
		_typing = false
		_next.visible = true
		return
	var spec: Dictionary = _panels[panel_index]
	var lines: Array = spec.get("lines", [])
	_line_i += 1
	if _line_i < lines.size():
		_start_line()
		return
	if panel_index + 1 >= _panels.size():
		_finish(false)
		return
	_show_panel(panel_index + 1, false)


func _process(delta: float) -> void:
	if not playing or _held:
		return
	_tick_typing(delta)
	_tick_hold(delta)
	_tick_fx(delta)
	_tick_bust(delta)


func _tick_typing(delta: float) -> void:
	if not _typing or _web_wait:
		return
	_acc += delta * CPS
	var add: int = int(_acc)
	if add <= 0:
		return
	_acc -= float(add)
	_shown = mini(_full.length(), _shown + add)
	_caption.visible_characters = _shown
	if _shown >= _full.length():
		_typing = false
		_next.visible = true


func _autoplay_on() -> bool:
	if cabin != null and cabin.sfx != null:
		return bool(cabin.sfx.cutscene_autoplay)
	return true


func _autoplay_caption() -> String:
	var on: bool = _autoplay_on()
	var key: String = "intro.autoplay.on" if on else "intro.autoplay.off"
	var t: String = KIT.copy_text(key)
	if t != "":
		return t
	return "Autoplay: On" if on else "Autoplay: Off"


func _sync_autoplay_btn() -> void:
	if _autoplay == null:
		return
	_autoplay.visible = playing
	_autoplay.text = _autoplay_caption()
	var skip_x: float = KIT.ROOM_W - 32.0
	if _skip != null:
		skip_x = _skip.position.x
	_autoplay.position = Vector2(skip_x - 16.0 - _autoplay.size.x, 32.0)


func _toggle_autoplay() -> void:
	var on: bool = not _autoplay_on()
	if cabin != null and cabin.sfx != null and cabin.sfx.has_method("set_cutscene_autoplay"):
		cabin.sfx.set_cutscene_autoplay(on)
	_sync_autoplay_btn()


func _tick_hold(delta: float) -> void:
	if _web_wait or _busy_fade:
		return
	_elapsed += delta
	if not _autoplay_on():
		return
	if _elapsed < _hold:
		return
	if _typing:
		_advance()
		return
	if panel_index + 1 >= _panels.size():
		_finish(false)
	else:
		_show_panel(panel_index + 1, false)


func _tick_fx(delta: float) -> void:
	if panel_index < 0 or panel_index >= _panels.size():
		return
	var spec: Dictionary = _panels[panel_index]
	if str(spec.get("fx", "")) == "rain_window" and _drip.visible:
		_drip_t += delta
		if _drip_t >= 1.4:
			_drip_t = 0.0
			_drip.position = Vector2(186, 22) * PX
			var tw := create_tween()
			tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tw.tween_property(_drip, "position:y", 110.0 * PX, 0.7)
	if bool(spec.get("knock", false)) and not _knock_done and _elapsed >= 0.3:
		_knock_done = true
		KIT.cue(cabin.sfx if cabin else null, &"cabin.door")
		var t := get_tree().create_timer(0.18, true, true, true)
		t.timeout.connect(func() -> void:
			KIT.cue(cabin.sfx if cabin else null, &"cabin.door")
		, CONNECT_ONE_SHOT)
	if bool(spec.get("stamp", false)) and not _stamp_done and _elapsed >= 2.5:
		_stamp_done = true
		KIT.cue(cabin.sfx if cabin else null, &"cabin.seal_stamp")
		var base: Vector2 = _panel_a.position
		var sh := create_tween()
		sh.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		sh.tween_property(_panel_a, "position", base + Vector2(2, -2) * PX, 0.05)
		sh.tween_property(_panel_a, "position", base + Vector2(-2, 2) * PX, 0.05)
		sh.tween_property(_panel_a, "position", base, 0.05)


func _tick_bust(delta: float) -> void:
	if not _bust.visible or not _typing:
		return
	_bust_t += delta
	if _bust_t >= 0.12:
		_bust_t = 0.0
		var i: int = randi() % 3
		_bust.texture = KIT.load_tex("nib/nib_bust_f%d.png" % i)


func _spawn_glints() -> void:
	var spots: Array = [
		Vector2(40, 40), Vector2(120, 50), Vector2(200, 36),
		Vector2(80, 90), Vector2(160, 100), Vector2(240, 80),
	]
	for p in spots:
		var sp: AnimatedSprite2D = KIT.anim_sprite(
			["plaque_glint_f0.png", "plaque_glint_f1.png", "plaque_glint_f2.png", "plaque_glint_f3.png"],
			"g", 8.0, true, p
		)
		_track_fx(sp)
		_fx.add_child(sp)
		if sp.sprite_frames:
			sp.play("g")
		_glints.append(sp)


func _track_fx(node: CanvasItem) -> void:
	node.z_index = 0
	node.z_as_relative = true
	node.set_meta("fx", true)


func _frame_hole() -> Rect2:
	# panel_frame.png keeps an 8px-native clear window. Rain stays inside that hole.
	var inset := 8.0 * PX
	return Rect2(_frame.position + Vector2(inset, inset), _frame.size - Vector2(inset, inset) * 2.0)


func _sync_fx_clip() -> void:
	if _fx == null or _frame == null:
		return
	var hole := _frame_hole()
	if _bar != null and _bar.visible:
		var bar := Rect2(_bar.position, _bar.size)
		if hole.intersects(bar):
			hole.size.y = maxf(0.0, bar.position.y - hole.position.y)
	if _skip != null and _skip.visible:
		var skip_r := Rect2(_skip.position, _skip.size)
		if hole.intersects(skip_r) and skip_r.end.y > hole.position.y:
			var top: float = skip_r.end.y
			var bottom: float = hole.end.y
			hole.position.y = top
			hole.size.y = maxf(0.0, bottom - top)
	if _autoplay != null and _autoplay.visible:
		var ap_r := Rect2(_autoplay.position, _autoplay.size)
		if hole.intersects(ap_r) and ap_r.end.y > hole.position.y:
			var ap_bottom: float = hole.end.y
			hole.position.y = ap_r.end.y
			hole.size.y = maxf(0.0, ap_bottom - hole.position.y)
	_fx.position = hole.position
	_fx.size = hole.size
	_fx.clip_contents = true
	_fx.clip_children = CanvasItem.CLIP_CHILDREN_ONLY


func _clear_glints() -> void:
	for g in _glints:
		if is_instance_valid(g):
			g.queue_free()
	_glints.clear()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and playing:
		_layout_dialog()


func _on_gui(event: InputEvent) -> void:
	if not playing or _busy_fade:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_advance()
		accept_event()
	elif event.is_action_pressed("ui_accept"):
		_advance()
		accept_event()


func _finish(skipped: bool) -> void:
	if not playing:
		return
	playing = false
	set_process(false)
	if _motion:
		_motion.kill()
		_motion = null
	_clear_glints()
	_rain.visible = false
	_drip.visible = false
	_bust.visible = false
	_deed.visible = false
	_next.visible = false
	if _bar:
		_bar.visible = false
	if _autoplay:
		_autoplay.visible = false
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_web_wait = false
	finished.emit(skipped)
