extends Control
## Left-gutter outburst: diagonal wipe, portrait pans in, title stack under it.

const FX_RAYS := preload("res://scripts/fx_rays.gd")

var art
var _q: Array = []
var _draining: bool = false
var _tw: Tween
var _life: float = 0.0:
	set(v):
		_life = v
		queue_redraw()
var _clock: float = 0.0
var _tex: Texture2D
var _title: String = ""
var _call: String = ""
var _is_item: bool = false
var log_glow: bool = false
var card_id: String = ""


func setup(p_art) -> void:
	art = p_art
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 14
	top_level = true
	visible = false
	texture_filter = TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(252, 200)
	size = Vector2(252, 200)
	set_process(true)


func set_log_glow(on: bool) -> void:
	log_glow = on
	queue_redraw()


func play(payload: Dictionary) -> void:
	var ticket := {"payload": payload, "done": false}
	_q.append(ticket)
	if not _draining:
		await _drain()
	else:
		while is_instance_valid(self) and not bool(ticket.get("done", false)):
			await get_tree().process_frame


func _drain() -> void:
	_draining = true
	while not _q.is_empty():
		var t: Dictionary = _q.pop_front()
		await _show(t.get("payload", {}))
		t["done"] = true
	_draining = false


func _show(payload: Dictionary) -> void:
	if OS.has_feature("editor"):
		print("[resolve] slash.show ", payload.get("card_id", ""), " tex=", payload.get("tex", null) != null)
	_tex = payload.get("tex", null)
	_title = str(payload.get("title", "")).strip_edges()
	_call = str(payload.get("call", "")).strip_edges()
	_is_item = bool(payload.get("is_item", false))
	card_id = str(payload.get("card_id", ""))
	if _title == "" and _call == "" and _tex == null:
		return
	if size.x < 32.0 or size.y < 32.0:
		size = Vector2(252, 200)
	if _tw != null and is_instance_valid(_tw):
		_tw.kill()
	visible = true
	_life = 0.0
	_clock = 0.0
	log_glow = false
	var fast: bool = bool(payload.get("fast", false))
	_tw = create_tween()
	_tw.tween_property(self, "_life", 1.0, 0.06 if fast else 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var hold: float = 0.55 if _call == "Can't Flee" else (0.19 if fast else 0.38)
	_tw.tween_interval(hold)
	_tw.tween_property(self, "_life", 0.0, 0.08 if fast else 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await _tw.finished
	visible = false
	card_id = ""
	_tex = null
	_title = ""
	_call = ""
	queue_redraw()


func _process(delta: float) -> void:
	if not visible:
		return
	_clock += delta
	queue_redraw()


func _draw() -> void:
	if _life <= 0.01 or size.x < 32.0 or size.y < 32.0:
		return
	var a: float = clampf(_life, 0.0, 1.0)
	var r := Rect2(Vector2.ZERO, size)
	_draw_slash(r, a)
	var port := Rect2(Vector2((size.x - 168.0) * 0.5, 8.0), Vector2(168, 128))
	var slide: float = lerpf(-90.0, 0.0, a)
	port.position.x += slide
	var fill := Color(0.08, 0.06, 0.05, 0.92 * a)
	draw_rect(port, fill, true)
	var edge := Color("e8c36a")
	edge.a = a
	if log_glow:
		edge = Color("fff0c0")
	var rim: Rect2 = port.grow(-3.0)
	if rim.size.x > 1.0 and rim.size.y > 1.0:
		draw_rect(rim, edge, false, 3.0)
	if _tex != null and is_instance_valid(_tex):
		var bob: float = sin(_clock * 8.0) * 2.0 * a
		var dest := Rect2(port.position + Vector2(28.0, 8.0 + bob), Vector2(112, 112))
		var mod := Color(1, 1, 1, a)
		draw_texture_rect(_tex, dest, false, mod)
	var font: Font = get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var ink := Color("f0e6d8")
	ink.a = a
	var gold := Color("e8c36a")
	gold.a = a
	var y: float = port.end.y + 22.0
	if _is_item:
		_draw_centered(font, _title, y, 18, ink)
		if _call != "":
			y += 26.0
			var flash_gold := gold
			if _call == "Can't Flee" and sin(_clock * 14.0) > 0.0:
				flash_gold = Color("fff0c0")
				flash_gold.a = a
			_draw_centered(font, _call, y, 26, flash_gold)
	else:
		if _title != "":
			_draw_centered(font, _title, y, 18, ink)
			y += 22.0
		if _call != "":
			_draw_centered(font, _call, y, 22, gold)


func _draw_slash(r: Rect2, a: float) -> void:
	if r.size.x < 40.0 or r.size.y < 40.0:
		return
	var band := PackedVector2Array([
		r.position + Vector2(-20.0, r.size.y * 0.12),
		r.position + Vector2(r.size.x + 24.0, r.size.y * 0.02),
		r.position + Vector2(r.size.x + 24.0, r.size.y * 0.78),
		r.position + Vector2(-20.0, r.size.y * 0.92),
	])
	var dark := Color(0.04, 0.03, 0.03, 0.72 * a)
	draw_colored_polygon(band, dark)
	var gold := Color("e8c36a", 0.85 * a)
	draw_line(band[0], band[1], gold, 3.2, true)
	draw_line(band[3], band[2], gold, 2.2, true)
	var origin: Vector2 = r.position + Vector2(-8.0, r.size.y * 0.5)
	var dest: Vector2 = r.position + Vector2(r.size.x + 8.0, r.size.y * 0.38)
	FX_RAYS.draw(self, origin, dest, Color("e8c36a", 0.7 * a), _clock, false)


func _draw_centered(font: Font, text: String, y: float, fs: int, col: Color) -> void:
	if text == "":
		return
	var sz: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
	var p := Vector2((size.x - sz.x) * 0.5, y)
	var out := Color(0.06, 0.05, 0.04, col.a)
	for ox in [-1, 0, 1]:
		for oy in [-1, 0, 1]:
			if ox == 0 and oy == 0:
				continue
			draw_string(font, p + Vector2(ox, oy), text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, out)
	draw_string(font, p, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)
