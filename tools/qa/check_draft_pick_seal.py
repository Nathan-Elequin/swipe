#!/usr/bin/env python3
"""Draft pick-seal overlays: 16×16, hard alpha, lossless import. No Godot."""
from __future__ import annotations

import struct
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
DRAFT = ROOT / "assets" / "ui" / "draft"

FILES = [
    "pick_seal.png",
    "pick_seal_press_f0.png",
    "pick_seal_press_f1.png",
    "pick_seal_press_f2.png",
    "pick_seal_press_f3.png",
    "draft_leftbehind.png",
    "recycle_return_f0.png",
    "recycle_return_f1.png",
    "recycle_return_f2.png",
    "recycle_return_f3.png",
]


def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"not a png: {path}")
    w, h = struct.unpack(">II", data[16:24])
    return int(w), int(h)


def check_file(path: Path) -> list[str]:
    fails: list[str] = []
    if not path.is_file():
        return [f"missing {path.name}"]
    w, h = png_size(path)
    if (w, h) != (16, 16):
        fails.append(f"{path.name} {w}x{h} want 16x16")
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
    for name in FILES:
        path = DRAFT / name
        fails = check_file(path)
        if fails:
            for f in fails:
                print("FAIL", f)
            failed += len(fails)
        else:
            print("PASS", name, "16x16")
    print(f"check_draft_pick_seal failed={failed}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
