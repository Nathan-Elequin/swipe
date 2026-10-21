Read design/visual/_COMMON.md, design/visual/ANIM-intent-plate.md and design/visual/ANIM-bleed-pulse.md, then implement both specs in one pass on branch anim/pass1-intent-bleed.

Scope:
1. REQUIRED CODE FIX first (ANIM-bleed-pulse.md, "REQUIRED CODE FIX"):
   - In scripts/main.gd::_tick_player_poison(), inside `if hp < before:`, add `_note_hp_lost(before - hp)`.
   - In scripts/main.gd::_player_take_atk(n), inside `if incoming > 0:`, add `_note_hp_lost(incoming)`.
   - Then add `signal bled(n)` and emit it from inside `_note_hp_lost`.
   - Run the existing logic QA rows for pacemaker and blood_chalice (design/qa/logic-pass/covering/rows/) and add one poison-tick row for each.
2. New scripts/intent_plate.gd and scripts/intent_badge.gd, as in ANIM-intent-plate.md:
   - Add a pure helper `_intent_hits()` in main.gd. Badges show the RAW hit; a badge flashes blue when Block soaks it.
   - fire(h) is called from `_owner_attack` after `combat_stage.lunge()`, indexed by the loop in `_apply_resolve_hits`.
   - sync() wherever btn_done's "Take {n}" text is set.
   - The plate clears in `_play_ended_visuals` / `_play_leave_visuals`.
3. Shark: the badge row ends with a loop chip. Extract the existing `↻` tag drawing from scripts/boss_wheel.gd (~L1948-1957, the hornet/shambling/shark tag) into a shared helper and use it on both the wheel and the plate, so they match exactly.
4. New scripts/bleed_pulse.gd: one red ring per HP-loss event from the hub hearts. Listeners hop as the ring passes (Vampire, Ogre, Dire Wolf, Spiked Flail, Breastplate, Pacemaker, Blood Chalice, Druid). Queue rings during `_bleed_begin`/`_bleed_end` batches, 150ms apart.

Art: PixelLab art isn't in yet. Create placeholder PNGs (flat shapes in the spec palette, correct native size and frame count) at these exact paths:
- assets/ui/anim/intent_claw_idle.png (16x16)
- assets/ui/anim/intent_claw_lit_f0.png … _f3.png (16x16)
- assets/ui/anim/intent_claw_burst_f0.png … _f3.png (24x24)
- assets/ui/anim/intent_claw_flame_idle.png (16x16)
- assets/ui/anim/intent_claw_flame_burst_f0.png … _f3.png (24x24)
- assets/ui/anim/intent_chip_shield.png, intent_chip_drop.png, intent_chip_flee.png (8x8 each)
Import all with Filter Nearest, no mipmaps, Lossless. Load them by path so the final art can overwrite the files. List every placeholder in assets/ui/anim/PLACEHOLDERS.md.

Rules:
- Never show the word "ATK"/"atk" or "Tier" to players. New strings go through PLAYER_COPY.text().
- Tweens and timers must respect Engine.time_scale.
- Don't change Space or any input binding.

QA with godot-mcp at 1680x1040 (follow the QA sections of both specs). Save the screenshots to design/visual/anim-qa/intent-plate/ and design/visual/anim-qa/bleed-pulse/. At minimum:
- Hornet Swarm: two badges, each "2", lit in order on Take.
- The same with 2 Block: badge 1 still reads 2 and flashes blue.
- Kobold after 2 items: 3 badges.
- Dragon: flame variant.
- Shark: badge + ↻ chip matching the wheel tag.
- Hornet vs Spiked Flail + Vampire: two rings.
- Poison tick of 2 with Pacemaker: ring + heal 1.
Then run scripts/dev/text_audit.gd.

Commit on the branch with a summary of files changed and the QA screenshot list. Don't export or push to itch.
