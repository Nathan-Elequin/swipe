extends SceneTree
## Runtime proof: map destination visibility ≠ fresh-start launch affordance.
## Instantiates campaign_map / held_map, drives present + LaunchHit presses.
## Run: godot --headless --path . --script res://scripts/dev/held_map_launch_selftest.gd
## Does not boot main.gd. Does not invent player-facing copy.

const SHELL := preload("res://scripts/campaign_shell.gd")
const CAMPAIGN_MAP := preload("res://scripts/campaign_map.gd")


func _initialize() -> void:
	var failed := false
	var rules: Dictionary = SHELL.read_json("res://data/campaign.json")
	var map: Control = CAMPAIGN_MAP.new()
	root.add_child(map)
	map.setup()

	# --- Fresh: only D1 destination + launch ---
	var fresh: Dictionary = SHELL.fresh_state()
	_seed_telegraphs(fresh, {"b1": ["goblin"], "b2": ["bandit"], "b3": ["dragon"]})
	map.show_map(rules, fresh, _stub_monsters(), {})
	failed = _check(failed, "fresh.b1.visible", map.destination_visible("b1")) or failed
	failed = _check(failed, "fresh.b1.launchable", map.destination_launchable("b1")) or failed
	failed = _check(failed, "fresh.b2.hidden_dest", not map.destination_visible("b2")) or failed
	failed = _check(failed, "fresh.b2.not_launchable", not map.destination_launchable("b2")) or failed
	failed = _check(failed, "fresh.b2.locked_pin", _has_locked(map, "b2")) or failed
	failed = _check(failed, "fresh.monster.b1", _monster_count(map, "goblin") == 1) or failed
	failed = _check(failed, "fresh.monster.b2.absent", _monster_count(map, "bandit") == 0) or failed
	var got_fresh: Array = await _press_launch(map, "b1")
	failed = _check(
		failed,
		"fresh.b1.emits_start",
		got_fresh.size() == 3 and int(got_fresh[0]) == 0 and bool(got_fresh[1]) == true and bool(got_fresh[2]) == false
	) or failed
	map.show_map(rules, fresh, _stub_monsters(), {})
	failed = _check(failed, "fresh.start_banner", _has_start_banner(map)) or failed
	var got_banner: Array = await _press_start_banner(map)
	failed = _check(
		failed,
		"fresh.banner.emits_first",
		got_banner.size() == 3 and int(got_banner[0]) == 0 and bool(got_banner[1]) == true and bool(got_banner[2]) == false
	) or failed
	failed = _check(failed, "fresh.b2.no_hit", (await _press_launch(map, "b2")).is_empty()) or failed

	# --- D2 Known (portal open), still not startable ---
	var d2: Dictionary = SHELL.fresh_state()
	_fill_pool(rules, d2, "b1", 5)
	SHELL.open_portal(rules, d2, "b1")
	_seed_telegraphs(d2, {"b1": ["goblin"], "b2": ["bandit"], "b3": ["dragon"]})
	failed = _check(failed, "shell.d2.unlocked", SHELL.biome_unlocked(rules, d2, 1)) or failed
	failed = _check(failed, "shell.d2.not_start", not SHELL.can_start(rules, d2, 1)) or failed
	map.show_map(rules, d2, _stub_monsters(), {})
	failed = _check(failed, "d2.b1.visible", map.destination_visible("b1")) or failed
	failed = _check(failed, "d2.b1.launchable", map.destination_launchable("b1")) or failed
	failed = _check(failed, "d2.b2.visible", map.destination_visible("b2")) or failed
	failed = _check(failed, "d2.b2.not_launchable", not map.destination_launchable("b2")) or failed
	failed = _check(failed, "d2.b2.stamp_not_locked", not _has_locked(map, "b2")) or failed
	failed = _check(failed, "d2.b3.still_locked", not map.destination_visible("b3") and _has_locked(map, "b3")) or failed
	failed = _check(failed, "d2.monster.b2", _monster_count(map, "bandit") == 1) or failed
	failed = _check(failed, "d2.b2.press_noop", (await _press_launch(map, "b2")).is_empty()) or failed
	var got_d1: Array = await _press_launch(map, "b1")
	failed = _check(
		failed,
		"d2.b1.still_emits",
		got_d1.size() == 3 and int(got_d1[0]) == 0
	) or failed

	# --- Shortcut grant: b2 becomes launchable ---
	var d3: Dictionary = SHELL.fresh_state()
	_fill_pool(rules, d3, "b1", 5)
	_fill_pool(rules, d3, "b2", 5)
	SHELL.open_portal(rules, d3, "b1")
	SHELL.open_portal(rules, d3, "b2")
	SHELL.grant_shortcut(rules, d3, "b2")
	_seed_telegraphs(d3, {"b1": ["goblin"], "b2": ["bandit"], "b3": ["dragon"]})
	failed = _check(failed, "shell.d3.can_start_d2", SHELL.can_start(rules, d3, 1)) or failed
	failed = _check(failed, "shell.d3.not_start_d3", not SHELL.can_start(rules, d3, 2)) or failed
	map.show_map(rules, d3, _stub_monsters(), {})
	failed = _check(failed, "d3.b2.visible", map.destination_visible("b2")) or failed
	failed = _check(failed, "d3.b2.launchable", map.destination_launchable("b2")) or failed
	failed = _check(failed, "d3.b3.visible", map.destination_visible("b3")) or failed
	failed = _check(failed, "d3.b3.not_launchable", not map.destination_launchable("b3")) or failed
	failed = _check(failed, "d3.monster.b3", _monster_count(map, "dragon") == 1) or failed
	var got_short: Array = await _press_launch(map, "b2")
	failed = _check(
		failed,
		"d3.b2.emits_shortcut",
		got_short.size() == 3 and int(got_short[0]) == 1 and bool(got_short[1]) == true and bool(got_short[2]) == false
	) or failed
	failed = _check(failed, "d3.b3.press_noop", (await _press_launch(map, "b3")).is_empty()) or failed

	# --- Read-only peek: destinations visible, no launch hits ---
	map.show_map(rules, d3, _stub_monsters(), {"read_only": true})
	failed = _check(failed, "peek.b2.visible", map.destination_visible("b2")) or failed
	failed = _check(failed, "peek.b3.visible", map.destination_visible("b3")) or failed
	failed = _check(failed, "peek.no_b1_launch", not map.destination_launchable("b1")) or failed
	failed = _check(failed, "peek.no_b2_launch", not map.destination_launchable("b2")) or failed

	map.queue_free()
	if failed:
		print("HELD_MAP_LAUNCH_FAIL")
		quit(1)
	else:
		print("HELD_MAP_LAUNCH_OK")
		quit(0)


func _fill_pool(rules: Dictionary, state: Dictionary, pool: String, n: int) -> void:
	var ids: Array = []
	var pools: Dictionary = {}
	for i in n:
		var id := "%s_%d" % [pool, i]
		ids.append(id)
		pools[id] = pool
	SHELL.bank(rules, state, ids, pools)


func _seed_telegraphs(state: Dictionary, by_pool: Dictionary) -> void:
	var deals: Dictionary = {}
	for pool in by_pool.keys():
		deals[str(pool)] = {"ids": [], "telegraph": (by_pool[pool] as Array).duplicate()}
	state["next_run"] = {"seed": 1, "deals": deals}


func _stub_monsters() -> Dictionary:
	return {
		"goblin": {"name": "Goblin", "hp": {"base": 2}, "atk": {"base": 1}, "ability": "---"},
		"bandit": {"name": "Bandit", "hp": {"base": 3}, "atk": {"base": 2}, "ability": "---"},
		"dragon": {"name": "Dragon", "hp": {"base": 8}, "atk": {"base": 4}, "ability": "---"},
	}


func _held(map: Control) -> Control:
	if map.has_method("held_map"):
		return map.call("held_map") as Control
	return null


func _has_locked(map: Control, pool: String) -> bool:
	var held := _held(map)
	if held == null:
		return false
	var pins: Node = held.get_node_or_null("Sheet/Pins")
	if pins == null:
		return false
	return pins.get_node_or_null("Locked_%s" % pool) != null


func _monster_count(map: Control, monster_id: String) -> int:
	var held := _held(map)
	if held == null:
		return 0
	var host: Node = held.get_node_or_null("Sheet/Monsters")
	if host == null:
		return 0
	var n := 0
	var want := "MapMonster_%s" % monster_id
	for child in host.get_children():
		if child.name == want:
			n += 1
	return n


func _has_start_banner(map: Control) -> bool:
	var held := _held(map)
	if held == null:
		return false
	var pins: Node = held.get_node_or_null("Sheet/Pins")
	if pins == null:
		return false
	return pins.get_node_or_null("LaunchHit_start") != null


func _press_start_banner(map: Control) -> Array:
	var held := _held(map)
	if held == null:
		return []
	held.set("_going", false)
	if not _has_start_banner(map):
		return []
	var box: Dictionary = {"got": []}
	var cb := func(i: int, shortcut: bool, end: bool) -> void:
		box["got"] = [i, shortcut, end]
	map.start_asked.connect(cb, CONNECT_ONE_SHOT)
	await held._launch_first_available()
	if map.start_asked.is_connected(cb):
		map.start_asked.disconnect(cb)
	return box["got"] as Array


func _press_launch(map: Control, pool: String) -> Array:
	var held := _held(map)
	if held == null:
		return []
	## Prior stamp press leaves _going true until present() rebuilds.
	held.set("_going", false)
	var pins: Node = held.get_node_or_null("Sheet/Pins")
	if pins == null:
		return []
	## Launch affordance = LaunchHit button present (wired in _add_stamp).
	var hit: Button = pins.get_node_or_null("LaunchHit_%s" % pool) as Button
	if hit == null:
		return []
	var seal = pins.get_node_or_null("Stamp_%s" % pool)
	if seal == null:
		return []
	var endless := pool == "endless"
	var index := 0
	if not endless:
		var rules: Dictionary = held.get("_rules")
		var biomes: Array = SHELL.biomes_of(rules)
		for i in biomes.size():
			if str((biomes[i] as Dictionary).get("id", "")) == pool:
				index = i
				break
	## Box capture: lambda reassignment would not write the outer Array.
	var box: Dictionary = {"got": []}
	var cb := func(i: int, shortcut: bool, end: bool) -> void:
		box["got"] = [i, shortcut, end]
	map.start_asked.connect(cb, CONNECT_ONE_SHOT)
	## Await the same handler the LaunchHit button calls (flatten → emit).
	await held._start_from_stamp(seal, index, endless)
	if map.start_asked.is_connected(cb):
		map.start_asked.disconnect(cb)
	return box["got"] as Array


func _check(failed: bool, label: String, ok: bool) -> bool:
	print(("PASS " if ok else "FAIL ") + label)
	return failed or not ok
