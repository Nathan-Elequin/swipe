# QA — 2026-10-11 Placement

## Feature

- Name / id: Direction A placement (`placement.tscn`, `owner_plate.tscn`)
- Spec: `design/visual/SCREEN-placement.md`

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Empty alcoves clickable | valid texture + gold + | + on empty seats | screenshot | Pass |
| Tier word | Weak/Tough/Deadly | `Deadly` pill | screenshot + dump tier 3 | Pass |
| No door label | none | no DOOR OPEN | screenshot | Pass |
| Hint | `door.seat_hint` | `Pick an empty spot.` | dump | Pass |
| Wheel visible | centre 548,350 | `[548, 350]` | dump | Pass |
| Cue | `cue.seat` | `A monster approaches. Select their location.` | dump | Pass |
| No "Tier" | | Deadly only | screenshot | Pass |
| Side-by-side | | `design/visual/qa/placement_qa_v1.png` | capture | Pass |

## Bugs

None that fail the bar.

1. **Repro** — torch line only draws when an empty seat is hovered; this still had no hover.
2. **Likely file** — `wheel_hud.gd` `set_torch`
3. **Suggested fix** — none required for the still; hover is the trigger in the spec
4. **Severity** — polish

## Balance notes

Visual only. 5 seated + 3 empty. Spider Queen pending.

## Player-facing copy issues

- Queen ability on the plate is the locked catalog line (egg), not the mockup's neighbor line. Do not rewrite.

## What was fixed this loop

- Loop 1: column door + owner plate + hint; valid alcoves; hide floating gate.
- Still left: torch line not in this still; occupied-seat shake not photographed.

## Next agent: start here

1. Resume at **fight** if this chat did not finish it.
2. Reuse `owner_plate.tscn`. Wheel stays (548, 350).
3. No `data/` edits.
