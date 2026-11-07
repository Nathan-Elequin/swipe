# ASSET LIST — Title framed B (boot hub) · 2026-11-07

Approved study B owns the playtest hub boot. Ship path:

| File | Size | Display | Notes |
|---|---|---|---|
| `assets/ui/title/cabin-vignette-native.png` | 340×220 | 680×440 nearest 2× | Exact composite from cabin / Nib / portrait / fire_f0. No new pixels. |
| `design/visual/mockups/study-B-1680x1040.png` | 1680×1040 | reference | Nathan-approved target. Not a runtime screenshot. |

Fonts: `assets/ui/fonts/eb_garamond/`, `assets/ui/fonts/open_sans/` (OFL). See `SCREEN-title-framed.md`.

---

# ASSET LIST — Title H3p-B final (Spinheritance)

Everything is in `hybrid-h3-ship/exports/` and ready to copy to `res://assets/ui/title/`. Import with Nearest filter, no mipmaps, Lossless.

## A. Baked layers: `exports/layers/` (place at x,y; scale 1)
| File | Size | Pos | Alpha | Palette / notes |
|---|---|---|---|---|
| title_room_bg.png | 1680×1040 | 0,0 | opaque | wall #4b2d18/#331d0e (44px planks), floor #2b170b/#1d0f06 |
| title_portrait_bartleby.png | 170×208 | 59,87 | yes | Grandpa Bartleby (`portrait_big` ×0.75) + drop shadow |
| title_window.png | 948×584 | 266,4 | yes | frame #22130a, sill #2a170b, view = window_view ×1.2, glass tint #aac3ff 16→5% |
| title_door_jamb.png | 660×792 | 1020,0 | yes | jamb #3a2313 + warm halo rgba(255,170,80,.24) |
| title_door_glow.png | 320×550 | 1250,40 | opaque | radial #fffbea→#ffe6a8→#f7ad52→#b85a1d→#5a240a; threshold #ffe9b8→#f2b464 |
| title_sprout_sai_silhouette.png | 286×326 | 1266,262 | yes | #000 body+Sai, rim rgba(255,214,150,.45–.6) |
| title_door_panel.png | 110×625 | 1570,2 | yes | inward door #2a190e, panels #352013, lit edge #ffcf86 55%, knob #c9a15a |
| title_spill_door_warm.png | 560×210 | 1120,590 | yes | #ffc57a @18% |
| title_spill_window_moon.png | 1080×450 | 180,590 | yes | #a9c2ff @8% |
| title_table.png | 1680×452 | 0,588 | yes | #8b5833, plank lines #5e3a1e, grain #7a4b2a, lip #b07a4a |
| title_map_title_baked.png | 995×399 | 367,630 | yes | widened map + Spinheritance logo, perspective-baked |
| title_loot_bag_spill.png | 408×280 | 1,760 | yes | burlap + Bag of Holding + spill + coins |
| title_loot_tray_grouped.png | 383×414 | 1297,626 | yes | tray + 12 items in 3 rows |
| title_nib_lantern.png | 548×548 | 186,286 | yes | Nib ×2.5 + lantern glow rgba(255,200,110,.42) |
| title_fx_vignette_lamp.png | 1680×1040 | 0,0 | yes | lamp pool rgba(255,200,120,.14) + vignette to rgba(10,4,1,.62) |
| title_press_start.png | 178×10 | 748,1014 | yes | reference only; ship as a Label (#e9cf98 @65%, 16px) |
| title_burlap_cloth.png | 381×262 | 1,778 | yes | optional: cloth only (#ad8a58/#9a7746/#c2a06c, stroke #6e5230, tie #d8c08a) |
| title_loot_tray.png | 383×414 | 1297,626 | yes | optional: tray only (#4a2716, brass #c9a15a, dividers #2e170b); 9-slice 24px |
| manifest.json | — | — | — | z-order + bounds for all of the above |

## B. Native / constructed sprites: `exports/sprites/`
| File | Size | Status | Notes |
|---|---|---|---|
| title_sprout_sai_sil.png | 58×64 | **NEW v2** | `sprout_idle_f0` + `sai.png` (½ scale), 1-bit black. Drawn at 5× Nearest |
| title_sprout_sai_sil_rim.png | — | **retired** | Rim now baked in layer / use outline shader |
| title_map_wide.png | 452×208 | **NEW (derived)** | map_wall widened by duplicating plain columns (90 at x=25, 90 at x=250) |
| title_logo.png | 720×160 | existing | = assets/dungeon/title/logo.png |
| title_portrait_bartleby.png | 224×272 | existing | = assets/dungeon/home/props/portrait_big.png |
| title_nib_lantern_f0.png | 128×128 | existing | = assets/dungeon/title/nib_lantern_f0.png (f1 also there for flicker) |
| title_window_view.png | 980×620 | mock source | mountain/cave view used in the window. **Not found in the repo's assets/**. Check source or commit it |
| (src) sprout_idle_f0.png + sai.png | 64×64 / 56×64 | in repo | Silhouette sources (teaser no longer used) |

## C. Existing game items used (no new art; repo paths)
- Bag spill: `assets/dungeon/items/bag_of_holding.png` ×2.6; `lucky_nickel` ×1.1, `cats_eye_marble`, `orb`, `mirror_shard` (rot 20°), `marble`, `counting_beads` (rot −15°) at ~×1; `assets/dungeon/home/fx/coin_f0.png` ×1.6 (6 coins).
- Tray, row 1 (arms ×1.05): `double_axe`, `spiked_flail`, `throwing_knife`, `sledgehammer`.
- Tray, row 2 (treasure ×1.15): `blood_chalice`, `victory_flask`, `watch`, `medallion`.
- Tray, row 3 (oddities ×1.28): `grimoire`, `cursed_scroll`, `polymorph`, `healing_potion`.
- Exact x/y/w/h/rotation for each: `exports/sprite_placements.json`. Map/logo entries there are local to the map plane.

## D. Fonts
- PRESS START: Silkscreen 16px, as in the mock. Swap to the project's pixel font if Silkscreen isn't bundled. Its license (OFL) allows bundling.
