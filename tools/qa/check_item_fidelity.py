#!/usr/bin/env python3
"""Assert item-fidelity revision2 approved art is installed exactly.

Stdlib only. For each of the six catalog ids:

- live ``assets/dungeon/items/<id>.png`` SHA-256 matches approved ``export64/<id>_64.png``
- approved 64 equals nearest-neighbor 4× of approved ``native16/<id>_16.png`` (decoded RGBA)
- native is 16×16, export/live are 64×64, color type RGBA, has transparent pixels
- ``scripts/dungeon_art.gd`` ITEM_PNG still maps id → that live path

Exit 0 on pass; 1 on failure. Prints one line per item plus a summary.
"""

from __future__ import annotations

import hashlib
import re
import struct
import sys
import zlib
from pathlib import Path

IDS = (
    "venom_veins",
    "kiss_of_death",
    "shardplate",
    "swift_sneaks",
    "love_potion",
    "tesla_coil",
)

PNG_SIG = b"\x89PNG\r\n\x1a\n"


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for candidate in (here.parents[2], Path.cwd()):
        if (candidate / "project.godot").is_file():
            return candidate
    return here.parents[2]


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_rgba(path: Path) -> tuple[int, int, list[bytes]]:
    data = path.read_bytes()
    if data[:8] != PNG_SIG:
        raise ValueError(f"{path}: missing PNG signature")
    pos = 8
    width = height = None
    bit_depth = color_type = None
    idat = b""
    while pos + 8 <= len(data):
        length = int.from_bytes(data[pos : pos + 4], "big")
        pos += 4
        ctype = data[pos : pos + 4]
        pos += 4
        chunk = data[pos : pos + length]
        pos += length + 4
        if ctype == b"IHDR":
            width, height, bit_depth, color_type, _comp, _filt, inter = struct.unpack(
                ">IIBBBBB", chunk
            )
            if bit_depth != 8 or color_type not in (2, 6) or inter != 0:
                raise ValueError(
                    f"{path}: unsupported PNG (bit={bit_depth} color={color_type} inter={inter})"
                )
        elif ctype == b"IDAT":
            idat += chunk
        elif ctype == b"IEND":
            break
    if width is None or height is None or color_type is None:
        raise ValueError(f"{path}: incomplete PNG")
    raw = zlib.decompress(idat)
    bpp = 4 if color_type == 6 else 3
    stride = width * bpp
    rows: list[bytes] = []
    i = 0
    prev = bytearray(stride)
    for _y in range(height):
        ftype = raw[i]
        i += 1
        row = bytearray(raw[i : i + stride])
        i += stride
        if ftype == 0:
            pass
        elif ftype == 1:
            for x in range(stride):
                left = row[x - bpp] if x >= bpp else 0
                row[x] = (row[x] + left) & 255
        elif ftype == 2:
            for x in range(stride):
                row[x] = (row[x] + prev[x]) & 255
        elif ftype == 3:
            for x in range(stride):
                left = row[x - bpp] if x >= bpp else 0
                row[x] = (row[x] + ((left + prev[x]) // 2)) & 255
        elif ftype == 4:
            for x in range(stride):
                a = row[x - bpp] if x >= bpp else 0
                b = prev[x]
                c = prev[x - bpp] if x >= bpp else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                row[x] = (row[x] + pr) & 255
        else:
            raise ValueError(f"{path}: bad filter type {ftype}")
        if bpp == 3:
            rgba = bytearray()
            for x in range(0, stride, 3):
                rgba += row[x : x + 3] + b"\xff"
            rows.append(bytes(rgba))
        else:
            rows.append(bytes(row))
        prev = bytearray(row)
    return width, height, rows


def nearest_scale(rows: list[bytes], w: int, h: int, scale: int) -> list[bytes]:
    out: list[bytes] = []
    for y in range(h):
        src = rows[y]
        big = bytearray()
        for x in range(w):
            px = src[x * 4 : (x + 1) * 4]
            big += px * scale
        line = bytes(big)
        for _ in range(scale):
            out.append(line)
    return out


def has_transparency(rows: list[bytes]) -> bool:
    for row in rows:
        for a in range(3, len(row), 4):
            if row[a] < 255:
                return True
    return False


def item_png_path(dungeon_art: str, item_id: str) -> str | None:
    # Match `"id": "res://assets/dungeon/items/id.png",` inside ITEM_PNG.
    pattern = re.compile(
        rf'"{re.escape(item_id)}"\s*:\s*"(res://assets/dungeon/items/{re.escape(item_id)}\.png)"'
    )
    match = pattern.search(dungeon_art)
    return match.group(1) if match else None


def main() -> int:
    root = repo_root()
    approved = root / "design/visual/item-fidelity/approved"
    native_dir = approved / "native16"
    export_dir = approved / "export64"
    live_dir = root / "assets/dungeon/items"
    dungeon_art = (root / "scripts/dungeon_art.gd").read_text(encoding="utf-8")

    failures: list[str] = []
    for item_id in IDS:
        native = native_dir / f"{item_id}_16.png"
        export = export_dir / f"{item_id}_64.png"
        live = live_dir / f"{item_id}.png"
        for path in (native, export, live):
            if not path.is_file():
                failures.append(f"{item_id}: missing {path.relative_to(root)}")
                continue
        if not native.is_file() or not export.is_file() or not live.is_file():
            continue

        mapped = item_png_path(dungeon_art, item_id)
        expected_res = f"res://assets/dungeon/items/{item_id}.png"
        if mapped != expected_res:
            failures.append(
                f"{item_id}: ITEM_PNG maps to {mapped!r}, expected {expected_res!r}"
            )

        live_hash = sha256_file(live)
        export_hash = sha256_file(export)
        if live_hash != export_hash:
            failures.append(
                f"{item_id}: live SHA {live_hash[:12]} != approved64 {export_hash[:12]}"
            )

        nw, nh, nrows = read_rgba(native)
        ew, eh, erows = read_rgba(export)
        lw, lh, lrows = read_rgba(live)
        if (nw, nh) != (16, 16):
            failures.append(f"{item_id}: native size {nw}x{nh}, want 16x16")
        if (ew, eh) != (64, 64):
            failures.append(f"{item_id}: export size {ew}x{eh}, want 64x64")
        if (lw, lh) != (64, 64):
            failures.append(f"{item_id}: live size {lw}x{lh}, want 64x64")
        if not has_transparency(nrows):
            failures.append(f"{item_id}: native16 has no transparent pixels")

        scaled = nearest_scale(nrows, nw, nh, 4)
        if scaled != erows:
            failures.append(f"{item_id}: export64 is not exact nearest 4x of native16")
        if scaled != lrows:
            failures.append(f"{item_id}: live PNG is not exact nearest 4x of native16")

        print(
            f"OK {item_id}: live==approved64 sha256={live_hash[:16]}… "
            f"nearest4x match, transparent RGBA, ITEM_PNG={mapped}"
        )

    if failures:
        print("FAIL")
        for line in failures:
            print(f"  - {line}")
        return 1
    print(f"PASS check_item_fidelity ({len(IDS)} items)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
