"""Insert Almighty Worm into board, catalog, runtime, locks."""
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
TS = 1792437600.0
ABILITY = "When you Spin me, you may Discard Items. Each sacrifice reduces my Atk and HP by 3."
FLOW = (
    "After Spin, overlay like Hired Hand. Click any card in hand (Hex, Potion, Egg, Marble, petrified) "
    "one at a time to Discard it; that is not an item use. Each Discard: I lose 3 Attack and 3 HP, "
    "and those numbers stay on this slice for later Spins. Continue ends the overlay and you fight "
    "at the numbers left. If HP hits 0 from a Discard, I am Defeated (loot, empty seat) and combat ends. "
    "Empty hand: Continue only, then 9/9. Quiet Bell: no overlay. Grappling Hook and Damsel neighbors "
    "are not a Spin. Commander +2 still applies after the −3."
)
CARD = {
    "id": "almighty_worm",
    "name": "Almighty Worm",
    "kind": "monster",
    "bucket": 3,
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
    "call_name": "Hunger Pains",
    "ability": ABILITY,
    "explainer": ABILITY,
    "log_hint": "Discard items: I lose 3 Attack and 3 HP each",
    "reminder": "",
    "ops": {},
    "flow": FLOW,
    "notes": "Bucket 3. Sand worm. Overlay + Continue. Stats stay reduced.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": 9,
    "atk_formula": "",
    "hp_base": 9,
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
    if "almighty_worm" not in run["monsters"]:
        run["monsters"].append("almighty_worm")
    rec.setdefault("cards", {})
    rec["cards"]["monster:almighty_worm"] = TS
    rec["updated"] = f"{NOW}T01:40:00"
    cards = locks.setdefault("cards", {})
    cards["monster:almighty_worm"] = {"fields": LOCK, "locked_at": NOW, "name": "Almighty Worm"}
    locks["updated"] = NOW

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok almighty_worm")


if __name__ == "__main__":
    main()
