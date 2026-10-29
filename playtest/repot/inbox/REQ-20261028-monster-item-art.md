---
id: REQ-20261028-monster-item-art
status: open
priority: normal
pr: 0
tip_sha: 3a453021d4acb152241c50e9eee9dd5122006f5e
branch: playtest/latest
created: 2026-10-28T22:05:00-05:00
created_by: pixel-cloud
viewport: 1680x1040
entry: F5 playtest hub → dungeon with dev pools so Sandbag, Scorpion, Oligarch, Harpy and the items Orb, Flying Saucer, Spiked Shield, Chaos Stone appear (dev deck or seeded pool)
---

# Monster + item art drop (Sandbag, Scorpion, Oligarch redo, Harpy polish, 5 items)

New 16px→64 stills, 48px facing idle, 24px wheel seats and 48px slash cut-ins for Sandbag, Scorpion and Oligarch. Harpy gets real slash cut-ins, distinct breathe frames, consistent left facing, and MONSTER_FACES harpy R→L. Item art: Orb, Flying Saucer, Spiked Shield (red, attack face) and Chaos Stone (mute_stone.png). All monsters face LEFT.

## What to verify
- Each monster's wheel seat shows its full body, not cropped and not the old stand-in.
- In a fight every monster faces LEFT toward the player side, Harpy included (she was mirrored wrong before).
- The slash cut-in plays the new frames: Harpy shows a portrait with the talon swipe and no full-body idle copy at the end (f4 removed).
- Item cards show the new art, sharp (Nearest, no blur). Orb greys when not Safe.

## Screenshots required
| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon wheel | Wheel with Sandbag, Scorpion, Oligarch, Harpy seated | 4 seats with new full-body 24px art, readable | 01-wheel-seats.png |
| 02 | fight | Face Sandbag | Tan sandbag with eyes, faces left / front | 02-fight-sandbag.png |
| 03 | fight | Face Scorpion | Scorpion pincers point LEFT | 03-fight-scorpion.png |
| 04 | fight | Face Oligarch (entry slash) | Red-haired elf in royal green gown, faces LEFT, coin-toss cut-in mid-play | 04-oligarch-slash.png |
| 05 | fight | Face Harpy, trigger slash | Harpy faces LEFT; cut-in is a portrait with wings and swipe | 05-harpy-slash.png |
| 06 | hand | Hand holding Orb, Flying Saucer, Spiked Shield, Chaos Stone | New icons crisp; Orb grey when not Safe | 06-items-hand.png |

## Pass criteria
- All six PNGs present; every `expect` readable.
- Any monster facing right, or a blurry or stand-in sprite = fail with the id.

## Outbox path
`playtest/repot/outbox/REQ-20261028-monster-item-art/`
