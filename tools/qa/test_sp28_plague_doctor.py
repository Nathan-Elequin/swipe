#!/usr/bin/env python3
"""SP-28 Plague Doctor pure-rule checks (mirrors scripts/sp28_plague_doctor.gd)."""


def freezes_poison(doctor_alive_unsilenced: bool) -> bool:
	return doctor_alive_unsilenced


def poison_would_activate(monster_poison_pending: bool, player_poison: int, living_monsters: int) -> bool:
	if monster_poison_pending:
		return True
	return player_poison > 0 and living_monsters > 0


def should_show_blocked_fx(freeze: bool, would_activate: bool) -> bool:
	return freeze and would_activate


def expect(cond: bool, label: str, fails: list) -> None:
	if not cond:
		fails.append(label)


def main() -> int:
	fails: list[str] = []
	expect(freezes_poison(True) is True, "alive doctor freezes", fails)
	expect(freezes_poison(False) is False, "no doctor no freeze", fails)
	expect(poison_would_activate(True, 0, 0) is True, "monster poison pending", fails)
	expect(poison_would_activate(False, 3, 2) is True, "player poison pending", fails)
	expect(poison_would_activate(False, 3, 0) is False, "player poison skipped when no monsters", fails)
	expect(poison_would_activate(False, 0, 2) is False, "no poison nothing pending", fails)
	expect(should_show_blocked_fx(True, True) is True, "fx when freeze blocks", fails)
	expect(should_show_blocked_fx(True, False) is False, "no fx when nothing would tick", fails)
	expect(should_show_blocked_fx(False, True) is False, "no fx when poison pays", fails)
	if fails:
		print("FAIL:", "; ".join(fails))
		return 1
	print("OK sp28 plague doctor")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
