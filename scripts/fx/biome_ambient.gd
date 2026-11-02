extends Node2D
## Biome ambient FX kit (b1–b5). Same 4-slot depth as Verdant Hollow:
## V0 haze (z-7) · V1 far particles (z-5) · V2 accent (z-4) · V3 near edge bands (z9)
## · optional shaft (z-6, yankable). Data-driven via BIOMES; Verdant (b1) stays
## pixel-identical to the tip preview. Shaft stays OFF for b2–b5.
##
## Yank the shaft alone (Verdant only):
##   1. const SHAFT_ENABLED := false  (or BIOMES.b1.shaft = false)
##   2. or delete the LightShaft child — kit without shaft remains.
## No player-facing copy. Absent BIOMES keys → no FX. Endless / cabin / map stay off.

const FX_BUDGET := preload("res://scripts/combat_fx_budget.gd")

## Ship-default for playtest. Flip false for one-line revert to today's dry hall.
const AMBIENT_DEFAULT_ON := true
## Dedicated shaft kill-switch. Flipping false (or deleting LightShaft) restores
## the recommended 4-layer kit without the diagonal beam. Only b1 requests shaft.
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

## Verdant palette locked (pixel-identical). Other biomes carry colours in BIOMES.
const C_CANOPY := Color("0f2219")
const C_MIST := Color("1b3a26")
const C_MOSS_DARK := Color("12261b")
const C_MOSS_MID := Color("2a4f2f")
const C_LEAF_DIM := Color("5f8f3c")
const C_LEAF_LIT := Color("9cc45a")
const C_FIREFLY := Color("E8D36A")

## Per-biome params. Builders read colours, directions, amounts, haze alphas,
## breath period, and shaft bool from here. b1 values match the tip Verdant kit.
const BIOMES := {
	"b1": {
		"shaft": true,
		"far": 22,
		"accent": 8,
		"near_each": 7,
		"mist": C_MIST,
		"mist_a": 0.28,
		"canopy": C_CANOPY,
		"canopy_a": 0.35,
		"mist_frac": 0.38,
		"canopy_frac": 0.22,
		"breath_s": 7.0,
		"far_a": C_LEAF_DIM,
		"far_b": C_LEAF_LIT,
		"far_alpha": 0.38,
		"far_dir": Vector2(0.25, -1.0),
		"far_spread": 35.0,
		"far_gravity": Vector2(1.5, -0.5),
		"far_vel_min": 3.0,
		"far_vel_max": 9.0,
		"far_scale_min": 2.0,
		"far_scale_max": 3.0,
		"far_life": 12.0,
		"accent_color": C_FIREFLY,
		"accent_color_b": C_FIREFLY,
		"accent_style": "twinkle",
		"accent_peak": 0.90,
		"accent_dir": Vector2(1.0, 0.0),
		"accent_spread": 180.0,
		"accent_gravity": Vector2.ZERO,
		"accent_vel_min": 4.0,
		"accent_vel_max": 12.0,
		"accent_orbit": 0.02,
		"accent_life": 9.0,
		"accent_scale_min": 2.0,
		"accent_scale_max": 2.0,
		"near_a": C_MOSS_DARK,
		"near_b": C_MOSS_MID,
		"near_alpha": 0.6,
		"near_dir": Vector2(0.15, 1.0),
		"near_spread": 10.0,
		"near_gravity": Vector2(0.0, 4.0),
		"near_vel_min": 30.0,
		"near_vel_max": 48.0,
		"near_scale_min": 3.0,
		"near_scale_max": 4.0,
		"near_life": 16.0,
		"near_rise": false,
	},
	## Crystal Cavern — cool mist + sharp glints + frost flecks. No shaft.
	"b2": {
		"shaft": false,
		"far": 20,
		"accent": 12,
		"near_each": 6,
		"mist": Color("2a4054"),
		"mist_a": 0.30,
		"canopy": Color("1a2a38"),
		"canopy_a": 0.30,
		"mist_frac": 0.38,
		"canopy_frac": 0.22,
		"breath_s": 7.0,
		"far_a": Color("5a7a90"),
		"far_b": Color("7fa9c4"),
		"far_alpha": 0.40,
		"far_dir": Vector2(0.15, -1.0),
		"far_spread": 40.0,
		"far_gravity": Vector2(0.8, -0.4),
		"far_vel_min": 2.0,
		"far_vel_max": 7.0,
		"far_scale_min": 1.5,
		"far_scale_max": 2.5,
		"far_life": 14.0,
		"accent_color": Color("c8e4f2"),
		"accent_color_b": Color("7fa9c4"),
		"accent_style": "glint",
		"accent_peak": 0.95,
		"accent_dir": Vector2(1.0, 0.0),
		"accent_spread": 180.0,
		"accent_gravity": Vector2.ZERO,
		"accent_vel_min": 1.0,
		"accent_vel_max": 4.0,
		"accent_orbit": 0.01,
		"accent_life": 8.0,
		"accent_scale_min": 2.0,
		"accent_scale_max": 3.0,
		"near_a": Color("152028"),
		"near_b": Color("2a4054"),
		"near_alpha": 0.65,
		"near_dir": Vector2(0.12, 1.0),
		"near_spread": 12.0,
		"near_gravity": Vector2(0.0, 3.5),
		"near_vel_min": 24.0,
		"near_vel_max": 42.0,
		"near_scale_min": 2.5,
		"near_scale_max": 3.5,
		"near_life": 16.0,
		"near_rise": false,
	},
	## Ashen Crypt — dusty haze + readable falling ash. Dry, not fire. No shaft.
	"b3": {
		"shaft": false,
		"far": 26,
		"accent": 6,
		"near_each": 7,
		"mist": Color("4a3028"),
		"mist_a": 0.32,
		"canopy": Color("2a1c18"),
		"canopy_a": 0.32,
		"mist_frac": 0.40,
		"canopy_frac": 0.20,
		"breath_s": 7.5,
		"far_a": Color("8a6a5a"),
		"far_b": Color("a89078"),
		"far_alpha": 0.42,
		"far_dir": Vector2(0.55, 1.0),
		"far_spread": 18.0,
		"far_gravity": Vector2(2.0, 3.5),
		"far_vel_min": 8.0,
		"far_vel_max": 18.0,
		"far_scale_min": 2.5,
		"far_scale_max": 4.0,
		"far_life": 11.0,
		"accent_color": Color("c47848"),
		"accent_color_b": Color("a86838"),
		"accent_style": "blink",
		"accent_peak": 0.55,
		"accent_dir": Vector2(0.2, 1.0),
		"accent_spread": 25.0,
		"accent_gravity": Vector2(0.5, 2.5),
		"accent_vel_min": 6.0,
		"accent_vel_max": 14.0,
		"accent_orbit": 0.0,
		"accent_life": 10.0,
		"accent_scale_min": 2.0,
		"accent_scale_max": 2.5,
		"near_a": Color("1a100e"),
		"near_b": Color("3a2820"),
		"near_alpha": 0.68,
		"near_dir": Vector2(0.18, 1.0),
		"near_spread": 12.0,
		"near_gravity": Vector2(0.0, 4.5),
		"near_vel_min": 28.0,
		"near_vel_max": 46.0,
		"near_scale_min": 3.5,
		"near_scale_max": 5.0,
		"near_life": 15.0,
		"near_rise": false,
	},
	## Cinder Forge — heat haze + rising embers/soot (directional flip). No shaft.
	"b4": {
		"shaft": false,
		"far": 20,
		"accent": 12,
		"near_each": 6,
		"mist": Color("5a2810"),
		"mist_a": 0.34,
		"canopy": Color("2a140c"),
		"canopy_a": 0.36,
		"mist_frac": 0.42,
		"canopy_frac": 0.18,
		"breath_s": 5.5,
		"far_a": Color("6a4030"),
		"far_b": Color("8a5840"),
		"far_alpha": 0.40,
		"far_dir": Vector2(0.1, -1.0),
		"far_spread": 30.0,
		"far_gravity": Vector2(0.5, -2.5),
		"far_vel_min": 6.0,
		"far_vel_max": 14.0,
		"far_scale_min": 2.0,
		"far_scale_max": 3.5,
		"far_life": 12.0,
		"accent_color": Color("d06828"),
		"accent_color_b": Color("e8a050"),
		"accent_style": "pulse",
		"accent_peak": 0.92,
		"accent_dir": Vector2(0.05, -1.0),
		"accent_spread": 28.0,
		"accent_gravity": Vector2(0.3, -3.0),
		"accent_vel_min": 10.0,
		"accent_vel_max": 22.0,
		"accent_orbit": 0.015,
		"accent_life": 8.0,
		"accent_scale_min": 2.0,
		"accent_scale_max": 3.0,
		"near_a": Color("1a0c08"),
		"near_b": Color("3a1c10"),
		"near_alpha": 0.70,
		"near_dir": Vector2(0.08, -1.0),
		"near_spread": 14.0,
		"near_gravity": Vector2(0.0, -3.5),
		"near_vel_min": 22.0,
		"near_vel_max": 40.0,
		"near_scale_min": 3.0,
		"near_scale_max": 4.5,
		"near_life": 14.0,
		"near_rise": true,
	},
	## Shadow Abyss — heavy crush + rare dim violet motes. No shaft.
	"b5": {
		"shaft": false,
		"far": 12,
		"accent": 6,
		"near_each": 8,
		"mist": Color("1a1630"),
		"mist_a": 0.22,
		"canopy": Color("0a0814"),
		"canopy_a": 0.48,
		"mist_frac": 0.22,
		"canopy_frac": 0.38,
		"breath_s": 10.0,
		"far_a": Color("2a2848"),
		"far_b": Color("3c3488"),
		"far_alpha": 0.28,
		"far_dir": Vector2(0.2, 0.1),
		"far_spread": 50.0,
		"far_gravity": Vector2(0.2, 0.15),
		"far_vel_min": 0.5,
		"far_vel_max": 2.5,
		"far_scale_min": 1.5,
		"far_scale_max": 2.5,
		"far_life": 18.0,
		"accent_color": Color("6a64b0"),
		"accent_color_b": Color("4a4488"),
		"accent_style": "orbit",
		"accent_peak": 0.50,
		"accent_dir": Vector2(1.0, 0.0),
		"accent_spread": 180.0,
		"accent_gravity": Vector2.ZERO,
		"accent_vel_min": 2.0,
		"accent_vel_max": 5.0,
		"accent_orbit": 0.04,
		"accent_life": 16.0,
		"accent_scale_min": 2.0,
		"accent_scale_max": 2.5,
		"near_a": Color("08060e"),
		"near_b": Color("1a1630"),
		"near_alpha": 0.75,
		"near_dir": Vector2(0.1, 1.0),
		"near_spread": 10.0,
		"near_gravity": Vector2(0.0, 3.0),
		"near_vel_min": 20.0,
		"near_vel_max": 36.0,
		"near_scale_min": 3.5,
		"near_scale_max": 5.0,
		"near_life": 18.0,
		"near_rise": false,
	},
}

var _field_size: Vector2 = Vector2(FIELD_W, FIELD_H)
var _enabled: bool = AMBIENT_DEFAULT_ON
var _biome_id: String = ""
var _cfg: Dictionary = {}
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
	_cfg = {}
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
	_cfg = cfg
	_recompute_band_w()
	_build_haze(cfg)
	## Shaft only when both the global kill-switch and this biome ask for it.
	if SHAFT_ENABLED and bool(cfg.get("shaft", false)):
		_build_shaft(cfg)
	_build_spores(cfg)
	_build_fireflies(cfg)
	_build_near(cfg)
	_layout_layers()
	_start_sway()
	mouse_filter_ignore_tree()
	## Starts full via preprocess — no empty first second.
	modulate.a = 1.0


func _build_haze(cfg: Dictionary) -> void:
	_haze = Node2D.new()
	_haze.name = "DampHaze"
	_haze.z_as_relative = false
	_haze.z_index = Z_HAZE
	add_child(_haze)

	var mist_c: Color = cfg.get("mist", C_MIST)
	var mist_a: float = float(cfg.get("mist_a", 0.28))
	var canopy_c: Color = cfg.get("canopy", C_CANOPY)
	var canopy_a: float = float(cfg.get("canopy_a", 0.35))

	_mist = TextureRect.new()
	_mist.name = "Mist"
	_mist.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mist.texture = _vertical_gradient(mist_c, 0.0, mist_a)
	_mist.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_mist.stretch_mode = TextureRect.STRETCH_SCALE
	_haze.add_child(_mist)

	_canopy = TextureRect.new()
	_canopy.name = "Canopy"
	_canopy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canopy.texture = _vertical_gradient(canopy_c, canopy_a, 0.0)
	_canopy.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_canopy.stretch_mode = TextureRect.STRETCH_SCALE
	_haze.add_child(_canopy)


func _build_shaft(cfg: Dictionary) -> void:
	## Soft thin diagonal from top-left. Low alpha tint from far_b (Verdant leaf lit).
	## Own named child so deleting it / SHAFT_ENABLED false yanks it alone.
	_shaft = TextureRect.new()
	_shaft.name = "LightShaft"
	_shaft.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shaft.z_as_relative = false
	_shaft.z_index = Z_SHAFT
	var shaft_c: Color = cfg.get("far_b", C_LEAF_LIT)
	_shaft.texture = _shaft_gradient(shaft_c)
	_shaft.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_shaft.stretch_mode = TextureRect.STRETCH_SCALE
	_shaft.pivot_offset = Vector2(90.0, 0.0)
	add_child(_shaft)


func _build_spores(cfg: Dictionary) -> void:
	var amount: int = int(cfg.get("far", cfg.get("spores", 22)))
	var far_a: Color = cfg.get("far_a", C_LEAF_DIM)
	var far_b: Color = cfg.get("far_b", C_LEAF_LIT)
	var far_alpha: float = float(cfg.get("far_alpha", 0.38))
	var life: float = float(cfg.get("far_life", 12.0))
	_spores = CPUParticles2D.new()
	_spores.name = "FarSpores"
	_spores.z_as_relative = false
	_spores.z_index = Z_SPORES
	_spores.amount = _web_halve(amount)
	_spores.lifetime = life
	_spores.preprocess = life
	_spores.fixed_fps = 30
	_spores.local_coords = false
	_spores.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_spores.direction = cfg.get("far_dir", Vector2(0.25, -1.0))
	_spores.spread = float(cfg.get("far_spread", 35.0))
	_spores.gravity = cfg.get("far_gravity", Vector2(1.5, -0.5))
	_spores.initial_velocity_min = float(cfg.get("far_vel_min", 3.0))
	_spores.initial_velocity_max = float(cfg.get("far_vel_max", 9.0))
	_spores.scale_amount_min = float(cfg.get("far_scale_min", 2.0))
	_spores.scale_amount_max = float(cfg.get("far_scale_max", 3.0))
	_spores.color = far_a
	_spores.color_ramp = _alpha_ramp([
		Vector2(0.0, 0.0), Vector2(0.15, far_alpha), Vector2(0.80, far_alpha), Vector2(1.0, 0.0)
	])
	_spores.color_initial_ramp = _color_pair_ramp(far_a, far_b)
	add_child(_spores)


func _build_fireflies(cfg: Dictionary) -> void:
	var amount: int = int(cfg.get("accent", cfg.get("fireflies", 8)))
	var ac: Color = cfg.get("accent_color", C_FIREFLY)
	var ac_b: Color = cfg.get("accent_color_b", ac)
	var style: String = str(cfg.get("accent_style", "twinkle"))
	var peak: float = float(cfg.get("accent_peak", 0.90))
	var life: float = float(cfg.get("accent_life", 9.0))
	var orbit: float = float(cfg.get("accent_orbit", 0.02))
	_fireflies = CPUParticles2D.new()
	_fireflies.name = "HollowFireflies"
	_fireflies.z_as_relative = false
	_fireflies.z_index = Z_FIREFLIES
	_fireflies.amount = _web_halve(amount)
	_fireflies.lifetime = life
	_fireflies.preprocess = life
	_fireflies.fixed_fps = 30
	_fireflies.local_coords = false
	_fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_fireflies.direction = cfg.get("accent_dir", Vector2(1.0, 0.0))
	_fireflies.spread = float(cfg.get("accent_spread", 180.0))
	_fireflies.gravity = cfg.get("accent_gravity", Vector2.ZERO)
	_fireflies.initial_velocity_min = float(cfg.get("accent_vel_min", 4.0))
	_fireflies.initial_velocity_max = float(cfg.get("accent_vel_max", 12.0))
	_fireflies.angular_velocity_min = 0.0
	_fireflies.angular_velocity_max = 0.0
	_fireflies.orbit_velocity_min = -orbit
	_fireflies.orbit_velocity_max = orbit
	_fireflies.scale_amount_min = float(cfg.get("accent_scale_min", 2.0))
	_fireflies.scale_amount_max = float(cfg.get("accent_scale_max", 2.0))
	_fireflies.color = ac
	_fireflies.color_ramp = _accent_alpha_ramp(style, peak)
	if ac != ac_b:
		_fireflies.color_initial_ramp = _color_pair_ramp(ac, ac_b)
	add_child(_fireflies)


func _accent_alpha_ramp(style: String, peak: float) -> Gradient:
	## Style shapes the V2 icon read. Verdant "twinkle" stays bit-identical.
	match style:
		"glint":
			## Crystal: sharp sparse spikes, out of sync via emission.
			return _alpha_ramp([
				Vector2(0.0, 0.0),
				Vector2(0.06, peak),
				Vector2(0.14, 0.05),
				Vector2(0.48, 0.0),
				Vector2(0.55, peak),
				Vector2(0.64, 0.05),
				Vector2(1.0, 0.0),
			])
		"blink":
			## Ashen: rare dull ember blink on a mostly-dim fall.
			return _alpha_ramp([
				Vector2(0.0, 0.0),
				Vector2(0.20, 0.22),
				Vector2(0.45, 0.18),
				Vector2(0.55, peak),
				Vector2(0.65, 0.18),
				Vector2(1.0, 0.0),
			])
		"pulse":
			## Cinder: soft rising ember pulse (most noticeable accent).
			return _alpha_ramp([
				Vector2(0.0, 0.0),
				Vector2(0.15, peak * 0.55),
				Vector2(0.40, peak),
				Vector2(0.70, peak * 0.45),
				Vector2(1.0, 0.0),
			])
		"orbit":
			## Shadow: long dim presence, never white / never flashy.
			return _alpha_ramp([
				Vector2(0.0, 0.0),
				Vector2(0.15, peak * 0.7),
				Vector2(0.50, peak),
				Vector2(0.85, peak * 0.6),
				Vector2(1.0, 0.0),
			])
		_:
			## Verdant twinkle (default): two soft pulses per life — exact tip values.
			return _alpha_ramp([
				Vector2(0.0, 0.0),
				Vector2(0.10, 0.90),
				Vector2(0.30, 0.25),
				Vector2(0.50, 0.85),
				Vector2(0.75, 0.20),
				Vector2(1.0, 0.0),
			])


func _build_near(cfg: Dictionary) -> void:
	var amount_each: int = int(cfg.get("near_each", 7))
	_near_root = Node2D.new()
	_near_root.name = "NearMossDrift"
	_near_root.z_as_relative = false
	_near_root.z_index = Z_NEAR
	add_child(_near_root)
	_near_l = _make_near_emitter("NearMossL", _web_halve(amount_each), cfg)
	_near_r = _make_near_emitter("NearMossR", _web_halve(amount_each), cfg)
	_near_root.add_child(_near_l)
	_near_root.add_child(_near_r)


func _make_near_emitter(nm: String, amount: int, cfg: Dictionary) -> CPUParticles2D:
	var near_a: Color = cfg.get("near_a", C_MOSS_DARK)
	var near_b: Color = cfg.get("near_b", C_MOSS_MID)
	var near_alpha: float = float(cfg.get("near_alpha", 0.6))
	var life: float = float(cfg.get("near_life", 16.0))
	var p := CPUParticles2D.new()
	p.name = nm
	p.z_as_relative = true
	p.z_index = 0
	p.amount = amount
	p.lifetime = life
	p.preprocess = life
	p.fixed_fps = 30
	p.local_coords = false
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(70.0, 8.0)
	p.direction = cfg.get("near_dir", Vector2(0.15, 1.0))
	p.spread = float(cfg.get("near_spread", 10.0))
	p.gravity = cfg.get("near_gravity", Vector2(0.0, 4.0))
	p.initial_velocity_min = float(cfg.get("near_vel_min", 30.0))
	p.initial_velocity_max = float(cfg.get("near_vel_max", 48.0))
	p.tangential_accel_min = -6.0
	p.tangential_accel_max = 6.0
	p.scale_amount_min = float(cfg.get("near_scale_min", 3.0))
	p.scale_amount_max = float(cfg.get("near_scale_max", 4.0))
	p.color = near_b
	p.color_ramp = _near_color_ramp(near_alpha)
	p.color_initial_ramp = _color_pair_ramp(near_a, near_b)
	return p


func _layout_layers() -> void:
	var w: float = _field_size.x
	var h: float = _field_size.y
	var mist_frac: float = float(_cfg.get("mist_frac", 0.38))
	var canopy_frac: float = float(_cfg.get("canopy_frac", 0.22))
	## V0 mist: bottom mist_frac. Canopy: top canopy_frac.
	if _mist != null:
		var mist_top: float = h * (1.0 - mist_frac)
		_mist.position = Vector2(0.0, mist_top)
		_mist.size = Vector2(w, h - mist_top)
	if _canopy != null:
		var canopy_h: float = h * canopy_frac
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
	var h: float = _field_size.y
	var rise: bool = bool(_cfg.get("near_rise", false))
	## Fall: spawn just above the top edge. Rise (Cinder): spawn just below bottom.
	var y: float = -12.0 if not rise else (h + 12.0)
	_near_l.position = Vector2(_band_w * 0.5, y)
	_near_l.emission_rect_extents = Vector2(maxf(8.0, _band_w * 0.5), 8.0)
	_near_r.position = Vector2(w - _band_w * 0.5, y)
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
	## Breath on mist alpha 0.75↔1.0 over breath_s (Verdant = 7 s).
	var breath: float = float(_cfg.get("breath_s", 7.0))
	_mist.modulate.a = 0.75
	_breath_tw = create_tween()
	_breath_tw.set_loops()
	_breath_tw.tween_property(_mist, "modulate:a", 1.0, breath).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_breath_tw.tween_property(_mist, "modulate:a", 0.75, breath).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
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


func _shaft_gradient(c: Color = C_LEAF_LIT) -> GradientTexture2D:
	## Soft core: transparent edges, tint α ≤ 0.08 in the middle.
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.45, 0.55, 1.0])
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


func _near_color_ramp(alpha: float = 0.6) -> Gradient:
	## Dark FG, α hold → 0 over the last 15%.
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.85, 1.0])
	g.colors = PackedColorArray([
		Color(1.0, 1.0, 1.0, alpha),
		Color(1.0, 1.0, 1.0, alpha),
		Color(1.0, 1.0, 1.0, 0.0),
	])
	return g


func _color_pair_ramp(a: Color, b: Color) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([a, b])
	return g
