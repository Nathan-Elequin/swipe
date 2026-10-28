#!/usr/bin/env python3
"""place_fight_art: defer during spin; NO per-frame _process poll.

#135 early-out mid-spin still left `_place_fight_art()` in `_process` every
frame. Mac spin_x5 @ d497ed18: ~42 place_calls/s (~41 early-outs/s) so
spike tags preferred place_fight_art; one cascade hit d_place=28. This lever
removes the process call and drives place from dirty/deferred + structural
callers only.

Also locks the #136 Mac F5 fix: same-frame early-out must schedule the next
process_frame flush, never call_deferred (MessageQueue ping-pong → signal 11).

Land residual after #138 (07bbdf27): spin_x5 still had one place_fight_art
spike with d_place_full=2 / place_full_usec≈154ms. `_refresh_face` must not
sync-force place or blank the gutter sig on every refresh — coalesce via dirty
flush, key plate rev into the sig, warm plaque cache after show_rule, and keep
spin-hold flush retries on process_frame.
No Godot needed.
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
    "func _queue_fight_art_flush_next_frame",
    "FRAME_METRICS.note_place",
    '_fight_art_sig = ""',
    "_place_fight_art(true)",
    "_fight_art_dirty",
    "_fight_art_frame",
    "_fight_art_flush_queued",
    "call_deferred(\"_flush_fight_art\")",
    "Engine.get_process_frames()",
    "_face_plate_rev",
    "_face_plate_content_sig",
    "CONNECT_ONE_SHOT",
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


def _func_body(text: str, name: str) -> str:
    parts = text.split(f"func {name}", 1)
    if len(parts) < 2:
        return ""
    # Stop before the next top-level func; drop leading doc-comments of that next func.
    body = parts[-1].split("\nfunc ", 1)[0]
    # Trim trailing ## doc block that belongs to the following function.
    lines = body.splitlines()
    while lines and lines[-1].startswith("##"):
        lines.pop()
    while lines and lines[-1].strip() == "":
        lines.pop()
    return "\n".join(lines)


def _code_only(body: str) -> str:
    """Drop full-line and trailing # comments so needles ignore prose."""
    out = []
    for line in body.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("#"):
            continue
        if " #" in line:
            line = line.split(" #", 1)[0]
        out.append(line)
    return "\n".join(out)


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
    place_fn = _func_body(text, "_place_fight_art")
    if "combat_stage.busy" in place_fn and "busy" in place_fn.split("var sig", 1)[-1].split("if sig ==", 1)[0]:
        sig_block = place_fn.split("var sig", 1)[-1].split("if sig ==", 1)[0]
        if "busy" in sig_block:
            print("FAIL place_fight_art sig must not include combat_stage.busy")
            failed += 1
    if "_face_plate_rev" not in place_fn.split("var sig", 1)[-1].split("if sig ==", 1)[0]:
        print("FAIL place sig must include _face_plate_rev (no blank-on-every-refresh)")
        failed += 1
    # Hub enforcement must run before sig is recorded (self-invalidation → 2× full).
    hub_i = place_fn.find("_hub_set(false, 1.0, Color.WHITE, true)")
    sig_i = place_fn.find("var sig :=")
    if hub_i < 0 or sig_i < 0 or hub_i > sig_i:
        print("FAIL place must _hub_set before recording geometry sig")
        failed += 1
    # Structural bug: _process must NOT call place every frame.
    proc = _process_body(text)
    if not proc:
        print("FAIL missing func _process")
        failed += 1
    elif "_place_fight_art(" in proc:
        print("FAIL _process must not call _place_fight_art (dirty/deferred only)")
        failed += 1
    # Same-frame early-out must NOT re-queue via _mark_fight_art_dirty /
    # call_deferred — that ping-pongs in one MessageQueue flush (Mac F5 #136).
    same_frame = place_fn.split("frame_i == _fight_art_frame", 1)
    if len(same_frame) < 2:
        print("FAIL place must keep same-frame early-out (frame_i == _fight_art_frame)")
        failed += 1
    else:
        same_body = same_frame[1].split("\nif ", 1)[0]
        if "_mark_fight_art_dirty()" in same_body:
            print("FAIL same-frame early-out must not call _mark_fight_art_dirty (use next-frame flush)")
            failed += 1
        if "_queue_fight_art_flush_next_frame()" not in same_body:
            print("FAIL same-frame early-out must call _queue_fight_art_flush_next_frame()")
            failed += 1
    flush_fn = _func_body(text, "_flush_fight_art")
    if "_queue_fight_art_flush_next_frame()" not in flush_fn:
        print("FAIL _flush_fight_art must defense-schedule next-frame when already placed this frame")
        failed += 1
    # Mid-spin flush must retry next frame (not drop dirty until a sync force).
    spin_flush = flush_fn.split("_spin_holds_fight_art()", 1)
    if len(spin_flush) < 2:
        print("FAIL _flush_fight_art must still gate on _spin_holds_fight_art")
        failed += 1
    else:
        # First branch body until the next `if` in flush.
        spin_body = _code_only(spin_flush[1].split("\n\tif ", 1)[0])
        if "_queue_fight_art_flush_next_frame()" not in spin_body:
            print("FAIL spin-hold flush must _queue_fight_art_flush_next_frame (keep dirty alive)")
            failed += 1
        if "call_deferred" in spin_body:
            print("FAIL spin-hold flush must not call_deferred (use next-frame)")
            failed += 1
    next_fn = _code_only(_func_body(text, "_queue_fight_art_flush_next_frame"))
    if "call_deferred" in next_fn:
        print("FAIL _queue_fight_art_flush_next_frame must not use call_deferred")
        failed += 1
    if "process_frame" not in next_fn:
        print("FAIL _queue_fight_art_flush_next_frame must wait on SceneTree.process_frame")
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
    # Land coalesce: _refresh_face dirties; must not sync-force place.
    refresh_fn = _func_body(text, "_refresh_face")
    refresh_code = _code_only(refresh_fn)
    if not refresh_fn:
        print("FAIL missing func _refresh_face")
        failed += 1
    else:
        if "_place_fight_art(" in refresh_code:
            print("FAIL _refresh_face must not call _place_fight_art (use _mark_fight_art_dirty)")
            failed += 1
        if "_mark_fight_art_dirty()" not in refresh_code:
            print("FAIL _refresh_face must _mark_fight_art_dirty for seat reveal")
            failed += 1
        if '_fight_art_sig = ""' in refresh_code:
            print("FAIL _refresh_face must not blank _fight_art_sig (plate rev is in place sig)")
            failed += 1
        if "_fight_art_plaque_rev = _face_plate_rev" not in refresh_code:
            print("FAIL _refresh_face must warm plaque cache after show_rule")
            failed += 1
    # Layout may still force place (structural resize).
    layout_fn = _func_body(text, "_layout_play_field")
    if "_place_fight_art(true)" not in layout_fn:
        print("FAIL _layout_play_field must still force place for structural layout")
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
