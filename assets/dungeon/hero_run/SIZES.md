# hero_run: asset list + export spec

Run-screen goblin (replaces `knight_m` on the wheel hub and the hall-wipe courier). Crypt Classic: 1px #100e0c outline, 3-4 tone ramps, light from upper-left, no dither, no AA. Palette = the cabin goblin exactly (see `design/visual/SCREEN-run-hero.md`).

## Export spec

- PNG RGBA, 8-bit, no colour profile. Alpha is 0 or 255 except the floor shadow row (#100e0c at alpha 115).
- Drawn at native 24x24, shipped at **integer 4x Nearest** = 96x96. Never rescale in-engine except by integer factors.
- Godot import: Filter **Off** (Nearest), Mipmaps **Off**, Repeat Off, Compress Lossless. `texture_filter = NEAREST` on the node.
- Every hero frame and gear overlay shares one rect: 96x96, **pivot (48,92)** = centre of the feet on the floor line. The shadow is below the pivot (rows 92..95).
- Faces right (toward the boss). Not flipped anywhere.
- Gear overlays: same rect and pivot as their base frame. Draw base, then rope, goggles, cap|helm (cap and helm both use the head slot). Overlays contain only gear pixels (verified: base + overlays == the worn render on all 40 frames).
- Badges: no digits in the art; code draws the number at the anchor in `layout.json`.

## Files

| file | native | shipped | notes |
|---|---|---|---|
| run_idle_f0..f3.png | 24x24 | 96x96 | loop; ms [220, 180, 220, 180]; body sinks 1px f1-f2, ear flops a frame late |
| run_swipe_f0..f4.png | 24x24 | 96x96 | once; ms [90, 60, 80, 110, 120]; f0 wind-up, f1 lunge, f2 SNATCH = hit frame, f3 fist + coin, f4 recover |
| run_hit_f0..f2.png | 24x24 | 96x96 | once; ms [70, 110, 120]; knocked back, hunch, recover (0.30s = hurt sting) |
| run_block_f0..f2.png | 24x24 | 96x96 | once; ms [60, 160, 120]; shield up, f1 IMPACT (BLK punch), lower (0.34s = block sting) |
| run_heal_f0..f3.png | 24x24 | 96x96 | once; ms [120, 120, 220, 180]; flask from pouch, raise, f2 gulp, satisfied glint |
| run_lowhp_f0..f3.png | 24x24 | 96x96 | loop; ms [260, 200, 260, 200]; replaces idle at low HP: hunched, panting, sweat |
| run_death_f0..f4.png | 24x24 | 96x96 | once-hold; ms [140, 140, 160, 200, 0]; stagger, buckle, topple, f3 FLOOR (bump), f4 sack spilled: hold |
| run_victory_f0..f3.png | 24x24 | 96x96 | once x2; ms [100, 140, 160, 120]; crouch, hop, apex fist + coin, land |
| run_grab_f0..f3.png | 24x24 | 96x96 | once; ms [100, 90, 140, 180]; draft pick: reach, grab, stuff in sack, pat |
| run_walkoff_f0..f3.png | 24x24 | 96x96 | loop; ms [70, 70, 70, 70]; hall-wipe courier run with the sack |
| gear/{cap,helm,goggles,rope}/run_*_fN.png | 24x24 | 96x96 | 160 overlays, one per frame per piece (40 x 4) |
| badges/badge_hp.png | 11x10 | 44x40 | HP normal |
| badges/badge_hp_flash.png | 11x10 | 44x40 | HP just changed / log focus: swap in for ~0.12s (replaces the fill lerp to f0e6d8) |
| badges/badge_hp_low.png | 11x10 | 44x40 | HP at or below the low-HP threshold (pair with run_lowhp); can blink with badge_hp |
| badges/badge_hp_empty.png | 11x10 | 44x40 | HP 0 (death) |
| badges/badge_blk.png | 11x12 | 44x48 | BLK > 0 |
| badges/badge_blk_empty.png | 11x12 | 44x48 | BLK 0 (replaces fill 1a3348 / rim 4a6a80) |
| badges/badge_blk_up.png | 11x12 | 44x48 | BLK gained this beat (ghost > blk; replaces fill 2a7a58 / rim 7dba7d) and log focus |
| badges/badge_blk_pierced.png | 11x12 | 44x48 | pierce active (hub_pierce): cracked shield. Code adds one short float-up of the existing pierce text above the shield; the old slash line and static caption are removed |
| layout.json | - | - | rects, pivots, number anchors, timings, events |

Also in this drop: `assets/dungeon/home/hero/gear/**` = the 176 **fixed** cabin overlays (same names and sizes as the repo; replace the shipped ones). See `design/visual/SPEC-cabin-hero-wiring.md`.

## Counts

- hero_run PNGs: 208 (40 base + 160 gear + 8 badges)
- cabin overlays: 176
