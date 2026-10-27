#!/usr/bin/env python3
"""Lever 2b: place_fight_art must defer full work during spin (force included).

#132 early-out skipped only non-force calls. AFTER captures (a660816b) still
tagged spin/lunge/attack spikes as place_fight_art because force=true from
_layout_play_field / resized ran full gutter math mid-spin and cascaded
(d_place up to 24). No Godot needed.
"""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MAIN = ROOT / "scripts" / "main.gd"

NEEDLES = [
    "func _spin_holds_fight_art",
    "func _place_fight_art(force: bool = false)",
    "FRAME_METRICS.note_place",
    '_fight_art_sig = ""',
    "_place_fight_art(true)",
    "_fight_art_dirty",
    "_fight_art_frame",
    "Engine.get_process_frames()",
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
    # #132 gate that force bypassed — must be gone.
    if "if not force and _spin_holds_fight_art()" in text:
        print("FAIL spin hold must defer force too (remove `not force and`)")
        failed += 1
    if "if _spin_holds_fight_art():" not in text:
        print("FAIL _place_fight_art must early-out on _spin_holds_fight_art() alone")
        failed += 1
    # busy must not invalidate the gutter sig (lunge/attack flicker).
    place_fn = text.split("func _place_fight_art", 1)[-1].split("\nfunc ", 1)[0]
    if "combat_stage.busy" in place_fn and "busy" in place_fn.split("var sig", 1)[-1].split("if sig ==", 1)[0]:
        # Allow reading busy for layout branches; ban it inside the sig string.
        sig_block = place_fn.split("var sig", 1)[-1].split("if sig ==", 1)[0]
        if "busy" in sig_block:
            print("FAIL place_fight_art sig must not include combat_stage.busy")
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
