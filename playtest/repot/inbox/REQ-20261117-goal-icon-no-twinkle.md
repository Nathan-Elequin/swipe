---
id: REQ-20261117-goal-icon-no-twinkle
status: open
priority: normal
tip_sha: f931f8ac
branch: cursor/remove-goal-icon-twinkle-55b1
created: 2026-11-17T07:10:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue with a commitment tier already picked so the top-left goal ring is visible
---

# Goal icon — no looping twinkle

Cloud ship: removed the looping gold plus-shaped Twinkle AnimatedSprite2D from `scripts/playtest_goal_icon.gd`. Ring, biome icon, hover ticker, tip, and tier fly-up in `main.gd` are unchanged. Trophy-board `twinkle_f*.png` assets stay for the board.

## What to verify

- Corner goal ring is steady when the goal is done — no blinking gold sparkle / plus twinkle beside the ring.
- Soft ring brightness pulse (if still present) is fine; the separate sparkle node must be gone.
- Hover still opens the progress ticker + tip.
- Picking a tier still plays the fly-up into the corner (one-shot flyer, not a loop).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight / cabin chrome | commitment tier active, goal reached (done state) so the ring shows | top-left goal ring with no Twinkle sprite / no looping sparkle beside it | 01-goal-steady.png |
| 02 | same | hover the goal icon | ProgressTicker visible; still no twinkle on the ring | 02-goal-hover.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261117-goal-icon-no-twinkle/`
