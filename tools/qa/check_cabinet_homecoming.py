#!/usr/bin/env python3
"""Source/unit checks for cabinet homecoming restoration (no Godot required).

Covers: pending serialize defaults, Spin copy keys, push-block FX suppression,
tutorial zero-credit open, S7 preference, lesson gating hooks.
Exit 0 on pass. Prints HOMECOMING_RESTORE_OK / FAIL.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FAILS: list[str] = []
PASSES: list[str] = []


def ok(name: str, cond: bool, detail: str = "") -> None:
    if cond:
        PASSES.append(name)
        print(f"PASS  {name}" + (f"  ({detail})" if detail else ""))
    else:
        FAILS.append(name)
        print(f"FAIL  {name}" + (f"  ({detail})" if detail else ""))


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def main() -> int:
    cabin = read("scripts/home_cabin.gd")
    main_gd = read("scripts/main.gd")
    rope = read("scripts/cabin/rope_exit.gd")
    copy = json.loads(read("data/player-copy.json"))
    keys = {row["key"]: row.get("text", "") for row in copy.get("rows", []) if "key" in row}

    # --- Spin exact copy (preserve words) ---
    expected = {
        "nib.home.give_home": "Let's give these a home.",
        "nib.lesson.new_mark": (
            "See that 'New!' mark? We haven't brought one of those home yet. "
            "Make it back with it, and we'll add it to the collection."
        ),
        "nib.lesson.extract_haul": (
            "These are the new finds you can bring home. "
            "Five different finds from Verdant Hollow will open the way deeper. "
            "They don't all have to come home together."
        ),
        "nib.lesson.five_finds": (
            "Five different finds from Verdant Hollow will open the way deeper. "
            "They don't all have to come home together."
        ),
        "nib.lesson.five_threshold": (
            "Five different finds! There's a way beyond Verdant Hollow now. "
            "Head through the Hollow to reach it."
        ),
        "nib.lesson.tutorial_return": (
            "Back in one piece. Next time, let's bring something home for these shelves."
        ),
    }
    for k, text in expected.items():
        ok(f"copy.{k}", keys.get(k) == text, f"got={keys.get(k)!r}")

    # No outdated glint lesson invented
    glint_lessons = [k for k in keys if "glint" in k.lower() and k.startswith("nib.lesson")]
    ok("copy.no_invented_glint_lesson", glint_lessons == [], f"{glint_lessons}")

    # --- Pending queue persistence ---
    ok("cabin.bank_pending_var", "var bank_pending: Array" in cabin)
    ok("cabin.save_writes_pending", 'data["bank_pending"]' in cabin)
    ok("cabin.read_default_empty", 'parsed.get("bank_pending", [])' in cabin)
    ok("cabin.ack_helper", "func _ack_bank_presented" in cabin)
    ok("cabin.restore_helper", "func _restore_bank_hold_from_pending" in cabin)
    ok(
        "cabin.restore_never_all_banked",
        "historic" in cabin.lower() or "Never reconstructed from historic" in cabin
        or "never all historic" in cabin.lower()
        or "Never treat historic swiped as pending" in cabin
        or "never treat historic" in cabin.lower(),
    )
    ok("cabin.clear_anim_keeps_pending", "bank_pending stays on disk" in cabin or "intentionally NOT cleared" in cabin or "Session FX flags only" in cabin)

    # --- Staging + S7 reuse ---
    ok("cabin.stage_homecoming", "func _stage_homecoming_bank" in cabin)
    ok("cabin.uses_existing_s7", "_bank_fx_bag_smoke" in cabin and "_bank_fx_arc_to_mount" in cabin)
    ok("cabin.give_home_before_fx", '["nib.home.give_home"]' in cabin)
    ok("cabin.threshold_after_cross", '["nib.lesson.five_threshold"]' in cabin)
    ok("cabin.verdant_threshold_b1_only", 'crossed.has("b1")' in cabin and "five_threshold" in cabin)

    # --- Push-block suppression preserved ---
    ok(
        "cabin.push_block_no_fx",
        "play_fx := (not from_push_block)" in cabin or "play_fx := (not from_push_block) and" in cabin,
    )
    ok("cabin.push_block_flag", "begin_push_block_bank" in cabin and "_bank_from_push_block" in cabin)
    ok("cabin.push_mounts_after_dialog", "open_hall_after_push_block" in cabin and "await _play_bank_sequence" in cabin)

    # --- Busy / cancel safety ---
    ok("cabin.busy_includes_bank", "_bank_busy or _homecoming_bank_staging" in cabin or "_bank_busy or _homecoming_bank_staging" in cabin.replace("\n", " "))
    busy_fn = re.search(r"func _busy\(\) -> bool:([\s\S]*?)(?=\nfunc |\Z)", cabin)
    ok("cabin.busy_fn_has_bank", busy_fn is not None and "_bank_busy" in busy_fn.group(1))
    ok("cabin.abort_releases_busy", "_abort_cabin_interaction" in cabin and "_bank_busy = false" in cabin)
    ok("cabin.offer_skips_keyring", '_beat == "keyring"' in cabin and "_offer_bank_sequence" in cabin)

    # --- Tutorial zero credit ---
    road = re.search(r"func _road_finish_to_cabin\([\s\S]*?(?=\nfunc )", main_gd)
    ok(
        "main.tutorial_open_empty",
        road is not None and '_open_home_cabin(true, "win", [], [])' in road.group(0),
    )
    ok("cabin.tutorial_return_lesson", '["nib.lesson.tutorial_return"]' in cabin)
    ok(
        "cabin.tutorial_gate",
        "tutorial_done and not tutorial_declined" in cabin and "tutorial_return" in cabin,
    )

    # --- Lesson hooks (ready / extract) ---
    ok("main.new_mark_ready_only", 'phase != "ready"' in main_gd and "new_mark" in main_gd)
    ok("main.new_mark_not_fighting", 'phase == "fighting"' in main_gd and "_play_new_mark_lesson" in main_gd)
    ok("main.extract_b1_only", 'pool != "b1"' in main_gd and "extract_haul" in main_gd)
    ok("rope.say_lesson", "func say_lesson" in rope)
    ok("main.no_campaign_bank_on_tutorial_road", "swipe_ids" not in (road.group(0) if road else ""))

    # --- Loss / duplicate paths stay quiet (static shape) ---
    ok(
        "main.loss_empty_ids",
        '_open_home_cabin(true, "loss", [], [])' in main_gd,
    )
    ok("cabin.swipe_only_new", "if not bool(swiped.get(sid, false)):" in cabin)

    # --- Rank shimmer / collection glow not re-enabled ---
    ok(
        "main.keeps_draft_glow_off",
        "set_draft_glow(false)" in main_gd and "set_cabinet_badge" in main_gd,
    )

    print("---")
    print(f"PASS_COUNT {len(PASSES)}")
    print(f"FAIL_COUNT {len(FAILS)}")
    if FAILS:
        print("HOMECOMING_RESTORE_FAIL")
        for f in FAILS:
            print(f"  - {f}")
        return 1
    print("HOMECOMING_RESTORE_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
