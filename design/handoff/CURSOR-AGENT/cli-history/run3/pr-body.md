Build pass 3 of the animation plan (`design/visual/BUILD-ORDER.md`): the spin cascade ticker and Shift-held fast-forward. Implemented with the Cursor CLI. Logs are in `design/cli-runs/11-anim-pass3/`: `PROMPT.md` is the Pass 3 prompt verbatim, and `PROMPT-fix.md` is the follow-up that adds the final art and a check that any seat count works.

## What changed
- **New `scripts/cascade_ticker.gd`**: a token strip under the wheel (y ≈ 690).
  - `begin()` runs after `_bleed_begin()` in `_on_spin`, and `end()` runs at `_unlock_if_fighting()`.
  - A token is pushed whenever a step actually fires (`_announce_slice`, `_flash_banner` item triggers, `_tick_player_poison`, `_tick_monster_poison`). Tokens reuse the monster stills and item icons.
  - `ability_slash` gets `payload["ticket"]`, so a token lights while its cut-in plays and stamps when the cut-in ends.
  - The strip lays out any number of tokens and doesn't depend on the seat count (QA has a 6-seat shot).
- **Shift fast-forward** (`_process`):
  - Holding Shift during a busy fighting or slaying cascade runs it ×3, with a ▶▶ chip on screen.
  - It drops back to normal on release, at unlock, on a phase change and on focus-out.
  - The game's normal animation speed is `ANIM_TIME_SCALE = 0.675`, so ×3 sets `Engine.time_scale` to 2.025 and release restores 0.675. The CLI's first version forced 1.0/3.0, which would have made every cascade run faster than normal even without Shift.
  - Space, `ui_accept` and the input map are unchanged, and no Spin shortcut was added. Hold-Shift-to-explain still works, and its panel no longer steals focus (`hover_panel.gd`).

## Art (`assets/ui/anim/`, imported with Nearest, no mipmaps, Lossless)
- **Final PixelLab art:**
  - `ticker_token_frame`, `ticker_token_stamp_f0..f3`, `ticker_ff`
  - the pass 1 intent files that were still placeholders: `intent_claw_idle`, `intent_claw_lit_f0..f3`, `intent_claw_burst_f0..f3`, `intent_claw_flame_idle`, `intent_claw_flame_burst_f0..f3`, `intent_chip_shield/drop/flee`
- `PLACEHOLDERS.md` is updated.

## QA (1680x1040, shot harness)
godot-mcp attaches to the open editor on the main folder, not this worktree, so the shots come from the repo shot harness.

Screenshots in `design/visual/anim-qa/spin-cascade-ticker/`:
- `01_cascade_300ms`, `02_cascade_900ms`, `03_cascade_1800ms`
- `04_cascade_ff_600ms` (▶▶ visible)
- `05_cascade_ff_release`
- `06_space_untouched`
- `07_six_seats`
- `08_intent_plate_final_art`

Results:
- Logged speeds: ×3 held gives `time_scale=2.025` with the chip on. Release goes back to `0.675`.
- `godot --headless --quit` exits 0 with no script or parse errors.
- The text audit finds no "Tier".

Not exported or pushed to itch.
