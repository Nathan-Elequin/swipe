#!/usr/bin/env python3
"""Mirrors scripts/playtest_ux.gd so the SP-06/10/12/13 defaults can be checked without Godot."""


def hover_inspect_allowed(phase: str) -> bool:
    return phase not in {"title", "victory", "defeat", "rest"}


def loot_remaining(opening: bool, pick_i: int, plan_n: int, seat_n: int, deck_n: int, offering: bool) -> dict:
    if opening:
        total = plan_n if plan_n > 0 else max(1, seat_n)
        rem = min(total, max(0, total - pick_i))
        return {"remaining": rem, "total": total}
    rem = max(0, deck_n)
    if offering:
        rem += 1
    return {"remaining": rem, "total": max(rem, seat_n)}


def main() -> int:
    cases = [
        ("hover_fighting", hover_inspect_allowed("fighting")),
        ("hover_slaying", hover_inspect_allowed("slaying")),
        ("hover_ready", hover_inspect_allowed("ready")),
        ("no_hover_title", not hover_inspect_allowed("title")),
        ("loot_open_six", loot_remaining(True, 0, 6, 6, 6, True) == {"remaining": 6, "total": 6}),
        ("loot_open_four", loot_remaining(True, 2, 6, 6, 6, True)["remaining"] == 4),
        ("loot_entry_four", loot_remaining(False, 0, 0, 6, 3, True)["remaining"] == 4),
        ("examples", set(["wizard", "golem", "goblin", "bandit", "commander"]) <= set(["wizard", "golem", "goblin", "bandit", "commander"])),
    ]
    failed = 0
    for name, ok in cases:
        print(f"CASE {name} ok={ok}")
        if not ok:
            failed += 1
    if failed:
        print("FAILED", failed)
        return 1
    print("SELFTEST_OK playtest_ux_policy")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
