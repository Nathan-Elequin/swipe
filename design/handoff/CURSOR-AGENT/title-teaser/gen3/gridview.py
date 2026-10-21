import sys, numpy as np
from PIL import Image, ImageDraw
def gridview(a, out, s=12):
    h, w = a.shape[:2]
    S = Image.new('RGBA', (w * s + 30, h * s + 30), (70, 70, 80, 255))
    im = Image.fromarray(a, 'RGBA').resize((w * s, h * s), Image.NEAREST)
    S.alpha_composite(im, (30, 30)); d = ImageDraw.Draw(S)
    for x in range(w + 1):
        d.line([(30 + x * s, 30), (30 + x * s, 30 + h * s)], fill=(255, 255, 255, 60) if x % 4 else (255, 80, 80, 160))
        if x % 4 == 0 and x < w: d.text((30 + x * s + 1, 2 + (x // 4 % 2) * 12), str(x), fill=(255, 255, 160))
    for y in range(h + 1):
        d.line([(30, 30 + y * s), (30 + w * s, 30 + y * s)], fill=(255, 255, 255, 60) if y % 4 else (255, 80, 80, 160))
        if y % 4 == 0 and y < h: d.text((2, 30 + y * s + 1), str(y), fill=(255, 255, 160))
    S.save(out)
