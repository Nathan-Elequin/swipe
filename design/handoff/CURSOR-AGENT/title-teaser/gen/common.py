"""Shared helpers for title-teaser strips. 420x260 native, seamless on X.
Draw on a 3-tile-wide canvas, every element repeated at +0/+420/+840, crop the middle tile.
No anti-aliasing anywhere: only ImageDraw polygons/rects/points and integer maths."""
from PIL import Image, ImageDraw
import math, random
W, H, FLOOR = 420, 260, 161
INK = '#100e0c'
GOLD = '#ffd84a'      # Torchlit bait gold (locked)
TORCH = '#f09a34'
EMBER = '#d0644a'
CREAM = '#fff3d6'

class Strip:
    def __init__(self, bg):
        self.im = Image.new('RGB', (W * 3, H), bg)
        self.d = ImageDraw.Draw(self.im)
    # every call takes x in tile space (0..419, may overflow) and is replicated 3x
    def poly(self, pts, fill, outline=None):
        for k in range(3):
            self.d.polygon([(x + W * k, y) for x, y in pts], fill=fill, outline=outline)
    def rect(self, x0, y0, x1, y1, fill, outline=None):
        for k in range(3):
            self.d.rectangle([x0 + W * k, y0, x1 + W * k, y1], fill=fill, outline=outline)
    def px(self, x, y, fill):
        for k in range(3):
            self.d.point((x + W * k, y), fill=fill)
    def hline(self, x0, x1, y, fill):
        self.rect(x0, y, x1, y, fill)
    def vline(self, x, y0, y1, fill):
        self.rect(x, y0, x, y1, fill)
    def ellipse(self, x0, y0, x1, y1, fill, outline=None):
        for k in range(3):
            self.d.ellipse([x0 + W * k, y0, x1 + W * k, y1], fill=fill, outline=outline)
    def get(self, x, y):
        return self.im.getpixel(((x % W) + W, y))
    def tile(self):
        return self.im.crop((W, 0, 2 * W, H))

def wave(x, terms):
    """periodic height: terms = [(amp, cycles_per_tile, phase)] -> seamless on X"""
    return sum(a * math.sin(2 * math.pi * c * x / W + p) for a, c, p in terms)

def stepped_glow(strip, cx, cy, radii, fills, mask_fn=None):
    """flat concentric rings (largest first), clipped to a predicate on (x,y) -> True to paint."""
    for r, f in zip(radii, fills):
        for y in range(max(0, cy - r), min(H, cy + r + 1)):
            for x in range(cx - r, cx + r + 1):
                if (x - cx) ** 2 + ((y - cy) * 1.0) ** 2 <= r * r:
                    if mask_fn is None or mask_fn(x, y):
                        strip.px(x, y, f)

def ship(img, path_native, path_shipped):
    img.save(path_native, optimize=True)
    img.resize((img.width * 4, img.height * 4), Image.NEAREST).save(path_shipped, optimize=True)

IMPORT = """[remap]

importer="texture"
type="CompressedTexture2D"
path="res://.godot/imported/{name}-teaser.ctex"
metadata={{
"vram_texture": false
}}

[deps]

source_file="res://assets/dungeon/title/{name}"
dest_files=["res://.godot/imported/{name}-teaser.ctex"]

[params]

compress/mode=0
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=false
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""
