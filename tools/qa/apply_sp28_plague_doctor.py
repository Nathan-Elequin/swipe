#!/usr/bin/env python3
"""Apply SP-28 Plague Doctor rework text. Idempotent. Author-lock override 2026-10-28."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "data" / "catalog.json"
BOARD = ROOT / "data" / "content-board.json"
LOCKS = ROOT / "data" / "author-locks.json"

ABILITY = (
	"On Spin, my Neighbors Gain 2 Poison and Heal 2. "
	"While I live, Poison does not activate."
)
CALL = "Time Bomb"
EXPLAINER = "Spin: Neighbors +2 Poison and Heal 2. Poison frozen while I live."
REMINDER = "On Spin: Neighbors Gain 2 Poison and Heal 2. Poison does not activate while I live."
LOG_HINT = "Neighbors +2 Poison and Heal 2; Poison frozen while alive"
NOTES = "SP-28. Bucket 5. Freeze-all poison while alive (player + monsters). Quiet Bell turns this off."
FLOW = (
	"SP-28 (2026-10-28). On every Spin while I live unsilenced: each living Neighbor Gains 2 Poison "
	"and Heals 2 (cap at their max HP). Poison stacks keep growing. "
	"While I live unsilenced, Poison NEVER activates — monster poison and the player's poison both stay frozen. "
	"On the first Spin after I die (or Quiet Bell silences every living Plague Doctor), stored Poison activates normally. "
	"When Poison would activate but is blocked, show my slash portrait and the dissolving line "
	"'Poison does not activate'."
)


def dump(path: Path, data) -> None:
	path.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")


def patch_monster(row: dict, on_board: bool) -> None:
	row["ability"] = ABILITY
	row["call_name"] = CALL
	row["explainer"] = EXPLAINER
	row["reminder"] = REMINDER
	row["log_hint"] = LOG_HINT
	row["notes"] = NOTES
	if on_board:
		row["flow"] = FLOW
	else:
		row["defined"] = FLOW
		row["exceptions"] = NOTES
	row["author_lock"] = True
	row["locked_at"] = "2026-10-28"
	fields = row.get("locked_fields")
	if not isinstance(fields, list):
		fields = []
	for f in (
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
	):
		if f not in fields:
			fields.append(f)
	row["locked_fields"] = fields
	row["review_note"] = ""
	row["status"] = "live"


def main() -> None:
	catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
	board = json.loads(BOARD.read_text(encoding="utf-8"))
	locks = json.loads(LOCKS.read_text(encoding="utf-8"))

	for row in catalog.get("monsters", []):
		if row.get("id") == "plague_doctor":
			patch_monster(row, on_board=False)
			break
	else:
		raise SystemExit("plague_doctor missing from catalog")

	for row in board.get("monsters", []):
		if row.get("id") == "plague_doctor":
			patch_monster(row, on_board=True)
			break
	else:
		raise SystemExit("plague_doctor missing from content-board")

	cards = locks.setdefault("cards", {})
	cards["monster:plague_doctor"] = {
		"fields": [
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
		],
		"locked_at": "2026-10-28",
		"name": "Plague Doctor",
	}

	dump(CATALOG, catalog)
	dump(BOARD, board)
	dump(LOCKS, locks)
	print("SP-28 Plague Doctor catalog/board/locks updated")


if __name__ == "__main__":
	main()
