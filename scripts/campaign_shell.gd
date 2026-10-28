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
		"endless_unlocked": false,
		"won": false,
		"drawer_seen": false,
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
	state["won"] = bool(state.get("won", false))
	state["drawer_seen"] = bool(state.get("drawer_seen", false))
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


static func pool_for_bucket(rules: Dictionary, bucket: int) -> String:
	if bucket < 0:
		return ""
	return str(rules.get("bucket_pools", {}).get(str(bucket), ""))


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


static func map_unlocked(rules: Dictionary, state: Dictionary) -> bool:
	return total_uniques(state) >= int(rules.get("start_gate_uniques", 3))


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


static func can_start(rules: Dictionary, state: Dictionary, index: int) -> bool:
	if not biome_unlocked(rules, state, index):
		return false
	if index <= 0:
		return true
	if not map_unlocked(rules, state):
		return false
	return shortcut_open(rules, state, index)


static func can_push(rules: Dictionary, state: Dictionary) -> bool:
	var run: Dictionary = state.get("run", {})
	if not bool(run.get("active", false)) or bool(run.get("endless", false)):
		return false
	var nxt: int = int(run.get("biome_index", 0)) + 1
	if not map_unlocked(rules, state):
		return false
	return biome_unlocked(rules, state, nxt)


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
	state["run"] = {
		"active": true,
		"biome_index": biome_index,
		"endless": endless,
		"shortcut": shortcut,
		"rerolls": 0,
		"delve_granted": false,
	}


static func grant_delve_reroll(rules: Dictionary, state: Dictionary) -> void:
	normalize(state)
	var run: Dictionary = state["run"]
	if bool(run.get("delve_granted", false)):
		return
	var add: int = maxi(1, int(rules.get("rerolls_per_delve", 1)))
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


func _copy_state(disk: Dictionary) -> void:
	state = fresh_state()
	if typeof(disk.get("banked", {})) == TYPE_DICTIONARY:
		state["banked"] = (disk["banked"] as Dictionary).duplicate(true)
	if typeof(disk.get("seen_deadly", [])) == TYPE_ARRAY:
		state["seen_deadly"] = (disk["seen_deadly"] as Array).duplicate()
	state["endless_unlocked"] = bool(disk.get("endless_unlocked", false))
	state["won"] = bool(disk.get("won", false))
	state["drawer_seen"] = bool(disk.get("drawer_seen", false))
	if typeof(disk.get("run", {})) == TYPE_DICTIONARY:
		state["run"] = (disk["run"] as Dictionary).duplicate(true)


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
