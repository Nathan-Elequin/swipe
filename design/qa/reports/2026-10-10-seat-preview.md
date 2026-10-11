## Feature

- Name / id: Mill seating hover telegraph (Lich / Commander / Wraith adjacency)
- Spec it was built from: chat — preview existing neighbor buffs while hovering an empty alcove; loud sight-lines and icon pulse. No rule change.

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Right screen | Mill seat cue; hover empty alcove while a monster is pending | Cue `A monster approaches. Select their location.` Ghost Lich in hovered alcove | godot_exec dump; screenshot_game of Lich between Skeleton and Wizard | Pass |
| Lich neighbors | Hovering the empty seat between Skeleton and Wizard previews +1 HP on both, live HP unchanged | links hp+1 to 0 and 2; preview `{0:{hp:1},2:{hp:1}}`; live Skeleton still 3/3, Wizard 5/2, alcove still empty | `design/qa/reports/evidence/2026-10-10-seat-preview.json` | Pass |
| Commander neighbors | Same hover with Commander pending previews +2 ATK | links atk+2 to 0 and 2; live Skeleton still 3/3 | same JSON | Pass |
| Wraith copy | Wraith next to Wizard copies ATK 5 | self atk 5, atk_d +2, copy_from 0, purple copy link | same JSON | Pass |
| No adjacency | Wizard pending next to Skeleton: ghost only | links [] | same JSON | Pass |
| Hover off | Clears beams and preview | `hover_off_clears: true` | same JSON | Pass |
| Locked text unchanged | No player-copy / board prose edits | This turn did not touch those files | git (scripts + qa report only) | Pass |
| No "Tier" on player screens | Weak/Tough/Deadly only | Cue and wheel names only | screenshot_game | Pass |
| Unreadable | Numbers and +N must be readable | After loop 2, +1 sits in a dark badge above each affected heart; gold beams from the ghost to those hearts | screenshot_game (Lich) | Pass |
| Errors | None | DAP `scope_list` noise only; no GDScript errors | `godot_editor_read` get_log_messages error | Pass |
| Combat rules | Unchanged (preview restore) | Live wheel not mutated by hover | JSON live_wheel_after_preview | Pass |

## Bugs

None remaining.

Loop 1: mid-beam `+N` stacked on the heart numeral and could be read as +4. Removed beam labels; +1 now in a badge above the icon.

## Balance notes

Not a balance change. Lich +1 HP / Commander +2 ATK / Wraith copy match the live late-buff pass.

## Player-facing copy issues

None. Cue is the existing locked mill seat line.

## What was fixed this loop

- Loop 1/2: Fake ×2 links on non-Queen neighbors; Lich self +3 ATK from comparing to an empty slot. Baselines are now the pending card’s own ATK/HP; ×2 only for Spider Queen.
- Loop 2/2: Mid-beam labels misread as +4. Dropped them; +1/+2 use a badge on the affected icon.
- Still left: nothing for this feature.

## Next agent: start here

1. Hover telegraph is `_refresh_seat_preview` in `scripts/main.gd`, drawn by `boss_wheel.gd` `seat_fx` / `_draw_seat_fx`.
2. It simulates a sit, diffs ATK/HP, restores the wheel, then overlays preview + beams. Do not leave the pending monster in `wheel`.
3. Re-test by mill-seating Lich between two owners; beams must hit the HP icons and live numbers must stay the same until click.
