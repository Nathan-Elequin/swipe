---
id: REQ-20261114-trophy-board-final-art
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-13T22:10:00-06:00
machine: Cherry
tip_sha: 80e7d6aa
godot: F5 playtest via godot-mcp, viewport 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` `80e7d6aa` (request named final-art branch).

| id | verdict | note |
|----|---------|------|
| 01 | pass | Centre wall is log planks + peg rail (coat, hat, scarf). No overlapping run-door sprite. Right SideDoor present. `01-main-log-wall.png`. |
| 02 | pass | Hall plate + oak frame, Verdant face bg, crest, painted placard, lights, lever, dots, arrows. Nearest pixels. `02-hall-board.png`. |
| 03 | pass | Claimed slots: gold aura / lit recess; unseen stay dark. `03-hall-claimed-aura.png`. |
| 04 | pass | Crystal locked face: padlock centred; dots/arrows readable; painted Crystal Cavern placard. `04-hall-locked-face.png`. |

## Pass criteria

- 1680×1040.
- Expect readable in each PNG.
- Editor log still reports missing `.ctex` for some `slot_recess_*` / `twinkle_f*` / mock PNGs; live board still showed final oak/placard art, not magenta.

## Blockers

None for the four required frames.

## Shots

All PNGs under `shots/`.
