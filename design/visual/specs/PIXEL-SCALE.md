# Pixel scale: 16×16 art at 4× (decided 2026-10-11)

| Layer | Authored | On screen |
|---|---|---|
| Monsters, items, hand icons | 16×16 | 64×64 (4×) |
| Loot on pedestal, monster reveal | same 16×16 art | 128×128 (8×) |
| Nib portrait | 32×32 | 128×128 (4×) |
| UI 9-slices / buttons | 1 art px = 4 screen px | 4 px outlines |
| Logo | ~96×32 | 4× |
| Text | pixel fonts at whole multiples of their design size | no AA |

Why:
- 1680/4 = 420 and 1040/4 = 260, an exact virtual canvas. 3× doesn't divide 1040.
- The current shots already show portraits at about 64 px in about 76 px seats. The ring (r≈300) holds eight 64 px portraits once the name chips move to inspect.
- CC0 16 px bases (0x72 DungeonTileset II, Kenney Tiny Dungeon, Niji Extended) can be remixed for $0.
- 64 unique sprites (35 items + 29 monsters) at 16 px is a one-person job. 32 px means 4× the pixels per sprite.
- It keeps Jam's locked "16×16 creatures, nearest-neighbor" rule.

Godot 4.7: Default Texture Filter = Nearest; Snap 2D Transforms/Vertices to Pixel = on; keep canvas_items/expand at 1680×1040 with art at integer 4×/8× (or a 420×260 SubViewport shown at 4×). FontFile: antialiasing None, hinting None.
