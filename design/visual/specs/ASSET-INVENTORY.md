# Asset inventory for the art refresh (2026-10-11)

Sources: `data/runtime.json`, `data/content-board.json` (2026-10-09), `data/player-copy.json`, the 15 current screenshots. All new art is 16×16 @4×, one unique sprite per card (unique-art rule).

## Screens / states
Title · How to Play (Nib talk box, docks bottom-left) · Draft ask · Draft reveal · Draft seat · Wheel ready · Spinning · Fight hit · Fight BLOCKED · Fight SLAIN · Victory (own plate) · Defeat (own plate) · Pause/Settings (70% dim, closes inspect) · Inspect plate · Between dungeons (rest).

## UI kit
- 9-slices: panel, inset, card ×3 rims (bronze/silver/gold), talk box, tooltip, door arch, plate.
- Buttons: primary (gold), secondary, disabled, hover/pressed; round Spin button.
- Badges: ATK, HP heart, BLK shield, HEAL, "?" variable, ×2 multi-hit.
- Tier plates Weak / Tough / Deadly (from tier.N.name, never "Tier"). Pass pips ×3 (full/spent).
- Hearts (full, cracked, empty + pulse). Hub disc + gold Block ring. Wheel slice full/empty/hover/selectable, rim, pointer, "+".
- Cursors: default, grab (thief hand), not-allowed. Logo: "Swipe" wordmark ~96×32 + sticky-fingers icon.

## Nib
32×32 portrait: neutral, smug, annoyed, proud, plus a 4-frame idle (blink, coin flip). Own silhouette: thief mask and scarf, not the Goblin monster. Draft: `mockups/nib-idle-sheet-x8.png`.

## VFX / animation
Loot glow pulse, coin sparkle, door slam dust, monster step-out, seat pop, spin streaks, hit sparks, block burst, slain slash, poison mark, heal plus, number pop, shake presets, 80 ms hit-stop (CPUParticles2D + Kenney CC0 particle textures). Each monster: 2-frame idle + 1 lunge frame.

## Items (35)
| Name | id | Risk | Note |
|---|---|---|---|
| Throwing Knife | `throwing_knife` | Weak |  |
| Shield | `shield` | Weak |  |
| Sai | `sai` | Weak |  |
| Medallion | `medallion` | Weak |  |
| Helmet | `helmet` | Weak |  |
| The Boot | `da_boot` | Weak |  |
| Bloody Gauntlets | `bloody_gauntlets` | Weak |  |
| Bracers | `bracers` | Tough |  |
| Knucklers | `knucklers` | Tough |  |
| Spiked Flail | `spiked_flail` | Deadly |  |
| Sledgehammer | `sledgehammer` | Deadly |  |
| Grimoire | `grimoire` | Weak |  |
| Breastplate | `breastplate` | Deadly |  |
| Smoke Bomb | `smoke_bomb` | Tough |  |
| Fangs | `fangs` | Tough |  |
| Poison Flask | `poison_flask` | Tough |  |
| Healing Potion | `healing_potion` | Deadly |  |
| Crossbow | `crossbow` | Deadly |  |
| Pocketwatch | `pocketwatch` | Deadly |  |
| Double Axe | `double_axe` | Tough |  |
| Victory Flask | `victory_flask` | Tough |  |
| Grappling Hook | `grappling_hook` | Weak |  |
| Spiked Shield | `spiked_shield` | Weak |  |
| Grief Jar | `grief_jar` | Tough |  |
| Longbow | `longbow` | Tough |  |
| Lantern | `lantern` | Deadly |  |
| Mirror Shard | `mirror_shard` | Tough |  |
| Echo Bell | `echo_bell` | Deadly |  |
| Quiet Bell | `quiet_bell` | Tough |  |
| Net | `net` | Weak |  |
| Chain | `iron_chain` | Tough |  |
| Counting Beads | `counting_beads` | Weak |  |
| Paci Fist | `last_match` | Deadly | id ≠ name: draw a Paci Fist |
| Scythe | `measuring_tape` | Deadly | id ≠ name: draw a Scythe |
| Chaos Stone | `mute_stone` | Tough | id ≠ name: draw a Chaos Stone |

## Owners (29)
| Name | id | Risk | Note |
|---|---|---|---|
| Wizard | `wizard` | Weak |  |
| Golem | `golem` | Weak |  |
| Goblin | `goblin` | Weak |  |
| Skeleton | `skeleton` | Weak |  |
| Hornet Swarm | `hornet_swarm` | Weak |  |
| Lich | `lich` | Weak |  |
| Ogre | `ogre` | Tough |  |
| Berserker | `berserker` | Tough |  |
| Dire Wolf | `dire_wolf` | Tough |  |
| Bandit | `bandit` | Tough |  |
| Two-Headed Serpent | `two_headed_serpent` | Tough | id ≠ name: draw a Two-Headed Serpent |
| Slime Boss | `slime_boss` | Deadly |  |
| Leech League | `leech_league` | Tough |  |
| Wraith | `wraith` | Tough |  |
| Mimic | `mimic` | Tough |  |
| Spider Queen | `spider_queen` | Deadly |  |
| Commander | `commander` | Deadly |  |
| Dragon | `dragon` | Deadly |  |
| Needleback | `needleback` | Tough |  |
| Gelatinous Cube | `gelatinous_cube` | Tough |  |
| Gargoyle | `gargoyle` | Tough |  |
| Harpy | `harpy` | Tough |  |
| Kobold Trapper | `kobold_trapper` | Tough |  |
| Clockwork Knight | `clockwork_knight` | Deadly |  |
| Basilisk | `basilisk` | Tough |  |
| Twins | `hollow` | Weak | id ≠ name: draw a Twins |
| Beggar | `beggar` | Weak |  |
| Wick | `wick` | Tough |  |
| Anvil | `anvil` | Deadly |  |

Also seen in screenshot 07 but not in runtime.json: "Damsel in Distress" (Guarded by Monsters). Confirm before drawing.
