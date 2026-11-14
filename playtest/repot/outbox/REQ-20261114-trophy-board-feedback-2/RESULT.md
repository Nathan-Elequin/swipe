---
id: REQ-20261114-trophy-board-feedback-2
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-13T22:10:00-06:00
machine: Cherry
tip_sha: 80e7d6aa
godot: F5 playtest via godot-mcp, viewport 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` `80e7d6aa`. Instant `slide_to` needs a few game frames before the painted placard texture is readable (first Crystal capture was a white bar; recapture after step is the real placard).

| id | verdict | note |
|----|---------|------|
| 01 | pass | Verdant Hollow painted placard, lights clear of the sign, oak stand + floor shadow + rug, bottom pyramid row inside the frame. `01-b1-verdant.png`. |
| 02 | pass | Crystal Cavern placard recentred, crystal lip, padlock, stand/shadow still readable. `02-b2-crystal.png`. |
| 03 | pass | Ashen Crypt placard + ashen lip; same chrome. `03-b3-ashen.png`. |
| 04 | pass | Cinder Forge placard + ember lip; same chrome. `04-b4-cinder.png`. |
| 05 | pass | Shadow Abyss placard; stand/shadow clear of the rug. `05-b5-shadow.png`. |

## Pass criteria

- All 1680×1040.
- Face name is the painted placard (no EB Garamond title overlay).
- No Tier / ATK.
- Nib idles right of the board on every face.

## Blockers

None after recapturing locked faces post-step.

## Shots

All PNGs under `shots/`.
