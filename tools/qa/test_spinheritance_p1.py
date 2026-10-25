#!/usr/bin/env python3
"""Lock the 2026-10-25 Spinheritance P1 card text and the pure readings."""

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load(name: str) -> dict:
    return json.loads((ROOT / "data" / name).read_text(encoding="utf-8"))


def by_id(rows: list) -> dict:
    return {row["id"]: row for row in rows}


def expect(ok: bool, label: str, fails: list) -> None:
    if not ok:
        fails.append(label)


def next_intrinsic_atk(current: int, hot: bool) -> int:
    return max(0, current + (4 if hot else -3))


def lifelink_hp(current_hp: int, hp_before_last_hit: int, died_from_damage: bool) -> int:
    if died_from_damage:
        return max(0, hp_before_last_hit)
    return max(0, current_hp)


def lifelink_change(player_hp: int, source_hp: int, player_max: int) -> dict:
    target = max(0, min(player_max, source_hp))
    if target == player_hp:
        return {"kind": "none", "n": 0, "hp": player_hp}
    if target > player_hp:
        return {"kind": "heal", "n": target - player_hp, "hp": target}
    return {"kind": "bleed", "n": player_hp - target, "hp": target}


def main() -> int:
    fails: list[str] = []
    catalog = load("catalog.json")
    board = load("content-board.json")
    runtime = load("runtime.json")
    monsters = by_id(catalog["monsters"])
    items = by_id(catalog["items"])
    board_m = by_id(board["monsters"])
    board_i = by_id(board["items"])
    runtime_ids = set(runtime.get("monsters", [])) | set(runtime.get("items", []))

    phoenix = monsters["phoenix"]
    expect(phoenix["ability"] == "If I am Defeated before I Attack, add a Phoenix Egg to the Dungeon Deck.", "phoenix ability", fails)
    expect(phoenix["author_lock"] is True, "phoenix lock", fails)
    expect("mill does not draw" in phoenix["defined"], "phoenix mill reading", fails)
    expect(board_m["phoenix"]["ability"] == phoenix["ability"], "phoenix board ability", fails)
    expect("mill does not draw" in board_m["phoenix"]["flow"], "phoenix board flow", fails)

    egg = monsters["phoenix_egg"]
    expect(egg["ability"] == "When I am Defeated, I Flee and hatch into a Phoenix.", "egg hatch", fails)
    expect(egg["call_name"] == "Hatch", "egg call", fails)

    berserker = monsters["berserker"]
    expect(berserker["ability"] == "When Spun, 50%: gain +4 Attack. Otherwise: lose 3 Attack.", "berserker ability", fails)
    expect(berserker["call_name"] == "Hot and Cold", "berserker call", fails)
    expect(berserker["atk"]["base"] == 5, "berserker atk", fails)
    expect(berserker["hp"]["base"] == 4, "berserker hp", fails)
    expect(berserker["author_lock"] is True, "berserker lock", fails)
    expect(board_m["berserker"]["atk_base"] == 5, "berserker board atk", fails)
    expect(board_m["berserker"]["call_name"] == "Hot and Cold", "berserker board call", fails)

    fairy = monsters["fairy"]
    expect(fairy["ability"] == "If I am Defeated without losing HP, gain a Fairy in a Bottle.", "fairy ability", fails)
    expect(fairy["call_name"] == "", "fairy call cleared", fails)
    expect(fairy["atk"]["base"] == 4, "fairy atk", fails)
    expect(fairy["hp"]["base"] == 1, "fairy hp", fails)
    expect(fairy["author_lock"] is True, "fairy lock", fails)

    bottle = items["fairy_in_a_bottle"]
    expect(bottle["ability"] == "Heal 2.", "bottle ability", fails)
    expect(bottle["name"] == "Fairy in a Bottle", "bottle name", fails)
    expect(bottle["ops"] == {"kind": "heal", "n": 2.0}, "bottle ops", fails)
    expect(bottle.get("author_lock", False) is False, "bottle unlocked", fails)
    expect(bottle["count"] == 0, "bottle not drafted", fails)
    expect(board_i["fairy_in_a_bottle"]["ability"] == "Heal 2.", "bottle board", fails)
    expect("fairy_in_a_bottle" not in runtime_ids, "bottle not in runtime", fails)

    zombie = monsters["zombie"]
    expect(zombie["ability"] == "When you Spin me, I Decay two of your Items.", "zombie ability", fails)
    expect(zombie["call_name"] == "Decay", "zombie call", fails)
    expect(
        zombie["reminder"] == "Decayed Items are linked. When you use one, Keep it and discard the other.",
        "zombie reminder",
        fails,
    )
    expect(zombie["author_lock"] is True, "zombie lock", fails)
    expect(catalog["keywords"]["decay"] == zombie["reminder"], "decay keyword", fails)

    raven = monsters["wraith"]
    expect(raven["name"] == "Raven", "raven name", fails)
    expect(raven["id"] == "wraith", "raven id", fails)
    expect(raven["ability"] == "When I am Defeated, set your HP to my most recent HP.", "raven ability", fails)
    expect(raven["call_name"] == "Lifelink", "raven call", fails)
    expect(raven["atk"]["base"] == 4, "raven atk", fails)
    expect(raven["hp"]["base"] == 2, "raven hp", fails)
    expect(raven["status"] == "live", "raven live", fails)
    expect(raven["author_lock"] is True, "raven lock", fails)
    expect(board_m["wraith"]["name"] == "Raven", "raven board name", fails)
    expect("wraith" in runtime.get("monsters", []), "wraith stays in runtime", fails)
    expect("phoenix" not in runtime.get("monsters", []), "phoenix token stays out", fails)

    ale = items["ale_flagon"]
    expect(ale["ability"] == "Heal yourself and the Enemy for 3 HP. Then draw an Item.", "ale ability", fails)
    expect(ale["ops"] == {"kind": "heal_both_draw", "heal": 3.0}, "ale ops", fails)
    expect("poison" not in ale["ops"], "ale no poison", fails)
    expect(ale["author_lock"] is True, "ale lock", fails)
    expect(board_i["ale_flagon"]["ops"]["kind"] == "heal_both_draw", "ale board ops", fails)

    rulings = {row["id"]: row for row in catalog["rulings"]}
    for sid in ("SP-21", "SP-22", "SP-23", "SP-25", "SP-26", "SP-29"):
        expect(sid in rulings and rulings[sid]["chat"] == "2026-10-25", sid, fails)
    expect("top of the Dungeon Deck" in rulings["SP-21"]["rule"], "SP-21 top", fails)
    expect("installed into the vacated seat" in rulings["SP-21"]["rule"], "SP-21 mill", fails)
    expect("every Spin" in rulings["SP-22"]["rule"], "SP-22 every spin", fails)
    expect("Heals 2" in rulings["SP-23"]["rule"], "SP-23 heal 2", fails)
    expect("Unused Decayed Items are discarded" in rulings["SP-25"]["rule"], "SP-25 unused", fails)
    expect("keeps the id wraith" in rulings["SP-26"]["rule"], "SP-26 id", fails)
    expect("loot pool" in rulings["SP-29"]["rule"], "SP-29 loot", fails)

    expect(next_intrinsic_atk(5, True) == 9, "hot 5", fails)
    expect(next_intrinsic_atk(5, False) == 2, "cold 5", fails)
    expect(next_intrinsic_atk(2, False) == 0, "cold 2", fails)
    expect(next_intrinsic_atk(0, True) == 4, "hot 0", fails)
    expect(lifelink_hp(0, 2, True) == 2, "one hit", fails)
    expect(lifelink_hp(0, 1, True) == 1, "last hit", fails)
    expect(lifelink_hp(2, 4, False) == 2, "boot hp", fails)
    expect(lifelink_change(6, 2, 6)["kind"] == "bleed", "bleed", fails)
    expect(lifelink_change(2, 2, 6)["kind"] == "none", "same", fails)
    expect(lifelink_change(1, 2, 6)["n"] == 1, "heal", fails)
    expect(lifelink_change(1, 9, 6)["hp"] == 6, "cap", fails)

    if fails:
        print("FAIL")
        for row in fails:
            print(" -", row)
        return 1
    print("SP_P1_DATA_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
