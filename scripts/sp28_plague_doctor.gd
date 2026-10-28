extends RefCounted
## Pure decisions for SP-28 Plague Doctor (2026-10-28).
## Freeze-all poison while any living unsilenced Doctor is on the wheel.


static func freezes_poison(doctor_alive_unsilenced: bool) -> bool:
	return doctor_alive_unsilenced


static func poison_would_activate(monster_poison_pending: bool, player_poison: int, living_monsters: int) -> bool:
	if monster_poison_pending:
		return true
	return player_poison > 0 and living_monsters > 0


static func should_show_blocked_fx(freeze: bool, would_activate: bool) -> bool:
	return freeze and would_activate


static func neighbor_poison_gain_on_spin() -> int:
	return 2


static func neighbor_heal_on_spin() -> int:
	return 2
