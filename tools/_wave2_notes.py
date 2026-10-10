# Patch board + catalog from Roster Paper Fight answers.
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

PATCH = {
    "iron_chain": {
        "ability": "Deal Attack equal to Block you hold. Keep this item.",
        "explainer": "(Attack = Block. Keep.)",
        "flow": "Click during a fight. Deal Attack equal to Block you hold. You keep that Block. This item Keeps. Unplayable at 0 Block. Counts as an item use. Goblin cannot take Attack damage.",
        "notes": "Hornet and Queen still Attack after. You still hold the Block for those swings.",
        "ops": {"kind": "atk_spend_blk"},
        "name": None,
    },
    "counting_beads": {
        "flow": "Click during a fight. Deal Attack equal to the dungeon cycle number (1, then 2, then 3, then 4, then 1). Every item use this dungeon advances that number, including this click. The cycle carries across fights and resets on the next dungeon. Two Beads share one number. Used up. Counts as an item use. Goblin cannot take Attack damage.",
        "notes": "Cube feed is not an item use, so the cycle does not advance. Anvil takes 1 from this Attack.",
        "ops": {"kind": "atk_empty"},
    },
    "last_match": {
        "ability": "If you have zero items that deal Attack, Defeat them.",
        "explainer": "(No Attack items: Defeat)",
        "flow": "Click during a fight. If you hold no items that deal Attack, Defeat them. This card is not an Attack item. Unplayable if any other card in hand deals Attack. Used up when it works. Counts as an item use. Gargoyle cannot be Defeated.",
        "notes": "Holding only this works. Echo copying an Attack item counts as an Attack item. Shield alone is enough.",
        "ops": {"kind": "defeat_only_item"},
    },
    "measuring_tape": {
        "name": "Scythe",
        "ability": "Deal Attack equal to double your HP. If they survive, Heal 2 and Keep this item.",
        "explainer": "(Attack = 2× HP. Survive: Heal 2, Keep.)",
        "flow": "Click during a fight. Deal Attack equal to twice your current HP. If they still have HP after that, including Goblin, Heal 2 and Keep this item. If they die, this is used up and you do not Heal. Counts as an item use.",
        "notes": "Goblin takes 0 Attack and still has HP, so Heal 2 and Keep. Anvil takes 1 from this Attack. Ogre HP is your HP, so this can still cut them.",
        "ops": {"kind": "atk_hp_gap"},
    },
    "mute_stone": {
        "name": "Chaos Stone",
        "ability": "Choose other items in your hand. Each becomes a random item of that item's tier.",
        "explainer": "(Reroll 1 or 2 other items.)",
        "flow": "Click during a fight, then click other items in your hand. If you hold only one other item, reroll that one. If you hold two or more, pick two. Each becomes a random item of that item's tier, with the same motion as Adventure Mode starter upgrades. This card cannot target itself. Unplayable if this is the only item in your hand. Used up. Counts as an item use.",
        "notes": "Does not deal Attack. Gargoyle petrify does not pick this. Cube feed is not this.",
        "ops": {"kind": "chaos_reroll"},
    },
    "basilisk": {
        "ability": "I discard every item you use immediately while you face me.",
        "explainer": "Items discard on use",
        "flow": "While you fight me, Keep does not work. Every item you use is discarded immediately. Knife nick, Lantern, and Breastplate leave your hand. Quiet Bell strips this.",
        "notes": "Keep after the fight is already over does not apply — the toss happens when you click.",
    },
    "hollow": {
        "name": "Twins",
        "ability": "Even Attack and even Block happen twice against me.",
        "explainer": "Even Attack or Block: twice",
        "flow": "While you fight me, an even Attack number hits me twice as two separate Attacks of that number. An even Block you gain while facing me is gained twice. Odd numbers happen once. Quiet Bell strips this.",
        "notes": "Anvil would take 1 from each of those two Attacks. Poison Flask is not an Attack.",
    },
    "beggar": {
        "ability": "My Attack copies the Attack number on your leftmost Attack item. If you have none, my Attack is 3.",
        "explainer": "Leftmost Attack, or 3",
        "flow": "My Attack is the live Attack number on your leftmost item that has an Attack number, after the usual hand sort, skipping cards with no Attack number. It updates on Spin and when you use an item. If you have no such item, my Attack is 3. Quiet Bell: printed Attack.",
        "notes": "Spent cards are skipped. Petrified cards have no Attack number for this.",
        "atk_base": 3,
        "atk_formula": "leftmost Attack item, else 3",
    },
    "wick": {
        "ability": "I gain 1 Attack and lose 1 HP whenever you use an item.",
        "explainer": "+1 Attack −1 HP per item use",
        "flow": "Whenever you use an item, every Wick on the wheel gains 1 Attack and loses 1 HP immediately, even if you are not facing them. A Wick at 0 HP is not removed until the fight you are in ends. If you are facing a Wick at 0 HP, they do not Attack; Done removes them as Slain. Cube feed is not an item use. Quiet Bell strips this.",
        "notes": "Kobold adds extra swings. I add to the Attack number. Both can stack if they ever sat together; they will not in one fight.",
        "atk_formula": "printed Attack, plus item uses on the wheel",
    },
    "anvil": {
        "ability": "I cannot lose more than 1 HP from one source.",
        "explainer": "Max 1 HP per source",
        "flow": "I cannot lose more than 1 HP from one source. Attack, Poison Flask, and other HP loss each chip 1. Defeat still works. Two separate Attacks chip 1 twice. Quiet Bell strips this, so full Attack lands.",
        "notes": "Needleback poke is not an Item hitting me. Poison Flask is not an Attack. Extra Attacks each chip 1.",
    },
}

SKIP_ABILITY = {"counting_beads"}
SKIP_EXPLAINER = {"counting_beads"}
SKIP_NAME = {"last_match"}


def patch_board_card(c: dict) -> None:
    cid = str(c.get("id", ""))
    p = PATCH.get(cid)
    if not p:
        return
    if "name" in p and p["name"] and cid not in SKIP_NAME:
        c["name"] = p["name"]
    if "ability" in p and cid not in SKIP_ABILITY:
        c["ability"] = p["ability"]
    if "explainer" in p and cid not in SKIP_EXPLAINER:
        c["explainer"] = p["explainer"]
    if "flow" in p:
        c["flow"] = p["flow"]
    if "notes" in p:
        c["notes"] = p["notes"]
    if "ops" in p:
        c["ops"] = p["ops"]
    if "atk_base" in p:
        c["atk_base"] = p["atk_base"]
    if "atk_formula" in p:
        c["atk_formula"] = p["atk_formula"]


def patch_catalog_card(c: dict) -> None:
    cid = str(c.get("id", ""))
    p = PATCH.get(cid)
    if not p:
        return
    if "name" in p and p["name"] and cid not in SKIP_NAME:
        c["name"] = p["name"]
    if "ability" in p and cid not in SKIP_ABILITY:
        c["ability"] = p["ability"]
    if "explainer" in p and cid not in SKIP_EXPLAINER:
        c["explainer"] = p["explainer"]
    if "flow" in p:
        c["defined"] = p["flow"]
    if "notes" in p:
        c["exceptions"] = p["notes"]
    if "ops" in p:
        c["ops"] = p["ops"]
    if "atk_base" in p:
        atk = c.get("atk")
        if not isinstance(atk, dict):
            atk = {}
        atk["base"] = p["atk_base"]
        c["atk"] = atk
    if "atk_formula" in p:
        atk = c.get("atk")
        if not isinstance(atk, dict):
            atk = {}
        atk["formula"] = p["atk_formula"]
        c["atk"] = atk


def main() -> None:
    board_path = ROOT / "data" / "content-board.json"
    cat_path = ROOT / "data" / "catalog.json"
    board = json.loads(board_path.read_text(encoding="utf-8"))
    cat = json.loads(cat_path.read_text(encoding="utf-8"))
    n = 0
    for key in ("items", "monsters"):
        for c in board.get(key, []):
            if str(c.get("id", "")) in PATCH:
                patch_board_card(c)
                n += 1
        for c in cat.get(key, []):
            if str(c.get("id", "")) in PATCH:
                patch_catalog_card(c)
    board["updated"] = "2026-10-08"
    board_path.write_text(json.dumps(board, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    cat_path.write_text(json.dumps(cat, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    print("patched", n, "board cards")


if __name__ == "__main__":
    main()
