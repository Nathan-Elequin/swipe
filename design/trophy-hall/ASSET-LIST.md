# ASSET LIST: Trophy Hall (cases + dumbwaiter)

All PNGs are **RGBA, drawn at native size and shipped at ×4 nearest-neighbour** (same convention as `assets/dungeon/home/SIZES.md`).
- Godot import: **Filter Nearest, Mipmaps off, Lossless (`compress/mode=0`)**. Commit every `.import`.
- No text or digits baked into any sprite.
- Final art goes through PixelLab (see `PIXELLAB-COMMISSION.md`). Rows marked **bake** come from a small Python/PIL script in `design/trophy-hall/bake/`, not PixelLab.
- Coordinates are room native px (×4 = screen px), from `SCREEN-trophy-hall.md` §3–§5.

Paths: case art goes in `assets/dungeon/home/cabinets/` (next to the trophy-slots art), dumbwaiter art in `assets/dungeon/home/hall/` (new folder). `_home()` resolves both through `KIT.HOME`.

## 1. NEW: case chrome
| # | path | native | shipped | frames | notes |
|---|---|---|---|---|---|
| C1 | `cabinets/case_crystal_cavern.png` | 60×176 | 240×704 | 1 | Full b2 body, placed at room native (132,24). Glacial frame, ice spires on the crown, icicles off the crown lip, crystal cluster at the base. **Glass opening transparent at canvas (6,44) 48×121** (≈6 px frame each side), which equals `CASE_GLASS[1]` = room (138,68). Must fully cover the plate's olive case, vines and moss (px x 536–748, y 149–794). Crown label area (canvas (5,16) 44×13) is a flat pale plank with no text. |
| C2 | `cabinets/trophy_crystal_cavern.png` | 24×24 | 96×96 | 1 | Replaces `trophy_sunken_mire`. Ice-crystal cluster on a small pedestal, same footprint and registration as `trophy_verdant_hollow.png`. Used as the **crest** (drawn at 48 px). |
| C3 | `cabinets/trophy_crystal_cavern_hover.png` | 24×24 | 96×96 | 1 | Gold rim-light alt, pixel-registered to C2 (same rule as the other `_hover`s). |
| C4 | `cabinets/case_door_rect_f0..f3.png` | 64×129 | 256×516 | 4 | Glass door, hinge on the left. Origin = glass rect − (14,4). f0 shut: 52×125 frame `#2B1A12` 1-px outline `#1E120C`, glass `#CFE6F2` at α≈18% with 2 diagonal sheen bands α≈30%, interior otherwise clear. f1–f3 swing outward: the slab narrows and skews left past the frame (f3 ≈ 12 px wide slab at x 2–14, dark edge `#4A2F1F`). Neutral wood, no biome colour, so it works on b1/b2/b4/b5. |
| C5 | `cabinets/case_door_arch_f0..f3.png` | 64×129 | 256×516 | 4 | Same as C4 with an arched top matching the Ashen Crypt glass (b3). |
| C6 | `cabinets/case_sheet_rect.png` | 56×166 | 224×664 | 1 | Dusty linen sheet over a whole rect case, crown included. Draped folds, dust specks, frayed bottom 6 rows (the hem). Linen `#B8B2A4` / `#9C978C` / `#7A766C` / shadow `#5A564E`, outline `#2E2B26`. The hem rows are drawn in light neutral greys so the hem mask can tint them. **Origin = `CASE_GLASS[i].position − (8,32)`** (glass sits at canvas (8,32)). |
| C7 | `cabinets/case_sheet_arch.png` | 56×166 | 224×664 | 1 | Same, draped over the b3 arch (rounded top). |
| C8 | `cabinets/case_sheet_spires.png` | 64×180 | 256×720 | 1 | Same, draped over the Crystal Cavern spires (the bumps show through). Origin = room (126,22) (glass at canvas (12,46)). |
| C9 | `cabinets/case_sheet_rect_hem.png` · `_arch_hem.png` · `_spires_hem.png` | same as C6–C8 | same | 1 each | **bake.** White mask of the hem rows only (alpha from the sheet). It's modulated with the biome accent at runtime. |
| C10 | `cabinets/case_padlock.png` | 10×12 | 40×48 | 1 | Iron padlock, shackle closed. `#6E6E6E` / `#C9CED6` / outline `#1E120C`, one brass keyhole `#C4A574`. Also drawn at 0.5 on dark dumbwaiter stops. |
| C11 | `cabinets/case_lamp_off.png` | 8×12 | 32×48 | 1 | Small hanging brass lantern on a 3-px chain stub, glass dark `#2B1A12`. |
| C12 | `cabinets/case_lamp_on_f0..f2.png` | 8×12 | 32×48 | 3 | Same lantern, flame `#F09A34`/`#FFD84A` flicker loop, registered to C11. 140 ms/frame. |
| C13 | `cabinets/case_gild_rect.png` | 56×166 | 224×664 | 1 | Complete overlay. Transparent except a 2-px gold trim around the glass + a gold band across the crown + corner studs. Gold `#FFD84A` / `#E8C36A` / `#C4A574` / shadow `#8A6A2E`. Same origin as C6 (glass at canvas (8,32)). |
| C14 | `cabinets/case_gild_arch.png` | 56×166 | 224×664 | 1 | Arch version (b3). |
| C15 | `cabinets/case_gild_spires.png` | 64×180 | 256×720 | 1 | Spires version (b2): gold traces up the ice spires. Origin = room (126,22) (glass at canvas (12,46)). |
| C16 | `cabinets/placard_gold_9.png` | 12×5 | 48×20 | 1 | **9-slice** margins L/R 3 native (12 px), T/B 1 (4 px). Gold `#FFD84A` face, `#C4A574` bevel, `#1E120C` outline. Claimed. |
| C17 | `cabinets/placard_seen_9.png` | 12×5 | 48×20 | 1 | 9-slice, same margins. Dark wood `#2B1A12` face, 1-px pencil-dashed border `#6E6E6E` (2 on / 1 off). Seen. |
| C18 | `cabinets/placard_blank_9.png` | 12×5 | 48×20 | 1 | 9-slice, same margins. Plain dark `#1E120C` with a `#2B1A12` 1-px inner line. Unseen. |
| C19 | `cabinets/case_plaque_9.png` | 16×12 | 64×48 | 1 | **9-slice** margins 4 native (16 px) on all sides. Brass plaque: `#C4A574` face, `#E8C36A` top bevel, `#8A6A2E` bottom bevel, `#1E120C` outline, 2 screws. Stretched to 46×12 per case. |
| C20 | `cabinets/item_seen_hatch.png` | 16×16 | 64×64 | 1 | **bake.** 1-px diagonal grey hatch `#C9CED6` at α 55%, 3-px pitch, clear between lines. Laid over seen items. |
| C21 | `cabinets/trophy_<biome>_grey.png` ×5 (`verdant_hollow`, `crystal_cavern`, `ashen_crypt`, `cinder_forge`, `shadow_abyss`) | 24×24 | 96×96 | 1 each | **bake.** Desaturated (luma) + darkened 15% from the colour trophy. It's the grey crest for In progress. |
| C23 | `cabinets/case_page_chevron.png` | 4×5 | 16×20 | 1 | Brass chevron stud pointing left (◀), for the PageBar on the case base (SCREEN §5.3). Flip with `flip_h` for ▶. Brass ramp as C19, 1-px `#1E120C` outline. Dimmed by modulate α .35 at the first/last page. **Fallback:** Godot Polygon2D in `#C4A574` with an ink outline. |
| C24 | `cabinets/case_page_chevron_hover.png` | 4×5 | 16×20 | 1 | Same, pixel-registered, top-left highlight `#FFD84A` (zoom hover). |
| C22 | `ui/lore_corner_brass.png` → `assets/dungeon/home/hall/lore_corner_brass.png` | 6×6 | 24×24 | 1 | Brass corner bracket (top-left orientation, 2 rivets), flipped for the other corners. Brass ramp as C19. |

## 2. NEW: dumbwaiter (`assets/dungeon/home/hall/`)
| # | path | native | shipped | frames | notes |
|---|---|---|---|---|---|
| D1 | `hall/dumbwaiter_shaft.png` | 28×161 | 112×644 | 1 | Placed at room native (45,38). **Header** y 0–20: a blank wood plank (label area (2,3) 24×8, no text) + a pulley housing slot at (9,4) 10×10. **Well** y 20–145: dark interior `#120C09`, two vertical guide rails, **5 brass ledges** at local y 43, 68, 93, 118, 143 (2 px). **Left stile** x 0–7 with 5 empty round lamp sockets centred at (4, 32+25k−25). **Right stile** x 25–28. **Base** y 145–161: cabinet front with a lever slot at (17,143) 8×16. Wood ramp `#1E120C`…`#8A5A32`. |
| D2 | `hall/dumbwaiter_car.png` | 16×14 | 64×56 | 1 | Wooden box car hanging from 2 hooks (at x 4 and 11), open tray window at (3,3) 10×8 (dark `#120C09` back). |
| D3 | `hall/dumbwaiter_lever_f0..f2.png` | 8×16 | 32×64 | 3 | Iron lever with a red knob `#A8322A`. f0 up (idle), f1 mid, f2 down (pulled). The pivot pixel is the same in all frames, at (4,12). |
| D4 | `hall/dumbwaiter_lamp_off.png` | 6×6 | 24×24 | 1 | Round brass-rimmed lamp, glass dark `#3A2A1C`. Fits a D1 socket. |
| D5 | `hall/dumbwaiter_lamp_on.png` | 6×6 | 24×24 | 1 | Same, glass `#F09A34` with a `#FFD84A` hot pixel and a 1-px glow halo inside the canvas. |
| D6 | `hall/dumbwaiter_tab.png` | 3×4 | 12×16 | 1 | **bake.** White tab with a 1-px `#1E120C` outline, modulated per biome accent. |
| D7 | `hall/dumbwaiter_pulley_f0..f1.png` | 10×10 | 40×40 | 2 | *Optional.* Spoked iron wheel, 2-frame spin. If it's missing, the housing in D1 reads fine as is. |
| — | ropes | — | — | — | Godot-drawn: 2 ColorRects, 1 native (4 px) wide, `#4A3020`, resized every tween step. |

## 3. EXISTING on tip, reused (no new art)
| asset | use |
|---|---|
| `rooms/cabinets_wall.png` (= Doop `sSXqYUHvO2`, **unchanged**) | Room plate. b2 is covered by C1. The left-wall sconce and stool are covered by D1. |
| `rooms/room_hall_glow.png` | Kept, under the shaft. |
| `cabinets/trophy_verdant_hollow{,_hover}.png`, `trophy_ashen_crypt{,_hover}`, `trophy_cinder_forge{,_hover}`, `trophy_shadow_abyss{,_hover}` (trophy-slots PR #179/#182) | **Crest** on the crown and the sheet (drawn at 48 px = 0.5 of 96). `_hover` = rim-light on case hover. |
| `plaque_glint_f0..f3.png` (16×8) | Claimed-placard twinkle, crest twinkle, Complete crown sweep |
| `trophy_place_burst_f0..f4.png` | Peg landing |
| `fx/fly_spark_f0..f2.png`, `fx/fly_trail.png` | Bank arc to the fixed peg (existing `_bank_fx_arc_to_mount`) |
| `fx/shelf_new_glow_f0..f3.png`, `fx/new_tag.png` | NEW marker on a just-claimed peg (existing behaviour, moved onto the peg) |
| `lantern_glow.png` (35×37) | Case lamp light pool, modulate `#F09A34` α .5, additive |
| Item art `tex_by_item` / `art.item_tex(id)` (64×64) | Peg item, unseen silhouette (modulate), car tray silhouette (32 px) |
| Retired in the hall (keep on disk): `trophy_mount*.png`, `item_seen_overlay.png`, `shelf_locked.png`, `cabinets/case_*.png`, `trophy_sunken_mire*.png` | Not drawn by the new hall |

## 4. Godot-drawn (no PNG)
| element | spec |
|---|---|
| Peg recess | StyleBoxFlat bg `#120C09`, border 4 px `#2B1A12`, radius 0 |
| Peg ledge | StyleBoxFlat `#5C3A22`, 4-px top line `#8A5A32` |
| Crown pips | 5 Panels of 12×12 px, gap 4: on `#FFD84A`, off `#3A2A1C`, border 4 px `#1A120E` |
| Page ticks (PageBar) | one Panel of 12×12 px per page, gap 8 px, border 4 px `#1E120C`: current `#F09A34`, page fully claimed `#FFD84A`, other `#3A2A1C`. Max 7 shown (windowed). No text. |
| Empty recess (last page) | Peg recess + ledge only, no placard or item |
| Depth bars on plaque | 5 × (8×20 px), gap 4: filled `#FFD84A`, empty `#4A3020`, outline `#1E120C` |
| Amber hover frame | StyleBoxFlat no fill, border 4 px `#F09A34` + outer 4 px `#1A120E` |
| Lore panel | StyleBoxFlat bg `#EFE0B6`, border 4 px `#1A120E`, shadow `#0B0706` offset (0,6) size 0, margins 20/16 + 4× C22 corners + Polygon2D tail (parchment, 4-px ink Line2D) |
| Zoom dim | ColorRect `#0B0706` α 0.25 |
| Difficulty chip | existing `UxStyle.metal(tier)` StyleBoxFlat + 3-px `#1A120E` border, `PlayerCopy.tier_name(tier).to_upper()` |
| Placeholder fallback | any missing PNG → ColorRect/StyleBoxFlat in the palette at the same rect, logged once |

## 5. Palette (from the diegetic-cabin guide + Trophy Hall override)
- **Crystal Cavern (glacial):** `#FFFFFF` highlight · `#DCEEF7` · `#CFE6F2` · `#B4D6EA` · `#7FA9C4` (deep ice shade) · outline `#2A4A60`. **Not olive, not swamp, no vines.**
- **Wood:** `#1E120C` outline · `#2B1A12` · `#4A2F1F` · `#5C3A22` · `#7A4E2B` · `#8A5A32`
- **Brass/gold:** `#8A6A2E` · `#C4A574` · `#E8C36A` · `#FFD84A`
- **Linen (sheet):** `#5A564E` · `#7A766C` · `#9C978C` · `#B8B2A4` · outline `#2E2B26`
- **Iron:** `#3A3A3E` · `#6E6E6E` · `#C9CED6`
- **Accents:** torch amber `#F09A34`, parchment `#E6D3A3`/`#EFE0B6`, ink `#4A3020`, pencil `#6E6E6E`, knob red `#A8322A`
- **Biome hem/tab accents:** b1 `#7DAE62` · b2 `#B4D6EA` · b3 `#A8A29A` · b4 `#D06A28` · b5 `#4C4588`

## 6. Export rules
- PNG RGBA, no colour profile, ×4 nearest from native. Snap to the 4-px grid: every opaque run is a multiple of 4 px.
- Hard edges only: no anti-aliasing, no soft shadows, no glows outside the canvas. Alpha is 0 or 255 except the door glass (C4/C5) and the hatch (C20).
- Same canvas and origin for every frame of an animation (C4, C5, C12, D3, D7) and for each hover/alt pair (C2/C3).
- 9-slice (NinePatchRect, `axis_stretch` TILE_FIT for the plaque, STRETCH for the placards): C16–C18 margins 12/12/4/4 px, C19 margins 16 px all sides.
- `.import`: `compress/mode=0`, `mipmaps/generate=false`, `process/fix_alpha_border=true`. The project default texture filter is Nearest. Set `texture_filter = NEAREST` on every TextureRect / AnimatedSprite2D / NinePatchRect anyway.
- Native masters go in `design/trophy-hall/art-source/1x/` (not shipped). The PixelLab raw outputs and the bake script go in `design/trophy-hall/art-source/`.

## 7. Counts
- **PixelLab sprites (images):** C1 1 · C2–C3 2 · C4 4 · C5 4 · C6–C8 3 · C10 1 · C11–C12 4 · C13–C15 3 · C16–C18 3 · C19 1 · C22 1 · C23–C24 2 · D1 1 · D2 1 · D3 3 · D4–D5 2 · D7 2 (optional) = **38 images (36 without the pulley), 25 distinct prompts**
- **Bake script:** C9 3 · C20 1 · C21 5 · D6 1 = **10 images**
- **Reused from tip:** 8 trophy PNGs + glints/bursts/fx/glow/item art
