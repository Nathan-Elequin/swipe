extends Control
## Soot ground for Direction A. Hall pan/bump stay so main.gd can still call them.

var art
var _t: float = 0.0
var hall: int = 0
var _pan: float = 0.0
var pan: float:
	get:
		return _pan
	set(v):
		_pan = v
		queue_redraw()


func setup(p_art) -> void:
	art = p_art
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(PRESET_FULL_RECT)
	z_index = -8
	texture_filter = TEXTURE_FILTER_NEAREST
	set_process(false)


func bump_hall() -> void:
	hall += 1
	queue_redraw()


func reset_hall() -> void:
	hall = 0
	_pan = 0.0
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("1A120E"), true)
