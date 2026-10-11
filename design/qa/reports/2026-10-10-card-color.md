# QA — 2026-10-10 card color dropdown

## Feature

- Name / id: Item `card_color` (Edit card + Roster)
- Spec: chat UI. Author picks Attack/Block/Heal/Defeat/… fill instead of ops guessing. No locked copy rewritten.

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Edit card dropdown | Card color on item sheet | Auto, Attack red, Block blue, Heal green, Defeat purple, Utility yellow, Smoke mauve, Chaos violet | screenshot of Edit card · Cursed Scroll | Pass |
| Heal fill | Green, not Attack red | `_item_view` fill `(0.141, 0.227, 0.133)` kind `HEAL` with `card_color=heal` | godot_exec dump | Pass |
| Auto still default | Empty ops still Auto | Editor selected Auto for unsaved Cursed Scroll | screenshot | Pass |
| Locked copy | Unchanged | No ability/explainer edits | no player-copy rewrite | Pass |
| No "Tier" on player mill | Editor may say Tier | Editor only | screenshot | Pass |
| Errors | None from game scripts | DAP debugger noise only | `get_log_messages` severity error | Pass |

## Bugs

None that block this pass.

## Balance notes

Not a rules change. Combat ops stay as they are; this only sets the card’s background (and the matching Attack/Block/Heal/Defeat badge family).

## Player-facing copy issues

None.

## What was fixed this loop

- Loop 1: added `card_color` to Edit card, Roster, HTML board, catalog merge, live mill/hotbar stamp.
- Still left: Cursed Scroll stays Auto until Nathan picks Heal and Saves.

## Next agent: start here

1. Field is `card_color` (`atk` / `blk` / `heal` / `defeat` / `utility` / `smoke` / `chaos`, or empty = Auto).
2. Do not infer Heal for empty ops in code — that is what this dropdown is for.
3. Do not rewrite locked Cursed Scroll ability/flow.
