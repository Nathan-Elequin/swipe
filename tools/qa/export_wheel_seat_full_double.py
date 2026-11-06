#!/usr/bin/env python3
"""Export wheel seats at native 48 (Weak/Tough) / 64 (Deadly) from facing.

Does not touch facing sources. Archives the previous 24/32 seat exports first.
1:1 byte-copy when facing canvas already matches the seat size. Otherwise
nearest-neighbor onto the seat canvas (64→48 Tough/Weak, 48→64 phoenix_egg).
Hard alpha 0/255. Zero PixelLab gens.

Also nearest-doubles the A who-ring hoops: 32→64 Weak, 40→80 Deadly.
"""
from __future__ import annotations

import json
import shutil
import struct
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
CAT = ROOT / "data" / "catalog.json"
FACING = ROOT / "assets" / "dungeon" / "anim" / "facing"
WHEEL = ROOT / "assets" / "dungeon" / "anim" / "wheel"
ANIM = ROOT / "assets" / "ui" / "anim"
ARCHIVE = ROOT / "design" / "archive" / "pass-wheel-24-32-seats"
MANIFEST = ROOT / "design" / "archive" / "pass-wheel-pre-facing" / "NEW-manifest-v2.json"

WEAK_SEAT = 48
DEADLY_SEAT = 64
WEAK_RING = 64
DEADLY_RING = 80


def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"not a png: {path}")
    w, h = struct.unpack(">II", data[16:24])
    return int(w), int(h)


def seat_native_px_for_tier(tier: int) -> int:
    return DEADLY_SEAT if int(tier) >= 3 else WEAK_SEAT


def snap_alpha(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                px[x, y] = (0, 0, 0, 0)
            elif a == 255:
                continue
            else:
                px[x, y] = (r, g, b, 255) if a >= 128 else (0, 0, 0, 0)
    return im


def fit_facing(src: Image.Image, seat: int) -> Image.Image:
    src = src.convert("RGBA")
    if src.size == (seat, seat):
        return snap_alpha(src)
    scaled = src.resize((seat, seat), Image.Resampling.NEAREST)
    return snap_alpha(scaled)


def save_png(im: Image.Image, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    im.save(dest, "PNG")


def archive_current_seats() -> int:
    ARCHIVE.mkdir(parents=True, exist_ok=True)
    n = 0
    for p in sorted(WHEEL.glob("*_wheel_*.png")):
        dest = ARCHIVE / p.name
        shutil.copy2(p, dest)
        n += 1
    readme = ARCHIVE / "README.md"
    readme.write_text(
        """# pass-wheel-24-32-seats

Archive of facing-derived wheel seats **before** the full-double pass (2026-11-06).

Those seats were native 24 (Weak/Tough) and 32 (Deadly), drawn at `WHEEL_SPRITE_SCALE` 2 → 48 / 64 on screen.

Live seats after this pass: native **48** Weak/Tough and **64** Deadly, still at scale 2 → 96 / 128 on screen. Facing sources under `assets/dungeon/anim/facing/` were not modified.

Restore:

```bash
cp design/archive/pass-wheel-24-32-seats/<id>_wheel_*.png assets/dungeon/anim/wheel/
```
""",
        encoding="utf-8",
    )
    return n


def export_seats() -> dict:
    cat = json.loads(CAT.read_text(encoding="utf-8"))
    pack_ids = {m["id"] for m in json.loads(MANIFEST.read_text(encoding="utf-8"))["monsters"]}
    methods: list[dict] = []
    for m in cat["monsters"]:
        mid = str(m.get("id", "")).strip()
        if mid not in pack_ids:
            continue
        tier = int(m.get("tier") or 0)
        seat = seat_native_px_for_tier(tier)
        frames: list[Path] = []
        i = 0
        while True:
            p = FACING / f"{mid}_facing_idle_f{i}.png"
            if not p.is_file():
                break
            frames.append(p)
            i += 1
        if not frames:
            print(f"FAIL no facing {mid}")
            continue
        fw, fh = png_size(frames[0])
        if fw == seat and fh == seat:
            method = f"copy_facing_{fw}"
        else:
            method = f"nearest_{fw}to{seat}"
        idle_out: list[Path] = []
        for fi, src_path in enumerate(frames):
            dest = WHEEL / f"{mid}_wheel_idle_f{fi}.png"
            if method.startswith("copy_"):
                shutil.copy2(src_path, dest)
            else:
                im = Image.open(src_path)
                save_png(fit_facing(im, seat), dest)
            idle_out.append(dest)
        shutil.copy2(idle_out[0], WHEEL / f"{mid}_wheel_base.png")
        shutil.copy2(idle_out[0], WHEEL / f"{mid}_wheel_breathe_f0.png")
        breathe1 = WHEEL / f"{mid}_wheel_breathe_f1.png"
        if len(idle_out) > 1 or breathe1.is_file():
            shutil.copy2(idle_out[1] if len(idle_out) > 1 else idle_out[0], breathe1)
        methods.append(
            {
                "id": mid,
                "tier": tier,
                "seat_px": seat,
                "facing": f"{fw}x{fh}",
                "frames": len(frames),
                "method": method,
            }
        )
    (ARCHIVE / "NEW-manifest-full-double.json").write_text(
        json.dumps(
            {
                "rule": "seat_px = 64 if catalog tier>=3 (Deadly) else 48",
                "archive_old_to": "design/archive/pass-wheel-24-32-seats/",
                "monsters": methods,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    return {"count": len(methods), "methods": methods}


def resize_ring(src: Path, dest: Path, want: int) -> None:
    im = Image.open(src).convert("RGBA")
    if im.size == (want, want):
        save_png(snap_alpha(im), dest)
        return
    out = im.resize((want, want), Image.Resampling.NEAREST)
    save_png(snap_alpha(out), dest)


def export_rings() -> None:
    # Double the A hoop in place (32→64, 40→80). Source is the live file
    # before overwrite; read into memory first.
    weak_src = [ANIM / f"seat_target_ghost_f{i}.png" for i in range(4)]
    weak_src.append(ANIM / "seat_target_locked.png")
    deadly_src = [ANIM / f"seat_target_ghost_deadly_f{i}.png" for i in range(4)]
    deadly_src.append(ANIM / "seat_target_locked_deadly.png")
    weak_imgs = [(p, Image.open(p).convert("RGBA")) for p in weak_src]
    deadly_imgs = [(p, Image.open(p).convert("RGBA")) for p in deadly_src]
    ring_arch = ARCHIVE / "who-rings-32-40"
    ring_arch.mkdir(parents=True, exist_ok=True)
    for p, im in weak_imgs + deadly_imgs:
        im.save(ring_arch / p.name, "PNG")
    for p, im in weak_imgs:
        save_png(snap_alpha(im.resize((WEAK_RING, WEAK_RING), Image.Resampling.NEAREST)), p)
    for p, im in deadly_imgs:
        save_png(snap_alpha(im.resize((DEADLY_RING, DEADLY_RING), Image.Resampling.NEAREST)), p)


def main() -> int:
    n_arch = archive_current_seats()
    print(f"archived {n_arch} seat pngs → {ARCHIVE}")
    info = export_seats()
    by = {}
    for row in info["methods"]:
        by[row["method"]] = by.get(row["method"], 0) + 1
    print(f"exported seats {info['count']} methods={by}")
    export_rings()
    print(f"who-rings {WEAK_RING}n Weak / {DEADLY_RING}n Deadly")
    return 0


if __name__ == "__main__":
    sys.exit(main())
