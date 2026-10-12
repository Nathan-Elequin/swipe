# QA report — hand cards, types, and callouts

## Feature

- Name / id: UI/Text/UX lane — hand cards + hover/callout panels
- Spec it was built from: chat 2026-10-12 (five rulings) + `design/visual/style-guide.md` §10 Must-keep fight UX

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Shift does not resize cards | height stays 210 | before=(140, 210) after=(140, 210) | `check_item_types.gd` `SHIFT_SIZE` | Pass |
| Type matches JSON `card_color` | every catalog item; Hook / Flask not ATK | 42 items OK; `HOOK_KIND=UTILITY FLASK_KIND=UTILITY` | `ITEM_TYPE_OK checked=42` | Pass |
| Hand clicks still work | spinning IGNORE, fighting STOP, Shield Block | IGNORE=2, STOP=0, blk 0→4 | `check_hand_use.gd` `HAND_USE_OK` | Pass |
| Boot / layers | title, Shield BLK 4, Goblin `no_atk_dmg`, scripts load | `BOOT_OK`; all 10 lane files OK | `check_boot.gd` / `check_layers.gd` | Pass |
| Item hover top-right | fly_tip pinned at `vp.x - width - 24, 28` | `_pin_top_right` / `_place_fly` | no display / godot-mcp | Note |
| Facing + hovered monster | ability name capsule + explainer | `look.call` + speech on `face_box` / fly_tip | no display / godot-mcp | Note |
| Log only on Shift / top-right hover | hidden when a callout is up | `_sync_authoring_chrome` `callout_up` | no display / godot-mcp | Note |
| Locked copy unchanged | no `data/` prose edits | no `data/` in this branch | git | Pass |
| No "Tier" on player screens | Weak / Tough / Deadly only | no copy change | git | Pass |

## Bugs

None in the headless checks. Facing callout, item pin, and log overlap were not screenshot-verified (dummy renderer, no godot-mcp).

## Balance notes

No combat math or ops changes. `_item_view` still overwrites gameplay `kind` from `card_color_family`. Only the card label uses `display_kind`.

## Player-facing copy issues

None. Did not edit `data/player-copy.json` or author-locked fields.

## What was fixed this loop

- Loop 1/3: utility `card_color` no longer paints ATK; Shift min-size stayed 210 after locking `_get_minimum_size` and keeping the number slot at 40px; item callout is top-right `hover_panel`; monster callout shows name + explainer; log hides while that callout is up.
- Still left: in-editor screenshots.

## Next agent: start here

1. In Play, hold Shift on Grappling Hook / Poison Flask: no ATK tag, card height unchanged, formula readable under the number.
2. Hover an item: details top-right, log gone.
3. Facing monster always has ability name + explainer beside the wheel.
