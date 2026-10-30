---
id: REQ-20261029-clear-parade-hub-hide
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-28T23:50:00-05:00
machine: Cherry
tip_sha: 416c678b4133864f97dc230dad243a04d6251631
godot: F5 playtest
viewport: 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` @ `416c678b` (includes merge of PR #177). Entry: F5 hub skip intro → Middle Progress → campaign delve 0 → empty wheel. Shots 01–04 used `clear_parade.freeze_at` 0.30 / 1.30 / 1.85 / 2.45 with hub hide flags on. Shot 05 used `freeze_at = -1` via `_enter_dungeon_clear` and was captured ~0.5 s after the parade returned (rest / rope). All PNGs 1680×1040. No wax seal in any frame.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Gold/torch burst on the hub. One right-facing `run_victory` Sprout; hub Sprout not drawn under it. Heart pips remain. No mound, no rope, no wax. |
| 02 | pass | Overlay Sprout hops right (unmirrored) into the burrow mouth. Hub hole empty except heart pips. Rope shut. |
| 03 | pass | Soil curtain wipes left→right across the burrow. Hub hole empty. Rope shut. No wax. |
| 04 | pass | Arrive hop faces right on the rim with a readable land-dust puff under the feet. Hub hole empty. Rope still shut. |
| 05 | pass | After the parade, hub Sprout is back on the rest screen and Grandpa's rope exit is open (Bank home / Climb Grandpa's rope). |

## Blockers

None.

## Shots

All five PNGs under `shots/` at 1680×1040 using the request filenames.
