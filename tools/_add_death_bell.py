"""Insert Death Bell and Toll into board, catalog, runtime, locks."""
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
TS = 1792462800.0
BELL_ABILITY = "When I Spawn, Gain 1 Toll. On Spin, I lose 2 HP. When I am Defeated, Discard 1 Item."
TOLL_ABILITY = "Unplayable. On Item Use, decrease this by 1. When this reaches 0, Die."
BELL_FLOW = (
    "When this slice is added to the wheel (Place, Challenge fill, Clockwork heir, Developer Test), "
    "Gain 1 Toll at 6 even if Zombie would block Gain. If the hand is full, the player clicks one item "
    "to throw away, then Toll lands. A second Death Bell grants a second Toll at 6. On Spin of this "
    "monster, if it is not silenced, it loses 2 HP (Anvil still max 1). Quiet Bell: skip the -2 HP and "
    "skip the Defeat discard; Tolls already in hand still tick. Item uses that already increment Beads "
    "(including Bushido's dummy throw) tick every Toll by 1. Potion auto, Buckler auto, and Cube/Worm/"
    "overlay picks do not tick. At Toll 1 the card pulses. At 0 they Die; Healing Potion can save. If "
    "the killing item ticks Toll from 1 to 0 while this Bell is the one being Defeated, the Defeat "
    "discard overlay happens first so they can throw Toll away and live. Defeat overlay: must click one "
    "item (Ability as the line), then the Bell rings and leaves with loot. Empty hand: skip discard, "
    "still ring. Toll is T0, black like Egg, Unplayable, not drafted."
)
TOLL_FLOW = (
    "Unplayable token. Starts at 6. Each item use that increments the Beads counter lowers the number "
    "by 1. At 1 it pulses. At 0: Die, Healing Potion can save. Overlay picks (Cube, Worm, Merchant, "
    "Bell spawn/defeat) do not tick. Bushido dummy throw does tick. Potion auto and Buckler auto do "
    "not. Stays between fights until dumped or it hits 0. Cube can eat it. Merchant can upgrade it."
)
BELL = {
    "id": "death_bell",
    "name": "Death Bell",
    "kind": "monster",
    "bucket": 9,
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
    "call_name": "Toll Of The Dead",
    "ability": BELL_ABILITY,
    "explainer": BELL_ABILITY,
    "log_hint": "Spawn Toll. Spin -2 HP. Defeat: Discard 1 Item.",
    "reminder": "",
    "ops": {},
    "flow": BELL_FLOW,
    "notes": "Bucket 9. Giant evil church bell. 12 HP 8 ATK.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": 8,
    "atk_formula": "",
    "hp_base": 12,
    "hp_formula": "",
    "contradiction_ids": [],
}
TOLL = {
    "id": "toll",
    "name": "Toll",
    "kind": "item",
    "bucket": -1,
    "tier": 0,
    "count": 0,
    "priority": 9,
    "rarity": "uncommon",
    "status": "live",
    "review": "rough",
    "review_note": "",
    "author_lock": True,
    "locked_at": NOW,
    "locked_fields": LOCK,
    "mode_pool": "all",
    "card_color": "egg",
    "call_name": "",
    "ability": TOLL_ABILITY,
    "explainer": TOLL_ABILITY,
    "log_hint": "Unplayable countdown. 0 = Die.",
    "reminder": "",
    "ops": {"kind": "toll"},
    "flow": TOLL_FLOW,
    "notes": "Token. Not drafted. Death Bell creates it. Black card like Egg. Starts at 6.",
    "flags": {"art": True, "dev": True, "hide": True},
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


def to_cat_m(b: dict) -> dict:
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


def to_cat_i(b: dict) -> dict:
    return {
        "id": b["id"], "name": b["name"], "ability": b["ability"], "explainer": b["explainer"],
        "defined": b["flow"], "exceptions": b.get("notes", ""), "log_hint": b["log_hint"],
        "bucket": b["bucket"], "tier": b["tier"], "count": 0, "priority": 9,
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
    upsert(board["monsters"], [BELL])
    upsert(board["items"], [TOLL])
    board["updated"] = NOW
    upsert(cat["monsters"], [to_cat_m(BELL)])
    upsert(cat["items"], [to_cat_i(TOLL)])
    if "death_bell" not in run["monsters"]:
        run["monsters"].append("death_bell")
    if "toll" not in run["items"]:
        run["items"].append("toll")
    rec.setdefault("cards", {})
    rec["cards"]["monster:death_bell"] = TS
    rec["cards"]["item:toll"] = TS
    rec["updated"] = f"{NOW}T03:00:00"
    cards = locks.setdefault("cards", {})
    cards["monster:death_bell"] = {"fields": LOCK, "locked_at": NOW, "name": "Death Bell"}
    cards["item:toll"] = {"fields": LOCK, "locked_at": NOW, "name": "Toll"}
    locks["updated"] = NOW

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok death_bell toll")


if __name__ == "__main__":
    main()
