---
id: REQ-20261114-ladder-wipe
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T00:30:00-06:00
machine: Cherry
tip_sha: pending-commit
godot: F5 playtest via godot-mcp, viewport 1680x1040
branch: playtest/latest
---

# Result

Music key from climb/exterior/keyring dumps: `cabin`.

| id | verdict | note |
|----|---------|------|
| 01 | fail | 12-frame burst `01-wipe-cover_f00–f11` did not show ClimbWipe (wipe_vis stayed false; `_do_climb` overlapped leftover splash). Canonical `01-wipe-cover.png` is a mid burst frame, not a solid upward wipe. |
| 02 | pass | Empty night exterior, Sprout hidden. `02-empty-exterior.png` (from walk burst f00). No horizontal slide. |
| 03 | pass | Current Sprout on the path from the left (`sprout_run` pose via `debug_pose("walk")`). `03-sprout-walk.png`. |
| 04 | captured | Unpack/first-look frames copied to `04-first-unpack.png`. Hall still shows Developer Test strip. |

## Pass criteria

- 1680×1040.
- Cabin music: pass on sampled beds.
- Wipe cover / no-dev-strip during climb: not proven in the burst (fail 01).

## Blockers

`_do_climb` awaits did not paint ClimbWipe into the 1.2s sampler. Exterior walk-in stills used `debug_pose("walk")` after a real `_go_home`.

## Shots

All PNGs under `shots/`.
