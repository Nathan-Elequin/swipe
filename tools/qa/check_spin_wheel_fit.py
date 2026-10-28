#!/usr/bin/env python3
"""Spin wheel: pass6 fit must stay cached across rot; no mid-spin refit.

Mac spin_x5 @ c208e866 (after #136/#137): fps ~30.9, frame_ms p95 78.8 /
max 101, truthful spike tags mostly wheel with process_ms ≈ 433.
Root cause: `_fit_sig_of` keyed on `snappedf(rot, 0.02)`, so every spin
tick rebuilt `_search_feet` for every seat.

Locks:
- fit sig has no rot
- fit + spoke_rest use base angle 0; `_spoke` spins by rot + hint
- note_wheel counted in `_draw` (truthful)
- mid-spin skips ability-card tree walk / hall flicker / seat breathe
- do not put `_place_fight_art` back into `_process` (#136/#137)
- spin_to total duration is SPIN_DURATION (1.56 s ≈ 1.2 × 1.3)

No Godot needed.
"""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
WHEEL = ROOT / "scripts" / "boss_wheel.gd"
BUDGET = ROOT / "scripts" / "combat_fx_budget.gd"
HALL = ROOT / "scripts" / "dungeon_bg.gd"
MAIN = ROOT / "scripts" / "main.gd"


def _func_body(text: str, name: str) -> str:
    m = re.search(rf"func {re.escape(name)}\([^)]*\)[^\n]*\n", text)
    if not m:
        return ""
    rest = text[m.end() :]
    end = re.search(r"\nfunc ", rest)
    return rest if end is None else rest[: end.start()]


def main() -> int:
    wheel = WHEEL.read_text(encoding="utf-8")
    budget = BUDGET.read_text(encoding="utf-8")
    hall = HALL.read_text(encoding="utf-8")
    main_gd = MAIN.read_text(encoding="utf-8")
    failed = 0

    fit_sig = _func_body(wheel, "_fit_sig_of")
    if not fit_sig:
        print("FAIL missing _fit_sig_of")
        failed += 1
    else:
        # Strip comments before scanning — the doc line names `rot` on purpose.
        code_lines = []
        for line in fit_sig.splitlines():
            code_lines.append(line.split("#", 1)[0])
        code = "\n".join(code_lines)
        if re.search(r"\brot\b", code) or "snappedf" in code:
            print("FAIL _fit_sig_of must not key on rot (spin rebuilds search_feet)")
            failed += 1

    fit_table = _func_body(wheel, "_fit_table")
    if "_wedge_starts(0.0)" not in fit_table and "_wedge_starts(0)" not in fit_table:
        print("FAIL _fit_table must fit in base space (_wedge_starts(0.0))")
        failed += 1
    if "_wedge_starts(rot)" in fit_table:
        print("FAIL _fit_table must not call _wedge_starts(rot)")
        failed += 1

    spoke_rest = _func_body(wheel, "_spoke_rest")
    if "_wedge_starts(0.0)" not in spoke_rest and "_wedge_starts(0)" not in spoke_rest:
        print("FAIL _spoke_rest must build in base space (_wedge_starts(0.0))")
        failed += 1
    if "_wedge_starts(rot)" in spoke_rest:
        print("FAIL _spoke_rest must not call _wedge_starts(rot)")
        failed += 1

    spoke = _func_body(wheel, "_spoke")
    if "rot + _move_hint_angle()" not in spoke and "rot+_move_hint_angle()" not in spoke:
        print("FAIL _spoke must _spin_spoke by rot + move-hint")
        failed += 1
    if "_spin_spoke" not in spoke:
        print("FAIL _spoke must call _spin_spoke")
        failed += 1

    spin_spoke = _func_body(wheel, "_spin_spoke")
    if "_spin_rect" in spin_spoke:
        print("FAIL _spin_spoke must rebuild upright sprite/tag from spun feet, not _spin_rect")
        failed += 1
    if "sprite_rect" not in spin_spoke or "tag_rect" not in spin_spoke:
        print("FAIL _spin_spoke must rebuild sprite_rect and tag_rect after spinning feet")
        failed += 1

    draw = _func_body(wheel, "_draw")
    if "FRAME_METRICS.note_wheel()" not in draw:
        print("FAIL note_wheel must live in _draw (truthful redraw count)")
        failed += 1

    process = _func_body(wheel, "_process")
    # Mid-spin must not force queue_redraw + note_wheel every process tick.
    spin_branch = ""
    if "if spinning:" in process:
        # first spinning block inside _process (tick / redraw)
        parts = process.split("if spinning:")
        if len(parts) >= 2:
            spin_branch = parts[1].split("\nelif ")[0].split("\nif ")[0]
    if "FRAME_METRICS.note_wheel()" in process and "FRAME_METRICS.note_wheel()" not in draw:
        print("FAIL note_wheel should not be process-only")
        failed += 1
    # After the hero/chrome section, spinning should not call queue_redraw.
    # Allow queue_redraw earlier for bond anim.
    tail = process
    if "_hero_tick" in process:
        tail = process.split("_hero_tick", 1)[-1]
    if "if spinning:" in tail and "queue_redraw()" in tail.split("if spinning:", 1)[-1].split("elif ", 1)[0]:
        print("FAIL mid-spin _process must not queue_redraw (rot setter owns spin redraws)")
        failed += 1

    idle_held = _func_body(wheel, "_wheel_idle_held")
    if "if spinning:" not in idle_held or "return true" not in idle_held:
        print("FAIL _wheel_idle_held must freeze seat idles while spinning")
        failed += 1

    sync_ab = _func_body(wheel, "_sync_ability_cards")
    if "spinning" not in sync_ab:
        print("FAIL _sync_ability_cards must early-out while spinning")
        failed += 1

    for needle in (
        "func set_spinning",
        "func is_spinning",
        "_spinning",
    ):
        if needle not in budget:
            print(f"FAIL combat_fx_budget missing {needle!r}")
            failed += 1

    if "FX_BUDGET.set_spinning(true)" not in wheel:
        print("FAIL spin_to must FX_BUDGET.set_spinning(true)")
        failed += 1
    if "FX_BUDGET.set_spinning(false)" not in wheel:
        print("FAIL spin end / kill_spin must FX_BUDGET.set_spinning(false)")
        failed += 1

    if "const SPIN_DURATION := 1.56" not in wheel:
        print("FAIL SPIN_DURATION must stay 1.56 (~30% slower than old 1.2 s)")
        failed += 1
    spin_to = _func_body(wheel, "spin_to")
    if "SPIN_DURATION" not in spin_to:
        print("FAIL spin_to must tween with SPIN_DURATION")
        failed += 1
    if re.search(r"tween_property\(self,\s*\"rot\".*,\s*1\.2\)", spin_to):
        print("FAIL spin_to must not hardcode old 1.2 s duration")
        failed += 1

    if "is_spinning()" not in hall:
        print("FAIL dungeon_bg must pause flicker while FX_BUDGET.is_spinning()")
        failed += 1

    # Do not regress #136/#137.
    proc_main = _func_body(main_gd, "_process")
    if "_place_fight_art(" in proc_main:
        print("FAIL main._process must not call _place_fight_art (#136)")
        failed += 1
    if "func _queue_fight_art_flush_next_frame" not in main_gd:
        print("FAIL keep #137 next-frame flush safety")
        failed += 1

    if failed:
        return 1
    print("SPIN_WHEEL_FIT_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
