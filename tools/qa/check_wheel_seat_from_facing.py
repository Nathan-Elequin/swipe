#!/usr/bin/env python3
"""Wheel seats from facing: PNG native size matches catalog difficulty.

Deadly (tier 3) → 64×64; every other monster with a wheel base in the v2
pack → 48×48. Idle f0 must match. No Godot needed.

Also see scripts/dev/wheel_seat_from_facing_selftest.gd for the headless
Godot twin.
"""
from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CAT = ROOT / "data" / "catalog.json"
WHEEL = ROOT / "assets" / "dungeon" / "anim" / "wheel"
MANIFEST = ROOT / "design" / "archive" / "pass-wheel-pre-facing" / "NEW-manifest-v2.json"


def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"not a png: {path}")
    w, h = struct.unpack(">II", data[16:24])
    return int(w), int(h)


def seat_native_px_for_tier(tier: int) -> int:
    return 64 if int(tier) >= 3 else 48


def main() -> int:
    cat = json.loads(CAT.read_text(encoding="utf-8"))
    pack_ids = {m["id"] for m in json.loads(MANIFEST.read_text(encoding="utf-8"))["monsters"]}
    failed = 0
    checked = 0
    for m in cat["monsters"]:
        mid = str(m.get("id", ""))
        if mid not in pack_ids:
            continue
        base = WHEEL / f"{mid}_wheel_base.png"
        if not base.is_file():
            print(f"FAIL missing base {mid}")
            failed += 1
            continue
        want = seat_native_px_for_tier(int(m.get("tier", 1)))
        w, h = png_size(base)
        if (w, h) != (want, want):
            print(f"FAIL {mid} base {w}x{h} want {want} (tier={m.get('tier')})")
            failed += 1
        idle0 = WHEEL / f"{mid}_wheel_idle_f0.png"
        if not idle0.is_file():
            print(f"FAIL {mid} missing idle f0")
            failed += 1
        else:
            iw, ih = png_size(idle0)
            if (iw, ih) != (want, want):
                print(f"FAIL {mid} idle {iw}x{ih} want {want}")
                failed += 1
        checked += 1
    if checked < 62:
        print(f"FAIL checked {checked} < 62")
        failed += 1
    print(f"check_wheel_seat_from_facing checked={checked} failed={failed}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
