#!/usr/bin/env python3
"""Flat-palette placeholder PNGs for ANIM-intent-plate (Pixel replaces later)."""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "assets" / "ui" / "anim"


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


def rect(buf: list[int], w: int, x0: int, y0: int, x1: int, y1: int, rgba: list[int]) -> None:
	for y in range(y0, y1):
		for x in range(x0, x1):
			set_px(buf, w, x, y, rgba)


def outline_rect(buf: list[int], w: int, x0: int, y0: int, x1: int, y1: int, rgba: list[int]) -> None:
	for x in range(x0, x1):
		set_px(buf, w, x, y0, rgba)
		set_px(buf, w, x, y1 - 1, rgba)
	for y in range(y0, y1):
		set_px(buf, w, x0, y, rgba)
		set_px(buf, w, x1 - 1, y, rgba)


OUT = [0x10, 0x0E, 0x0C, 0xFF]
DARK = [0x6A, 0x1C, 0x14, 0xFF]
MID = [0x8B, 0x1E, 0x1E, 0xFF]
LIT = [0xE0, 0x7A, 0x7A, 0xFF]
GOLD = [0xE8, 0xC3, 0x6A, 0xFF]
FLAME = [0xE0, 0x7A, 0x3D, 0xFF]
FLAME2 = [0xFF, 0xE6, 0xA8, 0xFF]
BLUE = [0x6E, 0xC8, 0xE8, 0xFF]
INK = [0xF0, 0xE6, 0xD8, 0xFF]
TRANS = [0, 0, 0, 0]


def claw(w: int, h: int, rim: list[int], body: list[int], bright: list[int] | None = None) -> list[int]:
	buf = fill(w, h, TRANS)
	margin = 1
	rect(buf, w, margin, margin, w - margin, h - margin, body)
	outline_rect(buf, w, margin, margin, w - margin, h - margin, OUT)
	ys = [4, 7, 10] if h == 16 else [6, 11, 16]
	for i, yy in enumerate(ys):
		for x in range(3, w - 3):
			set_px(buf, w, x, yy, rim)
			if bright and i == 1:
				set_px(buf, w, x, yy - 1, bright)
	cx0, cy0 = w // 2 - 3, h // 2 - 3
	rect(buf, w, cx0, cy0, cx0 + 6, cy0 + 6, body)
	return buf


def burst(w: int, h: int, rim: list[int], body: list[int], frame: int) -> list[int]:
	buf = fill(w, h, TRANS)
	r = 4 + frame * 2
	cx, cy = w // 2, h // 2
	for y in range(h):
		for x in range(w):
			d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
			if abs(d - r) < 1.2:
				set_px(buf, w, x, y, rim)
			elif r - 3 < d < r - 1.2:
				set_px(buf, w, x, y, body)
	core = claw(16, 16, rim, body)
	ox, oy = (w - 16) // 2, (h - 16) // 2
	for y in range(16):
		for x in range(16):
			i = (y * 16 + x) * 4
			if core[i + 3] > 0:
				set_px(buf, w, ox + x, oy + y, core[i : i + 4])
	return buf


def chip_shield() -> list[int]:
	buf = fill(8, 8, TRANS)
	rect(buf, 8, 1, 1, 7, 6, BLUE)
	outline_rect(buf, 8, 1, 1, 7, 6, OUT)
	for x, y in [(4, 2), (3, 3), (5, 3), (4, 4)]:
		set_px(buf, 8, x, y, INK)
	return buf


def chip_drop() -> list[int]:
	buf = fill(8, 8, TRANS)
	for y, xs in [(1, [3, 4]), (2, [2, 3, 4, 5]), (3, [2, 3, 4, 5]), (4, [3, 4]), (5, [3, 4])]:
		for x in xs:
			set_px(buf, 8, x, y, LIT)
	outline_rect(buf, 8, 2, 1, 6, 6, OUT)
	return buf


def chip_flee() -> list[int]:
	buf = fill(8, 8, TRANS)
	for x, y in [(1, 2), (2, 3), (4, 2), (5, 3), (2, 5), (3, 6), (5, 5), (6, 6)]:
		set_px(buf, 8, x, y, GOLD)
	return buf


def main() -> None:
	ROOT.mkdir(parents=True, exist_ok=True)
	files: dict[str, bytes] = {
		"intent_claw_idle.png": png(16, 16, claw(16, 16, MID, DARK)),
		"intent_claw_flame_idle.png": png(16, 16, claw(16, 16, FLAME, DARK, FLAME2)),
		"intent_chip_shield.png": png(8, 8, chip_shield()),
		"intent_chip_drop.png": png(8, 8, chip_drop()),
		"intent_chip_flee.png": png(8, 8, chip_flee()),
	}
	for i in range(4):
		body = [min(255, DARK[0] + i * 20), min(255, DARK[1] + i * 10), min(255, DARK[2] + i * 8), 255]
		files[f"intent_claw_lit_f{i}.png"] = png(16, 16, claw(16, 16, LIT, body, LIT if i >= 1 else None))
		files[f"intent_claw_burst_f{i}.png"] = png(24, 24, burst(24, 24, LIT, MID, i))
		files[f"intent_claw_flame_burst_f{i}.png"] = png(24, 24, burst(24, 24, FLAME2, FLAME, i))
	for name, data in sorted(files.items()):
		(ROOT / name).write_bytes(data)
		print(name, len(data))
	print("count", len(files))


if __name__ == "__main__":
	main()
