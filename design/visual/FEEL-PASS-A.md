# Feel pass A — timing, spin kick, stat count-up, FX positioning

Locked timing / feel changes from Nathan (Nov 18). Lane A only — Take button, layout, combo tracker, and inspect stay with lane B.

## Timing (old → new)

| Spot | Old | New |
|------|-----|-----|
| `boss_wheel.SPIN_DURATION` | 1.56s cubic in-out | reverted Nov 19 (Nathan): stays 1.56s cubic in-out, full lap is core feel |
| `boss_wheel.SLAY_RELEASE` | 0.16s | **0.2s** |
| `_play_ended_visuals` slay | await full `play_slay` + full defeat poof | `play_slay(..., true)` then continue at ~**0.2s** |
| Challenge multi-kill slays | sequential `await play_slay` | **parallel** early-release, one 0.2s wait |
| `_tick_player_poison` fallback wait | 0.22s | **0.11s** |
| Scorpion on-spin aura wait | 0.55s | **0.275s** |
| Magicat on-spin aura wait | 0.55s | **0.275s** |
| Quicksand crab on-spin wait | 0.12s | **0.06s** |
| Triclops “sorry” speech wait | 0.7s | **0.35s** |
| Echo Bell post-announce wait | 0.09s | **0.045s** |
| `_radiate_line` travel | `(0.34/1.5)/pace` | **half** `(0.17/1.5)/pace` |
| `_radiate_line` linger | `linger/pace` | **half** |
| Ability slash first-hold bonus | +250ms | **0** (combat) |
| Compact queued banners (2+) | full hold / band | hold **70ms** / item hold **0.10s**, band scale **0.82** |
| Stat count-up total | per-point courier flights | capped **0.5s** (`step = min(0.035, 0.5/steps)`) |

## FX positioning

- `fx_oneshot.play`: `add_child` **then** `global_position` (was reversed → wheel-parented FX sat offset).
- `boss_wheel.play_take_overlay`: wheel-local hub point converted with `to_global` before parenting to the scene root.
- Other `FxOneShot` callers that already pass globals (`slice_portrait_global`, pointer tip global, main/combat_stage hosts) land correctly after the attach-order fix.

## Seat rings

- `pulse_arrive` → quiet `_play_land_burst(..., true)`: ~60% scale, alpha 0.45, late glint frames dropped.
- Full burst stays on spin land only.

## FX texture cache

- `dungeon_art.fx_frames` static `_fx_frames_cache`.
- `DUNGEON_ART.warm_fx_cache()` at dungeon boot (`main` after `art.setup()`).
- `_ticker_push_poison` uses preloaded `POISON_BADGE_TEX` (no per-push `load()`).

## Hits / projectiles / banners

- `_play_item_strike_fx` returns on the **impact frame**; anim finishes without blocking resolve.
- `_announce_item_use` starts the banner and awaits the projectile in parallel; apply on arrival.
- Ability slash: early release everywhere in combat; compact form when 2+ tickets queued; `await_released` / `is_busy` key off ticket `done`, not banner fade.
- `_maybe_auto_spin` waits on `ability_slash.await_released()` (not `visible` for 90 frames).

## Spin land

- `_preload_spin_land(idx)` warms portrait/idle/run/slash frames during `spin_to`.
- Intent plate synced in the same land pass as `_place_fight_art` (no one-frame late pop).
- `_sync_hotbar` only rebuilds the seated `StyleBoxFlat` when seated vs tray mode changes.

## Stat count-up — converted callers

Helper: `_play_stat_count(index, is_hp, from, to, origin)` → radiate → `play_hp_ticks` / `play_atk_ticks` (capped) → finish punch + `wheel.num_tick_finish` + quiet land burst.

Routed through `_play_stat_delta` / `_play_stat_count`:

- `_show_hp_loss_pips`
- `_echo_skeletons` / `_echo_bandits` (via `_play_stat_delta`)
- `_chip_hp` slime Attack path (via `_play_stat_delta`)
- `_sync_dire_wolves`
- `_hurt_ogres`
- `_show_flee_stat_snap`
- `_glass_asp_after_hp_loss`
- `_deal_atk_at` slime Attack path
- `_sandbag_after_spin` (apply then count)
- `_collector_bag_self_cost`
- `_heal_monster`
- `_grow_vampires` (was `_fly_stat_courier` loops)
- `_step_berserkers` (was per-point courier)
- `_apply_queen_eggs_on_spin` (was per-point courier)
- `_sync_pair_stat` (was `_tick_stat_heard` loop)
- `_leech_pulse` (was `_tick_stat_heard` loop)
- `_martyr_gift_neighbors` (was `_tick_stat_heard` loop)
- `_love_gift_hp` (was per-point pulse)

`_tick_stat_heard` now forwards a one-step count to `_play_stat_count`.

## Not converted / not found

- **Body Slam / damsel_in_distress**: no per-point courier path; Damsel resolves neighbor Takes via `_damsel_resolve` / `_neighbor_full_attack`, not heart/sword flights.
- Cleric / draft-gate `0.7s` waits (speech / slam reveal) were **not** in the locked list — left alone.
- Lane B surfaces (Take button, layout, combo tracker, inspect) untouched on purpose.
