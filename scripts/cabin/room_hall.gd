extends "res://scripts/cabin/cabin_room.gd"
## Trophy hall. Cabin reparents _hole / _shelf_host here.
## Doop ship-strip cabinets wall (1680×1040) is the room plate north star.
## Live biome overlays are hit-only + slot icons — no second case frames.


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
	_hide_retired_chrome()


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


func _hide_retired_chrome() -> void:
	## Shelf page arrows + gauge retired (five fixed plate cases).
	## SignStudy is wrong for the right door (now Outpost) — hide until Spin/Pixel replace it.
	for hide_name in ["ShelfPrev", "ShelfNext", "Gauge", "SignStudy"]:
		var n = spots.get(hide_name, null)
		if n is CanvasItem:
			(n as CanvasItem).visible = false
		if n is CabinHotspot:
			(n as CabinHotspot).mouse_filter = Control.MOUSE_FILTER_IGNORE
			if (n as CabinHotspot)._hit:
				(n as CabinHotspot)._hit.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _refresh_doors() -> void:
	var mud_open: bool = cabin != null and cabin.is_room_unlocked("hall")
	## Right door → Outpost (mudroom). Unlocks with the hall.
	var side = spots.get("SideDoor", null)
	if side is CabinHotspot:
		side.tag_key = "room.mudroom.name" if mud_open else "cabin.hot.door_locked"
		side.set_locked(not mud_open, KIT.load_tex("doors/side_door_locked.png"))
		if mud_open:
			side.locked_tex = null
			side.hover_tex = KIT.load_tex("doors/side_door_hover.png")
			var closed: Texture2D = KIT.load_tex("doors/side_door_closed.png")
			if side.hover_tex == null:
				side.hover_tex = closed
			side.set_idle_tex(closed)
	var back = spots.get("BackDoor", null)
	if back is CabinHotspot:
		back.tag_key = "cabin.hot.back_main"
	_hide_retired_chrome()
