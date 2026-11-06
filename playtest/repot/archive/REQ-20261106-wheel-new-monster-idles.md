---
id: REQ-20261106-wheel-new-monster-idles
status: archived
priority: high
branch: cursor/wheel-new-monster-idles-9f05
created: 2026-11-06T22:45:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New / Middle Progress → dungeon wheel that seats Imp and/or Quicksand Crab next to an established monster (Skeleton, Twins/hollow, or Leech League)
archived_by: pixel
archived_at: 2026-11-06T17:40:00-06:00
---

# REQ-20261106-wheel-new-monster-idles

**Screen:** Boss wheel seat idle for new monsters  
**Spec:** `design/visual/SCREEN-wheel-new-monster-idles.md`  
**Viewport:** 1680×1040 · Nearest · no player-facing copy changes

## What shipped (cloud)

Loader bug: `wheel_frames_all` / `monster_wheel_frames` used only `facing_idle_f0` when `*_wheel_idle_fN` was missing, so Imp / Quicksand Crab / Huntsman / Phantom / Collector / Glass Asp sat static while Skeleton / Twins / Leech League animated. Fix wires the full authored facing idle strip. No new PNGs. Cloud has no Godot — runtime motion proof is this drain.

## What to verify

- Imp and Quicksand Crab (and other new ids on the ring) **change pose** while the wheel is idle (not spinning, not held).
- An established neighbor (Skeleton / Twins / Leech League) still animates.
- Mid-spin still freezes seat idles.
- No procedural wobble; motion is the authored f0→f3 strip.
- Tip watermark / build stamp optional; motion evidence is the time-pair or short clip.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon wheel | Ring includes Imp + Quicksand Crab + one established (Skeleton/Twins/Leech); capture at t≈0.0s, no spin | Baseline wheel; Imp/Crab visible | 01-idle-t0.png |
| 02 | dungeon wheel | Same ring, same camera; wait ≥0.4s (prefer ~0.6–0.8s) still no spin | Imp and/or Crab seat pixels differ from 01 (pose advanced); established neighbor also advanced or still looping | 02-idle-t06.png |
| 03 | dungeon wheel | Optional short clip (~1–2s) of the same idle ring | Visible frame change on Imp/Crab without spin | 03-idle-clip.mp4 (optional if PNG pair is clear) |
| 04 | dungeon wheel | Start a spin mid-idle | Seat sprites freeze during spin (no idle advance) | 04-spin-freeze.png |

## Pass criteria

- 01 and 02 at 1680×1040; Imp/Crab region differs between the two (not a single static contact sheet claiming motion).
- 04 shows freeze during spin (or RESULT notes equivalent).
- `RESULT.md` marks each id pass/fail with one evidence line.
- Optional: `python3 tools/qa/check_wheel_new_monster_idles.py` and/or Godot selftest exit 0 on this tip.

## Outbox path

`playtest/repot/outbox/REQ-20261106-wheel-new-monster-idles/`
