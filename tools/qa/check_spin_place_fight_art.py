#!/usr/bin/env python3
"""Lever 2: spin must not full-run _place_fight_art every tick. No Godot needed."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MAIN = ROOT / "scripts" / "main.gd"

NEEDLES = [
    "func _spin_holds_fight_art",
    "func _place_fight_art(force: bool = false)",
    "if not force and _spin_holds_fight_art()",
    "FRAME_METRICS.note_place",
    '_fight_art_sig = ""',
    "_place_fight_art(true)",
]

# Must keep the per-frame call site (early-out lives inside _place_fight_art).
PROCESS_CALL = "_place_fight_art()"


def main() -> int:
    text = MAIN.read_text(encoding="utf-8")
    failed = 0
    for needle in NEEDLES:
        if needle not in text:
            print(f"FAIL scripts/main.gd missing {needle!r}")
            failed += 1
    if "phase == \"spinning\"" not in text and "phase == 'spinning'" not in text:
        print("FAIL _spin_holds_fight_art must key off phase spinning")
        failed += 1
    if "wheel_view.spinning" not in text:
        print("FAIL _spin_holds_fight_art must key off wheel_view.spinning")
        failed += 1
    # _process still invokes place (no force) so spin early-out is measured.
    if PROCESS_CALL not in text:
        print("FAIL _process must still call _place_fight_art() without force")
        failed += 1
    # Do not widen attack budget / hitch breadcrumbs in this lever.
    banned = (
        "spike_markers",
        "FRAME_METRICS.note_spike",
    )
    for b in banned:
        if b in text:
            print(f"FAIL lever-2 PR must not add {b!r}")
            failed += 1
    if failed:
        return 1
    print("SPIN_PLACE_FIGHT_ART_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
