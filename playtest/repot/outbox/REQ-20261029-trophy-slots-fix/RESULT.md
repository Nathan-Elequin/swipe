---
id: REQ-20261029-trophy-slots-fix
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-29T13:15:00-05:00
machine: Cherry
tip_sha: 794e3255bfa4144e2fb40d0bb77259b1e3963230
godot: F5 playtest
viewport: 1680x1040
---

# Result

F5 → Middle Progress cabin → `_snap_to("hall")`. Campaign `fresh` then DEV `fill_b1` (Middle Progress save had all five cabinets already at 5/5, which would have hidden empty-glass). Viewport 1680×1040. Tip `794e3255`.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Verdant wreath sits in the glass top (`trophy_verdant_hollow.png`, 96×96). Pegs start below the trophy band; no hang past the case base. |
| 02 | pass | Hover swaps to `trophy_verdant_hollow_hover.png` gold rim-light at the same seat; hover plate “5 of 12 found”; texture_filter Nearest (1). |
| 03 | pass | After fill_b1 only: Ashen / Cinder / Shadow cases are empty glass (no trophy). Sunken shows peg silhouettes and no trophy (unlocked pool, collected 0). |
| 04 | pass | Banked b2 (Sunken Mire) via `debug_bank_matching(..., "b2")`. `trophy_sunken_mire.png` seated in the same top-glass slot (616,280 96×96). |

## Blockers

None. (Second biome was bankable in-session; not limited to one.)

## Shots

All four PNGs under `shots/` at 1680×1040.
