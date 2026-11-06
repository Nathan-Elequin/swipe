---
id: REQ-20261106-full-double-wheel-seats
status: open
priority: high
pr: 418
tip_sha: 37eec2ee
branch: playtest/latest
created: 2026-11-06T03:00:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → any mixed Weak/Tough/Deadly wheel
---

# Full-double wheel seats (Weak 96 / Deadly 128)

Nathan locked full-double seat size. Weak/Tough seats are native 48 (96px on screen at 2×). Deadly seats are native 64 (128px on screen at 2×). Art is a 1:1 copy of fight facing when the canvas already matches, otherwise a nearest refit of that facing — not a blurry upscale of the old 24/32 seats. Who-rings scale with the seats: Weak hoop 64n (128px on screen), Deadly hoop 80n (160px on screen). Same catalog-tier split as #414. No player-facing copy. Never show the word "Tier".

## What to verify

- Weak/Tough seats read at **96px** on screen (Goblin, Hornet, Ogre). Deadly seats read at **128px** (Dragon, Lich, Slime Boss).
- Who-ring still sits **outside** a Weak 96 seat and **outside** a Deadly 128 seat (Boot / Knife hover).
- Ogre (Tough, 64-facing art) is the Weak/Tough size, not Deadly.
- Mixed ring: two sizes, no wedge clip, name/HP/ATK still readable, taps still work.
- Facing fight portraits are unchanged.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon wheel | Fight a Weak seat (Goblin or Hornet). Hover Boot or Throwing Knife. | Seat is **96px** on screen; gold hoop sits outside it | 01-weak-96-ring.png |
| 02 | dungeon wheel | Fight a Deadly seat (Dragon, Lich, or Slime Boss). Hover Boot or Throwing Knife. | Seat is **128px** on screen; larger gold hoop sits outside it | 02-deadly-128-ring.png |
| 03 | dungeon wheel | Mixed ring: Weak + Tough + Deadly together (Goblin, Ogre, Dragon) | Two seat sizes; Ogre matches Goblin class, not Dragon; no overlap | 03-mixed-96-vs-128.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Shot 01 must show Weak **96** + ring still fits. Shot 02 must show Deadly **128** + ring still fits.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Optional: `python3 tools/qa/check_wheel_seat_from_facing.py` and `python3 tools/qa/check_who_rings.py` exit 0.
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261106-full-double-wheel-seats/`
