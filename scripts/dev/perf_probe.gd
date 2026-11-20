extends SceneTree
## Headless perf probe (CPU only, dev harness — not the player path).
## Boots main, stages fights via qa_staging_fight, times hover / unhover / use /
## Take, logs every frame over 30 ms (SPIKE), node-count growth per round (ROUND)
## and a node census diff (CENSUS).
## Run (sandboxed save): XDG_DATA_HOME=$(mktemp -d) PERF_ROUNDS=13 \
##   godot --headless --path . --script res://scripts/dev/perf_probe.gd

const MAIN_SCENE := "res://scenes/main.tscn"
const MONSTERS := ["goblin", "ogre", "bandit", "dire_wolf", "skeleton", "wizard"]
const ITEMS := ["spiked_flail", "throwing_knife", "shield", "sledgehammer", "dagger", "healing_potion"]

var main: Node
var _last_us: int = 0
var _frames: PackedFloat32Array = PackedFloat32Array()
var _rec: bool = false
var rounds: int = 12
var results: Array = []

class Rec extends Node:
	var cb: Callable
	func _process(_d: float) -> void:
		cb.call()

func _initialize() -> void:
	var r := OS.get_environment("PERF_ROUNDS")
	if r != "":
		rounds = int(r)
	change_scene_to_file(MAIN_SCENE)
	for i in 400:
		await process_frame
		main = root.get_node_or_null("Main")
		if main != null and ("_campaign" in main) and main._campaign != null:
			break
	if main == null:
		print("PERF_FAIL no main")
		quit(1)
		return
	for i in 60:
		await process_frame
	process_frame.connect(_tick)
	_last_us = Time.get_ticks_usec()
	var base := _snap()
	var census0 := {}
	print("BASE ", JSON.stringify(base))
	for rnd in rounds:
		_round = rnd
		var s: String = main.qa_staging_fight(MONSTERS, MONSTERS[rnd % MONSTERS.size()], ITEMS, false)
		await _settle(30)
		var items: Array = main.hotbar.duplicate()
		var n := 0
		for it in items:
			if n >= 3:
				break
			if typeof(it) != TYPE_DICTIONARY:
				continue
			var uid: int = int(it.get("uid", -1))
			var card: Control = main._hotbar_card_by_uid(uid)
			await _measure("hover", func(): main._on_item_hovered(it, card), 20)
			await _measure("unhover", func(): main._on_item_unhovered(), 10)
			if main.phase != "fighting":
				break
			var ph0: String = str(main.phase)
			await _measure_co("use", func(): await main._use_item(uid), 600)
			if results[-1]["wall_ms"] > 3000.0:
				print("USE_HANG card=", it.get("card_id"), " paused=", paused, " ts=", Engine.time_scale, " phase=", main.phase, " sprs=", main.get_children().filter(func(c): return c is AnimatedSprite2D).map(func(c): return [c.name, c.frame, c.is_playing(), c.speed_scale, c.process_mode, c.can_process()]))
			results[-1]["card"] = str(it.get("card_id", ""))
			results[-1]["ph"] = ph0 + ">" + str(main.phase)
			n += 1
		if main.phase == "fighting":
			await _measure_co("take", func(): await main._on_done(), 900)
		var w := 0
		while main.phase != "ready" and main.phase != "fighting" and w < 600:
			await process_frame
			w += 1
		print("AFTER_TAKE phase=", main.phase, " waited=", w)
		for sp in 3:
			if main.phase == "ready":
				await _measure_co("spin", func(): await main._on_spin(), 900)
				var w2 := 0
				while main.phase != "fighting" and w2 < 300:
					await process_frame
					w2 += 1
				if main.phase == "fighting":
					await _measure_co("take2", func(): await main._on_done(), 900)
				w2 = 0
				while main.phase != "ready" and w2 < 600:
					await process_frame
					w2 += 1
		var sn := _snap()
		sn["round"] = rnd
		sn["phase"] = str(main.phase)
		print("ROUND ", JSON.stringify(sn))
		if rnd == 1:
			census0 = _census()
	if not census0.is_empty():
		var c1 := _census()
		var diffs: Array = []
		for k in c1.keys():
			var dv: int = int(c1[k]) - int(census0.get(k, 0))
			if dv != 0:
				diffs.append([dv, k])
		for k in census0.keys():
			if not c1.has(k):
				diffs.append([-int(census0[k]), k])
		diffs.sort_custom(func(a, b): return absi(a[0]) > absi(b[0]))
		for i in mini(25, diffs.size()):
			print("CENSUS %+d %s" % [diffs[i][0], diffs[i][1]])
	print("STATE paused=", paused, " time_scale=", Engine.time_scale, " phase=", main.phase)
	for ch in main.get_children():
		if ch is AnimatedSprite2D:
			var a: AnimatedSprite2D = ch
			var tex_path := ""
			if a.sprite_frames != null and a.sprite_frames.get_frame_count(a.animation) > 0:
				var t: Texture2D = a.sprite_frames.get_frame_texture(a.animation, 0)
				tex_path = t.resource_path if t != null else ""
			print("LEAKSPR name=%s anim=%s playing=%s loop=%s vis=%s mod=%s tex=%s meta=%s" % [a.name, a.animation, a.is_playing(), a.sprite_frames.get_animation_loop(a.animation) if a.sprite_frames else false, a.visible, a.modulate, tex_path, a.get_meta_list()])
	_summary()
	quit(0)

var spikes: Array = []
var _cur_tag := ""
var _round := 0
var _last_nodes := 0
func _tick() -> void:
	var now := Time.get_ticks_usec()
	var ms := float(now - _last_us) / 1000.0
	var nodes := int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	if _rec:
		_frames.push_back(ms)
		if ms > 30.0:
			spikes.append({"r": _round, "tag": _cur_tag, "ms": snappedf(ms, 0.1), "phase": str(main.phase), "dnodes": nodes - _last_nodes})
	_last_nodes = nodes
	_last_us = now

func _snap() -> Dictionary:
	return {
		"nodes": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"objects": int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		"orphans": int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
		"resources": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		"mem_mb": snappedf(Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0, 0.1),
	}

func _settle(n: int) -> void:
	for i in n:
		await process_frame

func _measure(tag: String, f: Callable, frames: int) -> void:
	_frames = PackedFloat32Array()
	_rec = true
	var t0 := Time.get_ticks_usec()
	f.call()
	var sync_ms := float(Time.get_ticks_usec() - t0) / 1000.0
	await _settle(frames)
	_rec = false
	_book(tag, sync_ms, 0.0)

func _measure_co(tag: String, f: Callable, max_frames: int) -> void:
	_cur_tag = tag
	_frames = PackedFloat32Array()
	_rec = true
	var done := {"v": false}
	var t0 := Time.get_ticks_usec()
	var runner := func():
		await f.call()
		done["v"] = true
	runner.call()
	var sync_ms := float(Time.get_ticks_usec() - t0) / 1000.0
	var k := 0
	while not done["v"] and k < max_frames:
		await process_frame
		k += 1
	var wall := float(Time.get_ticks_usec() - t0) / 1000.0
	await _settle(15)
	_rec = false
	_book(tag, sync_ms, wall)

func _book(tag: String, sync_ms: float, wall: float) -> void:
	var mx := 0.0
	var over33 := 0
	var sum := 0.0
	for v in _frames:
		mx = maxf(mx, v)
		sum += v
		if v > 33.3:
			over33 += 1
	var d := {"tag": tag, "sync_ms": snappedf(sync_ms, 0.01), "wall_ms": snappedf(wall, 0.1), "frames": _frames.size(),
		"max_ms": snappedf(mx, 0.01), "avg_ms": snappedf(sum / maxf(1.0, _frames.size()), 0.01), "over33": over33}
	results.append(d)

func _summary() -> void:
	var by := {}
	for d in results:
		var t: String = d["tag"]
		if not by.has(t):
			by[t] = {"n": 0, "sync": [], "max": [], "avg": [], "wall": []}
		by[t]["n"] += 1
		by[t]["sync"].append(d["sync_ms"])
		by[t]["max"].append(d["max_ms"])
		by[t]["avg"].append(d["avg_ms"])
		by[t]["wall"].append(d["wall_ms"])
	for t in by.keys():
		var b: Dictionary = by[t]
		print("SUM %s n=%d sync_med=%.2f sync_max=%.2f frame_max_med=%.2f frame_max_max=%.2f avg_med=%.2f wall_med=%.1f" % [t, b.n, _med(b.sync), _mx(b.sync), _med(b.max), _mx(b.max), _med(b.avg), _med(b.wall)])
	for d in results:
		print("ROW ", JSON.stringify(d))
	for d in spikes:
		print("SPIKE ", JSON.stringify(d))

func _med(a: Array) -> float:
	var s := a.duplicate()
	s.sort()
	return float(s[s.size() / 2]) if not s.is_empty() else 0.0

func _mx(a: Array) -> float:
	var m := 0.0
	for v in a:
		m = maxf(m, float(v))
	return m


func _census() -> Dictionary:
	var d := {}
	var stack: Array = [root]
	var re := RegEx.new()
	re.compile("[0-9@]+")
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		var par: String = re.sub(str(n.get_parent().name), "#", true) if n.get_parent() != null else ""
		var key: String = "%s/%s(%s)" % [par, re.sub(str(n.name), "#", true), n.get_class()]
		d[key] = int(d.get(key, 0)) + 1
		for ch in n.get_children(true):
			stack.append(ch)
	return d
