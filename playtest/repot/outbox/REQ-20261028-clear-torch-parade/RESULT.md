---
id: REQ-20261028-clear-torch-parade
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-28T22:50:00-05:00
machine: Cherry
tip_sha: 240b0296a3153ac3f4621365c1fce46463b6841a
godot: F5 playtest
viewport: 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` @ `240b0296` (request named `cursor/clear-torch-parade` / `a8f2abf5`; Nathan asked for this checkout). Entry: F5 hub skipped intro → Middle Progress → quick dungeon → empty wheel + `_play_clear_parade`. No wax seal in any frame. Rope exit is not on screen in 01–04.

| id | verdict | note |
|----|---------|------|
| 01 | fail | Gold/torch burst is on the hub. Hub Sprout (hearts) stays drawn under it, so the victory cheer does not read as a clean right-facing `run_victory`. Burrow mound is already visible. |
| 02 | pass | Overlay Sprout runs right into the burrow mouth, unmirrored. Hub Sprout is still sitting in the hole beside the hop. Rope shut. |
| 03 | pass | Soil curtain wipes left→right over the hub/burrow. Rope shut. No wax. |
| 04 | fail | Right-facing arrive hop is on the rim, but hub Sprout is still in the hole, and there is no readable land-dust puff. Rope still shut (not yet the exit screen). |

## Blockers

None.

## Shots

All four PNGs under `shots/` at 1680×1040 using the request filenames.
