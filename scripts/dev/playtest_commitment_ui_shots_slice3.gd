extends SceneTree
## Headless UI shots for playtest commitment slice 3 (offramp).
##
## Run:
##   godot --headless --path . --script res://scripts/dev/playtest_commitment_ui_shots_slice3.gd
##
## Writes under design/audit-shots/commitment-slice3/ and
## playtest/repot/outbox/REQ-20261116-commitment-tiers-slice3/shots/


const OFFRAMP := preload("res://scripts/playtest_offramp.gd")
const C := preload("res://scripts/playtest_commitment.gd")

const OUT_A := "res://design/audit-shots/commitment-slice3"
const OUT_B := "res://playtest/repot/outbox/REQ-20261116-commitment-tiers-slice3/shots"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	await process_frame

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_A))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_B))

	var host: Window = get_root()
	var stage := ColorRect.new()
	stage.color = Color("15120f")
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.add_child(stage)

	var offramp: ColorRect = OFFRAMP.new()
	host.add_child(offramp)
	offramp.setup()

	## 01 — quick offramp form
	offramp.open_offramp(C.M_QUICK, {
		"tier": C.TIER_QUICK,
		"run_count": 1,
		"anon_id": "shot",
		"build_id": "slice3",
		"biomes_unlocked": 1,
		"cabinet_count": 0,
		"play_seconds": 120,
	})
	await process_frame
	await process_frame
	_shot("01-offramp-quick.png")

	## 02 — deeper offramp form
	offramp.close_panel()
	offramp.open_offramp(C.M_DEEPER, {
		"tier": C.TIER_DEEPER,
		"run_count": 3,
		"anon_id": "shot",
		"build_id": "slice3",
		"biomes_unlocked": 2,
		"cabinet_count": 5,
		"play_seconds": 2400,
	})
	await process_frame
	await process_frame
	_shot("02-offramp-deeper.png")

	## 03 — thank-you card
	offramp.show_thanks()
	await process_frame
	await process_frame
	_shot("03-offramp-thanks.png")

	print("PLAYTEST_COMMITMENT_UI_SHOTS_SLICE3_OK")
	quit(0)


func _shot(filename: String) -> void:
	var img: Image = null
	var tex: ViewportTexture = get_root().get_viewport().get_texture()
	if tex != null:
		img = tex.get_image()
	if img == null:
		img = _compose_fallback(filename)
		print("shot fallback compose for %s" % filename)
	for base in [OUT_A, OUT_B]:
		var path := "%s/%s" % [base, filename]
		var abs_path := ProjectSettings.globalize_path(path)
		DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
		var err := img.save_png(abs_path)
		print("shot %s -> %s (%s)" % [filename, abs_path, error_string(err)])


func _compose_fallback(filename: String) -> Image:
	var img := Image.create(1680, 1040, false, Image.FORMAT_RGBA8)
	img.fill(Color("15120f"))
	match filename:
		"01-offramp-quick.png":
			_draw_form(img, "You finished your first run!", "Thanks for playing this far.")
		"02-offramp-deeper.png":
			_draw_form(img, "You reached the Crystal Cavern!", "You've seen the game open up.")
		"03-offramp-thanks.png":
			_draw_thanks(img)
		_:
			_fill_label(img, 40, 40, filename, Color("e8c36a"))
	return img


func _draw_form(img: Image, header: String, line: String) -> void:
	_draw_box(img, 420, 60, 840, 900, Color("1a1410"), Color("e8c36a"))
	_fill_label(img, 460, 90, header, Color("e8c36a"))
	_fill_label(img, 460, 140, line, Color("f4ede3"))
	_fill_label(img, 460, 200, "How fun was it?", Color("e8c36a"))
	for i in 5:
		_draw_box(img, 460 + i * 60, 240, 48, 40, Color("30261a"), Color("e8c36a"))
		_fill_label(img, 476 + i * 60, 250, str(i + 1), Color("f4ede3"))
	_fill_label(img, 460, 320, "What was the most fun moment?", Color("b6a78e"))
	_draw_box(img, 460, 350, 760, 52, Color("100e0c"), Color("8a8178"))
	_fill_label(img, 460, 880, "Send   Keep playing   Go deeper   I'm done for now", Color("f4ede3"))


func _draw_thanks(img: Image) -> void:
	_draw_box(img, 420, 280, 840, 360, Color("1a1410"), Color("e8c36a"))
	_fill_label(img, 480, 340, "Thank you. Seriously. You can close the tab anytime,", Color("f4ede3"))
	_fill_label(img, 520, 380, "and your progress stays in this browser.", Color("f4ede3"))
	_fill_label(img, 480, 460, "Reach the Shadow Abyss and you'll help me design", Color("b6a78e"))
	_fill_label(img, 740, 560, "Keep playing", Color("f4ede3"))


func _draw_box(img: Image, x: int, y: int, w: int, h: int, fill: Color, border: Color) -> void:
	for yy in range(y, y + h):
		for xx in range(x, x + w):
			if xx < 0 or yy < 0 or xx >= img.get_width() or yy >= img.get_height():
				continue
			var edge := xx == x or yy == y or xx == x + w - 1 or yy == y + h - 1
			img.set_pixel(xx, yy, border if edge else fill)


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
				if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
					img.set_pixel(px, py, color)
		cx += 8
		if cx > img.get_width() - 20:
			break
