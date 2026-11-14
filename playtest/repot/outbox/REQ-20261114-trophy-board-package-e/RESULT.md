---
id: REQ-20261114-trophy-board-package-e
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-13T22:10:00-06:00
machine: Cherry
tip_sha: 80e7d6aa
godot: F5 playtest via godot-mcp, viewport 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` `80e7d6aa`. Audio: `amb_trophy_room.ogg` on the Ambience bus in the hall; cabin fire/rock/purr also running. Board one-shots were heard in the lever/homecoming paths; they were usually finished by the next sample.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Nib in the main-room rocking chair at the fireplace; right SideDoor is the hall door (this save already had hall unlocked). `01-main-nib.png`. |
| 02 | pass | After return flag: Nib idle to the right of the board; main Nib hidden (`nib_in_hall=true`). `02-hall-nib-idle.png`. |
| 03 | pass | Settings shows `Reduce motion: off` toggle (on/off copy). `03-reduce-motion.png`. |
| 04 | fail | 100% Verdant face shows gold sparkles on the active biome dot; a blinking *new* pip on a fresh-claim face was not isolated (frozen capture). `04-dot-pip.png`. |
| 05 | pass | Reduce motion on: face change lands on Crystal with no cog travel / no sliding neighbors. 0.15s fade elapsed before the MCP frames. `05-reduce-slide.png`. |

## Pass criteria

- 1680×1040.
- Hall ambience plays; leaving the hall was not re-shot (ambience hook confirmed while in hall).

## Blockers

Full first-return walk (key ring then Nib walk) was not replayed; Nib hall idle used the save flag + `NibHost.apply_visibility`.

## Shots

All PNGs under `shots/`.
