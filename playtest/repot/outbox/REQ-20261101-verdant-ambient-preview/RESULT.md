---
id: REQ-20261101-verdant-ambient-preview
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-01T16:20:00-05:00
machine: Cherry
tip_sha: dda565ce
godot: F5 playtest (godot-mcp) — F10 off/on stills
viewport: 1680x1040
---

# Result

| id | verdict | note |
|----|---------|------|
| 01 | pass | F10 off, 1680×1040 fight: dry hall, no motes/haze/shaft. Pair baseline vs 02. |
| 02 | pass | F10 on, same fight: darker damp vignette, motes, left shaft slot. Wheel, hotbar, Zombie plate stay clear. |
| 03 | pass | Campaign b1 seating/draft, ambient on. Wheel readable; empty hotbar (pre-grant). |
| 04 | pass | Live `wheel_view.spinning` + spores/fireflies `emitting`; kit stayed in the hall. Committed PNG is a post-land rest frame (spin tween uses ignore-time-scale; mid-tween file was not held). |
| c1 | skip | Movie Maker not run (one Godot process). |
| c2 | skip | Same. |

## Blockers

None for stills.

## Shots

All PNGs under `shots/` using the request filenames (1680×1040).
