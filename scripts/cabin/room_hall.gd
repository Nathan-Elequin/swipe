extends "res://scripts/cabin/cabin_room.gd"
## Trophy hall — hosts TrophyBoard (Package B). Cabin reparents hole/shelf here.
## Package A removes cabinets / Outpost door in parallel; this file stays board-first.


const ROOM_TROPHY := "rooms/room_trophy.png"
const ROOM_HALL := "rooms/room_hall.png"
const CABINETS_WALL := "rooms/cabinets_wall.png"

var trophy_board: Control = null


func _build_special() -> void:
	## Prefer new trophy plate when present; else hall / cabinets wall.
	if ResourceLoader.exists(KIT.HOME + ROOM_TROPHY):
		_bg_rel = ROOM_TROPHY
		_loaded_bg = false
	elif ResourceLoader.exists(KIT.HOME + CABINETS_WALL):
		_bg_rel = CABINETS_WALL
		_loaded_bg = false
	var flames: Array = extra.get("anchors", {}).get("hall", {}).get("flame", [])
	for f in flames:
		if f is Array and f.size() >= 2:
			_candle(Vector2(float(f[0]), float(f[1])))
	_hide_retired_chrome()
	_fit_hall_light()
	## Placeholder host name Package A looks for; B attaches the real board.
	if get_node_or_null("TrophyBoard") == null:
		var marker := Label.new()
		marker.name = "TrophyBoard"
		marker.text = ""
		marker.visible = false
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(marker)


func _apply_bg() -> void:
	var plate: Texture2D = KIT.load_tex(ROOM_TROPHY)
	if plate:
		bg.texture = plate
		_bg_rel = ROOM_TROPHY
		_loaded_bg = true
		_fit_hall_light()
		return
	plate = KIT.load_tex(CABINETS_WALL)
	if plate:
		bg.texture = plate
		_bg_rel = CABINETS_WALL
		_loaded_bg = true
		_fit_hall_light()
		return
	bg.texture = KIT.load_tex(ROOM_HALL)
	_bg_rel = ROOM_HALL
	_loaded_bg = bg.texture != null
	_fit_hall_light()


func _fit_hall_light() -> void:
	var g = spots.get("room_hall_glow", null)
	if g is CanvasItem and (_bg_rel == CABINETS_WALL or _bg_rel == ROOM_TROPHY):
		(g as CanvasItem).visible = false


func _hide_retired_chrome() -> void:
	## Shelf arrows + gauge retired. SideDoor stays until Package A removes Outpost.
	for hide_name in ["ShelfPrev", "ShelfNext", "Gauge", "Shelf"]:
		var n = spots.get(hide_name, null)
		if n is CanvasItem:
			(n as CanvasItem).visible = false
		if n is CabinHotspot:
			(n as CabinHotspot).mouse_filter = Control.MOUSE_FILTER_IGNORE
			if (n as CabinHotspot)._hit:
				(n as CabinHotspot)._hit.mouse_filter = Control.MOUSE_FILTER_IGNORE


func attach_trophy_board(board: Control) -> void:
	trophy_board = board
	var marker = get_node_or_null("TrophyBoard")
	if marker != null and marker != board:
		marker.name = "TrophyBoardMarker"
		marker.visible = false
	if board.get_parent() != self:
		if board.get_parent() != null:
			board.get_parent().remove_child(board)
		add_child(board)
	board.name = "TrophyBoard"
	board.z_index = 4
	_refresh_doors()


func _refresh_doors() -> void:
	var mud_open: bool = cabin != null and cabin.is_room_unlocked("hall")
	var side = spots.get("SideDoor", null)
	if side is CabinHotspot:
		side.tag_key = "cabin.hot.door_outpost" if mud_open else "cabin.hot.door_locked"
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
		back.set_locked(false)
	for door_name in ["BackDoor", "SideDoor", "SignOutpost"]:
		var door = spots.get(door_name, null)
		if door is CanvasItem:
			(door as CanvasItem).z_index = 8
		if door is CabinHotspot:
			(door as CabinHotspot).mouse_filter = Control.MOUSE_FILTER_IGNORE
			if (door as CabinHotspot)._hit:
				(door as CabinHotspot)._hit.mouse_filter = Control.MOUSE_FILTER_STOP
			move_child(door, -1)
	if trophy_board != null and is_instance_valid(trophy_board):
		move_child(trophy_board, -1)
	_hide_retired_chrome()
