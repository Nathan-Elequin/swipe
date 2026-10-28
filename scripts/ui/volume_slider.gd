extends Control
class_name VolumeSlider
## Pause Master slider. One bar: name, track, number. The whole bar is the hit target.

signal value_changed(value: float)

const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const KEY_STEP := 5.0
const PAGE_STEP := 10.0
const ROW_W := 512.0
const ROW_H := 64.0

var which: String = "Master"
var slider: HSlider
var _lab: Label
var _val: Label
var _plate: NinePatchRect
var _dragging: bool = false


func setup(p_which: String, label_text: String) -> void:
	which = p_which
	name = "VolumeSlider_%s" % which
	process_mode = Node.PROCESS_MODE_ALWAYS
	custom_minimum_size = Vector2(ROW_W, ROW_H)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	focus_mode = Control.FOCUS_ALL

	_plate = NinePatchRect.new()
	_plate.name = "Plate"
	_plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_plate.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_set_plate(false)
	add_child(_plate)

	var row := HBoxContainer.new()
	row.name = "Row"
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 44.0
	row.offset_right = -28.0
	row.offset_top = 4.0
	row.offset_bottom = -4.0
	row.add_theme_constant_override("separation", 12)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)

	_lab = Label.new()
	_lab.name = "Name"
	_lab.text = label_text if label_text != "" else which
	_lab.custom_minimum_size = Vector2(108, 0)
	_lab.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_lab.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lab.add_theme_font_size_override("font_size", 22)
	_lab.add_theme_color_override("font_color", KIT.INK)
	row.add_child(_lab)

	slider = HSlider.new()
	slider.name = "Slider"
	slider.min_value = 0
	slider.max_value = 100
	slider.step = KEY_STEP
	slider.page = PAGE_STEP
	slider.custom_minimum_size = Vector2(180, 32)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.focus_mode = Control.FOCUS_NONE
	slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slider.scrollable = false
	slider.add_theme_constant_override("center_grabber", 1)
	slider.value_changed.connect(_on_slide)
	KIT.apply_hslider(slider)
	row.add_child(slider)

	_val = Label.new()
	_val.name = "ValueReadout"
	_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_val.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_val.custom_minimum_size = Vector2(52, 0)
	_val.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_val.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_val.add_theme_font_size_override("font_size", 22)
	_val.add_theme_color_override("font_color", KIT.INK)
	row.add_child(_val)

	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))
	_refresh_readout()


func set_linear(lin: float) -> void:
	if slider == null:
		return
	slider.set_value_no_signal(clampf(lin, 0.0, 1.0) * 100.0)
	_refresh_readout()


func linear_value() -> float:
	if slider == null:
		return 0.0
	return slider.value / 100.0


static func stepped(value: float, delta: float, lo: float = 0.0, hi: float = 100.0) -> float:
	return clampf(value + delta, lo, hi)


func _set_plate(hover: bool) -> void:
	if _plate == null:
		return
	var rel := "ui/choice_tag_hover.png" if hover else "ui/choice_tag_idle.png"
	var tex := KIT.load_tex(rel)
	if tex == null:
		return
	_plate.texture = tex
	_plate.patch_margin_left = 32
	_plate.patch_margin_top = 16
	_plate.patch_margin_right = 32
	_plate.patch_margin_bottom = 16


func _on_hover(hover: bool) -> void:
	_set_plate(hover)


func _on_slide(value: float) -> void:
	_refresh_readout()
	value_changed.emit(value)


func _refresh_readout() -> void:
	if _val == null or slider == null:
		return
	_val.text = str(int(round(slider.value)))


func _apply_x(local_x: float) -> void:
	if slider == null:
		return
	var origin := get_global_rect().position.x
	var track := slider.get_global_rect()
	var left := track.position.x - origin
	var width := maxf(1.0, track.size.x)
	var t := clampf((local_x - left) / width, 0.0, 1.0)
	slider.value = t * 100.0


func _gui_input(event: InputEvent) -> void:
	if slider == null:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_dragging = true
				grab_focus()
				_apply_x(mb.position.x)
			else:
				_dragging = false
			accept_event()
			return
		if mb.pressed and (mb.button_index == MOUSE_BUTTON_WHEEL_UP or mb.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var wheel := KEY_STEP if mb.button_index == MOUSE_BUTTON_WHEEL_UP else -KEY_STEP
			slider.value = stepped(slider.value, wheel)
			accept_event()
			return
	if event is InputEventMouseMotion and _dragging:
		_apply_x((event as InputEventMouseMotion).position.x)
		accept_event()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		_on_key(event as InputEventKey)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		_dragging = false
		return
	if not _dragging:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_dragging = false
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		_apply_x(get_local_mouse_position().x)
		get_viewport().set_input_as_handled()


func _on_key(key: InputEventKey) -> void:
	if slider == null:
		return
	var delta: float = 0.0
	match key.keycode:
		KEY_LEFT, KEY_DOWN:
			delta = -KEY_STEP
		KEY_RIGHT, KEY_UP:
			delta = KEY_STEP
		KEY_PAGEUP:
			delta = PAGE_STEP
		KEY_PAGEDOWN:
			delta = -PAGE_STEP
		KEY_HOME:
			slider.value = 0
			accept_event()
			return
		KEY_END:
			slider.value = 100
			accept_event()
			return
		_:
			return
	slider.value = stepped(slider.value, delta)
	accept_event()
