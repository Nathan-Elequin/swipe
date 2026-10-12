# QA report — Wheel layout tightening

## Feature

- Name / id: Wheel seats, hub, and name capsules (`scripts/boss_wheel.gd`)
- Spec it was built from: Nathan fight-screen notes 2026-10-12 (sprites too big, HP/ATK too far apart, capsules awkward, hub ~40% too large). Must-keep UX: `design/visual/style-guide.md` §10.

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Sprites smaller so alcoves read | Seat sprite well under the old 84 px restore | `SPRITE` 84 → 56, `SEAT` 100 → 64, `SEAT_R` 200 → 188 | `scripts/boss_wheel.gd` consts | Pass |
| Heart left, sword right, close | Screen-left HP / screen-right ATK, not opposite rim sides | `ICON_GAP` 28; `_spoke` uses `Vector2(±ICON_GAP/2, pair_y)` | `_spoke` | Pass |
| Capsules smaller, inside the rim | Nunito 18, near the monster, no rim / neighbor overlap | Fonts `UI.SIZE_MIN` (18), pad 7/3, `max_w` 70–112, `_fit_title_rect` clamps inside rim and outside hub | `_draw_slice_title` / `_fit_title_rect` | Pass |
| Hub ~40% smaller and filled | Knight + six-heart arc + shield Block fill the disc | `HUB_R` 96 → 58; knight `1.38× / 1.86×` hub; hearts at `0.80` hub; shield at `0.50` hub. No HP numeral | `_draw_hub_block` | Pass |
| Must-keep: tier fill+rim | Weak / Tough / Deadly wedge fill and rim | `_draw_slice` still runs; baked alcove PNGs (hub r 96) hidden | `_draw` / `_build_alcoves` | Pass |
| Must-keep: monsters face knight | Flip toward hub | `port_pos.x >= center.x` still flips the portrait | `_draw_slice_contents` | Pass |
| Must-keep: buttons under arrow | Spin / Take-hit stay under the gold pointer | `wheel_hud.gd` pointer (530,664), buttons (418,700) unchanged. Outer r still 300 | `scripts/wheel_hud.gd` | Pass |
| No collision with hand / callout / draft | Do not grow into y 790, x 1086, or the facing plate | Outer r stayed 300. Wheel control still 624×624 at (236,38). No `hud_controller` hand/callout edits | git + `_layout` in `wheel_hud.gd` | Pass |
| Hand still usable after Spin | Filter IGNORE while spinning, STOP in fight; Shield raises Block | `FILTER_OK` / `USE_OK blk 0 -> 4` / `HAND_USE_OK` | `tools/qa/check_hand_use.gd` | Pass |
| Boot / layers | Title, HP 6, Shield BLK 4, Goblin `no_atk_dmg` | `BOOT_OK`; all lane scripts load | `check_boot.gd` / `check_layers.gd` | Pass |
| No "Tier" | Weak / Tough / Deadly only | No copy or board edits | git | Pass |
| Locked copy | Unchanged | No `data/` | git | Pass |
| Errors | No parse / script errors | Import clean; `--quit-after 2` exit 0. Shutdown RID leaks only (existing) | Godot 4.7.2 `--headless` | Pass |

## Bugs

None remaining from this layout pass.

## Balance notes

Headless Shield vs Golem: ATK 3 / HP 7, Block 0 → 4. Layout only. No always-win / always-lose.

## Player-facing copy issues

None. No `data/player-copy.json` or author-lock edits.

## What was fixed this loop

- Loop 1: shrink sprites, pair HP/ATK, compact capsules, hub 58 with knight / hearts / shield filling it. Hide baked alcove textures (inner hole was r 96). Re-verify `check_hand_use` after merging `origin/main` 43b9d4f.
- Still left: no godot-mcp, dummy renderer, so no in-editor screenshot of the tightened seats. Style-guide §5 still lists hub r 96.

## Next agent: start here

1. Play a full ring in Developer Test and look at Hornet Swarm / Damsel capsules — `_fit_title_rect` keeps them inside the rim; long names wrap at 18 px.
2. Do not turn baked alcove PNGs back on unless you redraw them for hub r 58. Metal wedges own Weak / Tough / Deadly fill+rim.
3. `tools/qa/check_hand_use.gd` must still pass after any `hud_controller` / hand-card mouse_filter change.
