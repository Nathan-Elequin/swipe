---
id: REQ-20261029-trophy-pegs-fit
status: fail
fulfilled_by: local-cursor
fulfilled_at: 2026-10-30T12:45:00-05:00
machine: Cherry
tip_sha: df90655dfde8e35b89945bc61267ec7d10a7b663
godot: F5 playtest (godot-mcp)
viewport: 1680x1040
---

# Result

Drained alongside REQ-20261030-trophy-hall-dumbwaiter on `playtest/latest` @ `df90655d`. Hall layout is the new dumbwaiter cases (Crystal Cavern, not Sunken Mire). Headless `BIOME_CABINETS_OK`.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Fresh/opened hall pegs sit in glass above the case base (same 01 as dumbwaiter fresh). |
| 02 | fail | Did not capture a true all-five-full frame (export/itch was the named job; grant-all PNG write missed the shots dir). |
| 03 | fail | No dedicated Nearest crop. |

## Blockers

Need a dedicated all-five-full Middle Progress hall shot on this tip. Inbox left **open**.
