"""Insert Bushido into board, catalog, runtime, locks."""
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
TS = 1792440000.0
ABILITY = "When facing me, your second Item used has no effect"
FLOW = (
    "After your first item click this fight resolves, every card looks overlaid like Petrify, "
    "but you can still click any card you could already click. That second click discards the card "
    "immediately: no Attack, Block, Heal, targeting menu, or Keep. Counting Beads and Sai still tick. "
    "Hex and Double-Buckler stay Unplayable. Petrified cards stay unclickable. Healing Potion and "
    "Double-Buckler auto do not count. Done after one item is legal. Quiet Bell: no overlay. "
    "Grappling Hook and Damsel neighbors are not this fight."
)
CARD = {
    "id": "bushido",
    "name": "Bushido",
    "kind": "monster",
    "bucket": 3,
    "tier": 2,
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
    "call_name": "Patient Disarm",
    "ability": ABILITY,
    "explainer": ABILITY,
    "log_hint": "Second item this fight does nothing",
    "reminder": "",
    "ops": {},
    "flow": FLOW,
    "notes": "Bucket 3. Samurai unsheathing. Overlay like petrify; dummy still clickable.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": 4,
    "atk_formula": "",
    "hp_base": 5,
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
    if "bushido" not in run["monsters"]:
        run["monsters"].append("bushido")
    rec.setdefault("cards", {})
    rec["cards"]["monster:bushido"] = TS
    rec["updated"] = f"{NOW}T01:55:00"
    cards = locks.setdefault("cards", {})
    cards["monster:bushido"] = {"fields": LOCK, "locked_at": NOW, "name": "Bushido"}
    locks["updated"] = NOW

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok bushido")


if __name__ == "__main__":
    main()
