#!/usr/bin/env python3
"""Frame-metrics overlay hooks. Runs without Godot."""

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

HOOKS = {
    "scripts/frame_metrics.gd": [
        "class_name FrameMetrics",
        "KEY_F8",
        "note_wheel",
        "note_stage",
        "note_hall",
        "note_slash",
        "note_place",
        "note_tag",
        "over_16_7",
        "over_33_3",
        "over_50",
        "spike_markers",
        "SPIKE_MS",
        "heavy_count",
        "TIME_PROCESS",
        "RENDER_TOTAL_DRAW_CALLS_IN_FRAME",
        "last_capture.json",
        "JavaScriptBridge.download_buffer",
        "cabin_idle",
        "fight_idle",
        "attack_x5",
        "spin_x5",
        "lunge_x5",
        "transition_x3",
    ],
    "scripts/frame_metrics_stamp.gd": [
        "class_name FrameMetricsStamp",
        "const GIT_SHA",
        "const CACHE_USEC",
        "func sha_hex",
        "func invalidate",
    ],
    "scripts/main.gd": [
        "frame_metrics.gd",
        "FRAME_METRICS.attach",
        "FRAME_METRICS.note_place",
        "_spin_holds_fight_art",
        "_fight_art_dirty",
        "_fight_art_frame",
    ],

    "scripts/boss_wheel.gd": [
        "frame_metrics.gd",
        "FRAME_METRICS.note_wheel",
        "_queue_decor_redraw",
    ],
    "scripts/combat_stage.gd": [
        "frame_metrics.gd",
        "FRAME_METRICS.note_stage",
    ],
    "scripts/dungeon_bg.gd": [
        "frame_metrics.gd",
        "FRAME_METRICS.note_hall",
        "FLICKER_STEP",
    ],
    "scripts/ability_slash.gd": [
        "frame_metrics.gd",
        "FRAME_METRICS.note_slash",
    ],
}

FORBIDDEN = (
    "data/catalog.json",
    "data/player-copy.json",
    "data/content-board.json",
)


def main() -> int:
    failed = 0
    overlay = ROOT / "scripts" / "frame_metrics.gd"
    if not overlay.is_file():
        print("FAIL overlay missing at scripts/frame_metrics.gd")
        return 1
    if "scripts/dev/" in overlay.as_posix():
        print("FAIL overlay is under scripts/dev")
        failed += 1
    text = overlay.read_text(encoding="utf-8")
    for banned in ("KEY_F2", "KEY_F3", "KEY_F4", "KEY_F5", "KEY_F6", "KEY_F7", "KEY_F9"):
        if banned in text:
            print(f"FAIL overlay binds {banned}")
            failed += 1
    stamp = (ROOT / "scripts" / "frame_metrics_stamp.gd").read_text(encoding="utf-8")
    if 'const GIT_SHA := "' not in stamp:
        print("FAIL stamp const missing")
        failed += 1
    for rel, needles in HOOKS.items():
        body = (ROOT / rel).read_text(encoding="utf-8")
        for needle in needles:
            if needle not in body:
                print(f"FAIL {rel} missing {needle!r}")
                failed += 1
    diff = subprocess.run(
        ["git", "diff", "--name-only", "playtest/cherry-latest"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    names = diff.stdout.splitlines()
    for name in names:
        low = name.replace("\\", "/").lower()
        if low.endswith(".png") or low in FORBIDDEN:
            print(f"FAIL diff touches {name}")
            failed += 1
    if failed:
        return 1
    print("FRAME_METRICS_HOOKS_OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
