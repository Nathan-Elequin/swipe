extends SceneTree
## Trophy-board layout shots → user://shots/trophy_board/
## Headless cloud uses procedural Image diagrams (dummy renderer has no viewport tex).
## Cherry F5 / gpu headless can still capture the live board when texture is available.


const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const COPY := preload("res://scripts/player_copy.gd")

const OUT_DIR := "user://shots/trophy_board"


func _init() -> void:
	await process_frame
	COPY.reload()
	var rules: Dictionary = SHELL.read_json("res://data/campaign.json")
	var board_data: Dictionary = SHELL.read_json("res://data/content-board.json")
	var items_by_id := {}
	for raw in board_data.get("items", []):
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id != "":
			items_by_id[id] = card
	var faces: Array = MODEL.faces(rules, items_by_id)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	var root := Control.new()
	root.size = Vector2(1680, 1040)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("1e120c")
	root.add_child(bg)
	get_root().add_child(root)

	var scenarios := [
		{"name": "fresh", "state": _state_fresh()},
		{"name": "mid", "state": _state_mid(faces)},
		{"name": "full", "state": _state_full(faces)},
	]
	var shot_i := 0
	for sc in scenarios:
		var state: Dictionary = sc["state"]
		var seen := {}
		for id in state.get("banked", {}).keys():
			seen[str(id)] = true
		if str(sc["name"]) == "mid" and faces.size() > 0:
			for id2 in MODEL.face_ids_flat(faces[0]):
				seen[str(id2)] = true
		var board: TrophyBoard = BOARD.new()
		root.add_child(board)
		board.setup(rules, items_by_id, state, seen, [])
		for fi in faces.size():
			board.slide_to(fi, true)
			await process_frame
			await process_frame
			var path := "%s/%02d_face%d_%s.png" % [OUT_DIR, shot_i + 1, fi + 1, sc["name"]]
			var img: Image = null
			var vp_tex: ViewportTexture = get_root().get_viewport().get_texture()
			if vp_tex != null:
				img = vp_tex.get_image()
			if img == null or img.get_width() < 2:
				img = _diagram(faces[fi], state, seen, str(sc["name"]))
			else:
				if img.get_width() != 1680 or img.get_height() != 1040:
					img.resize(1680, 1040, Image.INTERPOLATE_NEAREST)
			var err := img.save_png(path)
			var src := "diagram"
			if vp_tex != null and img != null and img.get_width() >= 2:
				# Prefer labeling diagram when we fell back; viewport path sets img from vp.
				pass
			print("shot ", path, " err=", err)
			shot_i += 1
		board.queue_free()
		await process_frame
	print("TROPHY_BOARD_SHOTS_OK count=", shot_i)
	quit(0 if shot_i >= 15 else 1)


func _diagram(face: Dictionary, state: Dictionary, seen: Dictionary, scenario: String) -> Image:
	var img := Image.create(1680, 1040, false, Image.FORMAT_RGBA8)
	img.fill(Color("1e120c"))
	## Room plate hint
	_fill_rect(img, Rect2i(0, 0, 1680, 1040), Color("2b1a12"))
	## Board outer
	var outer := MODEL.BOARD_OUTER
	_fill_rect(img, Rect2i(int(outer.position.x), int(outer.position.y), int(outer.size.x), int(outer.size.y)), Color("4a2f1f"))
	## Face viewport / backdrop
	var vp := MODEL.FACE_VIEWPORT
	var slug := str(face.get("slug", "verdant"))
	_fill_rect(img, Rect2i(int(vp.position.x), int(vp.position.y), int(vp.size.x), int(vp.size.y)), _slug_color(slug))
	## Painted placard (approx; feedback-2 uses real placard PNGs in feedback2_shots)
	_fill_rect(img, Rect2i(652, 0, 376, 160), Color("c4a574"))
	## Crest
	_fill_rect(img, Rect2i(240, 144, 96, 96), Color("e8c36a"))
	var locked: bool = MODEL.is_face_locked(
		SHELL.read_json("res://data/campaign.json"),
		state,
		face
	)
	var lit: int = 0 if locked else MODEL.lights_lit(
		SHELL.read_json("res://data/campaign.json"),
		state,
		face,
		[]
	)
	for k in 5:
		var on := k < lit
		_fill_rect(img, Rect2i(672 + k * 72, 164, 48, 64), Color("ffd84a") if on else Color("2b1a12"))
	## Lever (+24 face-local vs pre-feedback-2)
	if not locked:
		var ls: StringName = MODEL.lever_state(SHELL.read_json("res://data/campaign.json"), state, face)
		var lc := Color("8a6a2e")
		if ls == &"ready":
			lc = Color("ffd84a")
		elif ls == &"spent":
			lc = Color("5c3a22")
		_fill_rect(img, Rect2i(1344, 160, 64, 128), lc)
	else:
		_fill_rect(img, Rect2i(760, 400, 160, 192), Color("3a3a3e"))
	## Slots
	var lay: Dictionary = MODEL.layout(face)
	var rects: Dictionary = lay.get("rects", {})
	for id in rects.keys():
		var r: Rect2 = rects[id]
		var st: StringName = &"unseen" if locked else MODEL.slot_state(seen, state, str(id), [])
		var col := Color("100e0c")
		if st == &"seen":
			col = Color("9c978c")
		elif st == &"claimed":
			col = Color("e8c36a")
		_fill_rect(img, Rect2i(int(r.position.x), int(r.position.y), int(r.size.x), int(r.size.y)), col)
	## Dots
	for k in 5:
		var cur := k == int(face.get("index", 0))
		_fill_rect(img, Rect2i(712 + k * 56, 764, 32, 32), Color("ffd84a") if cur else Color("8a6a2e"))
	## Caption strip (debug only — not player-facing board chrome)
	_fill_rect(img, Rect2i(16, 1000, 1648, 28), Color("100e0c"))
	return img


func _fill_rect(img: Image, r: Rect2i, col: Color) -> void:
	var clipped := Rect2i(
		Vector2i(maxi(0, r.position.x), maxi(0, r.position.y)),
		Vector2i(
			mini(1680, r.position.x + r.size.x) - maxi(0, r.position.x),
			mini(1040, r.position.y + r.size.y) - maxi(0, r.position.y)
		)
	)
	if clipped.size.x <= 0 or clipped.size.y <= 0:
		return
	img.fill_rect(clipped, col)


func _slug_color(slug: String) -> Color:
	match slug:
		"verdant":
			return Color("2f5a2a")
		"crystal":
			return Color("2a4a60")
		"ashen":
			return Color("2e2b26")
		"cinder":
			return Color("3a1a10")
		"shadow":
			return Color("140e1e")
		_:
			return Color("2b1a12")


func _state_fresh() -> Dictionary:
	return {"banked": {}, "map_pieces": [], "endless_unlocked": false}


func _state_mid(faces: Array) -> Dictionary:
	var banked := {}
	if faces.is_empty():
		return {"banked": banked, "map_pieces": [], "endless_unlocked": false}
	var f0: Dictionary = faces[0]
	var ids: Array = MODEL.face_ids_flat(f0)
	for i in mini(5, ids.size()):
		banked[str(ids[i])] = "b1"
	var pieces: Array = ["b2"]
	if faces.size() > 1:
		var f1_ids: Array = MODEL.face_ids_flat(faces[1])
		for i in mini(2, f1_ids.size()):
			banked[str(f1_ids[i])] = "b2"
	return {"banked": banked, "map_pieces": pieces, "endless_unlocked": false}


func _state_full(faces: Array) -> Dictionary:
	var banked := {}
	var pieces: Array = []
	for i in faces.size():
		var f: Dictionary = faces[i]
		var pool := str(f.get("pool_id", ""))
		for id in MODEL.face_ids_flat(f):
			banked[str(id)] = pool
		if i + 1 < faces.size():
			pieces.append(str((faces[i + 1] as Dictionary).get("pool_id", "")))
	return {"banked": banked, "map_pieces": pieces, "endless_unlocked": true}
