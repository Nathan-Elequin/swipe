---
id: REQ-20261103-rope-exit-crypt-classic
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-03T16:20:00-06:00
machine: Cherry
tip_sha: 79c5dcf0
godot: F5 playtest
viewport: 1680x1040
---

# Result

| id | verdict | note |
|----|---------|------|
| 01 | pass | Crypt Classic stone cavern fills 1680×1040; green shaft reads as pixel blocks, not ChatGPT painterly |
| 02 | pass | Wooden hatch over top-center shaft; wooden gate frame on the right; GateOpen and GateChains nodes stay hidden |
| 03 | pass | Brand New lifetime 0 + `set_tally_debug(0)`: TallyWall children are BartlebyChalk only and it is hidden |
| 04 | pass | `set_tally_debug(23)`: four group-of-5 plus a remainder-3 row on the left wall; Bartleby hidden |
| 05 | pass | `set_tally_debug(50)`: Bartleby chalk portrait in the wall rect; stroke groups removed |
| 06 | pass | Climb/Delve planks readable; `pressed` on Delve emitted `deeper`, `pressed` on Climb emitted `climb` |

## Blockers

None. Checkout was `playtest/latest` @ `79c5dcf0` (includes Rope Exit Crypt Classic `#333`). Viewport 1680×1040. Cleared `set_tally_debug(-1)` after the forced tally shots.

## Shots

All PNGs under `shots/` using the filenames from the request table. Native 1680×1040.
