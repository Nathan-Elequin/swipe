#!/usr/bin/env python3
"""Read-only check: facing idle frames whose opaque pixels touch the canvas edge.

Flags a frame when 2 or more opaque pixels sit on the left column, the right
column, or the top row. The bottom row is allowed (feet). Does not write PNGs.
"""

from __future__ import annotations

import sys
from collections import defaultdict
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
FACING_DIR = ROOT / "assets" / "dungeon" / "anim" / "facing"
REPORT = ROOT / "design" / "visual" / "qa-wheel-pass2" / "facing_edge_report.md"
EDGE_MIN = 2


def opaque_mask(path: Path) -> tuple[int, int, list[list[bool]]]:
    with Image.open(path) as im:
        rgba = im.convert("RGBA")
        w, h = rgba.size
        pix = rgba.load()
    rows: list[list[bool]] = []
    for y in range(h):
        rows.append([pix[x, y][3] > 0 for x in range(w)])
    return w, h, rows


def measure(path: Path) -> dict:
    w, h, rows = opaque_mask(path)
    min_x, min_y = w, h
    max_x, max_y = -1, -1
    left = right = top = 0
    for y, row in enumerate(rows):
        for x, on in enumerate(row):
            if not on:
                continue
            if x < min_x:
                min_x = x
            if y < min_y:
                min_y = y
            if x > max_x:
                max_x = x
            if y > max_y:
                max_y = y
            if x == 0:
                left += 1
            if x == w - 1:
                right += 1
            if y == 0:
                top += 1
    if max_x < 0:
        bbox = "empty"
    else:
        bbox = f"{min_x},{min_y} {max_x - min_x + 1}x{max_y - min_y + 1}"
    flagged = left >= EDGE_MIN or right >= EDGE_MIN or top >= EDGE_MIN
    return {
        "canvas": f"{w}x{h}",
        "bbox": bbox,
        "L": left,
        "R": right,
        "T": top,
        "flagged": flagged,
    }


def monster_id(path: Path) -> str:
    stem = path.stem
    marker = "_facing_idle_"
    if marker not in stem:
        return stem
    return stem.split(marker, 1)[0]


def frame_tag(path: Path) -> str:
    stem = path.stem
    marker = "_facing_idle_"
    if marker not in stem:
        return stem
    return stem.split(marker, 1)[1]


def join_frames(frames: list[tuple[str, dict]], key: str) -> str:
    values = [row[key] for _, row in frames]
    if len(set(values)) == 1:
        return str(values[0])
    return ", ".join(f"{tag} {row[key]}" for tag, row in frames)


def main() -> int:
    paths = sorted(FACING_DIR.glob("*_facing_idle_f*.png"))
    by_id: dict[str, list[tuple[str, dict]]] = defaultdict(list)
    for path in paths:
        by_id[monster_id(path)].append((frame_tag(path), measure(path)))

    ids = sorted(by_id)
    flagged_ids = [
        mid
        for mid in ids
        if any(row["flagged"] for _, row in by_id[mid])
    ]

    lines = [
        "# Facing edge report",
        "",
        "Read-only check from `tools/check_facing_edges.py`. Opaque means alpha > 0.",
        "A frame is flagged when the left column, right column, or top row has 2 or more opaque pixels. The bottom row is allowed (feet).",
        "",
        "rust_bucket frames have a flat grey backdrop that `_knock_backdrop` (`scripts/dungeon_art.gd` L446-479) clears before the portrait is shown. Edge hits on that backdrop are expected.",
        "",
        f"Ids scanned: {len(ids)}. Frames scanned: {len(paths)}. Flagged ids: {len(flagged_ids)}.",
        "",
        "Flagged: " + (", ".join(flagged_ids) if flagged_ids else "(none)"),
        "",
        "| id | canvas | bbox | L | R | T | flagged |",
        "| --- | --- | --- | --- | --- | --- | --- |",
    ]
    for mid in ids:
        frames = sorted(by_id[mid], key=lambda item: item[0])
        yes = any(row["flagged"] for _, row in frames)
        lines.append(
            "| {id} | {canvas} | {bbox} | {L} | {R} | {T} | {flag} |".format(
                id=mid,
                canvas=join_frames(frames, "canvas"),
                bbox=join_frames(frames, "bbox"),
                L=join_frames(frames, "L"),
                R=join_frames(frames, "R"),
                T=join_frames(frames, "T"),
                flag="yes" if yes else "no",
            )
        )
    lines.append("")
    REPORT.parent.mkdir(parents=True, exist_ok=True)
    REPORT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {REPORT.relative_to(ROOT)}")
    print(f"flagged {len(flagged_ids)} / {len(ids)}")
    for mid in flagged_ids:
        print(mid)
    return 0


if __name__ == "__main__":
    sys.exit(main())
