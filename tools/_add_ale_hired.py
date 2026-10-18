"""Insert Ale Flagon and Hired Hand into board, catalog, runtime, locks."""
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
TS = 1792400000.0


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


ALE = {
    "id": "ale_flagon",
    "name": "Ale Flagon",
    "kind": "item",
    "bucket": 6,
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
    "card_color": "heal",
    "call_name": "",
    "ability": "Heal 5. Gain 3 Poison.",
    "explainer": "Heal 5. Gain 3 Poison.",
    "log_hint": "Heal 5, Gain 3 Poison",
    "reminder": "",
    "ops": {"kind": "heal_poison", "heal": 5, "poison": 3},
    "flow": "Click during a fight. Used up. Heal 5 (cap 6). Gain 3 Poison; amounts add. Droplet with the number sits next to your HP. Next Spin: facing monster’s poison ticks first and clears, then you lose HP equal to your poison and it clears. Block does not stop it. If that Spin already finished the last monster, skip your tick (victory). Healing Potion still saves a 0; poison is already gone. New dungeon wipes leftover poison. Any Spin counts.",
    "notes": "Bucket 6. Same droplet as monster poison.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": None,
    "atk_formula": "",
    "hp_base": None,
    "hp_formula": "",
    "contradiction_ids": [],
}

HIRED = {
    "id": "hired_hand",
    "name": "Hired Hand",
    "kind": "monster",
    "bucket": 6,
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
    "call_name": "Bribe",
    "ability": "If you Discard an item when facing me, I will Attack one of my Neighbors and Flee.",
    "explainer": "Discard an item: I Attack a Neighbor and Flee.",
    "log_hint": "Pay an item, I hit a Neighbor and Flee",
    "reminder": "Discard an item: I Attack a Neighbor and Flee.",
    "atk_base": 3,
    "hp_base": 4,
    "atk_formula": "",
    "hp_formula": "",
    "ops": {},
    "flow": "After Spin, overlay. Click any card in hand (Hex, Potion, Egg, Marble, petrified) to Discard it. That is not an item use. I deal my Attack to one living Neighbor at random (Pocketwatch rules: Needleback hits me). Then I Flee. No living Neighbors: Decline only, I do not Flee. Empty hand: overlay, Decline only, then a snarky line and we fight. Quiet Bell turns this off. Decline: snark, then ordinary combat.",
    "notes": "Bucket 6. Flee keeps the live tooltip.",
    "flags": {"art": True, "dev": True, "hide": False},
    "contradiction_ids": [],
}


def to_cat_item(b: dict) -> dict:
    return {
        "id": b["id"], "name": b["name"], "ability": b["ability"], "explainer": b["explainer"],
        "defined": b["flow"], "exceptions": b.get("notes", ""), "log_hint": b["log_hint"],
        "bucket": b["bucket"], "tier": b["tier"], "count": b.get("count", 1),
        "priority": b.get("priority", 3), "card_color": b.get("card_color", ""),
        "ops": b.get("ops", {}), "flags": b.get("flags", {}), "notes": b.get("notes", ""),
        "reminder": b.get("reminder", ""), "author_lock": True, "locked_at": NOW,
        "locked_fields": LOCK, "mode_pool": "all", "poc": False, "rarity": "uncommon",
        "review": "rough", "review_note": "", "status": "live", "type": "I", "call_name": "",
    }


def to_cat_mon(b: dict) -> dict:
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
    upsert(board["items"], [ALE])
    upsert(board["monsters"], [HIRED])
    board["updated"] = NOW
    upsert(cat["items"], [to_cat_item(ALE)])
    upsert(cat["monsters"], [to_cat_mon(HIRED)])
    if "ale_flagon" not in run["items"]:
        run["items"].append("ale_flagon")
    if "hired_hand" not in run["monsters"]:
        run["monsters"].append("hired_hand")
    rec.setdefault("cards", {})
    rec["cards"]["item:ale_flagon"] = TS
    rec["cards"]["monster:hired_hand"] = TS
    rec["updated"] = f"{NOW}T00:11:00"
    cards = locks.setdefault("cards", {})
    cards["item:ale_flagon"] = {"fields": LOCK, "locked_at": NOW, "name": "Ale Flagon"}
    cards["monster:hired_hand"] = {"fields": LOCK, "locked_at": NOW, "name": "Hired Hand"}
    locks["updated"] = NOW
    dump(ROOT / "data" / "content-board.json", board)
    dump(ROOT / "data" / "catalog.json", cat)
    dump(ROOT / "data" / "runtime.json", run)
    dump(ROOT / "data" / "recent-edits.json", rec)
    dump(ROOT / "data" / "author-locks.json", locks)
    print("ok", ALE["id"], HIRED["id"])


if __name__ == "__main__":
    main()
