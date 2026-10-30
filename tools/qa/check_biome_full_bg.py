#!/usr/bin/env python3
"""Full-art biome wheel plates: assets + dungeon_bg loader contract.

Locks (2026-10-30):
- Five opaque 1680×1040 RGB plates at assets/ui/biome_full/bg_wheel_b1.png…b5.png
- Quiet tint strips at assets/ui/biome_bg/bN.png stay untouched
- Loader prefers biome_full; falls back to quiet tint
- Full-art uses MIX @ ~1.0; quiet tint stays ADD @ ~0.50
- Opaque floor/wall/dais blit is skipped under a full-art plate

No Godot needed.
"""

from __future__ import annotations

import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FULL_DIR = ROOT / "assets" / "ui" / "biome_full"
QUIET_DIR = ROOT / "assets" / "ui" / "biome_bg"
HALL = ROOT / "scripts" / "dungeon_bg.gd"
BIOME_IDS = ("b1", "b2", "b3", "b4", "b5")


def _png_ihdr(path: Path) -> tuple[int, int, int]:
	data = path.read_bytes()
	if data[:8] != b"\x89PNG\r\n\x1a\n":
		raise ValueError(f"{path.name}: bad PNG signature")
	if data[12:16] != b"IHDR":
		raise ValueError(f"{path.name}: missing IHDR")
	w, h, _bit, ctype = struct.unpack(">IIBB", data[16:26])
	return w, h, ctype


def main() -> int:
	failed = 0
	hall = HALL.read_text(encoding="utf-8")

	if 'BIOME_FULL_DIR := "res://assets/ui/biome_full/bg_wheel_%s.png"' not in hall:
		print("FAIL dungeon_bg missing BIOME_FULL_DIR")
		failed += 1
	if 'BIOME_BG_DIR := "res://assets/ui/biome_bg/%s.png"' not in hall:
		print("FAIL dungeon_bg missing BIOME_BG_DIR quiet fallback")
		failed += 1
	if "BLEND_MODE_MIX" not in hall:
		print("FAIL dungeon_bg must use MIX for full-art plates")
		failed += 1
	if "BLEND_MODE_ADD" not in hall:
		print("FAIL dungeon_bg must keep ADD for quiet tint")
		failed += 1
	if "BIOME_FULL_ALPHA" not in hall or "BIOME_BG_ALPHA" not in hall:
		print("FAIL dungeon_bg missing full/quiet alpha constants")
		failed += 1
	if "if _biome_full:" not in hall:
		print("FAIL dungeon_bg must gate scenery under full-art")
		failed += 1
	# Full path tried before quiet path.
	full_idx = hall.find("BIOME_FULL_DIR % want")
	quiet_idx = hall.find("BIOME_BG_DIR % want")
	if full_idx < 0 or quiet_idx < 0 or full_idx > quiet_idx:
		print("FAIL set_biome must prefer biome_full before biome_bg")
		failed += 1

	for bid in BIOME_IDS:
		full = FULL_DIR / f"bg_wheel_{bid}.png"
		quiet = QUIET_DIR / f"{bid}.png"
		imp = FULL_DIR / f"bg_wheel_{bid}.png.import"
		if not full.is_file():
			print(f"FAIL missing {full.relative_to(ROOT)}")
			failed += 1
			continue
		if not quiet.is_file():
			print(f"FAIL quiet tint missing {quiet.relative_to(ROOT)}")
			failed += 1
		if not imp.is_file():
			print(f"FAIL missing import {imp.relative_to(ROOT)}")
			failed += 1
		else:
			imp_text = imp.read_text(encoding="utf-8")
			if "compress/mode=0" not in imp_text:
				print(f"FAIL {imp.name}: compress/mode should be 0 (lossless)")
				failed += 1
			if "mipmaps/generate=false" not in imp_text:
				print(f"FAIL {imp.name}: mipmaps must be off")
				failed += 1
		try:
			w, h, ctype = _png_ihdr(full)
		except ValueError as err:
			print(f"FAIL {err}")
			failed += 1
			continue
		if (w, h) != (1680, 1040):
			print(f"FAIL {full.name}: size {w}x{h}, want 1680x1040")
			failed += 1
		if ctype != 2:
			print(f"FAIL {full.name}: color type {ctype}, want 2 (RGB opaque)")
			failed += 1

	if failed:
		print(f"FAILED {failed} check(s)")
		return 1
	print("PASS: biome full-art plates + dungeon_bg MIX/ADD loader")
	return 0


if __name__ == "__main__":
	sys.exit(main())
