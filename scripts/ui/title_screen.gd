extends Control
## H3p-B title: stacked art layers + continue hint. Diegetic Spinheritance lives on the map PNG.

const COPY := preload("res://scripts/player_copy.gd")

@onready var _press: Label = $PressStart

var _pulse_on: bool = true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = TEXTURE_FILTER_NEAREST
	if _press:
		# No title.press_start key — reuse intro continue copy (do not invent PRESS START).
		_press.text = COPY.text("intro.next", "Click to continue")
		_press.add_theme_color_override("font_color", Color(0.9137255, 0.8117647, 0.5960785, 0.65))
		_press.add_theme_constant_override("outline_size", 0)
		_press.add_theme_font_size_override("font_size", 16)
		_press.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_press.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_press.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art := get_node_or_null("Art")
	if art is Control:
		(art as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		for child in art.get_children():
			if child is Control:
				(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_press_visible(on: bool) -> void:
	_pulse_on = on
	if _press:
		_press.visible = on
		if on:
			_press.modulate.a = 1.0


func _process(_delta: float) -> void:
	if not visible or not _pulse_on or _press == null or not _press.visible:
		return
	# Optional slow alpha pulse ~0.45↔0.65 over 1.6s (SCREEN §6).
	var t: float = Time.get_ticks_msec() * 0.001
	var a: float = 0.45 + 0.20 * (0.5 + 0.5 * sin(t * (TAU / 1.6)))
	_press.modulate.a = a
