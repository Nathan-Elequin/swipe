extends Control
## Fighting portrait: idle bob, lunge on attack, hit flash, cartoon blood, impact stars.

signal edit_wanted(card_id: String)

const OUTLINE_SHADER := preload("res://shaders/tier_outline.gdshader")
const PLAYTEST_FLAG := preload("res://scripts/playtest_flag.gd")
const FX_BUDGET := preload("res://scripts/combat_fx_budget.gd")

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
		if is_equal_approx(_lunge_x, v):
			return
		_lunge_x = v
		# Lunge tween used to rebuild the full atlas crop every process tick.
		# Nudge the already-placed sprite instead; frame changes still go through
		# `_place_sprite` from `_process` when `_portrait_dirty`.
		if _sprite != null and _sprite.texture != null:
			_sprite.position.x = size.x * 0.5 - _sprite.size.x * 0.5 + _lunge_x
			queue_redraw()
			if _fx:
				_fx.queue_redraw()
		else:
			_place_sprite()
			queue_redraw()
var flip_h: bool = false
var face_want := "L"
var lunge_dir := -1.0
var log_glow: bool = false
var _watch_tex: Texture2D
var _watch_t: float = 0.0
var _rage: bool = false
var _rage_cd: float = 0.0
var _fled: bool = false
var busy: bool = false
var _tier: int = 1
var _sprite: TextureRect
var _outline: ShaderMaterial
var _crop: AtlasTexture
var _opaque: Dictionary = {}
var _fx: Control
var _body_center: Vector2 = Vector2.ZERO
var _plinth_foot: Vector2 = Vector2.ZERO
var _plinth_w: float = 0.0
var _shown_fi: int = -1
var _shown_bob: int = -1
var _placed_sig: String = ""


func setup(p_art) -> void:
	art = p_art
	custom_minimum_size = Vector2(192, 160)
	size = Vector2(192, 160)
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_gui)
	texture_filter = TEXTURE_FILTER_NEAREST
	clip_contents = false
	clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
	z_index = 15
	top_level = true
	visible = false
	_outline = ShaderMaterial.new()
	_outline.shader = OUTLINE_SHADER
	_sprite = TextureRect.new()
	_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sprite.texture_filter = TEXTURE_FILTER_NEAREST
	_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprite.stretch_mode = TextureRect.STRETCH_KEEP
	_sprite.material = _outline
	add_child(_sprite)
	var fx := FxLayer.new()
	fx.name = "Fx"
	fx.host = self
	fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.z_index = 0
	fx.z_as_relative = true
	fx.set_meta("fx", true)
	fx.clip_contents = true
	_fx = fx
	add_child(_fx)
	set_process(true)


func show_monster(id: String, p_tier: int = 1) -> void:
	card_id = id
	_tier = p_tier
	_idle = []
	if art:
		if art.has_method("monster_portrait_frames"):
			_idle = art.monster_portrait_frames(id)
		if _idle.is_empty() and art.has_method("monster_facing_idle"):
			_idle = art.monster_facing_idle(id)
		if _idle.is_empty():
			_idle = art.monster_idle(id)
	_run = art.monster_run(id) if art else []
	_mode = "idle"
	_fi = 0.0
	_shown_fi = -1
	_shown_bob = -1
	_placed_sig = ""
	_flash = 0.0
	_blood.clear()
	_bursts.clear()
	_lunge_x = 0.0
	_watch_tex = null
	_watch_t = 0.0
	_rage = false
	_rage_cd = 0.0
	_fled = false
	modulate = Color.WHITE
	visible = true
	pivot_offset = size * 0.5
	_place_sprite()


func _on_gui(event: InputEvent) -> void:
	if card_id == "":
		return
	if not OS.has_feature("editor") and not PLAYTEST_FLAG.on():
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		edit_wanted.emit(card_id)
		accept_event()


func set_log_glow(on: bool) -> void:
	log_glow = on
	queue_redraw()


func mouth_global() -> Vector2:
	var r: Rect2 = get_global_rect()
	var flipped := _sprite != null and _sprite.flip_h
	var mouth_x: float = 0.48 if flipped else 0.52
	return r.position + Vector2(r.size.x * mouth_x, r.size.y * 0.50)


func hide_stage() -> void:
	visible = false
	card_id = ""
	if _sprite:
		_sprite.texture = null
	_idle.clear()
	_run.clear()
	_watch_tex = null
	_watch_t = 0.0
	_shown_fi = -1
	_shown_bob = -1
	_placed_sig = ""


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


func lunge(fast: bool = false) -> void:
	if OS.has_feature("editor"):
		print("[resolve] stage.lunge id=", card_id, " frames=", _idle.size(), "/", _run.size())
	FX_BUDGET.begin_heavy()
	busy = true
	_mode = "run"
	var go: float = 0.05 if fast else 0.1
	var back: float = 0.08 if fast else 0.16
	var tw := create_tween()
	tw.tween_property(self, "_lunge_x", 22.0 * lunge_dir, go).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "_lunge_x", 0.0, back)
	await tw.finished
	_mode = "idle"
	busy = false
	FX_BUDGET.end_heavy()


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


func set_rage_fire(on: bool) -> void:
	_rage = on
	if on:
		modulate = Color(1.15, 0.85, 0.7)
	elif not _fled:
		modulate = Color.WHITE


func set_fled_mark(on: bool) -> void:
	_fled = on
	if on:
		modulate = Color(0.72, 0.70, 0.66)
	elif not _rage:
		modulate = Color.WHITE


func play_rage_up() -> void:
	_burst("flame", Color("ff7a28"), 1.35)
	_burst("fire", Color("ffc04a"), 1.1)
	_burst("spark", Color("ffe08a"), 0.95)
	_flash = 0.9


func play_rage_down() -> void:
	_burst("smoke", Color("9aa0a8"), 1.2)
	_burst("twirl", Color("6a7280"), 0.9)
	_flash = 0.35


func play_transform() -> void:
	_burst("twirl", Color("c77dff"), 1.25)
	_burst("magic", Color("8ec8f0"), 1.05)
	_burst("spark", Color("ffe08a"), 0.95)
	_flash = 0.7


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
	var hold_idle: bool = FX_BUDGET.hold_low_priority_idles() and _mode == "idle"
	if not hold_idle:
		if _mode == "run":
			_fi += delta * 10.0
		elif _idle.size() >= 4:
			_fi += delta / 0.140
		else:
			_fi += delta * 6.0
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
	if _rage and not hold_idle:
		_rage_cd -= delta
		if _rage_cd <= 0.0:
			_rage_cd = 0.18
			_burst("flame", Color("ff6a20"), 0.85)
			_burst("spark", Color("ffd070"), 0.55)
	if not _portrait_dirty():
		return
	_place_sprite()
	queue_redraw()
	if _fx:
		_fx.queue_redraw()


func _portrait_dirty() -> bool:
	var frames: Array = _run if _mode == "run" and not _run.is_empty() else _idle
	var fi: int = 0
	if not frames.is_empty():
		fi = int(_fi) % frames.size()
	if fi != _shown_fi:
		_shown_fi = fi
		return true
	if _flash > 0.0 or _watch_t > 0.0 or not _blood.is_empty() or not _bursts.is_empty():
		return true
	if _lunge_x != 0.0:
		return true
	if _mode == "idle" and _idle.size() < 4 and not FX_BUDGET.hold_low_priority_idles():
		var bob_i: int = int(_bob * 12.0)
		if bob_i != _shown_bob:
			_shown_bob = bob_i
			return true
	return false


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


func _opaque_rect(tex: Texture2D) -> Rect2:
	var path: String = str(tex.resource_path)
	if path == "":
		path = str(tex.get_instance_id())
	var key: String = "%s:%s" % [path, tex.get_size()]
	if _opaque.has(key):
		return _opaque[key]
	var region := Rect2(Vector2.ZERO, tex.get_size())
	var img: Image = tex.get_image()
	if img != null:
		var used: Rect2 = img.get_used_rect()
		if used.size.x >= 1.0 and used.size.y >= 1.0:
			region = used
	_opaque[key] = region
	return region


func _tier_col() -> Color:
	if _tier >= 3:
		return Color("e8c36a")
	if _tier == 2:
		return Color("c5cdd8")
	return Color("c08050")


func _place_sprite() -> void:
	if _sprite == null:
		return
	var frames: Array = _run if _mode == "run" and not _run.is_empty() else _idle
	if frames.is_empty():
		_sprite.texture = null
		_sprite.material = null
		_placed_sig = ""
		return
	var tex: Texture2D = frames[int(_fi) % frames.size()]
	if tex == null or not is_instance_valid(tex):
		_sprite.texture = null
		_sprite.material = null
		return
	var used: Rect2 = _opaque_rect(tex)
	var uw: float = maxf(1.0, used.size.x)
	var uh: float = maxf(1.0, used.size.y)
	var fit_w: float = maxf(1.0, size.x - 8.0)
	var fit_h: float = maxf(1.0, size.y - 12.0)
	var scale_n: float = minf(fit_h / uh, fit_w / uw)
	scale_n = floor(scale_n / 0.25) * 0.25
	scale_n = clampf(scale_n, 0.25, 4.0)
	var dw: float = uw * scale_n
	var dh: float = uh * scale_n
	var bob: float = 0.0 if _idle.size() >= 4 else sin(_bob * 3.2) * 3.0
	if _crop == null:
		_crop = AtlasTexture.new()
	_crop.atlas = tex
	_crop.region = used
	_sprite.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_sprite.texture = _crop
	_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_sprite.stretch_mode = TextureRect.STRETCH_SCALE
	_sprite.size = Vector2(dw, dh)
	_sprite.pivot_offset = Vector2(dw * 0.5, dh)
	var rest_y: float = size.y - 6.0 - dh
	var y: float = clampf(rest_y + bob, 0.0, maxf(0.0, rest_y))
	_sprite.position = Vector2(size.x * 0.5 - dw * 0.5 + _lunge_x, y)
	_body_center = Vector2(size.x * 0.5, rest_y + dh * 0.5)
	_plinth_foot = Vector2(size.x * 0.5, rest_y + dh)
	_plinth_w = clampf(dw * 0.55, 56.0, 112.0)
	if art != null and art.has_method("monster_flip_h"):
		_sprite.flip_h = art.monster_flip_h(card_id, face_want)
	else:
		_sprite.flip_h = flip_h
	var mod := Color.WHITE
	if _flash > 0.45:
		mod = Color(1.6, 1.6, 1.8)
	elif _flash > 0.0:
		mod = Color(1.0, 0.55, 0.5).lerp(Color.WHITE, 1.0 - _flash)
	_sprite.modulate = mod
	if _outline != null:
		_sprite.material = _outline
		_outline.set_shader_parameter("outline_color", _tier_col())
		_outline.set_shader_parameter("outline_size", 0.0)


func body_center_global() -> Vector2:
	if _plinth_w <= 0.0:
		return global_position + size * 0.5
	return global_position + _body_center


func sprite_height() -> float:
	if _sprite == null:
		return 0.0
	return _sprite.size.y


func foot_local() -> Vector2:
	if _plinth_w <= 0.0:
		return Vector2(size.x * 0.5, size.y)
	return _plinth_foot


func _draw() -> void:
	if _plinth_w <= 0.0 or _sprite == null:
		return
	UxStyle.draw_floor_shadow(self, _plinth_foot, _sprite.size.x)


func _paint_fx(ci: Control) -> void:
	if _watch_tex != null and _watch_t > 0.0:
		var pulse: float = 0.85 + sin(_bob * 10.0) * 0.08
		var wz := Vector2(48, 48) * pulse
		var wp := Vector2(size.x * 0.5 - wz.x * 0.5 + _lunge_x, size.y * 0.42)
		var wc := Color.WHITE
		wc.a = clampf(_watch_t, 0.35, 1.0)
		ci.draw_texture_rect(_watch_tex, Rect2(wp, wz), false, wc)
	for b in _blood:
		var a: float = 1.0 - float(b["t"]) / float(b["life"])
		var c: Color = b["col"]
		c.a = a
		ci.draw_set_transform(b["p"], float(b["rot"]), b["s"])
		ci.draw_circle(Vector2.ZERO, float(b["r"]), c)
		ci.draw_circle(Vector2(float(b["r"]) * 0.55, -2.0), float(b["r"]) * 0.45, c)
		ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
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
		ci.draw_texture_rect(tex2, Rect2(u["p"] - sz * 0.5, sz), false, c2)


class FxLayer extends Control:
	var host

	func _draw() -> void:
		if host != null:
			host._paint_fx(self)


func _frame() -> void:
	var metal: Color = _tier_col()
	if log_glow:
		metal = Color("fff0c0")
		draw_rect(Rect2(Vector2(0, 0), size), Color(1.0, 0.94, 0.75, 0.22 + 0.18 * absf(sin(_bob * 8.0))), false, 6.0)
	var c: Vector2 = size * 0.5
	var rad: float = minf(size.x, size.y) * 0.48
	UxStyle.draw_squircle(self, c, rad, _tier, Color("1a120e"), metal, 3.4, true)
	if art.tile("wall_mid") != null:
		draw_texture_rect(art.tile("wall_mid"), Rect2(Vector2(0, 0), Vector2(size.x, 18)), false)


func _corner(p: Vector2, sx: float, sy: float) -> void:
	draw_line(p, p + Vector2(18.0 * sx, 0.0), Color("e8c36a"), 3.0, true)
	draw_line(p, p + Vector2(0.0, 18.0 * sy), Color("e8c36a"), 3.0, true)
