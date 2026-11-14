---
id: REQ-20261114-portal-hall-flow
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T00:50:00-06:00
machine: Cherry
tip_sha: 2c7b5865
godot: F5 playtest via godot-mcp, shots nearest-resized to 1680x1040
branch: playtest/latest
---

# Result

Evidence only. Nathan's `user://` JSON was copied to `_repot_backup_20261114_portal_trophy` then restored after Stop. Cabin `_persist_writes=false` during poses.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Hall visible after Crystal splash dismiss (not a black ColorRect). Five arch lights, board, floor lever spent. `01-hall-after-splash.png`. Music key `cabin`. |
| 02 | pass | Nib line verbatim: "Hear that rumble? Something down there just woke up." Nib 1.5×, feet on HALL_FLOOR_Y 920 in front of the dais. `02-nib-rumble-line.png` plus walk pose `02-nib-walk-floor.png`. |
| 03 | pass | Pointer from talk bar + 4-frame pulse ring on first light (`03-nib-pointer-ring.png` / `03a-pointer-first-light.png`) and on the lever (`03b-pointer-lever.png`). |
| 04 | pass | No Developer Test / Play Latest / Roster / Script strip. BoardDais at (152, 812) size 1376×96. `04-hall-no-strip-dais.png`. Build stamp `playtest.latest` still in the corner. |

Extra: Crystal splash `05-splash-crystal.png` / `05b-splash-hold.png` with bed `crystal_cavern`. See `audit/music-keys.txt`.

## Blockers

None for the table. First hall-after-splash save was eaten by the held-map beat of `BoardSequences.portal`; recaptured after hiding the map.

## Shots

All PNGs under `shots/` at 1680×1040 (nearest from the editor game pane).
