extends SceneTree
## Headless Image-blit composite for Juggernaut A art proof.
## Writes design/audit-shots/cursor/juggernaut-a/composite.png (Nearest blit).


const OUT := "res://design/audit-shots/cursor/juggernaut-a"
const OUT_FILE := "composite.png"
const W := 960
const H := 720
const BG := Color("1a100c")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(BG)

	## Labels are omitted (no font draw in headless blit). Layout top→bottom / left→right.
	## Wheel seat at 2× (48→96)
	var wheel := "res://assets/dungeon/anim/wheel/juggernaut_wheel_idle_f0.png"
	_blit_scaled(img, wheel, 32, 48, 96, 96)
	_blit_scaled(img, "res://assets/dungeon/anim/wheel/juggernaut_wheel_idle_f1.png", 144, 48, 96, 96)

	## Facing idle at 3× (64→192)
	var fx := 280
	var fy := 32
	for i in 4:
		var p := "res://assets/dungeon/anim/facing/juggernaut_facing_idle_f%d.png" % i
		_blit_scaled(img, p, fx + i * 168, fy, 192, 192)

	## Slash f0–f3 at 2× (64→128)
	var sx := 32
	var sy := 280
	for i in 4:
		var p := "res://assets/dungeon/anim/slash/juggernaut_slash_f%d.png" % i
		_blit_scaled(img, p, sx + i * 144, sy, 128, 128)
	_blit_scaled(img, "res://assets/dungeon/anim/slash/juggernaut_slash_base.png", sx + 4 * 144, sy, 128, 128)

	## Extra still at 2× (64×112 → 128×224)
	_blit_scaled(img, "res://assets/dungeon/extra/juggernaut.png", 720, 280, 128, 224)

	var path := "%s/%s" % [OUT, OUT_FILE]
	var err := img.save_png(path)
	print("juggernaut_a_composite ", path, " err=", err, " size=", img.get_width(), "x", img.get_height())
	print("JUGGERNAUT_A_COMPOSITE_%s" % ("OK" if err == OK else "FAIL"))
	quit(0 if err == OK else 1)


func _blit_scaled(dst: Image, path: String, x: int, y: int, w: int, h: int) -> bool:
	var src := Image.new()
	if src.load(path) != OK:
		print("FAIL load ", path)
		return false
	if src.get_format() != Image.FORMAT_RGBA8:
		src.convert(Image.FORMAT_RGBA8)
	if src.get_width() != w or src.get_height() != h:
		src.resize(w, h, Image.INTERPOLATE_NEAREST)
	for py in h:
		for px in w:
			var c: Color = src.get_pixel(px, py)
			if c.a <= 0.001:
				continue
			var dx := x + px
			var dy := y + py
			if dx < 0 or dy < 0 or dx >= W or dy >= H:
				continue
			var base: Color = dst.get_pixel(dx, dy)
			dst.set_pixel(dx, dy, base.blend(c))
	return true
