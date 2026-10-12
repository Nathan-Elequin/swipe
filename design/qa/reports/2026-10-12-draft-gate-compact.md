# QA report — compact draft gate

## Feature

- Name / id: draft-gate compact ask panel
- Spec it was built from: Nathan chat rulings 2026-10-12 (shrink ~40%, 60/40 item/threat, click item to take, Leave uses pass copy, wheel-tier severity). Copy/UI checklist.

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Headless parse | No script errors in game scripts | `--quit-after 2` after import: no `scripts/draft_gate.gd` / `wheel_hud.gd` / `main.gd` parse errors | Godot 4.7.2 log, exit 0 | Pass |
| Right screen | Compact ask panel, header `cue.ask` | `header=Take it or leave it?` | `check_hand_use` gate dump | Pass |
| Take is the item | No Take button; click item takes | `take_present=false`; `_on_gate_send` reached `seat` with Grief Jar | `check_hand_use: take ok action=seat item=Grief Jar` | Pass |
| Leave spends a pass | `door.pass` / `_one` / `_none`; disabled at 0 | `Leave it (3 passes left)`; 3 → 2 | `check_hand_use: leave spent a pass: 3 → 2` | Pass |
| No overlap | Column never covers hand, including 2-row reserve | column `[1086,28,560,526]` bottom 554; two-row hand top 566; `overlap=false` | `qa_probe` `layout` | Pass |
| Threat language | Weak/Tough/Deadly, never "Tier" | `threat=Tough`, `tier=2` internal only | gate dump | Pass |
| Hand use still works | Shield grants Block | BLK 0 → 4 | `check_hand_use: hand_use blk=4` | Pass |
| Locked copy | No `data/` edits | `git diff -- data/` empty | git | Pass |
| Unreadable / shot | Offscreen shot of ask | Headless dummy renderer cannot `texture_2d_get`; no PNG this run | log: skipped `_save_shot` on `headless` | Pass with notes |
| Errors | None in our scripts | Addon MCP parse noise only when import cache missing; clean after `--import` | Godot log | Pass |

## Bugs

None that fail the rule. Headless cannot screenshot the panel (dummy renderer). F5 Play is the visual check.

## Balance notes

No combat numbers changed. Shield still granted Block 4. Leave still spends one of three passes.

## Player-facing copy issues

None. `door.pass` / `door.pass_one` / `door.pass_none` / `cue.ask` / `tier.N.name` already had the wanted lines. Author-lock rows were not edited. `design/LANES.md` and a Must-keep UX section in `design/visual/style-guide.md` were not in the repo.

## What was fixed this loop

- Loop 1: first `check_hand_use` failed because Dive In has no Shield and Spin did not finish in 240 frames. Forced a fight + injected Shield. Draft take/leave already passed on that run.
- Loop 2: RESULT PASS (BLK 0→4, leave 3→2, take to seat, no overlap).
- Still left: in-editor / F5 screenshot of Weak vs Deadly chrome.

## Merge re-verify (2026-10-12, onto 43b9d4f)

Ported onto the lane split. `scripts/main.gd` is 82 lines (boot only). Combined `check_hand_use` now includes main’s FILTER/USE/CLICKS plus mill take/leave/clearance.

| Check | Actual | Evidence | Pass/Fail |
|---|---|---|---|
| `--quit-after 2` | No game-script errors | Godot 4.7.2 log | Pass |
| `check_layers` | All 10 lane scripts load | `LOAD … OK` | Pass |
| `check_boot` | title, HP 6, Shield BLK 4, Goblin `no_atk_dmg` | `BOOT_OK` | Pass |
| Spin filter | IGNORE while spinning, STOP while fighting | `FILTER_OK` | Pass |
| Shield pick | blk 0 → 4 | `USE_OK` | Pass |
| Door clicks | Take gone; Leave `Leave it (2 passes left)` STOP; item filter 0 | `CLICKS_OK` | Pass |
| Mill layout | column `[1086,28,560,526]` bottom 554 / two-row top 566, `overlap=false` | `LAYOUT_OK` | Pass |
| Leave / take | passes 3 → 2; take reached seat (`Lantern`) | `LEAVE_OK` `TAKE_OK` `HAND_USE_OK` | Pass |

`design/LANES.md` and style-guide §10 Must-keep UX are now on main and were kept.

## Next agent: start here

1. F5 Play → mill. Confirm the brown column stops above a two-row hand and Deadly reads as a big red-glow block.
2. Click the item (not a Take button) to take; click Leave to spend a pass.
3. If Nathan wants a PNG, capture from the editor — headless dummy cannot.
