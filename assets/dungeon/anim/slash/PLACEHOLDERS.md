# Slash cut-in frames (PixelLab)

Loader: `dungeon_art.monster_slash_frames(id)` reads:

- `assets/dungeon/anim/slash/<id>_slash_base.png` (portrait close-up base)
- `assets/dungeon/anim/slash/<id>_slash_f0.png` … `fN.png` (4–6 action frames; count = files present)

Native canvases are 32 / 48 / 64 / 80 px, shown at **4x** (or fitted down if 80×4 exceeds the 256px portrait box). Import: Filter **Nearest**, mipmaps off, compress Lossless.

Until frames land, the cut-in uses `monster_still(id)` with a punch-in (scale 3.6→4.0 relative to that canvas, 2px shake).

## Final art on disk (54 monsters)

| id | frames | canvas |
|---|---|---|
| `amalgam` | f0–f4 | 64 |
| `anvil` | f0–f3 | 48 |
| `bandit` | f0–f3 | 48 |
| `basilisk` | f0–f4 | 64 |
| `beggar` | f0–f3 | 48 |
| `berserker` | f0–f4 | 48 |
| `bodyguard` | f0–f3 | 48 |
| `bushido` | f0–f4 | 48 |
| `cleric` | f0–f4 | 48 |
| `clockwork_knight` | f0–f5 | 64 |
| `commander` | f0–f4 | 64 |
| `cowardly_king` | f0–f4 | 48 |
| `cultist` | f0–f3 | 48 |
| `death_bell` | f0–f5 | 64 |
| `dire_wolf` | f0–f3 | 48 |
| `dragon` | f0–f5 | 80 |
| `druid` | f0–f4 | 48 |
| `eel` | f0–f3 | 48 |
| `fairy` | f0–f3 | 32 |
| `gargoyle` | f0–f3 | 48 |
| `gelatinous_cube` | f0–f4 | 64 |
| `goblin` | f0–f3 | 48 |
| `harpy` | f0–f4 | 48 |
| `hired_hand` | f0–f3 | 48 |
| `hollow` | f0–f3 | 48 |
| `hydra` | f0–f5 | 80 |
| `juggernaut` | f0–f3 | 64 |
| `kobold_trapper` | f0–f3 | 48 |
| `leech_league` | f0–f4 | 48 |
| `lich` | f0–f3 | 64 |
| `magicat` | f0–f4 | 48 |
| `martyr` | f0–f4 | 48 |
| `merchant` | f0–f3 | 48 |
| `mimic` | f0–f4 | 48 |
| `mouse` | f0–f3 | 32 |
| `needleback` | f0–f3 | 48 |
| `ogre` | f0–f4 | 64 |
| `phoenix` | f0–f4 | 64 |
| `phoenix_egg` | f0–f4 | 48 |
| `plague_doctor` | f0–f4 | 48 |
| `poison_frog` | f0–f3 | 32 |
| `prism` | f0–f3 | 48 |
| `rust_bucket` | f0–f3 | 48 |
| `shambling_mound` | f0–f4 | 48 |
| `shark` | f0–f4 | 64 |
| `skeleton` | f0–f4 | 48 |
| `slime_boss` | f0–f3 | 64 |
| `spider_queen` | f0–f4 | 64 |
| `triclops` | f0–f4 | 48 |
| `two_headed_serpent` | f0–f4 | 64 |
| `vampire` | f0–f4 | 48 |
| `wick` | f0–f3 | 48 |
| `wraith` | f0–f3 | 48 |
| `zombie` | f0–f3 | 48 |

Each of the above also has `<id>_slash_base.png`.

## Still pending (still punch-in fallback)

Touch-ups in progress. Expected filenames once Pixel drops them:

| id | base | frames (canvas) |
|---|---|---|
| `hornet_swarm` | `hornet_swarm_slash_base.png` | `hornet_swarm_slash_f0.png` … `f4.png` (48×48) |
| `almighty_worm` | `almighty_worm_slash_base.png` | `almighty_worm_slash_f0.png` … `f5.png` (80×80) |

**Totals when complete:** 56 monsters (54 + 2 pending). Wizard and Golem have no ability and never call this.
