#!/usr/bin/env python3
"""SOURCE-ONLY checks for cabinet homecoming restoration (no Godot required).

Does NOT prove runtime cancellation reentry or live cabin FX.
For engine protocol tests when Godot is present:
  ./tools/qa/run_homecoming_ceremony.sh

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
NOTES: list[str] = []


def ok(name: str, cond: bool, detail: str = "") -> None:
    if cond:
        PASSES.append(name)
        print(f"PASS  {name}" + (f"  ({detail})" if detail else ""))
    else:
        FAILS.append(name)
        print(f"FAIL  {name}" + (f"  ({detail})" if detail else ""))


def note(name: str, text: str) -> None:
    NOTES.append(name)
    print(f"NOTE  {name}  ({text})")


def read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def main() -> int:
    print("KIND source-only (Godot runtime not invoked by this script)")
    cabin = read("scripts/home_cabin.gd")
    main_gd = read("scripts/main.gd")
    rope = read("scripts/cabin/rope_exit.gd")
    copy = json.loads(read("data/player-copy.json"))
    keys = {row["key"]: row.get("text", "") for row in copy.get("rows", []) if "key" in row}

    # --- Spin exact copy (preserve words; no agent edits to strings) ---
    # Compared to Spin-owned drafts from the implementation prompt.
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
    # Regression: under-quota five_finds must require THIS haul to include b1.
    five_block = re.search(
        r"Under-quota Verdant five-find teaching[\s\S]*?nib\.lesson\.five_finds[\s\S]*?await _dialog\.finished",
        cabin,
    )
    ok(
        "cabin.five_finds_requires_haul_b1",
        five_block is not None and "haul_has_b1" in five_block.group(0),
        "non-b1 return must not teach Verdant",
    )
    ok("cabin.haul_includes_pool_helper", "func _haul_includes_pool" in cabin)

    # --- Push-block suppression preserved ---
    ok(
        "cabin.push_block_no_fx",
        "play_fx := (not from_push_block)" in cabin or "play_fx := (not from_push_block) and" in cabin,
    )
    ok("cabin.push_block_flag", "begin_push_block_bank" in cabin and "_bank_from_push_block" in cabin)
    ok("cabin.push_mounts_after_dialog", "open_hall_after_push_block" in cabin and "await _play_bank_sequence" in cabin)

    # --- Busy / cancel / ceremony ownership (source pattern; not runtime proof) ---
    ok("cabin.ceremony_gen_var", "var _bank_ceremony_gen" in cabin)
    ok("cabin.begin_bank_ceremony", "func _begin_bank_ceremony" in cabin)
    ok("cabin.owns_bank_ceremony", "func _owns_bank_ceremony" in cabin)
    ok("cabin.release_bank_ceremony", "func _release_bank_ceremony" in cabin)
    ok("cabin.invalidate_bank_ceremony", "func _invalidate_bank_ceremony" in cabin)
    ok("cabin.busy_includes_bank", "_bank_busy or _homecoming_bank_staging" in cabin.replace("\n", " "))
    busy_fn = re.search(r"func _busy\(\) -> bool:([\s\S]*?)(?=\nfunc |\Z)", cabin)
    ok("cabin.busy_fn_has_bank", busy_fn is not None and "_bank_busy" in busy_fn.group(1))
    abort_fn = re.search(r"func _abort_cabin_interaction\(\) -> void:([\s\S]*?)(?=\nfunc |\Z)", cabin)
    ok(
        "cabin.abort_invalidates_ceremony",
        abort_fn is not None and "_invalidate_bank_ceremony()" in abort_fn.group(0),
    )
    ok(
        "cabin.give_home_await_checks_owns",
        '["nib.home.give_home"]' in cabin
        and "_owns_bank_ceremony(ceremony_gen)" in cabin,
    )
    ok(
        "cabin.ack_takes_ceremony_gen",
        "func _ack_bank_presented(step_id: String, ceremony_gen: int = -1)" in cabin,
    )
    ok("cabin.offer_skips_keyring", '_beat == "keyring"' in cabin and "_offer_bank_sequence" in cabin)
    ok("cabin.persist_writes_seam", "var _persist_writes: bool = true" in cabin)
    ok("cabin.save_guard_persist", "if not _persist_writes:" in cabin)
    ok("cabin.effective_save_path", "func _effective_save_path" in cabin)
    ok("cabin.staging_token_api", "func _claim_homecoming_staging" in cabin and "func _clear_homecoming_staging" in cabin)
    ok("cabin.track_kill_tweens", "func _track_bank_ceremony_tween" in cabin and "func _kill_bank_ceremony_tweens" in cabin)
    ok("cabin.track_fx_nodes", "func _track_bank_ceremony_fx" in cabin and "_bank_ceremony_fx_nodes" in cabin)
    ok(
        "cabin.await_ceremony_tween",
        "func _await_bank_ceremony_tween" in cabin and "bank_ceremony_fx_aborted" in cabin,
    )
    ok(
        "cabin.case_opened_takes_gen",
        "func _case_opened_beat(pool_id: String, ceremony_gen: int = -1)" in cabin,
    )
    ok(
        "cabin.arc_takes_gen",
        "func _bank_fx_arc_to_mount(item_id: String, pool_id: String, ceremony_gen: int = -1)" in cabin,
    )
    arc_m = re.search(
        r"func _bank_fx_arc_to_mount\([\s\S]*?(?=\nfunc )",
        cabin,
    )
    ok(
        "cabin.arc_owns_before_pop",
        arc_m is not None
        and "not _owns_bank_ceremony(ceremony_gen)" in arc_m.group(0)
        and arc_m.group(0).rfind("not _owns_bank_ceremony(ceremony_gen)")
        < arc_m.group(0).find("cabin.item_pop"),
    )
    ok(
        "cabin.arc_cancel_safe_await",
        arc_m is not None
        and "await _await_bank_ceremony_tween(tw, ceremony_gen)" in arc_m.group(0)
        and "await tw.finished" not in arc_m.group(0),
    )
    smoke_m = re.search(r"func _bank_fx_bag_smoke\([\s\S]*?(?=\nfunc )", cabin)
    ok(
        "cabin.smoke_cancel_safe_await",
        smoke_m is not None
        and "await _await_bank_ceremony_tween(tw, ceremony_gen)" in smoke_m.group(0)
        and "await tw.finished" not in smoke_m.group(0),
    )
    count_m = re.search(r"func _bank_fx_loud_count\([\s\S]*?(?=\nfunc )", cabin)
    ok(
        "cabin.count_cancel_safe_await",
        count_m is not None
        and "await _await_bank_ceremony_tween(tw, ceremony_gen)" in count_m.group(0)
        and "await tw.finished" not in count_m.group(0),
    )
    kill_m = re.search(r"func _kill_bank_ceremony_tweens\(\) -> void:([\s\S]*?)(?=\nfunc |\Z)", cabin)
    ok(
        "cabin.kill_frees_fx_and_aborts",
        kill_m is not None
        and "queue_free" in kill_m.group(1)
        and "bank_ceremony_fx_aborted.emit" in kill_m.group(1),
    )
    note(
        "runtime.cancellation_reentry",
        "SOURCE PATTERN ONLY here. Engine protocol (isolated user-data): "
        "./tools/qa/run_homecoming_ceremony.sh when Godot present. "
        "Expect LIFE.* helper_completes + fx_nodes_gone. "
        "Live give-home+FX cancel under full cabin tree = REQ H11 UNCOVERED. "
        "Linux XDG isolation does NOT verify Windows — Cherry needs a separate test profile.",
    )
    selftest = ROOT / "scripts/dev/homecoming_ceremony_selftest.gd"
    runner = ROOT / "tools/qa/run_homecoming_ceremony.sh"
    ok("qa.ceremony_selftest_present", selftest.is_file())
    ok("qa.ceremony_runner_present", runner.is_file())
    st = selftest.read_text(encoding="utf-8")
    ok("qa.selftest_disables_persist", '_persist_writes", false' in st or "_persist_writes\", false" in st or 'set("_persist_writes", false)' in st)
    rn = runner.read_text(encoding="utf-8")
    ok("qa.runner_isolates_xdg", "XDG_DATA_HOME" in rn and "mktemp" in rn)
    ok("qa.runner_requires_safe_assert", "SAFE.ack_save_noop_same_meta" in rn)
    ok(
        "qa.runner_requires_life_asserts",
        "LIFE.arc_helper_completes" in rn and "LIFE.arc_fx_nodes_gone" in rn,
    )
    ok("qa.runner_windows_unverified_note", "NOT verified on Windows" in rn or "Windows/Cherry" in rn)

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
    print(f"NOTE_COUNT {len(NOTES)}")
    print("DISTINCTION source-qa-ok-does-not-equal-runtime-verified")
    if FAILS:
        print("HOMECOMING_RESTORE_FAIL")
        for f in FAILS:
            print(f"  - {f}")
        return 1
    print("HOMECOMING_RESTORE_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
