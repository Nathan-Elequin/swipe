extends "res://scripts/cabin/cabin_room.gd"
## Trophy hall. Cabin reparents _hole / _shelf_host here.
## Doop ship-strip cabinets wall (1680×1040) is the room plate north star.


const CABINETS_WALL := "rooms/cabinets_wall.png"


func _build_special() -> void:
	## Prefer Doop cabinets wall plate when present; else classic room_hall.
	if ResourceLoader.exists(KIT.HOME + CABINETS_WALL):
		_bg_rel = CABINETS_WALL
		_loaded_bg = false
	var flames: Array = extra.get("anchors", {}).get("hall", {}).get("flame", [])
	for f in flames:
		if f is Array and f.size() >= 2:
			_candle(Vector2(float(f[0]), float(f[1])))


func _apply_bg() -> void:
	var plate: Texture2D = KIT.load_tex(CABINETS_WALL)
	if plate:
		bg.texture = plate
		_bg_rel = CABINETS_WALL
		_loaded_bg = true
		return
	bg.texture = KIT.load_tex("rooms/room_hall.png")
	_bg_rel = "rooms/room_hall.png"
	_loaded_bg = bg.texture != null


func _refresh_doors() -> void:
	var study_open: bool = cabin != null and cabin.is_room_unlocked("study")
	var side = spots.get("SideDoor", null)
	if side is CabinHotspot:
		side.tag_key = "cabin.hot.door_study" if study_open else "cabin.hot.door_locked"
		side.set_locked(not study_open, KIT.load_tex("doors/side_door_locked.png"))
		if study_open:
			side.locked_tex = null
			side.hover_tex = KIT.load_tex("doors/side_door_hover.png")
			var closed: Texture2D = KIT.load_tex("doors/side_door_closed.png")
			if side.hover_tex == null:
				side.hover_tex = closed
			side.set_idle_tex(closed)
	var back = spots.get("BackDoor", null)
	if back is CabinHotspot:
		back.tag_key = "cabin.hot.back_main"
	var prev = spots.get("ShelfPrev", null)
	var nxt = spots.get("ShelfNext", null)
	if prev:
		prev.visible = cabin != null and cabin.shelf_page() > 0
	if nxt:
		nxt.visible = cabin != null and cabin.shelf_page() < cabin.shelf_page_max()
