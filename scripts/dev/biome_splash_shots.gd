extends SceneTree
## Headless 1680×1040 shots for REQ-20261101-biome-enter-splash.


const OUT_DIR := "res://playtest/repot/outbox/REQ-20261101-biome-enter-splash/shots"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	var COPY = load("res://scripts/player_copy.gd")
	COPY.reload()
	var BiomeSplash = load("res://scripts/ui/biome_splash.gd")
	var splash = BiomeSplash.new()
	root.add_child(splash)
	var ctx := {
		"biome_id": "b1",
		"biome_name": "Verdant Hollow",
		"dungeon_index": 1,
		"delves": 4,
	}
	# Appear fully opaque for the hold shot (skip the dissolve for a clean capture).
	splash._biome_id = "b1"
	splash._ctx = ctx
	splash._build()
	splash._root.modulate.a = 1.0
	splash.visible = true
	await process_frame
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var img1: Image = get_root().get_viewport().get_texture().get_image()
	var path1 := "%s/01-verdant-splash.png" % OUT_DIR
	img1.save_png(path1)
	print("WROTE %s" % path1)

	# Fade out splash; leave a dark play-field stand-in for nest shot.
	await splash.play_out()
	await process_frame
	var bg := ColorRect.new()
	bg.color = Color("0B0706")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(bg)
	var wheel := ColorRect.new()
	wheel.color = Color("1b3a26")
	wheel.size = Vector2(520, 520)
	wheel.position = Vector2((1680 - 520) * 0.5, 120)
	root.add_child(wheel)
	var label := Label.new()
	label.text = "wheel nest rest (placeholder shot — local F5 for live wheel)"
	label.position = Vector2(40, 40)
	label.add_theme_color_override("font_color", Color("EFE0B6"))
	root.add_child(label)
	await process_frame
	await process_frame
	var img2: Image = get_root().get_viewport().get_texture().get_image()
	var path2 := "%s/02-wheel-after-nest.png" % OUT_DIR
	img2.save_png(path2)
	print("WROTE %s" % path2)
	print("SHOTS_OK")
	quit(0)
