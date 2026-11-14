extends "res://scripts/cabin/cabin_room.gd"
## Trophy hall — hosts TrophyBoard (Package B). Cabin reparents hole/shelf here.
## Package A removes cabinets / Outpost door in parallel; this file stays board-first.


const ROOM_TROPHY := "rooms/room_trophy.png"
const ROOM_HALL := "rooms/room_hall.png"

## Depth layers (full 1680×1040 plates). See assets/ui/trophy_board/depth/LAYERS.md.
const DEPTH_BEHIND := [
	{"name": "LightPoolWall", "rel": "trophy_board/depth/light_pool_wall", "z": 1},
	{"name": "DropShadow", "rel": "trophy_board/depth/drop_shadow", "z": 2},
]
const DEPTH_FRONT := [
	{"name": "FloorShadow", "rel": "trophy_board/depth/floor_shadow", "z": 5},
	{"name": "LightPoolFloor", "rel": "trophy_board/depth/light_pool_floor", "z": 6},
	{"name": "BenchStand", "rel": "trophy_board/depth/bench_stand", "z": 7},
]

var trophy_board: Control = null
var _depth_nodes: Array = []


func _build_special() -> void:
	## Prefer new trophy plate when present; else hall / cabinets wall.
	if ResourceLoader.exists(KIT.HOME + ROOM_TROPHY):
		_bg_rel = ROOM_TROPHY
		_loaded_bg = false
	var flames: Array = extra.get("anchors", {}).get("hall", {}).get("flame", [])
	for f in flames:
		if f is Array and f.size() >= 2:
			_candle(Vector2(float(f[0]), float(f[1])))
	_hide_retired_chrome()
	_fit_hall_light()
	_ensure_depth_layers()
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
	bg.texture = KIT.load_tex(ROOM_HALL)
	_bg_rel = ROOM_HALL
	_loaded_bg = bg.texture != null
	_fit_hall_light()


func _fit_hall_light() -> void:
	var g = spots.get("room_hall_glow", null)
	if g is CanvasItem and _bg_rel == ROOM_TROPHY:
		(g as CanvasItem).visible = false


func _hide_retired_chrome() -> void:
	## Shelf chrome + Outpost right door retired (Package A).
	for hide_name in ["ShelfPrev", "ShelfNext", "Gauge", "Shelf", "SideDoor", "SignOutpost"]:
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
	_ensure_depth_layers()
	_refresh_doors()


func _ensure_depth_layers() -> void:
	## Wall wash + drop shadow behind the board; floor shadow/pool + stand in front.
	for spec in DEPTH_BEHIND + DEPTH_FRONT:
		var n: String = str(spec["name"])
		var node: Control = get_node_or_null(n) as Control
		if node == null:
			node = _make_depth_plate(n, str(spec["rel"]))
			add_child(node)
			_depth_nodes.append(node)
		node.z_index = int(spec["z"])
		if node is TextureRect:
			(node as TextureRect).visible = (node as TextureRect).texture != null
	## Stand feet + contact shadow must read on the boards (y 804–855), above the rug.
	## If a future room plate shifts the rug up, nudge the stand plate so feet stay visible.
	var stand := get_node_or_null("BenchStand") as Control
	if stand != null:
		stand.position = Vector2.ZERO
		## Feet authored to screen y ~804–848; keep plate pinned at origin.


func _make_depth_plate(p_name: String, rel: String) -> TextureRect:
	var tr := TextureRect.new()
	tr.name = p_name
	tr.position = Vector2.ZERO
	tr.size = Vector2(1680, 1040)
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tex: Texture2D = KIT.ui_tex(rel)
	if tex != null:
		tr.texture = tex
	return tr


func _refresh_doors() -> void:
	var back = spots.get("BackDoor", null)
	if back is CabinHotspot:
		back.tag_key = "cabin.hot.back_main"
		back.set_locked(false)
	_hide_retired_chrome()
	if back is CanvasItem:
		(back as CanvasItem).z_index = 8
	## Tree order back→front: behind depth → board → front depth → door.
	for spec in DEPTH_BEHIND:
		var n = get_node_or_null(str(spec["name"]))
		if n != null:
			move_child(n, mini(get_child_count() - 1, 1))
	if trophy_board != null and is_instance_valid(trophy_board):
		move_child(trophy_board, -1)
	for spec in DEPTH_FRONT:
		var n2 = get_node_or_null(str(spec["name"]))
		if n2 != null:
			move_child(n2, -1)
	if back is CabinHotspot:
		(back as CabinHotspot).mouse_filter = Control.MOUSE_FILTER_IGNORE
		if (back as CabinHotspot)._hit:
			(back as CabinHotspot)._hit.mouse_filter = Control.MOUSE_FILTER_STOP
		move_child(back, -1)
