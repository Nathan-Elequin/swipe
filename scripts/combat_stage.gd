extends Control
## Fighting portrait: idle bob, lunge on attack, hit flash, cartoon blood, impact stars.

signal edit_wanted(card_id: String)

var art
var card_id: String = ""
var _idle: Array = []
var _run: Array = []
var _fi: float = 0.0
var _mode: String = "idle"
var _flash: float = 0.0
var _blood: Array = []
var _bursts: Array = []
var _bob: float = 0.0
var _lunge_x: float = 0.0:
	set(v):
		_lunge_x = v
		queue_redraw()
var flip_h: bool = false
var log_glow: bool = false
var _watch_tex: Texture2D
var _watch_t: float = 0.0
var busy: bool = false


func setup(p_art) -> void:
	art = p_art
	custom_minimum_size = Vector2(168, 128)
	size = Vector2(168, 128)
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui)
	texture_filter = TEXTURE_FILTER_NEAREST
	z_index = 12
	top_level = true
	visible = false
	set_process(true)


func show_monster(id: String) -> void:
	card_id = id
	_idle = art.monster_idle(id) if art else []
	_run = art.monster_run(id) if art else []
	_mode = "idle"
	_fi = 0.0
	_flash = 0.0
	_blood.clear()
	_bursts.clear()
	_lunge_x = 0.0
	_watch_tex = null
	_watch_t = 0.0
	modulate = Color.WHITE
	scale = Vector2(0.72, 0.72)
	visible = true
	pivot_offset = size * 0.5
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.28)


func _on_gui(event: InputEvent) -> void:
	if card_id == "":
		return
	if not OS.has_feature("editor"):
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		edit_wanted.emit(card_id)
		accept_event()


func set_log_glow(on: bool) -> void:
	log_glow = on
	queue_redraw()


func mouth_global() -> Vector2:
	var r: Rect2 = get_global_rect()
	return r.position + Vector2(r.size.x * 0.52, r.size.y * 0.50)


func hide_stage() -> void:
	visible = false
	card_id = ""
	_idle.clear()
	_run.clear()
	_watch_tex = null
	_watch_t = 0.0


func take_hit() -> void:
	_flash = 1.0
	_splatter(Color("8a1818"))
	_burst("star", Color("f0e6d8"), 1.0)
	_burst("spark", Color("e07a7a"), 0.85)
	pivot_offset = size * 0.5
	var tw := create_tween()
	tw.tween_property(self, "rotation", 0.08, 0.05)
	tw.tween_property(self, "rotation", -0.06, 0.06)
	tw.tween_property(self, "rotation", 0.0, 0.08)


func lunge() -> void:
	if OS.has_feature("editor"):
		print("[resolve] stage.lunge id=", card_id, " frames=", _idle.size(), "/", _run.size())
	busy = true
	_mode = "run"
	var tw := create_tween()
	tw.tween_property(self, "_lunge_x", 22.0, 0.1).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "_lunge_x", 0.0, 0.16)
	await tw.finished
	_mode = "idle"
	busy = false


func play_hypnotize(watch: Texture2D) -> void:
	_watch_tex = watch
	_watch_t = 1.0
	_burst("magic", Color("e8c36a"), 1.15)
	_burst("twirl", Color("c4a574"), 1.0)
	pivot_offset = size * 0.5
	var tw := create_tween()
	tw.tween_property(self, "rotation", 0.05, 0.08)
	tw.tween_property(self, "rotation", -0.05, 0.1)
	tw.tween_property(self, "rotation", 0.0, 0.1)
	await tw.finished
	if get_tree():
		await get_tree().create_timer(0.18).timeout


func play_block() -> void:
	_flash = 0.85
	_burst("twirl", Color("5aa8e8"), 1.15)
	_burst("magic", Color("8ec8f0"), 1.0)
	_burst("star", Color("d8eefc"), 0.9)


func play_bleed() -> void:
	_flash = 0.95
	_splatter(Color("5c1a6a"))
	_burst("magic", Color("9b4dca"), 1.25)
	_burst("spark", Color("c77dff"), 1.0)
	_burst("twirl", Color("4a1870"), 0.85)
	for _i in 7:
		_blood.append({
			"p": Vector2(size.x * 0.5 + randf_range(-36.0, 36.0), 18.0 + randf_range(0.0, 24.0)),
			"r": randf_range(4.0, 10.0),
			"s": Vector2(randf_range(0.45, 0.8), randf_range(1.2, 2.1)),
			"rot": randf_range(-0.2, 0.2),
			"col": Color("7b2d9b") if randf() > 0.4 else Color("3a1048"),
			"t": 0.0,
			"life": randf_range(0.45, 0.85),
		})


func vanish() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	await tw.finished
	hide_stage()
	modulate.a = 1.0


func _process(delta: float) -> void:
	if not visible:
		return
	_fi += delta * (10.0 if _mode == "run" else 6.0)
	_bob += delta
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta * 4.2)
	if _watch_t > 0.0:
		_watch_t = maxf(0.0, _watch_t - delta * 0.85)
	var keep: Array = []
	for b in _blood:
		b["t"] = float(b["t"]) + delta
		if float(b["t"]) < float(b["life"]):
			keep.append(b)
	_blood = keep
	var keep2: Array = []
	for u in _bursts:
		u["t"] = float(u["t"]) + delta
		if float(u["t"]) < float(u["life"]):
			keep2.append(u)
	_bursts = keep2
	queue_redraw()


func _splatter(col: Color) -> void:
	for _i in 9:
		_blood.append({
			"p": size * 0.5 + Vector2(randf_range(-48.0, 48.0), randf_range(-28.0, 52.0)),
			"r": randf_range(6.0, 18.0),
			"s": Vector2(randf_range(0.7, 1.6), randf_range(0.5, 1.2)),
			"rot": randf_range(0.0, TAU),
			"col": col,
			"t": 0.0,
			"life": randf_range(0.35, 0.7),
		})


func _burst(kind: String, col: Color, sc: float) -> void:
	_bursts.append({
		"kind": kind,
		"col": col,
		"t": 0.0,
		"life": 0.42,
		"sc": sc,
		"p": size * 0.5 + Vector2(randf_range(-12.0, 12.0), randf_range(-8.0, 8.0)),
	})


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color("1a120e"), true)
	if art != null:
		_frame()
	var frames: Array = _run if _mode == "run" and not _run.is_empty() else _idle
	if not frames.is_empty():
		var tex: Texture2D = frames[int(_fi) % frames.size()]
		if tex == null or not is_instance_valid(tex):
			print("[resolve] stage.draw skipped null tex id=", card_id)
			return
		var bob: float = sin(_bob * 3.2) * 3.0
		var dest := Rect2(Vector2(size.x * 0.5 - 56.0 + _lunge_x, 14.0 + bob), Vector2(112, 124))
		if flip_h:
			dest = Rect2(Vector2(dest.position.x + dest.size.x, dest.position.y), Vector2(-dest.size.x, dest.size.y))
		var mod := Color.WHITE
		if _flash > 0.45:
			mod = Color(1.6, 1.6, 1.8)
		elif _flash > 0.0:
			mod = Color(1.0, 0.55, 0.5).lerp(Color.WHITE, 1.0 - _flash)
		draw_texture_rect(tex, dest, false, mod)
		if _watch_tex != null and _watch_t > 0.0:
			var pulse: float = 0.85 + sin(_bob * 10.0) * 0.08
			var wz := Vector2(48, 48) * pulse
			var wp := Vector2(size.x * 0.5 - wz.x * 0.5 + _lunge_x, 46.0 + bob)
			var wc := Color.WHITE
			wc.a = clampf(_watch_t, 0.35, 1.0)
			draw_texture_rect(_watch_tex, Rect2(wp, wz), false, wc)
	for b in _blood:
		var a: float = 1.0 - float(b["t"]) / float(b["life"])
		var c: Color = b["col"]
		c.a = a
		draw_set_transform(b["p"], float(b["rot"]), b["s"])
		draw_circle(Vector2.ZERO, float(b["r"]), c)
		draw_circle(Vector2(float(b["r"]) * 0.55, -2.0), float(b["r"]) * 0.45, c)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for u in _bursts:
		if art == null:
			continue
		var tex2: Texture2D = art.vfx.get(str(u["kind"]), null)
		if tex2 == null:
			continue
		var k: float = float(u["t"]) / float(u["life"])
		var a2: float = 1.0 - k
		var sc: float = lerpf(0.35, float(u["sc"]) * 1.35, k)
		var c2: Color = u["col"]
		c2.a = a2
		var sz: Vector2 = Vector2(110, 110) * sc
		draw_texture_rect(tex2, Rect2(u["p"] - sz * 0.5, sz), false, c2)


func _frame() -> void:
	var gold := Color("c4a574")
	if log_glow:
		gold = Color("fff0c0")
		draw_rect(Rect2(Vector2(0, 0), size), Color(1.0, 0.94, 0.75, 0.22 + 0.18 * absf(sin(_bob * 8.0))), false, 6.0)
	draw_rect(Rect2(Vector2(4, 4), size - Vector2(8, 8)), gold, false, 3.0)
	draw_rect(Rect2(Vector2(9, 9), size - Vector2(18, 18)), Color("e8c36a") if not log_glow else Color("fff8d8"), false, 1.0)
	if art.tile("wall_mid") != null:
		draw_texture_rect(art.tile("wall_mid"), Rect2(Vector2(0, 0), Vector2(size.x, 18)), false)
	_corner(Vector2(2, 2), 1.0, 1.0)
	_corner(Vector2(size.x - 2, 2), -1.0, 1.0)
	_corner(Vector2(2, size.y - 2), 1.0, -1.0)
	_corner(Vector2(size.x - 2, size.y - 2), -1.0, -1.0)


func _corner(p: Vector2, sx: float, sy: float) -> void:
	draw_line(p, p + Vector2(18.0 * sx, 0.0), Color("e8c36a"), 3.0, true)
	draw_line(p, p + Vector2(0.0, 18.0 * sy), Color("e8c36a"), 3.0, true)
