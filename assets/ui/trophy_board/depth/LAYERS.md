# Depth layers — trophy board hall (pass 2, stronger)

Authored on the native 420×260 grid and scaled ×4 nearest-neighbour.
Screen-size PNGs (1680×1040) are the ones to composite in game. Native files are `*_native.png`.

Light is from above and slightly left (a skylight plus the existing left sconce), so shadows fall down and to the right. Shadows and light pools use 4×4 Bayer dither in the WOOD / WARM palettes — no Gaussian blur.

## Z-order (back → front)

| Z | Layer | File | Placement | Blend |
|---|---|---|---|---|
| 0 | Room plate + sconce glow | `room_trophy.png`, `room_trophy_glow.png` | 0,0,1680,1040 (native 0,0,420,260) | normal |
| 1 | Warm skylight on the wall | `light_pool_wall.png` | full plate, behind the board. Dithered gold shaft centred on x 840, falling off by native y 110. | normal |
| 2 | Wall drop shadow | `drop_shadow.png` | Cast of the cabinet body (native 44,10,332,192), offset **4 native right, 5 native down** (16 px, 20 px). 5-native dithered falloff, solid core. Hidden under the board; only the offset rim shows, mostly along the right rail. | normal |
| 3 | Board (backdrop, slots, items, lights, lever, frame, placard, dots, arrows) | existing + new art | board 176,40,1328,776 | normal |
| 4 | Floor contact shadow | `floor_shadow.png` | Dithered ellipse on the boards **in front of** the stand only, y 211–213 native (screen 844–855). Stops before the rug (y 214 / 856). Solid contact row under the apron and feet. | normal |
| 5 | Warm floor pool | `light_pool_floor.png` | Dithered gold ellipse on the same boards, native centre (205,212), radii 120×2.6, y 211–213 only. | normal |
| 6 | Oak stand + feet | `bench_stand.png` | Solid (not dithered). Top cap at native y 202–203, apron y 204–210 (28 px at ×4) with a continuous brass bead and plank seams, two brass-capped feet at native (46,201,23,12) and (352,201,23,12) ending at y 212. Sits **in front of** the frame and **on top of** the floor shadow/pool so the furniture stays solid. Does not cover the biome dots (dots end at screen y 796; stand starts at 804). | normal |
| 7 | Nib, hover card, dialog, skip | existing | — | normal |

Pass 1 was too subtle (offset 2×3 native, 4-native plinth, 16% wall wash, and the floor pool was composited *over* the plinth, which speckled it). This pass is meant to be readable at a glance: a real stand, a clear wall shadow, and a warm shaft from above.
