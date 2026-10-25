extends RefCounted
## Pure decisions for the 2026-10-25 Spinheritance P1 reworks.
## main.gd calls these so the combat code and the selftest share one reading.


static func next_intrinsic_atk(current: int, hot: bool) -> int:
	var delta := 4 if hot else -3
	return maxi(0, current + delta)


static func lifelink_hp(current_hp: int, hp_before_last_hit: int, died_from_damage: bool) -> int:
	if died_from_damage:
		return maxi(0, hp_before_last_hit)
	return maxi(0, current_hp)


static func lifelink_target(source_hp: int, player_max: int) -> int:
	return clampi(source_hp, 0, player_max)


## "none" / "heal" / "bleed", and the amount of the change.
static func lifelink_change(player_hp: int, source_hp: int, player_max: int) -> Dictionary:
	var target := lifelink_target(source_hp, player_max)
	if target == player_hp:
		return {"kind": "none", "n": 0, "hp": player_hp}
	if target > player_hp:
		return {"kind": "heal", "n": target - player_hp, "hp": target}
	return {"kind": "bleed", "n": player_hp - target, "hp": target}


static func phoenix_lays_egg(has_attacked: bool, silenced: bool) -> bool:
	return not silenced and not has_attacked


static func fairy_grants_bottle(hp_now: int, silenced: bool) -> bool:
	return not silenced and hp_now > 0


## used_uid < 0 means the combat ended with the link unused.
## Returns {keep: Array, discard: Array}.
static func decay_resolve(linked: Array, used_uid: int) -> Dictionary:
	var keep: Array = []
	var discard: Array = []
	if linked.is_empty():
		return {"keep": keep, "discard": discard}
	if linked.size() == 1:
		var only: int = int(linked[0])
		if used_uid == only:
			keep.append(only)
		else:
			discard.append(only)
		return {"keep": keep, "discard": discard}
	var a := int(linked[0])
	var b := int(linked[1])
	if used_uid == a:
		keep.append(a)
		discard.append(b)
	elif used_uid == b:
		keep.append(b)
		discard.append(a)
	else:
		discard.append(a)
		discard.append(b)
	return {"keep": keep, "discard": discard}
