extends SceneTree
## Headless proof: who-ring overlay PNGs match the Weak/Tough vs Deadly split.
## Weak/Tough seats (24 native) → 32×32 hoop. Deadly seats (32 native) → 40×40 hoop.
## Run: godot --headless --path . --script res://scripts/dev/who_ring_selftest.gd
## Does not boot main.gd.

const WHEEL := preload("res://scripts/boss_wheel.gd")


func _init() -> void:
	var failed := false
	failed = _check("ring_helper_deadly", WHEEL.who_ring_native_px_for_tier(3) == 40) or failed
	failed = _check("ring_helper_tough", WHEEL.who_ring_native_px_for_tier(2) == 32) or failed
	failed = _check("ring_helper_weak", WHEEL.who_ring_native_px_for_tier(1) == 32) or failed
	failed = _check("seat_helper_unchanged_deadly", WHEEL.seat_native_px_for_tier(3) == 32) or failed
	failed = _check("seat_helper_unchanged_weak", WHEEL.seat_native_px_for_tier(1) == 24) or failed
	for i in 4:
		failed = _png("res://assets/ui/anim/seat_target_ghost_f%s.png" % i, 32) or failed
		failed = _png("res://assets/ui/anim/seat_target_ghost_deadly_f%s.png" % i, 40) or failed
	failed = _png("res://assets/ui/anim/seat_target_locked.png", 32) or failed
	failed = _png("res://assets/ui/anim/seat_target_locked_deadly.png", 40) or failed
	print("who_ring_selftest failed=%s" % failed)
	quit(1 if failed else 0)


func _png(path: String, want: int) -> bool:
	if not FileAccess.file_exists(path):
		print("FAIL missing ", path)
		return true
	var img := Image.new()
	var err: Error = img.load(path)
	if err != OK:
		print("FAIL load ", path)
		return true
	var ok: bool = img.get_width() == want and img.get_height() == want
	print(("PASS " if ok else "FAIL ") + "%s %sx%s want %s" % [path, img.get_width(), img.get_height(), want])
	return not ok


func _check(label: String, ok: bool) -> bool:
	print(("PASS " if ok else "FAIL ") + label)
	return not ok
