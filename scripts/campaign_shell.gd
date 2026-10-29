class_name CampaignShell
extends RefCounted
## Campaign rules for the 5-biome shell. main.gd calls these. The selftest does too.


const SAVE_PATH := "user://campaign_save.json"
const DATA_PATH := "res://data/campaign.json"

var rules: Dictionary = {}
var state: Dictionary = {}


func load_all() -> void:
	rules = read_json(DATA_PATH)
	var disk: Dictionary = read_json(SAVE_PATH)
	state = fresh_state()
	if not disk.is_empty():
		_copy_state(disk)
	normalize(state)
	if bool(state.get("run", {}).get("active", false)):
		end_run(state)
		write()


func write() -> void:
	normalize(state)
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(state))


static func read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


static func fresh_state() -> Dictionary:
	return {
		"banked": {},
		"seen_deadly": [],
		"map_pieces": [],
		"endless_unlocked": false,
		"endless_best": 0,
		"won": false,
		"drawer_seen": false,
		"pencil_fresh": [],
		"mudroom_loadout": [],
		"next_run": {},
		"run": _idle_run(),
	}


static func normalize(state: Dictionary) -> void:
	if typeof(state.get("banked", {})) != TYPE_DICTIONARY:
		state["banked"] = {}
	var seen: Variant = state.get("seen_deadly", [])
	var clean: Array = []
	if typeof(seen) == TYPE_ARRAY or typeof(seen) == TYPE_PACKED_STRING_ARRAY:
		for raw_seen in seen:
			var seen_id := str(raw_seen)
			if seen_id != "" and not clean.has(seen_id):
				clean.append(seen_id)
	state["seen_deadly"] = clean
	state["endless_unlocked"] = bool(state.get("endless_unlocked", false))
	state["endless_best"] = maxi(0, int(state.get("endless_best", 0)))
	state["won"] = bool(state.get("won", false))
	state["drawer_seen"] = bool(state.get("drawer_seen", false))
	state["map_pieces"] = _clean_id_list(state.get("map_pieces", []))
	state["pencil_fresh"] = _clean_id_list(state.get("pencil_fresh", []))
	var pieces: Variant = state.get("map_pieces", [])
	var piece_clean: Array = []
	if typeof(pieces) == TYPE_ARRAY or typeof(pieces) == TYPE_PACKED_STRING_ARRAY:
		for raw_piece in pieces:
			var pid := str(raw_piece)
			if pid != "" and not piece_clean.has(pid):
				piece_clean.append(pid)
	state["map_pieces"] = piece_clean
	var loadout: Variant = state.get("mudroom_loadout", [])
	var load_clean: Array = []
	if typeof(loadout) == TYPE_ARRAY or typeof(loadout) == TYPE_PACKED_STRING_ARRAY:
		for raw_load in loadout:
			var lid := str(raw_load)
			if lid != "":
				load_clean.append(lid)
	state["mudroom_loadout"] = load_clean
	var next_run: Variant = state.get("next_run", {})
	if typeof(next_run) != TYPE_DICTIONARY:
		state["next_run"] = {}
	else:
		state["next_run"] = next_run
	var run: Dictionary = state.get("run", {})
	if typeof(run) != TYPE_DICTIONARY:
		run = {}
	var idle := _idle_run()
	for k in idle.keys():
		if not run.has(k):
			run[k] = idle[k]
	run["active"] = bool(run.get("active", false))
	run["biome_index"] = int(run.get("biome_index", 0))
	run["endless"] = bool(run.get("endless", false))
	run["shortcut"] = bool(run.get("shortcut", false))
	run["rerolls"] = maxi(0, int(run.get("rerolls", 0)))
	run["delve_granted"] = bool(run.get("delve_granted", false))
	state["run"] = run
	if bool(run.get("endless", false)) and bool(run.get("active", false)):
		var depth: int = maxi(1, int(run.get("biome_index", 0)) + 1)
		state["endless_best"] = maxi(int(state.get("endless_best", 0)), depth)


static func pool_for_bucket(rules: Dictionary, bucket: int) -> String:
	if bucket < 1:
		return ""
	var map: Variant = rules.get("card_pools", rules.get("bucket_pools", {}))
	if typeof(map) != TYPE_DICTIONARY:
		return ""
	return str((map as Dictionary).get(str(bucket), ""))


static func biomes_of(rules: Dictionary) -> Array:
	var raw: Variant = rules.get("biomes", [])
	return raw if typeof(raw) == TYPE_ARRAY else []


static func quota_of(rules: Dictionary) -> int:
	return maxi(1, int(rules.get("cabinet_quota", 5)))


static func deck_counts(rules: Dictionary) -> Vector2i:
	var deck: Dictionary = rules.get("deck", {})
	return Vector2i(maxi(1, int(deck.get("wheel", 6))), maxi(0, int(deck.get("reserve", 4))))


static func total_uniques(state: Dictionary) -> int:
	var banked: Dictionary = state.get("banked", {})
	return banked.size()


static func cabinet_count(state: Dictionary, pool: String) -> int:
	var n := 0
	var banked: Dictionary = state.get("banked", {})
	for id in banked.keys():
		if str(banked[id]) == pool:
			n += 1
	return n


static func map_unlocked(rules: Dictionary, _state: Dictionary = {}) -> bool:
	## start_gate_uniques 0: the held map works on the first Outpost visit.
	return total_uniques(_state) >= int(rules.get("start_gate_uniques", 0))


static func biome_unlocked(rules: Dictionary, state: Dictionary, index: int) -> bool:
	if index <= 0:
		return true
	var biomes := biomes_of(rules)
	if index >= biomes.size():
		return false
	var prev: Dictionary = biomes[index - 1]
	return cabinet_count(state, str(prev.get("id", ""))) >= quota_of(rules)


static func pool_unlocked(rules: Dictionary, state: Dictionary, pool: String) -> bool:
	var i := 0
	for raw in biomes_of(rules):
		var b: Dictionary = raw
		if str(b.get("id", "")) == pool:
			return biome_unlocked(rules, state, i)
		i += 1
	return false


static func pool_open_for_bucket(rules: Dictionary, state: Dictionary, bucket: int) -> bool:
	var pool := pool_for_bucket(rules, bucket)
	return pool != "" and pool_unlocked(rules, state, pool)


static func shortcut_open(rules: Dictionary, state: Dictionary, index: int) -> bool:
	var biomes := biomes_of(rules)
	if index < 0 or index >= biomes.size():
		return false
	return biome_unlocked(rules, state, index + 1)


## Index 0 is the normal run from the first biome. A later index can start once
## that biome is unlocked (the previous cabinet hit the quota and the path is
## penciled). The held map treats that click as a stamp shortcut: empty carry-in.
static func can_start(rules: Dictionary, state: Dictionary, index: int) -> bool:
	return biome_unlocked(rules, state, index)


static func can_push(rules: Dictionary, state: Dictionary) -> bool:
	var run: Dictionary = state.get("run", {})
	if not bool(run.get("active", false)):
		return false
	## Endless chains forever: Push is never Nib-gated there.
	if bool(run.get("endless", false)):
		return true
	var nxt: int = int(run.get("biome_index", 0)) + 1
	return biome_unlocked(rules, state, nxt)


## Hovering Push deeper shows Nib when this biome's cabinet is under quota.
## Never in Endless. Never at/above quota (even on the last biome where can_push is false).
static func push_needs_nib(rules: Dictionary, state: Dictionary) -> bool:
	var run: Dictionary = state.get("run", {})
	if not bool(run.get("active", false)) or bool(run.get("endless", false)):
		return false
	var pool := current_biome_id(rules, state)
	return cabinet_count(state, pool) < quota_of(rules)


static func current_biome_id(rules: Dictionary, state: Dictionary) -> String:
	var run: Dictionary = state.get("run", {})
	if bool(run.get("endless", false)):
		return str(rules.get("endless", {}).get("id", "endless"))
	var biomes := biomes_of(rules)
	var i: int = int(run.get("biome_index", 0))
	if i < 0 or i >= biomes.size():
		return "b1"
	return str((biomes[i] as Dictionary).get("id", "b1"))


static func biome_name(rules: Dictionary, biome_id: String) -> String:
	if biome_id == str(rules.get("endless", {}).get("id", "endless")):
		return str(rules.get("endless", {}).get("name", "Endless"))
	for raw in biomes_of(rules):
		var b: Dictionary = raw
		if str(b.get("id", "")) == biome_id:
			return str(b.get("name", biome_id))
	return biome_id


## How many uniques this pool would hold if the haul were banked now.
static func project_cabinet_count(state: Dictionary, pool: String, ids: Array, pools_by_id: Dictionary) -> int:
	var n := cabinet_count(state, pool)
	var banked: Dictionary = state.get("banked", {})
	var seen := {}
	for raw in ids:
		var id := str(raw)
		if id == "" or banked.has(id) or seen.has(id):
			continue
		if str(pools_by_id.get(id, "")) != pool:
			continue
		seen[id] = true
		n += 1
	return n


## Display name of the biome after the active run's current index, or "".
static func next_biome_name(rules: Dictionary, state: Dictionary) -> String:
	var run: Dictionary = state.get("run", {})
	if bool(run.get("endless", false)):
		return ""
	var biomes := biomes_of(rules)
	var i: int = int(run.get("biome_index", 0)) + 1
	if i < 0 or i >= biomes.size():
		return ""
	return str((biomes[i] as Dictionary).get("name", ""))


static func mix_for(rules: Dictionary, biome_id: String) -> Dictionary:
	if biome_id == str(rules.get("endless", {}).get("id", "endless")):
		var endless: Dictionary = rules.get("endless", {})
		var em: Dictionary = endless.get("mix", {})
		return em
	for raw in biomes_of(rules):
		var b: Dictionary = raw
		if str(b.get("id", "")) == biome_id:
			var mix: Dictionary = b.get("mix", {})
			return mix
	return {"weak": 6, "tough": 3, "deadly": 1}


static func begin_run(state: Dictionary, biome_index: int, shortcut: bool, endless: bool) -> void:
	normalize(state)
	var idx: int = 0 if endless else biome_index
	state["run"] = {
		"active": true,
		"biome_index": idx,
		"endless": endless,
		"shortcut": shortcut,
		"rerolls": 0,
		"delve_granted": false,
	}
	## Deadlies unique inside this run only, not across the save.
	state["seen_deadly"] = []
	if endless:
		state["endless_best"] = maxi(int(state.get("endless_best", 0)), 1)


static func map_piece_count(state: Dictionary) -> int:
	normalize(state)
	return (state.get("map_pieces", []) as Array).size()


## Next biome unlocked when filled_pool's cabinet crosses quota. Endless after b5.
static func next_after_pool(rules: Dictionary, filled_pool: String) -> Dictionary:
	var biomes := biomes_of(rules)
	for i in biomes.size():
		var b: Dictionary = biomes[i]
		if str(b.get("id", "")) != filled_pool:
			continue
		if i + 1 < biomes.size():
			var nxt: Dictionary = biomes[i + 1]
			return {
				"id": str(nxt.get("id", "")),
				"name": str(nxt.get("name", "")),
				"index": i + 1,
				"endless": false,
			}
		var endless: Dictionary = rules.get("endless", {})
		return {
			"id": str(endless.get("id", "endless")),
			"name": str(endless.get("name", "Endless")),
			"index": biomes.size(),
			"endless": true,
		}
	return {}


## Persist a map piece + fresh pencil toward the next biome. Idempotent per next id.
## Only call from the extract bank 5/5 ceremony — never cheats, death, or Push interrupt.
static func stamp_map_piece(rules: Dictionary, state: Dictionary, filled_pool: String) -> Dictionary:
	normalize(state)
	var nxt := next_after_pool(rules, filled_pool)
	var next_id := str(nxt.get("id", ""))
	if next_id == "":
		return {}
	var pieces: Array = state["map_pieces"]
	var fresh: Array = state["pencil_fresh"]
	var first := not pieces.has(next_id)
	if first:
		pieces.append(next_id)
	if not fresh.has(next_id):
		fresh.append(next_id)
	nxt["first"] = first
	nxt["filled"] = filled_pool
	return nxt


static func clear_pencil_fresh(state: Dictionary) -> void:
	normalize(state)
	state["pencil_fresh"] = []


static func grant_delve_reroll(rules: Dictionary, state: Dictionary) -> void:
	normalize(state)
	var run: Dictionary = state["run"]
	if bool(run.get("delve_granted", false)):
		return
	var add: int = maxi(1, int(rules.get("rerolls_per_delve", 1)))
	# +1 reroll perk per stamped map piece (Doop H). Rules key defaults to 1.
	var per_piece: int = maxi(0, int(rules.get("rerolls_per_map_piece", 1)))
	add += map_piece_count(state) * per_piece
	run["rerolls"] = int(run.get("rerolls", 0)) + add
	run["delve_granted"] = true


static func spend_reroll(state: Dictionary) -> bool:
	normalize(state)
	var run: Dictionary = state["run"]
	if int(run.get("rerolls", 0)) <= 0:
		return false
	run["rerolls"] = int(run["rerolls"]) - 1
	return true


static func push_deeper(rules: Dictionary, state: Dictionary) -> bool:
	if not can_push(rules, state):
		return false
	var run: Dictionary = state["run"]
	run["biome_index"] = int(run.get("biome_index", 0)) + 1
	run["shortcut"] = false
	run["delve_granted"] = false
	if bool(run.get("endless", false)):
		var depth: int = maxi(1, int(run.get("biome_index", 0)) + 1)
		state["endless_best"] = maxi(int(state.get("endless_best", 0)), depth)
	return true


static func end_run(state: Dictionary) -> void:
	normalize(state)
	state["run"] = _idle_run()


static func bank(rules: Dictionary, state: Dictionary, ids: Array, pools_by_id: Dictionary) -> Dictionary:
	normalize(state)
	var added: Array = []
	var banked: Dictionary = state["banked"]
	for raw in ids:
		var id := str(raw)
		if id == "" or banked.has(id):
			continue
		banked[id] = str(pools_by_id.get(id, ""))
		added.append(id)
	var already: bool = bool(state.get("won", false))
	var win := cabinets_complete(rules, state)
	if win:
		state["won"] = true
		state["endless_unlocked"] = true
	return {
		"added": added,
		"win": win,
		"show_drawer": win and not already and not bool(state.get("drawer_seen", false)),
		"map": map_unlocked(rules, state),
	}


static func mark_drawer_seen(state: Dictionary) -> void:
	normalize(state)
	state["drawer_seen"] = true


static func cabinets_complete(rules: Dictionary, state: Dictionary) -> bool:
	var q := quota_of(rules)
	for raw in biomes_of(rules):
		var b: Dictionary = raw
		if cabinet_count(state, str(b.get("id", ""))) < q:
			return false
	return not biomes_of(rules).is_empty()


static func debug_bank_matching(rules: Dictionary, state: Dictionary, entries: Array, n: int, pool: String) -> int:
	normalize(state)
	var got := 0
	var banked: Dictionary = state["banked"]
	for raw in entries:
		if got >= n:
			break
		var e: Dictionary = raw
		var id := str(e.get("id", ""))
		var p := str(e.get("pool", ""))
		if id == "" or banked.has(id):
			continue
		if pool != "" and p != pool:
			continue
		banked[id] = p
		got += 1
	if cabinets_complete(rules, state):
		state["won"] = true
		state["endless_unlocked"] = true
	return got


static func starter_tiers(rules: Dictionary, rng: RandomNumberGenerator) -> Array:
	var mix: Variant = rules.get("starter_item_mix", [3, 2, 1])
	var counts: Array = mix if typeof(mix) == TYPE_ARRAY else [3, 2, 1]
	var out: Array = []
	var tier := 1
	for raw in counts:
		for _i in int(raw):
			out.append(tier)
		tier += 1
	_shuffle(rng, out)
	return out


static func starter_hook_count(rules: Dictionary) -> int:
	var mix: Variant = rules.get("starter_item_mix", [3, 2, 1])
	var counts: Array = mix if typeof(mix) == TYPE_ARRAY else [3, 2, 1]
	var n := 0
	for raw in counts:
		n += int(raw)
	return maxi(1, n)


static func roll_mudroom_hooks(rules: Dictionary, rng: RandomNumberGenerator, items: Array, exclude: Array = []) -> Array:
	## One item id per starter_item_mix slot (tier totals unchanged).
	var tiers: Array = starter_tiers(rules, rng)
	var out: Array = []
	var used: Array = exclude.duplicate()
	for raw_t in tiers:
		var tier: int = int(raw_t)
		var pick: Array = _pick_n(rng, items, tier, used, 1)
		if pick.is_empty():
			pick = _pick_n(rng, items, tier, [], 1)
		if pick.is_empty():
			pick = _pick_n(rng, items, 0, used, 1)
		if pick.is_empty():
			pick = _pick_n(rng, items, 0, [], 1)
		if pick.is_empty():
			continue
		var id := str(pick[0])
		out.append(id)
		used.append(id)
	return out


static func set_mudroom_loadout(state: Dictionary, ids: Array) -> void:
	normalize(state)
	var clean: Array = []
	for raw in ids:
		var id := str(raw)
		if id != "":
			clean.append(id)
	state["mudroom_loadout"] = clean


static func mudroom_loadout_of(state: Dictionary) -> Array:
	normalize(state)
	return state.get("mudroom_loadout", [])


static func preview_rerolls(rules: Dictionary, state: Dictionary) -> int:
	## What the jar shows before a delve starts: base + map-piece perk.
	var add: int = maxi(1, int(rules.get("rerolls_per_delve", 1)))
	var per_piece: int = maxi(0, int(rules.get("rerolls_per_map_piece", 1)))
	var pieces: Array = state.get("map_pieces", [])
	if per_piece > 0 and typeof(pieces) == TYPE_ARRAY:
		add += per_piece * pieces.size()
	return add


static func take_pair(rng: RandomNumberGenerator, items: Array, tier: int, exclude: Array) -> Array:
	var picked := _pick_n(rng, items, tier, exclude, 2)
	if picked.size() < 2:
		picked = _pick_n(rng, items, tier, [], 2)
	if picked.size() < 2:
		picked = _pick_n(rng, items, 0, [], 2)
	return picked


static func compose(rules: Dictionary, rng: RandomNumberGenerator, monsters: Array, biome_id: String, used_deadly: Variant = null) -> Dictionary:
	var banned := {}
	if typeof(used_deadly) == TYPE_ARRAY:
		for raw_used in used_deadly:
			var uid := str(raw_used)
			if uid != "":
				banned[uid] = true
	var open: Array = []
	for raw_m in monsters:
		if typeof(raw_m) != TYPE_DICTIONARY:
			continue
		var m: Dictionary = raw_m
		var mid := str(m.get("id", ""))
		if mid == "":
			continue
		if int(m.get("tier", 0)) == 3 and banned.has(mid):
			continue
		open.append(m)
	var mix := mix_for(rules, biome_id)
	var counts := deck_counts(rules)
	var need: int = counts.x + counts.y
	var want := {
		1: int(mix.get("weak", 0)),
		2: int(mix.get("tough", 0)),
		3: int(mix.get("deadly", 0)),
	}
	var chosen: Array = []
	for tier in [3, 1, 2]:
		var left: int = int(want.get(tier, 0))
		while left > 0:
			var id := _pull(rng, open, chosen, tier, false)
			if id == "":
				break
			chosen.append(id)
			left -= 1
	while chosen.size() < need:
		var filler := _pull(rng, open, chosen, 0, true)
		if filler == "":
			break
		var ft := _tier_of_id(open, filler)
		if ft == 3 and _count_tier(open, chosen, 3) >= int(want.get(3, 0)):
			var other := _pull(rng, open, chosen, -3, true)
			if other != "":
				filler = other
		chosen.append(filler)
	if chosen.size() < need and not open.is_empty():
		var guard := 0
		while chosen.size() < need and guard < need * 4:
			guard += 1
			var any: Dictionary = open[rng.randi_range(0, open.size() - 1)]
			var aid := str(any.get("id", ""))
			if aid == "":
				continue
			if int(any.get("tier", 0)) == 3 and (chosen.has(aid) or _count_tier(open, chosen, 3) >= int(want.get(3, 0))):
				continue
			chosen.append(aid)
	if chosen.size() > need:
		chosen = chosen.slice(0, need)
	_shuffle(rng, chosen)
	var telegraph: Array = []
	for id2 in chosen:
		if _tier_of_id(open, str(id2)) == 3:
			var boss := str(id2)
			telegraph.append(boss)
			if typeof(used_deadly) == TYPE_ARRAY and not used_deadly.has(boss):
				used_deadly.append(boss)
	return {"ids": chosen, "telegraph": telegraph, "short": chosen.size() < need}


## Seed every biome's next-run deck once, with Deadlies unique across b1..b5.
## Does not touch state.seen_deadly — that stays a per-run memory.
static func seed_next_run(rules: Dictionary, state: Dictionary, rows: Array, seed: int) -> void:
	normalize(state)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed if seed != 0 else 1
	var used: Array = []
	var deals: Dictionary = {}
	for n in range(1, 6):
		var pool := "b%d" % n
		var deal: Dictionary = compose(rules, rng, rows, pool, used)
		deals[pool] = {
			"ids": (deal.get("ids", []) as Array).duplicate(),
			"telegraph": (deal.get("telegraph", []) as Array).duplicate(),
		}
	state["next_run"] = {
		"seed": seed,
		"deals": deals,
	}


## Consume a seeded biome deal for arm_delve. Filters against seen_deadly, refills
## via compose when short, then appends the final telegraph to seen_deadly.
static func consume_next_run_deal(
	rules: Dictionary,
	state: Dictionary,
	rows: Array,
	biome_id: String,
	rng: RandomNumberGenerator
) -> Dictionary:
	normalize(state)
	var used: Array = state["seen_deadly"]
	var nr: Variant = state.get("next_run", {})
	var deals: Dictionary = {}
	if typeof(nr) == TYPE_DICTIONARY:
		var raw_deals: Variant = (nr as Dictionary).get("deals", {})
		if typeof(raw_deals) == TYPE_DICTIONARY:
			deals = raw_deals
	if not deals.has(biome_id):
		var fallback: Dictionary = compose(rules, rng, rows, biome_id, used)
		state["seen_deadly"] = used
		return fallback
	var seeded: Dictionary = deals[biome_id]
	var ids: Array = []
	var telegraph: Array = []
	for raw_id in seeded.get("ids", []):
		var sid := str(raw_id)
		if sid != "" and not used.has(sid):
			ids.append(sid)
	for raw_tel in seeded.get("telegraph", []):
		var tid := str(raw_tel)
		if tid != "" and not used.has(tid):
			telegraph.append(tid)
	var mix := mix_for(rules, biome_id)
	var want_deadly: int = int(mix.get("deadly", 0))
	var counts := deck_counts(rules)
	var need: int = counts.x + counts.y
	if telegraph.size() < want_deadly or ids.size() < need:
		var banned: Array = used.duplicate()
		for keep_t in telegraph:
			if not banned.has(keep_t):
				banned.append(keep_t)
		var refill: Dictionary = compose(rules, rng, rows, biome_id, banned)
		for add_t in refill.get("telegraph", []):
			var ats := str(add_t)
			if telegraph.size() >= want_deadly:
				break
			if ats == "" or telegraph.has(ats):
				continue
			telegraph.append(ats)
			if not ids.has(ats):
				ids.append(ats)
		for add_id in refill.get("ids", []):
			if ids.size() >= need:
				break
			var aid := str(add_id)
			if aid == "" or ids.has(aid) or used.has(aid):
				continue
			ids.append(aid)
		if ids.size() > need:
			ids = ids.slice(0, need)
	for boss in telegraph:
		var bid := str(boss)
		if bid != "" and not used.has(bid):
			used.append(bid)
	state["seen_deadly"] = used
	return {"ids": ids, "telegraph": telegraph, "short": ids.size() < need}


func _copy_state(disk: Dictionary) -> void:
	## Older user://campaign_save.json files omit keys added later (map_pieces,
	## mudroom_loadout, pencil_fresh, endless_best, …). Never hard-index a key
	## after disk.get(key, default): the default makes typeof pass even when
	## the key is absent, then disk[key] crashes.
	state = fresh_state()
	if disk.has("banked") and typeof(disk["banked"]) == TYPE_DICTIONARY:
		state["banked"] = (disk["banked"] as Dictionary).duplicate(true)
	if disk.has("seen_deadly") and typeof(disk["seen_deadly"]) == TYPE_ARRAY:
		state["seen_deadly"] = (disk["seen_deadly"] as Array).duplicate()
	state["map_pieces"] = _clean_id_list(disk.get("map_pieces", []))
	state["pencil_fresh"] = _clean_id_list(disk.get("pencil_fresh", []))
	if disk.has("mudroom_loadout") and typeof(disk["mudroom_loadout"]) == TYPE_ARRAY:
		state["mudroom_loadout"] = (disk["mudroom_loadout"] as Array).duplicate()
	## Older saves omit next_run — default {} (never hard-index a missing key).
	if disk.has("next_run") and typeof(disk["next_run"]) == TYPE_DICTIONARY:
		state["next_run"] = (disk["next_run"] as Dictionary).duplicate(true)
	else:
		state["next_run"] = {}
	state["endless_unlocked"] = bool(disk.get("endless_unlocked", false))
	state["endless_best"] = maxi(0, int(disk.get("endless_best", 0)))
	state["won"] = bool(disk.get("won", false))
	state["drawer_seen"] = bool(disk.get("drawer_seen", false))
	if disk.has("run") and typeof(disk["run"]) == TYPE_DICTIONARY:
		state["run"] = (disk["run"] as Dictionary).duplicate(true)


static func _clean_id_list(raw: Variant) -> Array:
	var clean: Array = []
	if typeof(raw) != TYPE_ARRAY and typeof(raw) != TYPE_PACKED_STRING_ARRAY:
		return clean
	for item in raw:
		var sid := str(item)
		if sid != "" and not clean.has(sid):
			clean.append(sid)
	return clean


static func _idle_run() -> Dictionary:
	return {
		"active": false,
		"biome_index": 0,
		"endless": false,
		"shortcut": false,
		"rerolls": 0,
		"delve_granted": false,
	}


static func _pick_n(rng: RandomNumberGenerator, items: Array, tier: int, exclude: Array, n: int) -> Array:
	var skip := {}
	for raw in exclude:
		skip[str(raw)] = true
	var bag: Array = []
	for raw_it in items:
		var it: Dictionary = raw_it
		var id := str(it.get("id", ""))
		if id == "" or skip.has(id):
			continue
		var t := int(it.get("tier", 0))
		if tier > 0 and t != tier:
			continue
		if tier == -3 and t == 3:
			continue
		bag.append(id)
	_shuffle(rng, bag)
	var out: Array = []
	for i in mini(n, bag.size()):
		out.append(bag[i])
	return out


static func _pull(rng: RandomNumberGenerator, monsters: Array, chosen: Array, tier: int, relax: bool) -> String:
	var bag: Array = []
	for raw in monsters:
		var m: Dictionary = raw
		var id := str(m.get("id", ""))
		if id == "" or chosen.has(id):
			continue
		var t := int(m.get("tier", 0))
		if tier == -3 and t == 3:
			continue
		if tier > 0 and t != tier:
			continue
		if not relax and _blocked(monsters, chosen, m):
			continue
		bag.append(id)
	if bag.is_empty():
		return ""
	return str(bag[rng.randi_range(0, bag.size() - 1)])


static func _blocked(monsters: Array, chosen: Array, monster: Dictionary) -> bool:
	var id := str(monster.get("id", ""))
	var mine: Array = monster.get("contra", [])
	if typeof(mine) != TYPE_ARRAY:
		mine = []
	for raw in chosen:
		var other := str(raw)
		if other == id or mine.has(other):
			return true
		for raw_m in monsters:
			var prev: Dictionary = raw_m
			if str(prev.get("id", "")) != other:
				continue
			var theirs: Array = prev.get("contra", [])
			if typeof(theirs) == TYPE_ARRAY and theirs.has(id):
				return true
	return false


static func _tier_of_id(monsters: Array, id: String) -> int:
	for raw in monsters:
		var m: Dictionary = raw
		if str(m.get("id", "")) == id:
			return int(m.get("tier", 0))
	return 0


static func _count_tier(monsters: Array, chosen: Array, tier: int) -> int:
	var n := 0
	for raw in chosen:
		if _tier_of_id(monsters, str(raw)) == tier:
			n += 1
	return n


static func _shuffle(rng: RandomNumberGenerator, arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp: Variant = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
