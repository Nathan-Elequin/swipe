"""Insert Shambling Mound into board, catalog, runtime, locks."""
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
TS = 1792435200.0
ABILITY = "I Attack repeatedly until I die. I lose 1 HP each time I Attack."
FLOW = (
    "On any Attack this monster makes (Done, Damsel neighbor, Pocketwatch), it swings, then loses "
    "1 of its own HP, then swings again until that HP is 0. Swing count is remaining HP. ATK stays 1 "
    "(Commander still adds). Block leftover carries like Hornet. Quiet Bell: one swing, no HP loss. "
    "Flee skips the Attack, so they do not fall apart. Self HP loss is not your Attack (no Needleback, "
    "Twins, Prism). Hitting 0 is a normal Defeat with loot. Plate badge is ∞; Shift uses remaining HP."
)
CARD = {
    "id": "shambling_mound",
    "name": "Shambling Mound",
    "kind": "monster",
    "bucket": 4,
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
    "card_color": "",
    "call_name": "Self Deconstruct",
    "ability": ABILITY,
    "explainer": ABILITY,
    "log_hint": "Attacks until it dies; loses 1 HP per Attack",
    "reminder": "",
    "ops": {},
    "flow": FLOW,
    "notes": "Bucket 4. Walking moss heap. Like Hornet with ∞ swings. Any Attack, then Defeat with loot.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": 1,
    "atk_formula": "",
    "hp_base": 4,
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
    upsert(board["monsters"], [CARD])
    board["updated"] = NOW
    upsert(cat["monsters"], [to_cat(CARD)])
    if "shambling_mound" not in run["monsters"]:
        run["monsters"].append("shambling_mound")
    rec.setdefault("cards", {})
    rec["cards"]["monster:shambling_mound"] = TS
    rec["updated"] = f"{NOW}T01:15:00"
    cards = locks.setdefault("cards", {})
    cards["monster:shambling_mound"] = {"fields": LOCK, "locked_at": NOW, "name": "Shambling Mound"}
    locks["updated"] = NOW

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok shambling_mound")


if __name__ == "__main__":
    main()
