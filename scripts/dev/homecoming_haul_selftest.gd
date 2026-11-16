extends SceneTree
## Homecoming haul model — dialogue, board routing, lever-ready (b1..b5).
## Scenarios from saved-style states (no live user:// writes).
##
## Run: godot --headless --path . --script res://scripts/dev/homecoming_haul_selftest.gd


const OK_MARK := "HOMECOMING_HAUL_OK"
const FAIL_MARK := "HOMECOMING_HAUL_FAIL"
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
	failed = _check(rows, failed, "faces.5", faces.size() >= 5) or failed
	if faces.size() < 4:
		_finish(failed, rows)
		return

	var b1: Array = MODEL.face_ids_flat(faces[0])
	var b2: Array = MODEL.face_ids_flat(faces[1])
	var b3: Array = MODEL.face_ids_flat(faces[2])
	var b4: Array = MODEL.face_ids_flat(faces[3])
	failed = _check(rows, failed, "b1.ids", b1.size() >= 5) or failed
	failed = _check(rows, failed, "b2.ids", b2.size() >= 5) or failed
	failed = _check(rows, failed, "b3.ids", b3.size() >= 5) or failed
	failed = _check(rows, failed, "b4.ids", b4.size() >= 5) or failed

	## --- Pure haul model ---
	var CabinScr = load("res://scripts/home_cabin.gd")
	var cabin0 = _make_cabin(CabinScr, items_by_id, rules)
	cabin0._homecoming_kind = "win"
	cabin0.first_return_homecoming_done = true
	cabin0.bank_pending = []
	cabin0._bank_hold = {}
	cabin0._new_ids = []
	var haul0: Dictionary = HOMECOMING.build_haul(cabin0)
	failed = _check(rows, failed, "a.model.count0", int(haul0.get("count", -1)) == 0) or failed
	failed = _check(rows, failed, "a.model.kind_win", str(haul0.get("kind", "")) == "win") or failed

	## (a) return with 0 uniques win → empty line, not unpack/new
	var a = await _run_return(CabinScr, items_by_id, rules, {
		"kind": "win",
		"pending": [],
		"new_ids": [],
		"banked": {},
		"map_pieces": ["b1"],
		"first_done": true,
	})
	failed = _check(rows, failed, "a.empty.key",
		str(a.h.empty_or_loss_key).begins_with("nib.board.empty.")) or failed
	failed = _check(rows, failed, "a.empty.no_place", a.h.placed_order.is_empty()) or failed
	failed = _check(rows, failed, "a.empty.no_lever", int(a.h.lever_ready_face) < 0) or failed

	## (b) loss → loss line
	var b = await _run_return(CabinScr, items_by_id, rules, {
		"kind": "loss",
		"pending": [],
		"new_ids": [],
		"banked": {},
		"map_pieces": ["b1"],
		"first_done": true,
	})
	failed = _check(rows, failed, "b.loss.key",
		str(b.h.empty_or_loss_key).begins_with("nib.home.loss.")) or failed
	failed = _check(rows, failed, "b.loss.no_place", b.h.placed_order.is_empty()) or failed

	## (c) 3 new b2 uniques → new-line path, count 3, all routed to b2
	var c_ids: Array = [str(b2[0]), str(b2[1]), str(b2[2])]
	var c_banked := {}
	for cid in c_ids:
		c_banked[cid] = "b2"
	var c = await _run_return(CabinScr, items_by_id, rules, {
		"kind": "win",
		"pending": c_ids.duplicate(),
		"new_ids": c_ids.duplicate(),
		"banked": c_banked,
		"map_pieces": ["b1", "b2"],
		"first_done": true,
	})
	failed = _check(rows, failed, "c.count3", int(c.h.haul.get("count", -1)) == 3) or failed
	failed = _check(rows, failed, "c.placed3", c.h.placed_order.size() == 3) or failed
	failed = _check(rows, failed, "c.no_empty",
		not str(c.h.empty_or_loss_key).begins_with("nib.board.empty.")) or failed
	var c_boards_ok := true
	for row in c.h.haul.get("new_uniques", []):
		if str(row.get("pool_id", "")) != "b2":
			c_boards_ok = false
	failed = _check(rows, failed, "c.all_b2", c_boards_ok) or failed

	## (c2) desync repair: news has 3 b2, pending empty, ceremony not played → still unpack
	var c2_cabin = _make_cabin(CabinScr, items_by_id, rules)
	c2_cabin._homecoming_kind = "win"
	c2_cabin.first_return_homecoming_done = true
	c2_cabin._bank_played = false
	c2_cabin.bank_pending = []
	c2_cabin._bank_hold = {}
	c2_cabin._new_ids = c_ids.duplicate()
	var state_c2 := SHELL.fresh_state()
	state_c2["banked"] = c_banked.duplicate()
	state_c2["map_pieces"] = ["b1", "b2"]
	c2_cabin._campaign_shell = {"state": state_c2}
	var haul_c2: Dictionary = HOMECOMING.build_haul(c2_cabin)
	failed = _check(rows, failed, "c2.repair.count3", int(haul_c2.get("count", -1)) == 3,
		"ordered=%s" % str(haul_c2.get("ordered_ids", []))) or failed

	## (d) mixed b1+b2 → board order (b1 then b2)
	var d_ids: Array = [str(b2[0]), str(b1[0]), str(b1[1])]
	var d_banked := {str(b2[0]): "b2", str(b1[0]): "b1", str(b1[1]): "b1"}
	var d = await _run_return(CabinScr, items_by_id, rules, {
		"kind": "win",
		"pending": d_ids.duplicate(),
		"new_ids": d_ids.duplicate(),
		"banked": d_banked,
		"map_pieces": ["b1", "b2"],
		"first_done": true,
	})
	var d_order: Array = d.h.placed_order
	var d_ok := d_order.size() == 3
	if d_ok:
		var meta0: Dictionary = HOMECOMING._meta_for_static(str(d_order[0]), faces, items_by_id)
		var meta1: Dictionary = HOMECOMING._meta_for_static(str(d_order[1]), faces, items_by_id)
		var meta2: Dictionary = HOMECOMING._meta_for_static(str(d_order[2]), faces, items_by_id)
		d_ok = int(meta0.get("face_index", 9)) == 0 \
			and int(meta1.get("face_index", 9)) == 0 \
			and int(meta2.get("face_index", 9)) == 1
	failed = _check(rows, failed, "d.board_order", d_ok, "order=%s" % str(d_order)) or failed

	## (e) 5th b2 light → lever ready on b2 with lever_ready lines
	failed = await _assert_lever_ready(rows, failed, CabinScr, items_by_id, rules, faces,
		1, b2, ["b1", "b2"], "e") or failed

	## (f) same for b3 and b4
	failed = await _assert_lever_ready(rows, failed, CabinScr, items_by_id, rules, faces,
		2, b3, ["b1", "b2", "b3"], "f3") or failed
	failed = await _assert_lever_ready(rows, failed, CabinScr, items_by_id, rules, faces,
		3, b4, ["b1", "b2", "b3", "b4"], "f4") or failed

	## (g) duplicates / tokens ignored
	var tok_id := "marble"
	var g_pending: Array = [str(b1[0]), str(b1[0]), tok_id, "spider_egg"]
	var g_cabin = _make_cabin(CabinScr, items_by_id, rules)
	g_cabin._homecoming_kind = "win"
	g_cabin.first_return_homecoming_done = true
	g_cabin._bank_played = false
	g_cabin.bank_pending = g_pending.duplicate()
	g_cabin._bank_hold = {str(b1[0]): true, tok_id: true}
	g_cabin._new_ids = g_pending.duplicate()
	## Pending contains a duplicate + tokens — ordered should be one board unique only.
	var haul_g: Dictionary = HOMECOMING.build_haul(g_cabin)
	var g_ordered: Array = haul_g.get("ordered_ids", [])
	failed = _check(rows, failed, "g.unique_only",
		g_ordered.size() == 1 and str(g_ordered[0]) == str(b1[0]),
		"ordered=%s tokens=%s" % [str(g_ordered), str(haul_g.get("tokens_excluded", []))]) or failed
	var g_toks: Array = haul_g.get("tokens_excluded", [])
	failed = _check(rows, failed, "g.tokens_listed",
		g_toks.has(tok_id) and g_toks.has("spider_egg"),
		"tokens=%s" % str(g_toks)) or failed

	## Source: live state helper + newly-ready lever path exist.
	var home_src := FileAccess.get_file_as_string("res://scripts/cabin/homecoming.gd")
	var cabin_src := FileAccess.get_file_as_string("res://scripts/home_cabin.gd")
	failed = _check(rows, failed, "src.build_haul", home_src.find("static func build_haul") >= 0) or failed
	failed = _check(rows, failed, "src.live_state", home_src.find("func _live_state") >= 0) or failed
	failed = _check(rows, failed, "src.newly_ready", home_src.find("newly_ready") >= 0) or failed
	failed = _check(rows, failed, "src.apply_haul", cabin_src.find("func apply_homecoming_haul") >= 0) or failed
	failed = _check(rows, failed, "src.no_restage",
		cabin_src.find("not _bank_played and bank_pending.is_empty()") >= 0) or failed

	Engine.time_scale = 1.0
	_finish(failed, rows)


func _assert_lever_ready(
	rows: Array, failed: bool, CabinScr, items_by_id: Dictionary, rules: Dictionary,
	faces: Array, face_i: int, face_ids: Array, map_pieces: Array, tag: String
) -> bool:
	var quota: int = SHELL.quota_of(rules)
	if face_ids.size() < quota:
		return _check(rows, failed, "%s.skip_short" % tag, false, "need %d ids" % quota)
	## 4 already banked + 1 pending this return → newly ready after claim.
	var prior: Array = []
	var banked := {}
	for i in quota - 1:
		var id := str(face_ids[i])
		prior.append(id)
		banked[id] = str((faces[face_i] as Dictionary).get("pool_id", "b%d" % (face_i + 1)))
	var fresh := str(face_ids[quota - 1])
	banked[fresh] = str((faces[face_i] as Dictionary).get("pool_id", "b%d" % (face_i + 1)))
	## Older face may already be ready — must NOT steal the prompt.
	if face_i > 0 and faces.size() > 0:
		var b1_ids: Array = MODEL.face_ids_flat(faces[0])
		for j in mini(quota, b1_ids.size()):
			banked[str(b1_ids[j])] = "b1"
	var r = await _run_return(CabinScr, items_by_id, rules, {
		"kind": "win",
		"pending": [fresh],
		"new_ids": [fresh],
		"banked": banked,
		"map_pieces": map_pieces.duplicate(),
		"first_done": true,
		"first_light_seen": true,
	})
	failed = _check(rows, failed, "%s.lever_face" % tag,
		int(r.h.lever_ready_face) == face_i,
		"got=%s want=%s keys=%s" % [r.h.lever_ready_face, face_i, str(r.h.lever_ready_keys)]) or failed
	failed = _check(rows, failed, "%s.lever_keys" % tag,
		r.h.lever_ready_keys.has("nib.board.lever_ready.1")
		and r.h.lever_ready_keys.has("nib.board.lever_ready.2"),
		"keys=%s said=%s" % [str(r.h.lever_ready_keys), str(r.stub.said.keys())]) or failed
	failed = _check(rows, failed, "%s.said_lever" % tag,
		r.stub.said.has("nib.board.lever_ready.1"),
		"said=%s" % str(r.stub.said.keys())) or failed
	return failed


func _run_return(CabinScr, items_by_id: Dictionary, rules: Dictionary, cfg: Dictionary) -> Dictionary:
	var cabin = _make_cabin(CabinScr, items_by_id, rules)
	cabin._homecoming_kind = str(cfg.get("kind", "win"))
	cabin.first_return_homecoming_done = bool(cfg.get("first_done", true))
	cabin.first_light_seen = bool(cfg.get("first_light_seen", true))
	cabin._bank_played = false
	var pending: Array = cfg.get("pending", [])
	cabin.bank_pending = pending.duplicate()
	cabin._bank_hold = {}
	for pid in pending:
		cabin._bank_hold[str(pid)] = true
	cabin._new_ids = (cfg.get("new_ids", []) as Array).duplicate()
	var state := SHELL.fresh_state()
	state["banked"] = (cfg.get("banked", {}) as Dictionary).duplicate(true)
	state["map_pieces"] = (cfg.get("map_pieces", ["b1"]) as Array).duplicate()
	cabin._campaign_shell = {"state": state}
	var board: TrophyBoard = BOARD.new()
	root.add_child(board)
	board.reduce_motion = true
	board.setup(rules, items_by_id, state, {}, cabin.bank_pending.duplicate())
	var stub := _StubDialog.new()
	cabin.set("_dialog", stub)
	root.add_child(stub)
	var h = await HOMECOMING.run(board, cabin, null)
	return {"h": h, "stub": stub, "cabin": cabin, "board": board}


func _make_cabin(CabinScr, items_by_id: Dictionary, rules: Dictionary):
	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.items_by_id = items_by_id
	cabin.tex_by_item = {}
	cabin._campaign_rules = rules
	cabin.reduce_motion = true
	return cabin


func _check(rows: Array, failed: bool, name: String, ok: bool, detail: String = "") -> bool:
	var line := "PASS %s" % name if ok else "FAIL %s %s" % [name, detail]
	rows.append(line)
	return failed or not ok


func _finish(failed: bool, rows: Array) -> void:
	for r in rows:
		print(r)
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

	func _emit_finished() -> void:
		finished.emit(-1)
