"""Insert Double-Buckler into board, catalog, runtime, locks."""
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
TS = 1792436400.0
ABILITY = "Unplayable. Take half damage the next time you receive Even Atk damage, then Discard this."
FLOW = (
    "Never click this. Listens like Healing Potion. The next enemy Attack whose ATK number is even "
    "(2, 4, 6…) and would deal more than 0 after Block/pierce: mid-swing, cut that ATK in half "
    "(floor), then apply Block. Discard. 0 ATK and fully blocked even ATK do not fire. Spider Egg "
    "is not an enemy. Hornet/Damsel/Kobold/Shambling Mound: waits for the first even swing in that "
    "burst, then later swings are full. Two copies: first even spends one. Petrify still listens. "
    "Potion can still save if the halved hit kills you."
)
CARD = {
    "id": "double_buckler",
    "name": "Double-Buckler",
    "kind": "item",
    "bucket": 2,
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
    "log_hint": "Halve the next even enemy Attack",
    "reminder": "",
    "ops": {"kind": "passive"},
    "flow": FLOW,
    "notes": "Bucket 2. Two round bucklers. Unplayable. Not Egg, not Poison.",
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
    upsert(board["items"], [CARD])
    board["updated"] = NOW
    upsert(cat["items"], [to_cat(CARD)])
    if "double_buckler" not in run["items"]:
        run["items"].append("double_buckler")
    rec.setdefault("cards", {})
    rec["cards"]["item:double_buckler"] = TS
    rec["updated"] = f"{NOW}T01:30:00"
    cards = locks.setdefault("cards", {})
    cards["item:double_buckler"] = {"fields": LOCK, "locked_at": NOW, "name": "Double-Buckler"}
    locks["updated"] = NOW

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok double_buckler")


if __name__ == "__main__":
    main()
