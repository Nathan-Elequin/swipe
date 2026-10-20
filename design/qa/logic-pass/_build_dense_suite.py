"""Dense mill suite: item×monster grid, cheap misses, order swaps, human-seed families."""
from __future__ import annotations

import json
from pathlib import Path

from _scope import ITEM_WHEN, by_id, card_ref, items as load_items, monsters as load_monsters

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "dense-suite.json"
SLIM_OUT = ROOT / "dense-plan.json"

FILLER = "shield"
FILLER_B = "throwing_knife"
STAND_INS = ["goblin", "dragon", "slime_boss", "hornet_swarm", "cowardly_king"]
ORDER_HUBS = {
    "sai",
    "echo_bell",
    "bag_of_holding",
    "recycler",
    "counting_beads",
    "grief_jar",
    "knucklers",
    "spiked_flail",
    "measuring_tape",
    "blood_chalice",
    "pacemaker",
    "left_bracer",
    "bracers",
}


def clicks_for_item(it: dict, mon: dict) -> list:
    cid = it["id"]
    mode = ITEM_WHEN.get(cid, "")
    if it["unplayable"] or mode == "unplayable":
        return []
    if mode == "choose" or it["kind"] == "choose":
        if cid == "throwing_knife":
            return [
                {"op": "use", "item": cid},
                {"op": "choose", "id": "throw", "atk": 3, "keep": False},
            ]
        return [{"op": "use", "item": cid, "auto": True}]
    if it["target"] or mode == "target":
        return [{"op": "use", "item": cid, "auto": True}]
    return [{"op": "use", "item": cid, "auto": True}]


def need_done(it: dict, mon: dict) -> bool:
    if mon.get("on_done") or mon.get("extra_swing") or mon.get("pierce"):
        return True
    if mon.get("on_you_hp") and it.get("atk"):
        return False
    return True


def wheel_for(it: dict, mon: dict, mons_by: dict) -> tuple[list, str]:
    face = mon["id"]
    wheel = [face]
    needs_nb = it.get("neighbor") or it.get("target") or mon.get("neighbor")
    if needs_nb:
        for extra in ("wizard", "golem"):
            if extra != face and extra in mons_by:
                wheel.append(extra)
        if len(wheel) < 2:
            for mid in mons_by:
                if mid != face:
                    wheel.append(mid)
                    break
    return wheel, face


def expected_for(it: dict, mon: dict, family: str) -> dict:
    inv = ["surfaces"]
    expect = {"invariants": inv}
    if not it:
        if family.startswith("miss-empty") and mon.get("grant"):
            inv.append("no_gain_empty_or_full")
        if mon.get("on_done") or mon.get("on_hit") or mon.get("on_spin") or mon.get("on_gain") or mon.get("on_you_hp"):
            expect["must_fire"] = True
        return expect
    if it.get("unplayable") or ITEM_WHEN.get(it.get("id"), "") == "unplayable":
        expect["spent"] = {it["id"]: False}
        inv.append("still_in_hand")
        return expect
    if mon.get("immune_atk") and it.get("atk") and not it.get("cheese"):
        inv.append("goblin_no_atk_dmg")
    if it.get("keep") and str(family).startswith("seed-keep"):
        inv.append("keep_until_done")
    if it.get("blk"):
        expect["blk_min"] = 1
    if it.get("heal"):
        expect["hp_min"] = 1
    if family.startswith("miss-empty") and mon.get("grant"):
        inv.append("no_gain_empty_or_full")
    if family.startswith("miss-full") and mon.get("grant"):
        inv.append("no_gain_empty_or_full")
    if mon.get("on_done") or mon.get("on_hit") or mon.get("on_spin") or mon.get("on_gain") or mon.get("on_you_hp"):
        expect["must_fire"] = True
    if mon.get("atk_base") is not None:
        expect["printed_atk"] = mon["atk_base"]
    if mon.get("hp"):
        expect["printed_hp"] = mon["hp"]
    expect["on_spin"] = bool(mon.get("on_spin") and (mon.get("ability") or ""))
    expect["on_done"] = bool(mon.get("on_done"))
    return expect


def expected_text(it: dict | None, mon: dict, setup: str) -> str:
    if it:
        item_line = f"Item: {it['name']} — {it['ability'] or '(no ability)'}"
    else:
        item_line = "Item: (empty hand)"
    bits = [
        item_line,
        f"Monster: {mon['name']} — {mon['ability'] or '(printed ATK/HP only)'}",
        setup,
        "Inspect, Shift, the plate, the hotbar, and the log must agree.",
    ]
    return " ".join(bits)


def base_test(tid, title, family, verbs, it_ids, mon_ids, face, clicks, it, mon, setup, extra=None):
    row = {
        "id": tid,
        "title": title,
        "family": family,
        "verbs": verbs,
        "items": it_ids,
        "monsters": mon_ids,
        "face": face,
        "challenge": True,
        "clicks": clicks,
        "expected": expected_for(it, mon, family),
        "expected_text": expected_text(it, mon, setup),
        "cards": [card_ref(x, "item") for x in ([it] if it and it.get("id") else [])]
        + [card_ref(m, "monster") for m in ([mon] if mon else [])],
    }
    if extra:
        row.update(extra)
    return row


def grid_tests(its, mons, mons_by):
    out = []
    for it in its:
        for mon in mons:
            wheel, face = wheel_for(it, mon, mons_by)
            clicks = clicks_for_item(it, mon)
            if need_done(it, mon):
                clicks = list(clicks) + [{"op": "done"}]
            hand = [it["id"]]
            extra = {}
            if ITEM_WHEN.get(it["id"]) == "discard" or it["id"] == "recycler":
                fillers = [FILLER if it["id"] != FILLER else FILLER_B] * 5
                hand = fillers + [it["id"]]
                extra["fill_hand"] = fillers
            if it.get("heal"):
                extra["hp_before"] = 3
            setup = (
                f"Challenge hand. Wheel {', '.join(wheel)}. Click {it['name']}"
                + (", then Done." if clicks and clicks[-1].get("op") == "done" else ".")
            )
            out.append(
                base_test(
                    f"grid-{it['id']}-{mon['id']}",
                    f"{it['name']} vs {mon['name']}",
                    "grid",
                    ["grid", "surfaces"],
                    hand,
                    wheel,
                    face,
                    clicks,
                    it,
                    mon,
                    setup,
                    extra,
                )
            )
    return out


def miss_tests(its, mons, its_by, mons_by):
    out = []
    wizard = mons_by.get("wizard") or mons[0]
    golem = mons_by.get("golem") or mons[0]

    for mon in mons:
        if mon.get("grant") or mon.get("on_gain"):
            clicks = [{"op": "done"}] if mon.get("on_done") else []
            out.append(
                base_test(
                    f"miss-empty-{mon['id']}",
                    f"{mon['name']} with an empty hand",
                    "miss-empty",
                    ["miss", "empty_hand"],
                    [],
                    [mon["id"]],
                    mon["id"],
                    clicks,
                    None,
                    mon,
                    "Hand is empty. The special must still fire or honestly do nothing — not crash, not silent Gain into a full bag.",
                    {"allow_empty_hand": True},
                )
            )
            fillers = [FILLER] * 10
            out.append(
                base_test(
                    f"miss-full-{mon['id']}",
                    f"{mon['name']} with a full Challenge hand (10)",
                    "miss-full",
                    ["miss", "full_hand"],
                    fillers,
                    [mon["id"]],
                    mon["id"],
                    clicks,
                    its_by.get(FILLER, its[0]),
                    mon,
                    "10 items already in hand (Challenge cap). Gain must refuse, not overwrite, and inspect must still match.",
                    {"fill_hand": fillers, "hand_cap": 10},
                )
            )

        if mon.get("neighbor"):
            out.append(
                base_test(
                    f"miss-noneighbor-{mon['id']}",
                    f"{mon['name']} last on the wheel (no neighbor)",
                    "miss-noneighbor",
                    ["miss", "no_neighbor"],
                    [FILLER],
                    [mon["id"]],
                    mon["id"],
                    [{"op": "use", "item": FILLER, "auto": True}, {"op": "done"}],
                    its_by.get(FILLER, its[0]),
                    mon,
                    "Only this monster on the wheel. Neighbor math must be 0 / cannot, not a crash and not a ghost neighbor.",
                )
            )
            out.append(
                base_test(
                    f"miss-last-{mon['id']}",
                    f"{mon['name']} as the last monster",
                    "miss-last",
                    ["miss", "last_monster"],
                    [FILLER],
                    [mon["id"]],
                    mon["id"],
                    [{"op": "done"}],
                    its_by.get(FILLER, its[0]),
                    mon,
                    "Last seat on the wheel. Last-monster clauses must fire.",
                )
            )

        if mon.get("on_done") or mon.get("extra_swing"):
            out.append(
                base_test(
                    f"miss-done-{mon['id']}",
                    f"{mon['name']} — you click Done",
                    "miss-done",
                    ["miss", "done"],
                    [FILLER],
                    [mon["id"], "wizard"] if mon.get("neighbor") else [mon["id"]],
                    mon["id"],
                    [{"op": "done"}],
                    its_by.get(FILLER, its[0]),
                    mon,
                    "The special fires on Done. This row must click Done. A pass with no Done click is a harness miss.",
                    {"hp_before": 6},
                )
            )

        if mon.get("on_you_hp"):
            knife = its_by.get("arrow_head") or its_by.get("throwing_knife") or its[0]
            clicks = clicks_for_item(knife, mon) + [{"op": "done"}]
            out.append(
                base_test(
                    f"miss-youhp-{mon['id']}",
                    f"{mon['name']} after you lose HP",
                    "miss-youhp",
                    ["miss", "you_lose_hp"],
                    [knife["id"]],
                    [mon["id"]],
                    mon["id"],
                    clicks,
                    knife,
                    mon,
                    "You must actually lose HP so the special can fire.",
                    {"hp_before": 6},
                )
            )

        if mon.get("on_hit"):
            knife = its_by.get("throwing_knife") or its[0]
            clicks = clicks_for_item(knife, mon)
            out.append(
                base_test(
                    f"miss-hit-{mon['id']}",
                    f"{mon['name']} after it takes a hit",
                    "miss-hit",
                    ["miss", "on_hit"],
                    [knife["id"]],
                    [mon["id"]],
                    mon["id"],
                    clicks,
                    knife,
                    mon,
                    "Deal Attack so the on-hit special can update (Slime ATK, Needleback poke, Goblin immune).",
                )
            )

    for it in its:
        if it.get("neighbor") or it.get("target"):
            out.append(
                base_test(
                    f"miss-item-noneighbor-{it['id']}",
                    f"{it['name']} with no other monster to pick",
                    "miss-item-noneighbor",
                    ["miss", "no_neighbor"],
                    [it["id"]],
                    [golem["id"]],
                    golem["id"],
                    clicks_for_item(it, golem),
                    it,
                    golem,
                    "Solo monster. A target/neighbor item must say it cannot, not pick a ghost seat.",
                )
            )
        if it.get("keep"):
            clicks = clicks_for_item(it, wizard)
            if it["id"] == "throwing_knife":
                clicks = [
                    {"op": "use", "item": it["id"]},
                    {"op": "choose", "id": "nick", "atk": 1, "keep": True},
                    {"op": "done"},
                ]
            else:
                clicks = list(clicks) + [{"op": "done"}]
            out.append(
                base_test(
                    f"seed-keep-{it['id']}",
                    f"{it['name']} Keep is still in hand after Done",
                    "seed-keep",
                    ["seed", "keep"],
                    [it["id"]],
                    [wizard["id"]],
                    wizard["id"],
                    clicks,
                    it,
                    wizard,
                    "Keep is applied when the fight ends, not mid-click. After Done the card must still be in hand.",
                    {"expected": {"invariants": ["surfaces", "keep_until_done"], "spent": {it["id"]: False}}},
                )
            )
        if it["id"] == "sai" or ITEM_WHEN.get(it["id"]) == "flip":
            out.append(
                base_test(
                    f"seed-flip-{it['id']}",
                    f"{it['name']} after another item (2 then 4)",
                    "seed-flip",
                    ["seed", "flip"],
                    [FILLER, it["id"], it["id"]],
                    [golem["id"]],
                    golem["id"],
                    [
                        {"op": "use", "item": FILLER, "auto": True},
                        {"op": "use", "item": it["id"], "auto": True},
                        {"op": "use", "item": it["id"], "auto": True},
                    ],
                    it,
                    golem,
                    "Use Shield, then Sai, then the second Sai. Numbers must flip. A spent card cannot be the second click.",
                    {"two_copies": True},
                )
            )
        # Undo after a real click
        if not it.get("unplayable"):
            clicks = clicks_for_item(it, golem) + [{"op": "undo"}]
            out.append(
                base_test(
                    f"miss-undo-{it['id']}",
                    f"{it['name']} then Undo",
                    "miss-undo",
                    ["miss", "undo"],
                    [it["id"]],
                    [golem["id"]],
                    golem["id"],
                    clicks,
                    it,
                    golem,
                    "Click the item, then Undo. Numbers and the hand must go back. Inspect must still match the catalog.",
                )
            )
        out.append(
            base_test(
                f"miss-hp1-{it['id']}",
                f"{it['name']} while you are at 1 HP",
                "miss-hp1",
                ["miss", "hp1"],
                [it["id"]],
                [golem["id"]],
                golem["id"],
                clicks_for_item(it, golem) + [{"op": "done"}],
                it,
                golem,
                "You start at 1 HP. Lethal, Heal, and 'missing HP' formulas must be honest.",
                {"hp_before": 1},
            )
        )

    for mon in mons:
        if mon.get("grant"):
            out.append(
                base_test(
                    f"seed-facing-grant-{mon['id']}",
                    f"Spin {mon['name']} while facing her (grant still happens)",
                    "seed-facing-grant",
                    ["seed", "on_spin"],
                    [FILLER],
                    [mon["id"]],
                    mon["id"],
                    [],
                    its_by.get(FILLER, its[0]),
                    mon,
                    "Facing this monster on Spin must still Grant if the card Grants on Spin. A full hand is a separate row.",
                    {"hand_cap": 10},
                )
            )
    return out


def order_tests(its, mons, its_by, mons_by):
    out = []
    hubs = [it for it in its if it["id"] in ORDER_HUBS or it.get("copy_last") or it.get("hand_count")]
    partners = [it for it in its if it["id"] not in {h["id"] for h in hubs}]
    face_ids = [m for m in ("golem", "goblin", "dragon") if m in mons_by]
    for hub in hubs:
        for other in partners:
            for face_id in face_ids:
                mon = mons_by[face_id]
                for a, b, tag in ((hub, other, "ab"), (other, hub, "ba")):
                    clicks = clicks_for_item(a, mon) + clicks_for_item(b, mon) + [{"op": "done"}]
                    out.append(
                        base_test(
                            f"ord-{a['id']}-{b['id']}-{face_id}-{tag}",
                            f"{a['name']} then {b['name']} vs {mon['name']}",
                            "order",
                            ["order", "collision"],
                            [a["id"], b["id"]],
                            [face_id],
                            face_id,
                            clicks,
                            a,
                            mon,
                            f"Order matters: {a['name']} first, then {b['name']}. Copy-last / hand-count / Sai-flip must see the first click.",
                        )
                    )
    return out


def main():
    its = load_items()
    mons = load_monsters()
    its_by = by_id(its)
    mons_by = by_id(mons)
    tests = []
    tests += grid_tests(its, mons, mons_by)
    tests += miss_tests(its, mons, its_by, mons_by)
    tests += order_tests(its, mons, its_by, mons_by)
    sprites = {r["id"]: r.get("sprite") or "" for r in its + mons}
    payload = {
        "id": "dense-mill",
        "tests": tests,
        "sprites": sprites,
        "counts": {
            "items": len(its),
            "monsters": len(mons),
            "tests": len(tests),
            "grid": sum(1 for t in tests if t["family"] == "grid"),
            "miss": sum(1 for t in tests if t["family"].startswith("miss")),
            "order": sum(1 for t in tests if t["family"] == "order"),
            "seed": sum(1 for t in tests if t["family"].startswith("seed")),
        },
    }
    OUT.write_text(json.dumps(payload, ensure_ascii=False) + "\n", encoding="utf-8")
    SLIM_OUT.write_text(json.dumps(payload["counts"], indent=2) + "\n", encoding="utf-8")
    print(json.dumps(payload["counts"]))


if __name__ == "__main__":
    main()
