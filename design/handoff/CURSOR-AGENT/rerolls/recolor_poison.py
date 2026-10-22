"""Palette-swap the poison drip/burst frames onto the poison-lock green family.

No PixelLab calls. Exact colour swap, alpha and outline untouched.
Run from the repo root:  python design/handoff/CURSOR-AGENT/rerolls/recolor_poison.py
"""
import glob
from PIL import Image

# old olive/lime greens -> sage family anchored on #7dba7d / #8dcb8d (same as poison_lock.png)
SWAP = {
    "44702a": "3d6b3f",  # darkest shade
    "5a8a30": "5a965c",  # dark
    "6a9a3a": "6aa86c",  # mid-dark
    "8cbc48": "7dba7d",  # base
    "8dcb8d": "8dcb8d",  # base light (unchanged)
    "c4e07a": "b2e0b0",  # highlight
    "d8f0d0": "d8f0d0",  # sparkle (unchanged)
}


def rgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


MAP = {rgb(k): rgb(v) for k, v in SWAP.items()}
files = sorted(glob.glob("assets/ui/anim/poison_badge_drip_f*.png") + glob.glob("assets/ui/anim/poison_burst_f*.png"))
for f in files:
    im = Image.open(f).convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a and (r, g, b) in MAP:
                px[x, y] = MAP[(r, g, b)] + (a,)
    im.save(f)
    print("recoloured", f)
