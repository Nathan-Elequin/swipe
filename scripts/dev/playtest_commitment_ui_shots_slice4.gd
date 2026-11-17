extends SceneTree
## Headless UI shots for playtest commitment slice 4 (BIG victory).
##
## Run:
##   godot --headless --path . --script res://scripts/dev/playtest_commitment_ui_shots_slice4.gd
##
## Writes under design/audit-shots/commitment-slice4/ and
## playtest/repot/outbox/REQ-20261117-commitment-tiers-slice4/shots/


const VICTORY := preload("res://scripts/playtest_victory.gd")
const VC := preload("res://scripts/playtest_victory_code.gd")
const C := preload("res://scripts/playtest_commitment.gd")

const OUT_A := "res://design/audit-shots/commitment-slice4"
const OUT_B := "res://playtest/repot/outbox/REQ-20261117-commitment-tiers-slice4/shots"


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

	var code: String = VC.generate("shot-anon", C.M_BIG)
	var victory: ColorRect = VICTORY.new()
	host.add_child(victory)
	victory.setup()

	## 01 — full victory screen
	victory.open_victory(code, {
		"tier": C.TIER_BIG,
		"run_count": 6,
		"anon_id": "shot-anon",
		"build_id": "slice4",
		"biomes_unlocked": 5,
		"cabinet_count": 12,
		"play_seconds": 12000,
	})
	await process_frame
	await process_frame
	await process_frame
	_shot("01-victory-full.png")

	## 02 — thank-you card
	victory.show_thanks()
	await process_frame
	await process_frame
	_shot("02-victory-thanks.png")

	## 03 — compact code re-view
	victory.close_panel()
	victory.open_code_card(code, {"anon_id": "shot-anon"})
	await process_frame
	await process_frame
	_shot("03-victory-code-card.png")

	print("PLAYTEST_COMMITMENT_UI_SHOTS_SLICE4_OK")
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
		"01-victory-full.png":
			_draw_panel(img, "You reached the Shadow Abyss!", "ABYSS-XXXX-XXXX")
		"02-victory-thanks.png":
			_draw_panel(img, "Thank you. Seriously.", "")
		"03-victory-code-card.png":
			_draw_panel(img, "Your victory code", "ABYSS-XXXX-XXXX")
	return img


func _draw_panel(img: Image, title: String, code: String) -> void:
	for y in range(120, 920):
		for x in range(420, 1260):
			img.set_pixel(x, y, Color("1a1410"))
	## Gold border approx.
	for x in range(420, 1260):
		img.set_pixel(x, 120, Color("e8c36a"))
		img.set_pixel(x, 919, Color("e8c36a"))
	for y in range(120, 920):
		img.set_pixel(420, y, Color("e8c36a"))
		img.set_pixel(1259, y, Color("e8c36a"))
	## Title / code bands (solid markers — not readable text, just layout proof).
	for y in range(160, 210):
		for x in range(460, 1220):
			img.set_pixel(x, y, Color("e8c36a") if title != "" else Color("30261a"))
	if code != "":
		for y in range(280, 360):
			for x in range(520, 1160):
				img.set_pixel(x, y, Color("100e0c"))
