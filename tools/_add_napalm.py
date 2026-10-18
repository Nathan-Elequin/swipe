"""Insert Napalm into board, catalog, runtime, locks."""
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
TS = 1792420000.0
ABILITY = "Set the HP of the Enemy, its Neighbors, and yourself to 1 HP"
FLOW = (
    "Click during a fight. Used up. Not Attack. Block does not apply. "
    "Bleed each target for (current HP − 1) in one loss event, stopping at 1. "
    "Order: facing Enemy, then left neighbor (clockwise), then right neighbor (counter-clockwise), then you. "
    "Skip a neighbor at 0 HP (no revive). Already at 1 loses 0. Anvil goes to 1 anyway. "
    "Losing HP still triggers Ogre, Vampire, Spiked Flail, Cowardly King. "
    "Coward Attacks when they lose HP (you still have HP and Block); Flee waits until this item finishes. "
    "Fight only."
)
NAPALM = {
    "id": "napalm",
    "name": "Napalm",
    "kind": "item",
    "bucket": 6,
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
    "card_color": "utility",
    "call_name": "",
    "ability": ABILITY,
    "explainer": ABILITY,
    "log_hint": "Bleed enemy, neighbors, you to 1",
    "reminder": "",
    "ops": {"kind": "napalm"},
    "flow": FLOW,
    "notes": "Bucket 6. Fire storm art. Same Bleed as Cursed Scroll, not Attack.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": None,
    "atk_formula": "",
    "hp_base": None,
    "hp_formula": "",
    "contradiction_ids": [],
}


def load(p: Path) -> dict:
    return json.loads(p.read_text(encoding="utf-8"))


def dump(p: Path, data: dict) -> None:
    p.write_text(json.dumps(p.read_text(encoding="utf-8") if False else json.dumps(data), indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")


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
    upsert(board["items"], [NAPALM])
    board["updated"] = NOW
    upsert(cat["items"], [to_cat(NAPALM)])
    if "napalm" not in run["items"]:
        run["items"].append("napalm")
    rec.setdefault("cards", {})
    rec["cards"]["item:napalm"] = TS
    rec["updated"] = f"{NOW}T00:35:00"
    cards = locks.setdefault("cards", {})
    cards["item:napalm"] = {"fields": LOCK, "locked_at": NOW, "name": "Napalm"}
    locks["updated"] = NOW

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok napalm")


if __name__ == "__main__":
    main()
