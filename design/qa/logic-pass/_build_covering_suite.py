"""Covering suite: every live item and monster, states from the card's own verbs."""
from __future__ import annotations

import json
from pathlib import Path

from _scope import by_id, card_ref, items as load_items, monsters as load_monsters

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "covering-suite.json"


def _use(item, auto=True):
    return {"op": "use", "item": item, "auto": auto}


def _done():
    return {"op": "done"}


def _undo():
    return {"op": "undo"}


def build():
    its = by_id(load_items())
    mons = by_id(load_monsters())
    golem = mons.get("golem") or {}
    wizard = mons.get("wizard") or {}
    g_hp = int(golem.get("hp") or 7)
    w_hp = int(wizard.get("hp") or 2)
    dummy = "golem" if "golem" in mons else next(iter(mons))
    low = "wizard" if "wizard" in mons else dummy

    out = []

    def add(tid, title, family, item_ids, mon_ids, face, clicks, expected_text, expected, **kw):
        bad = [i for i in item_ids if i not in its] + [m for m in mon_ids if m not in mons]
        if bad:
            return
        row = {
            "id": tid,
            "title": title,
            "family": family,
            "items": item_ids,
            "monsters": mon_ids,
            "face": face,
            "challenge": True,
            "clicks": clicks,
            "expected_text": expected_text,
            "expected": expected,
            "cards": [card_ref(its[i], "item") for i in item_ids] + [card_ref(mons[m], "monster") for m in mon_ids],
        }
        row.update(kw)
        out.append(row)

    seen_items = set()
    seen_mons = set()

    for it in its.values():
        iid = it["id"]
        name = it["name"]
        kind = it["kind"]
        n = it.get("n")
        n = int(n) if isinstance(n, int) else None
        ability = it["ability"]
        seen_items.add(iid)

        if it["unplayable"]:
            add(
                "%s-unplayable" % iid,
                "%s stays Unplayable" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [],
                "%s is Unplayable. Do not click it. It stays in hand." % name,
                {"in_hand": {iid: True}},
            )
            continue

        if kind in ("blk", "blk_keep", "blk_even_keep") and n:
            add(
                "%s-gain-block" % iid,
                "%s grants %s Block" % (name, n),
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid), _done()],
                "Click %s. Plate Block becomes %s." % (name, n),
                {"blk": n, "in_hand": {iid: bool(it["keep"] and kind == "blk_keep")}},
            )
            continue

        if kind == "blk_from_hp":
            add(
                "%s-full-hp-cannot" % iid,
                "%s at full HP cannot" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "You are at 6/6. Missing HP is 0. %s cannot. Plate Block stays 0." % name,
                {"outcome": "cannot", "blk": 0},
            )
            add(
                "%s-missing-hp" % iid,
                "%s at 3 HP grants 3 Block" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "Start at 3 HP (missing 3). Block equal to missing HP is 3.",
                {"blk": 3},
                hp_before=3,
            )
            continue

        if kind == "blk_min_hp":
            add(
                "%s-vs-low" % iid,
                "%s Block equals the lower HP" % name,
                "item",
                [iid],
                [low],
                low,
                [_use(iid)],
                "You 6, facing %s HP. Block equals the lower HP." % w_hp,
                {"blk": min(6, w_hp)},
            )
            continue

        if kind == "blk_from_highest_atk":
            add(
                "%s-no-atk" % iid,
                "%s with no Attack item grants 0" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "No Attack item in hand. Highest Attack Item is none. Block stays 0.",
                {"blk": 0},
            )
            if "throwing_knife" in its:
                add(
                    "%s-with-knife" % iid,
                    "%s copies an Attack item as Block" % name,
                    "item",
                    ["throwing_knife", iid],
                    [dummy],
                    dummy,
                    [_use(iid)],
                    "Hand has Throwing Knife. %s grants Block equal to that Attack item." % name,
                    {"blk_min": 1},
                )
            continue

        if kind == "blk_last":
            add(
                "%s-no-last" % iid,
                "%s with no last Block cannot copy" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "No Block gained yet. Plate Block stays 0.",
                {"blk": 0},
            )
            if "shield" in its:
                add(
                    "%s-after-shield" % iid,
                    "%s copies Shield's 4 Block" % name,
                    "item",
                    ["shield", iid],
                    [dummy],
                    dummy,
                    [_use("shield"), _use(iid)],
                    "Shield first (Block 4). %s copies the last Block gained." % name,
                    {"blk_min": 4},
                )
            continue

        if kind == "blk_neighbor":
            add(
                "%s-alone" % iid,
                "%s with no Neighbor grants 0 / cannot" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "Wheel is only one monster. No Neighbor. Block stays 0.",
                {"blk": 0},
            )
            add(
                "%s-with-neighbor" % iid,
                "%s with a Neighbor" % name,
                "item",
                [iid],
                [dummy, low],
                dummy,
                [_use(iid, True)],
                "A Neighbor is present. Block equals that Neighbor's Attack (or 0 if the side is empty).",
                {},
            )
            continue

        if kind in ("heal_keep", "heal_full", "heal_poison", "heal_kills", "heal_swap_keep", "heal_last_loss"):
            add(
                "%s-heal-at-3" % iid,
                "%s Heals from 3 HP" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "Start at 3 HP. Click %s. Your HP plate goes up (capped at 6)." % name,
                {"hp_min": 4},
                hp_before=3,
            )
            add(
                "%s-heal-at-full" % iid,
                "%s at full HP" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "Start at 6 HP. Heal cannot raise you past max. Plate stays 6 (or the card still spends).",
                {"hp": 6},
            )
            continue

        if kind in ("defeat_hp", "bag_hold"):
            add(
                "%s-yes-low" % iid,
                "%s works vs a lower-HP enemy" % name,
                "item",
                [iid],
                [low],
                low,
                [_use(iid)],
                "Facing HP %s, you have 6. %s should Defeat or Bag them." % (w_hp, name),
                {"outcome": "fired"},
            )
            add(
                "%s-no-fat" % iid,
                "%s does not work vs a fatter enemy" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "Facing HP %s, you have 6. %s should not remove them." % (g_hp, name),
                {"face_hp": g_hp},
            )
            continue

        if kind == "defeat_atk":
            add(
                "%s-yes-dragon" % iid,
                "%s Defeats 6+ Attack" % name,
                "item",
                [iid],
                ["dragon"] if "dragon" in mons else [dummy],
                "dragon" if "dragon" in mons else dummy,
                [_use(iid)],
                "%s Defeats an enemy with 6 or more Attack." % name,
                {"outcome": "fired"},
            )
            add(
                "%s-no-golem" % iid,
                "%s does not Defeat Golem (ATK 3)" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "Golem Attack is under 6. They stay.",
                {"face_hp": g_hp},
            )
            continue

        if kind == "atk_last":
            add(
                "%s-no-last" % iid,
                "%s with no last monster cannot" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid)],
                "First fight. No last monster. %s cannot. Facing HP stays %s." % (name, g_hp),
                {"outcome": "cannot", "face_hp": g_hp},
            )
            continue

        if kind == "atk_spend_blk":
            add(
                "%s-no-block" % iid,
                "%s with 0 Block cannot spend Block" % name,
                "item",
                [iid],
                [dummy],
                dummy,
                [_use(iid), _done()],
                "You hold 0 Block. Attack equal to Block is 0 / cannot. Keep means it stays.",
                {"in_hand": {iid: True}, "face_hp": g_hp},
            )
            if "shield" in its:
                add(
                    "%s-after-shield" % iid,
                    "%s spends Shield Block as Attack" % name,
                    "item",
                    ["shield", iid],
                    [dummy],
                    dummy,
                    [_use("shield"), _use(iid), _done()],
                    "Shield first (4 Block). %s deals 4 Attack. Keep stays in hand after Done." % name,
                    {"face_hp": g_hp - 4, "in_hand": {iid: True}},
                )
            continue

        if kind == "choose":
            add(
                "%s-auto" % iid,
                "%s auto-picks the first option" % name,
                "item",
                [iid],
                [low],
                low,
                [_use(iid, True)],
                "Click %s. The first option fires. Plates or the hand change." % name,
                {"outcome": "fired"},
            )
            if iid == "throwing_knife":
                add(
                    "throwing_knife-keep-done",
                    "Throwing Knife Keep stays after Done",
                    "item",
                    [iid],
                    [dummy],
                    dummy,
                    [_use(iid, False), {"op": "choose", "id": "nick", "atk": 1, "keep": True}, _done()],
                    "Nick for ATK 1 and Keep. After Done the Knife is still in the hand.",
                    {"in_hand": {iid: True}, "face_hp": g_hp - 1},
                )
            continue

        if kind in ("atk", "atk_alt_24", "atk_7_hp", "atk_7_items", "atk_hp_loss", "atk_flee_keep", "atk_cleave", "atk_neighbor", "atk_opposite", "atk_empty"):
            extra = {}
            mons_for = [dummy]
            face = dummy
            if it["neighbor"] or kind in ("atk_neighbor", "atk_cleave", "atk_opposite"):
                mons_for = [dummy, low]
            if kind == "atk_7_hp":
                extra = {"hp_before": 3}
            clicks = [_use(iid, True)]
            exp = {"outcome": "fired"}
            if kind == "atk_flee_keep":
                clicks.append(_done())
                exp = {"in_hand": {iid: True}}
            add(
                "%s-atk" % iid,
                "%s Attack fires" % name,
                "item",
                [iid],
                mons_for,
                face,
                clicks,
                "Click %s. An Attack, Defeat, or Flee happens on the plates." % name,
                exp,
                **extra,
            )
            continue

        # Fallback: click it vs dummy and require the click to fire.
        add(
            "%s-fires" % iid,
            "%s fires vs a dummy" % name,
            "item",
            [iid],
            [dummy, low] if it["neighbor"] or it["target"] else [dummy],
            dummy,
            [_use(iid, True)],
            "Click %s. The plates or the hand change, or the log names %s / cannot." % (name, name),
            {"outcome": "fired"},
        )

    # Monster specials — one story each, item that actually triggers the verb.
    trigger_shield = "shield" if "shield" in its else next(iter(its))
    trigger_atk = "arrow_head" if "arrow_head" in its else ("throwing_knife" if "throwing_knife" in its else trigger_shield)

    for m in mons.values():
        mid = m["id"]
        mname = m["name"]
        seen_mons.add(mid)
        ability = m["ability"]
        items = [trigger_shield]
        clicks = []
        expected = {"outcome": "fired"}
        text = "Spin %s. Its Ability happens (plates or log)." % mname
        extra = {}

        if m.get("flee") or mid in ("basilisk", "mouse"):
            expected = {"outcome": "fled"}
            text = "Spin %s. It Flees. No fight to play an item. That is the monster working." % mname
        elif mid == "gelatinous_cube":
            clicks = [_use(trigger_shield)]
            expected = {"outcome": "cube_ate", "blk": 0}
            text = "Player clicked %s. Cube ate it. Block stays 0. That is Cube working." % its[trigger_shield]["name"]
        elif mid == "goblin":
            items = [trigger_atk]
            clicks = [_use(trigger_atk, True)]
            expected = {"invariants": ["goblin_no_atk_dmg"]}
            text = "Player clicked an Attack. Goblin HP does not drop (cannot take Attack damage)."
        elif mid == "dragon":
            clicks = [_use(trigger_shield), _done()]
            expected = {"outcome": "fired"}
            text = "Player clicked Shield (Block 4), then Done. Dragon ignores Block. You lose HP."
        elif mid == "eel":
            clicks = [_use(trigger_shield)]
            expected = {"blk": 4}
            text = "Player clicked Shield. Eel takes Attack equal to Block you gain."
        elif m.get("on_gain") or mid in ("eel", "zombie", "hired_hand"):
            clicks = [_use(trigger_shield)]
            text = "Player clicked Shield while facing %s. The on-gain special happens or does not, matching Ability." % mname
        elif m.get("on_hit") or mid in ("needleback", "anvil", "slime_boss"):
            items = [trigger_atk]
            clicks = [_use(trigger_atk, True)]
            text = "Player clicked Attack while facing %s. The on-hit special happens." % mname
        elif m.get("on_done") or mid in ("dragon", "harpy", "kobold_trapper", "martyr", "shambling_mound", "shark", "clockwork_knight"):
            clicks = [_use(trigger_shield), _done()]
            text = "Player clicked Shield, then Done, facing %s. The Done-time special happens." % mname
        elif m.get("neighbor") or mid in ("lich", "commander", "bodyguard", "prism", "wick"):
            items = [trigger_atk]
            clicks = [_use(trigger_atk, True)]
            extra_mons = [low, mid, dummy] if mid not in (low, dummy) else [low, mid]
            add(
                "monster-%s" % mid,
                "%s special" % mname,
                "monster",
                items,
                extra_mons,
                mid,
                clicks,
                "Player clicked Attack. %s: %s" % (mname, ability or "neighbor special"),
                expected,
            )
            continue
        elif m.get("on_you_hp"):
            items = [trigger_atk]
            clicks = [_use(trigger_atk, True)]
            extra = {"hp_before": 6}
            text = "Player clicked an item that costs HP, facing %s. The when-you-lose-HP special happens." % mname

        add(
            "monster-%s" % mid,
            "%s special" % mname,
            "monster",
            items,
            [mid],
            mid,
            clicks,
            text,
            expected,
            **extra,
        )

    # Keyword collisions that are not "one per card"
    if "shield" in its and "hollow" in mons:
        add(
            "keyword-even-block-hollow",
            "Even Block against Hollow/Twins",
            "keyword",
            ["shield"],
            ["hollow"],
            "hollow",
            [_use("shield")],
            "Player clicked Shield (Block 4, even). Against this monster, even Block happens twice. Plate Block is 8.",
            {"blk": 8},
        )
    if "quiet_bell" in its and "eel" in mons:
        add(
            "keyword-silence-eel",
            "Quiet Bell silences Eel",
            "keyword",
            ["quiet_bell"],
            ["eel"],
            "eel",
            [_use("quiet_bell")],
            "Player clicked Quiet Bell. Eel's unique Ability is gone.",
            {"outcome": "fired"},
        )
    if "shield" in its:
        add(
            "keyword-undo-block",
            "Undo after Shield",
            "surface",
            ["shield"],
            [dummy],
            dummy,
            [_use("shield"), _undo()],
            "Player clicked Shield, then Undo. Block returns to 0. Shield is back in hand.",
            {"blk": 0, "in_hand": {"shield": True}},
        )

    # Smoke / Adventure — table hang risk with timeout; still include one row.
    if "smoke_bomb" in its:
        add(
            "surface-smoke-bomb",
            "Smoke Bomb Spin again",
            "surface",
            ["smoke_bomb"],
            [dummy],
            dummy,
            [_use("smoke_bomb", True)],
            "Adventure-only: Smoke Bomb Spins again and grants a random item. If Challenge blocks it, that is cannot, not a Fail of Shield.",
            {"outcome": "fired"},
            adventure=True,
        )

    parked = [i for i in its if i not in seen_items]
    parked_m = [m for m in mons if m not in seen_mons]
    return out, parked, parked_m


def main():
    tests, parked_i, parked_m = build()
    payload = {
        "id": "covering-pass",
        "title": "Covering pass — every live card, states from its verbs",
        "parked_items": parked_i,
        "parked_monsters": parked_m,
        "tests": tests,
    }
    OUT.write_text(json.dumps(payload, indent="\t", ensure_ascii=False) + "\n", encoding="utf-8")
    fam = {}
    for t in tests:
        fam[t["family"]] = fam.get(t["family"], 0) + 1
    print("tests", len(tests), "families", fam, "parked_items", parked_i, "parked_monsters", parked_m)


if __name__ == "__main__":
    main()
