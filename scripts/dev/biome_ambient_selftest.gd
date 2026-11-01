extends SceneTree
## Headless checks for Verdant Hollow ambient FX kit. Does not boot main.tscn.
## Run: godot --headless --path . -s res://scripts/dev/biome_ambient_selftest.gd


func _init() -> void:
	var Ambient = load("res://scripts/fx/biome_ambient.gd")
	var failed := false
	var root_n := Node.new()
	root.add_child(root_n)

	## Stand-ins for wheel (z0) and hotbar (z16) so z + band geometry can be checked.
	var wheel := Control.new()
	wheel.name = "WheelView"
	wheel.z_index = 0
	wheel.position = Vector2(520, 120)
	wheel.size = Vector2(640, 640)
	root_n.add_child(wheel)

	var hotbar := Control.new()
	hotbar.name = "HotbarWrap"
	hotbar.z_index = 16
	hotbar.position = Vector2(420, 920)
	hotbar.size = Vector2(840, 96)
	root_n.add_child(hotbar)

	var amb = Ambient.new()
	root_n.add_child(amb)
	amb.setup(Vector2(1680, 1040))
	amb.set_avoid_rects([wheel.get_global_rect(), hotbar.get_global_rect()])

	## 1. b1 builds kit; b2 / "" build nothing.
	amb.set_enabled(true)
	amb.set_biome("b1")
	failed = _check(failed, "b1 builds haze", amb.get_node_or_null("DampHaze") != null) or failed
	failed = _check(failed, "b1 mist+canopy", _haze_rect_count(amb) == 2) or failed
	failed = _check(failed, "b1 spores", amb.get_node_or_null("FarSpores") != null) or failed
	failed = _check(failed, "b1 fireflies", amb.get_node_or_null("HollowFireflies") != null) or failed
	failed = _check(failed, "b1 near L", amb.find_child("NearMossL", true, false) != null) or failed
	failed = _check(failed, "b1 near R", amb.find_child("NearMossR", true, false) != null) or failed
	if Ambient.SHAFT_ENABLED:
		failed = _check(failed, "shaft child present", amb.shaft_present()) or failed
		failed = _check(failed, "shaft named LightShaft", amb.get_node_or_null("LightShaft") != null) or failed
	else:
		failed = _check(failed, "shaft yanked", not amb.shaft_present()) or failed

	amb.set_biome("b2")
	failed = _check(failed, "b2 builds 0", amb.layer_count() == 0) or failed
	amb.set_biome("")
	failed = _check(failed, "empty builds 0", amb.layer_count() == 0) or failed

	amb.set_biome("b1")
	## 2. BG z < wheel; FG z > wheel and < hotbar.
	var spores: CPUParticles2D = amb.get_node_or_null("FarSpores")
	var flies: CPUParticles2D = amb.get_node_or_null("HollowFireflies")
	var haze: Node2D = amb.get_node_or_null("DampHaze")
	var near_root: Node2D = amb.get_node_or_null("NearMossDrift")
	failed = _check(failed, "haze z < wheel", haze != null and haze.z_index < wheel.z_index) or failed
	failed = _check(failed, "spores z < wheel", spores != null and spores.z_index < wheel.z_index) or failed
	failed = _check(failed, "fireflies z < wheel", flies != null and flies.z_index < wheel.z_index) or failed
	failed = _check(failed, "near z > wheel", near_root != null and near_root.z_index > wheel.z_index) or failed
	failed = _check(failed, "near z < hotbar", near_root != null and near_root.z_index < hotbar.z_index) or failed
	if amb.shaft_present():
		var shaft: CanvasItem = amb.get_node_or_null("LightShaft")
		failed = _check(failed, "shaft z < wheel", shaft != null and shaft.z_index < wheel.z_index) or failed
		failed = _check(failed, "shaft z between haze and spores",
			shaft != null and haze != null and spores != null
			and shaft.z_index > haze.z_index and shaft.z_index < spores.z_index) or failed

	## 3. FG fall columns do not intersect wheel / hotbar at 1680×1040.
	var bands: Array = amb.near_band_rects()
	failed = _check(failed, "two bands", bands.size() == 2) or failed
	failed = _check(failed, "band width >= 96", amb.band_width() >= 96.0) or failed
	var wheel_r: Rect2 = wheel.get_global_rect()
	var hot_r: Rect2 = hotbar.get_global_rect()
	for b in bands:
		var band: Rect2 = b
		## Convert local band → global via ambient transform.
		var g := Rect2(amb.to_global(band.position), band.size)
		failed = _check(failed, "band misses wheel", not g.intersects(wheel_r)) or failed
		failed = _check(failed, "band misses hotbar", not g.intersects(hot_r)) or failed

	## 4. Particle budget.
	var total: int = amb.total_particle_amount()
	failed = _check(failed, "amount <= 50", total <= 50) or failed
	failed = _check(failed, "desktop whisper ~44", total <= 44 and total >= 20) or failed

	## 5. Off = invisible + not emitting.
	amb.set_enabled(false)
	failed = _check(failed, "off invisible", not amb.visible) or failed
	failed = _check(failed, "off spores quiet", spores != null and not spores.emitting) or failed
	failed = _check(failed, "off fireflies quiet", flies != null and not flies.emitting) or failed
	var nl: CPUParticles2D = amb.find_child("NearMossL", true, false)
	var nr: CPUParticles2D = amb.find_child("NearMossR", true, false)
	failed = _check(failed, "off near L quiet", nl != null and not nl.emitting) or failed
	failed = _check(failed, "off near R quiet", nr != null and not nr.emitting) or failed

	## 6. No player-facing copy nodes.
	failed = _check(failed, "no Label under ambient", amb.find_children("*", "Label", true, false).is_empty()) or failed
	failed = _check(failed, "no RichTextLabel under ambient", amb.find_children("*", "RichTextLabel", true, false).is_empty()) or failed

	## 7. Group membership for text_audit skip.
	failed = _check(failed, "in ambient_fx group", amb.is_in_group("ambient_fx")) or failed

	## 8. Only b1 in BIOMES.
	failed = _check(failed, "BIOMES has b1", Ambient.BIOMES.has("b1")) or failed
	failed = _check(failed, "BIOMES lacks b2", not Ambient.BIOMES.has("b2")) or failed
	failed = _check(failed, "BIOMES lacks b5", not Ambient.BIOMES.has("b5")) or failed
	failed = _check(failed, "CPUParticles only",
		amb.find_children("*", "GPUParticles2D", true, false).is_empty()) or failed

	amb.free()
	root_n.free()
	if failed:
		print("BIOME_AMBIENT_SELFTEST fail")
		quit(1)
	else:
		print("BIOME_AMBIENT_SELFTEST ok")
		quit(0)


func _haze_rect_count(amb: Node) -> int:
	var haze: Node = amb.get_node_or_null("DampHaze")
	if haze == null:
		return 0
	var n := 0
	for c in haze.get_children():
		if c is TextureRect:
			n += 1
	return n


func _check(already: bool, label: String, ok: bool) -> bool:
	if ok:
		print("PASS ", label)
		return already
	print("FAIL ", label)
	return true
