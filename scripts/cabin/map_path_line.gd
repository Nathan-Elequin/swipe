class_name MapPathLine
extends Line2D
## Dashed shortcut path on the held map. Package D.


const KIT := preload("res://scripts/cabin/cabin_kit.gd")

var _draw_tw: Tween
var _march: bool = false
var _reduce_motion: bool = false


func setup(from: Vector2, to: Vector2, dash_tex: Texture2D = null) -> void:
	name = "MapPathLine"
	width = 8.0
	default_color = Color("5C3A22")
	joint_mode = Line2D.LINE_JOINT_ROUND
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	antialiased = false
	if dash_tex != null:
		texture = dash_tex
		texture_mode = Line2D.LINE_TEXTURE_TILE
	clear_points()
	add_point(from)
	add_point(from)
	set_meta("path_from", from)
	set_meta("path_to", to)


func set_reduce_motion(on: bool) -> void:
	_reduce_motion = on


## Draw the path in over `seconds` (or appear whole when reduce_motion).
func play_draw_in(seconds: float = 1.2, march_after: bool = true) -> void:
	var from: Vector2 = get_meta("path_from", points[0] if points.size() > 0 else Vector2.ZERO)
	var to: Vector2 = get_meta("path_to", from)
	if _draw_tw != null and is_instance_valid(_draw_tw):
		_draw_tw.kill()
	if _reduce_motion or seconds <= 0.0:
		set_point_position(1, to)
		_march = march_after
		return
	set_point_position(1, from)
	_draw_tw = create_tween()
	_draw_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_draw_tw.set_trans(Tween.TRANS_CUBIC)
	_draw_tw.set_ease(Tween.EASE_IN_OUT)
	_draw_tw.tween_method(_set_end, from, to, seconds / maxf(0.001, Engine.time_scale))
	await _draw_tw.finished
	_march = march_after


func appear_whole() -> void:
	var to: Vector2 = get_meta("path_to", Vector2.ZERO)
	if points.size() >= 2:
		set_point_position(1, to)
	_march = false


func _set_end(p: Vector2) -> void:
	if points.size() >= 2:
		set_point_position(1, p)


func _process(delta: float) -> void:
	if not _march or _reduce_motion:
		return
	## March dashes while the shortcut is fresh.
	if texture != null:
		## Line2D has no dash_offset; nudge width pulse instead is worse.
		## Prefer texture offset via modulate alpha bob when no shader.
		modulate.a = 0.85 + 0.15 * sin(Time.get_ticks_msec() * 0.006)
	else:
		modulate.a = 1.0
