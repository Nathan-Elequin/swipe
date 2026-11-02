extends SceneTree
## Headless 1680×1040 splash stills for REQ-20261101-biome-splash-all5.
## One still per tip biome (01–05). Ambient kit hosted on splash when available.


const OUT_DIR := "res://playtest/repot/outbox/REQ-20261101-biome-splash-all5/shots"

const BIOMES := [
	{"id": "b1", "name": "Verdant Hollow", "file": "01-verdant-splash.png"},
	{"id": "b2", "name": "Crystal Cavern", "file": "02-crystal-splash.png"},
	{"id": "b3", "name": "Ashen Crypt", "file": "03-ashen-splash.png"},
	{"id": "b4", "name": "Cinder Forge", "file": "04-cinder-splash.png"},
	{"id": "b5", "name": "Shadow Abyss", "file": "05-shadow-splash.png"},
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1680, 1040))
	await process_frame
	var COPY = load("res://scripts/player_copy.gd")
	COPY.reload()
	var BiomeSplash = load("res://scripts/ui/biome_splash.gd")
	var Ambient = load("res://scripts/fx/biome_ambient.gd")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	var amb_home := Node2D.new()
	root.add_child(amb_home)
	var amb = Ambient.new()
	amb_home.add_child(amb)
	amb.setup(Vector2(1680, 1040))
	amb.set_enabled(true)

	for b in BIOMES:
		var bid: String = str(b["id"])
		var bname: String = str(b["name"])
		var fname: String = str(b["file"])
		amb.set_biome(bid)
		var splash = BiomeSplash.new()
		root.add_child(splash)
		var ctx := {
			"biome_id": bid,
			"biome_name": bname,
			"dungeon_index": int(bid.substr(1)),
			"delves": 4,
		}
		# Appear fully opaque for the hold shot (skip the dissolve for a clean capture).
		splash._biome_id = bid
		splash._ctx = ctx
		splash._build()
		splash.attach_ambient(amb)
		splash._root.modulate.a = 1.0
		splash.visible = true
		await process_frame
		await process_frame
		var path := "%s/%s" % [OUT_DIR, fname]
		var vp_tex: ViewportTexture = get_root().get_viewport().get_texture()
		var img: Image = vp_tex.get_image() if vp_tex != null else null
		if img == null:
			print("SKIP_SHOT %s (no viewport image in this headless renderer) ambient_amount=%s" % [
				path, amb.total_particle_amount()
			])
		else:
			img.save_png(path)
			print("WROTE %s ambient_amount=%s" % [path, amb.total_particle_amount()])
		splash.detach_ambient()
		splash.queue_free()
		await process_frame

	print("SHOTS_OK biome_splash_all5")
	quit(0)
