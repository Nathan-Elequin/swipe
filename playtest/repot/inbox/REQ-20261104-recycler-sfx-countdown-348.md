---
id: REQ-20261104-recycler-sfx-countdown-348
status: open
priority: high
pr: 348
tip_sha: PENDING
branch: cursor/recycler-sfx-countdown-348-4437
created: 2026-11-04T19:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New / Middle Progress → fight with Recycler in hand
---

# Recycler countdown SFX + armed zero (#348)

Cloud ship for issue #348. Discard ticks play `ui.slider_tick` with a louder number punch; when Recycler arms (next discard returns) the face shows a mint/green **0** on the existing recycle (`copy`) icon with Hex@1-style green glow (not gold READY). `item.use.recycler` oneshot plays on arm and on reclaim only.

## What to verify

- Each discard that decrements Recycler: hear `ui_tick` (~−8 dB) and see a bigger scale/number punch (5→4→3→2).
- When the countdown lands on armed: face shows **0** centered on the recycle arrows, mint/green plate glow (not gold READY ring).
- Next discard after armed: discarded item is copied back; hear `item_use_recycler` once on arm and once on reclaim (not on every mid-count tick).
- No new art asset — uses existing `assets/icons/copy.svg` + mint tint. Pixel follow-up only if a dedicated recycle-ring zero plate is wanted later.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight hub | Recycler in hand at 3+; discard one item | number punched down one step; no green zero yet | 01-tick-countdown.png |
| 02 | fight hub | Recycler armed (recycle_n ≤ 1) | mint glow; face shows 0 on recycle icon; not gold READY | 02-armed-zero.png |
| 03 | fight hub | Discard while armed | copy returns to hand; Recycler back to 5 | 03-reclaim.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Armed state clearly reads as green/positive 0 + recycle icon (not gold READY, not blank copy-only).
- Mid-count ticks look louder than a quiet label swap.

## Outbox path

`playtest/repot/outbox/REQ-20261104-recycler-sfx-countdown-348/`
