extends SceneTree
## Feedback-2 trophy board face shots → design/visual/trophy-board/feedback-2-shots/
## Composites room plate + depth + board chrome + painted placard (headless-safe).


const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const COPY := preload("res://scripts/player_copy.gd")

const OUT_DIR := "res://design/visual/trophy-board/feedback-2-shots"
const USER_OUT := "user://shots/trophy_board_feedback2"


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
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(USER_OUT))

	var state := _state_mid(faces)
	var seen := {}
	for id in state.get("banked", {}).keys():
		seen[str(id)] = true
	if faces.size() > 0:
		for id2 in MODEL.face_ids_flat(faces[0]):
			seen[str(id2)] = true

	var ok := 0
	for fi in faces.size():
		var face: Dictionary = faces[fi]
		var img := _compose(face, state, seen, rules)
		var pool := str(face.get("pool_id", "b%d" % (fi + 1)))
		var slug := str(face.get("slug", "verdant"))
		var fname := "face_%s_%s.png" % [pool, slug]
		var path_res := "%s/%s" % [OUT_DIR, fname]
		var path_user := "%s/%s" % [USER_OUT, fname]
		var err1 := img.save_png(path_res)
		var err2 := img.save_png(path_user)
		print("shot ", path_res, " err=", err1, "/", err2, " size=", img.get_width(), "x", img.get_height())
		if err1 == OK:
			ok += 1
	print("TROPHY_BOARD_FEEDBACK2_SHOTS_OK count=", ok)
	quit(0 if ok >= 5 else 1)


func _compose(face: Dictionary, state: Dictionary, seen: Dictionary, rules: Dictionary) -> Image:
	var img := Image.create(1680, 1040, false, Image.FORMAT_RGBA8)
	img.fill(Color("1e120c"))
	_blit(img, "res://assets/dungeon/home/rooms/room_trophy.png", 0, 0)
	_blit(img, "res://assets/ui/trophy_board/depth/light_pool_wall.png", 0, 0)
	_blit(img, "res://assets/ui/trophy_board/depth/drop_shadow.png", 0, 0)

	var outer := MODEL.BOARD_OUTER
	_blit(img, "res://assets/ui/trophy_board/board_frame.png", int(outer.position.x), int(outer.position.y))

	var slug := str(face.get("slug", "verdant"))
	var vp := MODEL.FACE_VIEWPORT
	_blit(img, "res://assets/ui/trophy_board/face_bg_%s.png" % slug, int(vp.position.x), int(vp.position.y))

	## Crest
	_blit(img, "res://assets/ui/trophy_board/crest_%s.png" % slug, 240, 144)

	var locked: bool = MODEL.is_face_locked(rules, state, face)
	var lit: int = 0 if locked else MODEL.lights_lit(rules, state, face, [])
	for k in 5:
		var light_path := "res://assets/ui/trophy_board/light_on.png" if k < lit else "res://assets/ui/trophy_board/light_off.png"
		_blit(img, light_path, 672 + k * 72, 164)
	if not locked:
		var ls: StringName = MODEL.lever_state(rules, state, face)
		var lever := "lever_locked"
		if ls == &"ready":
			lever = "lever_ready"
		elif ls == &"spent":
			lever = "lever_pulled"
		_blit(img, "res://assets/ui/trophy_board/%s.png" % lever, 1344, 160)
	else:
		_blit(img, "res://assets/ui/trophy_board/padlock.png", 760, 400)

	var lay: Dictionary = MODEL.layout(face)
	var rects: Dictionary = lay.get("rects", {})
	for id in rects.keys():
		var r: Rect2 = rects[id]
		var st: StringName = &"unseen" if locked else MODEL.slot_state(seen, state, str(id), [])
		var recess := "res://assets/ui/trophy_board/slot_recess_dark.png"
		if st == &"claimed":
			recess = "res://assets/ui/trophy_board/slot_recess_lit.png"
		_blit_scaled(img, recess, int(r.position.x), int(r.position.y), int(r.size.x), int(r.size.y))
		if st == &"unseen":
			_fill_rect(img, Rect2i(int(r.position.x) + 16, int(r.position.y) + 16, int(r.size.x) - 32, int(r.size.y) - 32), Color(0.04, 0.03, 0.025, 0.92))
		elif st == &"seen":
			_fill_rect(img, Rect2i(int(r.position.x) + 16, int(r.position.y) + 16, int(r.size.x) - 32, int(r.size.y) - 32), Color(0.45, 0.42, 0.38, 0.85))

	## Painted placard 1:1, centred on x 840, top y 0
	var pool := str(face.get("pool_id", "b1"))
	var placard_path := "res://assets/ui/trophy_board/placard_%s.png" % pool
	var pimg := _load_img(placard_path)
	if pimg != null:
		var pw := pimg.get_width()
		var ph := pimg.get_height()
		var px := 840 - int(pw / 2.0)
		img.blend_rect(pimg, Rect2i(0, 0, pw, ph), Vector2i(px, 0))

	for k in 5:
		var cur := k == int(face.get("index", 0))
		var dot := "res://assets/ui/trophy_board/dot_current.png" if cur else "res://assets/ui/trophy_board/dot_idle.png"
		_blit(img, dot, 712 + k * 56, 764)

	_blit(img, "res://assets/ui/trophy_board/depth/floor_shadow.png", 0, 0)
	_blit(img, "res://assets/ui/trophy_board/depth/light_pool_floor.png", 0, 0)
	_blit(img, "res://assets/ui/trophy_board/depth/bench_stand.png", 0, 0)
	return img


func _blit(dst: Image, path: String, x: int, y: int) -> void:
	var src := _load_img(path)
	if src == null:
		return
	dst.blend_rect(src, Rect2i(0, 0, src.get_width(), src.get_height()), Vector2i(x, y))


func _blit_scaled(dst: Image, path: String, x: int, y: int, w: int, h: int) -> void:
	var src := _load_img(path)
	if src == null:
		return
	var scaled := src.duplicate()
	scaled.resize(w, h, Image.INTERPOLATE_NEAREST)
	dst.blend_rect(scaled, Rect2i(0, 0, w, h), Vector2i(x, y))


func _load_img(path: String) -> Image:
	var abs_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(abs_path):
		return null
	var img := Image.new()
	var err := img.load(abs_path)
	if err != OK:
		return null
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
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


func _state_mid(faces: Array) -> Dictionary:
	var banked := {}
	if faces.is_empty():
		return {"banked": banked, "map_pieces": ["b2", "b3"], "endless_unlocked": false}
	var f0: Dictionary = faces[0]
	for i in mini(5, MODEL.face_ids_flat(f0).size()):
		banked[str(MODEL.face_ids_flat(f0)[i])] = "b1"
	var pieces: Array = ["b2"]
	if faces.size() > 1:
		var f1_ids: Array = MODEL.face_ids_flat(faces[1])
		for i in mini(2, f1_ids.size()):
			banked[str(f1_ids[i])] = "b2"
	return {"banked": banked, "map_pieces": pieces, "endless_unlocked": false}
