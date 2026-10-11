# QA — 2026-10-11 Defeat dashed hand

## Feature

- Name / id: Direction A defeat empty dashed hand + column hearts
- Spec: `design/visual/SCREEN-defeat.md` (close the gap from `2026-10-11-defeat.md`)

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Dashed empty hand | 140×190 slots, 4px dash, 50% alpha | 6 dashed slots; hotbar hidden; ghost 1030×190 | dump + `defeat_qa_v1_right.png` | Pass |
| Wheel dim | 22% `#5A5048` | modulate rgb ~0.35/0.31/0.28 a 0.22 | dump `mod` | Pass |
| Column hearts | 3 empty at 60px, 60% alpha | 3 empty hearts | dump `hearts`: 3 | Pass |
| HUD hearts empty | all empty | empty hearts at top | screenshot | Pass |
| Again outline gold | gold border + gold text | gold outline Again | screenshot after color override | Pass |
| Copy | `title.lose` / `title.lose_sub` | Defeated / never pays | dump | Pass |
| No TODO(copy) | | none | tree scan | Pass |
| Side-by-side | | `design/visual/qa/defeat_qa_v1.png` | capture | Pass |

## Bugs

None that fail the bar.

1. **Repro** — gold pointer under the wheel stays bright while the ring is dim.
2. **Likely file** — `wheel_hud.gd` pointer
3. **Suggested fix** — dim or hide the pointer on defeat
4. **Severity** — polish

## Balance notes

Visual only. Forced `hp = 0`, `phase = defeat` after the victory still.

## Player-facing copy issues

None on the plate. Authoring log still under Again.

## What was fixed this loop

- Loop 1: ghost dashed slots, hide hotbar, column empty hearts, gold Again text/hover.
- Still left: bright pointer; authoring log; seat sprites still on the dim ring (spec wants the full wheel, mockup also keeps seats).

## Next agent: start here

1. Confirm `hand.spent` = Used (if this report is read alone).
