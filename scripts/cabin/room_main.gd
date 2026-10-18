extends "res://scripts/cabin/cabin_room.gd"
## Front room. Fire / hero / Nib live here; cabin reparents the existing nodes in.

var firefly: AnimatedSprite2D
var nib: AnimatedSprite2D
var prompt: NinePatchRect
var prompt_lab
var gear_layers: Dictionary = {}


func _build_special() -> void:
	firefly = KIT.anim_sprite(
		["props/radio_firefly_f0.png", "props/radio_firefly_f1.png", "props/radio_firefly_f2.png", "props/radio_firefly_f3.png"],
		"fly", 1000.0 / 180.0, true, Vector2(166, 126)
	)
	firefly.z_index = 4
	add_child(firefly)
	if firefly.sprite_frames:
		firefly.play("fly")
	nib = AnimatedSprite2D.new()
	nib.name = "NibSprite"
	nib.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	nib.centered = false
	nib.position = KIT.pt(216, 172)
	nib.z_index = 5
	var sf := SpriteFrames.new()
	_add_anim(sf, "idle", ["nib/nib_idle_f0.png", "nib/nib_idle_f1.png"], 1.0, true)
	_add_anim(sf, "psst", ["nib/nib_psst_f0.png", "nib/nib_psst_f1.png"], 1000.0 / 280.0, true)
	_add_anim(sf, "talk", ["nib/nib_talk_f0.png", "nib/nib_talk_f1.png", "nib/nib_talk_f2.png"], 1000.0 / 90.0, true)
	_add_anim(sf, "point", ["nib/nib_point.png"], 1.0, true)
	_add_anim(sf, "gasp", ["nib/nib_gasp.png"], 1.0, false)
	_add_anim(sf, "walk", ["nib/nib_walk_f0.png", "nib/nib_walk_f1.png", "nib/nib_walk_f2.png", "nib/nib_walk_f3.png"], 8.0, true)
	nib.sprite_frames = sf
	add_child(nib)
	nib.play("idle")
	var nib_hot = spots.get("Nib", null)
	if nib_hot is CabinHotspot:
		nib_hot.z_index = 7
		nib_hot.idle_tex = null
		nib_hot.hover_tex = null
		nib_hot.press_tex = null
		nib_hot.texture = null
	prompt = KIT.nine("ui/dialog_box_9.png", Vector2(8, 8))
	prompt.size = KIT.pt(58, 22)
	prompt.position = KIT.pt(232, 148)
	prompt.z_index = 6
	prompt.visible = false
	prompt.mouse_filter = Control.MOUSE_FILTER_STOP
	prompt.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	prompt.gui_input.connect(_on_prompt_input)
	add_child(prompt)
	prompt_lab = KIT.label("nib.prompt", 18, KIT.INK)
	prompt_lab.set_anchors_preset(PRESET_FULL_RECT)
	prompt_lab.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_lab.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt.add_child(prompt_lab)
	var tw := create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.set_loops()
	tw.tween_property(prompt, "position:y", prompt.position.y - 2.0 * PX, 0.6)
	tw.tween_property(prompt, "position:y", prompt.position.y, 0.6)


func _add_anim(sf: SpriteFrames, anim: String, rels: Array, fps: float, loop: bool) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for rel in rels:
		var tex: Texture2D = KIT.load_tex(str(rel))
		if tex:
			sf.add_frame(anim, tex)


func set_gate(on: bool) -> void:
	prompt.visible = on
	prompt.mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
	if nib and nib.sprite_frames:
		nib.play("psst" if on else "idle")


func _on_prompt_input(event: InputEvent) -> void:
	if not prompt.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hotspot_activated.emit("Nib")
		accept_event()


func _refresh_doors() -> void:
	var hall_open: bool = cabin != null and cabin.is_room_unlocked("hall")
	var side = spots.get("SideDoor", null)
	if side is CabinHotspot:
		side.tag_key = "cabin.hot.door_hall" if hall_open else "cabin.hot.door_locked"
		side.set_locked(not hall_open, KIT.load_tex("doors/side_door_locked.png"))
		if hall_open:
			var closed: Texture2D = KIT.load_tex("doors/side_door_closed.png")
			side.locked_tex = null
			side.hover_tex = KIT.load_tex("doors/side_door_hover.png")
			if side.hover_tex == null:
				side.hover_tex = closed
			side.set_idle_tex(closed)
	_refresh_gear()


func _refresh_gear() -> void:
	if cabin == null:
		return
	var worn: Dictionary = cabin.gear_worn
	for piece in ["helm", "cap", "goggles", "rope"]:
		var n: String = "Gear_%s" % piece
		var hs = spots.get(n, null)
		if hs == null:
			continue
		var slot: String = str(extra.get("gear_slots", {}).get(piece, ""))
		var on: bool = str(worn.get(slot, "")) == piece
		hs.visible = true
		hs.modulate = Color(0.45, 0.45, 0.5, 0.85) if on else Color.WHITE
