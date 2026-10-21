# Returns checklist

Drop raw generator output here with the **raw** name. Pixel converts it into the **final** files (native size, 4× nearest, lossless, into `assets/dungeon/title/`). Tick a box when the raw file is in.

## Resolved conflicts (locked notes win)
- Sprout is **redesigned** (folder 00): chibi, big friendly eyes, waist-length teal cloak, striped tunic, hip sack. The design sheet replaces the old in-game refs for 02-04 and the title hero; in-game hero frames get redone later.
- Teaser items in motion are **24×24 native** (96 shipped), not 32×32.
- Title-still artifacts may be drawn larger, since they're part of the illustration.
- Dragon is **64×64 native** (256 shipped).
- Monsters **face right**.
- Sprout frames: **bottom edge on the floor**, matching the code. Feet on the last opaque row, no empty rows below.
- Bloom is **skipped** (code flash; `bloom_f*` is never loaded).
- Logo: AI makes only the i-dot wheel (folder 13); Pixel does the lettering fix (plain p, new dot).

## Raw files Nathan returns (one per folder; 22 total)
Names now drop `_sheet`; Gemini downloads are JPG, so they keep `.jpg`. Ticked = file is in. **Re-do** = see `cleanup-all/GRADES.md`.
- [x] `sprout_design_raw.jpg` ← folder `00_GEMINI_sprout_design`
- [x] `title_still_v3_raw.jpg` ← folder `01_GEMINI_title_still` · **re-do hero (old Sprout)**
- [x] `sprout_run_raw.jpg` ← folder `02_GEMINI_sprout_run` · **re-do with new design**
- [x] `sprout_grab_raw.jpg` ← folder `03_GEMINI_sprout_grab` · **re-do with new design**
- [x] `sprout_throw_raw.jpg` ← folder `04_GEMINI_sprout_throw` · **re-do with new design**
- [x] `nib_lantern_raw.jpg` ← folder `05_GEMINI_nib_lantern`
- [x] `mon_goblin_raw.jpg` ← folder `06_GEMINI_mon_goblin`
- [ ] `mon_dire_wolf_raw.png` ← folder `07_GEMINI_mon_dire_wolf (NEW design prompt)`
- [x] `mon_skeleton_raw.jpg` ← folder `08_GEMINI_mon_skeleton`
- [x] `mon_ogre_raw.jpg` ← folder `09_GEMINI_mon_ogre` · **re-prompt: 3 frames, needs 4**
- [x] `mon_hornet_swarm_raw.jpg` ← folder `10_GEMINI_mon_hornet_swarm` · **re-prompt: unreadable at 32**
- [x] `mon_spider_queen_raw.jpg` ← folder `11_GEMINI_mon_spider_queen`
- [x] `mon_dragon_raw.jpg` ← folder `12_GEMINI_mon_dragon`
- [ ] `logo_idot_wheel_raw_a.png` ← folder `13_PIXELLAB_logo_wheel_dot`
- [ ] `item_pocketwatch_raw.png` ← folder `14_PIXELLAB_item_pocketwatch`
- [ ] `item_lantern_raw.png` ← folder `15_PIXELLAB_item_lantern`
- [ ] `item_grimoire_raw.png` ← folder `16_PIXELLAB_item_grimoire`
- [ ] `item_healing_potion_raw.png` ← folder `17_PIXELLAB_item_healing_potion`
- [ ] `item_lucky_nickel_raw.png` ← folder `18_PIXELLAB_item_lucky_nickel`
- [ ] `item_sledgehammer_raw.png` ← folder `19_PIXELLAB_item_sledgehammer`
- [ ] `item_da_boot_raw.png` ← folder `20_PIXELLAB_item_da_boot`
- [ ] `item_helmet_raw.png` ← folder `21_PIXELLAB_item_helmet`
- [ ] *(optional)* `item_<id>_glint_raw.png` ← folders 14-21

## Final files Pixel ships to `assets/dungeon/title/` (52 required + 8 optional)

| File | Native | Shipped | Notes |
|---|---|---|---|
| [ ] `title_still.png` | 420×260 | 1680×1040 | opaque, replaces v2 |
| [ ] `logo.png` | ≤210×44 | ≤840×176 | transparent, Spinheritance + wheel i-dot |
| [ ] `sprout_run_f0.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_run_f1.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_run_f2.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_run_f3.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_grab_f0.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_grab_f1.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_grab_f2.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_grab_f3.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_throw_f0.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_throw_f1.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_throw_f2.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `sprout_throw_f3.png` | 48×48 | 192×192 | facing right, feet on bottom row |
| [ ] `nib_lantern_f0.png` | 32×32 | 128×128 | feet on bottom row |
| [ ] `nib_lantern_f1.png` | 32×32 | 128×128 | feet on bottom row |
| [ ] `mon_goblin_f0.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_goblin_f1.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_goblin_f2.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_goblin_f3.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_dire_wolf_f0.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_dire_wolf_f1.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_dire_wolf_f2.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_dire_wolf_f3.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_skeleton_f0.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_skeleton_f1.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_skeleton_f2.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_skeleton_f3.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_ogre_f0.png` | 48×48 | 192×192 | run loop, facing right |
| [ ] `mon_ogre_f1.png` | 48×48 | 192×192 | run loop, facing right |
| [ ] `mon_ogre_f2.png` | 48×48 | 192×192 | run loop, facing right |
| [ ] `mon_ogre_f3.png` | 48×48 | 192×192 | run loop, facing right |
| [ ] `mon_hornet_swarm_f0.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_hornet_swarm_f1.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_hornet_swarm_f2.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_hornet_swarm_f3.png` | 32×32 | 128×128 | run loop, facing right |
| [ ] `mon_spider_queen_f0.png` | 48×48 | 192×192 | run loop, facing right |
| [ ] `mon_spider_queen_f1.png` | 48×48 | 192×192 | run loop, facing right |
| [ ] `mon_spider_queen_f2.png` | 48×48 | 192×192 | run loop, facing right |
| [ ] `mon_spider_queen_f3.png` | 48×48 | 192×192 | run loop, facing right |
| [ ] `mon_dragon_f0.png` | 64×64 | 256×256 | run loop, facing right |
| [ ] `mon_dragon_f1.png` | 64×64 | 256×256 | run loop, facing right |
| [ ] `mon_dragon_f2.png` | 64×64 | 256×256 | run loop, facing right |
| [ ] `mon_dragon_f3.png` | 64×64 | 256×256 | run loop, facing right |
| [ ] `item_pocketwatch_f0.png` | 24×24 | 96×96 | centred |
| [ ] `item_lantern_f0.png` | 24×24 | 96×96 | centred |
| [ ] `item_grimoire_f0.png` | 24×24 | 96×96 | centred |
| [ ] `item_healing_potion_f0.png` | 24×24 | 96×96 | centred |
| [ ] `item_lucky_nickel_f0.png` | 24×24 | 96×96 | centred |
| [ ] `item_sledgehammer_f0.png` | 24×24 | 96×96 | centred |
| [ ] `item_da_boot_f0.png` | 24×24 | 96×96 | centred |
| [ ] `item_helmet_f0.png` | 24×24 | 96×96 | centred |
| [ ] `item_pocketwatch_f1.png` *(optional)* | 24×24 | 96×96 | glint frame |
| [ ] `item_lantern_f1.png` *(optional)* | 24×24 | 96×96 | glint frame |
| [ ] `item_grimoire_f1.png` *(optional)* | 24×24 | 96×96 | glint frame |
| [ ] `item_healing_potion_f1.png` *(optional)* | 24×24 | 96×96 | glint frame |
| [ ] `item_lucky_nickel_f1.png` *(optional)* | 24×24 | 96×96 | glint frame |
| [ ] `item_sledgehammer_f1.png` *(optional)* | 24×24 | 96×96 | glint frame |
| [ ] `item_da_boot_f1.png` *(optional)* | 24×24 | 96×96 | glint frame |
| [ ] `item_helmet_f1.png` *(optional)* | 24×24 | 96×96 | glint frame |

Not needed: `bloom_f0..f2.png` (skipped), strips (shipped v2).
