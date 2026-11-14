---
id: REQ-20261114-trophy-board-package-e
status: open
priority: high
branch: cursor/trophy-board-package-e-3afb
base: playtest/latest
created: 2026-11-14T03:50:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Fresh / Middle Progress → cabin main (fireplace / Nib)
---

# Trophy Board Package E — Nib hall move, reduce motion, audio hooks

Verify Package E on this branch after sync: Nib relocates to the trophy hall on the first return, Reduce motion is in settings, room ambience and board cues fire, biome-dot new-pip blinks.

## What to verify

- Fresh save: Nib is in main through the tutorial.
- First successful return: after the key-ring tour, Nib walks into the hall, says the two `nib.board.move.*` lines, then homecoming runs with him present.
- After reload: Nib is in the hall at the right of the board; main has no Nib sprite or hotspot.
- Settings → Reduce motion on: board slides fade (no travel), homecoming places without fly, rumble does not shake.
- Hall enter starts trophy-room ambience; leave fades it out.
- Biome dots show a blinking new-pip when a face has fresh claims.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | main | Fresh / early save before first haul | Nib at fireplace; hall door locked or closed | 01-main-nib.png |
| 02 | hall | After first successful return + key ring | Nib idle right of the board; main Nib gone | 02-hall-nib-idle.png |
| 03 | settings | Esc → settings | Reduce motion toggle visible (on/off) | 03-reduce-motion.png |
| 04 | hall | Face with fresh claims, reduce motion off | New pip blinking on that biome dot | 04-dot-pip.png |
| 05 | hall | Reduce motion on, slide faces | Cross-fade between faces, no cog spin | 05-reduce-slide.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261114-trophy-board-package-e/`
