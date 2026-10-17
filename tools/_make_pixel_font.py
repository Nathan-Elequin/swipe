#!/usr/bin/env python3
"""Build the 8x8 BMFont from public-domain VGA glyphs (font8x8 / IBM)."""
from __future__ import annotations

import pathlib
import re
import struct
import zlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
SRC = pathlib.Path(__file__).with_name("_font8x8_basic.h")
OUT = ROOT / "assets" / "ui" / "fonts"
CELL = 8
COLS = 16
ROWS = 8
W = COLS * CELL
H = ROWS * CELL


def parse_glyphs() -> list[list[int]]:
    text = SRC.read_text(encoding="utf-8")
    rows = re.findall(r"\{\s*((?:0x[0-9A-Fa-f]+,\s*){7}0x[0-9A-Fa-f]+)\s*\}", text)
    glyphs: list[list[int]] = []
    for row in rows:
        glyphs.append([int(p, 16) for p in row.split(",")])
    if len(glyphs) < 128:
        raise SystemExit("expected 128 glyphs, got %s" % len(glyphs))
    return glyphs[:128]


def png_chunk(tag: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)


def write_png(path: pathlib.Path, pixels: list[list[tuple[int, int, int, int]]]) -> None:
    raw = b""
    for row in pixels:
        raw += b"\x00"
        for r, g, b, a in row:
            raw += bytes((r, g, b, a))
    ihdr = struct.pack(">IIBBBBB", W, H, 8, 6, 0, 0, 0)
    png = b"\x89PNG\r\n\x1a\n"
    png += png_chunk(b"IHDR", ihdr)
    png += png_chunk(b"IDAT", zlib.compress(raw, 9))
    png += png_chunk(b"IEND", b"")
    path.write_bytes(png)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    glyphs = parse_glyphs()
    pixels = [[(0, 0, 0, 0) for _ in range(W)] for _ in range(H)]
    chars: list[str] = []
    for code in range(128):
        gx = (code % COLS) * CELL
        gy = (code // COLS) * CELL
        bits = glyphs[code]
        for y, byte in enumerate(bits):
            for x in range(CELL):
                if byte & (1 << x):
                    pixels[gy + y][gx + x] = (255, 255, 255, 255)
        if 32 <= code <= 126:
            chars.append(
                'char id=%d x=%d y=%d width=%d height=%d xoffset=0 yoffset=0 xadvance=%d page=0 chnl=15'
                % (code, gx, gy, CELL, CELL, CELL)
            )
    png_path = OUT / "swipe_pixel.png"
    write_png(png_path, pixels)
    fnt = [
        'info face="swipe_pixel" size=8 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=0 aa=0 padding=0,0,0,0 spacing=0,0',
        "common lineHeight=8 base=7 scaleW=%d scaleH=%d pages=1 packed=0 alphaChnl=0 redChnl=4 greenChnl=4 blueChnl=4" % (W, H),
        'page id=0 file="swipe_pixel.png"',
        "chars count=%d" % len(chars),
    ]
    fnt.extend(chars)
    (OUT / "swipe_pixel.fnt").write_text("\n".join(fnt) + "\n", encoding="utf-8")
    (OUT / "CREDITS.txt").write_text(
        "swipe_pixel: 8x8 VGA bitmap (public domain). Marcel Sondaar / IBM; packaged by Daniel Hepper (font8x8).\n",
        encoding="utf-8",
    )
    print("wrote", png_path, "and swipe_pixel.fnt")


if __name__ == "__main__":
    main()
