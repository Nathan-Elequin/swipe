"""Insert Jar O' Grease and Shark; rewrite Chaos Stone Ability to Swap."""
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
TS = 1792452000.0
JAR_ABILITY = "Heal 2, randomly Swap an Item, and Keep this."
JAR_FLOW = (
    "Click during a fight. Heal 2 (cap 6). Then one other unspent item in your hand Swaps: "
    "it is exchanged for a random leftover copy of the same Tier from the draft pile, and the "
    "old card goes back into that pile. You cannot Swap into a card with no remaining count. "
    "Never Swaps the Jar itself. If there is no legal other item (only the Jar, or no leftover "
    "copy of that item's Tier), the click is illegal. Keep this unless facing Zombie. Counts as "
    "an item use. Swap keyword: exchange for a random Item of the same Tier."
)
STONE_ABILITY = "Choose 2 Items and Swap them."
STONE_EXPLAINER = "Swap 1 or 2 other items."
STONE_FLOW = (
    "Click during a fight, then click other items in your hand. If you hold only one other item "
    "that can Swap, Swap that one. If you hold two or more that can Swap, pick two. Each Swap "
    "exchanges that card for a random leftover copy of the same Tier from the draft pile and "
    "returns the old card to the pile. You cannot Swap into a card with no remaining count. "
    "This card cannot target itself. Unplayable if nothing can Swap. Used up. Counts as an item use."
)
SHARK_ABILITY = "I Attack until you lose HP"
SHARK_FLOW = (
    "On any Attack this monster makes (Done, Damsel neighbor, Pocketwatch), it keeps swinging "
    "until you lose any HP this Attack. Prior HP loss this fight does not count. Quiet Bell: one "
    "swing even if leftover is 0. Net leftover 0: Attack 5 times for 0, then unique dialogue "
    "'Oh, so it's gonna be like that, huh? Wow. What a way to die.' then SLAIN (not BLOCKED), "
    "with loot. Pocketwatch: keep hitting the facing enemy until that enemy loses HP; Goblin "
    "and unhittable: one swing and stop, Shark is not slain. Plate badge is a loop mark, not ∞."
)
JAR = {
    "id": "jar_o_grease",
    "name": "Jar O' Grease",
    "kind": "item",
    "bucket": 0,
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
    "card_color": "heal",
    "call_name": "",
    "ability": JAR_ABILITY,
    "explainer": JAR_ABILITY,
    "log_hint": "Heal 2, randomly Swap an Item, Keep",
    "reminder": "",
    "ops": {"kind": "heal_swap_keep", "n": 2},
    "flow": JAR_FLOW,
    "notes": "Bucket 0. Jar of grease. Swap uses leftover draft counts.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": None,
    "atk_formula": "",
    "hp_base": None,
    "hp_formula": "",
    "contradiction_ids": [],
}
SHARK = {
    "id": "shark",
    "name": "Shark",
    "kind": "monster",
    "bucket": 4,
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
    "call_name": "Blood Thresh",
    "ability": SHARK_ABILITY,
    "explainer": SHARK_ABILITY,
    "log_hint": "Attacks until you lose HP",
    "reminder": "",
    "ops": {},
    "flow": SHARK_FLOW,
    "notes": "Bucket 4. Shark. Loop until you bleed; Net 5 zeros then slain.",
    "flags": {"art": True, "dev": True, "hide": False},
    "atk_base": 3,
    "atk_formula": "",
    "hp_base": 6,
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


def to_cat_i(b: dict) -> dict:
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


def rewrite_stone(rows: list) -> None:
    for r in rows:
        if str(r.get("id")) != "mute_stone":
            continue
        r["ability"] = STONE_ABILITY
        r["explainer"] = STONE_EXPLAINER
        r["defined"] = STONE_FLOW
        r["log_hint"] = "Swap 1 or 2 other items"
        r["review_note"] = ""
        break


def add_keyword_rows(copy: dict) -> None:
    rows = copy.setdefault("rows", [])
    keys = {str(r.get("key")) for r in rows}
    extra = [
        {
            "cat": "Inspect",
            "key": "keyword.swap",
            "where": "Keyword tip title for Swap",
            "text": "Swap",
            "author_lock": True,
            "locked_at": NOW,
        },
        {
            "cat": "Inspect",
            "key": "keyword.swap_body",
            "where": "Keyword tip body for Swap",
            "text": "exchange for a random Item of the same Tier",
            "author_lock": True,
            "locked_at": NOW,
        },
    ]
    for row in extra:
        if row["key"] not in keys:
            rows.append(row)


def main() -> None:
    board = load(ROOT / "data" / "content-board.json")
    cat = load(ROOT / "data" / "catalog.json")
    run = load(ROOT / "data" / "runtime.json")
    rec = load(ROOT / "data" / "recent-edits.json")
    locks = load(ROOT / "data" / "author-locks.json")
    copy = load(ROOT / "data" / "player-copy.json")
    upsert(board["items"], [JAR])
    upsert(board["monsters"], [SHARK])
    rewrite_stone(board["items"])
    board["updated"] = NOW
    upsert(cat["items"], [to_cat_i(JAR)])
    upsert(cat["monsters"], [to_cat_m(SHARK)])
    rewrite_stone(cat["items"])
    if "jar_o_grease" not in run["items"]:
        run["items"].append("jar_o_grease")
    if "shark" not in run["monsters"]:
        run["monsters"].append("shark")
    rec.setdefault("cards", {})
    rec["cards"]["item:jar_o_grease"] = TS
    rec["cards"]["monster:shark"] = TS
    rec["cards"]["item:mute_stone"] = TS
    rec["updated"] = f"{NOW}T02:10:00"
    cards = locks.setdefault("cards", {})
    cards["item:jar_o_grease"] = {"fields": LOCK, "locked_at": NOW, "name": "Jar O' Grease"}
    cards["monster:shark"] = {"fields": LOCK, "locked_at": NOW, "name": "Shark"}
    locks["updated"] = NOW
    add_keyword_rows(copy)

    def write(p: Path, data: dict) -> None:
        p.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")

    write(ROOT / "data" / "content-board.json", board)
    write(ROOT / "data" / "catalog.json", cat)
    write(ROOT / "data" / "runtime.json", run)
    write(ROOT / "data" / "recent-edits.json", rec)
    write(ROOT / "data" / "author-locks.json", locks)
    write(ROOT / "data" / "player-copy.json", copy)
    print("ok jar_o_grease shark mute_stone swap")


if __name__ == "__main__":
    main()
