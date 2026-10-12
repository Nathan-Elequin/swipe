# QA report — screen layout split + Spin/resolve buttons

## Feature

- Name / id: Screen layout (left draft / center wheel / right monster) and combat action buttons
- Spec it was built from: Nathan's rulings 0–6 in chat (2026-10-12). Must-keep fight UX §10. Paper Fight skipped — layout and a visibility bug, no new combat rule.

## Result

PENDING — headless `tools/qa` run not finished in this write. Fill after Godot 4.7.2 `--headless` pass.

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Spin / Done stay clickable | Draft Leave + item take; ready Spin; fighting Done / Safe / Take X | pending | `tools/qa/check_action_buttons.gd` | |
| Top-left hearts hidden | `hearts_box.visible == false`; hub hearts only | pending | probe `buttons.hearts_visible` | |
| Draft on the left | Column ~336px at x=32; Nib x < 400 | pending | `check_hand_use` / `check_fixes_v2` GATE | |
| Gate item = hover callout | `qa_snapshot.callout == true` | pending | `check_action_buttons` DRAFT | |
| Wheel + hand centered | Wheel center x=840; hotbar centered under Spin | pending | `qa_layout` | |
| Hub hearts / wheel size | OUTER_R 330, HUB_R 72, pips 20×17; no overlap | pending | `check_fixes_v2` WHEEL | |
| Event log off | Shift does not show it; toggle `_play_log_enabled` does | pending | `check_fixes_v2` LOG | |
| No Tier on player screens | Weak / Tough / Deadly only | pending | `check_fixes_v2` GATE | |
| Layers / boot / item types | Existing checks still pass | pending | `check_layers`, `check_boot`, `check_item_types` | |
| Combat always-checks | Attack vs Bleed; Block; Dragon; Goblin; Defeat paths | not in this change | — | skip |
| Errors | No red parse / runtime errors | pending | Godot stderr | |

## Bugs

None logged yet. This pass is the first headless run of the layout + button fix.

## Balance notes

No combat number changes.

## Player-facing copy issues

None. Did not edit `data/player-copy.json` or author-locked board fields.

## What was fixed this loop

- Loop 1/3: `_sync_buttons` now sets `btn_done.visible = enemy_up` (was hardcoded `false`). Layout split, hub grow, hover-panel reuse in the draft gate, event-log Developer toggle.
- Still left: headless evidence.

## Next agent: start here

1. If `check_action_buttons` fails on resolve visibility, read `_sync_buttons` in `scripts/ui/hud_controller.gd`.
2. If a check fails on column x or width, read `scripts/wheel_hud.gd` `_fit_column_above_hand`.
3. Do not overwrite `data/` or `item_card.gd`.
