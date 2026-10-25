extends VBoxContainer
class_name VolumeSlider
## Pause Master slider: large hit, 0–100 readout, keyboard steps.

signal value_changed(value: float)

const PX := 4.0
const KEY_STEP := 5.0
const PAGE_STEP := 10.0

var which: String = "Master"
var slider: HSlider
var _lab: Label
var _val: Label


func setup(p_which: String, label_text: String) -> void:
	which = p_which
	name = "VolumeSlider_%s" % which
	add_theme_constant_override("separation", 6)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(row)
	_lab = Label.new()
	_lab.text = label_text
	_lab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lab.add_theme_font_size_override("font_size", 18)
	_lab.add_theme_color_override("font_color", Color("f0e6d8"))
	row.add_child(_lab)
	_val = Label.new()
	_val.name = "ValueReadout"
	_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_val.custom_minimum_size = Vector2(48, 22)
	_val.add_theme_font_size_override("font_size", 18)
	_val.add_theme_color_override("font_color", Color("fff3d6"))
	row.add_child(_val)
	slider = HSlider.new()
	slider.name = "Slider"
	slider.min_value = 0
	slider.max_value = 100
	slider.step = KEY_STEP
	slider.page = PAGE_STEP
	slider.custom_minimum_size = Vector2(152.0 * PX, 48)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.focus_mode = Control.FOCUS_ALL
	slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slider.scrollable = true
	slider.add_theme_constant_override("center_grabber", 1)
	slider.value_changed.connect(_on_slide)
	slider.gui_input.connect(_on_slider_keys)
	add_child(slider)
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


func _on_slide(value: float) -> void:
	_refresh_readout()
	value_changed.emit(value)


func _refresh_readout() -> void:
	if _val == null or slider == null:
		return
	_val.text = str(int(round(slider.value)))


func _on_slider_keys(event: InputEvent) -> void:
	if slider == null or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key: InputEventKey = event
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
