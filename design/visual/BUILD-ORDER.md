# BUILD ORDER: animation specs → 5 Cursor CLI passes

**Before pass 1:** copy `_COMMON.md`, `ASSETS.md` and every `ANIM-*.md` from this folder into the repo at `design/visual/` (e.g. `design/visual/ANIM-intent-plate.md`). Every prompt below assumes they are there.

Each pass:
- merges on its own, on its own branch, and leaves the game playable
- uses **placeholder PNGs at the exact final filenames**, so PixelLab art drops in later with no code change
- ends with godot-mcp screenshot QA

| Pass | Scope | One line |
|---|---|---|
| 1 | Intent plate + Shark loop + HP-loss fix + Bleed pulse | One claw badge per raw hit that fires as it lands; Shark ends in the wheel's ↻ tag; every HP loss calls `_note_hp_lost` and sends one bleed ring. |
| 2 | Slash portrait system | `ability_slash.gd` becomes a full-screen diagonal cut-in for monsters (frames if present, still image otherwise); items keep the small banner; +250ms on each monster's first cut-in per run. |
| 3 | Spin cascade ticker + Shift fast-forward | Stamp tokens light in order as on-spin triggers fire; holding Shift runs the cascade at ×3. |
| 4 | Poison pop, petrify, grappling hook, aura threads | Status and utility clarity: pending poison drips and bursts, stone creep/shatter, rope-yank swap, buff threads that snap and re-tie. |
| 5 | Sai, marble, hotbar shimmer, hover preview | Hotbar expression: sai split/merge, marble red/blue swirl, Weak/Tough/Deadly glint, rule-table ghost previews on the intent plate. |

---

## Pass 1: Intent plate + Shark loop + HP-loss fix + Bleed pulse
```text
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
```

## Pass 2: Slash portrait system (fallback to stills)
```text
Read design/visual/_COMMON.md and design/visual/ANIM-slash-portrait.md, then implement the cut-in system on branch anim/pass2-slash-portrait.

Scope:
1. Upgrade scripts/ability_slash.gd; keep its queue (play → _drain → _show).
   - For monster payloads (is_item == false), play the full-screen diagonal band cut-in from the spec: dim, band with speed lines, flash disc by ability family, portrait at 4x, name + call name. Timings: snap in 120ms, frames at 70ms, hold 120ms, slash out 160ms.
   - Items (is_item == true) keep the current small gutter banner unchanged.
2. A monster's FIRST cut-in in each run holds +250ms. Track `_slash_seen` and reset it at run start.
3. Add `monster_slash_frames(id)` to scripts/dungeon_art.gd, loading `assets/dungeon/anim/slash/<id>_slash_f*.png` (and `<id>_slash_base.png`). If no frames exist, fall back to `art.monster_still(id)` with a Tween punch-in (scale 3.6→4.0, 2px shake). That fallback is the default for every monster in this pass.
4. Honour payload.fast and Engine.time_scale. Don't touch input bindings.
5. Size and place the node full-rect 1680x1040, replacing the gutter sizing in main.gd around L15003 for the monster path only.

Art: PixelLab slash frames aren't in yet. Don't create per-monster placeholders; the still fallback covers them. Create one placeholder set to prove the frame path: assets/dungeon/anim/slash/ogre_slash_base.png and ogre_slash_f0.png … ogre_slash_f4.png (64x64, made from the current Ogre still). Add a shader at shaders/slash_lines.gdshader (create that folder if there isn't one). List the expected filenames for all 56 monsters (from the spec table) in assets/dungeon/anim/slash/PLACEHOLDERS.md.

Use only existing copy (title and call_name from the payload), plus Triclops's call name "Cut And Run" if call_name is empty for triclops. Never show "Tier".

QA with godot-mcp at 1680x1040, saving to design/visual/anim-qa/slash-portrait/:
- Ogre ability: shots at 60ms, 300ms and 700ms after the cut-in starts. Compare 300ms against the mockup mock_slash_portrait_ogre.png (Pixel will attach it).
- Hornet Swarm and Vampire use the still fallback.
- Three queued triggers never overlap.
- The first Ogre cut-in in a run is longer than the second.
- An item trigger still shows the small banner.
Run scripts/dev/text_audit.gd.

Commit on the branch with the files-changed summary and the screenshot list. Don't export or push to itch.
```

## Pass 3: Spin cascade ticker + Shift fast-forward
```text
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
```

## Pass 4: Poison pop, petrify, grappling hook, aura threads
```text
Read design/visual/_COMMON.md, design/visual/ANIM-poison-pop.md, design/visual/ANIM-petrify.md, design/visual/ANIM-grappling-hook.md and design/visual/ANIM-aura-threads.md, then implement all four on branch anim/pass4-status-utility. Passes 1-3 are merged.

Scope:
1. Poison pop (new scripts/poison_pop.gd).
   - Drip loop on the slice badge (boss_wheel._draw_poison_badge) and a new hub poison badge.
   - burst_slice before `_chip_hp` in `_tick_monster_poison`; burst_hub replaces the 220ms wait in `_tick_player_poison`.
   - Padlock for Plague Doctor's "Always" poison.
   - Push a ticker token for each tick.
2. Petrify.
   - item_card.set_petrified(on, dummy, spins_left, animate) with shaders/petrify.gdshader (top-down creep using the existing assets/dungeon/ui/petrify_stone.png).
   - Gaze beam from `_petrify_best_atk` / `_hydra_even_killer` / `_apply_basilisk_gaze`.
   - 3-pip countdown via `_tick_gaze_petrify`; shatter in `_clear_petrify`.
   - The Bushido dummy overlay is unchanged.
3. Grappling hook (new scripts/hook_fx.gd): throw → taut → arc swap of the two portraits → retract → item draw, wrapped around the hook_swap branch of `_apply_mark`.
4. Aura threads: extend boss_wheel._draw_bonds with the spec's thread table. Snap and re-tie by diffing bond pairs around `collapse_slice` and `_sync_wheel_stats`. Silenced sources go grey.

Art placeholders at exact paths (Nearest, no mipmaps, Lossless), listed in the PLACEHOLDERS.md files:
- assets/ui/anim/poison_badge_drip_f0-3.png (8x8)
- assets/ui/anim/poison_burst_f0-3.png (24x24)
- assets/ui/anim/heart_drip_f0-3.png (12x12)
- assets/ui/anim/poison_lock.png (6x6)
- assets/ui/anim/petrify_shatter_f0-4.png (30x30)
- assets/dungeon/anim/hook_throw_f0-5.png (24x24)
- assets/dungeon/anim/hook_taut.png (24x24)
- assets/dungeon/anim/rope_tile.png (4x8)
- assets/ui/anim/aura_glyph_sword.png, aura_glyph_wisp.png, aura_glyph_drop.png, aura_glyph_lock.png, aura_glyph_shield.png (8x8)
"f0-3" means separate files _f0 … _f3.

Use the status label "Silenced" exactly where a silenced label is needed. Never show "Tier".

QA with godot-mcp at 1680x1040, following each spec's QA section, saving to design/visual/anim-qa/<spec-name>/:
- Ale Flagon then Spin: burst and hearts dripping.
- Miasma: only the spun slice bursts.
- Gargoyle: creep, then shatter on the next Spin.
- Hydra: three beams.
- Basilisk: pips count down.
- Grappling Hook: shots at 200 / 360 / 600 / 1100ms.
- Commander threads: snap and re-tie after a neighbour dies; Quiet Bell turns them grey.
- Hold Shift during a poison tick: ×3.

Commit on the branch with the files-changed summary and the screenshot list. Don't export or push to itch.
```

## Pass 5: Sai, marble, hotbar shimmer, hover preview
```text
Read design/visual/_COMMON.md, design/visual/ANIM-sai-twirl-split.md, design/visual/ANIM-marble-swirl.md, design/visual/ANIM-hotbar-shimmer.md and design/visual/ANIM-item-hover-preview.md, then implement all four on branch anim/pass5-hotbar. Passes 1-4 are merged.

Scope:
1. Sai.
   - Record the old alt_n in main.gd::_flip_alt_sais, then card.play_sai(old, new): 2→4 twirl-split, 4→2 the same frames reversed (merge).
   - The static icon follows alt_n on every _sync_hotbar, and on undo with no anim.
   - The value carries over between fights. At a new dungeon (_prep_next_dungeon sets 2) it just shows the single sai with no animation.
   - The number dissolve is delayed 120ms.
2. Marble.
   - Idle two-tone swirl in the hand.
   - _apply_marble awaits card.play_marble(is_atk): swirl, then settle red (Attack) or blue (Block), then courier.
   - _step_marbles grows +1 with a punch.
   - Bag of Marbles staggered roll-in; Magicat uses the cat's-eye idle.
3. Hotbar shimmer: shaders/rank_shimmer.gdshader on ItemCard.
   - Weak copper slow, Tough silver medium, Deadly gold fast + sparkle, with phase offset per uid.
   - Ready cards lift and breathe; unusable cards sink and desaturate.
   - Armed passives get an orbit glint. Sling shows the label "Loaded" with the tooltip "Loaded: your next Attack can hit any monster."
   - Apply the same shader to the draft gate panel and the Dungeon Deck peek. Never show the word "Tier" anywhere.
4. Hover preview, phase 1 only: the rule table in the spec (Kobold +1 hit, Harpy +1 poke, Amalgam ×2, Net −1…−3, Bushido 2nd use "no effect", kill dims all).
   - Hooks: _on_item_hovered / _on_item_unhovered.
   - Output: intent_plate.ghost(), wheel_view.set_preview() and the ghost hearts.
   - No full simulation.

Art placeholders at exact paths (Nearest, no mipmaps, Lossless), listed in the PLACEHOLDERS.md files:
- assets/dungeon/anim/sai_single.png and sai_pair.png (24x24)
- assets/dungeon/anim/sai_split_f0-7.png (24x24)
- assets/dungeon/anim/marble_idle_f0-3.png (24x24)
- assets/dungeon/anim/marble_swirl_f0-5.png (24x24)
- assets/dungeon/anim/marble_red.png and marble_blue.png (24x24)
- assets/dungeon/anim/marble_cat_idle_f0-3.png (24x24)
- assets/ui/anim/deadly_sparkle_f0-3.png (8x8)
- assets/ui/anim/intent_chip_plus.png (8x8)
"fN-M" means separate files _fN … _fM. Seed the sai and marble placeholders from the current item icons so they read correctly in the meantime.

QA with godot-mcp at 1680x1040, following each spec's QA section, saving to design/visual/anim-qa/<spec-name>/:
- Sai split at 120 / 240 / 360ms, merge back, carry-over to the next fight, plain 2 at a new dungeon.
- Marble swirl → colour → courier, and grow on Spin.
- 6s capture of Weak/Tough/Deadly glints; the unusable Boot sinks.
- Sling "Loaded" tooltip text exact.
- Hover Kobold / Net / Amalgam / Bushido / killing item ghosts.
- text_audit with 0 "Tier" hits.

Commit on the branch with the files-changed summary and the screenshot list. Don't export or push to itch.
```
