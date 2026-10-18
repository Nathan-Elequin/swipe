"""Insert Cultist and Blood Pact into board, catalog, runtime, locks."""
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
TS = 1792438800.0
CULTIST_ABILITY = "When you Spin me or my Neighbor, Gain 1 Blood Pact"
PACT_ABILITY = "You and your Enemy lose 2 HP"
CULTIST_FLOW = (
    "After Spin, each living Cultist who is not silenced grants 1 Blood Pact if you landed on them "
    "or on a monster sitting next to them. Two Cultists who both qualify grant two. Full hand: skip. "
    "Quiet Bell on the Cultist: that Cultist does not grant. Quiet Bell on their neighbor: they still grant. "
    "Grappling Hook and Damsel neighbors are not a Spin. Token is not loot. Then the fight happens as usual."
)
PACT_FLOW = (
    "Click during a fight. Used up. You lose 2 HP and the facing enemy loses 2 HP. Not Attack: Block does "
    "not stop it, Goblin takes it, Flail ticks. Anvil still max 1. Both chips happen even if you would hit 0; "
    "Healing Potion can save you. If they hit 0, they are Defeated. If you hit 0 and Potion does not save, you die. "
    "Not drafted. Cultist creates it. Tier 0 so Merchant can turn it into a Tier 1 item."
)
CULTIST = {
    "id": "cultist",
    "name": "Cultist",
    "kind": "monster",
    "bucket": 8,
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
    "call_name": "Blood Pact",
    "ability": CULTIST_ABILITY,
    "explainer": CULTIST_ABILITY,
    "log_hint": "Spin me or my neighbor: Gain Blood Pact",
    "reminder": "",
    "ops": {},
    "flow": CULTIST_FLOW,
    "notes": "Bucket 8. Hooded robe. One pact per qualifying Cultist.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": 2,
    "atk_formula": "",
    "hp_base": 2,
    "hp_formula": "",
    "contradiction_ids": [],
}
PACT = {
    "id": "blood_pact",
    "name": "Blood Pact",
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
    "ability": PACT_ABILITY,
    "explainer": PACT_ABILITY,
    "log_hint": "You and the enemy lose 2 HP",
    "reminder": "",
    "ops": {"kind": "blood_pact", "n": 2},
    "flow": PACT_FLOW,
    "notes": "Token. Not drafted. Cultist creates it. Black card like Egg. HP chip, not Attack.",
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
    upsert(board["monsters"], [CULTIST])
    upsert(board["items"], [PACT])
    board["updated"] = NOW
    upsert(cat["monsters"], [to_cat_m(CULTIST)])
    upsert(cat["items"], [to_cat_i(PACT)])
    if "cultist" not in run["monsters"]:
        run["monsters"].append("cultist")
    if "blood_pact" not in run["items"]:
        run["items"].append("blood_pact")
    rec.setdefault("cards", {})
    rec["cards"]["monster:cultist"] = TS
    rec["cards"]["item:blood_pact"] = TS
    rec["updated"] = f"{NOW}T01:50:00"
    cards = locks.setdefault("cards", {})
    cards["monster:cultist"] = {"fields": LOCK, "locked_at": NOW, "name": "Cultist"}
    cards["item:blood_pact"] = {"fields": LOCK, "locked_at": NOW, "name": "Blood Pact"}
    locks["updated"] = NOW

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    print("ok cultist blood_pact")


if __name__ == "__main__":
    main()
