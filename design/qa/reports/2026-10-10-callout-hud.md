# QA — 2026-10-10 facing plate, inspect, item hover

## Feature

- Name / id: Facing monster plate, top-right inspect, item hover, Spin cue, New button
- Spec: chat UI (copy/layout). No locked `player-copy.json` or board ability/explainer rewrites.

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Facing title | Larger, bolder | Lich title on metal plate | screenshot facing Lich | Pass |
| Facing Attack/HP | Heart left, sword right, no words | Heart 1, sword 3 | screenshot | Pass |
| Facing call name | Soul Tithe under stats | Soul Tithe | screenshot | Pass |
| Shift facing | Reminder replaces call; speech in balloon | Neighbors +1 HP; balloon 1st person | Shift screenshot | Pass |
| Top right default | Empty of monster echo | Only Log | ready + fight screenshots | Pass |
| Hover other owner | Same plate + speech, no reminder swap | Wizard inspect, blank call, speech | Wizard hover screenshot | Pass |
| Wizard/Golem call | Blank | Wheel shows name only | ready screenshot | Pass |
| Spin cue gone | No “somebody wants their stuff” | Cue empty | probe `cue: ""`; ready screenshot | Pass |
| New button | Not on fight HUD | Hidden; Spin only | ready screenshot `new_vis: false` | Pass |
| Item hover default | Title, stat icon, full text, no formula | Knucklers + sword 5 + ability | screenshot | Pass |
| Item hover Shift | Formula replaces the icon; text stays | `(8 − Items)` + ability | Shift screenshot | Pass |
| Hotbar Shift | Formula only, no explainer paragraph | Compact cards, formula chips | Shift screenshot | Pass |
| Defeat item | Formatted Defeat, not an Attack icon | The Boot Defeat chip + sentence | screenshot | Pass |
| Locked copy | Unchanged | No player-copy edits | git | Pass |
| No “Tier” | Player HUD | None on screenshots | screenshots | Pass |
| Errors | None from game scripts | DAP debugger noise only | editor log | Pass |

## Bugs

None that block this HUD pass.

## Balance notes

Not a rules change.

## Player-facing copy issues

- `cue.ready` is still locked as “Spin — somebody wants their stuff.” It is no longer shown. Flag only; not rewritten.

## What was fixed this loop

- Loop 1: facing icons, empty inspect, editor call/reminder/speech fields, keyword paint, cue off, New off the fight row, item inspect vs Shift formula, hotbar formula-only.

## Next agent: start here

1. Escape menu now has a New button in Start over. Confirm Nathan wants that label vs only Begin / Dive In.
2. Item inspect uses board ability as the paragraph. If a card’s ability still reads like the old math line, that is locked copy.
