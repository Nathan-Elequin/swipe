extends SceneTree
## Headless checks for the campaign shell. Does not boot main.gd.


func _init() -> void:
	var Shell = load("res://scripts/campaign_shell.gd")
	var rules: Dictionary = Shell.read_json("res://data/campaign.json")
	var failed := false
	var locked_names: Array[String] = ["Verdant Hollow", "Sunken Mire", "Ashen Crypt", "Cinder Forge", "Shadow Abyss"]
	failed = _check(failed, "five biomes", Shell.biomes_of(rules).size() == 5) or failed
	var named := 0
	for raw_name in Shell.biomes_of(rules):
		var named_biome: Dictionary = raw_name
		var want: String = locked_names[named] if named < locked_names.size() else ""
		failed = _check(failed, "name %s" % want, str(named_biome.get("name", "")) == want) or failed
		named += 1
	failed = _check(failed, "deck 6+4", Shell.deck_counts(rules) == Vector2i(6, 4)) or failed
	var expect := {
		"b1": Vector3i(6, 3, 1),
		"b2": Vector3i(5, 3, 2),
		"b3": Vector3i(4, 4, 2),
		"b4": Vector3i(3, 5, 2),
		"b5": Vector3i(3, 4, 3),
	}
	for raw in Shell.biomes_of(rules):
		var b: Dictionary = raw
		var id := str(b.get("id", ""))
		var mix: Dictionary = Shell.mix_for(rules, id)
		var w := int(mix.get("weak", 0))
		var t := int(mix.get("tough", 0))
		var d := int(mix.get("deadly", 0))
		var want: Vector3i = expect.get(id, Vector3i(-1, -1, -1))
		failed = _check(failed, "%s totals 10" % id, w + t + d == 10) or failed
		failed = _check(failed, "%s locked mix" % id, want == Vector3i(w, t, d)) or failed
	var fb: Dictionary = Shell.mix_for(rules, "missing")
	failed = _check(failed, "unknown biome uses cellar mix", int(fb.get("weak", 0)) == 6 and int(fb.get("tough", 0)) == 3 and int(fb.get("deadly", 0)) == 1) or failed
	var state: Dictionary = Shell.fresh_state()
	failed = _check(failed, "map shut", Shell.map_unlocked(rules, state) == false) or failed
	failed = _check(failed, "only verdant hollow starts", Shell.can_start(rules, state, 0) and not Shell.can_start(rules, state, 1)) or failed
	var pools := {"a": "b1", "b": "b1", "c": "b1", "d": "b1", "e": "b1"}
	Shell.bank(rules, state, ["a", "b", "c"], pools)
	failed = _check(failed, "gate at 3", Shell.map_unlocked(rules, state)) or failed
	failed = _check(failed, "verdant hollow counts the 3", Shell.cabinet_count(state, "b1") == 3) or failed
	failed = _check(failed, "sunken mire still locked", Shell.biome_unlocked(rules, state, 1) == false) or failed
	failed = _check(failed, "no push yet", Shell.can_push(rules, state) == false) or failed
	Shell.bank(rules, state, ["d", "e"], pools)
	failed = _check(failed, "verdant hollow full", Shell.cabinet_count(state, "b1") == 5) or failed
	failed = _check(failed, "sunken mire opens", Shell.biome_unlocked(rules, state, 1)) or failed
	failed = _check(failed, "stamp starts sunken mire", Shell.can_start(rules, state, 1)) or failed
	failed = _check(failed, "ashen crypt stays shut", Shell.can_start(rules, state, 2) == false) or failed
	failed = _check(failed, "shortcut to verdant hollow", Shell.shortcut_open(rules, state, 0)) or failed
	failed = _check(failed, "no shortcut to sunken mire yet", Shell.shortcut_open(rules, state, 1) == false) or failed
	Shell.begin_run(state, 0, false, false)
	failed = _check(failed, "can push into sunken mire", Shell.can_push(rules, state)) or failed
	Shell.grant_delve_reroll(rules, state)
	failed = _check(failed, "one reroll", int(state["run"]["rerolls"]) == 1) or failed
	Shell.grant_delve_reroll(rules, state)
	failed = _check(failed, "grant once", int(state["run"]["rerolls"]) == 1) or failed
	failed = _check(failed, "push", Shell.push_deeper(rules, state)) or failed
	failed = _check(failed, "carried the reroll", int(state["run"]["rerolls"]) == 1) or failed
	Shell.grant_delve_reroll(rules, state)
	failed = _check(failed, "next delve adds one", int(state["run"]["rerolls"]) == 2) or failed
	Shell.begin_run(state, 1, true, false)
	failed = _check(failed, "shortcut starts empty", int(state["run"]["rerolls"]) == 0 and bool(state["run"]["shortcut"])) or failed
	Shell.end_run(state)
	failed = _check(failed, "home clears rerolls", int(state["run"]["rerolls"]) == 0 and not bool(state["run"]["active"])) or failed
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var tiers: Array = Shell.starter_tiers(rules, rng)
	failed = _check(failed, "six offers", tiers.size() == 6) or failed
	failed = _check(failed, "mix 3 weak", _count(tiers, 1) == 3) or failed
	failed = _check(failed, "mix 2 tough", _count(tiers, 2) == 2) or failed
	failed = _check(failed, "mix 1 deadly", _count(tiers, 3) == 1) or failed
	var items: Array = [
		{"id": "w1", "tier": 1}, {"id": "w2", "tier": 1}, {"id": "w3", "tier": 1}, {"id": "w4", "tier": 1},
	]
	var kept: Array = Shell.take_pair(rng, items, 1, ["w1", "w2"])
	failed = _check(failed, "reroll skips discards", kept.size() == 2 and not kept.has("w1") and not kept.has("w2")) or failed
	var fallback: Array = Shell.take_pair(rng, [{"id": "only", "tier": 1}, {"id": "only", "tier": 1}], 1, ["only"])
	failed = _check(failed, "reroll cannot soft-lock", fallback.size() == 2) or failed
	var mons: Array = _roster(8, 8, 4, true)
	var deal: Dictionary = Shell.compose(rules, rng, mons, "b2")
	var ids: Array = deal["ids"]
	var telegraph: Array = deal["telegraph"]
	failed = _check(failed, "ten monsters", ids.size() == 10) or failed
	failed = _check(failed, "b2 two telegraphed", telegraph.size() == 2) or failed
	failed = _check(failed, "b2 weak", _count_ids(ids, mons, 1) == 5) or failed
	failed = _check(failed, "b2 tough", _count_ids(ids, mons, 2) == 3) or failed
	failed = _check(failed, "b2 deadly", _count_ids(ids, mons, 3) == 2) or failed
	for boss in telegraph:
		failed = _check(failed, "boss present %s" % boss, ids.has(boss)) or failed
	failed = _check(failed, "conflict respected", not (ids.has("d0") and ids.has("d1"))) or failed
	var roster: Array = _roster(8, 8, 10, true)
	var used: Array = []
	var seen := {}
	var deal_rng := RandomNumberGenerator.new()
	deal_rng.seed = 11
	for biome_id in ["b1", "b2", "b3", "b4", "b5"]:
		var one: Dictionary = Shell.compose(rules, deal_rng, roster, str(biome_id), used)
		var one_ids: Array = one["ids"]
		var one_tel: Array = one["telegraph"]
		var want2: Vector3i = expect[str(biome_id)]
		failed = _check(failed, "%s deck 10" % biome_id, one_ids.size() == 10) or failed
		failed = _check(failed, "%s deck weak" % biome_id, _count_ids(one_ids, roster, 1) == want2.x) or failed
		failed = _check(failed, "%s deck tough" % biome_id, _count_ids(one_ids, roster, 2) == want2.y) or failed
		failed = _check(failed, "%s deck deadly" % biome_id, _count_ids(one_ids, roster, 3) == want2.z) or failed
		failed = _check(failed, "%s telegraph" % biome_id, one_tel.size() == want2.z) or failed
		for tel_id in one_tel:
			var sid := str(tel_id)
			failed = _check(failed, "deadly once %s" % sid, not seen.has(sid)) or failed
			seen[sid] = true
			failed = _check(failed, "deadly dealt %s" % sid, one_ids.has(sid)) or failed
	failed = _check(failed, "ten deadly across the save", seen.size() == 10 and used.size() == 10) or failed
	var replay: Dictionary = Shell.compose(rules, deal_rng, roster, "b1", used)
	var replay_ids: Array = replay["ids"]
	failed = _check(failed, "replay still fills 10", replay_ids.size() == 10) or failed
	failed = _check(failed, "replay adds no deadly", replay["telegraph"].size() == 0 and _count_ids(replay_ids, roster, 3) == 0) or failed
	var short_roster: Array = _roster(8, 8, 2, false)
	var short_used: Array = []
	var short_rng := RandomNumberGenerator.new()
	short_rng.seed = 3
	var first: Dictionary = Shell.compose(rules, short_rng, short_roster, "b1", short_used)
	var second: Dictionary = Shell.compose(rules, short_rng, short_roster, "b2", short_used)
	var first_deadly := ""
	for fid in first["telegraph"]:
		first_deadly = str(fid)
	failed = _check(failed, "short b1 one deadly", _count_ids(first["ids"], short_roster, 3) == 1 and first["ids"].size() == 10) or failed
	failed = _check(failed, "short b2 does not repeat", _count_ids(second["ids"], short_roster, 3) == 1 and second["ids"].size() == 10) or failed
	failed = _check(failed, "short b2 different deadly", first_deadly != "" and not second["ids"].has(first_deadly)) or failed
	var memory: Dictionary = Shell.fresh_state()
	var memory_rng := RandomNumberGenerator.new()
	memory_rng.seed = 5
	Shell.compose(rules, memory_rng, roster, "b5", memory["seen_deadly"])
	failed = _check(failed, "save remembers deadly", memory["seen_deadly"].size() == 3) or failed
	Shell.end_run(memory)
	failed = _check(failed, "home keeps seen deadly", memory["seen_deadly"].size() == 3) or failed
	var full: Dictionary = Shell.fresh_state()
	for bi in Shell.biomes_of(rules):
		var pool := str((bi as Dictionary).get("id", ""))
		for k in 5:
			Shell.bank(rules, full, ["%s_%s" % [pool, k]], {"%s_%s" % [pool, k]: pool})
	failed = _check(failed, "win", bool(full.get("won", false)) and bool(full.get("endless_unlocked", false))) or failed
	var again: Dictionary = Shell.bank(rules, full, ["extra"], {"extra": "b1"})
	failed = _check(failed, "drawer once", bool(again.get("show_drawer", true)) == false) or failed
	## S8 / R5: Endless Push chains and deepest record updates.
	Shell.begin_run(full, 0, false, true)
	failed = _check(failed, "endless can push", Shell.can_push(rules, full)) or failed
	failed = _check(failed, "endless best starts at 1", int(full.get("endless_best", 0)) >= 1) or failed
	failed = _check(failed, "endless push", Shell.push_deeper(rules, full)) or failed
	failed = _check(failed, "endless still pushable", Shell.can_push(rules, full)) or failed
	failed = _check(failed, "endless best grew", int(full.get("endless_best", 0)) >= 2) or failed
	Shell.end_run(full)
	failed = _check(failed, "endless best kept at home", int(full.get("endless_best", 0)) >= 2) or failed
	## Map pieces add delve rerolls when rerolls_per_map_piece is set.
	var piece_state: Dictionary = Shell.fresh_state()
	piece_state["map_pieces"] = ["b2", "b3"]
	Shell.begin_run(piece_state, 0, false, false)
	Shell.grant_delve_reroll(rules, piece_state)
	var want_rolls: int = 1 + int(rules.get("rerolls_per_map_piece", 1)) * 2
	failed = _check(failed, "map piece rerolls", int(piece_state["run"]["rerolls"]) == want_rolls) or failed
	var hooks: Array = Shell.roll_mudroom_hooks(rules, rng, [
		{"id": "a", "tier": 1}, {"id": "b", "tier": 1}, {"id": "c", "tier": 1}, {"id": "d", "tier": 1},
		{"id": "e", "tier": 2}, {"id": "f", "tier": 2}, {"id": "g", "tier": 2},
		{"id": "h", "tier": 3}, {"id": "i", "tier": 3},
	])
	failed = _check(failed, "mudroom hooks match mix", hooks.size() == 6) or failed
	if failed:
		print("CAMPAIGN_SHELL_FAIL")
		quit(1)
		return
	print("CAMPAIGN_SHELL_OK")
	quit(0)


func _roster(weak_n: int, tough_n: int, deadly_n: int, contra: bool) -> Array:
	var mons: Array = []
	for n in weak_n:
		mons.append({"id": "w%d" % n, "tier": 1, "contra": []})
	for n2 in tough_n:
		mons.append({"id": "t%d" % n2, "tier": 2, "contra": []})
	for n3 in deadly_n:
		var contra_ids: Array = ["d1"] if contra and n3 == 0 else []
		mons.append({"id": "d%d" % n3, "tier": 3, "contra": contra_ids})
	return mons


func _count_ids(ids: Array, monsters: Array, tier: int) -> int:
	var n := 0
	for raw_id in ids:
		var id := str(raw_id)
		for raw in monsters:
			var m: Dictionary = raw
			if str(m.get("id", "")) == id and int(m.get("tier", 0)) == tier:
				n += 1
				break
	return n


func _count(arr: Array, want: int) -> int:
	var n := 0
	for v in arr:
		if int(v) == want:
			n += 1
	return n


func _check(failed: bool, label: String, ok: bool) -> bool:
	if ok:
		return failed
	push_error(label)
	return true
