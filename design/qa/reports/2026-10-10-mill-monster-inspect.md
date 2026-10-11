# QA report — mill monster inspect body

## Feature

- Name / id: mill monster plate shows inspect-hover ability
- Spec it was built from: chat — mill card default should be the top-right inspect text you get by hovering that monster in a fight, under the call name, not a Shift-only speech balloon

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Right screen | Twins mill plate shows Double Trouble plus the inspect-hover ability sentence | Name, 6/6, Double Trouble, then the locked ability | `design/qa/reports/evidence/2026-10-10-mill-monster-inspect.json`; in-game mill screenshot this turn | Pass |
| Locked text unchanged | Ability / explainer / call_name not rewritten | This turn did not edit `player-copy.json` / board / catalog | Git: no agent edits to those files this change | Pass |
| No "Tier" | Weak / Tough / Deadly only if rank is shown | Cue is "A monster approaches. Select their location." No Tier | Screenshot | Pass |
| Unreadable | Ability readable under the call name | Cream body on dark plate; Attack red / Block blue | Screenshot | Pass |
| Errors | None from this change | Only DAP `!scope_list.has(_current_frame)` | `godot_editor_read` get_log_messages severity error | Pass |

## Bugs

None that block this change.

## Balance notes

Twins 6 ATK / 6 HP. Mill only; no fight.

## Player-facing copy issues

- Paint treats the word **twice** in the locked Twins ability as a number-word, so it chips red like Attack. Do not rewrite the locked sentence. Flag only.

## What was fixed this loop

- Loop 1/3: mill owner plate body = `_monster_rule.speech` (same as `_fill_inspect_from_slice`). Mill Shift no longer opens a speech balloon over that plate.
- Still left: "twice" keyword color.

## Next agent: start here

1. If Nathan wants mill Shift to still show reminder math, add it under the ability instead of replacing Double Trouble.
2. Do not write locked Twins ability / explainer / reminder.
