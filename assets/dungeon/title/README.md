Pixel drops the boot cinematic here. Brief: `design/handoff/title-teaser/PIXEL.md`. File list: `ART-REQUEST.md`.

Itch waits on `title_still.png`. Code loads every file in that list when it exists; missing layers stay on the programmer dummy.

## PixelLab teaser frames (runs 2-3, installed 2026-10-22)

Installed by `design/handoff/CURSOR-AGENT/title-teaser/install/install_pixellab_teaser.py` from the art kit (`pixellab/run2/final`, `run3/final`, `items/`). No new gens. Import: Nearest, mipmaps off, Lossless.

| Files | Native | Shipped | Frames | Source |
|---|---|---|---|---|
| `sprout_run_f0-3`, `sprout_grab_f0-3`, `sprout_throw_f0-3` | 48×48 | 192×192 (4×) | 4 each | run2 |
| `sprout_hurt_f0-3` | 64×64 | 192×192 (**3×**, so he stays the run size) | 4 (f1 = white hit flash) | run3 `sprout64_hurt` + touch-up. Plays on the Helmet beat in place of the 24px wheel `run_block` placeholder. |
| `nib_lantern_f0-1` | 32×32 | 128×128 | 2 | run2 |
| `mon_goblin`, `mon_dire_wolf`, `mon_skeleton`, `mon_hornet_swarm` `_f0-3` | 32×32 | 128×128 | 4 | run3 redos (wolf mirrored + relit to face right) |
| `mon_ogre_f0-3` | 48×48 | 192×192 | 4 | run2 |
| `mon_spider_queen_f0-3` | 48×48 | 192×192 | 4 | run3 |
| `mon_dragon_f0-3` | 64×64 | 256×256 | 4 | run3 |
| `item_<id>_f0` (8 loot ids) | 24×24 | 96×96 | 1 | PixelLab items batch |
| `item_pocketwatch_f1`, `item_grimoire_f1` | 24×24 | 96×96 | twinkle | run2 |

Intro cutscene loops (`assets/dungeon/home/cutscenes/`): `intro_p1_candle_f0-3` and `intro_p3_seal_f0-3`, 320×180 native / 1280×720, 8 fps over the same stills (only the candle / seal pixels change). `cutscene_player.gd` falls back to the still if the frames are missing.
