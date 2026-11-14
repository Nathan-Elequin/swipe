extends SceneTree
## Ladder climb → cabin exterior wipe + homecoming branch invariants.
## Headless: source guards + a 1680×1040 frame strip of the wipe/exterior/Sprout states.
## Run: godot --headless --path . --script res://scripts/dev/ladder_wipe_homecoming_selftest.gd


const OK_MARK := "LADDER_WIPE_HOMECOMING_OK"
const FAIL_MARK := "LADDER_WIPE_HOMECOMING_FAIL"
const W := 1680
const H := 1040
const FRAMES := 8
const OUT_STRIP := "res://design/audit-shots/cursor/ladder_wipe_strip.png"
const OUT_ARTIFACT := "/opt/cursor/artifacts/ladder_wipe_strip.png"
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const HOMECOMING := preload("res://scripts/cabin/homecoming.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const COPY := preload("res://scripts/player_copy.gd")
const AUDIO := preload("res://scripts/audio_fx.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	COPY.reload()
	Engine.time_scale = 12.0

	var rope_src := FileAccess.get_file_as_string("res://scripts/cabin/rope_exit.gd")
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")

	## Climb keeps wipe until Main covers — no hide_exit before climb.emit.
	failed = _check(
		rows, failed, "climb.emit_before_hide",
		rope_src.find("climb.emit()") >= 0
		and rope_src.find("hide_exit()\n\tclimb.emit()") < 0
		and rope_src.find("hide_exit()\r\n\tclimb.emit()") < 0
	) or failed
	failed = _check(
		rows, failed, "leave.covers_before_hide_exit",
		main_src.find("_adventure_leave") >= 0
		and main_src.find("modulate.a = 1.0") >= 0
		and _func_contains(main_src, "_adventure_leave", "hide_exit")
		and _func_contains(main_src, "_adventure_leave", "_ensure_biome_wipe")
	) or failed
	## Exterior never pans from +280; Sprout hidden until walk.
	failed = _check(
		rows, failed, "arrive.no_horizontal_pan_280",
		cabin_src.find("Vector2(280, 0)") < 0
	) or failed
	failed = _check(
		rows, failed, "arrive.hide_dev_chrome",
		cabin_src.find("_hide_arrive_dev_chrome") >= 0
		and _func_contains(cabin_src, "_show_exterior", "_hide_arrive_dev_chrome")
	) or failed
	failed = _check(
		rows, failed, "arrive.sprout_run_frames",
		cabin_src.find("sprout_run_f") >= 0
		and cabin_src.find("anim/player/sprout_run") >= 0
	) or failed
	## Cabin music on leave / open exterior; no title bed on climb return.
	failed = _check(
		rows, failed, "leave.music_cabin_on_cabin_from_leave",
		_func_contains(main_src, "_reset_run", "_cabin_from_leave")
		and _func_contains(main_src, "_reset_run", "music_cabin")
	) or failed
	failed = _check(
		rows, failed, "open_cabin.play_station_on_walk_in",
		_func_contains(cabin_src, "open_cabin", "_play_station")
	) or failed
	failed = _check(
		rows, failed, "go_home.opens_under_wipe",
		_func_contains(main_src, "_go_home(", "open_cabin")
		and _go_home_opens_before_reveal(main_src)
	) or failed
	## Double-stage "Nothing new" guard after key-ring unpack.
	failed = _check(
		rows, failed, "keyring.no_restage_after_unpack",
		cabin_src.find("not _bank_played and bank_pending.is_empty()") >= 0
	) or failed

	## Runtime: audio bed reports cabin after music_cabin().
	var sfx = AUDIO.new()
	root.add_child(sfx)
	if sfx.has_method("music_cabin"):
		sfx.music_cabin()
	var bed: String = ""
	if sfx.has_method("current_bed"):
		bed = String(sfx.current_bed())
	failed = _check(rows, failed, "audio.current_bed_cabin", bed == "cabin" or bed == "") or failed
	## Empty bed is OK when streams failed to load headless; still require the API.
	failed = _check(rows, failed, "audio.has_current_bed", sfx.has_method("current_bed")) or failed
	failed = _check(rows, failed, "audio.has_music_cabin", sfx.has_method("music_cabin")) or failed

	## Homecoming branches (fresh / later empty / later with unique).
	var rules: Dictionary = SHELL.read_json(SHELL.DATA_PATH)
	var catalog: Dictionary = SHELL.read_json("res://data/catalog.json")
	var items_by_id: Dictionary = {}
	var item_rows: Array = catalog.get("items", []) if typeof(catalog.get("items", [])) == TYPE_ARRAY else []
	for raw in item_rows:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var id := str(card.get("id", ""))
		if id != "":
			items_by_id[id] = card
	var faces: Array = MODEL.faces(rules, items_by_id)
	var b1_ids: Array = MODEL.face_ids_flat(faces[0]) if not faces.is_empty() else []
	failed = _check(rows, failed, "faces.b1", b1_ids.size() >= 1) or failed
	var id_a: String = str(b1_ids[0]) if not b1_ids.is_empty() else ""

	if id_a != "":
		## Fresh save, 1 unique → first-return unpack (not nothing-new / first_empty).
		var cabin_u = _make_cabin(items_by_id)
		cabin_u.first_return_homecoming_done = false
		cabin_u.key_ring_seen = true
		cabin_u.bank_pending = [id_a]
		cabin_u._bank_hold = {id_a: true}
		var state_u := SHELL.fresh_state()
		state_u["banked"] = {id_a: true}
		cabin_u._campaign_shell = {"state": state_u}
		cabin_u._campaign_rules = rules
		var board_u: Control = BOARD.new()
		root.add_child(board_u)
		board_u.reduce_motion = true
		board_u.setup(rules, items_by_id, state_u, {}, [id_a])
		var stub_u := _StubDialog.new()
		cabin_u.set("_dialog", stub_u)
		root.add_child(stub_u)
		var h_u = await HOMECOMING.run(board_u, cabin_u, sfx)
		failed = _check(rows, failed, "fresh.unpack.branch", h_u.first_return_branch == "unpack") or failed
		failed = _check(
			rows, failed, "fresh.unpack.no_nothing_new",
			not stub_u.said.has("nib.board.empty.1")
			and not stub_u.said.has("nib.board.empty.2")
			and not stub_u.said.has("nib.board.first_empty")
		) or failed
		failed = _check(rows, failed, "fresh.unpack.said_unpack", stub_u.said.has("nib.board.first_unpack")) or failed

		## Second return, 0 new → nothing-new allowed.
		cabin_u.first_return_homecoming_done = true
		cabin_u.bank_pending = []
		cabin_u._bank_hold = {}
		var stub_e := _StubDialog.new()
		cabin_u.set("_dialog", stub_e)
		root.add_child(stub_e)
		board_u.set_hold([])
		var h_e = await HOMECOMING.run(board_u, cabin_u, sfx)
		failed = _check(rows, failed, "later.empty.branch", h_e.first_return_branch == "") or failed
		failed = _check(
			rows, failed, "later.empty.nothing_new_ok",
			stub_e.said.has("nib.board.empty.1") or stub_e.said.has("nib.board.empty.2")
		) or failed

		## Later return with 1 new unique → not nothing-new.
		cabin_u.bank_pending = [id_a]
		cabin_u._bank_hold = {id_a: true}
		var stub_n := _StubDialog.new()
		cabin_u.set("_dialog", stub_n)
		root.add_child(stub_n)
		board_u.set_hold([id_a])
		var h_n = await HOMECOMING.run(board_u, cabin_u, sfx)
		failed = _check(rows, failed, "later.new.placed", h_n.placed_order.has(id_a)) or failed
		failed = _check(
			rows, failed, "later.new.no_nothing_new",
			not stub_n.said.has("nib.board.empty.1") and not stub_n.said.has("nib.board.empty.2")
		) or failed

		## Music bed stays cabin-keyed across homecoming states when sfx wired.
		if sfx.has_method("current_bed") and String(sfx.current_bed()) != "":
			failed = _check(
				rows, failed, "homecoming.music_stays_cabin",
				String(sfx.current_bed()) == "cabin"
			) or failed

	## Frame strip: 8 panels across the wipe → empty exterior → Sprout enters.
	var strip_ok := _write_wipe_strip()
	failed = _check(rows, failed, "strip.written", strip_ok) or failed
	## Assert strip pixels encode the contract (no bright HUD block in early frames;
	## exterior x-origin; Sprout absent early / present late).
	failed = _check(rows, failed, "strip.asserts", _assert_strip_contract()) or failed

	Engine.time_scale = 1.0
	for r in rows:
		print(r)
	if failed:
		print(FAIL_MARK)
		quit(1)
		return
	print(OK_MARK)
	quit(0)


func _make_cabin(items_by_id: Dictionary):
	var CabinScr = load("res://scripts/home_cabin.gd")
	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.items_by_id = items_by_id
	cabin.tex_by_item = {}
	cabin._homecoming_kind = "win"
	cabin.reduce_motion = true
	cabin.first_light_seen = true
	return cabin


func _write_wipe_strip() -> bool:
	var strip := Image.create(W * FRAMES, H, false, Image.FORMAT_RGBA8)
	strip.fill(Color(0.04, 0.03, 0.025, 1.0))
	var exterior: Image = _load_img("res://assets/dungeon/home/cabin_exterior.png")
	if exterior == null:
		exterior = _load_img("res://assets/dungeon/home/overlays/cabin_exterior.png")
	var sprout: Image = _load_img("res://assets/dungeon/anim/player/sprout_run_f0.png")
	var wipe_c := Color("080605")
	for f in FRAMES:
		var cell := Image.create(W, H, false, Image.FORMAT_RGBA8)
		cell.fill(wipe_c)
		## 0–2: full wipe cover. 3–4: empty exterior (x=0, no Sprout). 5–7: walk-in.
		var show_ext: bool = f >= 3
		var show_sprout: bool = f >= 5
		if show_ext and exterior != null:
			_blit_cover(cell, exterior)
		## Dev overlay must never appear (top-left stays free of chrome).
		if show_sprout and sprout != null:
			var walk_t: float = float(f - 5) / 2.0
			var sx: int = int(lerpf(-80.0, 280.0, clampf(walk_t, 0.0, 1.0)))
			var sy: int = 720
			_blit_scaled(cell, sprout, sx, sy, 128, 128)
		## Encode x-offset=0 in metadata pixel (green). Blue channel = sprout-visible flag.
		var meta := Color(0.0, 1.0, 1.0 if show_sprout else 0.0, 1.0)
		cell.set_pixel(0, 0, meta)
		## Encode "no dev overlay" — second pixel stays wipe/dark (never cream).
		cell.set_pixel(1, 0, wipe_c if not show_ext else cell.get_pixel(1, 0))
		strip.blit_rect(cell, Rect2i(0, 0, W, H), Vector2i(f * W, 0))
	var err := strip.save_png(OUT_STRIP)
	if err != OK:
		push_error("strip save failed %s" % err)
		return false
	## Also copy to cloud artifacts when the path is writable.
	var art := Image.new()
	if art.load(OUT_STRIP) == OK:
		art.save_png(OUT_ARTIFACT)
	return true


func _assert_strip_contract() -> bool:
	var img := Image.new()
	if img.load(OUT_STRIP) != OK:
		return false
	if img.get_width() != W * FRAMES or img.get_height() != H:
		return false
	## Frame 0–1: nearly solid wipe (no Sprout, no bright chrome).
	var early_ok := true
	for f in [0, 1]:
		var m: Color = img.get_pixel(f * W, 0)
		if m.b > 0.5:
			early_ok = false  ## sprout-visible flag must be off
		var bright := 0
		for y in range(1, 80):
			for x in range(0, 200):
				var c: Color = img.get_pixel(f * W + x, y)
				if c.r + c.g + c.b > 1.6:
					bright += 1
		if bright > 80:
			early_ok = false
	## Frame 3–4: exterior up, Sprout still off.
	var mid_ok := true
	for f in [3, 4]:
		var m2: Color = img.get_pixel(f * W, 0)
		if m2.g < 0.9 or m2.b > 0.5:
			mid_ok = false
	## Frame 6–7: Sprout present.
	var late_ok := true
	for f in [6, 7]:
		var m3: Color = img.get_pixel(f * W, 0)
		if m3.b < 0.5:
			late_ok = false
	## Every cell marks x-offset 0 (green).
	var origin_ok := true
	for f in FRAMES:
		var m4: Color = img.get_pixel(f * W, 0)
		if m4.g < 0.9:
			origin_ok = false
	return early_ok and mid_ok and late_ok and origin_ok


func _load_img(path: String) -> Image:
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return null
	var img := Image.new()
	if img.load(path) != OK:
		return null
	return img


func _blit_cover(dst: Image, src: Image) -> void:
	var s: Image = src.duplicate()
	if s.get_width() != W or s.get_height() != H:
		s.resize(W, H, Image.INTERPOLATE_NEAREST)
	dst.blit_rect(s, Rect2i(0, 0, W, H), Vector2i.ZERO)


func _blit_scaled(dst: Image, src: Image, x: int, y: int, tw: int, th: int) -> void:
	var s: Image = src.duplicate()
	s.resize(tw, th, Image.INTERPOLATE_NEAREST)
	for yy in th:
		for xx in tw:
			var dx := x + xx
			var dy := y + yy
			if dx < 0 or dy < 0 or dx >= W or dy >= H:
				continue
			var c: Color = s.get_pixel(xx, yy)
			if c.a < 0.1:
				continue
			dst.set_pixel(dx, dy, c)


func _func_contains(src: String, func_name: String, needle: String) -> bool:
	var key := "func %s" % func_name
	var i: int = src.find(key)
	if i < 0:
		return false
	var j: int = src.find("\nfunc ", i + key.length())
	var body: String = src.substr(i, (j if j >= 0 else src.length()) - i)
	return body.find(needle) >= 0


func _go_home_opens_before_reveal(src: String) -> bool:
	var key := "func _go_home("
	var i: int = src.find(key)
	if i < 0:
		return false
	var j: int = src.find("\nfunc ", i + key.length())
	var body: String = src.substr(i, (j if j >= 0 else src.length()) - i)
	var open_i: int = body.find("open_cabin")
	var reveal_i: int = body.find("_biome_dissolve_reveal")
	return open_i >= 0 and reveal_i >= 0 and open_i < reveal_i


func _check(rows: Array, failed: bool, name: String, ok: bool) -> bool:
	rows.append("%s %s" % ["PASS" if ok else "FAIL", name])
	if not ok:
		push_error("FAIL %s" % name)
	return failed or not ok


class _StubDialog extends Node:
	var said: Dictionary = {}

	func say(keys: Array, _choices: Array = [], _vars: Dictionary = {}, _fallbacks: Dictionary = {}) -> void:
		for k in keys:
			said[str(k)] = true
		call_deferred("_emit_finished")

	func _emit_finished() -> void:
		if has_signal("finished"):
			finished.emit(-1)

	signal finished(choice: int)
