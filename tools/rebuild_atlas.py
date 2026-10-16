#!/usr/bin/env python3
"""Paste the new Crypt Classic hall tiles into the existing 0x72 atlas, slice by slice.

Run from the Godot project root (needs Pillow):   python tools/rebuild_atlas.py
Reads   assets/dungeon/tile_list.txt   (name x y w h per line - unchanged)
        assets/dungeon/atlas.png       (the current 512x512 atlas)
        assets/dungeon/tiles/<name>.png (new art; 4x ship size or 1x - both accepted)
Writes  assets/dungeon/atlas.png  (a copy of the old one is kept as assets/dungeon/atlas_0x72_backup.png)
Only slices that have a matching tiles/<name>.png are replaced; the rect is cleared first so no old pixels
show through transparent areas. Every other slice (monster frames, spikes, stairs, ...) is left as it was.
"""
import os, shutil, sys
from PIL import Image

ROOT = os.getcwd()
LIST = os.path.join(ROOT, 'assets/dungeon/tile_list.txt')
ATLAS = os.path.join(ROOT, 'assets/dungeon/atlas.png')
TILES = os.path.join(ROOT, 'assets/dungeon/tiles')
BACKUP = os.path.join(ROOT, 'assets/dungeon/atlas_0x72_backup.png')

def main():
    rects = {}
    for line in open(LIST, encoding='utf-8'):
        p = line.split()
        if len(p) == 5: rects[p[0]] = tuple(int(v) for v in p[1:])
    if not os.path.exists(BACKUP): shutil.copyfile(ATLAS, BACKUP)
    atlas = Image.open(ATLAS).convert('RGBA')
    done, skipped = [], []
    for fn in sorted(os.listdir(TILES)):
        if not fn.endswith('.png'): continue
        name = fn[:-4]
        if name not in rects: skipped.append(name); continue
        x, y, w, h = rects[name]
        im = Image.open(os.path.join(TILES, fn)).convert('RGBA')
        if im.size != (w, h):
            k = im.width // w
            if im.size != (w * k, h * k): sys.exit(f'{fn}: {im.size} is not a multiple of slice {w}x{h}')
            im = im.resize((w, h), Image.NEAREST)
        atlas.paste((0, 0, 0, 0), (x, y, x + w, y + h))
        atlas.alpha_composite(im, (x, y)); done.append(name)
    atlas.save(ATLAS)
    print(f'replaced {len(done)} slices in atlas.png:', ', '.join(done))
    if skipped: print('no slice in tile_list.txt for:', ', '.join(skipped))

if __name__ == '__main__':
    main()
