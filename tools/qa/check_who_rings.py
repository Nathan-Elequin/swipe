#!/usr/bin/env python3
"""Who-ring overlay: 64×64 on Weak/Tough, 80×80 on Deadly. Hard alpha. No Godot."""
from __future__ import annotations

import struct
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
ANIM = ROOT / "assets" / "ui" / "anim"


def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"not a png: {path}")
    w, h = struct.unpack(">II", data[16:24])
    return int(w), int(h)


def who_ring_native_px_for_tier(tier: int) -> int:
    return 80 if int(tier) >= 3 else 64


def check_file(path: Path, want: int) -> list[str]:
    fails: list[str] = []
    if not path.is_file():
        return [f"missing {path.name}"]
    w, h = png_size(path)
    if (w, h) != (want, want):
        fails.append(f"{path.name} {w}x{h} want {want}")
    im = Image.open(path).convert("RGBA")
    hist = im.getchannel("A").histogram()
    if any(hist[i] for i in range(1, 255)):
        fails.append(f"{path.name} semi-alpha")
    imp = path.with_name(path.name + ".import")
    if not imp.is_file():
        fails.append(f"missing import {imp.name}")
    else:
        text = imp.read_text(encoding="utf-8")
        if "compress/mode=0" not in text:
            fails.append(f"{imp.name} compress/mode not 0")
        if "mipmaps/generate=false" not in text:
            fails.append(f"{imp.name} mipmaps not false")
    return fails


def main() -> int:
    failed = 0
    if who_ring_native_px_for_tier(3) != 80 or who_ring_native_px_for_tier(1) != 64:
        print("FAIL helper")
        failed += 1
    files = [(ANIM / f"seat_target_ghost_f{i}.png", 64) for i in range(4)]
    files.append((ANIM / "seat_target_locked.png", 64))
    files.extend((ANIM / f"seat_target_ghost_deadly_f{i}.png", 80) for i in range(4))
    files.append((ANIM / "seat_target_locked_deadly.png", 80))
    for path, want in files:
        fails = check_file(path, want)
        if fails:
            for f in fails:
                print("FAIL", f)
            failed += len(fails)
        else:
            print("PASS", path.name, f"{want}x{want}")
    print(f"check_who_rings failed={failed}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
