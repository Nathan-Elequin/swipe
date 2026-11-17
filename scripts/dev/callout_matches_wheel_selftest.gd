extends SceneTree
## Headless: fight callout idle matches wheel seat (source, framing, timing).
## Run: godot --headless --path . --script res://scripts/dev/callout_matches_wheel_selftest.gd
## Does not boot main.gd.

const ART := preload("res://scripts/dungeon_art.gd")
const STAGE := preload("res://scripts/combat_stage.gd")
const WHEEL := preload("res://scripts/boss_wheel.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var art = ART.new()
	art.setup()
	var failed := false
	var failing_ids: Array[String] = []
	var cat_path := "res://data/catalog.json"
	if not FileAccess.file_exists(cat_path):
		push_error("missing catalog.json")
		quit(1)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(cat_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("catalog.json is not an object")
		quit(1)
		return
	var monsters: Array = (parsed as Dictionary).get("monsters", [])
	var all_wheel: Dictionary = art.wheel_frames_all()
	var checked := 0

	failed = _check("idle_frame_sec", is_equal_approx(ART.IDLE_FRAME_SEC, 0.2)) or failed

	for row in monsters:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var id: String = str((row as Dictionary).get("id", "")).strip_edges()
		if id == "":
			continue
		var seat: Array = art.monster_seat_frames(id)
		if seat.is_empty():
			continue
		var portrait: Array = art.monster_portrait_frames(id)
		var wheel_arr: Array = all_wheel.get(id, [])
		var ok_sizes := (
			portrait.size() == seat.size()
			and seat.size() == wheel_arr.size()
			and seat.size() > 0
		)
		if not ok_sizes:
			print("FAIL size_%s portrait=%s seat=%s wheel=%s" % [
				id, portrait.size(), seat.size(), wheel_arr.size()
			])
			failed = true
			failing_ids.append(id)
			continue
		var px_ok := _portrait_matches_seat(art, id, portrait, seat)
		if not px_ok:
			print("FAIL pixels_%s" % id)
			failed = true
			failing_ids.append(id)
			continue
		var place_ok := _placement_stable(art, id)
		if not place_ok:
			print("FAIL place_%s" % id)
			failed = true
			failing_ids.append(id)
			continue
		checked += 1
		print("PASS ", id)

	failed = _check("checked_at_least_1", checked >= 1) or failed
	failed = _seat_index_matches_wheel_tex(art) or failed

	if failed:
		print("CALLOUT_WHEEL_MATCH_FAIL ids=%s checked=%s" % [",".join(failing_ids), checked])
		quit(1)
	else:
		print("CALLOUT_WHEEL_MATCH_OK checked=%s" % checked)
		quit(0)


func _portrait_matches_seat(art, id: String, portrait: Array, seat: Array) -> bool:
	var expected: Array = _knock_union_crop(seat)
	if expected.size() != portrait.size():
		return false
	for i in portrait.size():
		var a: Texture2D = portrait[i] as Texture2D
		var b: Texture2D = expected[i] as Texture2D
		if a == null or b == null:
			return false
		var ia: Image = a.get_image()
		var ib: Image = b.get_image()
		if ia == null or ib == null:
			return false
		if ia.get_width() != ib.get_width() or ia.get_height() != ib.get_height():
			return false
		if ia.get_data() != ib.get_data():
			return false
	return true


func _knock_union_crop(src: Array) -> Array:
	var imgs: Array = []
	for t in src:
		if t == null:
			continue
		var img: Image = (t as Texture2D).get_image()
		if img == null:
			continue
		img = img.duplicate()
		_knock_backdrop(img)
		imgs.append(img)
	if imgs.is_empty():
		return []
	var union := Rect2i()
	var have := false
	for img in imgs:
		var used: Rect2i = img.get_used_rect()
		if used.size.x < 1 or used.size.y < 1:
			continue
		union = used if not have else union.merge(used)
		have = true
	if not have:
		return []
	var out: Array = []
	for img in imgs:
		var region: Rect2i = union.intersection(Rect2i(Vector2i.ZERO, img.get_size()))
		if region.size.x < 1 or region.size.y < 1:
			region = Rect2i(Vector2i.ZERO, img.get_size())
		out.append(ImageTexture.create_from_image(img.get_region(region)))
	return out


func _knock_backdrop(img: Image) -> void:
	# Mirror dungeon_art._knock_backdrop exactly.
	var w: int = img.get_width()
	var h: int = img.get_height()
	if w < 4 or h < 4:
		return
	var seed: Color = img.get_pixel(0, 0)
	if seed.a < 0.2:
		return
	var sat: float = maxf(seed.r, maxf(seed.g, seed.b)) - minf(seed.r, minf(seed.g, seed.b))
	if sat > 0.18:
		return
	var tol := 0.14
	var stack: Array[Vector2i] = [Vector2i(0, 0), Vector2i(w - 1, 0), Vector2i(0, h - 1), Vector2i(w - 1, h - 1)]
	var seen := {}
	var clear := Color(0, 0, 0, 0)
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h:
			continue
		var key: int = p.x + p.y * w
		if seen.has(key):
			continue
		var c: Color = img.get_pixel(p.x, p.y)
		if c.a < 0.15:
			seen[key] = true
			continue
		if absf(c.r - seed.r) > tol or absf(c.g - seed.g) > tol or absf(c.b - seed.b) > tol:
			continue
		seen[key] = true
		img.set_pixel(p.x, p.y, clear)
		stack.append(p + Vector2i(1, 0))
		stack.append(p + Vector2i(-1, 0))
		stack.append(p + Vector2i(0, 1))
		stack.append(p + Vector2i(0, -1))


func _placement_stable(art, id: String) -> bool:
	for sz in [Vector2(280, 216), Vector2(280, 160), Vector2(280, 96)]:
		var stage = STAGE.new()
		root.add_child(stage)
		stage.setup(art)
		stage.size = sz
		stage.custom_minimum_size = sz
		stage.show_monster(id, 1)
		if stage._idle.is_empty():
			stage.queue_free()
			return false
		var sizes: Array = []
		var xs: Array = []
		var feet: Array = []
		for i in stage._idle.size():
			stage._fi = float(i)
			stage._place_sprite()
			sizes.append(stage._sprite.size)
			xs.append(stage._sprite.position.x)
			feet.append(stage._sprite.position.y + stage._sprite.size.y)
		stage.queue_free()
		for i in range(1, sizes.size()):
			if sizes[i] != sizes[0]:
				return false
			if not is_equal_approx(float(xs[i]), float(xs[0])):
				return false
			if not is_equal_approx(float(feet[i]), float(feet[0])):
				return false
	return true


func _seat_index_matches_wheel_tex(art) -> bool:
	var failed := false
	var wheel = WHEEL.new()
	root.add_child(wheel)
	var frames: Array = art.monster_seat_frames("goblin")
	if frames.is_empty():
		frames = art.monster_wheel_frames("goblin")
	if frames.is_empty():
		print("FAIL seat_index_no_goblin_frames")
		wheel.queue_free()
		return true
	wheel.tex_wheel_frames = {"goblin": frames}
	wheel.slices = [{"card_id": "goblin", "hp": 3, "kind": "monster"}]
	wheel.facing_index = 0
	wheel.spinning = false
	wheel.hover_index = -1
	for t in [0.0, 0.15, 0.25, 0.55, 1.1, 2.4]:
		wheel._glow_t = t
		var idx: int = wheel.seat_frame_index(0)
		var tex: Texture2D = wheel._wheel_tex(0)
		if idx < 0:
			failed = _check("seat_index_t_%s" % t, false) or failed
			continue
		var expect: Texture2D = frames[idx] as Texture2D
		failed = _check("seat_index_tex_t_%s" % t, tex == expect) or failed
	# Shared const used by callout path.
	failed = _check("shared_idle_sec", is_equal_approx(ART.IDLE_FRAME_SEC, 0.2)) or failed
	wheel.queue_free()
	return failed


func _check(label: String, ok: bool) -> bool:
	if ok:
		print("PASS ", label)
		return false
	print("FAIL ", label)
	return true
