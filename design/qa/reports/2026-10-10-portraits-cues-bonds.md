## Feature

- Name / id: Rounded metal portraits; hide mill/setup cue line; live adjacency beams (quiet idle / loud hover)
- Spec it was built from: chat. No rule change. Locked cue strings left in player-copy; they are not drawn.

## Result

PASS

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Portraits | Rounded square, metal rim, no glow, no star/hex | Rounded boxes with bronze/silver/gold rims | screenshot_game idle | Pass |
| Cue line | No "Take it or leave it" / seat / starters overlay | `cue_visible: false`, empty text | JSON + screenshot | Pass |
| Idle bonds | Quiet transparent beams to the affected HP/ATK | Wraith: Wizard ATK → Wraith ATK. Lich → Skeleton HP. Commander → neighbor ATK | screenshot idle | Pass |
| Hover Commander | Same beams louder with sparks/arrows | Gold/red beams into Gargoyle and Lich Attack | screenshot hover | Pass |
| Locked copy | Do not rewrite cue strings | player-copy untouched; `_set_cue` hides the label | this turn | Pass |
| No "Tier" | | Names and metals only | screenshot | Pass |
| Errors | None | DAP noise only | editor log | Pass |

## Bugs

None remaining.

## Balance notes

Not a balance change.

## Player-facing copy issues

None. Cue keys still exist in player-copy and are unused on screen.

## What was fixed this loop

- Loop 1/1: Portraits use `UxStyle.round_plate`. Cue label always hidden. Live `_draw_bonds` uses scaled `_draw_sight_beam` (0.28 idle / 0.86 hover). Wraith beam is neighbor ATK → Wraith ATK.
- Still left: nothing for this request.

## Next agent: start here

1. Cue chrome is `cue_label` via `_set_cue("")` in `_refresh` — do not turn it back on unless Nathan asks.
2. Portrait shape is `UxStyle.round_plate`; rank is metal color, not star/hex.
3. Live adjacency is `_draw_bonds` in `boss_wheel.gd`; placement preview is still `seat_fx` at full strength.
