class_name NibHost
extends RefCounted
## Package E — resolve the live Nib host (main or hall) and play react / gasp / talk.
## Cabin owns the save flag; this helper only finds sprites and hotspots.


const KIT := preload("res://scripts/cabin/cabin_kit.gd")
const IDLE_NATIVE := Vector2(386, 172)
const IDLE_PX := Vector2(1544, 688)
const MAIN_IDLE_NATIVE := Vector2(216, 172)


static func room_id(cabin) -> String:
	if cabin != null and bool(cabin.get("nib_in_hall")):
		return "hall"
	return "main"


static func room_node(cabin):
	if cabin == null:
		return null
	var rooms = cabin.get("_rooms")
	if typeof(rooms) != TYPE_DICTIONARY:
		return null
	return rooms.get(room_id(cabin))


static func sprite(cabin) -> AnimatedSprite2D:
	var room = room_node(cabin)
	if room == null:
		return null
	var nib = room.get("nib")
	if nib is AnimatedSprite2D:
		return nib
	return null


static func hotspot(cabin):
	var room = room_node(cabin)
	if room == null:
		return null
	var spots = room.get("spots")
	if typeof(spots) != TYPE_DICTIONARY:
		return null
	return spots.get("Nib", null)


static func talk(cabin, on: bool) -> void:
	var nib := sprite(cabin)
	if nib == null or nib.sprite_frames == null:
		return
	if on:
		nib.play("talk")
		return
	var gate_on := false
	if cabin != null and cabin.has_method("_gate_on"):
		gate_on = bool(cabin.call("_gate_on")) and room_id(cabin) == "main"
	nib.play("psst" if gate_on else "idle")


static func play(cabin, anim: String) -> void:
	var nib := sprite(cabin)
	if nib == null or nib.sprite_frames == null:
		return
	if nib.sprite_frames.has_animation(anim):
		nib.play(anim)


static func react(cabin, sfx = null) -> void:
	## Delighted hop on light / lever ready / gild.
	play(cabin, "react" if _has_anim(cabin, "react") else "talk")
	KIT.cue(sfx, &"nib.react")
	## Fall back to talk briefly if react frames are missing — caller restores idle.


static func gasp(cabin, sfx = null) -> void:
	play(cabin, "gasp")
	KIT.cue(sfx, &"speech.nib_gasp")


static func bubble_anchor_native(cabin) -> Vector2:
	var nib := sprite(cabin)
	if nib == null:
		return MAIN_IDLE_NATIVE if room_id(cabin) == "main" else IDLE_NATIVE
	var px: float = 4.0
	if cabin != null and cabin.get("PX") != null:
		px = float(cabin.PX)
	return Vector2(nib.position.x / px, nib.position.y / px)


static func apply_visibility(cabin) -> void:
	## After the move: hide main Nib; show hall Nib. Before: opposite.
	if cabin == null:
		return
	var rooms = cabin.get("_rooms")
	if typeof(rooms) != TYPE_DICTIONARY:
		return
	var in_hall: bool = bool(cabin.get("nib_in_hall"))
	_set_room_nib_visible(rooms.get("main"), not in_hall)
	_set_room_nib_visible(rooms.get("hall"), in_hall)
	if in_hall:
		_snap_hall_idle(rooms.get("hall"), cabin)


static func _set_room_nib_visible(room, on: bool) -> void:
	if room == null:
		return
	var nib = room.get("nib")
	if nib is CanvasItem:
		(nib as CanvasItem).visible = on
	var spots = room.get("spots")
	if typeof(spots) == TYPE_DICTIONARY:
		var hs = spots.get("Nib", null)
		if hs is CanvasItem:
			(hs as CanvasItem).visible = on
			if hs is Control:
				(hs as Control).mouse_filter = (
					Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
				)


static func _snap_hall_idle(room, cabin) -> void:
	if room == null:
		return
	var px: float = 4.0
	if cabin != null and cabin.get("PX") != null:
		px = float(cabin.PX)
	var nib = room.get("nib")
	if nib is Node2D:
		(nib as Node2D).position = IDLE_NATIVE * px
	var spots = room.get("spots")
	if typeof(spots) == TYPE_DICTIONARY:
		var hs = spots.get("Nib", null)
		if hs is Control:
			(hs as Control).position = IDLE_NATIVE * px


static func _has_anim(cabin, anim: String) -> bool:
	var nib := sprite(cabin)
	return nib != null and nib.sprite_frames != null and nib.sprite_frames.has_animation(anim)
