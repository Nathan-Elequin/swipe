#!/usr/bin/env python3
"""Flat magenta placeholder PNGs for ANIM pass4 (Pixel replaces later)."""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAGENTA = [0xFF, 0x00, 0xFF, 0xFF]
OUT = [0x10, 0x0E, 0x0C, 0xFF]


def png(w: int, h: int, rgba_pixels: list[int]) -> bytes:
	def chunk(tag: bytes, data: bytes) -> bytes:
		return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

	raw = b"".join(b"\x00" + bytes(rgba_pixels[y * w * 4 : (y + 1) * w * 4]) for y in range(h))
	ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
	return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")


def flat(w: int, h: int) -> list[int]:
	buf = MAGENTA * (w * h)
	for x in range(w):
		for y in (0, h - 1):
			i = (y * w + x) * 4
			buf[i : i + 4] = OUT
	for y in range(h):
		for x in (0, w - 1):
			i = (y * w + x) * 4
			buf[i : i + 4] = OUT
	return buf


def write(rel: str, w: int, h: int) -> None:
	path = ROOT / rel
	path.parent.mkdir(parents=True, exist_ok=True)
	path.write_bytes(png(w, h, flat(w, h)))
	print(rel, path.stat().st_size)


def main() -> None:
	for i in range(4):
		write(f"assets/ui/anim/poison_badge_drip_f{i}.png", 8, 8)
		write(f"assets/ui/anim/poison_burst_f{i}.png", 24, 24)
		write(f"assets/ui/anim/heart_drip_f{i}.png", 12, 12)
	write("assets/ui/anim/poison_lock.png", 6, 6)
	for i in range(5):
		write(f"assets/ui/anim/petrify_shatter_f{i}.png", 30, 30)
	for i in range(6):
		write(f"assets/dungeon/anim/hook_throw_f{i}.png", 24, 24)
	write("assets/dungeon/anim/hook_taut.png", 24, 24)
	write("assets/dungeon/anim/rope_tile.png", 4, 8)
	for name in ("sword", "wisp", "drop", "lock", "shield"):
		write(f"assets/ui/anim/aura_glyph_{name}.png", 8, 8)
	print("count ok")


if __name__ == "__main__":
	main()
