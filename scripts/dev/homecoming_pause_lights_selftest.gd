extends SceneTree
## Loss / first-look homecoming: tree unpaused when cabin idle; arch lights stay 0
## until an item actually lands (Nathan: light never before item arrives).
##
## Run: godot --headless --path . --script res://scripts/dev/homecoming_pause_lights_selftest.gd


const OK_MARK := "HOMECOMING_PAUSE_LIGHTS_OK"
const FAIL_MARK := "HOMECOMING_PAUSE_LIGHTS_FAIL"
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const HOMECOMING := preload("res://scripts/cabin/homecoming.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	Engine.time_scale = 12.0

	var rules: Dictionary = SHELL.read_json(SHELL.DATA_PATH)
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
	failed = _check(rows, failed, "faces.ok", faces.size() >= 1) or failed
	if faces.is_empty():
		_finish(failed, rows)
		return
	var b1_ids: Array = MODEL.face_ids_flat(faces[0])
	failed = _check(rows, failed, "b1.ids", b1_ids.size() >= 1) or failed

	var CabinScr = load("res://scripts/home_cabin.gd")

	## --- Source contracts ---
	var main_src := FileAccess.get_file_as_string("res://scripts/main.gd")
	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	var board_src := FileAccess.get_file_as_string("res://scripts/cabin/trophy_board.gd")
	var model_src := FileAccess.get_file_as_string("res://scripts/cabin/trophy_board_model.gd")
	failed = _check(rows, failed, "src.refresh_no_repause_open_cabin",
		main_src.find("cabin_already_open") >= 0
		and main_src.find("do NOT re-pause here") >= 0, "") or failed
	failed = _check(rows, failed, "src.go_home_pause_before_dissolve",
		_func_contains(main_src, "_go_home(", "Pause immediately so arrive owns")
		and _go_home_pauses_before_dissolve(main_src), "") or failed
	## Give up / limp home must clear SceneTree.paused before dissolve / cabin arrive.
	failed = _check(rows, failed, "src.give_up_clears_pause",
		_func_contains(main_src, "_give_up(", "get_tree().paused = false")
		and _func_contains(main_src, "_go_home_loss(", "get_tree().paused = false"), "") or failed
	failed = _check(rows, failed, "src.dissolve_out_runs_while_paused",
		_func_contains(main_src, "_biome_dissolve_out(", "TWEEN_PAUSE_PROCESS"), "") or failed
	var settings_src := FileAccess.get_file_as_string("res://scripts/settings_menu.gd")
	failed = _check(rows, failed, "src.give_up_yes_drops_keep_paused",
		_func_contains(settings_src, "_on_give_up_yes(", "_keep_paused = false"), "") or failed
	failed = _check(rows, failed, "src.idle_pause_guard",
		cabin_src.find("func _guard_cabin_idle_unpaused") >= 0, "") or failed
	failed = _check(rows, failed, "src.board_landed",
		board_src.find("var _landed") >= 0
		and board_src.find("func lights_lit_count") >= 0, "") or failed
	failed = _check(rows, failed, "src.model_landed_arg",
		model_src.find("landed = null") >= 0
		or model_src.find("landed=null") >= 0, "") or failed

	## --- Model: landed-only lights; banked+held without landed → 0 ---
	var id0 := str(b1_ids[0])
	var state := {"banked": {id0: "b1"}, "map_pieces": ["b1"], "endless_unlocked": false}
	failed = _check(rows, failed, "model.held_subtracts",
		MODEL.lights_lit(rules, state, faces[0], [id0]) == 0, "") or failed
	failed = _check(rows, failed, "model.landed_empty",
		MODEL.lights_lit(rules, state, faces[0], [], {}) == 0, "") or failed
	failed = _check(rows, failed, "model.landed_one",
		MODEL.lights_lit(rules, state, faces[0], [], {id0: true}) == 1, "") or failed
	## Banked without landed dict still uses legacy banked−held (compat).
	failed = _check(rows, failed, "model.legacy_banked",
		MODEL.lights_lit(rules, state, faces[0], []) == 1, "") or failed

	## --- Board: banked+hold → 0 lights until place_claimed ---
	var board: TrophyBoard = BOARD.new()
	root.add_child(board)
	board.reduce_motion = true
	board.setup(rules, items_by_id, state, {}, [id0])
	await process_frame
	failed = _check(rows, failed, "board.preland_lights0",
		board.lights_lit_count(0) == 0,
		"lit=%s landed=%s" % [board.lights_lit_count(0), str(board.landed_ids())]) or failed
	board.place_claimed(id0, false)
	await process_frame
	failed = _check(rows, failed, "board.postland_lights1",
		board.lights_lit_count(0) == 1,
		"lit=%s" % board.lights_lit_count(0)) or failed

	## --- Loss / first-look empty: first_look+first_empty, 0 lights, pause guard ---
	var cabin = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set_process(true)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.items_by_id = items_by_id
	cabin.tex_by_item = {}
	cabin._campaign_rules = rules
	cabin.reduce_motion = true
	cabin._homecoming_kind = "loss"
	cabin.first_return_homecoming_done = false
	cabin.first_light_seen = true
	cabin._bank_played = false
	cabin.bank_pending = []
	cabin._bank_hold = {}
	cabin._new_ids = []
	cabin._beat = "idle"
	var empty_state := SHELL.fresh_state()
	empty_state["banked"] = {}
	empty_state["map_pieces"] = ["b1"]
	cabin._campaign_shell = {"state": empty_state}
	var board2: TrophyBoard = BOARD.new()
	root.add_child(board2)
	board2.reduce_motion = true
	board2.setup(rules, items_by_id, empty_state, {}, [])
	cabin._trophy_board = board2
	var stub := _StubDialog.new()
	cabin.set("_dialog", stub)
	root.add_child(stub)

	paused = true
	var h = await HOMECOMING.run(board2, cabin, null)
	failed = _check(rows, failed, "loss.first_return_branch_empty",
		str(h.first_return_branch) == "empty",
		"branch=%s" % h.first_return_branch) or failed
	failed = _check(rows, failed, "loss.said_first_look",
		stub.said.has("nib.board.first_look"),
		"said=%s" % str(stub.said.keys())) or failed
	failed = _check(rows, failed, "loss.said_first_empty",
		stub.said.has("nib.board.first_empty"),
		"said=%s" % str(stub.said.keys())) or failed
	failed = _check(rows, failed, "loss.no_loss_line_on_first",
		not stub.said.has("nib.home.loss.1")
		and not stub.said.has("nib.home.loss.2")
		and not stub.said.has("nib.home.loss.3"),
		"said=%s" % str(stub.said.keys())) or failed
	failed = _check(rows, failed, "loss.lights0",
		board2.lights_lit_count(0) == 0,
		"lit=%s" % board2.lights_lit_count(0)) or failed
	failed = _check(rows, failed, "loss.placed_empty",
		h.placed_order.is_empty(), "") or failed

	## Simulate stuck pause after ceremony; idle guard must clear it.
	cabin.visible = true
	cabin._beat = "idle"
	cabin._arriving = false
	cabin._bank_busy = false
	cabin._homecoming_bank_staging = false
	cabin._room_busy = false
	cabin._pan_busy = false
	cabin._overlay_name = ""
	paused = true
	cabin.call("_guard_cabin_idle_unpaused")
	failed = _check(rows, failed, "pause.guard_releases_idle",
		paused == false, "paused=%s" % paused) or failed

	## Title _refresh must not re-pause an already-open cabin (source + helper).
	paused = false
	cabin.call("_release_cabin_tree_pause")
	failed = _check(rows, failed, "pause.release_helper",
		paused == false, "") or failed

	## Banked credit still in hold / pending must not light before land (fresh board).
	var board3: TrophyBoard = BOARD.new()
	root.add_child(board3)
	board3.reduce_motion = true
	var pending_state := {"banked": {id0: "b1"}, "map_pieces": ["b1"]}
	board3.setup(rules, items_by_id, pending_state, {}, [id0])
	failed = _check(rows, failed, "pending.lights0_before_land",
		board3.lights_lit_count(0) == 0,
		"lit=%s landed=%s" % [board3.lights_lit_count(0), str(board3.landed_ids())]) or failed

	Engine.time_scale = 1.0
	_finish(failed, rows)


func _func_contains(src: String, func_name: String, needle: String) -> bool:
	var key := "func %s" % func_name
	var start: int = src.find(key)
	if start < 0:
		return false
	var nxt: int = src.find("\nfunc ", start + key.length())
	var body: String = src.substr(start, nxt - start if nxt >= 0 else src.length() - start)
	return body.find(needle) >= 0


func _go_home_pauses_before_dissolve(src: String) -> bool:
	var key := "func _go_home("
	var start: int = src.find(key)
	if start < 0:
		return false
	var nxt: int = src.find("\nfunc ", start + key.length())
	var body: String = src.substr(start, nxt - start if nxt >= 0 else src.length() - start)
	var pause_i: int = body.find("get_tree().paused = true")
	var dissolve_i: int = body.find("_biome_dissolve_reveal")
	return pause_i >= 0 and dissolve_i >= 0 and pause_i < dissolve_i


func _check(rows: Array, failed: bool, name: String, ok: bool, detail: String = "") -> bool:
	var line := "PASS %s" % name if ok else "FAIL %s %s" % [name, detail]
	rows.append(line)
	print(line)
	return failed or not ok


func _finish(failed: bool, rows: Array) -> void:
	for r in rows:
		pass
	if failed:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)


class _StubDialog extends Node:
	var said: Dictionary = {}
	signal finished(choice: int)

	func say(keys: Array, _choices: Array = [], _vars: Dictionary = {}, _fallbacks: Dictionary = {}) -> void:
		for k in keys:
			said[str(k)] = true
		call_deferred("_emit_finished")

	func say_bubble(key: String, _pos = Vector2.ZERO, _vars = {}) -> void:
		said[str(key)] = true

	func is_open() -> bool:
		return false

	func _emit_finished() -> void:
		finished.emit(-1)
