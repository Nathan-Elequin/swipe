#!/usr/bin/env python3
"""Headless assert: Trophy Hall peg columns fit inside CASE_GLASS above the case base.

Mirrors scripts/biome_cabinets.gd peg_column_layout + glass height 121.
Exit 0 on pass, 1 on fail. No Godot required.
"""
from __future__ import annotations

import sys

CASE_GLASS = [
    [82, 68, 48, 121],
    [142, 68, 48, 121],
    [202, 68, 48, 121],
    [262, 68, 48, 121],
    [322, 68, 48, 121],
]
PX = 4.0
TROPHY_NATIVE = 24.0
TROPHY_PAD_TOP_NATIVE = 2.0
TROPHY_GAP_BELOW_NATIVE = 2.0
PEG_FIT_MAX = 6
PEG_SCALE_MAX = 0.55
CELL = (128.0, 160.0)


def trophy_reserved_height(glass_h: float, case_scale: float) -> float:
    s = max(case_scale, 0.001)
    tsize = TROPHY_NATIVE * s
    pad_top = TROPHY_PAD_TOP_NATIVE * s
    gap = TROPHY_GAP_BELOW_NATIVE * s
    return min(glass_h, pad_top + tsize + gap)


def peg_column_height(n: int, msize_y: float, gap_y: float, pad_top: float) -> float:
    if n <= 0:
        return pad_top
    return pad_top + float(n) * msize_y + float(n - 1) * gap_y


def peg_column_layout(clip_w: float, clip_h: float, cell, peg_count: int) -> dict:
    cell_x, cell_y = cell
    n_fit = max(1, min(max(peg_count, 1), PEG_FIT_MAX))
    max_s = min(PEG_SCALE_MAX, max(0.05, (clip_w - 6.0) / cell_x))
    max_w = max(8, int(cell_x * max_s))
    for gap in (2, 3, 4, 1, 0):
        for pad in (2, 3, 4, 1, 0):
            for w in range(max_w, 7, -1):
                h = max(1, int(round(cell_y * float(w) / cell_x)))
                need = peg_column_height(n_fit, float(h), float(gap), float(pad))
                if need > clip_h + 0.01:
                    continue
                return {
                    "msize": (float(w), float(h)),
                    "gap_y": float(gap),
                    "pad_top": float(pad),
                    "need": need,
                }
    raise AssertionError(f"no peg layout for clip=({clip_w},{clip_h}) n={n_fit}")


def main() -> int:
    failed = 0
    for i, g in enumerate(CASE_GLASS):
        if g[3] != 121:
            print(f"FAIL glass {i} height {g[3]} != 121")
            failed += 1
        gi_px_w = g[2] * PX
        gi_px_h = g[3] * PX
        # Painted case accent on cabinets_wall starts ~y=764; glass bottom must be <= 756.
        screen_bottom = (g[1] + g[3]) * PX
        if screen_bottom > 756.0 + 0.01:
            print(f"FAIL glass {i} screen bottom {screen_bottom} overlaps case base")
            failed += 1
        reserved = trophy_reserved_height(gi_px_h, PX)
        clips = {
            "trophy": (gi_px_w, max(0.0, gi_px_h - reserved)),
            "empty": (gi_px_w, gi_px_h),
        }
        for label, (cw, ch) in clips.items():
            lay = peg_column_layout(cw, ch, CELL, PEG_FIT_MAX)
            mw, mh = lay["msize"]
            if mw != int(mw) or mh != int(mh):
                print(f"FAIL peg int {label} {i}: {lay['msize']}")
                failed += 1
            if lay["need"] > ch + 0.01:
                print(f"FAIL pegs fit {label} {i}: need {lay['need']} > clip {ch}")
                failed += 1
            clip_top = reserved if label == "trophy" else 0.0
            peg_bottom = clip_top + lay["need"]
            if peg_bottom > gi_px_h + 0.01:
                print(f"FAIL peg above base {label} {i}: bottom {peg_bottom} > glass {gi_px_h}")
                failed += 1
            else:
                print(
                    f"OK {label} case {i}: msize={lay['msize']} gap={lay['gap_y']} "
                    f"pad={lay['pad_top']} bottom={peg_bottom}/{gi_px_h}"
                )
    if failed:
        print(f"TROPHY_PEGS_FIT_FAIL ({failed})")
        return 1
    print("TROPHY_PEGS_FIT_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
