# QA — 2026-10-10 color pick paint + monster Hover math removed

## Feature

- Name / id: Painted Card color dropdown; monster Hover math field removed
- Spec: chat UI. No locked copy rewritten.

## Result

PASS

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Color dropdown is the paint | Closed control shows Heal green | Fill `(0.141, 0.227, 0.133)`; green Heal control with swatch | screenshot Cursed Scroll Edit card | Pass |
| Goblin sheet | Call name, Shift line, Speech. No Hover math | Keys have no `explainer` | goblin editor screenshot + dump | Pass |
| Locked copy | Unchanged | Goblin ability/call/reminder untouched | screenshot | Pass |
| Errors | None from game scripts | DAP only | get_log_messages | Pass |

## Bugs

None.

## Balance notes

Not a rules change. Monster `explainer` still exists in JSON if it was saved; it is not shown and not used in the fight HUD.

## Player-facing copy issues

None.

## What was fixed this loop

- Loop 1: PopupMenu `set_item_custom_bg_color` does not exist in this Godot — dropped it, used swatches + painting the OptionButton.
- Still left: none.

## Next agent: start here

1. Monster player texts are call_name, reminder (Shift), ability (speech). Do not put explainer back on the monster sheet.
2. `UxStyle.paint_color_pick` skins the Card color OptionButton.
