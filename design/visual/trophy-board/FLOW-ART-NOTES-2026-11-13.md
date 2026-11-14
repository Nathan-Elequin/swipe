# Flow-overhaul art drop — 2026-11-13 (lever + satchel redo)

Pixel art, Crypt Classic, **Nearest** filtering on every file (Filter Off, Mipmaps Off). No painterly/realistic treatment. These props stay on the game's pixel grid and outline.

Nothing was committed or pushed. Staged at `/workspace/flow-overhaul-art/`.

## Credits
- PixelLab balance from the first pass: **621.9 → 612.9**. Spent **9** gens (8 pixflux statics + 1 animate-with-text-v3). Floor 100 never approached.
- This redo spent **0** additional gens. The tall lever and the leather floor satchel are hand-pixelled.
- Keepers from PixelLab (approved, unchanged): dead portal (seed 17, init strength 200) + 6-frame mist loop.
- Hand-pixelled (approved, unchanged): arch lights, unique star, carried-items 9-slice strip.
- Hand-pixelled (redone this pass): brass floor lever (all states + pull + glow), floor satchel.

## Filtering
Import every PNG with **Nearest**, no mipmaps, lossless. Same as the rest of the trophy-board / rope-exit set. Do **not** use Linear (that was only for the painted placards).

## Layout in `final/`
Mirrored to repo paths. Shipped files are **×4 nearest** from native (also stored under `final/native/`).

### 1. Brass floor lever — keep existing names, **new size**
Stands on the hall floor beside the board, not on the face lights, not on the sconces.

| file | native | shipped | notes |
|---|---|---|---|
| `assets/ui/trophy_board/lever_locked.png` | **48×56** (was 40×32; original game 16×32) | **192×224** (was 160×128; original 64×128) | Shaft up at 30° from vertical, iron chain + small padlock on the right of the shaft |
| `assets/ui/trophy_board/lever_ready.png` | 48×56 | 192×224 | Same pose, unlocked, warm brass highlights |
| `assets/ui/trophy_board/lever_pulled.png` | 48×56 | 192×224 | Shaft full-down along the quadrant; `= lever_pull_f4` |
| `assets/ui/trophy_board/lever_pull_f0..f4.png` | 48×56 | 192×224 | 5 frames @ 12 fps. f0 = ready, f4 = pulled. Angles lerp 30° → 95° from vertical |
| `assets/ui/trophy_board/lever_glow.png` | **72×80** (was 56×48; original 32×48) | **288×320** | 3 stepped alpha rings, #FFD84A. Do not flatten / snap the alpha |

- Canvas is 48×56 (32×56 was too tight for a 30° shaft plus the full-down pose).
- Pivot (native): **(15.5, 49.0)**
- Shaft length: 26 px. Up / locked / ready angle: **30° from vertical**, clockwise (to the right). Pulled angle: **95°**.
- Ready grip centre ≈ **(28.5, 26.5)**. Bbox top is native y=23, so the grip tops out **33 px** above the ground ≈ **1.27×** Nib’s 26 px visible height (a bit above his head / horns when bottoms are aligned).
- Place the lever bottom-aligned with Nib (Nib is 24×32 native / 96×128 shipped; visible bbox height 26 native / 104 shipped). The lever sprite is 192×224 shipped.
- Glow: place at lever origin **− (8, 14) native / − (32, 56) shipped**. The halo is then centred on the ready grip. Glow canvas 72×80 native / 288×320 shipped.
- Wiring will need to update the old 64×128 (and the first-pass 160×128) hit/art rect. This lever is a floor prop, **192×224**, standing **beside** the board on the hall floor, away from the sconces.

### 2. Dead portal — **approved, unchanged**
Fits `GATE_APERTURE` in `rope_exit.gd`: screen rect `(1244, 443, 256, 448)`, behind `rope_exit_gate_frame.png` (plate `(1180, 379, 384, 512)`).

| file | native | shipped | notes |
|---|---|---|---|
| `assets/dungeon/home/overlays/portal_dead.png` | 64×112 | 256×448 | Static. Dark stone jambs, shallow inner arch, faint cold mist, no swirl |
| `assets/dungeon/home/overlays/portal_dead_mist_f0..f5.png` | 64×112 | 256×448 | 6-frame subtle mist loop. **Stone is locked** (0 px jamb jitter vs f0). 6–8 fps, loop. |

The in-game live portal stays the existing particle vortex in this same aperture. The contact sheet's "live" still is **indicative only** (`work/portal_live_indicative.png`) and is not a ship asset.

### 3. Arch lights — **approved, unchanged**
Same brass-lantern language as the board's 12×16 lights, smaller.

| file | native | shipped | notes |
|---|---|---|---|
| `assets/dungeon/home/overlays/arch_light_off.png` | 8×12 | 32×48 | Dark glass |
| `assets/dungeon/home/overlays/arch_light_on.png` | 8×12 | 32×48 | Lit amber, 1-px hot spot |

Sit five of them along the wooden lintel (gate plate y + ~8 shipped). They count **uniques already placed on the board**.

### 4. Floor satchel + unique star
The satchel was redone: it is a soft leather bag lying on the floor, not a wooden chest. The star is approved and unchanged.

| file | native | shipped | notes |
|---|---|---|---|
| `assets/dungeon/home/overlays/satchel_floor.png` | 64×48 | 256×192 | Soft brown leather, flap folded back, dark strap, brass buckle, three placeholder items peeking from the mouth (scroll, potion, coin pouch). Does **not** replace the homecoming `satchel_idle/open/close` set. |
| `assets/ui/trophy_board/unique_star.png` | 10×10 | 40×40 | Gold badge for new uniques |

**Mouth rect (native, x0,y0,x1,y1):** `(8, 14, 56, 28)` — **48×14**. Room for three 16×16 item icons peeking (width is exact at 3×16; height shows the lower part of each icon, which is the point of "peeking out"). At shipped size the mouth is `(32, 56, 224, 112)` in the 256×192 texture. The painted scroll / potion / pouch are placeholders — composite the real item icons into this rect.

### 5. Carried-items hotbar backing — **approved, unchanged**
| file | native | shipped | notes |
|---|---|---|---|
| `assets/ui/trophy_board/carried_strip_9.png` | 24×16 | 96×64 | Wood trough, brass corner rivets |

**9-slice margins (native):** L **6** / T **5** / R **6** / B **5**
**9-slice margins (shipped ×4):** L **24** / T **20** / R **24** / B **20**
The centre (native x6..17, y5..10) is a flat fill so it stretches without seams.

## What not to do
- Don't overwrite `assets/ui/trophy_board/satchel_*.png` (homecoming bag).
- Don't use Linear filtering on any of this set.
- Don't ship `work/portal_live_indicative.png` as the live portal — the live one is still particles.
