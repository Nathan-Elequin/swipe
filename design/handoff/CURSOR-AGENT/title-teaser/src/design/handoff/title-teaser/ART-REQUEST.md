# ART-REQUEST — title teaser (full shot list)

Pixel owns PNG bytes. Draw native, we ship 4× nearest. Lossless, no mipmaps. Transparent unless **opaque** is stated. Palette: cabin oak `#3a2414` `#5a3a24` `#c4a574` `#fff3d6` `#100e0c`; ink `#1c120c`; cream `#fff3d6`; gold `#e8c36a`.

Read [`PIXEL.md`](PIXEL.md) first. This table is the drop list. Folder: `assets/dungeon/title/`.

Pivot default for characters: centre of feet, on the floor. Items: centre of the object.

## A. Worlds (opaque, seamless on X)

| File | Native | Shipped | Frames | Notes |
|---|---|---|---|---|
| `hill_strip.png` | 420×260 | 1680×1040 | 1 | Night Kettle Hill + cabin + run door to the dark. Floor at native y=161. Loop X. Beat 1. |
| `hall_strip.png` | 420×260 | 1680×1040 | 1 | Dungeon hall that reads as adventure, not combat chrome. Floor y=161. Loop X. Beats 2–4. |
| `hall_strip_b.png` | 420×260 | 1680×1040 | 1 | Second hall (tint / props). Optional but wanted for “halls change” at beat 3. Same floor. |

## B. Title still (opaque)

| File | Native | Shipped | Frames | Notes |
|---|---|---|---|---|
| `title_still.png` | 420×260 | 1680×1040 | 1 | Full-bleed painting. Inheritance + spend-to-keep + mountain. Sprout, flying loot, crowding monsters, cabin/Nib as a ghost. **No English** until NAME.md is locked. Keep faces out of the hub hole (see SCREEN). **Itch waits on this file.** |
| `logo.png` | fit width ≤ 240 native | 4× | 1 | Transparent lettering of the locked name. Skip if you paint the name into the still and say so. |

## C. Sprout (teaser scale — not the wheel 24px)

Same goblin as `hero_run`. Facing right. Texture 48×48 native / 192×192 shipped. Feet on the bottom centre (pivot 24, 46 native). 4 frames each, ~70ms.

| File | Notes |
|---|---|
| `sprout_run_f0.png` … `sprout_run_f3.png` | Loop. Sack on his back. Beats 1–4. |
| `sprout_grab_f0.png` … `sprout_grab_f3.png` | Once. Reach, snatch, stuff, recover. Beat 2. |
| `sprout_throw_f0.png` … `sprout_throw_f3.png` | Once. Wind-up, throw Boot/Helmet, recover. Beat 3. |

## D. Nib cameo

| File | Native | Shipped | Notes |
|---|---|---|---|
| `nib_lantern_f0.png` | 32×32 | 128×128 | Planted, lantern, does not run. Beat 1 only. |
| `nib_lantern_f1.png` | 32×32 | 128×128 | Idle tick / flame. Loop with f0. |

## E. Items (readable floaters)

32×32 native / 128×128 shipped. One still is enough; `_f1` optional bob. Must read as the named object, unique vs `assets/dungeon/items/<id>.png`.

| File | Job in the teaser |
|---|---|
| `item_pocketwatch_f0.png` | caught |
| `item_lantern_f0.png` | caught |
| `item_grimoire_f0.png` | caught |
| `item_healing_potion_f0.png` | caught |
| `item_lucky_nickel_f0.png` | missed (passes him) |
| `item_sledgehammer_f0.png` | missed |
| `item_da_boot_f0.png` | spent (thrown, then gone) |
| `item_helmet_f0.png` | spent |

## F. Monsters (chase)

32×32 native / 128×128 shipped except ogre / queen / dragon: **48×48** native / 192×192. 4-frame run, facing **left** (they chase from behind). Unique vs `assets/dungeon/extra/<id>.png`.

| File | Size native |
|---|---|
| `mon_goblin_f0.png` … `f3` | 32×32 |
| `mon_dire_wolf_f0.png` … `f3` | 32×32 |
| `mon_skeleton_f0.png` … `f3` | 32×32 |
| `mon_ogre_f0.png` … `f3` | 48×48 |
| `mon_hornet_swarm_f0.png` … `f3` | 32×32 |
| `mon_spider_queen_f0.png` … `f3` | 48×48 |
| `mon_dragon_f0.png` … `f3` | 48×48 |

## G. Optional bloom

| File | Native | Notes |
|---|---|---|
| `bloom_f0.png` `f1` `f2` | 64×64 | Additive-looking white burst for the whiteout. Transparent. Code can also flash a white rect. |

## Itch bar

Must land before friends see this: **A + B (`title_still.png`)**. C–G can follow in the same drop if you can; if not, still + strips first, Sprout/items/monsters next. Do not ship a still that is “goblin in a hallway.”

## Return

One page: every file, native w×h, shipped w×h, frames, loop, pivot. `design/visual/sizes/title-teaser.sizes.json` once the PNGs exist.
