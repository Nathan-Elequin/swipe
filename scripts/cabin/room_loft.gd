extends "res://scripts/cabin/cabin_room.gd"
## Loft: bed (quit), trunk, cat, telescope.

var cat_sleep: AnimatedSprite2D
var new_tag: TextureRect


func _build_special() -> void:
	var flames: Array = extra.get("anchors", {}).get("loft", {}).get("flame", [])
	for f in flames:
		if f is Array and f.size() >= 2:
			_candle(Vector2(float(f[0]), float(f[1])))
	cat_sleep = KIT.anim_sprite(
		["props/cat_sleep_f0.png", "props/cat_sleep_f1.png"],
		"z", 1000.0 / 900.0, true, Vector2(176, 196)
	)
	cat_sleep.z_index = 3
	add_child(cat_sleep)
	if cat_sleep.sprite_frames:
		cat_sleep.play("z")
		var sf: SpriteFrames = cat_sleep.sprite_frames
		if not sf.has_animation("rub"):
			sf.add_animation("rub")
			sf.set_animation_loop("rub", false)
			sf.set_animation_speed("rub", 1000.0 / 180.0)
			for i in 4:
				var tex: Texture2D = KIT.load_tex("props/cat_rub_f%d.png" % i)
				if tex:
					sf.add_frame("rub", tex)
	new_tag = KIT.tex_rect("fx/new_tag.png", Vector2(126, 182), Vector2(16, 10), 5)
	new_tag.visible = false
	add_child(new_tag)


func _refresh_doors() -> void:
	if cabin and cabin.has_method("trunk_has_unread"):
		new_tag.visible = cabin.trunk_has_unread()
	var tr = spots.get("Trunk", null)
	if tr is CabinHotspot and cabin and bool(cabin.get("trunk_open")):
		tr.set_idle_tex(KIT.load_tex("props/trunk_open.png"))
	elif tr is CabinHotspot:
		tr.set_idle_tex(KIT.load_tex("props/trunk.png"))
