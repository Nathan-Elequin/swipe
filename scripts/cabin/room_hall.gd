extends "res://scripts/cabin/cabin_room.gd"
## Trophy hall — hosts TrophyBoard (Package B). Cabin reparents hole/shelf here.
## Package A removes cabinets / Outpost door in parallel; this file stays board-first.


const ROOM_TROPHY := "rooms/room_trophy.png"
const ROOM_HALL := "rooms/room_hall.png"
const NIB_HOST := preload("res://scripts/cabin/nib_host.gd")
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD_DAIS_PATH := "res://assets/ui/trophy/board_dais.png"
## SCREEN §2 / §9 — idle spot right of the board (native). Prefer NIB_HOST.hall_idle_native().
const NIB_IDLE_NATIVE := Vector2(386, 164)

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
var nib: AnimatedSprite2D = null
var board_dais: Control = null
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
	_ensure_board_dais()
	_ensure_depth_layers()
	## Placeholder host name Package A looks for; B attaches the real board.
	if get_node_or_null("TrophyBoard") == null:
		var marker := Label.new()
		marker.name = "TrophyBoard"
		marker.text = ""
		marker.visible = false
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(marker)
	_build_hall_nib()


func _ensure_board_dais() -> void:
	## Named host for future dais art. Dark wood placeholder until Pixel drops the PNG.
	board_dais = get_node_or_null("BoardDais") as Control
	if board_dais == null:
		board_dais = Control.new()
		board_dais.name = "BoardDais"
		add_child(board_dais)
	board_dais.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_dais.z_index = 3
	var outer: Rect2 = MODEL.BOARD_OUTER
	var floor_y: float = MODEL.HALL_FLOOR_Y
	board_dais.position = Vector2(outer.position.x, outer.end.y)
	board_dais.size = Vector2(outer.size.x, maxf(24.0, floor_y - outer.end.y))
	## Clear prior children then load art or placeholder.
	for c in board_dais.get_children():
		c.queue_free()
	if ResourceLoader.exists(BOARD_DAIS_PATH):
		var tr := TextureRect.new()
		tr.name = "BoardDaisArt"
		tr.texture = load(BOARD_DAIS_PATH) as Texture2D
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_dais.add_child(tr)
	else:
		var wood := ColorRect.new()
		wood.name = "BoardDaisPlaceholder"
		wood.color = Color("2a1a12")
		wood.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
		wood.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_dais.add_child(wood)
		var lip := ColorRect.new()
		lip.name = "BoardDaisLip"
		lip.color = Color("3d2818")
		lip.position = Vector2(0, 0)
		lip.size = Vector2(board_dais.size.x, 8)
		lip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board_dais.add_child(lip)


func _build_hall_nib() -> void:
	## Package E: Nib lives here after the first successful return.
	var idle: Vector2 = NIB_HOST.hall_idle_top_left()
	var drawn: Vector2 = NIB_HOST.nib_drawn_size()
	nib = AnimatedSprite2D.new()
	nib.name = "NibSprite"
	nib.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	nib.centered = false
	NIB_HOST.apply_hall_scale(nib)
	nib.position = idle
	## Above depth stand/pools (z 5–7) per depth/LAYERS.md — Nib + dialog sit in front.
	nib.z_index = 8
	var sf := SpriteFrames.new()
	_add_nib_anim(sf, "idle", ["nib/nib_idle_f0.png", "nib/nib_idle_f1.png"], 1.0, true)
	_add_nib_anim(sf, "talk", ["nib/nib_talk_f0.png", "nib/nib_talk_f1.png", "nib/nib_talk_f2.png"], 1000.0 / 90.0, true)
	_add_nib_anim(sf, "gasp", ["nib/nib_gasp.png"], 1.0, false)
	_add_nib_anim(sf, "walk", ["nib/nib_walk_f0.png", "nib/nib_walk_f1.png", "nib/nib_walk_f2.png", "nib/nib_walk_f3.png"], 8.0, true)
	_add_nib_anim(sf, "react", ["nib/nib_react_f0.png", "nib/nib_react_f1.png", "nib/nib_react_f2.png", "nib/nib_react_f3.png"], 10.0, false)
	nib.sprite_frames = sf
	add_child(nib)
	nib.play("idle")
	## Hotspot from layout (or synthesize at idle rect).
	var nib_hot = spots.get("Nib", null)
	if nib_hot == null:
		nib_hot = Control.new()
		nib_hot.name = "Nib"
		nib_hot.position = idle
		nib_hot.size = drawn
		nib_hot.mouse_filter = Control.MOUSE_FILTER_STOP
		nib_hot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		nib_hot.z_index = 8
		nib_hot.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				hotspot_activated.emit("Nib")
		)
		add_child(nib_hot)
		spots["Nib"] = nib_hot
	elif nib_hot is CabinHotspot:
		nib_hot.z_index = 8
		nib_hot.idle_tex = null
		nib_hot.hover_tex = null
		nib_hot.press_tex = null
		nib_hot.texture = null
		nib_hot.position = idle
		nib_hot.size = drawn
	## Hidden until cabin.nib_in_hall (Package E relocation).
	var show_nib: bool = cabin != null and bool(cabin.get("nib_in_hall"))
	nib.visible = show_nib
	if nib_hot is CanvasItem:
		(nib_hot as CanvasItem).visible = show_nib
		if nib_hot is Control and not show_nib:
			(nib_hot as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE


func _add_nib_anim(sf: SpriteFrames, anim: String, rels: Array, fps: float, loop: bool) -> void:
	sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for rel in rels:
		var tex: Texture2D = KIT.load_tex(str(rel))
		if tex:
			sf.add_frame(anim, tex)


func set_nib_in_hall(on: bool) -> void:
	if nib != null:
		nib.visible = on
		if on and nib.sprite_frames:
			nib.play("idle")
	var nib_hot = spots.get("Nib", null)
	if nib_hot is CanvasItem:
		(nib_hot as CanvasItem).visible = on
		if nib_hot is Control:
			(nib_hot as Control).mouse_filter = (
				Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE
			)


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
	_ensure_board_dais()
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
	## Tree order back→front: behind depth → board → dais → front depth → door.
	for spec in DEPTH_BEHIND:
		var n = get_node_or_null(str(spec["name"]))
		if n != null:
			move_child(n, mini(get_child_count() - 1, 1))
	if trophy_board != null and is_instance_valid(trophy_board):
		move_child(trophy_board, -1)
	if board_dais != null and is_instance_valid(board_dais):
		move_child(board_dais, -1)
	for spec in DEPTH_FRONT:
		var n2 = get_node_or_null(str(spec["name"]))
		if n2 != null:
			move_child(n2, -1)
	## Nib in front of stand / light pools (depth LAYERS.md z 7+).
	if nib != null and is_instance_valid(nib):
		move_child(nib, -1)
	var nib_hot2 = spots.get("Nib", null)
	if nib_hot2 is CanvasItem and is_instance_valid(nib_hot2):
		move_child(nib_hot2, -1)
	if back is CabinHotspot:
		(back as CabinHotspot).mouse_filter = Control.MOUSE_FILTER_IGNORE
		if (back as CabinHotspot)._hit:
			(back as CabinHotspot)._hit.mouse_filter = Control.MOUSE_FILTER_STOP
		move_child(back, -1)
