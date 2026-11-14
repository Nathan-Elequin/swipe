---
id: REQ-20261114-trophy-board-package-a
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-13T22:10:00-06:00
machine: Cherry
tip_sha: 80e7d6aa
godot: F5 playtest via godot-mcp, viewport 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` `80e7d6aa` (request named Package A branch `654e6678`). Isolated `user://` cabin/campaign files, then restored Nathan's saves after Stop.

| id | verdict | note |
|----|---------|------|
| main-no-run-door | pass | Main fireplace wall is log planks, peg rail, coat/hat/scarf. Nodes: LeftDoor + SideDoor only — no RunDoor / Outpost hotspot. `main_no_run_door.png`. |
| hall-board | pass | Trophy hall shows `room_trophy` plate + carousel board (Verdant Hollow placard, pyramid, lights, lever). No cabinet cases, no right Outpost door. `hall_trophyboard.png`. |
| exterior-arrive | pass | Night cabin exterior, path to door, lantern, clickable door (glow node on). `exterior_arrive.png`. |

## Pass criteria

1. pass — no centre “Toward the Outpost” / RunDoor.
2. pass — live TrophyBoard; no five cabinets; no Outpost door.
3. pass — exterior door is the cabin entry (hall/main after click is wired; interior hall verified separately).
4. fail — editor log: `Attempt to open script 'res://scripts/cabin/room_mudroom.gd' resulted in error 'File not found'`. Play did not crash. Also missing `.ctex` for some trophy_board slot/twinkle/mocks at import time.

## Blockers

None for shots. Criterion 4 is a leftover mudroom script load, not a missing PNG.

## Shots

All PNGs under `shots/` at 1680×1040.
