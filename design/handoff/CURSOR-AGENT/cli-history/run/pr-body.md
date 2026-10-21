Build pass 1 of the animation plan (`design/visual/BUILD-ORDER.md`): intent plate + Shark loop chip + HP-loss fix + Bleed pulse. Implemented with the Cursor CLI. Logs are in `design/cli-runs/09-anim-pass1/` (`PROMPT.md` is the pass 1 prompt verbatim, `PROMPT-fix.md` is the QA follow-up).

## What changed
- **HP-loss fix** (`scripts/main.gd`): `_tick_player_poison()` and `_player_take_atk()` now call `_note_hp_lost(...)`, and `_note_hp_lost` emits the new `signal bled(n)`. Pacemaker and Blood Chalice now see poison-tick and poke losses.
- **Intent plate** (new `scripts/intent_plate.gd` and `scripts/intent_badge.gd`; pure `_intent_hits()` in main.gd)
  - There is one claw badge per raw hit, and it lights as that hit lands on Take (`fire()` from `_owner_attack`).
  - When Block soaks a hit, its badge flashes blue and keeps the raw number.
  - Dragon uses the flame variant, and the plate clears at fight end and on leave.
  - Fixed a bug where Take cleared the plate on `slaying` before `fire()` ran. Also fixed the first-fight layout and sync.
- **Shark loop chip**: the wheel's ↻/∞/×2 tag drawing moved into `UxStyle.draw_multi_tag` (`scripts/ux_style.gd`). The wheel (`boss_wheel.gd`) and the plate both use it, so the two match exactly.
- **Bleed pulse** (new `scripts/bleed_pulse.gd`)
  - Each HP-loss event sends one red ring from the hub hearts, and listeners hop as it passes.
  - During `_bleed_begin`/`_bleed_end` batches, rings are queued 150ms apart.
- **Logic QA**: added the rows `pacemaker-poison-tick` and `blood_chalice-poison-tick`; both pass. `logic_qa.gd` gained `poison_before`.
- **Shot harness**: added shots for the intent plate and bleed pulse. They run through the real Take and poison paths.
- **Specs**: `design/visual/_COMMON.md`, `ASSETS.md`, `BUILD-ORDER.md`, `ANIM-*.md`

## QA (1680x1040)
`design/visual/anim-qa/intent-plate/`:
- `01_hornet_plate`
- `02_hit1_lit`
- `03_hit2`
- `04_hornet_block_soak`
- `05_kobold_3`
- `06_dragon_flame`
- `07_shark_loop`
- `08_shambling_overflow`

`design/visual/anim-qa/bleed-pulse/`:
- `01_hornet_two_rings`
- `02_poison_pacemaker`

Results:
- Hornet Swarm shows two "2" badges.
- Shark shows its badge plus a ↻ chip that matches the wheel tag.
- Kobold shows 3 badges.
- Poison tick of 2 with Pacemaker: ring plus heal 1.
- `godot --headless --quit` exits 0 with no SCRIPT or parse errors.
- No new player-facing "ATK" or "Tier". The existing combat log still says "enemy ATK"; that is older and not part of this PR.

Screenshots come from the repo shot harness. godot-mcp attaches to the open editor on the main folder, so it was not used against this worktree.

## Placeholders (PixelLab art should replace these; they are loaded by path, so no code change is needed)
Listed in `assets/ui/anim/PLACEHOLDERS.md`:
- `intent_claw_idle.png` (16x16)
- `intent_claw_lit_f0..f3.png` (16x16)
- `intent_claw_burst_f0..f3.png` (24x24)
- `intent_claw_flame_idle.png` (16x16)
- `intent_claw_flame_burst_f0..f3.png` (24x24)
- `intent_chip_shield.png`, `intent_chip_drop.png`, `intent_chip_flee.png` (8x8)

Not exported or pushed to itch.
