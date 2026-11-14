extends SceneTree
## Package D: gates, migration, lights latch, portal sequence spy.
## Run: ./tools/qa/run_board_gates.sh


const SHELL := preload("res://scripts/campaign_shell.gd")
const MODEL := preload("res://scripts/cabin/trophy_board_model.gd")
const SEQ := preload("res://scripts/cabin/board_sequences.gd")


func _init() -> void:
	var failed := false
	var rules: Dictionary = SHELL.read_json("res://data/campaign.json")

	## --- Fresh: only Verdant starts; later biomes fogged (not unlocked) ---
	var fresh: Dictionary = SHELL.fresh_state()
	SHELL.normalize_with_rules(rules, fresh)
	failed = _check(failed, "fresh.can_start.b1", SHELL.can_start(rules, fresh, 0)) or failed
	failed = _check(failed, "fresh.no_start.b2", not SHELL.can_start(rules, fresh, 1)) or failed
	failed = _check(failed, "fresh.b2.locked", not SHELL.biome_unlocked(rules, fresh, 1)) or failed
	failed = _check(failed, "fresh.portal.b2.closed", not SHELL.portal_opened(fresh, "b2")) or failed

	## --- 5 unique b1: lever ready, push blocked until pull ---
	## Skip silent migration so we exercise the live lever gate (not a backfilled portal).
	var lit5: Dictionary = SHELL.fresh_state()
	lit5["migrated_board_v1"] = true
	_fill_stored(lit5, "b1", 5)
	SHELL.normalize_with_rules(rules, lit5)
	failed = _check(failed, "5.b1.still_locked_dest", not SHELL.biome_unlocked(rules, lit5, 1)) or failed
	failed = _check(failed, "5.b1.no_start.b2", not SHELL.can_start(rules, lit5, 1)) or failed
	SHELL.begin_run(lit5, 0, false, false)
	failed = _check(failed, "5.b1.push_blocked", not SHELL.can_push(rules, lit5)) or failed
	failed = _check(failed, "5.b1.push_needs_nib", SHELL.push_needs_nib(rules, lit5)) or failed
	failed = _check(failed, "5.b1.push_key_lever", SHELL.push_block_key(rules, lit5) == "nib.push_block.lever") or failed
	var face_b1 := {"pool_id": "b1", "index": 0, "ids": _ids("b1", 5), "rows": {3: [], 2: [], 1: _ids("b1", 5)}}
	## Lights without portal: min(5, claimed). With synthetic face ids matching banked.
	failed = _check(failed, "5.b1.lights", MODEL.lights_lit(rules, lit5, face_b1) == 5) or failed
	failed = _check(failed, "5.b1.lever_ready", MODEL.lever_state(rules, lit5, face_b1) == &"ready") or failed

	## Pull opens portal → Known (unlocked) but not startable; Push works.
	var opened: Dictionary = SHELL.open_portal(rules, lit5, "b1")
	failed = _check(failed, "pull.stamps.b2", str(opened.get("id", "")) == "b2") or failed
	failed = _check(failed, "pull.portal.b2", SHELL.portal_opened(lit5, "b2")) or failed
	failed = _check(failed, "pull.biome_unlocked.b2", SHELL.biome_unlocked(rules, lit5, 1)) or failed
	failed = _check(failed, "pull.still_no_start.b2", not SHELL.can_start(rules, lit5, 1)) or failed
	failed = _check(failed, "pull.can_push", SHELL.can_push(rules, lit5)) or failed
	failed = _check(failed, "pull.no_nib", not SHELL.push_needs_nib(rules, lit5)) or failed
	failed = _check(failed, "pull.lever_spent", MODEL.lever_state(rules, lit5, face_b1) == &"spent") or failed
	failed = _check(failed, "pull.lights_latched", MODEL.lights_lit(rules, lit5, face_b1) == 5) or failed

	## 100% board → shortcut
	var full: Dictionary = SHELL.fresh_state()
	_fill_stored(full, "b1", 14)
	SHELL.open_portal(rules, full, "b1")
	var granted: Dictionary = SHELL.grant_shortcut(rules, full, "b2")
	failed = _check(failed, "shortcut.first", bool(granted.get("first", false))) or failed
	failed = _check(failed, "shortcut.can_start.b2", SHELL.can_start(rules, full, 1)) or failed
	failed = _check(failed, "shortcut.fresh.has", (full["shortcut_fresh"] as Array).has("b2")) or failed
	SHELL.note_shortcut_launched(full, "b2")
	failed = _check(failed, "shortcut.badge_cleared", not (full["shortcut_fresh"] as Array).has("b2")) or failed
	failed = _check(failed, "shortcut.still_startable", SHELL.can_start(rules, full, 1)) or failed

	## b5 lever → Endless
	var abyss: Dictionary = SHELL.fresh_state()
	for pool in ["b1", "b2", "b3", "b4", "b5"]:
		_fill_stored(abyss, pool, 5)
	## Open prior portals so cabinets_complete path is honest.
	for pool2 in ["b1", "b2", "b3", "b4"]:
		SHELL.open_portal(rules, abyss, pool2)
	var end_portal: Dictionary = SHELL.open_portal(rules, abyss, "b5")
	failed = _check(failed, "b5.lever.endless", bool(end_portal.get("endless", false))) or failed
	failed = _check(failed, "b5.endless_unlocked", bool(abyss.get("endless_unlocked", false))) or failed

	## Migration fixtures
	failed = _migrate_a(rules) or failed
	failed = _migrate_b(rules) or failed
	failed = _migrate_c(rules) or failed

	## rows_for_biome: opened pools mix (Nathan C3)
	var rows: Array = [
		{"id": "m1", "pool": "b1", "tier": 1},
		{"id": "m2", "pool": "b2", "tier": 1},
		{"id": "m3", "pool": "b3", "tier": 1},
	]
	var mix_state: Dictionary = SHELL.fresh_state()
	mix_state["map_pieces"] = ["b2"]
	SHELL.normalize_with_rules(rules, mix_state)
	var sliced: Array = SHELL.rows_for_biome(rules, mix_state, rows, "b1")
	var ids_got: Array = []
	for r in sliced:
		ids_got.append(str(r.get("id", "")))
	failed = _check(failed, "mix.includes.b1", ids_got.has("m1")) or failed
	failed = _check(failed, "mix.includes.b2", ids_got.has("m2")) or failed
	failed = _check(failed, "mix.excludes.b3", not ids_got.has("m3")) or failed

	## bank() never sets won / drawer
	var bank_state: Dictionary = SHELL.fresh_state()
	for pool3 in ["b1", "b2", "b3", "b4", "b5"]:
		_fill_stored(bank_state, pool3, 5)
	var bank_res: Dictionary = SHELL.bank(rules, bank_state, ["extra"], {"extra": "b1"})
	failed = _check(failed, "bank.no_drawer", not bool(bank_res.get("show_drawer", false))) or failed
	## Fresh bank of 5/5 each without prior won should leave won false.
	var bank_clean: Dictionary = SHELL.fresh_state()
	for pool4 in ["b1", "b2", "b3", "b4", "b5"]:
		var ids4: Array = []
		var pools4 := {}
		for k in 5:
			var id4 := "%s_bk_%d" % [pool4, k]
			ids4.append(id4)
			pools4[id4] = pool4
		SHELL.bank(rules, bank_clean, ids4, pools4)
	failed = _check(failed, "bank.clean.no_won", not bool(bank_clean.get("won", false))) or failed
	failed = _check(failed, "bank.clean.no_endless", not bool(bank_clean.get("endless_unlocked", false))) or failed

	## SceneTree spy: BoardSequences.portal records bucket_reveal call
	failed = await _sequence_spy(rules) or failed

	if failed:
		print("BOARD_GATES_FAIL")
		quit(1)
	print("BOARD_GATES_OK")
	quit(0)


## (a) old save: 5 in b1, no map piece → silent backfill, lever spent
func _migrate_a(rules: Dictionary) -> bool:
	var s: Dictionary = SHELL.fresh_state()
	_fill_stored(s, "b1", 5)
	s["migrated_board_v1"] = false
	s["map_pieces"] = []
	SHELL.normalize_with_rules(rules, s)
	var failed := false
	failed = _check(failed, "mig_a.piece.b2", (s["map_pieces"] as Array).has("b2")) or failed
	failed = _check(failed, "mig_a.unlocked.b2", SHELL.biome_unlocked(rules, s, 1)) or failed
	failed = _check(failed, "mig_a.flag", bool(s.get("migrated_board_v1", false))) or failed
	var face := {"pool_id": "b1", "index": 0, "ids": _ids("b1", 5)}
	failed = _check(failed, "mig_a.lever_spent", MODEL.lever_state(rules, s, face) == &"spent") or failed
	return failed


## (b) old one-behind start at b3 → still startable, no ceremony
func _migrate_b(rules: Dictionary) -> bool:
	var s: Dictionary = SHELL.fresh_state()
	_fill_stored(s, "b1", 5)
	_fill_stored(s, "b2", 5)
	_fill_stored(s, "b3", 5)
	s["migrated_board_v1"] = false
	s["map_pieces"] = ["b2", "b3", "b4"]
	s["shortcuts"] = []
	SHELL.normalize_with_rules(rules, s)
	var failed := false
	## Old can_start(2) needed 5 in b3 → grandfather b3.
	failed = _check(failed, "mig_b.can_start.b3", SHELL.can_start(rules, s, 2)) or failed
	failed = _check(failed, "mig_b.badge_seen", (s["shortcut_badge_seen"] as Array).has("b3")) or failed
	failed = _check(failed, "mig_b.no_fresh", not (s["shortcut_fresh"] as Array).has("b3")) or failed
	return failed


## (c) 4 lights with an open portal → lever spent, lights latched at 5
func _migrate_c(rules: Dictionary) -> bool:
	var s: Dictionary = SHELL.fresh_state()
	_fill_stored(s, "b1", 4)
	s["map_pieces"] = ["b2"]
	s["migrated_board_v1"] = true
	SHELL.normalize_with_rules(rules, s)
	var face := {"pool_id": "b1", "index": 0, "ids": _ids("b1", 14)}
	var failed := false
	failed = _check(failed, "mig_c.lights_latched", MODEL.lights_lit(rules, s, face) == 5) or failed
	failed = _check(failed, "mig_c.lever_spent", MODEL.lever_state(rules, s, face) == &"spent") or failed
	failed = _check(failed, "mig_c.claimed_4", MODEL.claimed_unique(s, face) == 4) or failed
	return failed


func _sequence_spy(rules: Dictionary) -> bool:
	var failed := false
	var host := Node.new()
	root.add_child(host)
	var seq = SEQ.new()
	host.add_child(seq)
	var state: Dictionary = SHELL.fresh_state()
	state["migrated_board_v1"] = true
	_fill_stored(state, "b1", 5)
	var cabin_node = load("res://scripts/dev/board_gates_cabin_shim.gd").new()
	host.add_child(cabin_node)
	cabin_node.bind(rules, state)
	## Let the SceneTree finish parenting before timers/tweens.
	await process_frame
	seq.reduce_motion = true
	Engine.time_scale = 8.0
	seq.setup(cabin_node, null, null, null, cabin_node)
	await seq.portal(0)
	failed = _check(failed, "seq.portal.b2", SHELL.portal_opened(cabin_node._campaign_shell.state, "b2")) or failed
	failed = _check(failed, "seq.reveal_bucket", seq.last_reveal_bucket == 2) or failed
	failed = _check(failed, "seq.map_reveal_opt", str(seq.last_map_opts.get("reveal", "")) == "b2") or failed
	Engine.time_scale = 1.0
	host.queue_free()
	return failed


func _fill_stored(state: Dictionary, pool: String, n: int) -> void:
	var banked: Dictionary = state.get("banked", {})
	if typeof(banked) != TYPE_DICTIONARY:
		banked = {}
		state["banked"] = banked
	for i in n:
		banked["%s_fill_%d" % [pool, i]] = pool


func _ids(pool: String, n: int) -> Array:
	var out: Array = []
	for i in n:
		out.append("%s_fill_%d" % [pool, i])
	return out


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		print("OK ", label)
		return failed
	print("FAIL ", label)
	return true
