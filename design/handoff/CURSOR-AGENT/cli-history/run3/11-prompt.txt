Read design/visual/_COMMON.md and design/visual/ANIM-spin-cascade-ticker.md, then implement on branch anim/pass3-cascade-ticker. Passes 1-2 are merged.

Scope:
1. New scripts/cascade_ticker.gd: a strip under the wheel (y ≈ 690) with 48px stamp tokens.
   - Phase 1 (lazy) only: begin() after `_bleed_begin()` in main.gd::_on_spin, push(id, tex) when a step actually fires (hook `_announce_slice`, `_flash_banner` item triggers, `_tick_player_poison`, `_tick_monster_poison`), end() at `_unlock_if_fighting()`.
   - Token icons reuse the monster stills and item icons.
   - Pass `payload["ticket"]` to ability_slash so the token lights while its cut-in shows and stamps when it ends.
2. Shift fast-forward: in main.gd::_process, while phase is fighting/slaying and `_walker_busy`, `Input.is_key_pressed(KEY_SHIFT)` sets `Engine.time_scale = 3.0`; otherwise 1.0.
   - Restore to 1.0 in `_unlock_if_fighting()`, on phase change and on focus-out.
   - Show the ▶▶ chip while held.
   - Do NOT touch Space or ui_accept, and do NOT add a Spin shortcut.
   - The existing "hold Shift to explain" must keep working; just make sure the explainer doesn't steal focus.

Art placeholders at exact paths (Nearest, no mipmaps, Lossless), listed in assets/ui/anim/PLACEHOLDERS.md:
- assets/ui/anim/ticker_token_frame.png (12x12)
- assets/ui/anim/ticker_token_stamp_f0.png … _f3.png (12x12)
- assets/ui/anim/ticker_ff.png (12x8)

QA with godot-mcp at 1680x1040, saving to design/visual/anim-qa/spin-cascade-ticker/:
- Seat Plague Doctor, Spider Queen, Cultist and Harpy, and give the player Grief Jar and a Marble. Force-spin (qa_spin_idx) a Cultist neighbour.
- Shots at 300 / 900 / 1800ms.
- Repeat with KEY_SHIFT held: ▶▶ visible and the cascade about 3x faster (log Engine.time_scale).
- Release mid-cascade: back to 1.0.
- Space behaves exactly as before.

Commit on the branch with the files-changed summary and the screenshot list. Don't export or push to itch.
