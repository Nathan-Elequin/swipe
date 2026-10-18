"""Insert Hydra into board, catalog, runtime, locks."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
LOCK = [
    "name", "ability", "explainer", "flow", "notes", "ops", "rarity", "tier",
    "count", "priority", "atk_base", "hp_base", "atk_formula", "hp_formula",
    "call_name", "reminder", "card_color", "log_hint",
]
NOW = "2026-10-18"
TS = 1792410000.0
FLOW = (
    "When you Spin me (same moment as Gargoyle, before Queen eggs and Juggernaut Shield): "
    "look at the live Attack or Block number on each item in hand. Egg counts. 0 is even. "
    "Heal, Defeat, Poison, Hex, Potion, Bag, Magnet, and Smoke do not. Even numbers are Petrified "
    "(Unplayable until your next Spin, same overlay as Gargoyle). Then I Gain +2 Attack for each "
    "item petrified this landing. That Attack stays on me for the dungeon and stacks if you Spin me "
    "again. Quiet Bell after I fired: I keep the Attack; I will not Petrify or Gain on a later landing. "
    "Quiet Bell before I fire: this landing does nothing."
)
HYDRA = {
    "id": "hydra",
    "name": "Hydra",
    "kind": "monster",
    "bucket": 7,
    "tier": 3,
    "count": 1,
    "priority": 3,
    "rarity": "uncommon",
    "status": "live",
    "review": "rough",
    "review_note": "",
    "author_lock": True,
    "locked_at": NOW,
    "locked_fields": LOCK,
    "mode_pool": "all",
    "card_color": "",
    "call_name": "Even Killer",
    "ability": "I Petrify all Items with an Even Atk or Blk value and Gain +2 Atk for each",
    "explainer": "Petrify even Attack and Block. +2 Attack each.",
    "log_hint": "Petrify even ATK/BLK, +2 ATK each",
    "reminder": "Petrify even Attack and Block. +2 Attack each.",
    "atk_base": 3,
    "hp_base": 5,
    "atk_formula": "",
    "hp_formula": "",
    "ops": {},
    "flow": FLOW,
    "notes": "Bucket 7. Petrify tooltip is Gargoyle’s: Unplayable until your next Spin.",
    "flags": {"art": True, "dev": True, "hide": False},
    "contradiction_ids": [],
}


def load(p: Path) -> dict:
    return json.loads(p.read_text(encoding="utf-8"))


def dump(p: Path, data: dict) -> None:
    p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")


def upsert(rows: list, news: list) -> None:
    have = {str(r.get("id")) for r in rows}
    for n in news:
        if n["id"] not in have:
            rows.append(n)
            have.add(n["id"])


def to_cat(b: dict) -> dict:
    return {
        "id": b["id"], "name": b["name"], "ability": b["ability"], "explainer": b["explainer"],
        "defined": b["flow"], "exceptions": b.get("notes", ""), "log_hint": b["log_hint"],
        "bucket": b["bucket"], "tier": b["tier"], "count": 1, "priority": 3,
        "call_name": b.get("call_name", ""), "reminder": b.get("reminder", ""),
        "atk": {"base": int(b.get("atk_base") or 0)},
        "hp": {"base": int(b.get("hp_base") or 0)},
        "notes": b.get("notes", ""), "author_lock": True, "locked_at": NOW,
        "locked_fields": LOCK, "mode_pool": "all", "poc": False, "rarity": "uncommon",
        "review": "rough", "review_note": "", "status": "live", "type": "M",
        "card_color": "", "flags": b.get("flags", {}), "ops": {},
    }


def main() -> None:
    board = load(ROOT / "data" / "content-board.json")
    cat = load(ROOT / "data" / "catalog.json")
    run = load(ROOT / "data" / "runtime.json")
    rec = load(ROOT / "data" / "recent-edits.json")
    locks = load(ROOT / "data" / "author-locks.json")
    upsert(board["monsters"], [HYDRA])
    board["updated"] = NOW
    upsert(cat["monsters"], [to_cat(HYDRA)])
    if "hydra" not in run["monsters"]:
        run["monsters"].append("hydra")
    rec.setdefault("cards", {})
    rec["cards"]["monster:hydra"] = TS
    rec["updated"] = f"{NOW}T00:25:00"
    cards = locks.setdefault("cards", {})
    cards["monster:hydra"] = {"fields": LOCK, "locked_at": NOW, "name": "Hydra"}
    locks["updated"] = NOW
    dump(ROOT / "data" / "content-board.json", board)
    dump(ROOT / "data" / "catalog.json", cat)
    dump(ROOT / "data" / "runtime.json", run)
    dump(ROOT / "data" / "recent-edits.json", rec)
    dump(ROOT / "data" / "author-locks.json", locks)
    print("ok hydra")


if __name__ == "__main__":
    main()
