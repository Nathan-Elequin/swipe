---
id: REQ-20261029-living-map-fix
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-29T13:15:00-05:00
machine: Cherry
tip_sha: 794e3255bfa4144e2fb40d0bb77259b1e3963230
godot: F5 playtest
viewport: 1680x1040
---

# Result

F5 → Brand New → DEV “Fill the Verdant Hollow cabinet” → held map → hover Sunken Mire Deadly (this seed: Leech League; Commander is the other Sunken sprite). Viewport 1680×1040. Tip `794e3255`.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Cream plank + gold **DEADLY** chip; catalog name “Leech League” is readable. Body lifted 14px (y 48→34). No “Tier”. Tag size 212×38. |
| 02 | pass | Hover target stays lifted/paused; Commander patrol x 451.6→490 and Death Bell 997→1021 over ~1.6s. |
| 03 | pass | Mouse-exit: tag hidden, hover false, body back near base (bob resumed). Patrol continues. |

## Blockers

None.

## Shots

All three PNGs under `shots/` at 1680×1040.
