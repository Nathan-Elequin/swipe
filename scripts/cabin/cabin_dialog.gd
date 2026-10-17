extends Control
## Nib talk box and a small non-blocking bubble. Copy keys only.

signal finished(choice: int)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const PX := 4.0

var cabin
var _box: NinePatchRect
var _shade: ColorRect
var _plate: NinePatchRect
var _plate_lab
var _bust: TextureRect
var _text
var _next: AnimatedSprite2D
var _choices: HBoxContainer
var _bubble: NinePatchRect
var _bubble_lab
var _bubble_tw: Tween
var _keys: Array = []
var _choice_keys: Array = []
var _line_i: int = 0
var _typing: bool = false
var _full: String = ""
var _shown: int = 0
var _cps: float = 45.0
var _acc: float = 0.0
var _bust_t: float = 0.0
var _bust_i: int = 0
var _blink_t: float = 4.0
var _open: bool = false
var _picked: int = -1
var _sfx
var _talk_cb: Callable


func setup(p_cabin) -> void:
	cabin = p_cabin
	_sfx = p_cabin.sfx if p_cabin else null
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 7
	visible = false
	_shade = ColorRect.new()
	_shade.name = "DialogShade"
	_shade.color = Color("100e0ce8")
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shade)
	_box = KIT.nine("ui/dialog_box_9.png", Vector2(12, 12))
	_box.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_box)
	_plate = KIT.nine("ui/nameplate_9.png", Vector2(6, 4))
	_plate.size = Vector2(40, 14) * PX
	_box.add_child(_plate)
	_plate_lab = KIT.label("tutorial.speaker", 18, KIT.INK)
	_plate_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_plate_lab.set_anchors_preset(PRESET_FULL_RECT)
	_plate.add_child(_plate_lab)
	_bust = TextureRect.new()
	_bust.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_bust.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bust.stretch_mode = TextureRect.STRETCH_KEEP
	_bust.size = Vector2(32, 32) * PX
	_bust.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_child(_bust)
	_text = KIT.raw_label("", 30, KIT.INK, true)
	_text.max_lines = 3
	_text.min_font_size = 16
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_box.add_child(_text)
	_next = KIT.anim_sprite(["ui/dialog_next_f0.png", "ui/dialog_next_f1.png"], "n", 1000.0 / 300.0, true, Vector2(0, 0))
	_box.add_child(_next)
	_choices = HBoxContainer.new()
	_choices.add_theme_constant_override("separation", int(12 * PX))
	_choices.visible = false
	_box.add_child(_choices)
	_layout_talk(false)
	_bubble = KIT.nine("ui/dialog_box_9.png", Vector2(8, 8))
	_bubble.visible = false
	_bubble.z_index = 8
	_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bubble)
	_bubble_lab = KIT.raw_label("", 26, KIT.INK)
	_bubble_lab.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.add_child(_bubble_lab)
	set_process(true)


func is_open() -> bool:
	return _open


func has_choices() -> bool:
	return _open and _choices.visible


func say(keys: Array, choices: Array = [], vars: Dictionary = {}) -> void:
	_keys = keys.duplicate()
	_choice_keys = choices.duplicate()
	_line_i = 0
	_picked = -1
	_open = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_choices.visible = false
	_layout_talk(choices.size() > 0)
	_box.modulate.a = 0.0
	_shade.modulate.a = 0.0
	var shade_tw := create_tween()
	shade_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	shade_tw.tween_property(_shade, "modulate:a", 1.0, 0.15)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_box, "modulate:a", 1.0, 0.15)
	if _keys.is_empty():
		_text.text = ""
		_text.visible_characters = -1
		_typing = false
		if _choice_keys.size() > 0:
			_show_choices()
		else:
			_close(-1)
		return
	_show_line(vars)


func say_bubble(key: String, at_native: Vector2 = Vector2(216, 150), vars: Dictionary = {}) -> void:
	var t: String = KIT.fill_text(key, vars)
	if t == "":
		t = KIT.copy_text(key)
	_bubble_lab.text = t
	_bubble_lab.size = Vector2.ZERO
	_bubble_lab.custom_minimum_size = Vector2(0, 0)
	var w: float = minf(140.0 * PX, maxf(40.0 * PX, t.length() * 11.0))
	_bubble_lab.custom_minimum_size = Vector2(w - 16.0, 0)
	_bubble.size = Vector2(w, 36 * PX)
	_bubble.position = Vector2(at_native.x * PX - w * 0.5, at_native.y * PX)
	_bubble.visible = true
	_bubble.modulate.a = 1.0
	if _bubble_tw:
		_bubble_tw.kill()
	var hold: float = 1.2 + 0.04 * float(t.length())
	_bubble_tw = create_tween()
	_bubble_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_bubble_tw.tween_interval(hold)
	_bubble_tw.tween_property(_bubble, "modulate:a", 0.0, 0.2)
	_bubble_tw.tween_callback(func() -> void:
		_bubble.visible = false
	)
	if key == "nib.prompt":
		KIT.cue(_sfx, &"speech.nib_psst")


func advance() -> void:
	if not _open:
		return
	if _choices.visible:
		return
	if _typing:
		_shown = _full.length()
		_text.visible_characters = _shown
		_typing = false
		_next.visible = true
		return
	_line_i += 1
	if _line_i >= _keys.size():
		if _choice_keys.size() > 0:
			_show_choices()
			return
		_close(-1)
		return
	_show_line({})


func pick(i: int) -> void:
	if not _choices.visible:
		return
	_close(i)


func _layout_talk(with_choices: bool) -> void:
	var view := Vector2(KIT.ROOM_W, KIT.ROOM_H)
	if is_inside_tree():
		view = get_viewport_rect().size
	var safe := 32.0
	var pad := 16.0
	var bust_sz := Vector2(32, 32) * PX
	var prompt_h := 36.0
	var gap := 12.0
	var box_h := 64.0 * PX
	if with_choices:
		box_h += 20.0 * PX
	var box_w := 300.0 * PX
	box_w = minf(box_w, view.x - safe * 2.0)
	var box_x := clampf((view.x - box_w) * 0.5, safe, view.x - safe - box_w)
	var box_y := view.y - safe - box_h
	_box.position = Vector2(box_x, box_y)
	_box.size = Vector2(box_w, box_h)
	_shade.position = Vector2(box_x - 8.0, box_y - 8.0)
	_shade.size = Vector2(box_w + 16.0, box_h + 16.0)
	_plate.position = Vector2(8, -8) * PX
	var inner := Rect2(Vector2(pad, pad), Vector2(box_w - pad * 2.0, box_h - pad * 2.0))
	_bust.position = inner.position
	_bust.size = bust_sz
	var text_x := inner.position.x + bust_sz.x + gap
	var text_w := inner.size.x - bust_sz.x - gap
	var text_h := inner.size.y - prompt_h - gap
	_text.position = Vector2(text_x, inner.position.y)
	_text.size = Vector2(maxf(8.0, text_w), maxf(8.0, text_h))
	_text.max_lines = 3
	_text.fit()
	_next.position = Vector2(inner.end.x - 18.0 * PX, inner.end.y - 16.0 * PX)
	_choices.position = Vector2(text_x, inner.end.y - prompt_h)
	_choices.size = Vector2(text_w, prompt_h)


func _show_line(_vars: Dictionary) -> void:
	var key: String = str(_keys[_line_i])
	_full = KIT.copy_text(key)
	_shown = 0
	_acc = 0.0
	_typing = true
	_text.text = _full
	_text.visible_characters = 0
	_next.visible = false
	_bust.texture = KIT.load_tex("nib/nib_bust_f0.png")
	if _sfx and _sfx.has_method("speak"):
		_sfx.speak(&"nib", _full)
	if cabin and cabin.has_method("nib_talk"):
		cabin.nib_talk(true)


func _show_choices() -> void:
	for c in _choices.get_children():
		c.queue_free()
	_choices.visible = true
	for i in _choice_keys.size():
		var b: Button = KIT.choice_tag(str(_choice_keys[i]), Vector2(92, 16))
		var idx: int = i
		b.pressed.connect(func() -> void:
			pick(idx)
		)
		_choices.add_child(b)
		b.scale = Vector2(0.8, 0.8)
		var tw := create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_interval(0.06 * float(i))
		tw.tween_property(b, "scale", Vector2.ONE, 0.12)


func _close(choice: int) -> void:
	_open = false
	_typing = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if cabin and cabin.has_method("nib_talk"):
		cabin.nib_talk(false)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(_box, "modulate:a", 0.0, 0.1)
	if _shade:
		tw.parallel().tween_property(_shade, "modulate:a", 0.0, 0.1)
	tw.tween_callback(func() -> void:
		visible = false
		_choices.visible = false
		finished.emit(choice)
	)


func _process(delta: float) -> void:
	if _open and _typing:
		_acc += delta * _cps
		while _acc >= 1.0 and _shown < _full.length():
			_acc -= 1.0
			_shown += 1
		_text.visible_characters = _shown
		if _shown >= _full.length():
			_typing = false
			_next.visible = true
			if _next.sprite_frames:
				_next.play("n")
		_bust_t += delta
		if _bust_t >= 0.09:
			_bust_t = 0.0
			_bust_i = (_bust_i + 1) % 3
			_bust.texture = KIT.load_tex("nib/nib_bust_f%d.png" % _bust_i)
	_blink_t -= delta
	if _blink_t <= 0.0 and _open and not _typing:
		_bust.texture = KIT.load_tex("nib/nib_bust_blink.png")
		_blink_t = randf_range(3.0, 5.0)


func _gui_input(event: InputEvent) -> void:
	if not _open:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		if _choices.visible:
			return
		advance()
		accept_event()
	if event.is_action_pressed("ui_left") and _choices.visible and _choices.get_child_count() > 0:
		(_choices.get_child(0) as Button).grab_focus()
		accept_event()
	if event.is_action_pressed("ui_right") and _choices.visible and _choices.get_child_count() > 1:
		(_choices.get_child(1) as Button).grab_focus()
		accept_event()
