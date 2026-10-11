# QA — 2026-10-10 keyword marks

## Feature

- Name / id: Inline keyword styling (Attack, Block, Keep, numbers)
- Spec: chat UI. Colored words on the baseline instead of background boxes. No locked copy rewritten.

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Mill sentence | Keywords sit in the line, no overlapping boxes | `ATK 3, or ATK 1 and Keep this item` as colored words | mill screenshot this chat; probe `has_bg: false` | Pass |
| Mill Shift | Formula replaces the stat; sentence stays | `(3) or (1 and Keep)` inline, no pills | Shift mill screenshot | Pass |
| Inspect | Same marks as mill | Shield: `Gain 4 Block.` with `4` and `Block` in blue on the line | `design/qa/reports/evidence/2026-10-10-keyword-marks.png` | Pass |
| Locked copy | Unchanged | paint wraps existing ability text | no player-copy / board prose edits | Pass |
| No "Tier" | Player HUD | None on mill or inspect | screenshots | Pass |
| Errors | None from game scripts | DAP debugger noise only | `get_log_messages` severity error | Pass |

## Bugs

None that block this pass.

## Balance notes

Not a rules change.

## Player-facing copy issues

None. `throwing_knife` ability still reads `Atk 3, or Atk 1 and Keep this item`. Highlighting only wraps it.

## What was fixed this loop

- Loop 1: dropped `[bgcolor]` pills and padding spaces; merged `ATK 3` into one mark; skipped Item/Enemy/Owner as keywords.
- Still left: mill card still has empty brown below a short sentence (layout, not the marks).

## Next agent: start here

1. Keyword look lives in `scripts/ux_style.gd` `chip()` / `paint()`. Tutorial and the editor preview use that same path.
2. Do not put `[bgcolor]` back on player sentences.
3. Do not rewrite locked ability strings to “fix” wrapping.
