"""Insert Lucky Nickel into board, catalog, runtime, locks."""
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
TS = 1792428000.0
ABILITY = "Block 1. If your Block is now Even, Keep this."
FLOW = (
    "Click during a fight. Gain 1 Block. Then if your Block total is even, Keep "
    "(spent this fight, still in your hand for later fights, same as Lantern). "
    "If odd, used up. Twins only doubles even Block gains, so this 1 is not doubled. "
    "Basilisk still blocks Keep. Block resets to 0 each fight, so a first click at 0 "
    "becomes 1 (odd) and is used up unless you already held odd Block. Fight only. Not Attack."
)
NICKEL = {
    "id": "lucky_nickel",
    "name": "Lucky Nickel",
    "kind": "item",
    "bucket": 7,
    "tier": 1,
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
    "card_color": "blk",
    "call_name": "",
    "ability": ABILITY,
    "explainer": ABILITY,
    "log_hint": "Block 1, Keep if Block is even",
    "reminder": "",
    "ops": {"kind": "blk_even_keep", "n": 1},
    "flow": FLOW,
    "notes": "Bucket 7. Coin with Grandpa goblin's face. Not Attack.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": None,
    "atk_formula": "",
    "hp_base": None,
    "hp_formula": "",
    "contradiction_ids": [],
}


def load(p: Path) -> dict:
    return json.loads(p.read_text(encoding="utf-8"))


def upsert(rows: list, news: list) -> None:
    have = {str(r.get("id")) for r in rows}
    for n in news:
        if n["id"] not in have:
            rows.append(n)
            have.add(n["id"])
        else:
            for i, r in enumerate(rows):
                if str(r.get("id")) == n["id"]:
                    rows[i] = n
                    break


def to_cat(b: dict) -> dict:
    return {
        "id": b["id"], "name": b["name"], "ability": b["ability"], "explainer": b["explainer"],
        "defined": b["flow"], "exceptions": b.get("notes", ""), "log_hint": b["log_hint"],
        "bucket": b["bucket"], "tier": b["tier"], "count": 1, "priority": 3,
        "card_color": b.get("card_color", ""), "ops": b.get("ops", {}),
        "flags": b.get("flags", {}), "notes": b.get("notes", ""),
        "reminder": b.get("reminder", ""), "author_lock": True, "locked_at": NOW,
        "locked_fields": LOCK, "mode_pool": "all", "poc": False, "rarity": "uncommon",
        "review": "rough", "review_note": "", "status": "live", "type": "I", "call_name": "",
    }


def main() -> None:
    board = load(ROOT / "data" / "content-board.json")
    cat = load(ROOT / "data" / "catalog.json")
    run = load(ROOT / "data" / "runtime.json")
    rec = load(ROOT / "data" / "recent-edits.json")
    locks = load(ROOT / "data" / "author-locks.json")
    upsert(board["items"], [NICKEL])
    board["updated"] = NOW
    upsert(cat["items"], [to_cat(NICKEL)])
    if "lucky_nickel" not in run["items"]:
        run["items"].append("lucky_nickel")
    rec.setdefault("cards", {})
    rec["cards"]["item:lucky_nickel"] = TS
    rec["updated"] = f"{NOW}T00:45:00"
    cards = locks.setdefault("cards", {})
    cards["item:lucky_nickel"] = {"fields": LOCK, "locked_at": NOW, "name": "Lucky Nickel"}
    locks["updated"] = NOW

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok lucky_nickel")


if __name__ == "__main__":
    main()
