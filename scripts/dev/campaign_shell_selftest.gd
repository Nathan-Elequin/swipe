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
	var prev_weak := 99
	var prev_tough := -1
	for raw in Shell.biomes_of(rules):
		var b: Dictionary = raw
		var mix: Dictionary = b.get("mix", {})
		var w := int(mix.get("weak", 0))
		var t := int(mix.get("tough", 0))
		var d := int(mix.get("deadly", 0))
		failed = _check(failed, "%s totals 10" % b.get("id", ""), w + t + d == 10) or failed
		failed = _check(failed, "%s two deadly" % b.get("id", ""), d == 2) or failed
		failed = _check(failed, "%s weak falls" % b.get("id", ""), w < prev_weak) or failed
		failed = _check(failed, "%s tough rises" % b.get("id", ""), t > prev_tough) or failed
		prev_weak = w
		prev_tough = t
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
	var mons: Array = []
	for n in 8:
		mons.append({"id": "w%d" % n, "tier": 1, "contra": []})
	for n2 in 8:
		mons.append({"id": "t%d" % n2, "tier": 2, "contra": []})
	mons.append({"id": "d0", "tier": 3, "contra": ["d1"]})
	mons.append({"id": "d1", "tier": 3, "contra": []})
	mons.append({"id": "d2", "tier": 3, "contra": []})
	mons.append({"id": "d3", "tier": 3, "contra": []})
	var deal: Dictionary = Shell.compose(rules, rng, mons, "b1")
	var ids: Array = deal["ids"]
	var telegraph: Array = deal["telegraph"]
	failed = _check(failed, "ten monsters", ids.size() == 10) or failed
	failed = _check(failed, "two telegraphed", telegraph.size() == 2) or failed
	var deadly_n := 0
	for id in ids:
		if str(id).begins_with("d"):
			deadly_n += 1
	for boss in telegraph:
		failed = _check(failed, "boss present %s" % boss, ids.has(boss)) or failed
	failed = _check(failed, "exactly two deadly", deadly_n == 2) or failed
	failed = _check(failed, "conflict respected", not (ids.has("d0") and ids.has("d1"))) or failed
	var full: Dictionary = Shell.fresh_state()
	for bi in Shell.biomes_of(rules):
		var pool := str((bi as Dictionary).get("id", ""))
		for k in 5:
			Shell.bank(rules, full, ["%s_%s" % [pool, k]], {"%s_%s" % [pool, k]: pool})
	failed = _check(failed, "win", bool(full.get("won", false)) and bool(full.get("endless_unlocked", false))) or failed
	var again: Dictionary = Shell.bank(rules, full, ["extra"], {"extra": "b1"})
	failed = _check(failed, "drawer once", bool(again.get("show_drawer", true)) == false) or failed
	if failed:
		print("CAMPAIGN_SHELL_FAIL")
		quit(1)
		return
	print("CAMPAIGN_SHELL_OK")
	quit(0)


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
