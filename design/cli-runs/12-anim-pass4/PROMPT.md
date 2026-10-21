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
