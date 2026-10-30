extends SceneTree
## Render dungeon_bg at 1680×1040 for b1 then b4, compare edge means.
## Needs a real renderer (dummy/--headless cannot capture). On Linux CI/cloud:
##   xvfb-run -a godot --path <repo> --script res://tools/qa/check_biome_tint.gd
## On Cherry: run the same --script line against the installed Godot 4.x binary.

const W := 1680
const H := 1040
const OUT_DIR := "user://biome_tint_check"

var _vp: SubViewport
var _bg
var _step: int = 0


func _init() -> void:
	call_deferred("_boot")


func _boot() -> void:
	var art_scr = load("res://scripts/dungeon_art.gd")
	var bg_scr = load("res://scripts/dungeon_bg.gd")
	if art_scr == null or bg_scr == null:
		push_error("failed to load dungeon_art / dungeon_bg")
		quit(1)
		return
	var art = art_scr.new()
	art.setup()
	_vp = SubViewport.new()
	_vp.size = Vector2i(W, H)
	_vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_vp.transparent_bg = false
	root.add_child(_vp)
	_bg = bg_scr.new()
	_vp.add_child(_bg)
	_bg.setup(art)
	_bg.size = Vector2(W, H)
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.set_biome("b1")
	_step = 0
	# Wait a couple frames for import/atlas + redraw.
	await process_frame
	await process_frame
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_capture("b1")
	_bg.set_biome("b4")
	await process_frame
	await process_frame
	_capture("b4")
	_compare()
	quit(0)


func _capture(tag: String) -> void:
	var tex: ViewportTexture = _vp.get_texture()
	var img: Image = tex.get_image()
	if img == null:
		push_error("no image for %s" % tag)
		quit(1)
		return
	var path := "%s/%s.png" % [OUT_DIR, tag]
	img.save_png(path)
	print("wrote ", ProjectSettings.globalize_path(path))


func _region_mean(img: Image, x0: int, y0: int, x1: int, y1: int) -> Vector3:
	var s := Vector3.ZERO
	var n := 0
	for y in range(y0, y1):
		for x in range(x0, x1):
			var c: Color = img.get_pixel(x, y)
			s += Vector3(c.r * 255.0, c.g * 255.0, c.b * 255.0)
			n += 1
	if n == 0:
		return Vector3.ZERO
	return s / float(n)


func _compare() -> void:
	var p1 := "%s/b1.png" % OUT_DIR
	var p4 := "%s/b4.png" % OUT_DIR
	var i1 := Image.load_from_file(ProjectSettings.globalize_path(p1))
	var i4 := Image.load_from_file(ProjectSettings.globalize_path(p4))
	if i1 == null or i4 == null:
		# Image.load_from_file wants absolute; try user path via FileAccess
		i1 = Image.new()
		i4 = Image.new()
		if i1.load(p1) != OK or i4.load(p4) != OK:
			push_error("could not reload captures")
			quit(1)
			return
	var l1 := _region_mean(i1, 0, 200, 40, 800)
	var l4 := _region_mean(i4, 0, 200, 40, 800)
	var r1 := _region_mean(i1, W - 40, 200, W, 800)
	var r4 := _region_mean(i4, W - 40, 200, W, 800)
	print("b1 left=", l1, " right=", r1)
	print("b4 left=", l4, " right=", r4)
	# Verdant: green channel should dominate left edge.
	if l1.y <= l1.x:
		push_error("FAIL: Verdant left edge not green-dominant: %s" % l1)
		quit(2)
		return
	# Cinder: red should dominate left edge.
	if l4.x <= l4.y:
		push_error("FAIL: Cinder left edge not red/orange-dominant: %s" % l4)
		quit(2)
		return
	var delta: float = absf(l1.x - l4.x) + absf(l1.y - l4.y) + absf(l1.z - l4.z)
	delta += absf(r1.x - r4.x) + absf(r1.y - r4.y) + absf(r1.z - r4.z)
	print("edge_delta_sum=", delta)
	if delta < 20.0:
		push_error("FAIL: b1 vs b4 edges too similar (delta=%s)" % delta)
		quit(2)
		return
	print("PASS: biome tint edges differ (Verdant green vs Cinder orange)")
