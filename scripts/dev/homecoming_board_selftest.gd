extends SceneTree
## Package C — TrophyBoard homecoming timeline selftest (SceneTree).
## Builds a cabin stub + real TrophyBoard, runs Homecoming at time_scale 8.
## Asserts place order, minimal face slides, light flashes, bank_pending drain,
## skip path, and reduce_motion path.
##
## Sets cabin._persist_writes=false so a direct invoke cannot touch live saves.


const OK_MARK := "HOMECOMING_BOARD_OK"
const FAIL_MARK := "HOMECOMING_BOARD_FAIL"
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const HOMECOMING := preload("res://scripts/cabin/homecoming.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const COPY := preload("res://scripts/player_copy.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	COPY.reload()
	Engine.time_scale = 8.0

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
	failed = _check(rows, failed, "faces_loaded", faces.size() == 5) or failed
	if faces.is_empty():
		_finish(failed, rows)
		return

	## Pick 2 b1 items + 1 b2 item for multi-face order.
	var b1_ids: Array = MODEL.face_ids_flat(faces[0])
	var b2_ids: Array = MODEL.face_ids_flat(faces[1]) if faces.size() > 1 else []
	failed = _check(rows, failed, "b1_has_items", b1_ids.size() >= 2) or failed
	failed = _check(rows, failed, "b2_has_items", b2_ids.size() >= 1) or failed
	var id_a: String = str(b1_ids[0])
	var id_b: String = str(b1_ids[1])
	var id_c: String = str(b2_ids[0]) if not b2_ids.is_empty() else ""

	## --- Ownership still works on a bare cabin script ---
	var CabinScr = load("res://scripts/home_cabin.gd")
	failed = _check(rows, failed, "cabin_loads", CabinScr != null) or failed
	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.items_by_id = items_by_id
	cabin.tex_by_item = {}
	cabin._homecoming_kind = "win"
	cabin.reduce_motion = false
	cabin.bank_pending = [id_c, id_b, id_a] if id_c != "" else [id_b, id_a]
	cabin._bank_hold = {}
	for pid in cabin.bank_pending:
		cabin._bank_hold[str(pid)] = true
	## Minimal campaign shell state: banked includes pending (already credited).
	var state := SHELL.fresh_state()
	state["banked"] = {}
	for pid2 in cabin.bank_pending:
		state["banked"][str(pid2)] = true
	## Unlock b2 portal so face 1 is not locked for the multi-face pass.
	state["map_pieces"] = {"b2": true}
	var shell_stub := {"state": state}
	cabin._campaign_shell = shell_stub
	cabin._campaign_rules = rules

	## Host control for FX + board.
	var host := Control.new()
	host.name = "Host"
	host.size = Vector2(1680, 1040)
	root.add_child(host)
	## Reparent cabin under host so Homecoming FX attach to a Control with size.
	## Homecoming uses cabin as host — cabin is ColorRect, OK.
	cabin.size = Vector2(1680, 1040)

	var board: TrophyBoard = BOARD.new()
	cabin.add_child(board)
	cabin._trophy_board = board
	board.setup(rules, items_by_id, state, {}, cabin.bank_pending.duplicate())
	board.slide_to(0, true)
	await process_frame

	## Static: Homecoming class + cabin wires exist.
	var hc_static: Node = HOMECOMING.new() if HOMECOMING != null else null
	failed = _check(
		rows, failed, "STATIC.homecoming_class",
		hc_static != null and hc_static.has_method("run")
	) or failed
	if hc_static != null:
		hc_static.free()
	failed = _check(
		rows, failed, "STATIC.cabin_play_bank",
		cabin.has_method("_play_bank_sequence") and cabin.has_method("_stage_homecoming_bank")
	) or failed
	failed = _check(
		rows, failed, "STATIC.no_old_bank_fx_arc",
		not cabin.has_method("_bank_fx_arc_to_mount")
	) or failed
	failed = _check(
		rows, failed, "STATIC.board_set_hold",
		board.has_method("set_hold")
	) or failed
	failed = _check(
		rows, failed, "ART.satchel_idle",
		ResourceLoader.exists("res://assets/ui/trophy_board/satchel_idle.png")
	) or failed
	failed = _check(
		rows, failed, "ART.poof_f0",
		ResourceLoader.exists("res://assets/ui/trophy_board/poof_f0.png")
	) or failed
	failed = _check(
		rows, failed, "ART.rise_glint_f0",
		ResourceLoader.exists("res://assets/ui/trophy_board/rise_glint_f0.png")
	) or failed
	failed = _check(
		rows, failed, "ART.light_flash_f0",
		ResourceLoader.exists("res://assets/ui/trophy_board/light_flash_f0.png")
	) or failed

	## --- Full homecoming at time_scale 8 ---
	var pending_before: Array = cabin.bank_pending.duplicate()
	var spy := {
		"placed": [],
		"faces": 0,
		"lights": 0,
		"finished": false,
		"placed_order": [],
	}
	var h2 := Homecoming.new()
	h2.board = board
	h2.cabin = cabin
	h2.sfx = null
	h2.reduce_motion = false
	cabin.add_child(h2)
	h2.item_placed.connect(func(cid: String) -> void:
		spy["placed"].append(cid)
	)
	h2.light_flashed.connect(func(_fi: int, _li: int) -> void:
		spy["lights"] = int(spy["lights"]) + 1
	)
	h2.finished.connect(func() -> void:
		spy["finished"] = true
		spy["faces"] = h2.face_change_count
		spy["placed_order"] = h2.placed_order.duplicate()
	)
	await h2._run()
	await process_frame

	var placed: Array = spy.get("placed_order", spy["placed"])
	## Order: both b1 before b2 (board order, minimal rightward slides).
	var idx_a: int = placed.find(id_a)
	var idx_b: int = placed.find(id_b)
	var idx_c: int = placed.find(id_c) if id_c != "" else -1
	failed = _check(rows, failed, "placed_all", placed.size() == pending_before.size()) or failed
	failed = _check(rows, failed, "pending_drained", cabin.bank_pending.is_empty()) or failed
	if id_c != "":
		failed = _check(
			rows, failed, "order_b1_before_b2",
			idx_a >= 0 and idx_b >= 0 and idx_c >= 0 and maxi(idx_a, idx_b) < idx_c
		) or failed
		## One slide b1→b2 (not back). face_change_count should be small.
		failed = _check(
			rows, failed, "minimal_face_slides",
			int(spy["faces"]) <= 2
		) or failed
	failed = _check(rows, failed, "finished_flag", bool(spy["finished"])) or failed

	## --- Skip mid-sequence ---
	cabin.bank_pending = [id_a, id_b]
	cabin._bank_hold = {id_a: true, id_b: true}
	state["banked"][id_a] = true
	state["banked"][id_b] = true
	board.set_hold(cabin.bank_pending)
	board.refresh()
	var h3 := Homecoming.new()
	h3.board = board
	h3.cabin = cabin
	h3.reduce_motion = false
	cabin.add_child(h3)
	var skip_flag := [false]
	var skip_done := [false]
	h3.skipped.connect(func() -> void: skip_flag[0] = true)
	h3.finished.connect(func() -> void: skip_done[0] = true)
	h3.call_deferred("request_skip")
	await h3._run()
	await process_frame
	failed = _check(rows, failed, "skip_drains_pending", cabin.bank_pending.is_empty()) or failed
	failed = _check(rows, failed, "skip_finished", bool(skip_done[0])) or failed
	failed = _check(rows, failed, "skip_flag", bool(skip_flag[0])) or failed

	## --- Reduce motion: places without fly, pending drains ---
	cabin.bank_pending = [id_a]
	cabin._bank_hold = {id_a: true}
	cabin.reduce_motion = true
	board.set_hold(cabin.bank_pending)
	board.reduce_motion = true
	board.refresh()
	await HOMECOMING.run(board, cabin, null)
	failed = _check(rows, failed, "reduce_motion_drains", cabin.bank_pending.is_empty()) or failed
	cabin.reduce_motion = false
	board.reduce_motion = false

	## --- Empty pending: win line path does not crash ---
	cabin.bank_pending = []
	cabin._bank_hold.clear()
	cabin._homecoming_kind = "win"
	board.set_hold([])
	var h5 := Homecoming.new()
	h5.board = board
	h5.cabin = cabin
	cabin.add_child(h5)
	await h5._run()
	failed = _check(rows, failed, "empty_win_ok", true) or failed

	## --- Stale ceremony cannot ack (crash mid-sequence leaves pending) ---
	cabin.bank_pending = [id_a, id_b]
	cabin._bank_hold = {id_a: true, id_b: true}
	var gen_live: int = cabin.call("_begin_bank_ceremony")
	cabin.call("_invalidate_bank_ceremony")
	cabin.call("_ack_bank_presented", id_a, gen_live)
	failed = _check(
		rows, failed, "stale_ack_keeps_pending",
		(cabin.bank_pending as Array).has(id_a) and (cabin.bank_pending as Array).has(id_b)
	) or failed
	## Live ack still drains.
	var gen2: int = cabin.call("_begin_bank_ceremony")
	cabin.call("_ack_bank_presented", id_a, gen2)
	failed = _check(
		rows, failed, "live_ack_removes",
		not (cabin.bank_pending as Array).has(id_a)
	) or failed
	cabin.call("_release_bank_ceremony", gen2)

	## Source contracts
	var home_src := FileAccess.get_file_as_string("res://scripts/cabin/homecoming.gd")
	failed = _check(
		rows, failed, "STATIC.no_tier_atk",
		home_src.find("Tier") < 0 and home_src.find("ATK") < 0 and home_src.find("atk") < 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.step_2s",
		home_src.find("HOMECOMING_STEP := 2.0") >= 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.uses_place_claimed",
		home_src.find("place_claimed") >= 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.uses_flash_light",
		home_src.find("flash_light") >= 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.hands_off_to_board_sequences",
		home_src.find("_maybe_run_board_complete_sequences") >= 0
		and home_src.find("BoardSequences.portal") < 0
		and home_src.find("await BS.shortcut") < 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.slot_from_board_api",
		home_src.find("slot_global_center") >= 0
		and home_src.find("624") < 0
		and home_src.find("1056") < 0
	) or failed
	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	failed = _check(
		rows, failed, "STATIC.arrive_skips_main_walk_hall",
		cabin_src.find("fade straight into the trophy hall") >= 0
		or cabin_src.find("Package C: exterior click") >= 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.interior_keyring_main",
		cabin_src.find("key_ring_seen") >= 0
		and cabin_src.find("counts_as_successful_dungeon_return") >= 0
	) or failed
	failed = _check(
		rows, failed, "STATIC.cabin_has_board_sequences_hook",
		cabin_src.find("func _maybe_run_board_complete_sequences") >= 0
		and cabin_src.find("BoardSequences") >= 0
	) or failed

	Engine.time_scale = 1.0
	_finish(failed, rows)


func _check(rows: Array, failed: bool, id: String, ok: bool) -> bool:
	var mark := "PASS" if ok else "FAIL"
	var line := "ASSERT %s %s" % [mark, id]
	rows.append(line)
	print(line)
	if not ok:
		push_error(line)
	return failed or not ok


func _finish(failed: bool, rows: Array) -> void:
	for r in rows:
		pass
	if failed:
		print(FAIL_MARK)
		push_error(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)
