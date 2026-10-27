#!/usr/bin/env python3
"""SP-30 source hooks. Runs without Godot so CI can still check the wiring."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

HOOKS = {
    "scripts/combat_fx_budget.gd": [
        "class_name CombatFxBudget",
        "func hold_low_priority_idles",
        "func is_heavy_state",
        "func decorative_fps",
        "func decor_step",
        "func set_spinning",
        "func is_spinning",
        "return 12.0",
        "return 4.0",
        "SP-30",
        "attack_x5",
    ],
    "scripts/combat_stage.gd": [
        "combat_fx_budget.gd",
        "hold_low_priority_idles",
        "_portrait_dirty",
        "_decor_is_immediate",
        "decor_step",
    ],
    "scripts/dungeon_bg.gd": [
        "combat_fx_budget.gd",
        "FLICKER_STEP",
        "hold_low_priority_idles",
        "is_spinning",
    ],
    "scripts/boss_wheel.gd": [
        "combat_fx_budget.gd",
        "_queue_decor_redraw",
        "_wheel_wants_live_draw",
        "begin_heavy",
        "_set_hero_heavy",
        "FRAME_METRICS.note_wheel",
        "hold_low_priority_idles",
        "set_spinning",
        "_wedge_starts(0.0)",
        "rot + _move_hint_angle()",
    ],
    "scripts/player_stage.gd": [
        "combat_fx_budget.gd",
        "is_heavy_state",
        "begin_heavy",
    ],
    "scripts/item_card.gd": [
        "combat_fx_budget.gd",
        "hold_low_priority_idles",
    ],
    "scripts/ability_slash.gd": [
        "combat_fx_budget.gd",
        "begin_heavy",
        "end_heavy",
        "FRAME_METRICS.note_slash",
        "decor_step",
        "_slash_dirty",
        "release_early",
        "func _show_cutin(fast: bool, release_early: bool = false, ticket: Dictionary = {})",
        "Portrait tell is up",
    ],
    "scripts/main.gd": [
        "_fight_art_sig",
        "_fight_art_dirty",
        "_fight_art_frame",
        "_spin_holds_fight_art",
        '"release_early": true',
        "func _announce_slice",
    ],
}


def main() -> int:
    failed = 0
    for rel, needles in HOOKS.items():
        path = ROOT / rel
        text = path.read_text(encoding="utf-8")
        for needle in needles:
            if needle not in text:
                print(f"FAIL {rel} missing {needle!r}")
                failed += 1
    if failed:
        return 1
    print("COMBAT_FX_BUDGET_HOOKS_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
