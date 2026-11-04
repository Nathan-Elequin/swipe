# Offline balance Monte Carlo — assumptions

Pure-data Python sim under `tools/sim/`. Reads `data/catalog.json` only.
Does **not** run Godot, does **not** call `main.gd`, and does **not** change catalog numbers.

Goal: order-of-magnitude win rates and “this pair looks broken” flags for human review.
Not engine parity.

## What this models honestly

| Rule | Sim behavior | Source |
|---|---|---|
| Resolve hit | `incoming = max(0, enemy_atk − blk)`; leftover BLK stays until spent | catalog `blk_floor` ruling |
| Block | BLK resets to 0 on each new Spin / fight start | named var `blk` |
| Goblin | ATK damage never reduces HP; Defeat (Boot / Fangs / Sledge) still works | `MONSTER_SPECIAL.goblin` / Ability |
| Dragon | Attack ignores Block (`pierce`) | Ability / `pierce` |
| Hornet Swarm | Two swings on Done; Block spent per swing | Ability |
| Harpy | One swing on Spin land; one swing after each item if still facing & alive | Ability + Notes |
| Shark | On Done, keeps swinging until you lose ≥1 HP this Attack sequence (or 5 zero-damage swings then stop) | Ability + Notes (Quiet Bell / Net 0 path simplified) |
| The Boot | Defeat if `enemy_hp < player_hp` (strict). Spent. | `defeat_hp` |
| Fangs | Take one swing (Block works), then Defeat, then Heal equal to stored enemy HP (cap 6) | `fangs` flow |
| Spiked Flail | ATK = `2 × hp_loss_events` this dungeon (any HP loss amount = one event) | `flail_on_hp_loss` ruling; notes say base 0 |
| Breastplate | +2 BLK; Keep if `lost_hp_this_combat` | `blk_keep` |
| Healing Potion | Passive: on lethal, discard and Heal 3 | engine `_try_potion` |
| Keep | Kept items stay in hand for later fights in a ladder; discarded otherwise | keyword Keep |
| One exchange | After Done (or Defeat), the faced monster is gone — no multi-round duel | `one_encounter_then_gone` |
| Player HP | Start / max 6 | catalog `player` |

## Supported item ops (used by the bot)

`blk`, `atk`, `choose` (Throwing Knife + Net), `defeat_hp`, `fangs`, `atk_hp_loss`,
`blk_keep`, `heal_keep`, `passive` (potion), `atk_7_hp`, `blk_from_hp`, `blk_min_hp`,
`atk_alt_24`, `shield_alt`, `defeat_atk`, `heal`, `smoke` (abort = neither win nor death; counted as `escaped`).

Items with unsupported ops are left in the hand and ignored by the bot (logged in report coverage).

## Important consequence of one-exchange

Because surviving the enemy hit still removes the slice, **any monster whose Attack you can fully Block is a free "win" for that duel** even if you never deal damage (Goblin included). Goblin's "no ATK damage" only matters when you try to kill them with Attack before Done. Real dungeon pressure comes from pierce (Dragon), multi-swing (Harpy / Hornet / Shark), ATK that scales to your HP (Dire Wolf), and fights where you cannot assemble enough Block.

Shark under full Block: sim swings up to 5 times for 0, then treats the exchange as survived (slice removed). Quiet Bell / dialogue paths are not modeled.

## Deliberately out of scope

- Full wheel: neighbors, Across, cleave, bodyguard redirect, prism, commander aura
- Draft / mill / biome ladders as real adventure runs (ladder mode is a fixed monster list only)
- Petrify, Decay, Gaze, Hex countdowns, Toll, Poison DoT beyond “skip if marked” stub
- Smoke redraw loot, Echo Bell copy, Recycler, Marble growth
- UI timing, animation, RNG of wheel weights (Spin is uniform among remaining)
- Exact Harpy / Shark edge cases with Quiet Bell, Net leftover-0 dialogue, Lich undying

When a special cannot be modeled, the monster is still included with a **simplified** special or **vanilla ATK/HP only**, and the report marks `model: simplified` or `model: stats_only`.

## Bot policy (`greedy_survive`)

1. Use Boot / Sledge when legal.
2. Else if Fangs would not kill you after Block (or potion is available) and you cannot fully Block + kill cheaply, prefer Fangs when incoming ≥ remaining HP − 1 or enemy HP ≥ 4.
3. Else spend ATK items that can reduce enemy HP to 0 (Goblin: skip ATK).
4. Else spend BLK / Net to survive the incoming hit.
5. Else Done.

This is a competent but not optimal human. Win rates are a lower/upper bound depending on the pair — treat outliers as review candidates, not auto-nerfs.

## Seeds

`--seed N` seeds Python `random`. Each (loadout, monster, trial) uses a derived sub-seed so reruns are stable.
