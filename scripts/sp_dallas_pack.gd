extends RefCounted
## Pure decisions for SP-20 Bushido, SP-24 Martyr, SP-27 Shambling Mound (2026-10-28).


static func bushido_should_swap(alive: bool, silenced: bool, hp_after_item: int) -> bool:
	## After a counted item use while facing Bushido: swap only if he still lives.
	return alive and not silenced and hp_after_item > 0


static func bushido_swap_pair(hp: int, atk: int) -> Dictionary:
	return {"hp": atk, "atk": hp}


static func martyr_gift_after_loss(hp_after_loss: int) -> int:
	## Remaining HP measured after the loss that killed him.
	return maxi(0, hp_after_loss)


static func martyr_dies_on_hp_loss(before: int, after: int, silenced: bool, already_done: bool) -> bool:
	if silenced or already_done:
		return false
	return before > after


static func martyr_dies_on_defeat(hp_now: int, silenced: bool, already_done: bool) -> bool:
	## Defeat while still holding HP (Boot / Sledge / Net-style).
	if silenced or already_done:
		return false
	return hp_now > 0


static func shambling_mound_base_hp() -> int:
	return 6
