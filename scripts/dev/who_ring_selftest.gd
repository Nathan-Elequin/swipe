extends SceneTree
## Headless proof: who-ring overlay PNGs match the Weak/Tough vs Deadly split.
## Weak/Tough seats (48 native) → 64×64 hoop. Deadly seats (64 native) → 80×80 hoop.
## Run: godot --headless --path . --script res://scripts/dev/who_ring_selftest.gd
## Does not boot main.gd.

const WHEEL := preload("res://scripts/boss_wheel.gd")


func _init() -> void:
	var failed := false
	failed = _check("ring_helper_deadly", WHEEL.who_ring_native_px_for_tier(3) == 80) or failed
	failed = _check("ring_helper_tough", WHEEL.who_ring_native_px_for_tier(2) == 64) or failed
	failed = _check("ring_helper_weak", WHEEL.who_ring_native_px_for_tier(1) == 64) or failed
	failed = _check("seat_helper_deadly", WHEEL.seat_native_px_for_tier(3) == 64) or failed
	failed = _check("seat_helper_weak", WHEEL.seat_native_px_for_tier(1) == 48) or failed
	for i in 4:
		failed = _png("res://assets/ui/anim/seat_target_ghost_f%s.png" % i, 64) or failed
		failed = _png("res://assets/ui/anim/seat_target_ghost_deadly_f%s.png" % i, 80) or failed
	failed = _png("res://assets/ui/anim/seat_target_locked.png", 64) or failed
	failed = _png("res://assets/ui/anim/seat_target_locked_deadly.png", 80) or failed
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
