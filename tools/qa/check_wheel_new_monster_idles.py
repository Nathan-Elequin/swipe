#!/usr/bin/env python3
"""New-monster wheel idle wiring: distinct authored frames + loader path rules.

Cloud-safe (no Godot). Proves:
1. Target ids have facing idle f0–f3 with distinct pixel buffers, OR an
   existing wheel idle strip with distinct buffers (anvil).
2. wheel_frames_all fallback must not collapse to a single facing_idle_f0
   when a multi-frame facing strip exists — mirrors scripts/dungeon_art.gd.

Does not invent frames. Does not require Godot playback.
"""
from __future__ import annotations

import struct
import sys
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FACING = ROOT / "assets" / "dungeon" / "anim" / "facing"
WHEEL = ROOT / "assets" / "dungeon" / "anim" / "wheel"
DUNGEON_ART = ROOT / "scripts" / "dungeon_art.gd"

# New / recently locked monsters Nathan called out for wheel idle motion.
NEW_IDS = (
	"imp",
	"quicksand_crab",
	"huntsman",
	"phantom",
	"collector",
	"glass_asp",
	"anvil",
)

# Established controls that must keep multi-frame wheel strips.
CONTROL_IDS = (
	"skeleton",
	"leech_league",
	"hollow",  # Twins
	"goblin",
)


def decode_png_rgba_bytes(path: Path) -> bytes:
	data = path.read_bytes()
	if data[:8] != b"\x89PNG\r\n\x1a\n":
		raise ValueError(f"not png: {path}")
	pos = 8
	width = height = bit_depth = color_type = None
	idat = b""
	while pos < len(data):
		length = struct.unpack(">I", data[pos : pos + 4])[0]
		ctype = data[pos + 4 : pos + 8]
		chunk = data[pos + 8 : pos + 8 + length]
		pos += 12 + length
		if ctype == b"IHDR":
			width, height, bit_depth, color_type, _, _, _ = struct.unpack(
				">IIBBBBB", chunk
			)
		elif ctype == b"IDAT":
			idat += chunk
		elif ctype == b"IEND":
			break
	if bit_depth != 8:
		raise ValueError(f"bit_depth {bit_depth} at {path}")
	bpp = {2: 3, 6: 4, 0: 1, 4: 2, 3: 1}[int(color_type)]
	raw = zlib.decompress(idat)
	stride = int(width) * bpp
	out = bytearray()
	i = 0
	prev = bytearray(stride)

	def paeth(a: int, b: int, c: int) -> int:
		p = a + b - c
		pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
		if pa <= pb and pa <= pc:
			return a
		if pb <= pc:
			return b
		return c

	for _y in range(int(height)):
		filt = raw[i]
		i += 1
		row = bytearray(raw[i : i + stride])
		i += stride
		if filt == 1:
			for x in range(stride):
				left = row[x - bpp] if x >= bpp else 0
				row[x] = (row[x] + left) & 255
		elif filt == 2:
			for x in range(stride):
				row[x] = (row[x] + prev[x]) & 255
		elif filt == 3:
			for x in range(stride):
				left = row[x - bpp] if x >= bpp else 0
				row[x] = (row[x] + ((left + prev[x]) // 2)) & 255
		elif filt == 4:
			for x in range(stride):
				a = row[x - bpp] if x >= bpp else 0
				b = prev[x]
				c = prev[x - bpp] if x >= bpp else 0
				row[x] = (row[x] + paeth(a, b, c)) & 255
		elif filt != 0:
			raise ValueError(f"filter {filt} at {path}")
		out.extend(row)
		prev = row
	return bytes(out)


def strip_paths(folder: Path, stem: str) -> list[Path]:
	out: list[Path] = []
	for i in range(0, 8):
		p = folder / f"{stem}_f{i}.png"
		if not p.is_file():
			break
		out.append(p)
	return out


def distinct_count(paths: list[Path]) -> int:
	return len({decode_png_rgba_bytes(p) for p in paths})


def resolved_strip(mid: str) -> tuple[str, list[Path]]:
	"""Mirror monster_wheel_frames preference order (files on disk only)."""
	wheel_idle = strip_paths(WHEEL, f"{mid}_wheel_idle")
	if wheel_idle:
		return "wheel_idle", wheel_idle
	breathe: list[Path] = []
	for name in (f"{mid}_wheel_breathe_f0.png", f"{mid}_wheel_breathe_f1.png"):
		p = WHEEL / name
		if p.is_file():
			breathe.append(p)
	if breathe:
		return "wheel_breathe", breathe
	base = WHEEL / f"{mid}_wheel_base.png"
	wheel_one = [base] if base.is_file() else []
	face = strip_paths(FACING, f"{mid}_facing_idle")
	if (not wheel_one or len(wheel_one) == 1) and len(face) > len(wheel_one):
		return "facing_idle", face
	if wheel_one:
		return "wheel_base", wheel_one
	if face:
		return "facing_idle", face
	return "missing", []


def main() -> int:
	failed = 0
	src = DUNGEON_ART.read_text(encoding="utf-8")
	# Guard against regressing to the single-f0 seat freeze.
	if 'd[str(id)] = [face]' in src or "d[str(id)] = [face]" in src:
		print("FAIL dungeon_art.gd still assigns single-frame [face] in wheel_frames_all")
		failed += 1
	if "_facing_strip" not in src or "face.size() > out.size()" not in src:
		print("FAIL dungeon_art.gd missing facing-strip fallback in monster_wheel_frames")
		failed += 1

	for mid in NEW_IDS + CONTROL_IDS:
		kind, paths = resolved_strip(mid)
		if not paths:
			print(f"FAIL {mid} no idle strip on disk")
			failed += 1
			continue
		n = distinct_count(paths)
		need_motion = mid != "anvil" or kind == "wheel_idle"
		# Anvil facing is intentionally duplicated; its wheel_idle must animate.
		if mid == "anvil" and kind != "wheel_idle":
			print(f"FAIL anvil resolved {kind} instead of wheel_idle")
			failed += 1
		if need_motion and len(paths) < 2:
			print(f"FAIL {mid} resolved {kind} with {len(paths)} frame(s) — seats would freeze")
			failed += 1
		elif need_motion and n < 2:
			print(
				f"FAIL {mid} {kind}: {len(paths)} files but only {n} distinct pixel buffer(s) — "
				"authored motion missing; Pixel must regenerate (do not invent frames)"
			)
			failed += 1
		else:
			print(
				f"PASS {mid} via {kind}: files={len(paths)} distinct_pixels={n}"
			)

	# Named examples from the report.
	for mid in ("imp", "quicksand_crab"):
		kind, paths = resolved_strip(mid)
		if kind != "facing_idle" or len(paths) < 4 or distinct_count(paths) < 4:
			print(f"FAIL {mid} expected facing_idle 4 distinct, got {kind} n={len(paths)}")
			failed += 1

	print(f"check_wheel_new_monster_idles failed={failed}")
	return 1 if failed else 0


if __name__ == "__main__":
	sys.exit(main())
