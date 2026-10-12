# QA report — screen layout split + Spin/resolve buttons

## Feature

- Name / id: Screen layout (left draft / center wheel / right monster) and combat action buttons
- Spec it was built from: Nathan's rulings 0–6 in chat (2026-10-12). Must-keep fight UX §10. Paper Fight skipped — layout and a visibility bug, no new combat rule.

## Result

PASS

Godot 4.7.2.stable headless dummy renderer (`/tmp/godot/Godot_v4.7.2-stable_linux.x86_64`). No godot-mcp in this cloud run, so no in-editor stills. Evidence is `tools/qa` print lines below.

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Spin / Done stay clickable | Draft Leave + item take; ready Spin; fighting Done / Safe / Take X | Leave visible STOP; Spin visible STOP; Take 3 visible STOP | `check_action_buttons.gd` `DRAFT_OK` / `SPIN_OK` / `RESOLVE_OK text=Take 3` / `ACTION_BTN_OK` | Pass |
| Top-left hearts hidden | `hearts_box.visible == false`; hub hearts only | `hearts_visible=false` at draft and fight | probe `buttons.hearts_visible` in `DRAFT_BTNS` and `FIGHT_BTNS` | Pass |
| Draft on the left | Column ~336px at x=32; Nib x < 400 | column `[32,28,336,526]`; Nib x=75 | `check_hand_use` `DRAFT_LAYOUT` / `DRAFT_GATE`; `check_fixes_v2` `COLUMN [32,28,336,572]` | Pass |
| Gate item = hover callout | `qa_snapshot.callout == true` | `callout=true`, item name Healing Potion / Breastplate | `check_action_buttons` `DRAFT_OK callout=true`; `check_hand_use` `DRAFT_GATE` | Pass |
| Wheel + hand centered | Wheel center x=840; hotbar centered under Spin | `wheel_center=[840,350]`; spin `[710,694,260,68]`; hand `[539,778,602,210]` | `check_hand_use` `DRAFT_LAYOUT` | Pass |
| Hub hearts / wheel size | OUTER_R 330, HUB_R 72, pips 20×17; no seat overlap | 5 seats upright, Hornet capsule 110×50, no overlap | `check_fixes_v2` `WHEEL_OK seats=5` | Pass |
| Event log off | Shift does not show it; toggle `_play_log_enabled` does | Shift visible=false; toggle visible=true at `(32,640,336×200)` | `check_fixes_v2` `LOG_OK off unless Developer toggle` | Pass |
| No Tier on player screens | Weak / Tough / Deadly only | threats=Weak,Tough,Deadly | `check_fixes_v2` `GATE_OK` | Pass |
| Layers / boot / item types | Existing checks still pass | layers OK; `BOOT_OK`; `ITEM_TYPE_OK checked=42` | `check_layers`, `check_boot`, `check_item_types` | Pass |
| Hand use / mill | Click item uses; Leave spends a pass; take seats | Shield blk 0→4; Leave 3→2; take → seat | `check_hand_use` `HAND_USE_OK` | Pass |
| Nib vs hand | Nib stays above the hotbar | Nib y=466, hand y=778 | `check_hand_use` `DRAFT_GATE` nib `[75,466,88,88]` | Pass |
| Combat always-checks | Attack vs Bleed; Block; Dragon; Goblin; Defeat paths | not in this change | — | skip |
| Errors | No red parse / runtime errors | only known headless RID leaks at exit | Godot stderr | Pass |

## Bugs

None remaining after loop 2.

1. **Repro (fixed)** — `_sync_buttons` set `btn_done.visible = false` every refresh, so Done / Safe / Take X never came back after a spin.
2. **Likely file + function** — `scripts/ui/hud_controller.gd` `_sync_buttons`
3. **Suggested fix** — `btn_done.visible = enemy_up` (shipped)
4. **Severity** — wrong rule (game unplayable)

1. **Repro (fixed)** — Nib well used the gate's unclipped `size.y`, so it landed on the hotbar at y=775.
2. **Likely file + function** — `scripts/draft_gate.gd` `_place_nib`
3. **Suggested fix** — place from `get_global_rect()` and clamp above a two-row hand (shipped)
4. **Severity** — polish / overlap

## Balance notes

Golem ATK 3 HP 7. Shield Block 0 → 4. Resolve label `Take 3` with blk 0. No number changes.

## Player-facing copy issues

None. Did not edit `data/player-copy.json` or author-locked board fields. Threat plates show Weak / Tough / Deadly.

## What was fixed this loop

- Loop 1/3: `_sync_buttons` now sets `btn_done.visible = enemy_up`. Layout split, hub grow, hover-panel reuse in the draft gate, event-log Developer toggle. All six `tools/qa` scripts returned OK.
- Loop 2/3: `_place_nib` used unclipped height and sat on the hand. Clamped under the visible column (Nib y=466, hand y=778). `HAND_USE_OK` again.
- Still left: no godot-mcp stills.

## Next agent: start here

1. If `check_action_buttons` fails on resolve visibility, read `_sync_buttons` in `scripts/ui/hud_controller.gd`.
2. If a check fails on column x or Nib y, read `scripts/wheel_hud.gd` `_fit_column_above_hand` and `scripts/draft_gate.gd` `_place_nib`.
3. Do not overwrite `data/` or `item_card.gd`.
