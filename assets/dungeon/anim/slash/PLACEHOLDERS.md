# Slash cut-in frames (PixelLab)

Loader: `dungeon_art.monster_slash_frames(id)` reads:

- `assets/dungeon/anim/slash/<id>_slash_base.png` (portrait close-up base)
- `assets/dungeon/anim/slash/<id>_slash_f0.png` … `fN.png` (4–6 action frames)

Until frames land, the cut-in uses `monster_still(id)` with a punch-in (scale 3.6→4.0, 2px shake).

**In this pass:** only Ogre has placeholder frames (copied from the current still) to prove the path. Do not treat those as final art.

Import: Filter **Nearest**, mipmaps off, compress Lossless.

## Expected filenames (56 monsters)

| id | base | frames (canvas) |
|---|---|---|
| `goblin` | `goblin_slash_base.png` | `goblin_slash_f0.png` … `f3.png` (48×48) |
| `skeleton` | `skeleton_slash_base.png` | `skeleton_slash_f0.png` … `f4.png` (48×48) |
| `hornet_swarm` | `hornet_swarm_slash_base.png` | `hornet_swarm_slash_f0.png` … `f4.png` (48×48) |
| `lich` | `lich_slash_base.png` | `lich_slash_f0.png` … `f3.png` (64×64) |
| `ogre` | `ogre_slash_base.png` | `ogre_slash_f0.png` … `f4.png` (64×64) |
| `vampire` | `vampire_slash_base.png` | `vampire_slash_f0.png` … `f4.png` (48×48) |
| `berserker` | `berserker_slash_base.png` | `berserker_slash_f0.png` … `f4.png` (48×48) |
| `dire_wolf` | `dire_wolf_slash_base.png` | `dire_wolf_slash_f0.png` … `f3.png` (48×48) |
| `bandit` | `bandit_slash_base.png` | `bandit_slash_f0.png` … `f3.png` (48×48) |
| `leech_league` | `leech_league_slash_base.png` | `leech_league_slash_f0.png` … `f4.png` (48×48) |
| `wraith` | `wraith_slash_base.png` | `wraith_slash_f0.png` … `f3.png` (48×48) |
| `mimic` | `mimic_slash_base.png` | `mimic_slash_f0.png` … `f4.png` (48×48) |
| `two_headed_serpent` | `two_headed_serpent_slash_base.png` | `two_headed_serpent_slash_f0.png` … `f4.png` (64×64) |
| `slime_boss` | `slime_boss_slash_base.png` | `slime_boss_slash_f0.png` … `f3.png` (64×64) |
| `spider_queen` | `spider_queen_slash_base.png` | `spider_queen_slash_f0.png` … `f4.png` (64×64) |
| `commander` | `commander_slash_base.png` | `commander_slash_f0.png` … `f4.png` (64×64) |
| `dragon` | `dragon_slash_base.png` | `dragon_slash_f0.png` … `f5.png` (80×80) |
| `needleback` | `needleback_slash_base.png` | `needleback_slash_f0.png` … `f3.png` (48×48) |
| `gelatinous_cube` | `gelatinous_cube_slash_base.png` | `gelatinous_cube_slash_f0.png` … `f4.png` (64×64) |
| `gargoyle` | `gargoyle_slash_base.png` | `gargoyle_slash_f0.png` … `f3.png` (48×48) |
| `harpy` | `harpy_slash_base.png` | `harpy_slash_f0.png` … `f4.png` (48×48) |
| `kobold_trapper` | `kobold_trapper_slash_base.png` | `kobold_trapper_slash_f0.png` … `f3.png` (48×48) |
| `clockwork_knight` | `clockwork_knight_slash_base.png` | `clockwork_knight_slash_f0.png` … `f5.png` (64×64) |
| `basilisk` | `basilisk_slash_base.png` | `basilisk_slash_f0.png` … `f4.png` (64×64) |
| `hollow` | `hollow_slash_base.png` | `hollow_slash_f0.png` … `f3.png` (48×48) |
| `beggar` | `beggar_slash_base.png` | `beggar_slash_f0.png` … `f3.png` (48×48) |
| `wick` | `wick_slash_base.png` | `wick_slash_f0.png` … `f3.png` (48×48) |
| `anvil` | `anvil_slash_base.png` | `anvil_slash_f0.png` … `f3.png` (48×48) |
| `bodyguard` | `bodyguard_slash_base.png` | `bodyguard_slash_f0.png` … `f3.png` (48×48) |
| `cowardly_king` | `cowardly_king_slash_base.png` | `cowardly_king_slash_f0.png` … `f4.png` (48×48) |
| `merchant` | `merchant_slash_base.png` | `merchant_slash_f0.png` … `f3.png` (48×48) |
| `juggernaut` | `juggernaut_slash_base.png` | `juggernaut_slash_f0.png` … `f3.png` (64×64) |
| `cleric` | `cleric_slash_base.png` | `cleric_slash_f0.png` … `f4.png` (48×48) |
| `martyr` | `martyr_slash_base.png` | `martyr_slash_f0.png` … `f4.png` (48×48) |
| `prism` | `prism_slash_base.png` | `prism_slash_f0.png` … `f3.png` (48×48) |
| `plague_doctor` | `plague_doctor_slash_base.png` | `plague_doctor_slash_f0.png` … `f4.png` (48×48) |
| `hired_hand` | `hired_hand_slash_base.png` | `hired_hand_slash_f0.png` … `f3.png` (48×48) |
| `hydra` | `hydra_slash_base.png` | `hydra_slash_f0.png` … `f5.png` (80×80) |
| `zombie` | `zombie_slash_base.png` | `zombie_slash_f0.png` … `f3.png` (48×48) |
| `triclops` | `triclops_slash_base.png` | `triclops_slash_f0.png` … `f4.png` (48×48) |
| `shambling_mound` | `shambling_mound_slash_base.png` | `shambling_mound_slash_f0.png` … `f4.png` (48×48) |
| `almighty_worm` | `almighty_worm_slash_base.png` | `almighty_worm_slash_f0.png` … `f5.png` (80×80) |
| `cultist` | `cultist_slash_base.png` | `cultist_slash_f0.png` … `f3.png` (48×48) |
| `bushido` | `bushido_slash_base.png` | `bushido_slash_f0.png` … `f4.png` (48×48) |
| `shark` | `shark_slash_base.png` | `shark_slash_f0.png` … `f4.png` (64×64) |
| `death_bell` | `death_bell_slash_base.png` | `death_bell_slash_f0.png` … `f5.png` (64×64) |
| `phoenix_egg` | `phoenix_egg_slash_base.png` | `phoenix_egg_slash_f0.png` … `f4.png` (48×48) |
| `phoenix` | `phoenix_slash_base.png` | `phoenix_slash_f0.png` … `f4.png` (64×64) |
| `amalgam` | `amalgam_slash_base.png` | `amalgam_slash_f0.png` … `f4.png` (64×64) |
| `fairy` | `fairy_slash_base.png` | `fairy_slash_f0.png` … `f3.png` (32×32) |
| `eel` | `eel_slash_base.png` | `eel_slash_f0.png` … `f3.png` (48×48) |
| `druid` | `druid_slash_base.png` | `druid_slash_f0.png` … `f4.png` (48×48) |
| `mouse` | `mouse_slash_base.png` | `mouse_slash_f0.png` … `f3.png` (32×32) |
| `magicat` | `magicat_slash_base.png` | `magicat_slash_f0.png` … `f4.png` (48×48) |
| `rust_bucket` | `rust_bucket_slash_base.png` | `rust_bucket_slash_f0.png` … `f3.png` (48×48) |
| `poison_frog` | `poison_frog_slash_base.png` | `poison_frog_slash_f0.png` … `f3.png` (32×32) |

**Totals:** 56 bases + ~260 frames. Wizard and Golem have no ability and never call this.
