extends SceneTree
## Headless: which next_run seeds deal Juggernaut (pool b2) into Verdant / any biome.
## Also checks fresh saves get distinct random seeds unless SPIN_RUN_SEED is set.
## Run: godot --headless --path . --script res://scripts/dev/juggernaut_seed_scan_selftest.gd


const OK_MARK := "JUGGERNAUT_SEED_SCAN_OK"
const FAIL_MARK := "JUGGERNAUT_SEED_SCAN_FAIL"
const Shell = preload("res://scripts/campaign_shell.gd")
const BucketRules = preload("res://scripts/bucket_rules.gd")
const ModePool = preload("res://scripts/mode_pool.gd")

const SCAN_N := 400
const REPORT_CAP := 40


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var rows: Array = []
	var rules: Dictionary = Shell.read_json(Shell.DATA_PATH)
	var catalog: Dictionary = Shell.read_json("res://data/catalog.json")
	var runtime: Dictionary = Shell.read_json("res://data/runtime.json")
	var runtime_mons: Array = runtime.get("monsters", [])
	failed = _check(rows, failed, "runtime.has_juggernaut", runtime_mons.has("juggernaut"), "") or failed

	var roster: Array = _campaign_seed_roster(catalog)
	var has_jugg_row := false
	for raw in roster:
		if str((raw as Dictionary).get("id", "")) == "juggernaut":
			has_jugg_row = true
			failed = _check(rows, failed, "juggernaut.pool_b2",
				str((raw as Dictionary).get("pool", "")) == "b2",
				str((raw as Dictionary).get("pool", ""))) or failed
			break
	failed = _check(rows, failed, "roster.includes_juggernaut", has_jugg_row, "") or failed

	## Random seed helper: two consecutive rolls must differ (no forced env).
	OS.set_environment("SPIN_RUN_SEED", "")
	var s1: int = _roll_like_main()
	var s2: int = _roll_like_main()
	failed = _check(rows, failed, "seed.random_differs", s1 != s2, "s1=%s s2=%s" % [s1, s2]) or failed

	## Explicit seed wins.
	OS.set_environment("SPIN_RUN_SEED", "99")
	failed = _check(rows, failed, "seed.explicit_env", _roll_like_main() == 99, "") or failed
	OS.set_environment("SPIN_RUN_SEED", "")

	## Fresh state (b1 only): Juggernaut must not leak into Verdant.
	var locked: Dictionary = Shell.fresh_state()
	Shell.seed_next_run(rules, locked, roster, 21)
	var locked_b1: Array = ((locked.get("next_run", {}) as Dictionary).get("deals", {}) as Dictionary).get("b1", {}).get("ids", [])
	failed = _check(rows, failed, "fresh.verdant_no_juggernaut",
		not locked_b1.has("juggernaut"), str(locked_b1)) or failed

	## Middle Progress-style: b2+b3 open so pool-2 mill mixes into Verdant.
	var hits_b1: Array = []
	var hits_any: Array = []
	for i in SCAN_N:
		var seed: int = i + 1
		var state: Dictionary = Shell.fresh_state()
		state["map_pieces"] = ["b2", "b3"]
		Shell.seed_next_run(rules, state, roster, seed)
		var deals: Dictionary = (state.get("next_run", {}) as Dictionary).get("deals", {})
		var in_b1 := false
		var in_any := false
		for biome_id in ["b1", "b2", "b3", "b4", "b5"]:
			var ids: Array = (deals.get(biome_id, {}) as Dictionary).get("ids", [])
			if ids.has("juggernaut"):
				in_any = true
				if biome_id == "b1":
					in_b1 = true
		if in_b1 and hits_b1.size() < REPORT_CAP:
			hits_b1.append(seed)
		if in_any and hits_any.size() < REPORT_CAP:
			hits_any.append(seed)

	failed = _check(rows, failed, "scan.juggernaut_in_verdant",
		hits_b1.size() > 0, "0/%s seeds" % SCAN_N) or failed
	failed = _check(rows, failed, "scan.juggernaut_any_biome",
		hits_any.size() > 0, "0/%s seeds" % SCAN_N) or failed

	print("JUGGERNAUT_SEEDS_VERDANT %s" % _join_ints(hits_b1))
	print("JUGGERNAUT_SEEDS_ANY %s" % _join_ints(hits_any))
	print("JUGGERNAUT_SCAN_N %s verdant_hits=%s any_hits_capped=%s" % [
		SCAN_N, hits_b1.size(), hits_any.size()
	])

	for r in rows:
		print(r)
	if failed:
		print(FAIL_MARK)
		quit(1)
	else:
		print(OK_MARK)
		quit(0)


func _roll_like_main() -> int:
	## Mirror scripts/main.gd `_campaign_next_run_seed` (no main instance).
	var env_raw := OS.get_environment("SPIN_RUN_SEED").strip_edges()
	if env_raw.is_valid_int():
		var env_n: int = int(env_raw)
		return env_n if env_n != 0 else 1
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var seed: int = int(Time.get_ticks_usec()) ^ int(Time.get_unix_time_from_system()) ^ rng.randi()
	if seed == 0:
		seed = int(Time.get_ticks_msec()) | 1
	return seed


func _campaign_seed_roster(catalog: Dictionary) -> Array:
	var rows: Array = []
	var rules: Dictionary = Shell.read_json(Shell.DATA_PATH)
	var mons: Variant = catalog.get("monsters", [])
	if typeof(mons) != TYPE_ARRAY:
		return rows
	for raw in mons:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var card: Dictionary = raw
		var st := str(card.get("status", "live"))
		if st == "retired" or st == "hold":
			continue
		if not ModePool.allows(card, ModePool.ADVENTURE):
			continue
		var cid := str(card.get("id", ""))
		if cid == "" or cid == "smoke_bomb" or BucketRules.is_always_starter_id(cid):
			continue
		if BucketRules.is_token(card):
			continue
		var pool := Shell.pool_for_bucket(rules, BucketRules.of_card(card))
		if pool == "":
			continue
		rows.append({
			"id": cid,
			"tier": int(card.get("tier", 1)),
			"contra": [],
			"pool": pool,
		})
	return rows


func _join_ints(vals: Array) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for v in vals:
		parts.append(str(v))
	return ",".join(parts)


func _check(rows: Array, failed: bool, name: String, ok: bool, detail: String) -> bool:
	rows.append("%s %s%s" % ["PASS" if ok else "FAIL", name, (": " + detail) if (not ok and detail != "") else ""])
	return failed or not ok
