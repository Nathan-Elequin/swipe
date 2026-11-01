extends Node2D
## Verdant Hollow (b1) ambient FX preview kit.
## Two-depth ambience: damp BG haze + spores + fireflies behind the wheel,
## dark near moss flecks in screen-edge bands only. Optional thin light shaft
## is its own named child and can be yanked without ripping the rest of the kit.
##
## Yank the shaft alone:
##   1. const SHAFT_ENABLED := false  (or BIOMES.b1.shaft = false)
##   2. or delete the LightShaft child — kit without shaft remains.
## No player-facing copy. b2–b5 absent from BIOMES → no FX there.

const FX_BUDGET := preload("res://scripts/combat_fx_budget.gd")

## Ship-default for playtest. Flip false for one-line revert to today's dry hall.
const AMBIENT_DEFAULT_ON := true
## Dedicated shaft kill-switch. Flipping false (or deleting LightShaft) restores
## the recommended 4-layer kit without the diagonal beam.
const SHAFT_ENABLED := true

## Absolute canvas z (z_as_relative = false) so values compare with dungeon_bg (-8)
## and wheel_view (0) even though we are one Node2D sibling under main.
## Shaft takes the -6 slot; V1/V2 sit at -5/-4 (still behind the wheel).
const Z_HAZE := -7
const Z_SHAFT := -6
const Z_SPORES := -5
const Z_FIREFLIES := -4
const Z_NEAR := 9

const FIELD_W := 1680.0
const FIELD_H := 1040.0
const BAND_DEFAULT := 140.0
const BAND_MIN := 96.0
const FADE_IN_S := 0.6

## Palette from Verdant splash ramp + wax greens + firefly gold. No new colours.
const C_CANOPY := Color("0f2219")
const C_MIST := Color("1b3a26")
const C_MOSS_DARK := Color("12261b")
const C_MOSS_MID := Color("2a4f2f")
const C_LEAF_DIM := Color("5f8f3c")
const C_LEAF_LIT := Color("9cc45a")
const C_FIREFLY := Color("E8D36A")

## Per-biome params. Only b1 in v1 — absent keys build nothing.
const BIOMES := {
	"b1": {
		"shaft": true,
		"spores": 22,
		"fireflies": 8,
		"near_each": 7,
	},
}

var _field_size: Vector2 = Vector2(FIELD_W, FIELD_H)
var _enabled: bool = AMBIENT_DEFAULT_ON
var _biome_id: String = ""
var _avoid_rects: Array = [] ## Rect2 in ambient/local (viewport) space
var _band_w: float = BAND_DEFAULT
var _fade_tw: Tween
var _sway_tw: Tween
var _near_sway_tw: Tween
var _breath_tw: Tween

var _haze: Node2D
var _mist: TextureRect
var _canopy: TextureRect
var _shaft: TextureRect
var _spores: CPUParticles2D
var _fireflies: CPUParticles2D
var _near_l: CPUParticles2D
var _near_r: CPUParticles2D
var _near_root: Node2D


func _init() -> void:
	## Group must stick even when constructed in a SceneTree _init selftest
	## before _ready runs.
	name = "BiomeAmbient"
	add_to_group("ambient_fx")
	z_as_relative = false
	z_index = 0
	visible = false


func _ready() -> void:
	if not is_in_group("ambient_fx"):
		add_to_group("ambient_fx")
	mouse_filter_ignore_tree()


func mouse_filter_ignore_tree() -> void:
	## Controls under us must never steal clicks from the wheel / hotbar.
	for n in get_children():
		_ignore_mouse(n)


func _ignore_mouse(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		_ignore_mouse(c)


func setup(field_size: Vector2) -> void:
	_field_size = Vector2(
		maxf(8.0, field_size.x if field_size.x > 0.0 else FIELD_W),
		maxf(8.0, field_size.y if field_size.y > 0.0 else FIELD_H)
	)
	_recompute_band_w()
	if _biome_id != "" and _has_layers():
		_layout_layers()


func set_avoid_rects(rects: Array) -> void:
	## Pass global rects of wheel / hotbar / draft / cue; we convert to local.
	_avoid_rects.clear()
	var xf: Transform2D = get_global_transform().affine_inverse()
	for raw in rects:
		if typeof(raw) != TYPE_RECT2 and not (raw is Rect2):
			continue
		var g: Rect2 = raw
		if g.size.x < 4.0 or g.size.y < 4.0:
			continue
		var p1: Vector2 = xf * g.position
		var p2: Vector2 = xf * g.end
		_avoid_rects.append(Rect2(
			Vector2(minf(p1.x, p2.x), minf(p1.y, p2.y)),
			Vector2(absf(p2.x - p1.x), absf(p2.y - p1.y))
		))
	_recompute_band_w()
	if _has_layers():
		_layout_near_bands()


func set_biome(id: String) -> void:
	var want := str(id).strip_edges()
	if want == _biome_id and _has_layers():
		_apply_enabled_state(false)
		return
	clear()
	_biome_id = want
	if want == "" or not BIOMES.has(want):
		return
	_build_layers(BIOMES[want] as Dictionary)
	_apply_enabled_state(false)


func set_enabled(on: bool) -> void:
	var was := _enabled
	_enabled = on
	if not _has_layers():
		visible = false
		return
	if on and not was:
		_apply_enabled_state(true)
	else:
		_apply_enabled_state(false)


func is_enabled() -> bool:
	return _enabled


func toggle() -> void:
	set_enabled(not _enabled)


func clear() -> void:
	_stop_tweens()
	for c in get_children():
		c.free()
	_haze = null
	_mist = null
	_canopy = null
	_shaft = null
	_spores = null
	_fireflies = null
	_near_l = null
	_near_r = null
	_near_root = null
	_biome_id = ""
	visible = false
	modulate.a = 1.0


func current_biome() -> String:
	return _biome_id


func band_width() -> float:
	return _band_w


func layer_count() -> int:
	## Named top-level kit pieces currently built (excludes empty).
	var n := 0
	if _haze != null:
		n += 1
	if _shaft != null:
		n += 1
	if _spores != null:
		n += 1
	if _fireflies != null:
		n += 1
	if _near_l != null:
		n += 1
	if _near_r != null:
		n += 1
	return n


func total_particle_amount() -> int:
	var total := 0
	for p in [_spores, _fireflies, _near_l, _near_r]:
		if p != null:
			total += int(p.amount)
	return total


func shaft_present() -> bool:
	return _shaft != null and is_instance_valid(_shaft)


func near_band_rects() -> Array:
	## Full-height fall columns used by the selftest (local space).
	var h: float = _field_size.y
	return [
		Rect2(0.0, 0.0, _band_w, h),
		Rect2(_field_size.x - _band_w, 0.0, _band_w, h),
	]


func _has_layers() -> bool:
	return _haze != null or _spores != null or _fireflies != null or _near_l != null


func _web_halve(n: int) -> int:
	if FX_BUDGET.is_web():
		return int(ceili(float(n) * 0.5))
	return n


func _build_layers(cfg: Dictionary) -> void:
	_recompute_band_w()
	_build_haze()
	if SHAFT_ENABLED and bool(cfg.get("shaft", true)):
		_build_shaft()
	_build_spores(int(cfg.get("spores", 22)))
	_build_fireflies(int(cfg.get("fireflies", 8)))
	_build_near(int(cfg.get("near_each", 7)))
	_layout_layers()
	_start_sway()
	mouse_filter_ignore_tree()
	## Starts full via preprocess — no empty first second.
	modulate.a = 1.0


func _build_haze() -> void:
	_haze = Node2D.new()
	_haze.name = "DampHaze"
	_haze.z_as_relative = false
	_haze.z_index = Z_HAZE
	add_child(_haze)

	_mist = TextureRect.new()
	_mist.name = "Mist"
	_mist.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mist.texture = _vertical_gradient(C_MIST, 0.0, 0.28)
	_mist.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mist.stretch_mode = TextureRect.STRETCH_SCALE
	_haze.add_child(_mist)

	_canopy = TextureRect.new()
	_canopy.name = "Canopy"
	_canopy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canopy.texture = _vertical_gradient(C_CANOPY, 0.35, 0.0)
	_canopy.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_canopy.stretch_mode = TextureRect.STRETCH_SCALE
	_haze.add_child(_canopy)


func _build_shaft() -> void:
	## Soft thin diagonal from top-left. Low alpha Verdant tint.
	## Own named child so deleting it / SHAFT_ENABLED false yanks it alone.
	_shaft = TextureRect.new()
	_shaft.name = "LightShaft"
	_shaft.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shaft.z_as_relative = false
	_shaft.z_index = Z_SHAFT
	_shaft.texture = _shaft_gradient()
	_shaft.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_shaft.stretch_mode = TextureRect.STRETCH_SCALE
	_shaft.pivot_offset = Vector2(90.0, 0.0)
	add_child(_shaft)


func _build_spores(amount: int) -> void:
	_spores = CPUParticles2D.new()
	_spores.name = "FarSpores"
	_spores.z_as_relative = false
	_spores.z_index = Z_SPORES
	_spores.amount = _web_halve(amount)
	_spores.lifetime = 12.0
	_spores.preprocess = 12.0
	_spores.fixed_fps = 30
	_spores.local_coords = false
	_spores.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_spores.direction = Vector2(0.25, -1.0)
	_spores.spread = 35.0
	_spores.gravity = Vector2(1.5, -0.5)
	_spores.initial_velocity_min = 3.0
	_spores.initial_velocity_max = 9.0
	_spores.scale_amount_min = 2.0
	_spores.scale_amount_max = 3.0
	_spores.color = C_LEAF_DIM
	_spores.color_ramp = _alpha_ramp([
		Vector2(0.0, 0.0), Vector2(0.15, 0.38), Vector2(0.80, 0.38), Vector2(1.0, 0.0)
	])
	_spores.color_initial_ramp = _color_pair_ramp(C_LEAF_DIM, C_LEAF_LIT)
	add_child(_spores)


func _build_fireflies(amount: int) -> void:
	_fireflies = CPUParticles2D.new()
	_fireflies.name = "HollowFireflies"
	_fireflies.z_as_relative = false
	_fireflies.z_index = Z_FIREFLIES
	_fireflies.amount = _web_halve(amount)
	_fireflies.lifetime = 9.0
	_fireflies.preprocess = 9.0
	_fireflies.fixed_fps = 30
	_fireflies.local_coords = false
	_fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_fireflies.direction = Vector2(1.0, 0.0)
	_fireflies.spread = 180.0
	_fireflies.gravity = Vector2.ZERO
	_fireflies.initial_velocity_min = 4.0
	_fireflies.initial_velocity_max = 12.0
	_fireflies.angular_velocity_min = 0.0
	_fireflies.angular_velocity_max = 0.0
	_fireflies.orbit_velocity_min = -0.02
	_fireflies.orbit_velocity_max = 0.02
	_fireflies.scale_amount_min = 2.0
	_fireflies.scale_amount_max = 2.0
	_fireflies.color = C_FIREFLY
	## Two soft pulses per life, staggered by emission — twinkle, don't flash.
	_fireflies.color_ramp = _alpha_ramp([
		Vector2(0.0, 0.0),
		Vector2(0.10, 0.90),
		Vector2(0.30, 0.25),
		Vector2(0.50, 0.85),
		Vector2(0.75, 0.20),
		Vector2(1.0, 0.0),
	])
	add_child(_fireflies)


func _build_near(amount_each: int) -> void:
	_near_root = Node2D.new()
	_near_root.name = "NearMossDrift"
	_near_root.z_as_relative = false
	_near_root.z_index = Z_NEAR
	add_child(_near_root)
	_near_l = _make_near_emitter("NearMossL", _web_halve(amount_each))
	_near_r = _make_near_emitter("NearMossR", _web_halve(amount_each))
	_near_root.add_child(_near_l)
	_near_root.add_child(_near_r)


func _make_near_emitter(nm: String, amount: int) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.name = nm
	p.z_as_relative = true
	p.z_index = 0
	p.amount = amount
	p.lifetime = 16.0
	p.preprocess = 16.0
	p.fixed_fps = 30
	p.local_coords = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(70.0, 8.0)
	p.direction = Vector2(0.15, 1.0)
	p.spread = 10.0
	p.gravity = Vector2(0.0, 4.0)
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 48.0
	p.tangential_accel_min = -6.0
	p.tangential_accel_max = 6.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 4.0
	p.color = C_MOSS_MID
	p.color_ramp = _near_color_ramp()
	p.color_initial_ramp = _color_pair_ramp(C_MOSS_DARK, C_MOSS_MID)
	return p


func _layout_layers() -> void:
	var w: float = _field_size.x
	var h: float = _field_size.y
	## V0 mist: bottom 38% (y 645–1040 at 1040). Canopy: top 22% (y 0–230).
	if _mist != null:
		var mist_top: float = h * (1.0 - 0.38)
		_mist.position = Vector2(0.0, mist_top)
		_mist.size = Vector2(w, h - mist_top)
	if _canopy != null:
		var canopy_h: float = h * 0.22
		_canopy.position = Vector2.ZERO
		_canopy.size = Vector2(w, canopy_h)
	if _shaft != null:
		## Thin soft beam from top-left, ~28° diagonal across the upper field.
		_shaft.size = Vector2(180.0, h * 1.15)
		_shaft.position = Vector2(w * 0.08, -h * 0.05)
		_shaft.pivot_offset = Vector2(90.0, 0.0)
		_shaft.rotation_degrees = 28.0
		_shaft.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if _spores != null:
		_spores.position = Vector2(w * 0.5, h * 0.5)
		_spores.emission_rect_extents = Vector2(w * 0.5 + 20.0, h * 0.5 + 20.0)
	if _fireflies != null:
		_fireflies.position = Vector2(w * 0.5, h * 0.5)
		_fireflies.emission_rect_extents = Vector2(w * 0.5 + 20.0, h * 0.5 + 20.0)
	_layout_near_bands()


func _layout_near_bands() -> void:
	if _near_l == null or _near_r == null:
		return
	var w: float = _field_size.x
	## Spawn just above the top edge inside each band.
	_near_l.position = Vector2(_band_w * 0.5, -12.0)
	_near_l.emission_rect_extents = Vector2(maxf(8.0, _band_w * 0.5), 8.0)
	_near_r.position = Vector2(w - _band_w * 0.5, -12.0)
	_near_r.emission_rect_extents = Vector2(maxf(8.0, _band_w * 0.5), 8.0)


func _recompute_band_w() -> void:
	## Start at 140; narrow (floor 96) if a full-height band would hit avoid rects.
	var w: float = _field_size.x
	var h: float = _field_size.y
	var band := BAND_DEFAULT
	while band > BAND_MIN:
		var left := Rect2(0.0, 0.0, band, h)
		var right := Rect2(w - band, 0.0, band, h)
		if not _band_hits_avoids(left) and not _band_hits_avoids(right):
			break
		band -= 8.0
	_band_w = maxf(BAND_MIN, band)


func _band_hits_avoids(band: Rect2) -> bool:
	for raw in _avoid_rects:
		var r: Rect2 = raw
		if band.intersects(r):
			return true
	return false


func _apply_enabled_state(fade_in: bool) -> void:
	_stop_fade()
	if not _enabled or not _has_layers():
		visible = false
		_set_emitting(false)
		modulate.a = 1.0
		return
	visible = true
	_set_emitting(true)
	if fade_in:
		modulate.a = 0.0
		_fade_tw = create_tween()
		_fade_tw.tween_property(self, "modulate:a", 1.0, FADE_IN_S)
	else:
		modulate.a = 1.0


func _set_emitting(on: bool) -> void:
	for p in [_spores, _fireflies, _near_l, _near_r]:
		if p != null:
			p.emitting = on


func _start_sway() -> void:
	_stop_sway()
	if _mist == null:
		return
	## Breath on mist alpha 0.75↔1.0 over 7 s.
	_mist.modulate.a = 0.75
	_breath_tw = create_tween()
	_breath_tw.set_loops()
	_breath_tw.tween_property(_mist, "modulate:a", 1.0, 7.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_breath_tw.tween_property(_mist, "modulate:a", 0.75, 7.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	## ±2 px x sway on mist over 11 s (parallax stand-in).
	var base_x: float = _mist.position.x
	_sway_tw = create_tween()
	_sway_tw.set_loops()
	_sway_tw.tween_property(_mist, "position:x", base_x + 2.0, 11.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_sway_tw.tween_property(_mist, "position:x", base_x - 2.0, 11.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	## Near bands sway ±3 px opposite phase (9 s).
	if _near_root != null:
		_near_root.position.x = 3.0
		_near_sway_tw = create_tween()
		_near_sway_tw.set_loops()
		_near_sway_tw.tween_property(_near_root, "position:x", -3.0, 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_near_sway_tw.tween_property(_near_root, "position:x", 3.0, 9.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _stop_tweens() -> void:
	_stop_fade()
	_stop_sway()


func _stop_fade() -> void:
	if _fade_tw != null and is_instance_valid(self) and _fade_tw.is_valid():
		_fade_tw.kill()
	_fade_tw = null


func _stop_sway() -> void:
	if _sway_tw != null and _sway_tw.is_valid():
		_sway_tw.kill()
	_sway_tw = null
	if _breath_tw != null and _breath_tw.is_valid():
		_breath_tw.kill()
	_breath_tw = null
	if _near_sway_tw != null and _near_sway_tw.is_valid():
		_near_sway_tw.kill()
	_near_sway_tw = null


func _vertical_gradient(rgb: Color, a_top: float, a_bot: float) -> GradientTexture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([
		Color(rgb.r, rgb.g, rgb.b, a_top),
		Color(rgb.r, rgb.g, rgb.b, a_bot),
	])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = 8
	tex.height = 256
	tex.fill_from = Vector2(0.5, 0.0)
	tex.fill_to = Vector2(0.5, 1.0)
	return tex


func _shaft_gradient() -> GradientTexture2D:
	## Soft core: transparent edges, Verdant leaf tint α ≤ 0.08 in the middle.
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 0.55, 1.0])
	var c := C_LEAF_LIT
	g.colors = PackedColorArray([
		Color(c.r, c.g, c.b, 0.0),
		Color(c.r, c.g, c.b, 0.08),
		Color(c.r, c.g, c.b, 0.08),
		Color(c.r, c.g, c.b, 0.0),
	])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = 64
	tex.height = 8
	tex.fill_from = Vector2(0.0, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	return tex


func _alpha_ramp(stops: Array) -> Gradient:
	## stops: Array of Vector2(offset, alpha). Colour stays white; particle.color tints.
	var g := Gradient.new()
	var offs := PackedFloat32Array()
	var cols := PackedColorArray()
	for s in stops:
		var v: Vector2 = s
		offs.append(v.x)
		cols.append(Color(1.0, 1.0, 1.0, v.y))
	g.offsets = offs
	g.colors = cols
	return g


func _near_color_ramp() -> Gradient:
	## Dark FG, α 0.6 → 0 over the last 15%.
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.85, 1.0])
	g.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, 0.6),
		Color(1.0, 1.0, 1.0, 0.6),
		Color(1.0, 1.0, 1.0, 0.0),
	])
	return g


func _color_pair_ramp(a: Color, b: Color) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([a, b])
	return g
