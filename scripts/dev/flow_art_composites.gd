extends SceneTree
## Headless 1680×1040 composites for the flow-overhaul final art drop.
## Writes design/audit-shots/cursor/flow-art/*.png (Nearest blit, no Linear).


const OUT := "res://design/audit-shots/cursor/flow-art"
const W := 1680
const H := 1040


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var ok := true
	ok = _shot_hall_lever("01_hall_lever_locked_faint.png", &"locked", true) and ok
	ok = _shot_hall_lever("02_hall_lever_ready.png", &"ready", false) and ok
	ok = _shot_transition("03_transition_dead_portal_haul.png") and ok
	print("FLOW_ART_COMPOSITES_%s" % ("OK" if ok else "FAIL"))
	quit(0 if ok else 1)


func _shot_hall_lever(filename: String, lever_state: StringName, faint: bool) -> bool:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color("1a100c"))
	## Hall plate if present.
	_blit_scaled(img, "res://assets/dungeon/home/rooms/room_hall.png", 0, 0, W, H)
	## Trophy board face backdrop (verdant) into FACE_VIEWPORT.
	_blit_scaled(img, "res://assets/ui/trophy_board/face_bg_verdant.png", 224, 128, 1232, 616)
	## Crest + lights strip hint.
	_blit(img, "res://assets/ui/trophy_board/crest_verdant.png", 240, 144)
	for k in 5:
		var lit_count := 5 if lever_state == &"ready" else (2 if faint else 0)
		var light_path := "res://assets/ui/trophy_board/light_on.png" if k < lit_count else "res://assets/ui/trophy_board/light_off.png"
		_blit(img, light_path, 672 + k * 72, 164)
	## Nib at hall idle (386,172)×4 = (1544,688), 96×128.
	_blit(img, "res://assets/dungeon/home/nib/nib_idle_f0.png", 1544, 688)
	## Lever: face-local bottom 688 → screen y = 128+464 = 592 for 224-tall art.
	var lever_x := 224 + 1232 - 192 + 16 ## face origin + face-local x
	var lever_y := 128 + (688 - 224)
	var glow_x := lever_x - 32
	var glow_y := lever_y - 56
	if faint or lever_state == &"ready":
		_blit_mod(img, "res://assets/ui/trophy_board/lever_glow.png", glow_x, glow_y, 0.85 if lever_state == &"ready" else 0.28)
	var lever_path := "res://assets/ui/trophy_board/lever_locked.png"
	if lever_state == &"ready":
		lever_path = "res://assets/ui/trophy_board/lever_ready.png"
	elif lever_state == &"spent":
		lever_path = "res://assets/ui/trophy_board/lever_pulled.png"
	_blit(img, lever_path, lever_x, lever_y)
	## Caption strip (debug only — not player-facing).
	_fill(img, Rect2i(16, 1008, 1648, 24), Color(0.05, 0.03, 0.02, 0.85))
	return _save(img, filename)


func _shot_transition(filename: String) -> bool:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color("080605"))
	_blit_scaled(img, "res://assets/dungeon/home/overlays/rope_exit_cavern_bg.png", 0, 0, W, H)
	## Dead portal in GATE_APERTURE (1244, 443, 256, 448) + mist f2.
	_blit(img, "res://assets/dungeon/home/overlays/portal_dead.png", 1244, 443)
	_blit(img, "res://assets/dungeon/home/overlays/portal_dead_mist_f2.png", 1244, 443)
	## Gate frame on top.
	_blit(img, "res://assets/dungeon/home/overlays/rope_exit_gate_frame.png", 1180, 379)
	## 2/5 arch lights along lintel (gate y + 8).
	var light_w := 32
	var gap := 12
	var total_w := 5 * light_w + 4 * gap
	var x0 := 1180 + (384 - total_w) / 2
	var y0 := 379 + 8
	for k in 5:
		var p := "res://assets/dungeon/home/overlays/arch_light_on.png" if k < 2 else "res://assets/dungeon/home/overlays/arch_light_off.png"
		_blit(img, p, x0 + k * (light_w + gap), y0)
	## Floor satchel with 2 real icons + mouth shadow (placeholders covered).
	var sx := 980
	var sy := 820
	_blit(img, "res://assets/dungeon/home/overlays/satchel_floor.png", sx, sy)
	_fill(img, Rect2i(sx + 32, sy + 56, 192, 56), Color(0.20, 0.12, 0.08, 1.0))
	_blit_item_icon(img, "boot", sx + 32, sy + 48)
	_blit_item_icon(img, "net", sx + 96, sy + 48)
	## Carried strip + starred unique.
	_blit_scaled(img, "res://assets/ui/trophy_board/carried_strip_9.png", 80, 920, 1520, 104)
	var icons := ["boot", "net", "smoke_bomb"]
	var icon := 64
	var strip_gap := 16
	var n := icons.size()
	var total := n * icon + (n - 1) * strip_gap
	var ix0 := 80 + int((1520 - total) / 2)
	var iy0 := 920 + int((104 - icon) / 2)
	for i in n:
		_blit_item_icon(img, icons[i], ix0 + i * (icon + strip_gap), iy0)
	## Star on first (new unique).
	_blit(img, "res://assets/ui/trophy_board/unique_star.png", ix0 + icon - 22, iy0 - 14)
	return _save(img, filename)


func _blit_item_icon(dst: Image, item_id: String, x: int, y: int) -> void:
	## Prefer dungeon item art; fall back to a flat pip.
	var path := "res://assets/dungeon/items/%s.png" % item_id
	if _blit_scaled(dst, path, x, y, 64, 64):
		return
	_fill(dst, Rect2i(x, y, 64, 64), Color("c4a574"))


func _blit(dst: Image, path: String, x: int, y: int) -> bool:
	return _blit_mod(dst, path, x, y, 1.0)


func _blit_scaled(dst: Image, path: String, x: int, y: int, w: int, h: int) -> bool:
	var src := Image.new()
	if src.load(path) != OK:
		return false
	if src.get_format() != Image.FORMAT_RGBA8:
		src.convert(Image.FORMAT_RGBA8)
	if src.get_width() != w or src.get_height() != h:
		src.resize(w, h, Image.INTERPOLATE_NEAREST)
	## Opaque full-plate backdrops can replace; sprites must alpha-blend.
	var opaque_plate := w >= W - 8 and h >= H - 8
	if opaque_plate:
		dst.blit_rect(src, Rect2i(0, 0, w, h), Vector2i(x, y))
		return true
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


func _blit_mod(dst: Image, path: String, x: int, y: int, a: float) -> bool:
	var src := Image.new()
	if src.load(path) != OK:
		return false
	if src.get_format() != Image.FORMAT_RGBA8:
		src.convert(Image.FORMAT_RGBA8)
	for py in src.get_height():
		for px in src.get_width():
			var c: Color = src.get_pixel(px, py)
			if c.a <= 0.001:
				continue
			c.a *= a
			var dx := x + px
			var dy := y + py
			if dx < 0 or dy < 0 or dx >= W or dy >= H:
				continue
			var base: Color = dst.get_pixel(dx, dy)
			dst.set_pixel(dx, dy, base.blend(c))
	return true


func _fill(img: Image, r: Rect2i, col: Color) -> void:
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			if x >= 0 and y >= 0 and x < W and y < H:
				img.set_pixel(x, y, col)


func _save(img: Image, filename: String) -> bool:
	var path := "%s/%s" % [OUT, filename]
	var err := img.save_png(path)
	print("composite ", path, " err=", err, " size=", img.get_width(), "x", img.get_height())
	return err == OK
