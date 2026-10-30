# PixelLab commission: Trophy Hall (dumbwaiter ships, strata cut)

**Status:** generated 2026-10-30 (01:46–02:15 CDT). 38 pixflux gens, balance 1004→966. 36 required images + 10 baked, all in `pixellab/final/`; the optional D7 pulley was skipped. Waiting on Pixel's review and **not copied into Cherry**. Details, keepers, hand-pixel fallbacks and flags are in `pixellab/STATUS.md`.
**Prefer free PixelLab:** `pixflux` for statics, `animate`/inpaint for frame sets. Use the existing frame as the init image so the registration matches.
**Estimate:** 25 prompts, 36 required images (+2 optional). Allow about 2–3 gens per keeper: **~70–90 gens in total**. The animation sets (door ×2, lamp, lever) cost the most retries.
**Style anchor (every prompt):** "Crypt Classic pixel art, hard 1-px dark outline, no anti-aliasing, no dithering gradients, limited palette, top-left torch light, flat 3/4 front view, transparent background". Generate at **native** size (or 2× then nearest-downscale), then export ×4 nearest per `ASSET-LIST.md` §6.
**Refs to attach:** tip `rooms/cabinets_wall.png` (Doop `sSXqYUHvO2`), `cabinets/trophy_verdant_hollow.png`, Doop frames `LQYDndcx0L`, `8f1j8BSEe-` (right half only), `BFx-Nk9guT`, `nAq0ZecRXO`.

## Palettes (paste into each prompt)
- **GLACIAL:** `#FFFFFF #DCEEF7 #CFE6F2 #B4D6EA #7FA9C4`, outline `#2A4A60`
- **WOOD:** `#1E120C #2B1A12 #4A2F1F #5C3A22 #7A4E2B #8A5A32`
- **BRASS:** `#8A6A2E #C4A574 #E8C36A #FFD84A`
- **LINEN:** `#2E2B26 #5A564E #7A766C #9C978C #B8B2A4`
- **IRON:** `#1E120C #3A3A3E #6E6E6E #C9CED6`
- **FLAME:** `#A8322A #F09A34 #FFD84A`

## Commission list
| # | file(s) | native | frames | palette | prompt |
|---|---|---|---|---|---|
| 1 | `cabinets/case_crystal_cavern.png` | 60×176 | 1 | GLACIAL + WOOD (dark back only) | Tall glass display cabinet carved from pale glacial ice, white and pale blue. A crown of 5 sharp ice spires on top. A flat pale plank sign band under the spires (leave it blank, no text). Short icicles hanging off the crown lip. A cluster of 3–4 faceted crystals at the base. Thick frosted frame 6 px wide. **Exact transparent rectangular window at (10,44) 48×121**. Frost specks on the frame. It must not look like a swamp, moss or olive case. |
| 2 | `cabinets/trophy_crystal_cavern.png` | 24×24 | 1 | GLACIAL + WOOD | Small trophy: a cluster of 3 pale blue-white ice crystals on a little dark wood pedestal. Same size and pose as the init `trophy_verdant_hollow.png` (use it as init and keep the pedestal footprint). |
| 3 | `cabinets/trophy_crystal_cavern_hover.png` | 24×24 | 1 | + BRASS | Same as #2, pixel-identical, plus a 1-px gold rim light on the top-left edges (match the `trophy_verdant_hollow_hover.png` treatment). |
| 4 | `cabinets/case_door_rect_f0..f3.png` | 64×129 | 4 | WOOD + GLACIAL `#CFE6F2` glass | A glass cabinet door, hinge on the left, opening outward toward the viewer. f0 shut: thin dark wood frame 52×125 at (14,4), nearly clear glass with two diagonal sheen streaks. f1/f2/f3: the door swings open in 3 hard steps, getting narrower with a dark wood edge, and ends as a 12-px slab at the left. Stepped animation, no motion blur. |
| 5 | `cabinets/case_door_arch_f0..f3.png` | 64×129 | 4 | same | Same as #4, but the door has a rounded arched top (for a stone-arch case). Use #4 as init. |
| 6 | `cabinets/case_sheet_rect.png` | 56×166 | 1 | LINEN | A dusty grey-beige linen dust sheet draped over a tall rectangular cabinet, covering it completely. Soft vertical folds, a slightly peaked top over the crown. Dust specks. The bottom 6 rows are a frayed hem in light grey (it gets tinted later). No colour other than the linen palette. |
| 7 | `cabinets/case_sheet_arch.png` | 56×166 | 1 | LINEN | Same sheet over a cabinet with a rounded arch top. Use #6 as init. |
| 8 | `cabinets/case_sheet_spires.png` | 64×180 | 1 | LINEN | Same sheet draped over a cabinet whose crown has 5 sharp spires, so 5 pointed bumps show under the cloth. Use #6 as init. |
| 9 | `cabinets/case_padlock.png` | 10×12 | 1 | IRON + BRASS `#C4A574` | Chunky iron padlock, closed shackle, one brass keyhole, small and readable. |
| 10 | `cabinets/case_lamp_off.png` | 8×12 | 1 | BRASS + WOOD | Tiny hanging brass lantern on a short chain, unlit, dark glass. |
| 11 | `cabinets/case_lamp_on_f0..f2.png` | 8×12 | 3 | BRASS + FLAME | #10 lit: a warm amber flame inside, 3-frame flicker loop. Pixel-registered to #10 (use it as init). |
| 12 | `cabinets/case_gild_rect.png` | 56×166 | 1 | BRASS | Transparent overlay: just a 2-px gold trim outlining a 48×121 window at (8,32), a gold band across the top crown (y 3–16), and 4 gold corner studs. Nothing else is opaque. |
| 13 | `cabinets/case_gild_arch.png` | 56×166 | 1 | BRASS | Same as #12 for an arch-topped window. |
| 14 | `cabinets/case_gild_spires.png` | 64×180 | 1 | BRASS | Same as #12 around the window at (12,46) 48×121, plus thin gold traces up 5 crown spires. |
| 15 | `cabinets/placard_gold_9.png` | 12×5 | 1 | BRASS + `#1E120C` | Tiny gold name placard, bevelled, dark outline. It gets 9-sliced, so the middle columns must be flat. |
| 16 | `cabinets/placard_seen_9.png` | 12×5 | 1 | WOOD + `#6E6E6E` | Tiny dark wood placard with a grey pencil-dashed border (2 on / 1 off). Flat middle. |
| 17 | `cabinets/placard_blank_9.png` | 12×5 | 1 | WOOD | Tiny plain near-black placard with a faint inner line. Flat middle. |
| 18 | `cabinets/case_plaque_9.png` | 16×12 | 1 | BRASS + `#1E120C` | Small brass floor plaque, top bevel light, bottom bevel dark, 2 screws at the left and right. 9-slice friendly: the 8×4 centre must be flat. |
| 19 | `hall/lore_corner_brass.png` | 6×6 | 1 | BRASS | Brass L-shaped corner bracket for the top-left corner of a parchment card, 2 tiny rivets. |
| 19b | `cabinets/case_page_chevron.png` + `_hover.png` | 4×5 | 2 | BRASS + `#1E120C` | Tiny brass chevron stud pointing left, like a cabinet hardware rivet, for flipping trophy-case pages. Hover = the same pixels plus a bright `#FFD84A` top-left highlight. Pixel-registered pair. |
| 20 | `hall/dumbwaiter_shaft.png` | 28×161 | 1 | WOOD + BRASS + IRON | Front view of a narrow wooden dumbwaiter shaft built into a cabin wall.<br>• Top: a blank wooden header plank (no text) with a round pulley housing.<br>• Middle: a dark open shaft with 2 thin iron guide rails and 5 evenly spaced brass ledges (every 25 px).<br>• Left stile: 5 empty round lamp sockets.<br>• Bottom: a cabinet base with a slot for a lever.<br>Same wood and lighting as the cabinets-wall plate. |
| 21 | `hall/dumbwaiter_car.png` | 16×14 | 1 | WOOD + IRON | Small wooden dumbwaiter box car with 2 iron hanging hooks on top and an open dark tray window in the front. |
| 22 | `hall/dumbwaiter_lever_f0..f2.png` | 8×16 | 3 | IRON + `#A8322A` | Iron pull lever with a red ball knob on a small base plate. f0 straight up, f1 at 45°, f2 pulled down. Same pivot in every frame. Stepped. |
| 23 | `hall/dumbwaiter_lamp_off.png` / `_on.png` | 6×6 | 2 | BRASS + FLAME | Round brass-rimmed indicator lamp. Off: dark amber-brown glass. On: bright amber glass with a 1-px yellow hot spot. Pixel-registered pair. |
| 24 | *(optional)* `hall/dumbwaiter_pulley_f0..f1.png` | 10×10 | 2 | IRON | Spoked iron pulley wheel, 2-frame rotation (spokes offset 45°). |

## Not PixelLab (bake script `design/trophy-hall/art-source/bake.py`, PIL, about 10 min)
- `case_sheet_{rect,arch,spires}_hem.png`: white mask of the bottom 6 opaque rows of each sheet.
- `trophy_{verdant_hollow,crystal_cavern,ashen_crypt,cinder_forge,shadow_abyss}_grey.png`: luma desaturate + 15% darken.
- `item_seen_hatch.png`: 16×16, 1-px diagonal `#C9CED6` at α 140, 3-px pitch.
- `dumbwaiter_tab.png`: 3×4 white with a `#1E120C` outline.
- Then ×4 nearest-export everything and write `.import` files (Nearest, no mipmaps, lossless).

## Acceptance (art QA before handing to Cursor)
- **#1** at room native (132,24) fully hides the olive case on `cabinets_wall.png`. Check by compositing in the bake script and eyeballing `contact_b2.png`. The window is exactly 48×121 at (10,44).
- Every frame set keeps the same canvas and origin, and the outline never jitters between frames.
- No text, digits or letters in any sprite.
- Glacial art reads **white / pale blue** next to the green Verdant case, with zero olive or yellow-green pixels.
