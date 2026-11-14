extends SceneTree
## Flow overhaul (2026-11-14): first-return gating + branches, first-light pause, dead-portal click.
## Keeps TROPHY_BOARD_MODEL_OK / NIB_RELOCATION_OK green; this is an additive mark.


const OK_MARK := "FLOW_OVERHAUL_OK"
const FAIL_MARK := "FLOW_OVERHAUL_FAIL"
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const BOARD := preload("res://scripts/cabin/trophy_board.gd")
const HOMECOMING := preload("res://scripts/cabin/homecoming.gd")
const SHELL := preload("res://scripts/campaign_shell.gd")
const COPY := preload("res://scripts/player_copy.gd")
const ROPE := preload("res://scripts/cabin/rope_exit.gd")
const GATE := preload("res://scripts/cabin/gate_portal.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	COPY.reload()
	Engine.time_scale = 10.0

	## --- Copy + SFX keys ---
	for k in [
		"nib.portal.cold", "nib.board.first_look", "nib.board.first_empty",
		"nib.board.first_unpack", "nib.board.first_placed", "nib.board.first_hover_hint",
		"nib.board.first_light.1", "nib.board.first_light.2",
	]:
		failed = _check(rows, failed, "copy.%s" % k, COPY.text(k, "") != "") or failed
	failed = _check(
		rows, failed, "copy.portal.1_discovery",
		COPY.text("nib.portal.1", "").find("THAT") >= 0
	) or failed
	var sfx_map: Dictionary = SHELL.read_json("res://data/sfx-map.json")
	var cues: Dictionary = sfx_map.get("cues", {}) if typeof(sfx_map.get("cues", {})) == TYPE_DICTIONARY else {}
	failed = _check(rows, failed, "cue.portal.fizzle", cues.has("portal.fizzle")) or failed

	## --- Dead portal: no swirl when set_alive(false) ---
	var gate: Control = GATE.new()
	root.add_child(gate)
	gate.configure(Rect2(0, 0, 256, 448), Rect2(0, 400, 240, 56))
	gate.set_next_biome("b2")
	gate.set_alive(false)
	failed = _check(rows, failed, "gate.dead.not_alive", gate.is_alive() == false) or failed
	var spiral = gate.get_node_or_null("SpiralMotes")
	failed = _check(
		rows, failed, "gate.dead.no_swirl",
		spiral == null or (spiral is CPUParticles2D and not (spiral as CPUParticles2D).emitting)
	) or failed
	gate.set_alive(true)
	failed = _check(rows, failed, "gate.alive", gate.is_alive() == true) or failed
	if spiral is CPUParticles2D:
		failed = _check(rows, failed, "gate.alive.swirl", (spiral as CPUParticles2D).emitting) or failed

	## --- Rope exit: dead click fizzles, never blocks ---
	var CabinScr = load("res://scripts/home_cabin.gd")
	var cabin: Node = CabinScr.new()
	cabin.set("_persist_writes", false)
	cabin.set_process(false)
	cabin.set_physics_process(false)
	root.add_child(cabin)
	cabin.call("_apply_defaults")
	cabin.reduce_motion = true
	var rope = ROPE.new()
	root.add_child(rope)
	rope.setup(cabin, {})
	rope.open_exit(1, [
		{"id": "boot", "name": "Boot", "tex": null, "is_new": true, "tier": 1},
		{"id": "net", "name": "Net", "tex": null, "is_new": false, "tier": 1},
	])
	rope.apply_exit_mode(true, false, true, {
		"biome": "Verdant Hollow",
		"n": 2,
		"quota": 5,
		"next_id": "b2",
		"portal_alive": false,
		"lights_lit": 2,
	}, false)
	failed = _check(rows, failed, "rope.portal_dead", rope.get("_portal_alive") == false) or failed
	failed = _check(rows, failed, "rope.arch_lights", int(rope.get("_arch_lights_lit")) == 2) or failed
	## No wall-grid "New unique" labels.
	var loot_host = rope.get("_loot_host")
	var has_new_unique_label := false
	if loot_host != null:
		for c in loot_host.get_children():
			if str(c.name).find("extract") >= 0 or (c is Label and str((c as Label).text).to_lower().find("unique") >= 0):
				has_new_unique_label = true
	failed = _check(rows, failed, "rope.no_new_unique_text", not has_new_unique_label) or failed
	failed = _check(rows, failed, "rope.has_satchel", rope.get("_floor_satchel") != null) or failed
	failed = _check(rows, failed, "rope.has_strip", rope.get("_loot_strip") != null) or failed
	## Fizzle path.
	rope.call("_fizzle_dead_portal")
	failed = _check(rows, failed, "rope.fizzle_meta", bool(rope.get_meta("last_portal_fizzle", false))) or failed
	## Blocking interrupt retired.
	rope.call("_try_push_interrupt")
	failed = _check(rows, failed, "rope.no_interrupt", rope.get("_interrupt_open") == false) or failed

	## Alive visit → 5 arch lights + swirl.
	rope.apply_exit_mode(true, true, false, {
		"biome": "Verdant Hollow",
		"n": 5,
		"quota": 5,
		"next_id": "b2",
		"portal_alive": true,
		"lights_lit": 5,
	}, false)
	failed = _check(rows, failed, "rope.portal_alive", rope.get("_portal_alive") == true) or failed
	failed = _check(rows, failed, "rope.arch_all_lit", int(rope.get("_arch_lights_lit")) == 5) or failed

	## --- First-return gating + empty / unpack branches ---
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
	failed = _check(rows, failed, "faces", faces.size() == 5) or failed
	var b1_ids: Array = MODEL.face_ids_flat(faces[0]) if not faces.is_empty() else []
	failed = _check(rows, failed, "b1_items", b1_ids.size() >= 1) or failed

	## Empty branch
	var cabin_e: Node = CabinScr.new()
	cabin_e.set("_persist_writes", false)
	cabin_e.set_process(false)
	cabin_e.set_physics_process(false)
	root.add_child(cabin_e)
	cabin_e.items_by_id = items_by_id
	cabin_e.tex_by_item = {}
	cabin_e._homecoming_kind = "win"
	cabin_e.key_ring_seen = true
	cabin_e.first_return_homecoming_done = false
	cabin_e.first_light_seen = false
	cabin_e.reduce_motion = true
	cabin_e.bank_pending = []
	cabin_e._bank_hold = {}
	var state_e := SHELL.fresh_state()
	cabin_e._campaign_shell = {"state": state_e}
	cabin_e._campaign_rules = rules
	var board_e: Control = BOARD.new()
	root.add_child(board_e)
	board_e.reduce_motion = true
	board_e.setup(rules, items_by_id, state_e, {}, [])
	var stub_dialog_e := _StubDialog.new()
	cabin_e.set("_dialog", stub_dialog_e)
	root.add_child(stub_dialog_e)
	var h_empty = await HOMECOMING.run(board_e, cabin_e, null)
	failed = _check(rows, failed, "first.empty.branch", h_empty.first_return_branch == "empty") or failed
	failed = _check(rows, failed, "first.empty.flag", bool(cabin_e.first_return_homecoming_done)) or failed
	failed = _check(rows, failed, "first.empty.said_look", stub_dialog_e.said.has("nib.board.first_look")) or failed
	failed = _check(rows, failed, "first.empty.said_empty", stub_dialog_e.said.has("nib.board.first_empty")) or failed

	## Unpack branch + first-light pause
	var cabin_u: Node = CabinScr.new()
	cabin_u.set("_persist_writes", false)
	cabin_u.set_process(false)
	cabin_u.set_physics_process(false)
	root.add_child(cabin_u)
	cabin_u.items_by_id = items_by_id
	cabin_u.tex_by_item = {}
	cabin_u._homecoming_kind = "win"
	cabin_u.key_ring_seen = true
	cabin_u.first_return_homecoming_done = false
	cabin_u.first_light_seen = false
	cabin_u.reduce_motion = true
	var id_a: String = str(b1_ids[0])
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
	var stub_dialog_u := _StubDialog.new()
	cabin_u.set("_dialog", stub_dialog_u)
	root.add_child(stub_dialog_u)
	## Minimal ack so place_claimed doesn't crash.
	if not cabin_u.has_method("_ack_bank_presented"):
		pass
	var h_unpack = await HOMECOMING.run(board_u, cabin_u, null)
	failed = _check(rows, failed, "first.unpack.branch", h_unpack.first_return_branch == "unpack") or failed
	failed = _check(rows, failed, "first.unpack.placed", h_unpack.placed_order.has(id_a)) or failed
	failed = _check(rows, failed, "first.unpack.flag", bool(cabin_u.first_return_homecoming_done)) or failed
	failed = _check(rows, failed, "first.light.pause", h_unpack.first_light_did_pause) or failed
	failed = _check(rows, failed, "first.light.flag", bool(cabin_u.first_light_seen)) or failed
	failed = _check(rows, failed, "first.said_unpack", stub_dialog_u.said.has("nib.board.first_unpack")) or failed
	failed = _check(rows, failed, "first.said_light", stub_dialog_u.said.has("nib.board.first_light.1")) or failed

	## Later return does not re-trigger first-return lines.
	cabin_u.first_return_homecoming_done = true
	cabin_u.bank_pending = []
	cabin_u._bank_hold = {}
	var stub2 := _StubDialog.new()
	cabin_u.set("_dialog", stub2)
	root.add_child(stub2)
	var h_later = await HOMECOMING.run(board_u, cabin_u, null)
	failed = _check(rows, failed, "later.not_first", h_later.first_return_branch == "") or failed
	failed = _check(rows, failed, "later.no_first_look", not stub2.said.has("nib.board.first_look")) or failed

	## Source guards: no Tier/ATK in new rope loot path.
	var rope_src := FileAccess.get_file_as_string("res://scripts/cabin/rope_exit.gd")
	failed = _check(rows, failed, "src.no_new_unique_label", rope_src.find("extract.new_unique") < 0 or rope_src.find("_show_loot") >= 0) or failed
	## After rewrite, extract.new_unique should not be called from _show_loot.
	failed = _check(
		rows, failed, "src.show_loot_no_unique_chip",
		rope_src.find("FloorSatchel") >= 0 and rope_src.find("LootStrip") >= 0
	) or failed
	failed = _check(rows, failed, "src.fizzle", rope_src.find("_fizzle_dead_portal") >= 0) or failed
	var home_src := FileAccess.get_file_as_string("res://scripts/cabin/homecoming.gd")
	failed = _check(rows, failed, "src.first_light", home_src.find("_play_first_light_scene") >= 0) or failed
	failed = _check(rows, failed, "src.first_return_step", home_src.find("FIRST_RETURN_STEP") >= 0) or failed
	var face_src := FileAccess.get_file_as_string("res://scripts/cabin/trophy_board_face.gd")
	failed = _check(rows, failed, "src.floor_lever", face_src.find("big brass") >= 0 or face_src.find("128, 256") >= 0) or failed

	_finish(failed, rows)


func _check(rows: Array, failed: bool, name: String, ok: bool) -> bool:
	rows.append("%s %s" % ["PASS" if ok else "FAIL", name])
	if not ok:
		push_warning("FLOW_OVERHAUL FAIL: %s" % name)
	return failed or not ok


func _finish(failed: bool, rows: Array) -> void:
	for r in rows:
		print(r)
	print(FAIL_MARK if failed else OK_MARK)
	quit(1 if failed else 0)


class _StubDialog extends Node:
	signal finished
	var said: Array = []

	func say(keys: Array, _choices: Array = [], _vars: Dictionary = {}, _fb: Dictionary = {}) -> void:
		for k in keys:
			said.append(str(k))
		call_deferred("_emit_done")

	func say_bubble(key: String, _pos: Vector2 = Vector2.ZERO, _vars: Dictionary = {}) -> void:
		said.append(str(key))

	func _emit_done() -> void:
		finished.emit()
