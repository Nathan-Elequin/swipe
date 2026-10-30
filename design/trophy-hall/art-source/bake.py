#!/usr/bin/env python3
"""Bake hem masks, grey crests, hatch, and dumbwaiter tab for Trophy Hall.

PixelLab keeps the painted sprites; this script only derives the bake rows in
ASSET-LIST § bake / PIXELLAB-COMMISSION "Not PixelLab". Safe to re-run.
"""
from __future__ import annotations

import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CAB = ROOT / "assets" / "dungeon" / "home" / "cabinets"
HALL = ROOT / "assets" / "dungeon" / "home" / "hall"
SRC_1X = Path(__file__).resolve().parent / "1x"


def _png_rgba(path: Path):
    data = path.read_bytes()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    # Minimal decoder via Pillow when present; else skip.
    try:
        from PIL import Image
    except ImportError as e:
        raise SystemExit("Pillow required for bake.py") from e
    im = Image.open(path).convert("RGBA")
    return im


def write_import(png: Path) -> None:
    rel = str(png.relative_to(ROOT)).replace("\\", "/")
    uid_path = png.with_suffix(png.suffix + ".import")
    body = f"""[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bake_{png.stem}"
path="res://.godot/imported/{png.name}-bake.ctex"
metadata={{
"vram_texture": false
}}

[deps]

source_file="res://{rel}"
dest_files=["res://.godot/imported/{png.name}-bake.ctex"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""
    uid_path.write_text(body)


def hem_mask(sheet: Path, out: Path, bottom_rows: int = 6) -> None:
    from PIL import Image
    im = _png_rgba(sheet)
    w, h = im.size
    out_im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    px = im.load()
    opx = out_im.load()
    # Find bottom-most opaque rows and mask them white.
    opaque_rows = []
    for y in range(h - 1, -1, -1):
        if any(px[x, y][3] > 0 for x in range(w)):
            opaque_rows.append(y)
        if len(opaque_rows) >= bottom_rows:
            break
    for y in opaque_rows:
        for x in range(w):
            a = px[x, y][3]
            if a:
                opx[x, y] = (255, 255, 255, a)
    out_im.save(out)
    write_import(out)


def grey_crest(src: Path, out: Path) -> None:
    from PIL import Image
    im = _png_rgba(src)
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            luma = int(0.299 * r + 0.587 * g + 0.114 * b)
            luma = max(0, int(luma * 0.85))
            px[x, y] = (luma, luma, luma, a)
    im.save(out)
    write_import(out)


def hatch(out: Path, size: int = 16) -> None:
    from PIL import Image
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = im.load()
    pitch = 3
    col = (201, 206, 214, 140)  # #C9CED6 @ ~55%
    for y in range(size):
        for x in range(size):
            if (x + y) % pitch == 0:
                px[x, y] = col
    # Upscale ×4 nearest for shipped size
    im4 = im.resize((size * 4, size * 4), Image.NEAREST)
    im4.save(out)
    write_import(out)


def tab(out: Path) -> None:
    from PIL import Image
    im = Image.new("RGBA", (3, 4), (0, 0, 0, 0))
    px = im.load()
    ink = (30, 18, 12, 255)
    white = (255, 255, 255, 255)
    for y in range(4):
        for x in range(3):
            edge = x in (0, 2) or y in (0, 3)
            px[x, y] = ink if edge else white
    im4 = im.resize((12, 16), Image.NEAREST)
    im4.save(out)
    write_import(out)


def main() -> None:
    SRC_1X.mkdir(parents=True, exist_ok=True)
    HALL.mkdir(parents=True, exist_ok=True)
    for shape in ("rect", "arch", "spires"):
        sheet = CAB / f"case_sheet_{shape}.png"
        if sheet.exists():
            hem_mask(sheet, CAB / f"case_sheet_{shape}_hem.png")
    for biome in (
        "verdant_hollow",
        "crystal_cavern",
        "ashen_crypt",
        "cinder_forge",
        "shadow_abyss",
    ):
        src = CAB / f"trophy_{biome}.png"
        if src.exists():
            grey_crest(src, CAB / f"trophy_{biome}_grey.png")
    hatch(CAB / "item_seen_hatch.png")
    tab(HALL / "dumbwaiter_tab.png")
    print("bake.py: done")


if __name__ == "__main__":
    main()
