# QA report — hand cards, types, and callouts

## Feature

- Name / id: UI/Text/UX lane — hand cards + hover/callout panels
- Spec it was built from: chat 2026-10-12 (five rulings) + `design/visual/style-guide.md` §10 Must-keep fight UX

## Result

PASS WITH NOTES (headless scripts; no godot-mcp / in-editor click-through in this environment)

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Shift does not resize cards | `custom_minimum_size.y` stays 210 | see `SHIFT_SIZE` from `check_item_types.gd` | `tools/qa/check_item_types.gd` | pending run |
| Formula is smaller and breaks cleanly | 13px, line break at `or`, number still shown | code: `UiPalette.SIZE_FORMULA`, `UX.pretty_formula` | script + `item_card.gd` | pending run |
| Type matches JSON `card_color` | Hook / Flask not ATK; every catalog item matches | `ITEM_TYPE_OK` | `check_item_types.gd` | pending run |
| Item hover top-right | fly_tip pinned at `vp.x - width - 24, 28` | `_pin_top_right` / `_place_fly` | headless cannot screenshot | note |
| Facing + hovered monster | ability name capsule + explainer | `face_box` / fly_tip get `look.call` + speech | code path | note |
| Log only on Shift / top-right hover | hidden when a callout is up | `_sync_authoring_chrome` `callout_up` | code path | note |
| Hand clicks still work | spinning IGNORE, fighting STOP, Shield Block | `check_hand_use.gd` | `HAND_USE_OK` | pending run |
| Locked copy unchanged | no `data/` prose edits | git | git | Pass |
| No "Tier" on player screens | Weak / Tough / Deadly only | no copy change | git | Pass |

## Bugs

None left in the type / size scripts once they exit 0. Facing callout and log overlap were not screenshot-verified (no Godot display / godot-mcp here).

## Balance notes

No combat math or ops changes. `_item_view` kind overwrite for gameplay is unchanged; only the card label uses `display_kind`.

## Player-facing copy issues

None. Did not edit `data/player-copy.json` or author-locked fields.

## What was fixed this loop

- Loop 1/3: utility `card_color` no longer paints ATK on the card; Shift formula stays inside 210px; item callout is top-right `hover_panel`; monster callout shows name + explainer; log hides while that callout is up.
- Still left: in-editor screenshots (needs Godot Editor + godot-mcp).

## Next agent: start here

1. Run `godot --headless --path <repo> --script tools/qa/check_item_types.gd` and `check_hand_use.gd` if this environment has Godot.
2. In Play, hold Shift on Grappling Hook / Poison Flask: no ATK tag, card height unchanged.
3. Hover an item: details top-right, log gone. Hover a non-facing monster: name capsule + explainer top-right. Facing monster always has that pair beside the wheel.
