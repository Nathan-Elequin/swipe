extends Control
## Layered dungeon hall: dark floor, wall band, sparse props, dais under the wheel.

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
	set_process(true)


func bump_hall() -> void:
	hall += 1
	queue_redraw()


func reset_hall() -> void:
	hall = 0
	_pan = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	if art == null or not art.ready_ok:
		draw_rect(Rect2(Vector2.ZERO, size), Color("0a0807"), true)
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color("0a0807"), true)
	var ts: float = 48.0
	var cols: int = int(ceil(size.x / ts)) + 2
	var rows: int = int(ceil(size.y / ts)) + 1
	var floors: Array = ["floor_1", "floor_2", "floor_3", "floor_4", "floor_5", "floor_6", "floor_7", "floor_8"]
	var room: float = 1.0 - 0.06 * float(hall % 4)
	var floor_mod := Color(0.38 * room, 0.34 * room, 0.30 * room, 1.0)
	if hall % 3 == 1:
		floor_mod = Color(0.32 * room, 0.30 * room, 0.36 * room, 1.0)
	elif hall % 3 == 2:
		floor_mod = Color(0.36 * room, 0.28 * room, 0.26 * room, 1.0)
	var ox: float = fmod(pan, ts)
	if ox < 0.0:
		ox += ts
	var shift: int = hall * 5 + int(floor(pan / ts))
	for y in range(2, rows):
		for x in range(-1, cols):
			var n: String = str(floors[((x + shift) * 3 + y * 7) % floors.size()])
			_blit(n, Vector2(float(x) * ts - ox, y * ts), Vector2(ts, ts), floor_mod)
	var wall_mod := Color(0.55 * room, 0.50 * room, 0.44 * room, 1.0)
	for x in range(-1, cols):
		var cap: String = "wall_top_mid"
		if x + shift == 0:
			cap = "wall_top_left"
		_blit(cap, Vector2(float(x) * ts - ox, 0.0), Vector2(ts, ts), wall_mod)
		_blit("wall_mid", Vector2(float(x) * ts - ox, ts), Vector2(ts, ts), wall_mod)
	_blit("wall_banner_red", Vector2(ts * 1.0 - ox, ts), Vector2(ts, ts), Color(0.7, 0.55, 0.5, 1.0))
	_blit("wall_banner_yellow", Vector2(size.x - ts * 2.0 - ox, ts), Vector2(ts, ts), Color(0.7, 0.62, 0.45, 1.0))
	var flicker: float = 0.32 + 0.12 * sin(_t * 5.2)
	_glow(Vector2(ts * 1.5, ts * 1.35), flicker)
	_glow(Vector2(size.x - ts * 1.5, ts * 1.35), flicker * 0.9)
	_blit("column", Vector2(10.0, size.y * 0.18), Vector2(40, 128), Color(0.5, 0.46, 0.4, 1.0))
	_blit("column", Vector2(size.x - 50.0, size.y * 0.18), Vector2(40, 128), Color(0.5, 0.46, 0.4, 1.0))
	_blit("chest_full_open_anim_f0", Vector2(18.0, size.y - 72.0), Vector2(44, 44), Color(0.55, 0.5, 0.42, 1.0))
	_blit("skull", Vector2(size.x - 64.0, size.y - 64.0), Vector2(36, 36), Color(0.6, 0.55, 0.48, 1.0))
	_blit("crate", Vector2(size.x - 118.0, size.y - 80.0), Vector2(40, 56), Color(0.5, 0.46, 0.4, 1.0))
	var dais: Vector2 = size * 0.5 + Vector2(0.0, 18.0)
	var dais_r: float = minf(size.x, size.y) * 0.28
	draw_circle(dais, dais_r, Color(0.04, 0.03, 0.02, 0.78))
	draw_arc(dais, dais_r, 0.0, TAU, 48, Color(0.12, 0.09, 0.07, 0.55), 6.0, true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 130.0)), Color(0.03, 0.02, 0.015, 0.55), true)
	draw_rect(Rect2(Vector2(0.0, size.y - 150.0), Vector2(size.x, 150.0)), Color(0.03, 0.02, 0.015, 0.62), true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(110.0, size.y)), Color(0.03, 0.02, 0.015, 0.58), true)
	draw_rect(Rect2(Vector2(size.x - 110.0, 0.0), Vector2(110.0, size.y)), Color(0.03, 0.02, 0.015, 0.58), true)


func _blit(name: String, pos: Vector2, sz: Vector2, modulate: Color = Color.WHITE) -> void:
	var t: Texture2D = art.tile(name)
	if t == null:
		return
	draw_texture_rect(t, Rect2(pos, sz), false, modulate)


func _glow(pos: Vector2, a: float) -> void:
	var fire: Texture2D = art.vfx.get("flame", null)
	if fire != null:
		var c := Color(1.0, 0.5, 0.18, 0.28 * a)
		draw_texture_rect(fire, Rect2(pos - Vector2(22, 30), Vector2(44, 58)), false, c)
	_blit("wall_fountain_mid_red_anim_f%d" % (int(_t * 6.0) % 3), pos - Vector2(16, 16), Vector2(32, 32), Color(1.0, 0.7, 0.4, 0.45 * a))
