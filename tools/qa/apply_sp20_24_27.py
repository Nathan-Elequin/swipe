#!/usr/bin/env python3
"""Apply SP-20 Bushido, SP-24 Martyr, SP-27 Shambling Mound. Idempotent. Author-lock override 2026-10-28."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "data" / "catalog.json"
BOARD = ROOT / "data" / "content-board.json"
LOCKS = ROOT / "data" / "author-locks.json"
RECENT = ROOT / "data" / "recent-edits.json"

LOCK_FIELDS = [
	"name",
	"ability",
	"explainer",
	"flow",
	"notes",
	"ops",
	"rarity",
	"tier",
	"count",
	"priority",
	"atk_base",
	"hp_base",
	"atk_formula",
	"hp_formula",
	"call_name",
	"reminder",
	"card_color",
	"log_hint",
]

BUSHIDO = {
	"ability": "After each Item you use while facing me, swap my HP and Attack.",
	"call_name": "Dance Swap",
	"explainer": "After each Item while facing me: swap my HP and Attack",
	"reminder": "After each Item while facing me: swap my HP and Attack.",
	"log_hint": "After each item: swap HP and Attack",
	"notes": "SP-20. Bucket 3. After each counted item use while facing me unsilenced, swap current HP and Attack. If that item drops me to 0 HP I die and do not swap. Quiet Bell turns this off.",
	"exceptions": "SP-20. Replaces Patient Disarm. Quiet Bell turns this off.",
	"flow": (
		"SP-20 (2026-10-28). 6 HP / 5 Attack. After each Item you use while facing me "
		"(the same uses that increment items_used_this_combat), swap my current HP and Attack. "
		"If that item drops me to 0 HP, I die and do NOT swap. Quiet Bell: no swap. "
		"Replaces Patient Disarm (second-item dummy)."
	),
	"atk": 5,
	"hp": 6,
}

MARTYR = {
	"ability": "When I lose HP or Attack, I die. My Neighbors each gain HP equal to my remaining HP.",
	"call_name": "Noble Death",
	"explainer": "On HP loss or Attack: I die. Neighbors gain my remaining HP",
	"reminder": "On HP loss or Attack: I die. Neighbors gain my remaining HP.",
	"log_hint": "Dies on HP loss or Attack; neighbors gain remaining HP",
	"notes": "SP-24. Bucket 6. Wick, Berserker, Victory Flask, Mimic count this Defeat. Mimic does not gift because I already Attacked.",
	"exceptions": "SP-24. Bucket 6. Wick, Berserker, Victory Flask, Mimic count this Defeat. Mimic does not gift because I already Attacked.",
	"flow": (
		"SP-24 (2026-10-28). 7 HP / 0 Attack. I die on any HP loss (including poison ticks), "
		"when I would be Defeated, or when I Attack (0 Attack still Attacks). "
		"On death: each living Neighbor gains HP equal to my remaining HP measured after the loss "
		"that killed me (Attack / Defeat with HP still up uses the HP I still have). "
		"Gain grows max HP like Vampire. Empty seats skipped. Quiet Bell turns this off."
	),
	"atk": 0,
	"hp": 7,
}

MOUND = {
	"atk": 1,
	"hp": 6,
	"notes": "SP-27. Bucket 4. Walking moss heap. Like Hornet with ∞ swings. Any Attack, then Defeat with loot. HP 6 (babySlime Boss).",
	"exceptions": "SP-27. Bucket 4. Walking moss heap. Like Hornet with ∞ swings. Any Attack, then Defeat with loot. HP 6.",
	"flow_extra": "SP-27 (2026-10-28). HP is 6 (was 4). Behavior otherwise unchanged.",
}


def dump(path: Path, data) -> None:
	path.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")


def by_id(rows):
	return {row["id"]: row for row in rows}


def set_stats(row, atk, hp, on_board: bool) -> None:
	if on_board:
		row["atk_base"] = float(atk)
		row["hp_base"] = float(hp)
		row["atk_formula"] = ""
		row["hp_formula"] = ""
	else:
		row["atk"] = {"base": float(atk)}
		row["hp"] = {"base": float(hp)}


def stamp_lock(row) -> None:
	row["author_lock"] = True
	row["locked_at"] = "2026-10-28"
	fields = row.get("locked_fields")
	if not isinstance(fields, list):
		fields = []
	for f in LOCK_FIELDS:
		if f not in fields:
			fields.append(f)
	row["locked_fields"] = fields
	row["review_note"] = ""
	row["status"] = "live"


def patch_bushido(row, on_board: bool) -> None:
	set_stats(row, BUSHIDO["atk"], BUSHIDO["hp"], on_board)
	row["ability"] = BUSHIDO["ability"]
	row["call_name"] = BUSHIDO["call_name"]
	row["explainer"] = BUSHIDO["explainer"]
	row["reminder"] = BUSHIDO["reminder"]
	row["log_hint"] = BUSHIDO["log_hint"]
	row["notes"] = BUSHIDO["notes"]
	if on_board:
		row["flow"] = BUSHIDO["flow"]
	else:
		row["defined"] = BUSHIDO["flow"]
		row["exceptions"] = BUSHIDO["exceptions"]
	stamp_lock(row)


def patch_martyr(row, on_board: bool) -> None:
	set_stats(row, MARTYR["atk"], MARTYR["hp"], on_board)
	row["ability"] = MARTYR["ability"]
	row["call_name"] = MARTYR["call_name"]
	row["explainer"] = MARTYR["explainer"]
	row["reminder"] = MARTYR["reminder"]
	row["log_hint"] = MARTYR["log_hint"]
	row["notes"] = MARTYR["notes"]
	if on_board:
		row["flow"] = MARTYR["flow"]
	else:
		row["defined"] = MARTYR["flow"]
		row["exceptions"] = MARTYR["exceptions"]
	stamp_lock(row)


def patch_mound(row, on_board: bool) -> None:
	set_stats(row, MOUND["atk"], MOUND["hp"], on_board)
	row["notes"] = MOUND["notes"]
	if on_board:
		flow = str(row.get("flow", ""))
		if "SP-27" not in flow:
			row["flow"] = (flow + " " + MOUND["flow_extra"]).strip()
	else:
		defined = str(row.get("defined", ""))
		if "SP-27" not in defined:
			row["defined"] = (defined + " " + MOUND["flow_extra"]).strip()
		row["exceptions"] = MOUND["exceptions"]
	stamp_lock(row)


def upsert_ruling(rulings: list, rid: str, rule: str) -> None:
	for row in rulings:
		if row.get("id") == rid:
			row["chat"] = "2026-10-28"
			row["rule"] = rule
			return
	rulings.append({"chat": "2026-10-28", "id": rid, "rule": rule})


def main() -> None:
	catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
	board = json.loads(BOARD.read_text(encoding="utf-8"))
	locks = json.loads(LOCKS.read_text(encoding="utf-8"))
	recent = json.loads(RECENT.read_text(encoding="utf-8"))

	cat_m = by_id(catalog["monsters"])
	board_m = by_id(board["monsters"])

	patch_bushido(cat_m["bushido"], False)
	patch_bushido(board_m["bushido"], True)
	patch_martyr(cat_m["martyr"], False)
	patch_martyr(board_m["martyr"], True)
	patch_mound(cat_m["shambling_mound"], False)
	patch_mound(board_m["shambling_mound"], True)

	cards_lock = locks.setdefault("cards", {}) if isinstance(locks, dict) else {}
	for key, name in (
		("monster:bushido", "Bushido"),
		("monster:martyr", "Martyr"),
		("monster:shambling_mound", "Shambling Mound"),
	):
		cards_lock[key] = {
			"fields": list(LOCK_FIELDS),
			"locked_at": "2026-10-28",
			"name": name,
		}
	if isinstance(locks, dict):
		locks["updated"] = "2026-10-28"
		# Never park card locks at the document root.
		for key in ("monster:bushido", "monster:martyr", "monster:shambling_mound"):
			locks.pop(key, None)

	cards = recent.setdefault("cards", {})
	ts = 1793212800.0
	for key in ("monster:bushido", "monster:martyr", "monster:shambling_mound"):
		cards[key] = ts

	rulings = catalog.setdefault("rulings", [])
	upsert_ruling(
		rulings,
		"SP-20",
		"Bushido is 6 HP / 5 Attack. Dance Swap: after each Item used while facing him, swap current HP and Attack. "
		"An item that drops him to 0 HP kills him with no swap. Replaces Patient Disarm. Author-lock override 2026-10-28.",
	)
	upsert_ruling(
		rulings,
		"SP-24",
		"Martyr dies on any HP loss (including poison), when he would be Defeated, or when he Attacks. "
		"Neighbors gain his remaining HP measured after the loss that killed him (grow max like Vampire). "
		"Author-lock override 2026-10-28.",
	)
	upsert_ruling(
		rulings,
		"SP-27",
		"Shambling Mound HP is 6 (was 4). Self Deconstruct behavior unchanged. Author-lock override 2026-10-28.",
	)

	dump(CATALOG, catalog)
	dump(BOARD, board)
	dump(LOCKS, locks)
	dump(RECENT, recent)
	print("SP-20/24/27 Bushido Martyr Shambling Mound catalog/board/locks updated")


if __name__ == "__main__":
	main()
