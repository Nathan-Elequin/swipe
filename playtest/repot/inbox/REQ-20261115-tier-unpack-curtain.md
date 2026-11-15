---
id: REQ-20261115-tier-unpack-curtain
status: done
priority: high
branch: cursor/tier-unpack-curtain-6725
created: 2026-11-15T01:08:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Continue / Middle Progress → win a run (or Middle Progress with banked returns) → trophy hall satchel unpack; also browse to a locked board face
---

# Tiered unpack + velvet curtain A

Wires Nathan's two approved trophy-board features: metal-ramped unpack (bronze / silver / gold swoosh, land FX, plinth, aura, SFX) and the velvet curtain on locked faces (option A).

## What to verify

- Banking a return unpacks deposits in board order, then ascending metal rank within a face (bronze → silver → gold). The board slides to each face as its items land.
- Beat order stays locked: float out of satchel → drift with swoosh → land FX + land SFX → only then does the slot light (plinth + aura). Slot must never be lit before the item arrives.
- Gold gets the full swell / hang / snap beat; bronze and silver are shorter. Reduced motion keeps order + SFX, drops scale/swoosh, crossfades FX.
- Claimed slots keep metal plinths and looping auras after unpack (not only during the fly).
- Locked faces show the velvet curtain over the inner slot field (alpha 0.82), under the padlock, not covering the title placard, biome dots, or side arrows.
- Clicking a locked face (curtain or padlock) plays the jiggle once, shakes the padlock, plays `cabin.locked`, and keeps the locked hover tip. Spam does not stack.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall trophy | Bank a return with mixed metals across 2 boards; capture 3–4 frames mid-sequence (board slide + items in flight) | Deposits land face-by-face; swoosh trails visible; later face not lit early | 01-unpack-sequence.png |
| 02 | hall trophy | Same unpack; freeze a gold item mid-swell before socket | Gold sprite enlarged (~1.3) on the flight path; swoosh_gold trail | 02-gold-mid-swell.png |
| 03 | hall trophy | After unpack settles; claim at least one bronze, one silver, one gold (same or adjacent faces) | Side-by-side claimed plinths/auras read copper / steel / gold | 03-claimed-metals.png |
| 04 | hall trophy | Slide to a locked face (e.g. Ashen Crypt before unlock) | Curtain covers the grey slot field; padlock on top; title / arrows / dots clear | 04-locked-curtain.png |
| 05 | hall trophy | Click the locked curtain or padlock; capture mid-jiggle | Curtain jiggle frame + padlock slightly tilted/offset; no stacked spam | 05-locked-jiggle.png |

## Pass criteria

- Shots at 1680×1040.
- Each expect readable in the PNG without guessing.
- No player-facing "Tier" / "Weak" / "Tough" / "Deadly" from this work.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261115-tier-unpack-curtain/`
