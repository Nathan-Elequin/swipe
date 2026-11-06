extends SceneTree
## Headless proof: every live wheel seat PNG matches difficulty sizing.
## Deadly (catalog tier 3) → 64×64 native; all other monsters → 48×48.
## Also checks boss_wheel.seat_native_px_for_tier and that idle strips exist.
## Run: godot --headless --path . --script res://scripts/dev/wheel_seat_from_facing_selftest.gd
## Does not boot main.gd.

const WHEEL := preload("res://scripts/boss_wheel.gd")


func _init() -> void:
	var failed := false
	var cat_path := "res://data/catalog.json"
	if not FileAccess.file_exists(cat_path):
		push_error("missing catalog.json")
		quit(1)
		return
	var raw: String = FileAccess.get_file_as_string(cat_path)
	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("catalog.json is not an object")
		quit(1)
		return
	var monsters: Array = (parsed as Dictionary).get("monsters", [])
	var checked := 0
	var skipped := 0
	for row in monsters:
		if typeof(row) != TYPE_DICTIONARY:
			continue
		var m: Dictionary = row
		var id: String = str(m.get("id", "")).strip_edges()
		if id == "":
			continue
		# Facing-seat pack installs base + idle_f0 for 62 monsters. Legacy
		# leftovers (fungal_colony) keep an old base without idle — skip those.
		var base_path := "res://assets/dungeon/anim/wheel/%s_wheel_base.png" % id
		var idle0 := "res://assets/dungeon/anim/wheel/%s_wheel_idle_f0.png" % id
		if not FileAccess.file_exists(base_path) or not FileAccess.file_exists(idle0):
			skipped += 1
			continue
		var tier: int = int(m.get("tier", 1))
		var want: int = WHEEL.seat_native_px_for_tier(tier)
		failed = _check(
			"tier_helper_%s" % id,
			want == (64 if tier >= 3 else 48)
		) or failed
		var img: Image = Image.new()
		var err: Error = img.load(base_path)
		failed = _check("load_base_%s" % id, err == OK) or failed
		if err == OK:
			failed = _check(
				"seat_px_%s" % id,
				img.get_width() == want and img.get_height() == want
			) or failed
		var idle_img := Image.new()
		var ierr: Error = idle_img.load(idle0)
		failed = _check("load_idle_%s" % id, ierr == OK) or failed
		if ierr == OK:
			failed = _check(
				"idle_px_%s" % id,
				idle_img.get_width() == want and idle_img.get_height() == want
			) or failed
		checked += 1

	failed = _check("checked_at_least_62", checked >= 62) or failed
	failed = _check("helper_deadly", WHEEL.seat_native_px_for_tier(3) == 64) or failed
	failed = _check("helper_tough", WHEEL.seat_native_px_for_tier(2) == 48) or failed
	failed = _check("helper_weak", WHEEL.seat_native_px_for_tier(1) == 48) or failed
	failed = _check("helper_zero", WHEEL.seat_native_px_for_tier(0) == 48) or failed

	print("wheel_seat_from_facing_selftest checked=%s skipped=%s failed=%s" % [checked, skipped, failed])
	quit(1 if failed else 0)


func _check(label: String, ok: bool) -> bool:
	if ok:
		print("PASS ", label)
		return false
	print("FAIL ", label)
	return true
