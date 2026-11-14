extends "res://scripts/cabin/cabin_room.gd"
## Trophy hall — hosts TrophyBoard (Package B). Cabin reparents hole/shelf here.
## Package A removes cabinets / Outpost door in parallel; this file stays board-first.


const ROOM_TROPHY := "rooms/room_trophy.png"
const ROOM_HALL := "rooms/room_hall.png"
## SCREEN §2 / §9 — idle spot right of the board (native).
const NIB_IDLE_NATIVE := Vector2(386, 172)

var trophy_board: Control = null
var nib: AnimatedSprite2D = null


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
	## Placeholder host name Package A looks for; B attaches the real board.
	if get_node_or_null("TrophyBoard") == null:
		var marker := Label.new()
		marker.name = "TrophyBoard"
		marker.text = ""
		marker.visible = false
		marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(marker)
	_build_hall_nib()


func _build_hall_nib() -> void:
	## Package E: Nib lives here after the first successful return.
	nib = AnimatedSprite2D.new()
	nib.name = "NibSprite"
	nib.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	nib.centered = false
	nib.position = KIT.pt(NIB_IDLE_NATIVE.x, NIB_IDLE_NATIVE.y)
	nib.z_index = 5
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
		nib_hot.position = KIT.pt(NIB_IDLE_NATIVE.x, NIB_IDLE_NATIVE.y)
		nib_hot.size = KIT.pt(24, 32)
		nib_hot.mouse_filter = Control.MOUSE_FILTER_STOP
		nib_hot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		nib_hot.z_index = 7
		nib_hot.gui_input.connect(func(ev: InputEvent) -> void:
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				hotspot_activated.emit("Nib")
		)
		add_child(nib_hot)
		spots["Nib"] = nib_hot
	elif nib_hot is CabinHotspot:
		nib_hot.z_index = 7
		nib_hot.idle_tex = null
		nib_hot.hover_tex = null
		nib_hot.press_tex = null
		nib_hot.texture = null
		nib_hot.position = KIT.pt(NIB_IDLE_NATIVE.x, NIB_IDLE_NATIVE.y)
		nib_hot.size = KIT.pt(24, 32)
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
	_refresh_doors()


func _refresh_doors() -> void:
	var back = spots.get("BackDoor", null)
	if back is CabinHotspot:
		back.tag_key = "cabin.hot.back_main"
		back.set_locked(false)
	_hide_retired_chrome()
	if back is CanvasItem:
		(back as CanvasItem).z_index = 8
	if back is CabinHotspot:
		(back as CabinHotspot).mouse_filter = Control.MOUSE_FILTER_IGNORE
		if (back as CabinHotspot)._hit:
			(back as CabinHotspot)._hit.mouse_filter = Control.MOUSE_FILTER_STOP
		move_child(back, -1)
	if trophy_board != null and is_instance_valid(trophy_board):
		move_child(trophy_board, -1)
