# QA — 2026-10-10 output-first item color

## Feature

- Name / id: Item paint uses the card’s output (Bracers Block-blue even when the formula names Attack)
- Spec: chat 2026-10-10; Copy/UI checklist

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Bracers ability | Block + formula Attack chips are Block-blue `#6BB3D9`, not Attack-red | Both Block and Attack are `#6BB3D9` | `evidence/2026-10-10-output-color.json` `bracers_body` | Pass |
| Bracers formula | `(Neighbor ATK)` is Block-blue | `[color=#6BB3D9](Neighbor ATK)[/color]` | same json `bracers_eq` | Pass |
| Helmet | Block output; HP words in the formula are Block-blue | body + eq `#6BB3D9` | same json `helmet_*` | Pass |
| Crossbow control | Attack output stays red | `#E07A7A` on 4 Attack | same json `crossbow_body` | Pass |
| Locked text unchanged | No rewrite of board/player-copy prose | Paint only wraps BBCode | no player-copy edit this pass | Pass |
| No “Tier” | Not shown on this inspect | Not in dumped strings | json | Pass |
| Errors | No parse/red errors after `face_t` fix | Editor log silent after reload | `godot_editor_read` errors since cursor 7: none | Pass |
| Fight screenshot | Inspect panel on screen | Roster was open in the running game; no fight shot | note | Notes |

## Bugs

None in the color rule.

## Balance notes

n/a

## Player-facing copy issues

- Bracers ability still says “weaker Neighboring enemy’s Attack.” Code still uses the right-hand neighbor, not the weaker of the two. Flag only.
- Cursed Scroll locked Ability still says “At the start of each combat.” Shipped tax is after every Spin. Nathan had Roster open rewriting that sentence; do not overwrite.

## What was fixed this loop

- Loop 1: `face_t` parse error blocked launch. Renamed to `face`. Reload succeeded. Color probes passed. No retest needed.

## Next agent: start here

1. Output color lives in `UxStyle.paint(..., output_kind, formula)` and `Main._paint_item_text`.
2. Spiked Shield still uses mixed Attack/Block chips on purpose (two outputs).
3. Do not close Roster if it is open with unsaved orange/red cells.
