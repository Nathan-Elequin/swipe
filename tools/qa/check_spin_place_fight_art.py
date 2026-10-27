#!/usr/bin/env python3
"""place_fight_art: defer during spin; NO per-frame _process poll.

#135 early-out mid-spin still left `_place_fight_art()` in `_process` every
frame. Mac spin_x5 @ d497ed18: ~42 place_calls/s (~41 early-outs/s) so
spike tags preferred place_fight_art; one cascade hit d_place=28. This lever
removes the process call and drives place from dirty/deferred + structural
callers only. No Godot needed.
"""

from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
MAIN = ROOT / "scripts" / "main.gd"

NEEDLES = [
    "func _spin_holds_fight_art",
    "func _place_fight_art(force: bool = false)",
    "func _mark_fight_art_dirty",
    "func _flush_fight_art",
    "FRAME_METRICS.note_place",
    '_fight_art_sig = ""',
    "_place_fight_art(true)",
    "_fight_art_dirty",
    "_fight_art_frame",
    "_fight_art_flush_queued",
    "call_deferred(\"_flush_fight_art\")",
    "Engine.get_process_frames()",
    "_face_plate_rev",
]


def _process_body(text: str) -> str:
    m = re.search(r"func _process\([^)]*\) -> void:\n", text)
    if not m:
        return ""
    start = m.end()
    rest = text[start:]
    # Next top-level func (col 0) ends the body.
    end_m = re.search(r"\nfunc ", rest)
    return rest if end_m is None else rest[: end_m.start()]


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
        sig_block = place_fn.split("var sig", 1)[-1].split("if sig ==", 1)[0]
        if "busy" in sig_block:
            print("FAIL place_fight_art sig must not include combat_stage.busy")
            failed += 1
    # Structural bug: _process must NOT call place every frame.
    proc = _process_body(text)
    if not proc:
        print("FAIL missing func _process")
        failed += 1
    elif "_place_fight_art(" in proc:
        print("FAIL _process must not call _place_fight_art (dirty/deferred only)")
        failed += 1
    # Full place must skip unconditional reset_size when plaque rev matches.
    if "face_box.reset_size()" not in place_fn:
        print("FAIL place still needs a gated face_box.reset_size path")
        failed += 1
    if "_fight_art_plaque_rev" not in place_fn:
        print("FAIL full place must cache plaque rev to skip reset_size")
        failed += 1
    if "_place_sprite" not in place_fn:
        print("FAIL place must still call _place_sprite when stage moves")
        failed += 1
    # Do not widen hitch breadcrumb machinery inside main.
    banned = (
        "spike_markers",
        "FRAME_METRICS.note_spike",
    )
    for b in banned:
        if b in text:
            print(f"FAIL place PR must not add {b!r} to main.gd")
            failed += 1
    if failed:
        return 1
    print("SPIN_PLACE_FIGHT_ART_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
