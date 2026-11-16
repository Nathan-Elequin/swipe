extends SceneTree
## Headless proof shot: measures NewStar after layout, draws a diagram PNG.
## (Dummy headless renderer often has no usable viewport texture.)
## Run: godot --headless --path . --script res://scripts/dev/new_star_shot.gd

const ITEM_CARD := preload("res://scripts/item_card.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var out_rel := "res://playtest/repot/outbox/REQ-20261116-hotbar-new-star-size/shots"
	var out_abs := ProjectSettings.globalize_path(out_rel)
	DirAccess.make_dir_recursive_absolute(out_abs)

	var hot_panel := PanelContainer.new()
	hot_panel.clip_contents = false
	hot_panel.position = Vector2(24, 24)
	var hsb := StyleBoxFlat.new()
	hsb.bg_color = Color("14100ce8")
	hsb.border_color = Color("c4a574")
	hsb.set_border_width_all(2)
	hsb.set_corner_radius_all(8)
	hsb.content_margin_left = 4
	hsb.content_margin_right = 4
	hsb.content_margin_top = 4
	hsb.content_margin_bottom = 4
	hot_panel.add_theme_stylebox_override("panel", hsb)
	root.add_child(hot_panel)

	var hot_grid := HBoxContainer.new()
	hot_grid.add_theme_constant_override("separation", 8)
	hot_panel.add_child(hot_grid)

	var card: Control = ITEM_CARD.new()
	hot_grid.add_child(card)
	card.setup(1, "crossbow", "3", null, Color("5c2626"), Color("c5cdd8"), "Crossbow")
	card.custom_minimum_size = Vector2(ITEM_CARD.CARD_W, ITEM_CARD.CARD_H)
	card.size = Vector2(ITEM_CARD.CARD_W, ITEM_CARD.CARD_H)
	card.set_live("3", "", true)
	card.set_new_star(true)

	hot_panel.queue_sort()
	card.queue_sort()
	await process_frame
	await process_frame

	var star = card.get("_new_star") as Control
	if star == null or not star.visible:
		push_error("NEW_STAR_SHOT_FAIL no visible star")
		quit(1)
		return
	if not is_equal_approx(star.size.x, 28.0) or not is_equal_approx(star.size.y, 28.0):
		push_error("NEW_STAR_SHOT_FAIL star size %s" % str(star.size))
		quit(1)
		return

	var card_r: Rect2 = card.get_global_rect()
	var star_r: Rect2 = star.get_global_rect()
	var img := _diagram(card_r, star_r)
	var path := out_abs.path_join("01-new-star-corner.png")
	var err := img.save_png(path)
	if err != OK:
		push_error("NEW_STAR_SHOT_FAIL save %s" % err)
		quit(1)
		return
	print(
		"NEW_STAR_SHOT_OK path=", path,
		" star_local=", star.size,
		" star_global=", star_r,
		" card_global=", card_r
	)
	quit(0)


func _diagram(card_r: Rect2, star_r: Rect2) -> Image:
	## Paint card + star relative to a padded canvas so Cherry can compare.
	var pad := 32.0
	var w := int(maxi(360, int(card_r.size.x + pad * 2.0)))
	var h := int(maxi(220, int(card_r.size.y + pad * 2.0)))
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color("1a1410"))
	var origin := Vector2(pad, pad)
	_fill_rect(img, Rect2(origin, card_r.size), Color("5c2626"))
	## Fake icon band (center) — star must not cover this.
	var icon := Rect2(
		origin + Vector2(card_r.size.x * 0.5 - 29.0, 36.0),
		Vector2(58, 58)
	)
	_fill_rect(img, icon, Color("3a3330"))
	## Star in local card space.
	var star_local := Rect2(star_r.position - card_r.position + origin, star_r.size)
	_fill_rect(img, star_local, Color("FFD84A"))
	## Outline card.
	_stroke_rect(img, Rect2(origin, card_r.size), Color("c5cdd8"))
	return img


func _fill_rect(img: Image, r: Rect2, c: Color) -> void:
	var x0 := clampi(int(r.position.x), 0, img.get_width() - 1)
	var y0 := clampi(int(r.position.y), 0, img.get_height() - 1)
	var x1 := clampi(int(r.position.x + r.size.x), 0, img.get_width())
	var y1 := clampi(int(r.position.y + r.size.y), 0, img.get_height())
	for y in range(y0, y1):
		for x in range(x0, x1):
			img.set_pixel(x, y, c)


func _stroke_rect(img: Image, r: Rect2, c: Color) -> void:
	var x0 := int(r.position.x)
	var y0 := int(r.position.y)
	var x1 := int(r.position.x + r.size.x) - 1
	var y1 := int(r.position.y + r.size.y) - 1
	for x in range(x0, x1 + 1):
		if x >= 0 and x < img.get_width():
			if y0 >= 0 and y0 < img.get_height():
				img.set_pixel(x, y0, c)
			if y1 >= 0 and y1 < img.get_height():
				img.set_pixel(x, y1, c)
	for y in range(y0, y1 + 1):
		if y >= 0 and y < img.get_height():
			if x0 >= 0 and x0 < img.get_width():
				img.set_pixel(x0, y, c)
			if x1 >= 0 and x1 < img.get_width():
				img.set_pixel(x1, y, c)
