<!-- RECONSTRUCTED 2026-10-21 02:40 CT by Grok Bot for the handoff. The original PROMPT-fix.md for pass 4
     vanished from this folder while the fix run (run12fix.ps1) was still going (killed ~02:22 CT) and no copy
     survived on Cherry or the box. This text rebuilds its intent from the pass 3 fix prompt pattern, the
     run notes (design/handoff/CURSOR-AGENT/pass4/PROGRESS.md) and what the fix run actually changed. It is NOT verbatim. -->
Follow-up for pass 4 on branch anim/pass4 (the anim-pass4 commit so far is yours). Re-read design/visual/ANIM-poison-pop.md, ANIM-petrify.md, ANIM-grappling-hook.md and ANIM-aura-threads.md.

New: final PixelLab art has been dropped at the exact placeholder paths (same native sizes):
- assets/ui/anim/poison_badge_drip_f0-3, poison_burst_f0-3, heart_drip_f0-3, petrify_shatter_f0-4, aura_glyph_sword/wisp/drop/lock/shield
- assets/dungeon/anim/hook_throw_f0-5, hook_taut, rope_tile
assets/ui/anim/poison_lock.png (6x6) is still a placeholder: keep it listed in PLACEHOLDERS.md.

Do:
1. Make sure every PNG above has a matching .import (Nearest via project default, no mipmaps, Lossless compress/mode=0) and commit PNGs + .import. Revert unrelated --import churn (other .import files, project.godot, default_bus_layout.tres).
2. Update assets/ui/anim/PLACEHOLDERS.md and assets/dungeon/anim/PLACEHOLDERS.md: mark the files above as final PixelLab art; keep poison_lock.png as placeholder.
3. Poison colour: the game's poison is green (#7dba7d droplet, #d8f0d0 number) but the new art is purple (#4a3a78/#7a6aa8 with a #8cbc48 green accent in the burst). Do not recolour; flag it in the commit message for Nathan.
4. Nothing may depend on the wheel seat count (4-8 seats; a test branch uses 6). Check poison_pop.gd, hook_fx.gd, the aura thread code and the harness for 8-seat assumptions.
5. Re-run QA at 1680x1040 with the repo shot harness (godot-mcp attaches to Nathan's open editor; do not use it) into design/visual/anim-qa/<spec-name>/ and overwrite the PNGs. Add a six-seat shot per spec (06_six_seats / 05_six_seats) and poison-pop/07_plague_lock.png (Plague Doctor "Always" padlock). Look at every PNG.
6. Run Godot headless --quit and confirm no new SCRIPT ERROR or parse errors. Run the text audit (no "Tier", no "ATK"). Normal anim speed is ANIM_TIME_SCALE 0.675; Shift x3 = 2.025.

Rules: never show "Tier" or "ATK"/"atk"; new strings via PLAYER_COPY.text(); respect Engine.time_scale. Never touch Nathan's main folder, other worktrees or `movement`. One Godot process at a time, on this worktree; kill only Godot processes you started. Don't commit .wrangler/, .art-ping.env, .art-ping.last, build/ or stray logs. Don't push, merge, rebase, stash or reset.

Commit on the branch as anim-pass4(N): with a summary and the final screenshot list. Don't export or push to itch.
