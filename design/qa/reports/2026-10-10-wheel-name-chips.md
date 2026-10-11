# QA report — Wheel name chips (Hornet Swarm / Twice)

## Feature

- Name / id: Wheel slice title capsules (`scripts/boss_wheel.gd` `_draw_slice_title`)
- Spec it was built from: Nathan screenshot — "Hornet Swarm" and "Twice" were not centered in the chips meant to hold them.

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Hornet Swarm + Twice in the chip | Name and call centered in the same oval | After loop 2: both sit inside the gold facing pill, Twice under the name | screenshot_game, facing Hornet | Pass |
| Goblin + No Attack | Same treatment, shorter name | Text inside the left-side pill | same screenshot | Pass |
| Wizard + Spellbook | One-word name still fits | Small oval at top, both lines inside | same screenshot | Pass |
| No "Tier" | Weak/Tough/Deadly or nothing | Inspect "Hornet Swarm / Twice"; wheel chips have no Tier | screenshot | Pass |
| Locked copy | Do not rewrite names/calls | No player-copy or catalog string edits | git: only `boss_wheel.gd` | Pass |
| Errors | None | "No error messages (cursor 0)." | get_log_messages severity error | Pass |
| Loop 1 (fail) | Same as expected | Name sat on the *roof* of the pill: draw Y is baseline, not top | first screenshot this chat | Fail, then fixed |

## Bugs

1. **Loop 1 — text used the first-line baseline as if it were the top of the box.** Repro: Developer Test, seat Hornet Swarm, face it. Name rode the top edge; Twice looked low in the oval. File: `scripts/boss_wheel.gd` `_draw_chip_line`. Fix: add `font.get_ascent(fs)` to Y. Severity: unreadable / polish (layout).

## Balance notes

None. Draw-only.

## Player-facing copy issues

None. "Twice" is the existing call name.

## What was fixed this loop

- Loop 1: sized the capsule to the glyph box and centered in `inner_w` instead of `max_w` (the off-to-the-side bug). QA screenshot still showed the name on the roof.
- Loop 2: treat draw Y as baseline. Re-test screenshot: name and Twice inside the pill.
- Still left: chips sit out on the gold rim; inward nudge is mild on purpose.

## Next agent: start here

1. If Nathan still hates the Hornet chip, look at `_spoke` `nam: origin + dir * r * 0.90` — that is position on the rim, not the text math.
2. Do not restyle locked "Twice" / "Hornet Swarm" strings.
3. Keep using Developer Test + `screenshot_game` after any `_draw_slice_title` tweak; freeze hides nothing here because this is `_draw`.
