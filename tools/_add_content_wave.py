"""Insert the 2026-10-17 content drop into board, catalog, runtime, recent-edits."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
LOCK = [
    "name", "ability", "explainer", "flow", "notes", "ops", "rarity", "tier",
    "count", "priority", "atk_base", "hp_base", "atk_formula", "hp_formula",
    "call_name", "reminder", "card_color", "log_hint",
]
NOW = "2026-10-17"
TS = 1792320000.0


def item_board(d: dict) -> dict:
    base = {
        "atk_base": None, "atk_formula": "", "author_lock": True, "call_name": "",
        "contradiction_ids": [], "count": 1, "flags": {"art": True, "dev": True, "hide": False},
        "hp_base": None, "hp_formula": "", "kind": "item", "locked_at": NOW,
        "locked_fields": LOCK, "mode_pool": "all", "notes": "", "ops": {},
        "priority": 3, "rarity": "uncommon", "reminder": "", "review": "rough",
        "review_note": "", "status": "live",
    }
    base.update(d)
    return base


def mon_board(d: dict) -> dict:
    base = {
        "atk_formula": "", "author_lock": True, "card_color": "",
        "contradiction_ids": [], "count": 1, "flags": {"art": True, "dev": True, "hide": False},
        "hp_formula": "", "kind": "monster", "locked_at": NOW, "locked_fields": LOCK,
        "mode_pool": "all", "notes": "", "ops": {}, "priority": 3, "rarity": "uncommon",
        "reminder": "", "review": "rough", "review_note": "", "status": "live",
    }
    base.update(d)
    return base


def item_cat(d: dict) -> dict:
    row = {
        "author_lock": True, "call_name": "", "count": 1, "exceptions": "",
        "flags": {"art": True, "dev": True, "hide": False}, "locked_at": NOW,
        "locked_fields": LOCK, "mode_pool": "all", "notes": "", "ops": {},
        "poc": False, "priority": 3, "rarity": "uncommon", "reminder": "",
        "review": "rough", "review_note": "", "status": "live", "type": "I",
    }
    row.update(d)
    return row


def mon_cat(d: dict) -> dict:
    row = {
        "author_lock": True, "card_color": "", "count": 1, "exceptions": "",
        "flags": {"art": True, "dev": True, "hide": False}, "locked_at": NOW,
        "locked_fields": LOCK, "mode_pool": "all", "notes": "", "ops": {},
        "poc": False, "priority": 3, "rarity": "uncommon", "reminder": "",
        "review": "rough", "review_note": "", "status": "live", "type": "M",
    }
    row.update(d)
    return row


ITEMS_BOARD = [
    item_board({
        "id": "shuriken", "name": "Shuriken", "bucket": 1, "tier": 1, "card_color": "atk",
        "ability": "2 Attack. If the Enemy lives, you Flee and Keep this.",
        "explainer": "(ATK 2) Flee and Keep if they live",
        "log_hint": "2 Attack, Flee and Keep if they live",
        "ops": {"kind": "atk_flee_keep", "n": 2},
        "flow": "Click during a fight. Deal 2 Attack. Needleback and Harpy still apply. If they still have HP, you Flee (Spin at random, can be the same monster) and Keep this. If they hit 0, this is used up and you do not Flee. Goblin ignores Attack so they live. Fight only.",
        "notes": "Bucket 1. Flee skips their Attack (Hornet never swings).",
    }),
    item_board({
        "id": "miasma", "name": "Miasma", "bucket": 4, "tier": 3, "card_color": "utility",
        "ability": "Apply Poison to all Monsters equal to the lowest HP on any Monster",
        "explainer": "Poison all for the lowest HP",
        "log_hint": "Poison everyone for the lowest HP",
        "ops": {"kind": "miasma"},
        "flow": "Click during a fight. Read current HP of every living monster, take the lowest, add that much Poison to every living monster. Plague Doctor neighbors stay at 2. The facing enemy ticks immediately (lose that HP, mark clears). If that slays them, combat ends. Other marks tick on a later Spin, then clear. Fight only. Used up.",
        "notes": "Bucket 4. Poison sources add. Flask is +5 on a neighbor.",
    }),
    item_board({
        "id": "bag_of_marbles", "name": "Bag of Marbles", "bucket": 3, "tier": 3,
        "card_color": "utility",
        "ability": "Fill your inventory with Marbles",
        "explainer": "Fill empty seats to 10 with Marbles",
        "log_hint": "Fill to 10 Marbles",
        "ops": {"kind": "bag_marbles"},
        "flow": "Click during a fight. Used up. Then fill empty seats with Marble tokens until the hand has 10 cards, even in the 50-seat dungeon. Facing Basilisk: this is spent and you Gain none. Fight only.",
        "notes": "Bucket 3. Marble is a Token, not drafted.",
    }),
    item_board({
        "id": "marble", "name": "Marble", "bucket": -1, "tier": 0, "card_color": "yellow",
        "count": 0, "priority": 9,
        "flags": {"art": True, "dev": True, "hide": True},
        "ability": "Gain 0 Atk or 0 Block randomly. On Spin, increase these numbers by 1",
        "explainer": "(N, Attack or Block)",
        "log_hint": "Random Attack or Block, grows on Spin",
        "ops": {"kind": "marble"},
        "flow": "Token. Not an Attack item until it declares Attack. Click during a fight: a callout names Attack or Block at random, then that number fires. 0 can be clicked and is used up. Each Marble has its own number starting at 0. Every Spin each Marble in hand +1. New dungeon resets to 0. Used up on click.",
        "notes": "Created by Bag of Marbles. Merchant treats Tier 0 like Egg.",
    }),
    item_board({
        "id": "hex", "name": "Hex", "bucket": 6, "tier": 2, "card_color": "defeat",
        "ability": "Unplayable. Defeats the Monster 6 Spins from now.",
        "explainer": "Defeat in 6 Spins",
        "log_hint": "Countdown Defeat",
        "ops": {"kind": "hex"},
        "flow": "Unplayable. Starts at 6. Every Spin (Smoke, Flee, auto-spin, landing) the number drops by 1. At 1 it flashes red. On the Spin that hits 0, Defeat the landed enemy with no HP chip (like The Boot). Gargoyle is Defeated. Commander can still Flee. Two Hexes at 0 both spend, one Defeat. Hex fires before poison on that landing. New dungeon resets to 6. Used up when it fires.",
        "notes": "Bucket 6. Skull + number on the card.",
    }),
]

MONS_BOARD = [
    mon_board({
        "id": "martyr", "name": "Martyr", "bucket": 6, "tier": 1,
        "atk_base": 0, "hp_base": 7, "call_name": "Noble Death",
        "ability": "When I Attack, I die. My Neighbors each gain HP equal to my current HP",
        "explainer": "On Attack: I die. Neighbors gain my HP",
        "log_hint": "Dies on Attack, neighbors gain that HP",
        "reminder": "When I Attack, I die. Neighbors gain my HP.",
        "flow": "0 Attack still Attacks. Snapshot HP, then I die as a Defeat. Each living neighbor gains that much current HP and max HP (like Vampire). Empty seats skipped. Killing me with items before Done skips this. Quiet Bell turns this off.",
        "notes": "Bucket 6. Wick, Berserker, Victory Flask, Mimic count this Defeat. Mimic does not gift because I already Attacked.",
    }),
    mon_board({
        "id": "prism", "name": "Prism", "bucket": 4, "tier": 3,
        "atk_base": 8, "hp_base": 6, "call_name": "Refract Damage",
        "ability": "When I would take Attack damage, both of my Neighbors take it instead.",
        "explainer": "Neighbors take my Attack damage",
        "log_hint": "Dumps Attack onto both neighbors",
        "reminder": "Attack at me hits both neighbors instead.",
        "flow": "When Attack would hit me, I take 0. Living neighbors take that Attack as if you attacked them, left (clockwise) first, then right. One living neighbor takes the full hit once. Zero living neighbors: I take it. A loop (two Prisms) fizzles that share. Needleback, Twins, Bodyguard, Goblin, Anvil apply on the one who actually takes it. Poison, Boot, Sledgehammer still hit me. Quiet Bell turns this off.",
        "notes": "Bucket 4. Double Axe and bows still refract the share aimed at me.",
    }),
    mon_board({
        "id": "plague_doctor", "name": "Plague Doctor", "bucket": 5, "tier": 1,
        "atk_base": 2, "hp_base": 3, "call_name": "Always Plague",
        "ability": "My Neighbors Always have 2 Poison. When you Spin, I heal my Neighbors for 2.",
        "explainer": "Neighbors Always 2 Poison. Spin: they Heal 2",
        "log_hint": "Neighbors Always 2 Poison, heal 2 on Spin",
        "reminder": "Neighbors Always have 2 Poison. On Spin I heal them 2.",
        "flow": "While I live unsilenced, each living neighbor's Poison is exactly 2. Extra Poison cannot raise them. Every Spin: facing poison ticks first (then clears; I write 2 again if they lived). Then I heal each living neighbor +2 current HP and +2 max HP. A 2 HP neighbor dies to poison before the heal. When I die, Always ends and the 2 goes away. Quiet Bell turns this off.",
        "notes": "Bucket 5. Always is the live keyword.",
    }),
]


def to_cat_item(b: dict) -> dict:
    return item_cat({
        "id": b["id"], "name": b["name"], "ability": b["ability"], "explainer": b["explainer"],
        "defined": b["flow"], "exceptions": b.get("notes", ""), "log_hint": b["log_hint"],
        "bucket": b["bucket"], "tier": b["tier"], "count": b.get("count", 1),
        "priority": b.get("priority", 3), "card_color": b.get("card_color", ""),
        "ops": b.get("ops", {}), "flags": b.get("flags", {"art": True, "dev": True, "hide": False}),
        "notes": b.get("notes", ""), "reminder": b.get("reminder", ""),
    })


def to_cat_mon(b: dict) -> dict:
    return mon_cat({
        "id": b["id"], "name": b["name"], "ability": b["ability"], "explainer": b["explainer"],
        "defined": b["flow"], "exceptions": b.get("notes", ""), "log_hint": b["log_hint"],
        "bucket": b["bucket"], "tier": b["tier"], "count": b.get("count", 1),
        "priority": b.get("priority", 3), "call_name": b.get("call_name", ""),
        "reminder": b.get("reminder", ""),
        "atk": {"base": int(b.get("atk_base") or 0)},
        "hp": {"base": int(b.get("hp_base") or 0)},
        "notes": b.get("notes", ""),
    })


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


def main() -> None:
    board_p = ROOT / "data" / "content-board.json"
    cat_p = ROOT / "data" / "catalog.json"
    run_p = ROOT / "data" / "runtime.json"
    rec_p = ROOT / "data" / "recent-edits.json"
    board = load(board_p)
    cat = load(cat_p)
    run = load(run_p)
    rec = load(rec_p)
    upsert(board["items"], ITEMS_BOARD)
    upsert(board["monsters"], MONS_BOARD)
    board["updated"] = NOW
    upsert(cat["items"], [to_cat_item(b) for b in ITEMS_BOARD])
    upsert(cat["monsters"], [to_cat_mon(b) for b in MONS_BOARD])
    for i in ["shuriken", "miasma", "bag_of_marbles", "marble", "hex"]:
        if i not in run["items"]:
            run["items"].append(i)
    for m in ["martyr", "prism", "plague_doctor"]:
        if m not in run["monsters"]:
            run["monsters"].append(m)
    rec.setdefault("cards", {})
    for b in ITEMS_BOARD:
        rec["cards"][f"item:{b['id']}"] = TS
    for b in MONS_BOARD:
        rec["cards"][f"monster:{b['id']}"] = TS
    rec["updated"] = f"{NOW}T23:59:00"
    locks_p = ROOT / "data" / "author-locks.json"
    locks = load(locks_p)
    cards = locks.setdefault("cards", {})
    for b in ITEMS_BOARD:
        cards[f"item:{b['id']}"] = {"fields": LOCK, "locked_at": NOW, "name": b["name"]}
    for b in MONS_BOARD:
        cards[f"monster:{b['id']}"] = {"fields": LOCK, "locked_at": NOW, "name": b["name"]}
    locks["updated"] = NOW
    dump(board_p, board)
    dump(cat_p, cat)
    dump(run_p, run)
    dump(rec_p, rec)
    dump(locks_p, locks)
    print("board items", len(board["items"]), "monsters", len(board["monsters"]))
    print("catalog items", len(cat["items"]), "monsters", len(cat["monsters"]))


if __name__ == "__main__":
    main()
