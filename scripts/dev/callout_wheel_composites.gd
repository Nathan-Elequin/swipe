extends SceneTree
## Image-blit composites proving callout idle matches wheel seat framing.
## Writes design/audit-shots/cursor/callout-wheel-match/<id>.png
## Method: headless Image blit (Nearest). Viewport capture needs xvfb (optional).

const ART := preload("res://scripts/dungeon_art.gd")
const WHEEL := preload("res://scripts/boss_wheel.gd")
const STAGE := preload("res://scripts/combat_stage.gd")

const OUT := "res://design/audit-shots/cursor/callout-wheel-match"
const W := 1680
const H := 1040
const IDS := ["juggernaut", "golem", "ogre", "goblin", "phantom", "shark", "bear_trap"]
const STAGE_SZ := Vector2(280, 216)
const CELL := 160
const FOOT_Y_WHEEL := 220
const FOOT_Y_BEFORE := 480
const FOOT_Y_AFTER := 740


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var art = ART.new()
	art.setup()
	var ok := true
	for id in IDS:
		ok = _shot(art, id) and ok
	print("CALLOUT_WHEEL_COMPOSITES_%s method=image-blit" % ("OK" if ok else "FAIL"))
	quit(0 if ok else 1)


func _shot(art, id: String) -> bool:
	var seat: Array = art.monster_seat_frames(id)
	if seat.is_empty():
		seat = art.monster_wheel_frames(id)
	var portrait: Array = art.monster_portrait_frames(id)
	if seat.is_empty() or portrait.is_empty():
		print("skip ", id, " (no frames)")
		return false
	var n: int = mini(seat.size(), portrait.size())
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color("1a1410"))
	_fill(img, Rect2i(0, FOOT_Y_WHEEL, W, 2), Color("FFD84A"))
	_fill(img, Rect2i(0, FOOT_Y_BEFORE, W, 2), Color("c08050"))
	_fill(img, Rect2i(0, FOOT_Y_AFTER, W, 2), Color("8dcb8d"))
	_caption(img, 16, 24, "WHEEL seat @ WHEEL_SPRITE_SCALE (feet-anchored) — %s" % id)
	_caption(img, 16, FOOT_Y_WHEEL + 16, "CALLOUT BEFORE — per-frame crop/scale (old)")
	_caption(img, 16, FOOT_Y_BEFORE + 16, "CALLOUT AFTER — strip region + scale (new)")

	var x0 := 40
	for i in n:
		var cell_x := x0 + i * (CELL + 24)
		# Row 1: wheel seat full canvas, feet-anchored at WHEEL_SPRITE_SCALE.
		_blit_wheel_cell(img, seat[i] as Texture2D, cell_x, FOOT_Y_WHEEL)
		# Row 2: old per-frame callout math on portrait frames.
		_blit_callout_old(img, portrait[i] as Texture2D, cell_x, FOOT_Y_BEFORE)
		# Row 3: new strip framing via combat_stage.
		_blit_callout_new(img, art, id, i, cell_x, FOOT_Y_AFTER)

	var path := "%s/%s.png" % [OUT, id]
	var err := img.save_png(path)
	print("composite ", path, " err=", err, " method=image-blit frames=", n)
	return err == OK


func _blit_wheel_cell(dst: Image, tex: Texture2D, cell_x: int, foot_y: int) -> void:
	if tex == null:
		return
	var src: Image = tex.get_image()
	if src == null:
		return
	if src.get_format() != Image.FORMAT_RGBA8:
		src.convert(Image.FORMAT_RGBA8)
	var sc: float = WHEEL.WHEEL_SPRITE_SCALE
	var dw: int = int(round(float(src.get_width()) * sc))
	var dh: int = int(round(float(src.get_height()) * sc))
	var scaled := src.duplicate()
	scaled.resize(dw, dh, Image.INTERPOLATE_NEAREST)
	var x: int = cell_x + int((CELL - dw) / 2)
	var y: int = foot_y - dh
	_blit_img(dst, scaled, x, y)


func _blit_callout_old(dst: Image, tex: Texture2D, cell_x: int, foot_y: int) -> void:
	if tex == null:
		return
	var used: Rect2 = _opaque_of(tex)
	var uw: float = maxf(1.0, used.size.x)
	var uh: float = maxf(1.0, used.size.y)
	var fit_w: float = maxf(1.0, STAGE_SZ.x - 8.0)
	var fit_h: float = maxf(1.0, STAGE_SZ.y - 12.0)
	var scale_n: float = minf(fit_h / uh, fit_w / uw)
	scale_n = floor(scale_n / 0.25) * 0.25
	scale_n = clampf(scale_n, 0.25, 4.0)
	var dw: int = int(round(uw * scale_n))
	var dh: int = int(round(uh * scale_n))
	var src: Image = tex.get_image()
	if src == null:
		return
	if src.get_format() != Image.FORMAT_RGBA8:
		src.convert(Image.FORMAT_RGBA8)
	var region := Rect2i(int(used.position.x), int(used.position.y), int(used.size.x), int(used.size.y))
	region = region.intersection(Rect2i(0, 0, src.get_width(), src.get_height()))
	if region.size.x < 1 or region.size.y < 1:
		return
	var crop: Image = src.get_region(region)
	crop.resize(dw, dh, Image.INTERPOLATE_NEAREST)
	# Fit into a STAGE_SZ preview cell, feet at foot_y.
	var preview_sc: float = float(CELL) / STAGE_SZ.x
	var pdw: int = int(round(float(dw) * preview_sc))
	var pdh: int = int(round(float(dh) * preview_sc))
	crop.resize(pdw, pdh, Image.INTERPOLATE_NEAREST)
	var x: int = cell_x + int((CELL - pdw) / 2)
	var y: int = foot_y - pdh
	_blit_img(dst, crop, x, y)


func _blit_callout_new(dst: Image, art, id: String, fi: int, cell_x: int, foot_y: int) -> void:
	var stage = STAGE.new()
	root.add_child(stage)
	stage.setup(art)
	stage.size = STAGE_SZ
	stage.custom_minimum_size = STAGE_SZ
	stage.show_monster(id, 1)
	stage._fi = float(fi)
	stage._place_sprite()
	var tex: Texture2D = stage._sprite.texture
	if tex == null:
		stage.queue_free()
		return
	var src: Image = tex.get_image()
	if src == null:
		stage.queue_free()
		return
	if src.get_format() != Image.FORMAT_RGBA8:
		src.convert(Image.FORMAT_RGBA8)
	var dw: int = int(round(stage._sprite.size.x))
	var dh: int = int(round(stage._sprite.size.y))
	src.resize(dw, dh, Image.INTERPOLATE_NEAREST)
	var preview_sc: float = float(CELL) / STAGE_SZ.x
	var pdw: int = int(round(float(dw) * preview_sc))
	var pdh: int = int(round(float(dh) * preview_sc))
	src.resize(pdw, pdh, Image.INTERPOLATE_NEAREST)
	var x: int = cell_x + int((CELL - pdw) / 2)
	var y: int = foot_y - pdh
	_blit_img(dst, src, x, y)
	stage.queue_free()


func _opaque_of(tex: Texture2D) -> Rect2:
	var region := Rect2(Vector2.ZERO, tex.get_size())
	var img: Image = tex.get_image()
	if img != null:
		var used: Rect2 = img.get_used_rect()
		if used.size.x >= 1.0 and used.size.y >= 1.0:
			region = used
	return region


func _blit_img(dst: Image, src: Image, x: int, y: int) -> void:
	for py in src.get_height():
		for px in src.get_width():
			var c: Color = src.get_pixel(px, py)
			if c.a <= 0.001:
				continue
			var dx := x + px
			var dy := y + py
			if dx < 0 or dy < 0 or dx >= W or dy >= H:
				continue
			var base: Color = dst.get_pixel(dx, dy)
			dst.set_pixel(dx, dy, base.blend(c))


func _fill(img: Image, r: Rect2i, col: Color) -> void:
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			if x >= 0 and y >= 0 and x < W and y < H:
				img.set_pixel(x, y, col)


func _caption(img: Image, x: int, y: int, _text: String) -> void:
	# Caption strip (debug only — no player copy). Text is in the filename/path.
	_fill(img, Rect2i(x, y, 1200, 10), Color(0.05, 0.03, 0.02, 0.7))
