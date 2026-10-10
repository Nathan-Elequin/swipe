import json
from pathlib import Path

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
WAVE1 = [
    "lantern",
    "mirror_shard",
    "echo_bell",
    "quiet_bell",
    "net",
    "gelatinous_cube",
    "gargoyle",
    "harpy",
    "kobold_trapper",
    "clockwork_knight",
]

LOCKED = [
    "name",
    "ability",
    "explainer",
    "flow",
    "notes",
    "ops",
    "rarity",
    "tier",
    "count",
    "priority",
    "atk_base",
    "hp_base",
    "atk_formula",
    "hp_formula",
]


def item_board(card_id, name, ability, explainer, flow, notes, ops, tier, priority, count=1):
    return {
        "ability": ability,
        "atk_base": None,
        "atk_formula": "",
        "author_lock": False,
        "contradiction_ids": [],
        "count": count,
        "explainer": explainer,
        "flow": flow,
        "hp_base": None,
        "hp_formula": "",
        "id": card_id,
        "kind": "item",
        "locked_at": "",
        "locked_fields": [],
        "name": name,
        "notes": notes,
        "ops": ops,
        "priority": priority,
        "rarity": "uncommon",
        "review": "rough",
        "review_note": "",
        "status": "live",
        "tier": tier,
    }


def mon_board(card_id, name, ability, explainer, flow, notes, atk, hp, atk_formula, tier, priority, count=1):
    return {
        "ability": ability,
        "atk_base": atk,
        "atk_formula": atk_formula,
        "author_lock": False,
        "contradiction_ids": [],
        "count": count,
        "explainer": explainer,
        "flow": flow,
        "hp_base": hp,
        "hp_formula": "",
        "id": card_id,
        "kind": "monster",
        "locked_at": "",
        "locked_fields": [],
        "name": name,
        "notes": notes,
        "ops": {},
        "priority": priority,
        "rarity": "uncommon",
        "review": "rough",
        "review_note": "",
        "status": "live",
        "tier": tier,
    }


def item_cat(card_id, name, ability, explainer, defined, exceptions, ops, tier, priority, count=1):
    return {
        "ability": ability,
        "author_lock": False,
        "count": float(count),
        "defined": defined,
        "exceptions": exceptions,
        "explainer": explainer,
        "flags": {"art": True, "dev": True, "hide": False},
        "id": card_id,
        "locked_at": "",
        "locked_fields": [],
        "name": name,
        "ops": ops,
        "poc": False,
        "priority": float(priority),
        "rarity": "uncommon",
        "tier": tier,
        "type": "I",
        "review": "rough",
        "review_note": "",
        "status": "live",
    }


def mon_cat(card_id, name, ability, explainer, defined, exceptions, atk, hp, atk_formula, tier, priority, count=1):
    row = {
        "ability": ability,
        "atk": {"base": float(atk)},
        "author_lock": False,
        "count": float(count),
        "defined": defined,
        "exceptions": exceptions,
        "explainer": explainer,
        "flags": {"art": True, "dev": True, "hide": False},
        "hp": {"base": float(hp)},
        "id": card_id,
        "locked_at": "",
        "locked_fields": [],
        "name": name,
        "poc": False,
        "priority": float(priority),
        "rarity": "uncommon",
        "tier": float(tier),
        "type": "M",
        "review": "rough",
        "review_note": "",
        "status": "live",
    }
    if atk_formula:
        row["atk"]["formula"] = atk_formula
    return row


ITEMS = [
    item_board(
        "iron_chain",
        "Chain",
        "Deal Attack equal to your Block, then your Block becomes 0.",
        "(ATK = BLK, then BLK 0)",
        "Click during a fight. Deal Attack equal to Block you hold right now, then Block becomes 0. If Block is 0, Unplayable. Used up. Counts as an item use. Goblin cannot take Attack damage.",
        "Hornet and Queen still Attack after. You dumped Block, so later swings are unblocked.",
        {"kind": "atk_spend_blk"},
        2,
        3,
    ),
    item_board(
        "counting_beads",
        "Counting Beads",
        "Deal Attack equal to empty alcoves on the wheel.",
        "(8 − owners left)",
        "Click during a fight. Deal Attack equal to 8 minus how many owners are still on the wheel. If the wheel is full, Unplayable. Used up. Counts as an item use. Goblin cannot take Attack damage.",
        "Clockwork growing past 8 means 0 empty alcoves. Anvil takes 1 from this.",
        {"kind": "atk_empty"},
        1,
        2,
        2,
    ),
    item_board(
        "last_match",
        "Last Match",
        "If this is your only Item, Defeat the facing owner.",
        "(Only item: Defeat)",
        "Click during a fight. If this is the only Item still in your hand, Defeat them. If you hold anything else, Unplayable and the card stays. Used up when it works. Counts as an item use. Gargoyle cannot be Defeated.",
        "Spent cards already left your hand. Echo copying this still needs to be your only card.",
        {"kind": "defeat_only_item"},
        3,
        4,
    ),
    item_board(
        "measuring_tape",
        "Measuring Tape",
        "Deal Attack equal to the gap between your HP and theirs.",
        "(|your HP − their HP|)",
        "Click during a fight. Deal Attack equal to the absolute difference between your current HP and the facing owner's current HP. Used up. Counts as an item use. Goblin cannot take Attack damage.",
        "Ogre copies your HP, so the gap is 0. Anvil takes 1 from this.",
        {"kind": "atk_hp_gap"},
        2,
        3,
    ),
    item_board(
        "mute_stone",
        "Mute Stone",
        "This owner Attacks once this fight. Extra swings are gone.",
        "(One swing)",
        "Click during a fight. Hornet, Queen, and Kobold Attack once on Done this fight. Other uniques stay. If they were never going to Attack extra, the card still is used up. Counts as an item use.",
        "Does not stop Harpy interrupt. Quiet Bell still strips the whole unique. Mute is only extra Done swings.",
        {"kind": "mute_swings"},
        2,
        3,
    ),
]

MONS = [
    mon_board(
        "basilisk",
        "Basilisk",
        "I make Keep fail this fight.",
        "Keep discards",
        "While you fight me, Keep does not work. Knife nick, Lantern, and Breastplate are used up and leave your hand. Quiet Bell strips this.",
        "Keep after the fight is already over does not apply — the toss happens when you click.",
        3,
        5,
        "",
        2,
        4,
    ),
    mon_board(
        "hollow",
        "Hollow",
        "If you take my Attack holding 0 Block, I die after the swing.",
        "0 Block: I die",
        "On Done, I Attack as usual. If you had 0 Block when you clicked Done and you live, I am Slain (gold), not Leave-alive. If you held any Block, I Leave like anyone else. Smoke skip means I Leave and do not die this way.",
        "Hornet extras still all happen, then I die if you started at 0 Block.",
        4,
        3,
        "",
        1,
        3,
        2,
    ),
    mon_board(
        "beggar",
        "Beggar",
        "My Attack is 6 if your hand is empty, else 1.",
        "Empty hand: ATK 6",
        "My Attack is 1 while you hold any Item, and 6 the moment your hand is empty. It updates when you spend. Locked printed HP 4. Quiet Bell: printed Attack.",
        "Inverse Bandit. Last Match into me jumps me to 6 if it fails to Defeat.",
        1,
        4,
        "6 if hand empty else 1",
        1,
        3,
        2,
    ),
    mon_board(
        "wick",
        "Wick",
        "I gain 1 Attack each time you use an Item this fight.",
        "(1 + items used)",
        "Printed Attack 1. Each item use this fight raises my Attack by 1, including Echo. Cube feed is not an item use. Quiet Bell freezes printed Attack.",
        "Kobold adds extra swings. I add to the Attack number. Both can stack if they ever sat together; they will not in one fight.",
        1,
        6,
        "1 + items used this fight",
        2,
        4,
    ),
    mon_board(
        "anvil",
        "Anvil",
        "I cannot take more than 1 Attack from a single Item.",
        "Max 1 Attack per item",
        "Any Item that deals Attack to me deals 1 instead, even Knife 3, Beads, Tape, Chain, Axe, Bow. Defeat still works. Goblin-style 0 is still 0. Quiet Bell strips this, so full Attack lands.",
        "Needleback poke is not an Item hitting me. Double Axe hits me for 1, neighbors for their full 2.",
        3,
        8,
        "",
        3,
        5,
    ),
]


def bump_review(rows):
    for row in rows:
        if str(row.get("id", "")) in WAVE1 and str(row.get("review", "")) == "rough":
            row["review"] = "refined"


def main():
    board_p = ROOT / "data" / "content-board.json"
    cat_p = ROOT / "data" / "catalog.json"
    run_p = ROOT / "data" / "runtime.json"
    board = json.loads(board_p.read_text(encoding="utf-8"))
    cat = json.loads(cat_p.read_text(encoding="utf-8"))
    run = json.loads(run_p.read_text(encoding="utf-8"))

    bump_review(board.get("items", []))
    bump_review(board.get("monsters", []))
    bump_review(cat.get("items", []))
    bump_review(cat.get("monsters", []))

    have_i = {str(r.get("id")) for r in board.get("items", [])}
    have_m = {str(r.get("id")) for r in board.get("monsters", [])}
    for row in ITEMS:
        if row["id"] not in have_i:
            board["items"].append(row)
    for row in MONS:
        if row["id"] not in have_m:
            board["monsters"].append(row)

    have_ci = {str(r.get("id")) for r in cat.get("items", [])}
    have_cm = {str(r.get("id")) for r in cat.get("monsters", [])}
    for row in ITEMS:
        if row["id"] not in have_ci:
            cat["items"].append(
                item_cat(
                    row["id"],
                    row["name"],
                    row["ability"],
                    row["explainer"],
                    row["flow"],
                    row["notes"],
                    row["ops"],
                    row["tier"],
                    row["priority"],
                    row["count"],
                )
            )
    for row in MONS:
        if row["id"] not in have_cm:
            cat["monsters"].append(
                mon_cat(
                    row["id"],
                    row["name"],
                    row["ability"],
                    row["explainer"],
                    row["flow"],
                    row["notes"],
                    row["atk_base"],
                    row["hp_base"],
                    row["atk_formula"],
                    row["tier"],
                    row["priority"],
                    row["count"],
                )
            )

    for iid in [r["id"] for r in ITEMS]:
        if iid not in run.get("items", []):
            run["items"].append(iid)
    for mid in [r["id"] for r in MONS]:
        if mid not in run.get("monsters", []):
            run["monsters"].append(mid)

    board_p.write_text(json.dumps(board, indent="\t") + "\n", encoding="utf-8")
    cat_p.write_text(json.dumps(cat, indent="\t") + "\n", encoding="utf-8")
    run_p.write_text(json.dumps(run, indent="\t") + "\n", encoding="utf-8")
    print("wave2 ok", [r["id"] for r in ITEMS], [r["id"] for r in MONS])


if __name__ == "__main__":
    main()
