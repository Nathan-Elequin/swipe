extends SceneTree
## Perf audit: wheel seat-layout solve is memoized and the hoisted clearance
## math matches the original sample-by-sample math exactly.
## Run: godot --headless --path . --script res://scripts/dev/perf_fit_selftest.gd

const BOSS_WHEEL := preload("res://scripts/boss_wheel.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	var w = BOSS_WHEEL.new()
	w.size = Vector2(698, 698)
	root.add_child(w)
	await process_frame
	var slices: Array = []
	for nm in ["Goblin", "Ogre", "Bandit", "Dire Wolf", "Skeleton", "Wizard"]:
		slices.append({"kind": "monster", "card_id": nm.to_lower().replace(" ", "_"), "name": nm, "call_name": "Call", "hp": 3, "atk": 2})
	w.slices = slices
	## 1) Hoisted clearance == original clearance on random seats.
	var rng := RandomNumberGenerator.new()
	rng.seed = 1919
	var c: Vector2 = w._center()
	var R: float = w._radius()
	var hub_r: float = R * w.HUB_FRAC
	var mism := 0
	for k in 2000:
		var i: int = rng.randi_range(0, 5)
		var a0: float = rng.randf_range(-PI, PI)
		var a1: float = a0 + rng.randf_range(0.3, 1.4)
		var sz := Vector2(rng.randf_range(60, 130), rng.randf_range(60, 130))
		var f: Vector2 = c + Vector2.from_angle(rng.randf_range(-PI, PI)) * rng.randf_range(40, R)
		var want: float = w._block_clearance(f, c, R, hub_r, a0, a1, sz, i)
		var n0: Vector2 = Vector2.from_angle(a0).rotated(PI * 0.5)
		var n1: Vector2 = Vector2.from_angle(a1).rotated(-PI * 0.5)
		var got: float = w._block_clearance_pre(f, c, R, hub_r, n0, n1, sz, w._tag_width_px(i), w._tag_height_px(i))
		if want != got:
			mism += 1
	failed = _check(failed, "hoisted clearance identical (2000 samples, %d mismatches)" % mism, mism == 0) or failed
	## 2) Fresh solve vs memo hit: identical feet, clearances, tag sizes.
	w._fit_memo.clear()
	w._fit_sig = ""
	var t0 := Time.get_ticks_usec()
	var a: Array = (w._fit_table(6) as Array).duplicate()
	var solve_ms := float(Time.get_ticks_usec() - t0) / 1000.0
	var cl_a: Array = w._fit_clearance.duplicate()
	var fs_a: Dictionary = w._tag_fs.duplicate()
	w._fit_sig = ""  # what set_slices() does every refresh
	t0 = Time.get_ticks_usec()
	var b: Array = w._fit_table(6)
	var memo_ms := float(Time.get_ticks_usec() - t0) / 1000.0
	failed = _check(failed, "memo feet identical", a == b) or failed
	failed = _check(failed, "memo clearances identical", cl_a == w._fit_clearance) or failed
	failed = _check(failed, "memo tag sizes identical", fs_a == w._tag_fs) or failed
	print("  solve_ms=%.2f memo_ms=%.3f" % [solve_ms, memo_ms])
	failed = _check(failed, "memo hit is cheap (<2 ms)", memo_ms < 2.0) or failed
	## 3) Different wheel size must not reuse a stale layout.
	w.size = Vector2(640, 640)
	w._fit_sig = ""
	var c2: Array = w._fit_table(6)
	failed = _check(failed, "resize re-solves", c2 != a) or failed
	w.queue_free()
	if failed:
		print("PERF_FIT_SELFTEST fail")
		quit(1)
	else:
		print("PERF_FIT_SELFTEST ok")
		quit(0)


func _check(failed: bool, name: String, ok: bool) -> bool:
	print("  %s %s" % ["ok  " if ok else "FAIL", name])
	return failed if ok else true
