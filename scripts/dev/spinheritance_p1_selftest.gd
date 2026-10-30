extends SceneTree
## Headless checks for the 2026-10-25 Spinheritance P1 readings. Does not boot main.gd.


func _init() -> void:
	var rules = load("res://scripts/spinheritance_p1.gd")
	var failed := false
	failed = _eq(failed, "hot from 5", rules.next_intrinsic_atk(5, true), 9) or failed
	failed = _eq(failed, "cold from 5", rules.next_intrinsic_atk(5, false), 2) or failed
	failed = _eq(failed, "cold from 2", rules.next_intrinsic_atk(2, false), 0) or failed
	failed = _eq(failed, "hot from 0", rules.next_intrinsic_atk(0, true), 4) or failed
	failed = _eq(failed, "cold from 0", rules.next_intrinsic_atk(0, false), 0) or failed
	failed = _eq(failed, "lifelink one hit", rules.lifelink_hp(0, 2, true), 2) or failed
	failed = _eq(failed, "lifelink last hit", rules.lifelink_hp(0, 1, true), 1) or failed
	failed = _eq(failed, "lifelink still up", rules.lifelink_hp(2, 4, false), 2) or failed
	var bleed: Dictionary = rules.lifelink_change(6, 2, 6)
	failed = _eq(failed, "bleed kind", str(bleed.get("kind", "")), "bleed") or failed
	failed = _eq(failed, "bleed n", int(bleed.get("n", -1)), 4) or failed
	failed = _eq(failed, "bleed hp", int(bleed.get("hp", -1)), 2) or failed
	var same: Dictionary = rules.lifelink_change(2, 2, 6)
	failed = _eq(failed, "same kind", str(same.get("kind", "")), "none") or failed
	var heal: Dictionary = rules.lifelink_change(1, 2, 6)
	failed = _eq(failed, "heal kind", str(heal.get("kind", "")), "heal") or failed
	failed = _eq(failed, "heal n", int(heal.get("n", -1)), 1) or failed
	failed = _eq(failed, "cap", rules.lifelink_target(9, 6), 6) or failed
	failed = _eq(failed, "no egg after attack", rules.phoenix_lays_egg(true, false), false) or failed
	failed = _eq(failed, "egg before attack", rules.phoenix_lays_egg(false, false), true) or failed
	failed = _eq(failed, "no egg if quiet", rules.phoenix_lays_egg(false, true), false) or failed
	failed = _eq(failed, "bottle archived", rules.fairy_grants_bottle(1, false), false) or failed
	failed = _eq(failed, "no bottle at 0", rules.fairy_grants_bottle(0, false), false) or failed
	failed = _eq(failed, "no bottle if quiet", rules.fairy_grants_bottle(1, true), false) or failed
	var used: Dictionary = rules.decay_resolve([11, 22], 22)
	failed = _eq(failed, "decay keep", int(used["keep"][0]), 22) or failed
	failed = _eq(failed, "decay discard", int(used["discard"][0]), 11) or failed
	var unused: Dictionary = rules.decay_resolve([11, 22], -1)
	failed = _eq(failed, "unused count", unused["discard"].size(), 2) or failed
	failed = _eq(failed, "unused keep", unused["keep"].size(), 0) or failed
	var solo_use: Dictionary = rules.decay_resolve([11], 11)
	failed = _eq(failed, "solo keep", int(solo_use["keep"][0]), 11) or failed
	failed = _eq(failed, "solo discard", solo_use["discard"].size(), 0) or failed
	var solo_left: Dictionary = rules.decay_resolve([11], -1)
	failed = _eq(failed, "solo unused", int(solo_left["discard"][0]), 11) or failed
	if failed:
		print("SP_P1_FAIL")
		quit(1)
		return
	print("SP_P1_OK")
	quit(0)


func _eq(failed: bool, label: String, got, want) -> bool:
	if got == want:
		return failed
	push_error("%s got %s want %s" % [label, got, want])
	return true
