"""Pad keyword card rect 60px in 1680x1040 space, 2x nearest. Verify full card in crop."""
from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image

OUT = Path(__file__).resolve().parent / "shots"
TARGET_W, TARGET_H = 1680, 1040
PAD = 60


def nearest_resize(im: Image.Image, w: int, h: int) -> Image.Image:
    return im.resize((w, h), Image.NEAREST)


def process(stem: str, rect: tuple[float, float, float, float], raw_path: Path | None = None) -> dict:
    raw = raw_path or OUT / "_raw.png"
    im = Image.open(raw).convert("RGBA")
    full = nearest_resize(im, TARGET_W, TARGET_H)
    full_path = OUT / f"{stem}-full.png"
    full.save(full_path)

    x, y, w, h = rect
    cx0 = max(0, int(round(x)) - PAD)
    cy0 = max(0, int(round(y)) - PAD)
    cx1 = min(TARGET_W, int(round(x + w)) + PAD)
    cy1 = min(TARGET_H, int(round(y + h)) + PAD)
    crop = full.crop((cx0, cy0, cx1, cy1))
    crop2 = nearest_resize(crop, crop.size[0] * 2, crop.size[1] * 2)
    crop_path = OUT / f"{stem}.png"
    crop2.save(crop_path)

    # Card in crop-local 1680 space, then *2.
    card = (int(round(x)), int(round(y)), int(round(x + w)), int(round(y + h)))
    inside = card[0] >= cx0 and card[1] >= cy0 and card[2] <= cx1 and card[3] <= cy1
    info = {
        "stem": stem,
        "fb": im.size,
        "full": list(full.size),
        "rect": [x, y, w, h],
        "crop_src": [cx0, cy0, cx1, cy1],
        "crop2": list(crop2.size),
        "card_fully_inside": inside,
        "full_path": str(full_path.name),
        "crop_path": str(crop_path.name),
    }
    print(json.dumps(info))
    if not inside:
        raise SystemExit(f"{stem}: card not fully inside crop")
    return info


if __name__ == "__main__":
    stem = sys.argv[1]
    rect = tuple(float(v) for v in sys.argv[2].split(","))
    raw = Path(sys.argv[3]) if len(sys.argv) > 3 else None
    process(stem, rect, raw)
