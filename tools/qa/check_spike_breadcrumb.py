#!/usr/bin/env python3
"""Lever 4: shared hitch spike breadcrumbs + stamp cache. No Godot needed."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

NEEDLES = {
    "scripts/frame_metrics.gd": [
        "const SPIKE_MS",
        "const SPIKE_KEEP",
        "spike_markers",
        "spike_ms_threshold",
        "func _record_spike",
        "func note_tag",
        "static var last_tag",
        "over_50",
        "STAMP.text()",
        "_cap_sha",
        "_cap_dirty",
        "KEY_F8",
        "cabin_idle",
        "transition_x3",
        "last_capture.json",
    ],
    "scripts/frame_metrics_stamp.gd": [
        "const CACHE_USEC",
        "func invalidate",
        "_cache_text",
        "BuildStamp.from_repo()",
    ],
}

# Do not widen combat / art / catalog in this measurement PR.
FORBIDDEN_TOUCH = (
    "data/catalog.json",
    "data/player-copy.json",
    "data/content-board.json",
)


def main() -> int:
    failed = 0
    for rel, needles in NEEDLES.items():
        path = ROOT / rel
        if not path.is_file():
            print(f"FAIL missing {rel}")
            failed += 1
            continue
        body = path.read_text(encoding="utf-8")
        for needle in needles:
            if needle not in body:
                print(f"FAIL {rel} missing {needle!r}")
                failed += 1
    metrics = (ROOT / "scripts" / "frame_metrics.gd").read_text(encoding="utf-8")
    if "SPIKE_MS := 50.0" not in metrics and "SPIKE_MS = 50.0" not in metrics:
        print("FAIL SPIKE_MS must be ~50 ms")
        failed += 1
    # Keys 1–6 and user://perf path must stay.
    for keep in ("KEY_1", "KEY_6", "user://perf"):
        if keep not in metrics:
            print(f"FAIL frame_metrics.gd missing {keep!r}")
            failed += 1
    stamp = (ROOT / "scripts" / "frame_metrics_stamp.gd").read_text(encoding="utf-8")
    if "CACHE_USEC" not in stamp:
        print("FAIL stamp cache missing")
        failed += 1
    # Measurement PR must not rewrite combat rules.
    for banned in ("func _place_fight_art", "decorative_fps", "begin_heavy"):
        if banned in metrics:
            print(f"FAIL measurement PR must not embed {banned!r} in frame_metrics")
            failed += 1
    for name in FORBIDDEN_TOUCH:
        if (ROOT / name).is_file() and name in metrics:
            print(f"FAIL metrics references forbidden {name}")
            failed += 1
    if failed:
        return 1
    print("SPIKE_BREADCRUMB_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
