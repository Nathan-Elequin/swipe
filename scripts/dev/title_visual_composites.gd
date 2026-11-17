extends SceneTree
## Headless 1680×1040 composites for Living trophy room title visuals.
## Prefers software blit (works under dummy renderer). Writes playtest/proof/title-visual/*.png


const OUT := "res://playtest/proof/title-visual"
const W := 1680
const H := 1040


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var ok := true
	ok = _compose_title_save("01-title-save.png") and ok
	ok = _compose_title_nosave("02-title-nosave.png") and ok
	ok = _compose_picker("03-picker.png") and ok
	ok = _compose_settings("04-settings.png") and ok
	ok = _compose_intro_preview("05-intro-preview.png") and ok
	ok = _compose_start_over("06-start-over-confirm.png") and ok
	ok = _compose_ticker_combat("07-ticker-combat.png") and ok
	ok = _compose_ticker_title("08-ticker-title.png") and ok

	var names := [
		"01-title-save.png", "02-title-nosave.png", "03-picker.png", "04-settings.png",
		"05-intro-preview.png", "06-start-over-confirm.png", "07-ticker-combat.png", "08-ticker-title.png",
	]
	for n in names:
		var abs_path := ProjectSettings.globalize_path("%s/%s" % [OUT, n])
		if not FileAccess.file_exists(abs_path):
			print("missing %s" % n)
			ok = false
			continue
		var f := FileAccess.open(abs_path, FileAccess.READ)
		if f == null or f.get_length() < 64:
			print("empty %s" % n)
			ok = false
		if f:
			f.close()

	print("TITLE_VISUAL_COMPOSITES_%s" % ("OK" if ok else "FAIL"))
	quit(0 if ok else 1)


func _compose_title_save(filename: String) -> bool:
	var img := _base_title()
	_blit_board(img, [
		[&"cleared", 100], [&"entered", 42], [&"entered", 7], [&"gray", 0], [&"gray", 0],
	])
	_blit_menu(img, ["title.menu.continue", "title.menu.settings", "title.menu.feedback"], true)
	_blit_goal_ring(img, "deeper")
	_fill_label(img, 930, 170, "title.overlay", Color("f4ede3"))
	return _save(img, filename)


func _compose_title_nosave(filename: String) -> bool:
	var img := _base_title()
	_blit_board(img, [
		[&"entered", 0], [&"gray", 0], [&"gray", 0], [&"gray", 0], [&"gray", 0],
	])
	_blit_menu(img, ["title.menu.new_game", "title.menu.settings", "title.menu.feedback"], false)
	_fill_label(img, 930, 170, "title.overlay", Color("f4ede3"))
	return _save(img, filename)


func _compose_picker(filename: String) -> bool:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color("0b0908"))
	_blit_scaled(img, "res://assets/ui/biome_splash/bg_verdant.png", 0, 0, 1680, 832)
	_fill(img, Rect2i(0, 0, W, H), Color(0.043, 0.035, 0.031, 0.68))
	_fill_label(img, 80, 60, "playtest.tier.choose_title", Color("f4ede3"))
	var ids := ["quick", "deeper", "big"]
	var splashes := ["verdant", "crystal", "shadow"]
	var monsters := ["goblin", "gargoyle", "lich"]
	for i in 3:
		var x := 124 + 500 * i
		var y := 206
		var hovered := i == 1
		var yy := y - (8 if hovered else 0)
		_draw_box(img, x, yy, 440, 586, Color("100e0c"), Color("e8c36a") if hovered else Color("6b5235"), 4)
		_blit_scaled(img, "res://assets/ui/biome_splash/bg_%s.png" % splashes[i], x - 20, yy, 480, 240)
		## Card vignette (native 200×112 → 400×224) over the dim splash well.
		_blit_scaled(img, "res://assets/ui/title/picker/card_vignette_%s.png" % ids[i], x + 20, yy + 12, 400, 224)
		_blit_scaled(img, "res://assets/dungeon/anim/facing/%s_facing_idle_f0.png" % monsters[i], x + 180, yy + 100, 80 if monsters[i] != "lich" else 96, 80 if monsters[i] != "lich" else 96)
		_blit_scaled(img, "res://assets/ui/title/goal/goal_ring_%s.png" % ids[i], x + 181, yy + 290, 78, 78)
		_fill_label(img, x + 30, yy + 400, "playtest.tier.%s.title" % ids[i], Color("e8c36a"))
		_fill_label(img, x + 30, yy + 440, "biome.name.%s" % splashes[i], Color("f4ede3"))
		_fill_label(img, x + 30, yy + 480, "playtest.tier.%s.time" % ids[i], Color("b6a78e"))
		_draw_box(img, x + 44, yy + 518, 352, 56, Color("3a3220"), Color("e8c36a"), 2)
		_fill_label(img, x + 120, yy + 534, "picker.pick.%s" % ids[i], Color("f0e6d8"))
	_fill_label(img, 56, 840, "picker.back", Color("b6a78e"))
	return _save(img, filename)


func _compose_settings(filename: String) -> bool:
	var img := _base_title()
	_fill(img, Rect2i(0, 0, W, H), Color(0.043, 0.035, 0.031, 0.62))
	_blit_scaled(img, "res://assets/dungeon/home/overlays/pause_board.png", 440, 60, 800, 720)
	_fill_label(img, 720, 80, "pause.settings", Color("2a1c10"))
	var labels := [
		"Item sparkles: on", "Invert scroll: off", "Reduce motion: off",
		"pause.master", "pause.music", "pause.ambience", "pause.sound", "pause.ui",
	]
	for i in labels.size():
		_draw_box(img, 584, 148 + i * 72, 512, 64, Color("3a3220"), Color("c9a15a"), 2)
		_fill_label(img, 620, 168 + i * 72, labels[i], Color("f0e6d8"))
	_draw_box(img, 664, 796, 352, 64, Color("3a3220"), Color("e8c36a"), 2)
	_fill_label(img, 780, 816, "settings.back", Color("f0e6d8"))
	_blit_scaled(img, "res://assets/ui/title/title_nib_lantern.png", 110, 560, 274, 274)
	return _save(img, filename)


func _compose_intro_preview(filename: String) -> bool:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color("0b0908"))
	_draw_box(img, 252, 72, 1176, 736, Color("0b0908"), Color("8a693e"), 4)
	## Nested title preview (no-save) scaled into frame.
	var inner := _base_title()
	_blit_board(inner, [
		[&"entered", 0], [&"gray", 0], [&"gray", 0], [&"gray", 0], [&"gray", 0],
	])
	_blit_menu(inner, ["title.menu.new_game", "title.menu.settings", "title.menu.feedback"], false)
	inner.resize(1168, 728, Image.INTERPOLATE_BILINEAR)
	img.blit_rect(inner, Rect2i(0, 0, 1168, 728), Vector2i(256, 76))
	_fill_label(img, 430, 840, "intro.preview.caption", Color("f4ede3"))
	return _save(img, filename)


func _compose_start_over(filename: String) -> bool:
	var img := _base_title()
	_blit_board(img, [
		[&"cleared", 100], [&"entered", 42], [&"entered", 7], [&"gray", 0], [&"gray", 0],
	])
	_blit_menu(img, ["title.menu.continue", "title.menu.settings", "title.menu.feedback"], true)
	_fill(img, Rect2i(0, 0, W, H), Color(0.043, 0.035, 0.031, 0.6))
	_draw_box(img, 560, 410, 560, 220, Color("100e0c"), Color("e8c36a"), 2)
	_fill_label(img, 640, 440, "title.start_over.ask", Color("f4ede3"))
	_fill_label(img, 640, 480, "title.start_over.body", Color("9c8f7d"))
	_draw_box(img, 620, 540, 224, 64, Color("3a3220"), Color("e8c36a"), 2)
	_fill_label(img, 680, 560, "title.start_over.no", Color("f0e6d8"))
	_draw_box(img, 870, 540, 224, 64, Color("3a3220"), Color("6b5235"), 2)
	_fill_label(img, 930, 560, "title.start_over.yes", Color("f0e6d8"))
	return _save(img, filename)


func _compose_ticker_combat(filename: String) -> bool:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color("15120f"))
	## Wheel / hand keep-out hints.
	_draw_box(img, 837 - 296, 317 - 296, 592, 592, Color(0.2, 0.18, 0.15, 0.35), Color(0.35, 0.3, 0.25, 0.5), 2)
	_draw_box(img, 382, 700, 916, 310, Color(0.25, 0.2, 0.15, 0.4), Color(0.4, 0.3, 0.2, 0.5), 2)
	_blit_goal_ring(img, "quick")
	_blit_ticker(img, [
		[&"entered", 0], [&"gray", 0], [&"gray", 0], [&"gray", 0], [&"gray", 0],
	])
	_fill_label(img, 100, 130, "playtest.goal.quick", Color("f4ede3"))
	return _save(img, filename)


func _compose_ticker_title(filename: String) -> bool:
	var img := _base_title()
	_blit_board(img, [
		[&"cleared", 100], [&"entered", 42], [&"entered", 7], [&"gray", 0], [&"gray", 0],
	])
	_blit_menu(img, ["title.menu.continue", "title.menu.settings", "title.menu.feedback"], true)
	_blit_goal_ring(img, "deeper")
	_blit_ticker(img, [
		[&"cleared", 100], [&"entered", 42], [&"entered", 7], [&"gray", 0], [&"gray", 0],
	])
	_fill_label(img, 100, 130, "playtest.goal.deeper", Color("f4ede3"))
	return _save(img, filename)


func _base_title() -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color("0b0908"))
	_blit_scaled(img, "res://assets/ui/biome_splash/bg_verdant.png", 0, 0, 1680, 832)
	_fill(img, Rect2i(0, 832, 1680, 208), Color("0b0908"))
	_fill(img, Rect2i(0, 0, W, H), Color(0.043, 0.035, 0.031, 0.52))
	_blit_scaled(img, "res://assets/ui/title/title_nib_lantern.png", 560, 624, 274, 274)
	return img


func _blit_board(img: Image, states: Array) -> void:
	## TitleBoard at (90,196) scaled 2x covering 664x388.
	var ox := 90
	var oy := 196
	_blit_scaled(img, "res://assets/ui/trophy_board/board_frame.png", ox, oy, 664, 388)
	_blit_scaled(img, "res://assets/ui/trophy_board/board_trim_gold.png", ox, oy, 664, 388)
	var slugs := ["verdant", "crystal", "ashen", "cinder", "shadow"]
	var fulls := ["verdant_hollow", "crystal_cavern", "ashen_crypt", "cinder_forge", "shadow_abyss"]
	for i in 5:
		var st: StringName = states[i][0]
		var pct: int = int(states[i][1])
		var wx := ox + (12 + 63 * i) * 2
		var wy := oy + 22 * 2
		## Face crop into window.
		_blit_scaled(img, "res://assets/ui/trophy_board/face_bg_%s.png" % slugs[i], wx, wy, 112, 308)
		if st == &"gray":
			_fill(img, Rect2i(wx, wy, 112, 308), Color(0.36, 0.36, 0.40, 0.45))
		if st == &"cleared":
			_blit_scaled(img, "res://assets/ui/title/board_window_cap_gold.png", wx, wy, 112, 8)
		var stem := "gray"
		if st == &"entered":
			stem = "entered"
		elif st == &"cleared":
			stem = "cleared"
		var ix := ox + (22 + 63 * i) * 2
		var iy := oy + 130 * 2
		_blit_scaled(img, "res://assets/ui/title/progress/biome_%s_%s.png" % [fulls[i], stem], ix, iy, 72, 72)
		## Pct / name in screen space.
		if st == &"entered":
			_fill_label(img, 150 + 126 * i, 502, "%d%%" % pct, Color("e8c36a"))
		var name_col := Color("8a7f70") if st == &"gray" else Color("f4ede3")
		_fill_label(img, 110 + 126 * i, 592, "biome.name.%s" % slugs[i], name_col)
	_blit_scaled(img, "res://assets/ui/title/board_windows_5.png", ox + 24, oy + 44, 616, 308)


func _blit_menu(img: Image, keys: Array, start_over: bool) -> void:
	for i in keys.size():
		var y := 300 + 124 * i
		_draw_box(img, 1110, y, 440, 80, Color("3a3220"), Color("c9a15a"), 2)
		_fill_label(img, 1180, y + 28, str(keys[i]), Color("f0e6d8"))
		## Presenter pip.
		_fill(img, Rect2i(1020, y + 16, 48, 48), Color("2a2018"))
	if start_over:
		_fill_label(img, 1210, 700, "title.menu.start_over", Color("9c8f7d"))


func _blit_goal_ring(img: Image, which: String) -> void:
	_blit_scaled(img, "res://assets/ui/title/goal/goal_ring_%s.png" % which, 16, 16, 78, 78)


func _blit_ticker(img: Image, states: Array) -> void:
	_draw_box(img, 100, 14, 436, 100, Color(0.102, 0.078, 0.063, 0.96), Color("e8c36a"), 2)
	var fulls := ["verdant_hollow", "crystal_cavern", "ashen_crypt", "cinder_forge", "shadow_abyss"]
	for i in 5:
		var st: StringName = states[i][0]
		var pct: int = int(states[i][1])
		var stem := "gray"
		if st == &"entered":
			stem = "entered"
		elif st == &"cleared":
			stem = "cleared"
		var x := 100 + 18 + i * (72 + 10)
		var y := 14 + 14
		_blit_scaled(img, "res://assets/ui/title/progress/biome_%s_%s.png" % [fulls[i], stem], x, y, 72, 72)
		if st == &"entered":
			_fill_label(img, x + 16, y + 46, "%d%%" % pct, Color("e8c36a"))


func _blit_scaled(dst: Image, path: String, x: int, y: int, w: int, h: int) -> bool:
	var src := Image.new()
	if src.load(path) != OK:
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


func _fill(img: Image, r: Rect2i, col: Color) -> void:
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			if x < 0 or y < 0 or x >= W or y >= H:
				continue
			if col.a >= 0.999:
				img.set_pixel(x, y, col)
			else:
				img.set_pixel(x, y, img.get_pixel(x, y).blend(col))


func _draw_box(img: Image, x: int, y: int, w: int, h: int, fill: Color, border: Color, bw: int = 2) -> void:
	_fill(img, Rect2i(x, y, w, h), fill)
	for t in range(bw):
		_fill(img, Rect2i(x + t, y + t, w - 2 * t, 1), border)
		_fill(img, Rect2i(x + t, y + h - 1 - t, w - 2 * t, 1), border)
		_fill(img, Rect2i(x + t, y + t, 1, h - 2 * t), border)
		_fill(img, Rect2i(x + w - 1 - t, y + t, 1, h - 2 * t), border)


func _fill_label(img: Image, x: int, y: int, text: String, color: Color) -> void:
	var cx := x
	for ch in text:
		if str(ch) == " ":
			cx += 8
			continue
		for dy in range(0, 10):
			for dx in range(0, 6):
				var px := cx + dx
				var py := y + dy
				if px >= 0 and py >= 0 and px < W and py < H:
					img.set_pixel(px, py, color)
		cx += 8
		if cx > W - 20:
			break


func _save(img: Image, filename: String) -> bool:
	var path := "%s/%s" % [OUT, filename]
	var err := img.save_png(path)
	print("composite ", path, " err=", err, " size=", img.get_width(), "x", img.get_height())
	return err == OK
