extends SceneTree
## Feel pass A: FX attach order, stat-count 0.5s cap, spin duration + easing.
## Run: godot --headless --path . --script res://scripts/dev/feel_pass_a_selftest.gd


const FX_ONESHOT := preload("res://scripts/fx_oneshot.gd")
const DUNGEON_ART := preload("res://scripts/dungeon_art.gd")
const BOSS_WHEEL := preload("res://scripts/boss_wheel.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := false
	failed = await _check_fx_attach_order() or failed
	failed = _check_spin_constants() or failed
	failed = _check_stat_count_cap() or failed
	failed = _check_fx_cache() or failed
	if failed:
		print("feel_pass_a_selftest: FAIL")
		quit(1)
		return
	print("feel_pass_a_selftest: OK")
	quit(0)


func _check(failed: bool, name: String, ok: bool) -> bool:
	if ok:
		print("  ok  ", name)
		return failed
	print("  FAIL ", name)
	return true


func _check_fx_attach_order() -> bool:
	var failed := false
	var root := get_root()
	var parent := Node2D.new()
	parent.name = "FxParent"
	parent.position = Vector2(200, 100)
	root.add_child(parent)
	await process_frame

	var art = DUNGEON_ART.new()
	var frames: Array = art.fx_frames("land_burst")
	if frames.is_empty():
		# Minimal 1x1 placeholder so the helper still runs.
		var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 0, 1, 1))
		frames = [ImageTexture.create_from_image(img)]

	var want := Vector2(840, 520)
	var spr: AnimatedSprite2D = FX_ONESHOT.play(parent, frames, want, 2.0, 14.0, false, 40)
	failed = _check(failed, "FxOneShot spawned", spr != null and is_instance_valid(spr)) or failed
	if spr != null:
		# After add_child-then-global_position, spr must sit at the requested global.
		failed = _check(
			failed,
			"FxOneShot global_position matches target (attach-before-pos)",
			spr.global_position.distance_to(want) < 0.5
		) or failed
		# Parent offset would have shifted it by ~200,100 if order were wrong.
		failed = _check(
			failed,
			"FxOneShot not offset by parent local space",
			spr.global_position.distance_to(want + parent.position) > 50.0
			or parent.position == Vector2.ZERO
		) or failed
	parent.queue_free()
	return failed


func _check_spin_constants() -> bool:
	var failed := false
	var src: String = FileAccess.get_file_as_string("res://scripts/boss_wheel.gd")
	failed = _check(failed, "SPIN_DURATION is 1.56", src.find("const SPIN_DURATION := 1.56") >= 0) or failed
	## Locked Feel pass A: cubic spin uses EASE_IN_OUT (not EASE_OUT-only).
	failed = _check(
		failed,
		"spin tween uses EASE_IN_OUT",
		src.find("_spin_tween.set_ease(Tween.EASE_IN_OUT)") >= 0
	) or failed
	failed = _check(
		failed,
		"spin tween not EASE_OUT-only",
		src.find("_spin_tween.set_ease(Tween.EASE_OUT)") < 0
	) or failed
	# Runtime constant on a live instance.
	var wheel = BOSS_WHEEL.new()
	failed = _check(failed, "BOSS_WHEEL.SPIN_DURATION == 1.56", is_equal_approx(float(wheel.SPIN_DURATION), 1.56)) or failed
	wheel.free()
	return failed


func _check_stat_count_cap() -> bool:
	var failed := false
	var src: String = FileAccess.get_file_as_string("res://scripts/main.gd")
	failed = _check(failed, "_play_stat_count exists", src.find("func _play_stat_count(") >= 0) or failed
	failed = _check(
		failed,
		"stat count step capped at 0.5s total",
		src.find("minf(0.035, 0.5 / float(maxi(steps, 1)))") >= 0
	) or failed
	# Mirror the formula: 20 steps → 0.025 each; 5 steps → 0.035.
	var step20: float = minf(0.035, 0.5 / 20.0)
	var step5: float = minf(0.035, 0.5 / 5.0)
	failed = _check(failed, "20-step count ≤ 0.5s", is_equal_approx(step20 * 20.0, 0.5) or step20 * 20.0 <= 0.5) or failed
	failed = _check(failed, "5-step uses 0.035", is_equal_approx(step5, 0.035)) or failed
	return failed


func _check_fx_cache() -> bool:
	var failed := false
	DUNGEON_ART.warm_fx_cache()
	var a = DUNGEON_ART.new()
	var b = DUNGEON_ART.new()
	var f1: Array = a.fx_frames("land_burst")
	var f2: Array = b.fx_frames("land_burst")
	failed = _check(failed, "fx_frames cache returns same count", f1.size() == f2.size()) or failed
	return failed
