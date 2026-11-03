# Rope Exit chamber — dynamic tally wall (spec)

Status: art only. Not wired into Godot. Pixel reviews this with Nathan first.
Generators: `gen/make_chamber.py` (background, with `TALLY_RECT`) and `gen/make_tally.py` (overlays and previews).

## Wall rect
| | x | y | w | h |
|---|---|---|---|---|
| native 420×260 | 92 | 82 | 56 | 44 |
| 4× 1680×1040 | 368 | 328 | 224 | 176 |

- The rect is on the left wall: below the Bartleby pendant (y 45–62), right of the left torch (x ≈ 52), above the crates (tops at y 151), and left of the green shaft edge (x ≈ 146 at this height).
- The background has the rock cracks softened inside the rect and 1px around it, so chalk reads cleanly. There are no baked tallies.

## Max and layout
- **Max 50** = 10 groups of 5.
- **Layout: 2 rows × 5 groups.** Each row = 25 marks; it reads left to right like a ledger.
- Group cell is 10×12. Column pitch is 11 px; row pitch is 22 px. Group `g` (0–9) has this top-left inside the rect:
  `ox = 1 + (g % 5) * 11`, `oy = 4 + (g / 5) * 22`
  - At native that is `(92 + ox, 82 + oy)`. At 4× it is `((92 + ox) * 4, (82 + oy) * 4)`.
- Inside a group, the 4 strokes sit at (1,1), (3,2), (5,1), (7,2). Each stroke is `prop_tally_stroke.png` (2×10: chalk plus a 1px dark scratch shadow).
- The 5th mark is a slash from (0,10) to (9,2). It's baked into `tally_group5.png` and `tally_sheet.png` frame 5.
- For a partial group with n = 1–4 marks, use `tally_sheet.png` frame n-1 (5 frames of 10×12, laid out horizontally).

## Swap at 50
- When `count >= 50`, hide all groups and show `tally_bartleby_chalk.png` (56×44) at the rect origin.
- It's a chalk portrait of Bartleby: hood with a bent tip, long ears, spectacles, bulb nose, grin, beard and cloak shoulders. It has no text and no numbers.
- Story beat: we stopped counting and drew Grandpa.
- Optional: a one-time reveal (tallies fade out, chalk fades in) the first time `count` crosses 50. Any wording for that moment comes from Nathan or the copy keys. **Never invent copy.**

## Count source (Cursor: read before wiring)
- Nathan's intent: one new tally **every time the player clears a dungeon, lifetime**.
- `main.gd` has `var dungeons_cleared`, which it passes into `rope_exit.open_exit(dungeons_cleared, …)`. That is the **per-run** belly count: it resets to 0 in several places (lines ≈2309, 2466, 2976) and goes up by 1 per clear (≈2541).
- `home_cabin.gd` has `deepest_belly` (a best depth, not a running total).
- Neither is a lifetime total. Before wiring, add or confirm a persisted lifetime counter (for example a saved `total_dungeons_cleared` that goes up wherever `dungeons_cleared += 1` runs), and drive the wall from that:
  `count = clamp(lifetime_clears, 0, 50)`
- If Nathan instead wants the wall to show this run's depth, use the `cleared` argument of `open_exit` directly. Pick one; don't mix them.
- (Line numbers are from a local snapshot at `/tmp/sw`, commit cef99200, 2026-11-01; check them against the current tip.)

## Asset list (out/, RGBA, alpha 0/255 only, plus `_4x` nearest previews)
- `prop_tally_stroke.png` 2×10
- `tally_group5.png` 10×12
- `tally_sheet.png` 50×12 (frames 1–5 marks)
- `tally_bartleby_chalk.png` 56×44 (same box as the wall rect)
- Previews over the background: `preview_tally_00.png`, `preview_tally_23.png`, `preview_tally_49.png`, `preview_tally_50_bartleby.png`
- There is no separate empty wall patch; the background already carries the calmed rect.

Colours: chalk `#c9b9a8`, chalk highlight `#e8dcc4`, scratch shadow `#100e0c`. All are already in the cabin palette; the background stays at 44 colours.
