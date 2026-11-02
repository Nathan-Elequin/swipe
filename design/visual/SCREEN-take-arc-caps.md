# SCREEN: Take arc rounded caps + arced Take (2026-11-02)

Nathan greenlit polish on the H3-B2 cream Take arc under the wheel. Live tip had square radial cuts and flat horizontal "Take" + burst. Doop H3-B2 mock showed rounded-end intent; arced text is new.

Refs (task attachments): `nathan-take-flat.png` = live tip (flat Take, square ends); `doop-h3-b2.png` = Doop H3-B2 mock (rounded ends intent; text still flat).

## Look lock

1. **End caps** — Ovular disk caps at t=0 and t=1, same stack as move-arrow `_draw_tail`: ink `half+2`, wood `half-1`, face `half-4`, outward `draw_arc` highlight ±0.7 rad in hi (width 2). No trim bead on Take caps.
2. **Take / Safe word** — Follows the band midline curvature via per-char `draw_set_transform` (`a - PI/2`). Locked Spin copy strings unchanged.
3. **Damage burst + hit number** — Same rotation as the word at their arc seat; drawn local around `-size/2`.
4. **Block pip** — Rotates to match the left-third chord angle when Block > 0.
5. **One click target** — Whole arc still one Button; `_has_point` also accepts the cap discs (`BODY_W*0.5+2` of each chord tip).
6. **Sweep** — `SWEEP` nudged to `1.32` (was `1.42`) so caps stay clear of move-arrow tails. Selftest allows ~1.0–1.7.

## Code

- `scripts/ui/take_arc.gd` — `_draw_end_caps`, `_draw_arc_text`, rewritten `_draw_take_side` / `_draw_block_pip`, rect + hit extensions
- `scripts/dev/take_arc_selftest.gd` — `hit_left_cap` / `hit_right_cap`

## Out of scope

Player-facing Take/Safe words. Item cards. Defeat. Splash. Move-arrow art itself.
