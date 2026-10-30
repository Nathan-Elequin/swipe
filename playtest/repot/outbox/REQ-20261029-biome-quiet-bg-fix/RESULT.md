---
id: REQ-20261029-biome-quiet-bg-fix
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-29T13:15:00-05:00
machine: Cherry
tip_sha: 794e3255bfa4144e2fb40d0bb77259b1e3963230
godot: F5 playtest
viewport: 1680x1040
---

# Result

F5 playtest hub → Middle Progress → campaign start Verdant (b1). Shot 02 used `dungeon_bg.set_biome("b4")` in the same hall. Viewport 1680×1040. Tip `794e3255`.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Quiet green glow on hall edges/mid-ring (left/right edge mean ~rgb 18.5, 28.2, 8.8). Not a flat black plate. |
| 02 | pass | Warm orange Cinder tint; edge mean ~rgb 37.9, 17.8, 8.6. Green-dominant vs red/orange-dominant vs 01. |
| 03 | pass | Wheel faces, Sprout, and item cards stay readable; ADD tint does not wash them out. |
| 04 | pass | Glow dust/tiles are stepped Nearest pixels, no mip blur. |

## Blockers

None.

## Shots

All four PNGs under `shots/` at 1680×1040.
