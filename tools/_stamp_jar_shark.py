"""Stamp Jar O' Grease and Shark unique 16x16 (4x nearest) art."""
from __future__ import annotations

import hashlib
from pathlib import Path

from PIL import Image

ROOT = Path(r"C:\Users\Natha\Documents\boss-rush")
ITEMS = ROOT / "assets" / "dungeon" / "items"
EXTRA = ROOT / "assets" / "dungeon" / "extra"

PAL = {
    ".": (0, 0, 0, 0),
    "k": (26, 18, 16, 255),
    "K": (58, 42, 36, 255),
    "m": (92, 92, 100, 255),
    "M": (168, 172, 180, 255),
    "w": (220, 224, 228, 255),
    "n": (48, 48, 52, 255),
    "g": (196, 148, 52, 255),
    "G": (232, 196, 106, 255),
    "o": (140, 88, 28, 255),
    "O": (184, 124, 48, 255),
    "r": (168, 36, 36, 255),
    "R": (220, 72, 56, 255),
    "s": (216, 176, 140, 255),
    "S": (240, 208, 176, 255),
    "b": (56, 92, 168, 255),
    "B": (120, 168, 220, 255),
    "p": (108, 48, 140, 255),
    "P": (176, 96, 212, 255),
    "e": (40, 120, 56, 255),
    "E": (88, 176, 72, 255),
    "c": (92, 56, 32, 255),
    "C": (140, 88, 48, 255),
    "y": (232, 196, 64, 255),
    "Y": (255, 236, 140, 255),
    "u": (72, 72, 76, 255),
    "U": (132, 128, 120, 255),
    "t": (200, 72, 120, 255),
    "i": (248, 248, 252, 255),
    "d": (36, 80, 44, 255),
    "a": (168, 48, 48, 255),
    "h": (80, 140, 72, 255),
    "f": (252, 120, 40, 255),
    "F": (255, 188, 72, 255),
    "x": (20, 16, 14, 255),
    "z": (64, 160, 72, 255),
    "q": (120, 96, 160, 255),
    "Q": (188, 156, 220, 255),
    "v": (88, 28, 28, 255),
    "j": (48, 28, 20, 255),
    "l": (172, 196, 80, 255),
    "L": (212, 228, 120, 255),
    "A": (168, 148, 52, 255),  # oily grease
    "D": (120, 108, 36, 255),
}


def draw(rows: list[str]) -> Image.Image:
    w = max(len(r) for r in rows)
    rows = [r.ljust(w, ".") for r in rows]
    h = len(rows)
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            px[x, y] = PAL[ch]
    return im


def up4(im: Image.Image) -> Image.Image:
    return im.resize((im.size[0] * 4, im.size[1] * 4), Image.Resampling.NEAREST)


def save(im: Image.Image, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    up4(im).save(dest)


JAR = [
    "................",
    "......kkk.......",
    ".....koook......",
    ".....koOok......",
    "......kkk.......",
    ".....kwwwk......",
    "....kwYYYYwk....",
    "....kYAAlAYk....",
    "....kALlLAyk....",
    "....kALllAYk....",
    "....kDAAlDYk....",
    "....kYDAAYyk....",
    ".....kYYYYk.....",
    "......kkkk......",
    "................",
    "................",
]

SHARK = [
    "................",
    "..........k.....",
    "....kkk..kUk....",
    "...kUUUk.kUk....",
    "..kUwwwUkkUkk...",
    ".kUUwwwUUUUrk...",
    "kUUUwwwUUUUrk...",
    "kUUwwwUUUUUkk...",
    ".kUUUUUUUUkkR...",
    "..kUUUUUUk.kR...",
    "...kUkUkk...k...",
    "....k.k.........",
    "................",
    "................",
    "................",
    "................",
]


def main() -> None:
    jobs = [
        (draw(JAR), ITEMS / "jar_o_grease.png"),
        (draw(SHARK), EXTRA / "shark.png"),
    ]
    for im, dest in jobs:
        save(im, dest)
        h = hashlib.md5(dest.read_bytes()).hexdigest()
        print(dest.name, h[:10], im.size, dest.stat().st_size)
    all_pngs = list(ITEMS.glob("*.png")) + list(EXTRA.glob("*.png"))
    by_hash: dict[str, list[str]] = {}
    for p in all_pngs:
        h = hashlib.md5(p.read_bytes()).hexdigest()
        by_hash.setdefault(h, []).append(p.name)
    dups = {h: n for h, n in by_hash.items() if len(n) > 1}
    print("DUPLICATES", dups if dups else "none")


if __name__ == "__main__":
    main()
