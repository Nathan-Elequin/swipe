---
id: REQ-20261114-trophy-board-package-c
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-13T22:10:00-06:00
machine: Cherry
tip_sha: 80e7d6aa
godot: F5 playtest via godot-mcp, viewport 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` `80e7d6aa`. Homecoming fly was captured with godot-mcp `screenshot_at_ms` at 1680×1040 plus a disk PNG of satchel + item leaving the mouth.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Night exterior, door clickable. `01-exterior.png`. |
| 02 | pass | Satchel on the rug; item rises from the mouth toward the pyramid (MCP 717ms frame also showed mid-air spark on Sledgehammer). One chime per new light is wired (`board.light_chime_*`); samples during freeze often missed the one-shot. `02-homecoming-fly.png`. |
| 03 | pass | After items, five lights + lever READY glow. Lever does not auto-pull. `03-lever-ready.png`. |
| 04 | pass | Hall idle, no satchel; Nib `nib.board.empty.*`: “Nothing new this time. The board can wait.” `04-empty-return.png`. |

## Pass criteria

- 1680×1040.
- No Tier / ATK.
- Fly target uses live slot centres (item heads at the pyramid cell, not a hardcoded off-board point).

## Blockers

Frozen `godot_game_time` steps skipped most of the satchel tween. Real-time MCP sequence caught the fly.

## Shots

All PNGs under `shots/`.
