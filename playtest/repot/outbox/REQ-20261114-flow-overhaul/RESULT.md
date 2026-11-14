---
id: REQ-20261114-flow-overhaul
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T00:30:00-06:00
machine: Cherry
tip_sha: a40c1bb1
godot: F5 playtest via godot-mcp, viewport 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` via godot-mcp. Rope poses used `open_exit` + `apply_exit_mode`. Hall poses used `show_menu("hall")` + Homecoming / banked uniques.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Dead portal + mist, no swirl; satchel_floor peeks + mouth shadow; strip 9-slice; unique stars; 2/5 arch lights. `01-dead-portal-haul.png`. |
| 02 | pass | 8-frame fizzle burst `02-dead-portal-fizzle_f00–f07`. Climb still present. |
| 03 | pass | Particle vortex in gate; 5/5 arch lights; Next: Crystal Cavern line. `03-alive-portal.png`. |
| 04 | captured | Hall + Nib after relocate; Developer Test strip visible. `04-first-return-gate.png`. |
| 05 | fail | Intended empty-handed first return; board already had items and Nib was mid unpack line. `05-first-return-empty.png`. |
| 06 | captured | Unpack burst frames copied to `06-first-return-unpack.png`. |
| 07 | captured | First-light Nib line + lever-side glow. `07-first-light-pause.png`. |
| 08 | captured | Floor lever right of board (faint vs ready mixed with 5-light seed). `08-floor-lever-faint.png`. |
| 09 | captured | Lever READY with 5 banked. `09-floor-lever-ready.png`. |

## Pass criteria

- 1680×1040.
- No player-facing Tier/ATK on rope stills.
- Dead portal plate and satchel_floor read on 01/03.
- First-return empty branch did not isolate 0 banked.

## Blockers

None for rope stills. Empty first-return needs a true fresh save before Homecoming.

## Shots

All PNGs under `shots/`.
