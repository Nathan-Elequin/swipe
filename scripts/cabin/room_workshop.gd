extends "res://scripts/cabin/cabin_room.gd"
## Workshop: dummy, Brag-o-Meter, patents, ladder.

var brag_gear: AnimatedSprite2D


func _build_special() -> void:
	## Room art is H-flipped (cabin left chain). Mirror native X for the gear pip.
	brag_gear = KIT.anim_sprite(
		["props/brag_gear_f0.png", "props/brag_gear_f1.png", "props/brag_gear_f2.png", "props/brag_gear_f3.png"],
		"g", 1000.0 / 120.0, true, Vector2(420.0 - 220.0 - 12.0, 116)
	)
	brag_gear.z_index = 4
	add_child(brag_gear)
	if brag_gear.sprite_frames:
		brag_gear.play("g")
	var brag = spots.get("BragOMeter", null)
	if brag is CabinHotspot and brag._hit:
		brag._hit.mouse_entered.connect(func() -> void:
			if brag_gear.sprite_frames:
				brag_gear.sprite_frames.set_animation_speed("g", 1000.0 / 60.0)
		)
		brag._hit.mouse_exited.connect(func() -> void:
			if brag_gear.sprite_frames:
				brag_gear.sprite_frames.set_animation_speed("g", 1000.0 / 120.0)
		)


func _refresh_doors() -> void:
	var loft_open: bool = cabin != null and cabin.is_room_unlocked("loft")
	## Ladder sits on the LEFT after the cabin flip.
	var lad = spots.get("Ladder", null)
	if lad is CabinHotspot:
		lad.tag_key = "cabin.hot.door_loft" if loft_open else "cabin.hot.door_locked"
		lad.set_locked(not loft_open, KIT.load_tex("doors/ladder_locked.png"))
		lad.flip_h = true
		if loft_open:
			lad.locked_tex = null
			lad.hover_tex = KIT.load_tex("doors/ladder_hover.png")
			var opened: Texture2D = KIT.load_tex("doors/ladder_open.png")
			if lad.hover_tex == null:
				lad.hover_tex = opened
			lad.set_idle_tex(opened)
	var back = spots.get("BackDoor", null)
	if back is CabinHotspot:
		back.tag_key = "cabin.hot.back_study"
	var sign = spots.get("SignLoft", null)
	if sign is CanvasItem:
		sign.visible = true
		sign.z_index = 5
