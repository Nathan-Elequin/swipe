---
id: REQ-20261030-wheel-callout-clear
status: open
priority: high
branch: playtest/latest
created: 2026-10-30T22:00:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → fight with a live callout (Harpy or any long Ability plate) and move arrows visible (Adventure)
---

# REQ-20261030-wheel-callout-clear

**Screen:** Combat wheel + hotbar + move arrows + right monster callout  
**What shipped:** Issue #199 — combat cluster (wheel, item hotbar, both move arrows) nudged ~5% of viewport width left via `ViewFrame.COMBAT_CLUSTER_LEFT_FRAC` / `combat_cluster_left_nudge()` (~84px at 1680). Holding Shift no longer changes the active combatant callout (`face_box`) size, position, or content; Shift still drives hotbar formulas, cascade fast-forward, and wheel wedge inspect. Also backmerges main's biome music fade on victory rest / Push (`7abb2ffb`).  
**Viewport:** 1680×1040 · Nearest · no player-facing copy edits · no new mechanics

## Outbox
`playtest/repot/outbox/REQ-20261030-wheel-callout-clear/shots/`

## What to verify

- Fight idle: right move arrow does not cover the monster callout plate.
- Shift held: active combatant callout unchanged (same text, same size, same place).
- Hotbar still centered under the wheel after the left nudge.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Adventure fight idle, callout visible, move arrows on | Right move arrow clear of the monster callout at its current size | 01-fight-idle-arrow-clear.png |
| 02 | fight | Same seat, hold Shift | Callout text/size/position unchanged vs idle (no Shift equation expand) | 02-shift-held-callout-same.png |
| 03 | fight | Same fight, show hotbar | Hotbar still aligned under the wheel (cluster moved together) | 03-hotbar-under-wheel.png |

## Pass criteria

- All three PNGs at 1680×1040.
- 01: visible gap between right arrow and callout plate.
- 02: callout matches idle (no Shift-only equation / size change).
- 03: hotbar centers under wheel, not left behind at the old X.

## Copy / gameplay

No copy string edits. No rule / number changes. Music-fade backmerge is audio-only.
