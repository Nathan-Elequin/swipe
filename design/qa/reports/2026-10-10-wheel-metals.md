## Feature

- Name / id: Wheel Weak / Tough / Deadly metals (bronze, silver, gold)
- Spec it was built from: chat — match item metals on alcove fill, portrait rim, and name capsule; make rank readable at a glance. No rule change.

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Right screen | Mill / wheel with mixed ranks | Seated Clockwork Knight, Gargoyle, Commander, Skeleton, Anvil, Wizard, Bandit | `design/qa/reports/evidence/2026-10-10-wheel-metals.json`; screenshot_game | Pass |
| Bronze / silver / gold | Same item metals: `#c08050` / `#c5cdd8` / `#e8c36a` on rims and chips | Wedges ochre vs grey-blue vs cocoa; stars gold, hex silver, circles bronze; name chips match | screenshot_game | Pass |
| Locked text unchanged | No player-copy / board prose edits | Only `ux_style.gd`, `boss_wheel.gd`, `main.gd` `_tier_metal`, `draft_gate.gd` metal helper | this turn | Pass |
| No "Tier" on player screens | Weak/Tough/Deadly via color/shape only | Cue `Take it or leave it?`; names only | screenshot_game | Pass |
| Unreadable | Names, HP, ATK still readable | Metal ink on dark chips; hearts/swords unchanged. Mill cue overlaps Commander name (pre-existing) | screenshot_game | Pass with notes |
| Errors | None | DAP `scope_list` only | `godot_editor_read` get_log_messages error | Pass |

## Bugs

None for this change.

## Balance notes

Not a balance change.

## Player-facing copy issues

None. Call titles on the wheel now use the rank metal instead of ATK/HP keyword colors so the chip reads as one rank.

## What was fixed this loop

- Loop 1/1: Alcove fill, portrait well/rim, and name capsule all use `UxStyle.metal*` (same hexes as item rims). Facing no longer paints every slice gold.
- Still left: mill cue can sit on the south name chip (old layout).

## Next agent: start here

1. Metals live in `scripts/ux_style.gd` (`metal`, `metal_wedge`, `metal_well`, `metal_chip`, `metal_ink`, `metal_call`).
2. Wheel draws them in `boss_wheel.gd` `_fill_for`, `_draw_tier_plate` / `_draw_tier_rim`, `_draw_slice_title`.
3. Do not print the word Tier on the wheel; rank is bronze circle / silver hex / gold star.
