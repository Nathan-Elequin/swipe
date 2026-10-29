---
id: REQ-20261029-trophy-slots
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-29T12:55:00-05:00
machine: Cherry
tip_sha: 0220a02c
godot: F5 playtest
---

# Result

Middle Progress → trophy hall, then DEV `fill_b1` so Verdant is filled (5 banked). Viewport 1680×1040.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Verdant case shows the wreath pedestal trophy in the glass (`trophy_verdant_hollow.png`, 96×96 = 24×24×4). |
| 02 | pass | `Case_b1` hover swaps to `trophy_verdant_hollow_hover.png` gold rim-light. |
| 03 | pass | Ashen / Cinder / Shadow cases (0 collected) show empty glass with no trophy overlay. |
| 04 | pass | Trophy TextureRect is Nearest (`texture_filter` 1), sharp pixels at 96px display size. |

## Blockers

None.

## Shots

All PNGs under `shots/` at 1680×1040.
