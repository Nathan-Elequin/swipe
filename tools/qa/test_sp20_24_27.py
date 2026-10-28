#!/usr/bin/env python3
"""SP-20/24/27 pure-rule and catalog checks."""

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]


def expect(cond: bool, label: str, fails: list) -> None:
	if not cond:
		fails.append(label)


def bushido_should_swap(alive: bool, silenced: bool, hp_after: int) -> bool:
	return alive and not silenced and hp_after > 0


def bushido_swap(hp: int, atk: int) -> tuple:
	return atk, hp


def martyr_gift(hp_after: int) -> int:
	return max(0, hp_after)


def main() -> int:
	fails: list[str] = []
	catalog = json.loads((ROOT / "data/catalog.json").read_text(encoding="utf-8"))
	board = json.loads((ROOT / "data/content-board.json").read_text(encoding="utf-8"))
	mons = {m["id"]: m for m in catalog["monsters"]}
	bmons = {m["id"]: m for m in board["monsters"]}

	b = mons["bushido"]
	expect(b.get("call_name") == "Dance Swap", "bushido call", fails)
	expect("Patient Disarm" not in str(b.get("call_name", "")), "no Patient Disarm call", fails)
	expect(int(b["atk"]["base"]) == 5, "bushido atk 5", fails)
	expect(int(b["hp"]["base"]) == 6, "bushido hp 6", fails)
	expect("swap my HP and Attack" in str(b.get("ability", "")), "bushido ability", fails)
	expect("SP-20" in str(b.get("defined", "")), "bushido defined", fails)

	bb = bmons["bushido"]
	expect(bb.get("call_name") == "Dance Swap", "board bushido call", fails)
	expect(float(bb.get("atk_base", 0)) == 5.0, "board bushido atk", fails)
	expect(float(bb.get("hp_base", 0)) == 6.0, "board bushido hp", fails)

	m = mons["martyr"]
	expect(m.get("call_name") == "Noble Death", "martyr call", fails)
	expect(int(m["atk"]["base"]) == 0, "martyr atk 0", fails)
	expect(int(m["hp"]["base"]) == 7, "martyr hp 7", fails)
	expect("lose HP" in str(m.get("ability", "")), "martyr ability hp loss", fails)
	expect("SP-24" in str(m.get("defined", "")), "martyr defined", fails)

	sm = mons["shambling_mound"]
	expect(int(sm["hp"]["base"]) == 6, "mound hp 6", fails)
	expect(float(bmons["shambling_mound"].get("hp_base", 0)) == 6.0, "board mound hp", fails)
	expect("SP-27" in str(sm.get("defined", "")), "mound defined", fails)

	rulings = {r["id"]: r for r in catalog.get("rulings", [])}
	for rid in ("SP-20", "SP-24", "SP-27"):
		expect(rid in rulings, f"ruling {rid}", fails)
		expect(rulings.get(rid, {}).get("chat") == "2026-10-28", f"{rid} date", fails)

	expect(bushido_should_swap(True, False, 6), "swap when alive", fails)
	expect(not bushido_should_swap(True, False, 0), "no swap at 0", fails)
	expect(not bushido_should_swap(True, True, 6), "no swap silenced", fails)
	expect(bushido_swap(6, 5) == (5, 6), "swap pair", fails)
	expect(martyr_gift(5) == 5, "gift after partial", fails)
	expect(martyr_gift(0) == 0, "gift after lethal", fails)

	main_gd = (ROOT / "scripts/main.gd").read_text(encoding="utf-8")
	expect("Dance Swap" in main_gd or "dance_swap" in main_gd, "main has dance_swap", fails)
	expect("_bushido_dance_swap" in main_gd, "main has dance swap fn", fails)
	expect("_martyr_after_hp_loss" in main_gd, "main has martyr hp loss", fails)
	expect("patient_disarm" not in main_gd or "Dance Swap" in main_gd, "patient disarm replaced", fails)

	if fails:
		print("SP_DALLAS_FAIL")
		for f in fails:
			print(" -", f)
		return 1
	print("SP_DALLAS_OK")
	return 0


if __name__ == "__main__":
	sys.exit(main())
