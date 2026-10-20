#!/usr/bin/env python3
"""Uniqueness + import check for title teaser art.

If Pixel has not dropped title_still.png yet, exit 0 and print waiting.
When the still (and optional strips) exist: PNG signature, IHDR vs expected
shipped size, and file-hash uniqueness vs every ITEM/MONSTER extra PNG.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
from pathlib import Path

PNG_SIG = b"\x89PNG\r\n\x1a\n"
STILL = "assets/dungeon/title/title_still.png"
HILL = "assets/dungeon/title/hill_strip.png"
HALL = "assets/dungeon/title/hall_strip.png"
LOGO = "assets/dungeon/title/logo.png"
EXPECTED = {
    STILL: (1680, 1040),
    HILL: (1680, 1040),
    HALL: (1680, 1040),
}


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for cand in (here.parents[2], Path.cwd()):
        if (cand / "project.godot").is_file():
            return cand
    return here.parents[2]


def ihdr(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if data[:8] != PNG_SIG:
        raise ValueError("missing PNG signature")
    w = int.from_bytes(data[16:20], "big")
    h = int.from_bytes(data[20:24], "big")
    return w, h


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def extra_pngs(root: Path) -> list[Path]:
    art = (root / "scripts" / "dungeon_art.gd").read_text(encoding="utf-8")
    paths = re.findall(r'res://(assets/dungeon/(?:items|extra)/[^"]+\.png)', art)
    out: list[Path] = []
    for rel in paths:
        p = root / rel
        if p.is_file():
            out.append(p)
    return out


def main() -> int:
    root = repo_root()
    still = root / STILL
    if not still.is_file():
        print("waiting on Pixel: title_still.png is not in yet")
        return 0
    fails: list[str] = []
    for rel, size in EXPECTED.items():
        p = root / rel
        if not p.is_file():
            if rel == STILL:
                fails.append(f"missing {rel}")
            continue
        try:
            w, h = ihdr(p)
        except ValueError as e:
            fails.append(f"{rel}: {e}")
            continue
        if (w, h) != size:
            fails.append(f"{rel}: IHDR {w}x{h}, expected {size[0]}x{size[1]} shipped")
        imp = Path(str(p) + ".import")
        if imp.is_file():
            txt = imp.read_text(encoding="utf-8", errors="replace")
            if "compress/mode=0" not in txt and "compress/mode=lossy" in txt:
                fails.append(f"{rel}: import is not lossless")
            if "mipmaps/generate=true" in txt:
                fails.append(f"{rel}: mipmaps on")
    cards = extra_pngs(root)
    still_hash = digest(still)
    for other in cards:
        if digest(other) == still_hash:
            fails.append(f"title_still.png duplicates {other.relative_to(root).as_posix()}")
    for extra in (HILL, HALL, LOGO):
        p = root / extra
        if not p.is_file():
            continue
        h = digest(p)
        for other in cards:
            if digest(other) == h:
                fails.append(f"{extra} duplicates {other.relative_to(root).as_posix()}")
    report = {
        "still": STILL,
        "waiting": False,
        "failures": fails,
    }
    out = root / "design" / "audit-shots" / "cursor"
    out.mkdir(parents=True, exist_ok=True)
    (out / "title_teaser_check.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    if fails:
        print("FAIL")
        for f in fails:
            print(" -", f)
        return 1
    print("PASS: title still is unique and sized")
    return 0


if __name__ == "__main__":
    sys.exit(main())
