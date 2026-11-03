extends Control
## Spiral portal behind Rope Exit GateFrame (Crypt Classic).
## Layer siblings: cavern BG → this (void + spiral + floor shadow) → GateFrame on top
## so posts/lintel alpha-clip the swirl. CPUParticles2D only (GL Compatibility / web).
## Palette from BiomeAmbient.BIOMES (b1–b5). Empty next id → dim sealed (no bright swirl).

const AMBIENT := preload("res://scripts/fx/biome_ambient.gd")

## Idle vs delve-hover spiral feel.
const IDLE_SPEED := 1.0
const HOT_SPEED := 2.35
const IDLE_AMOUNT := 18
const HOT_AMOUNT := 36
const SEALED_AMOUNT := 0
const TWEEN_S := 0.22

var _biome_id: String = ""
var _hot: bool = false
var _void: TextureRect
var _core: TextureRect
var _floor_shadow: TextureRect
var _spiral: CPUParticles2D
var _hot_tw: Tween
var _dot_tex: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	clip_contents = false
	_dot_tex = _make_dot(3)
	_build_stack()
	set_next_biome("")


## aperture: screen-space fill inside the posts. floor_shadow: soft contact on room floor.
func configure(aperture: Rect2, floor_shadow: Rect2) -> void:
	position = aperture.position
	size = aperture.size
	if _floor_shadow:
		# Shadow is parented here but positioned in parent (rope_exit) space via
		# absolute offsets relative to this control's origin.
		_floor_shadow.position = floor_shadow.position - aperture.position
		_floor_shadow.size = floor_shadow.size
	_layout_inner()


## next_id: "b1"…"b5". Empty / unknown / endless → dim sealed portal.
func set_next_biome(next_id: String) -> void:
	_biome_id = str(next_id).strip_edges()
	_layout_inner()
	_apply_biome_look()
	_apply_hot_visual(false, true)


func _layout_inner() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	if _spiral:
		_spiral.position = size * 0.5
		# Orbit stays inside the posts; sphere radius scales with aperture.
		_spiral.emission_sphere_radius = clampf(minf(size.x, size.y) * 0.08, 12.0, 28.0)
	if _core:
		var sealed := not AMBIENT.BIOMES.has(_biome_id)
		var core_size := Vector2(96, 120) if not sealed else Vector2(64, 80)
		_core.size = core_size
		_core.position = (size - core_size) * 0.5


func set_hot(on: bool) -> void:
	if _hot == on:
		return
	_hot = on
	_apply_hot_visual(on, false)


func _build_stack() -> void:
	_floor_shadow = TextureRect.new()
	_floor_shadow.name = "FloorShadow"
	_floor_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_floor_shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_floor_shadow.stretch_mode = TextureRect.STRETCH_SCALE
	_floor_shadow.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Draw under void inside this control's children; still behind GateFrame sibling.
	_floor_shadow.z_index = -1
	add_child(_floor_shadow)

	_void = TextureRect.new()
	_void.name = "Void"
	_void.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_void.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_void.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_void.stretch_mode = TextureRect.STRETCH_SCALE
	_void.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_void)

	_core = TextureRect.new()
	_core.name = "CoreGlow"
	_core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_core.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_core.stretch_mode = TextureRect.STRETCH_SCALE
	_core.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_core)

	_spiral = CPUParticles2D.new()
	_spiral.name = "SpiralMotes"
	_spiral.texture = _dot_tex
	_spiral.fixed_fps = 30
	_spiral.local_coords = true
	_spiral.emitting = false
	_spiral.explosiveness = 0.0
	_spiral.randomness = 0.55
	_spiral.lifetime = 3.2
	_spiral.preprocess = 3.2
	_spiral.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_spiral.emission_sphere_radius = 18.0
	_spiral.direction = Vector2(1.0, 0.0)
	_spiral.spread = 180.0
	_spiral.gravity = Vector2.ZERO
	_spiral.initial_velocity_min = 28.0
	_spiral.initial_velocity_max = 52.0
	_spiral.radial_accel_min = -14.0
	_spiral.radial_accel_max = -6.0
	_spiral.tangential_accel_min = 8.0
	_spiral.tangential_accel_max = 18.0
	_spiral.orbit_velocity_min = 0.85
	_spiral.orbit_velocity_max = 1.35
	_spiral.scale_amount_min = 1.2
	_spiral.scale_amount_max = 2.4
	_spiral.amount = IDLE_AMOUNT
	_spiral.speed_scale = IDLE_SPEED
	add_child(_spiral)


func _apply_biome_look() -> void:
	var sealed := not AMBIENT.BIOMES.has(_biome_id)
	var cfg: Dictionary = AMBIENT.BIOMES.get(_biome_id, {}) if not sealed else {}
	var mist: Color = cfg.get("mist", Color("12141a")) if not sealed else Color("12141a")
	var canopy: Color = cfg.get("canopy", Color("0a0c10")) if not sealed else Color("0a0c10")
	var far_b: Color = cfg.get("far_b", Color("6a7080")) if not sealed else Color("3a4048")
	var accent: Color = cfg.get("accent_color", Color("c8d0dc")) if not sealed else Color("4a5058")
	var accent_b: Color = cfg.get("accent_color_b", accent) if not sealed else accent

	# Soft vertical oval void — darker rim, deep centre (reads as depth in the arch).
	var void_a: float = 0.92 if not sealed else 0.72
	_void.texture = _radial_void(canopy, mist, void_a, sealed)
	_floor_shadow.texture = _floor_blob(Color(0.02, 0.02, 0.04, 0.55 if not sealed else 0.35))

	_core.texture = _radial_core(accent if not sealed else Color(0.25, 0.28, 0.32), 0.55 if not sealed else 0.12)
	_core.modulate = Color(1, 1, 1, 1.0 if not sealed else 0.35)
	_core.visible = true

	_spiral.color = accent
	_spiral.color_ramp = _mote_alpha_ramp(0.85 if not sealed else 0.0)
	_spiral.color_initial_ramp = _color_pair(accent, accent_b if not sealed else accent)
	if sealed:
		_spiral.emitting = false
		_spiral.visible = false
		modulate = Color(0.72, 0.74, 0.78, 1.0)
	else:
		_spiral.visible = true
		_spiral.amount = maxi(1, IDLE_AMOUNT)
		_spiral.speed_scale = IDLE_SPEED
		_spiral.emitting = true
		modulate = Color(1, 1, 1, 1)


func _apply_hot_visual(on: bool, instant: bool) -> void:
	if _hot_tw != null and _hot_tw.is_valid():
		_hot_tw.kill()
	_hot_tw = null
	var sealed := not AMBIENT.BIOMES.has(_biome_id)
	if sealed:
		_spiral.emitting = false
		_spiral.visible = false
		_core.modulate = Color(1, 1, 1, 0.35)
		return
	var target_speed: float = HOT_SPEED if on else IDLE_SPEED
	var target_amount: int = HOT_AMOUNT if on else IDLE_AMOUNT
	var core_a: float = 0.95 if on else 0.70
	var void_mod: float = 1.12 if on else 1.0
	if instant:
		_spiral.speed_scale = target_speed
		_spiral.amount = target_amount
		_spiral.emitting = true
		_spiral.visible = true
		_core.modulate = Color(1, 1, 1, core_a)
		_void.modulate = Color(void_mod, void_mod, void_mod, 1.0)
		return
	_spiral.amount = target_amount
	_spiral.emitting = true
	_spiral.visible = true
	_hot_tw = create_tween()
	_hot_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_hot_tw.tween_property(_spiral, "speed_scale", target_speed, TWEEN_S)
	_hot_tw.parallel().tween_property(_core, "modulate:a", core_a, TWEEN_S)
	_hot_tw.parallel().tween_property(_void, "modulate", Color(void_mod, void_mod, void_mod, 1.0), TWEEN_S)


func _make_dot(radius: int) -> Texture2D:
	var d: int = radius * 2 + 1
	var img := Image.create(d, d, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := Vector2(radius, radius)
	for y in range(d):
		for x in range(d):
			if Vector2(x, y).distance_to(c) <= float(radius) + 0.15:
				img.set_pixel(x, y, Color(1, 1, 1, 1))
	return ImageTexture.create_from_image(img)


func _radial_void(centre: Color, rim: Color, peak_a: float, sealed: bool) -> Texture2D:
	var g := Gradient.new()
	var mid_a: float = peak_a * (0.88 if not sealed else 0.75)
	g.offsets = PackedFloat32Array([0.0, 0.45, 0.78, 1.0])
	g.colors = PackedColorArray([
		Color(centre.r, centre.g, centre.b, peak_a),
		Color(centre.r, centre.g, centre.b, mid_a),
		Color(rim.r, rim.g, rim.b, peak_a * 0.55),
		Color(rim.r, rim.g, rim.b, 0.0),
	])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = 128
	tex.height = 192
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.52)
	tex.fill_to = Vector2(0.92, 0.52)
	return tex


func _radial_core(c: Color, peak_a: float) -> Texture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.35, 0.7, 1.0])
	g.colors = PackedColorArray([
		Color(c.r, c.g, c.b, peak_a),
		Color(c.r, c.g, c.b, peak_a * 0.55),
		Color(c.r, c.g, c.b, peak_a * 0.12),
		Color(c.r, c.g, c.b, 0.0),
	])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = 64
	tex.height = 64
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	return tex


func _floor_blob(c: Color) -> Texture2D:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	g.colors = PackedColorArray([
		Color(c.r, c.g, c.b, c.a),
		Color(c.r, c.g, c.b, c.a * 0.45),
		Color(c.r, c.g, c.b, 0.0),
	])
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = 128
	tex.height = 48
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.35)
	tex.fill_to = Vector2(1.0, 0.35)
	return tex


func _mote_alpha_ramp(peak: float) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.12, 0.55, 0.85, 1.0])
	g.colors = PackedColorArray([
		Color(1, 1, 1, 0.0),
		Color(1, 1, 1, peak),
		Color(1, 1, 1, peak * 0.85),
		Color(1, 1, 1, peak * 0.35),
		Color(1, 1, 1, 0.0),
	])
	return g


func _color_pair(a: Color, b: Color) -> Gradient:
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([a, b])
	return g
