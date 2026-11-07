extends Control
## Small gold play-triangle for framed title selection (study B: 8×12 at left inset).

const COL := Color("efc36e")

var _active: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(8, 12)


func set_active(on: bool) -> void:
	_active = on
	visible = on
	queue_redraw()


func _draw() -> void:
	if not _active and not visible:
		return
	var w: float = size.x if size.x > 0.0 else 8.0
	var h: float = size.y if size.y > 0.0 else 12.0
	var pts := PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(w, h * 0.5),
		Vector2(0.0, h),
	])
	draw_colored_polygon(pts, COL)
