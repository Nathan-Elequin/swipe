---
id: REQ-20261105-wheel-seat-from-facing
status: open
priority: high
branch: playtest/latest
created: 2026-11-05T23:59:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New or Middle Progress → any dungeon with a mixed wheel
---

# REQ-20261105-wheel-seat-from-facing

**Screen:** Boss wheel seats from fight facing  
**Spec:** `design/visual/SCREEN-wheel-seat-from-facing.md`  
**Mock:** `design/visual/mockups/CONTACT-wheel-mock-v2.png`  
**Viewport:** 1680×1040 · Nearest · no new player-facing strings · never show "Tier"

## What shipped

Every live monster wheel seat is a difficulty-sized crop of its fight facing sprite. Deadly seats are 32 native (64px on-screen at 2×); Weak and Tough are 24 native (48px), including Tough monsters whose fight art is 64px (ogre, juggernaut, hydra, shark, gelatinous_cube). Seats idle-animate from `_wheel_idle_fN` strips. Old seats archived under `design/archive/pass-wheel-pre-facing/`.

## What to verify

- Mixed Weak / Tough / Deadly seats read at two sizes (48 vs 64 on-screen).
- Deadly 32n next to a 24n neighbor: no overlap, no edge clip, name/HP/ATK chrome still readable.
- Ogre (Tough, 64-facing art) sits at 24n / 48px — not the Deadly size.
- Idle animation plays on seats that are not mid-spin / not held.
- No player-facing copy changes; the word "Tier" never appears.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon wheel | Seat a mix: at least one Weak (e.g. goblin), one Tough (e.g. ogre or merchant), one Deadly (e.g. dragon or lich) on the same ring | Two seat sizes visible; Weak/Tough smaller than Deadly; silhouettes match fight facing | 01-mixed-weak-tough-deadly.png |
| 02 | dungeon wheel | Put a Deadly (32n) beside a Weak or Tough (24n) — e.g. dragon next to goblin | Deadly seat reads larger; no sprite overlap; no clip at seat edges | 02-deadly-next-to-24.png |
| 03 | dungeon wheel | Seat ogre (Tough) on the ring with a Weak neighbor | Ogre is 24n / 48px on-screen (same size class as Weak), not Deadly 64px | 03-ogre-tough-at-24.png |
| 04 | dungeon wheel | Same mixed ring; wait ~1s with no spin so idle advances | Seats show idle frame change (breathe/pose); freeze still holds mid-spin | 04-idle-anim.png |
| 05 | dungeon wheel | Dense or mixed ring; crop/close on seat edges | No clipping or overlap at seat edges; HP/ATK/name chrome clear | 05-no-clip-overlap.png |

## Pass criteria

- All five PNGs present at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Optional: `godot --headless --path . --script res://scripts/dev/wheel_seat_from_facing_selftest.gd` exits 0, or `python3 tools/qa/check_wheel_seat_from_facing.py` exits 0.

## Outbox path

`playtest/repot/outbox/REQ-20261105-wheel-seat-from-facing/`
