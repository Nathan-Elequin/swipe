#!/usr/bin/env python3
"""Apply SP-21/22/23/25/26/29 card text, numbers, and rulings. Idempotent."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "data" / "catalog.json"
BOARD = ROOT / "data" / "content-board.json"

DECAY_DEF = "Decayed Items are linked. When you use one, Keep it and discard the other."

PHOENIX_ABILITY = "If I am Defeated before I Attack, add a Phoenix Egg to the Dungeon Deck."
BERSERKER_ABILITY = "On Spin, 50%: gain +4 Attack. Otherwise: lose 3 Attack."
FAIRY_ABILITY = "If I am Defeated without losing HP, gain a Fairy in a Bottle."
ZOMBIE_ABILITY = "When you Spin me, I Decay two of your Items."
WRAITH_ABILITY = "When I am Defeated, set your HP to my most recent HP."
ALE_ABILITY = "Heal yourself and the Enemy for 3 HP. Then draw an Item."
BOTTLE_ABILITY = "Heal 2."

PHOENIX_DEFINED = (
    "SP-21 (2026-10-25). If Defeated before I Attack (has_attacked is still false: "
    "Attack damage or a defeat item, and also a skip that never lets me Attack), "
    "add a Phoenix Egg to the top of the Dungeon Deck. Block-then-I-Attack does not lay an egg. "
    "The egg goes on top of the Dungeon Deck. Challenge and Adventure seat it with normal hole fill and loot. "
    "The mill does not draw that deck, so the egg is installed into the vacated seat. "
    "Phoenix Egg still hatches into a Phoenix. Quiet Bell turns this off."
)
BERSERKER_DEFINED = (
    "SP-22 (2026-10-25). Every Spin, each living unsilenced Berserker rolls. "
    "50%: that copy's Attack gains +4. Otherwise it loses 3 Attack. "
    "The change stacks. Attack clamps at 0 (further losses do not go negative; the next gain starts from 0). "
    "Commander still adds after this. Separate + and − animations."
)
FAIRY_DEFINED = (
    "SP-23 (2026-10-25). 1 HP / 4 Attack. If I am Defeated while I still have HP "
    "(Block, a defeat item, or a skip — not an Attack that drops me to 0), "
    "you gain a Fairy in a Bottle. The bottle is a normal use item: Heal 2. "
    "It is a token (not drafted). Quiet Bell turns this off."
)
ZOMBIE_DEFINED = (
    "SP-25 (2026-10-25). When you Spin me, I Decay up to two random Items that do not already have Keep. "
    + DECAY_DEF
    + " The discarded Item counts as a discard (Recycler and the same discard path as Hired Hand). "
    "If only one eligible Item, Decay that one: using it Keeps it, and there is no partner. "
    "If a Decayed Item is not used this combat, discard it. Other Items work normally. Quiet Bell turns this off."
)
WRAITH_DEFINED = (
    "SP-26 (2026-10-25). Display name stays Wraith. Id stays wraith. 2 HP / 4 Attack, tier 2. "
    "When I am Defeated, set your HP to my HP just before the defeating event. "
    "One killing hit from 2 uses 2. Several hits use the HP before the last hit. "
    "A defeat item or blocking then leaving uses the HP I still have. "
    "Lower HP is losing HP (Bleed). Higher HP is a heal. Equal does nothing. Cap at 6. Quiet Bell turns this off."
)
ALE_DEFINED = (
    "SP-29 (2026-10-25). Click during a fight. Used up. Heal yourself 3 (cap 6) and Heal the Enemy 3 (cap at their max HP). "
    "Then draw one random Item from the current loot pool, the same draw Catapult and Grappling Hook use. "
    "No Poison."
)
BOTTLE_DEFINED = (
    "SP-23 token. Not drafted. Fairy creates it when Defeated without losing HP. "
    "Click during a fight. Heal 2 (cap 6). Used up."
)


def dump(path: Path, data) -> None:
    path.write_text(json.dumps(data, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")


def by_id(rows):
    return {row["id"]: row for row in rows}


def set_monster_stats(row, atk, hp, on_board: bool) -> None:
    if on_board:
        row["atk_base"] = float(atk)
        row["hp_base"] = float(hp)
        row["atk_formula"] = ""
        row["hp_formula"] = ""
    else:
        row["atk"] = {"base": float(atk)}
        row["hp"] = {"base": float(hp)}


def patch_shared(row, **fields) -> None:
    for key, value in fields.items():
        row[key] = value


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    board = json.loads(BOARD.read_text(encoding="utf-8"))
    cat_m = by_id(catalog["monsters"])
    cat_i = by_id(catalog["items"])
    board_m = by_id(board["monsters"])
    board_i = by_id(board["items"])

    phoenix = cat_m["phoenix"]
    patch_shared(
        phoenix,
        ability=PHOENIX_ABILITY,
        explainer="Defeated before I Attack: add a Phoenix Egg to the Dungeon Deck",
        defined=PHOENIX_DEFINED,
        log_hint="Before Attack: Phoenix Egg on top of the deck",
        notes="Token. Not drafted. Phoenix Egg creates it. SP-21: egg goes on the deck, not into this seat.",
        exceptions="Token. Not drafted. Phoenix Egg creates it. SP-21.",
    )
    board_phoenix = board_m["phoenix"]
    patch_shared(
        board_phoenix,
        ability=PHOENIX_ABILITY,
        explainer="Defeated before I Attack: add a Phoenix Egg to the Dungeon Deck",
        flow=PHOENIX_DEFINED,
        log_hint="Before Attack: Phoenix Egg on top of the deck",
        notes="Token. Not drafted. Phoenix Egg creates it. SP-21: egg goes on the deck, not into this seat.",
    )

    berserker = cat_m["berserker"]
    set_monster_stats(berserker, 5, 4, False)
    patch_shared(
        berserker,
        ability=BERSERKER_ABILITY,
        call_name="Hot and Cold",
        explainer="50% +4 Attack, otherwise lose 3 Attack",
        defined=BERSERKER_DEFINED,
        log_hint="Every Spin: 50% +4 Attack, otherwise −3",
        notes="SP-22. Every Spin. Stacks. Attack clamps at 0.",
        exceptions="",
    )
    board_z = board_m["berserker"]
    set_monster_stats(board_z, 5, 4, True)
    patch_shared(
        board_z,
        ability=BERSERKER_ABILITY,
        call_name="Hot and Cold",
        explainer="50% +4 Attack, otherwise lose 3 Attack",
        flow=BERSERKER_DEFINED,
        log_hint="Every Spin: 50% +4 Attack, otherwise −3",
        notes="SP-22. Every Spin. Stacks. Attack clamps at 0.",
    )

    fairy = cat_m["fairy"]
    set_monster_stats(fairy, 4, 1, False)
    patch_shared(
        fairy,
        ability=FAIRY_ABILITY,
        call_name="",
        explainer="Defeated without losing HP: gain a Fairy in a Bottle",
        defined=FAIRY_DEFINED,
        log_hint="Clean Defeat: gain a Fairy in a Bottle",
        notes="SP-23. No ability name was specified, so the old Fairy Dust call name is cleared.",
        exceptions="Bucket 3. Bottle art still needed.",
    )
    board_f = board_m["fairy"]
    set_monster_stats(board_f, 4, 1, True)
    patch_shared(
        board_f,
        ability=FAIRY_ABILITY,
        call_name="",
        explainer="Defeated without losing HP: gain a Fairy in a Bottle",
        flow=FAIRY_DEFINED,
        log_hint="Clean Defeat: gain a Fairy in a Bottle",
        notes="SP-23. No ability name was specified, so the old Fairy Dust call name is cleared.",
    )

    zombie = cat_m["zombie"]
    patch_shared(
        zombie,
        ability=ZOMBIE_ABILITY,
        call_name="Decay",
        explainer="Decay two of your Items",
        defined=ZOMBIE_DEFINED,
        reminder=DECAY_DEF,
        log_hint="Decay two Items",
        notes="SP-25. Keyword Decay. Unused Decayed Items are discarded.",
        exceptions="SP-25. Replaces the old no-Keep rule.",
    )
    board_zo = board_m["zombie"]
    patch_shared(
        board_zo,
        ability=ZOMBIE_ABILITY,
        call_name="Decay",
        explainer="Decay two of your Items",
        flow=ZOMBIE_DEFINED,
        reminder=DECAY_DEF,
        log_hint="Decay two Items",
        notes="SP-25. Keyword Decay. Unused Decayed Items are discarded.",
    )

    wraith = cat_m["wraith"]
    set_monster_stats(wraith, 4, 2, False)
    patch_shared(
        wraith,
        name="Wraith",
        ability=WRAITH_ABILITY,
        call_name="Lifelink",
        explainer="Defeated: set your HP to my most recent HP",
        defined=WRAITH_DEFINED,
        log_hint="Defeated: your HP becomes my last HP",
        notes="SP-26. Display name stays Wraith. Id stays wraith. No id migration.",
        exceptions="SP-26. Sprite stays the existing wraith picture.",
        status="live",
    )
    board_w = board_m["wraith"]
    set_monster_stats(board_w, 4, 2, True)
    patch_shared(
        board_w,
        name="Wraith",
        ability=WRAITH_ABILITY,
        call_name="Lifelink",
        explainer="Defeated: set your HP to my most recent HP",
        flow=WRAITH_DEFINED,
        log_hint="Defeated: your HP becomes my last HP",
        notes="SP-26. Display name stays Wraith. Id stays wraith. No id migration.",
        status="live",
    )

    ale = cat_i["ale_flagon"]
    patch_shared(
        ale,
        ability=ALE_ABILITY,
        explainer="Heal 3 (you and the Enemy), then draw an Item",
        defined=ALE_DEFINED,
        log_hint="Heal 3 each, then draw an Item",
        notes="SP-29. Shared heal. Draw is a random loot-pool Item. No Poison.",
        exceptions="SP-29. Replaces Heal 5 and Poison.",
        ops={"kind": "heal_both_draw", "heal": 3.0},
    )
    board_a = board_i["ale_flagon"]
    patch_shared(
        board_a,
        ability=ALE_ABILITY,
        explainer="Heal 3 (you and the Enemy), then draw an Item",
        flow=ALE_DEFINED,
        log_hint="Heal 3 each, then draw an Item",
        notes="SP-29. Shared heal. Draw is a random loot-pool Item. No Poison.",
        ops={"kind": "heal_both_draw", "heal": 3.0},
    )

    if "fairy_in_a_bottle" not in cat_i:
        catalog["items"].append(_bottle_catalog())
    else:
        _overwrite_bottle(cat_i["fairy_in_a_bottle"], False)
    if "fairy_in_a_bottle" not in board_i:
        board["items"].append(_bottle_board())
    else:
        _overwrite_bottle(board_i["fairy_in_a_bottle"], True)

    rulings = catalog.setdefault("rulings", [])
    want = _rulings()
    by_rule = {row.get("id"): row for row in rulings}
    for row in want:
        if row["id"] in by_rule:
            by_rule[row["id"]].update(row)
        else:
            rulings.append(row)

    dump(CATALOG, catalog)
    dump(BOARD, board)
    print("updated catalog and content board")


def _bottle_catalog() -> dict:
    row = {
        "ability": BOTTLE_ABILITY,
        "author_lock": False,
        "bucket": -1.0,
        "call_name": "",
        "card_color": "heal",
        "count": 0.0,
        "defined": BOTTLE_DEFINED,
        "exceptions": "Token. Not drafted. Fairy creates it. Needs art.",
        "explainer": "Heal 2",
        "flags": {"art": False, "dev": True, "hide": True},
        "id": "fairy_in_a_bottle",
        "log_hint": "Heal 2",
        "mode_pool": "all",
        "name": "Fairy in a Bottle",
        "notes": "Token. Not drafted. Fairy creates it. Needs art.",
        "ops": {"kind": "heal", "n": 2.0},
        "poc": False,
        "priority": 9.0,
        "rarity": "uncommon",
        "reminder": "",
        "review": "rough",
        "review_note": "",
        "status": "live",
        "tier": 0.0,
        "type": "I",
    }
    return row


def _bottle_board() -> dict:
    return {
        "ability": BOTTLE_ABILITY,
        "atk_base": None,
        "atk_formula": "",
        "author_lock": False,
        "bucket": -1.0,
        "call_name": "",
        "card_color": "heal",
        "contradiction_ids": [],
        "count": 0.0,
        "explainer": "Heal 2",
        "flow": BOTTLE_DEFINED,
        "hp_base": None,
        "hp_formula": "",
        "id": "fairy_in_a_bottle",
        "kind": "item",
        "log_hint": "Heal 2",
        "mode_pool": "all",
        "name": "Fairy in a Bottle",
        "notes": "Token. Not drafted. Fairy creates it. Needs art.",
        "ops": {"kind": "heal", "n": 2.0},
        "priority": 9.0,
        "rarity": "uncommon",
        "reminder": "",
        "review": "rough",
        "review_note": "",
        "status": "live",
        "tier": 0.0,
    }


def _overwrite_bottle(row: dict, on_board: bool) -> None:
    fresh = _bottle_board() if on_board else _bottle_catalog()
    row.clear()
    row.update(fresh)


def _rulings() -> list:
    return [
        {
            "chat": "2026-10-25",
            "id": "SP-21",
            "rule": (
                "Phoenix lays a Phoenix Egg onto the top of the Dungeon Deck when Defeated before it Attacks "
                "(including Net or Skip; not after it has Attacked, including Block). "
                "Challenge and Adventure draw that egg as the next hole fill and offer loot. "
                "The mill has no hole fill, so the egg is installed into the vacated seat. "
                "Phoenix Egg's hatch ability stays. "
                "Author-lock override: phoenix ability, explainer, defined, log_hint, notes."
            ),
        },
        {
            "chat": "2026-10-25",
            "id": "SP-22",
            "rule": (
                "Berserker is 4 HP / 5 Attack. Hot and Cold rolls on every Spin, not only when you land on that copy. "
                "+4 Attack or −3 Attack, stacking, clamped at 0. "
                "Author-lock override: berserker ability, call_name, explainer, defined, log_hint, notes, atk base."
            ),
        },
        {
            "chat": "2026-10-25",
            "id": "SP-23",
            "rule": (
                "Fairy is 1 HP / 4 Attack. Defeated without losing HP (still has HP) grants Fairy in a Bottle, a normal use item that Heals 2. "
                "No new call name was specified; Fairy Dust was cleared. "
                "Author-lock override: fairy ability, call_name, explainer, defined, log_hint, notes, atk base."
            ),
        },
        {
            "chat": "2026-10-25",
            "id": "SP-25",
            "rule": (
                "Zombie Decay links up to two Items that do not already have Keep. "
                "Using one Keeps it and discards the other immediately. "
                "Unused Decayed Items are discarded at the end of the combat. "
                "Fewer than two eligible Items: Decay what is there. Keyword name is Decay. "
                "Author-lock override: zombie ability, explainer, defined, reminder, log_hint, notes."
            ),
        },
        {
            "chat": "2026-10-25",
            "id": "SP-26",
            "rule": (
                "Wraith keeps its display name and the id wraith. 2 HP / 4 Attack, tier 2. "
                "Lifelink sets your HP to Wraith's HP just before the defeating event (before the last hit if several hits kill it). "
                "Lower is Bleed, higher is a heal, equal does nothing, cap 6. "
                "Author-lock override: wraith ability, call_name, explainer, defined, log_hint, notes, atk base, hp base. "
                "Display name stays Wraith."
            ),
        },
        {
            "chat": "2026-10-25",
            "id": "SP-29",
            "rule": (
                "Ale Flagon heals you and the Enemy for 3, then draws one random Item from the current loot pool. No Poison. "
                "Author-lock override: ale_flagon ability, explainer, defined, log_hint, notes, ops."
            ),
        },
    ]


if __name__ == "__main__":
    main()
