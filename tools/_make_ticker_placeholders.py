#!/usr/bin/env python3
"""Flat-palette placeholder PNGs for ANIM-spin-cascade-ticker (Pixel replaces later)."""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "assets" / "ui" / "anim"

OUT = [0x10, 0x0E, 0x0C, 0xFF]
GOLD = [0xE8, 0xC3, 0x6A, 0xFF]
BRASS = [0xD4, 0x89, 0x4E, 0xFF]
INK = [0xF0, 0xE6, 0xD8, 0xFF]
DARK = [0x14, 0x10, 0x0C, 0xFF]
TRANS = [0, 0, 0, 0]


def png(w: int, h: int, rgba_pixels: list[int]) -> bytes:
	def chunk(tag: bytes, data: bytes) -> bytes:
		return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

	raw = b"".join(b"\x00" + bytes(rgba_pixels[y * w * 4 : (y + 1) * w * 4]) for y in range(h))
	ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
	return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def fill(w: int, h: int, rgba: list[int]) -> list[int]:
	return list(rgba) * (w * h)


def set_px(buf: list[int], w: int, x: int, y: int, rgba: list[int]) -> None:
	h = len(buf) // (w * 4) if w > 0 else 0
	if 0 <= x < w and 0 <= y < h:
		i = (y * w + x) * 4
		buf[i : i + 4] = rgba


def ring(w: int, h: int, rim: list[int], fill_c: list[int] | None = None) -> list[int]:
	buf = fill(w, h, TRANS)
	cx, cy = (w - 1) / 2.0, (h - 1) / 2.0
	r_out = min(cx, cy)
	r_in = r_out - 2.2
	for y in range(h):
		for x in range(w):
			d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
			if d <= r_out and d >= r_in:
				set_px(buf, w, x, y, rim)
			elif fill_c is not None and d < r_in:
				set_px(buf, w, x, y, fill_c)
	# Outer ink outline ticks
	for x in range(w):
		set_px(buf, w, x, 0, OUT)
		set_px(buf, w, x, h - 1, OUT)
	for y in range(h):
		set_px(buf, w, 0, y, OUT)
		set_px(buf, w, w - 1, y, OUT)
	return buf


def stamp_frame(frame: int) -> list[int]:
	# Press-down: ring thickens, then ink tick appears.
	press = min(3, frame)
	rim = GOLD if frame < 2 else BRASS
	buf = ring(12, 12, rim, DARK if frame >= 1 else None)
	if frame >= 2:
		# Tick mark
		for x, y in [(3, 6), (4, 7), (5, 8), (6, 7), (7, 6), (8, 5), (9, 4)]:
			yy = y + (1 if press >= 3 else 0)
			set_px(buf, 12, x, yy, INK)
			set_px(buf, 12, x, yy - 1, OUT)
	return buf


def ff_chip() -> list[int]:
	buf = fill(12, 8, TRANS)
	# Two gold chevrons ▶▶
	for ox in (1, 6):
		for y in range(1, 7):
			span = min(y - 1, 6 - y)
			for x in range(ox, ox + 1 + span):
				if x < 12:
					set_px(buf, 12, x, y, GOLD)
		for y in range(1, 7):
			set_px(buf, 12, ox, y, OUT)
	return buf


def main() -> None:
	ROOT.mkdir(parents=True, exist_ok=True)
	files: dict[str, bytes] = {
		"ticker_token_frame.png": png(12, 12, ring(12, 12, GOLD, None)),
		"ticker_ff.png": png(12, 8, ff_chip()),
	}
	for i in range(4):
		files[f"ticker_token_stamp_f{i}.png"] = png(12, 12, stamp_frame(i))
	for name, data in sorted(files.items()):
		path = ROOT / name
		path.write_bytes(data)
		print(name, len(data))
	print("count", len(files))


if __name__ == "__main__":
	main()
