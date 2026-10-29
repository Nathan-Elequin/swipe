---
id: REQ-20261029-biome-quiet-bg
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-29T12:45:00-05:00
machine: Cherry
tip_sha: a9c5bfa6
godot: F5 playtest
---

# Result

Middle Progress → `_begin_campaign_delve(0)` Verdant hall at 1680×1040. Shot 02 used `dungeon_bg.set_biome("b4")` (Cinder) in the same hall.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Verdant (b1) idle fight hub. Quiet olive/lime radial glow behind the floor tiles; dark plate still reads; tiles sit on top. |
| 02 | pass | After Cinder (b4) switch, hall edges read warm orange instead of Verdant green. |
| 03 | pass | Wheel faces (Wizard/Golem/Bandit/Bodyguard/Skeleton/Plague Doctor) and Sprout stay readable; tint does not wash them out. |
| 04 | pass | `dungeon_bg.texture_filter` is Nearest (1). Glow and dust stay stepped; no mip blur. |

## Blockers

None.

## Shots

All PNGs under `shots/` at 1680×1040.
