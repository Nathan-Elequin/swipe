# Home / cabin art: sizes, anchors, timing

Style is Crypt Classic. Everything is drawn at native size and shipped at **4x nearest-neighbour**. All files are PNG RGBA. Coordinates below are in **native px**. Multiply by 4 for the shipped files (they are in brackets). Native copies are in `1x/` (outside the repo).
Godot import: Filter Off, Mipmaps Off. All sprite canvases are transparent except the two room backgrounds and the door frames.

| file | native | shipped | notes |
|---|---|---|---|
| cabin_exterior.png | 420x260 | 1680x1040 | full bleed, opaque. Night scene. The closed door is baked in. Not baked: the lantern (only its bracket is), chimney smoke, roof cat and light pools - those are separate sprites/overlays. |
| cabin_door_closed.png | 52x66 | 208x264 | opaque door leaf. Pixel-identical to the baked door. |
| cabin_door_open_f0..f2.png | 52x66 | 208x264 | opaque. Leaf swings inward (hinge on the left) and shows a dark #120e0c room with a hearth glow. |
| lantern_swing_f0..f2.png | 16x16 | 64x64 | transparent. 15 px tall (hook to bottom outline). |
| cabin_interior.png | 420x260 | 1680x1040 | opaque. The firebox is empty, the chair is not in the background, and the firelight pool is a separate overlay (fire_glow.png). |
| hero_walk_f0..f3.png | 32x32 | 128x128 | Goblin scavenger, faces right. |
| hero_walk_loot_f0..f3.png | 32x32 | 128x128 | same walk with a loot sack (a coin pokes out). |
| hero_rock_f0..f3.png | 32x32 | 128x128 | rocking chair baked in. A coin toss arcs in front of his nose. |
| hero_idle_blink_f0..f1.png | 32x32 | 128x128 | optional idle with a blink. |
| fire_f0..f2.png | 32x32 | 128x128 | hearth fire with the logs baked in. |
| trophy_mount.png / trophy_mount_hover.png | 32x40 | 128x160 | Same registration. The hover version only brightens the gold rim and nameplate. |
| plaque_glint_f0..f3.png | 16x8 | 64x32 | white/gold sweep, no dark pixels. Additive-friendly. |
| shelf_locked.png | 128x40 | 512x160 | Four dark mount silhouettes, a chain, a padlock and a board. Fills 4 mount slots (4 x 32). |
| item_seen_overlay.png | 16x16 | 64x64 | Grey frame with a clear centre. Lay it over the 16x16 recess. |
| hero_drop_sack_f0..f3.png | 32x32 | 128x128 | arrival: the sack slides off his back and plops behind him; the coin bounces and he catches it. One-shot. |
| loot_sack_dropped.png | 32x32 | 128x128 | the sack left on the floor: same canvas, origin and flip as drop_sack f3, without the hero. |
| hero_sit_f0..f4.png | 32x32 | 128x128 | arrival: he hops and plops into the rocking chair (chair baked in). f4 is pixel-identical to hero_rock_f0. One-shot. |
| smoke_puff_f0..f2.png | 48x46 | 192x184 | chimney smoke, seamless 3-frame loop. Soft grey puffs, no outline. |
| cat_idle_f0..f3.png | 16x15 | 64x60 | roof cat: f0 sit, f1 blink, f2 tail up, f3 tail flick + ear twitch. |
| trophy_place_burst_f0..f4.png | 48x48 | 192x192 | stamp when an item lands on a mount: flash, gold ring, sparkles, dust. Light colours only, so it is additive-friendly. One-shot. |
| window_glow.png | 67x29 | 268x116 | exterior light overlay (window spill on the ground). |
| door_glow.png | 93x22 | 372x88 | exterior light overlay (warm pool in front of the door and on the doorstep). |
| lantern_glow.png | 35x37 | 140x148 | exterior light overlay (lantern light on the wall). |
| fire_glow.png | 185x101 | 740x404 | interior light overlay (firelight on the floor, hearth, rug and stones around the firebox; the shelf hole is untouched). |

Not shipped: `design/home/cabin_interior_guides.png` (420x260) and `cabin_interior_guides_4x.png` (1680x1040). They show the shelf hole as a 1px magenta box drawn just outside it, 40px row ticks, and boxes for the fire and chair anchors.

## Exterior anchors (cabin_exterior)
- **Door**: the opening and door sprites go at **(236,134)**, size 52x66 [(944,536), 208x264]. The door sprite canvas equals the opening, so place every door frame at that same origin.
  - Click zone: use the opening **(236,134,52,66)**, or the opening plus its frame **(232,126,60,74)** [(928,504,240,296)]. Both are at least 48x64.
- **Lantern**: the pivot is the hook at **(305,139)** [(1220,556)]. Place the lantern canvas at pivot - (8,0) = **(297,139)** [(1188,556)]. Inside the canvas the pivot pixel is (8,0) [(32..35,0)].
- **Path**: enters at the left edge (x=0, y~236..252) and curves to the doorstep (x 228..294, y 200..206). The centreline is a cubic Bezier through (-14,248), (70,250), (170,214) and (262,204).
  - Hero feet: the walk frames have their feet outline on row 30. Put origin.y = path_y - 30. Example used in the composite: origin (92,207), feet at y 237.
- Baked light pools are flat one-step tone swaps, not gradients: under the window, in front of the door, and around the lantern.

## Interior anchors (cabin_interior)
- **Shelf hole**: **x 140..399, y 20..179** = Rect2(140,20,260,160) [Rect2(560,80,1040,640)]. It holds plain horizontal planks only, 9px pitch, no joints and no props (the build script checks this).
  - That fits 4 rows of 40 px and 8 mounts of 32 px per row (256 px, 4 px slack). With x0 = 142 the rows are centred.
- **Fire**: the firebox opening is **(72,150) 40x46**. Place fire_f* at **(76,164)** [(304,656)]. The fire's bottom row (195) sits on the firebox floor and it is centred at x 91/92.
- **Rocking hero**: place hero_rock_f* at **(10,205)** [(40,820)], on the round rug left of the fire.
  - Inside the frame: seat top is row 20 (x 4..19), so the absolute seat is y 225, x 14..29, centre (22,225). Rockers rest on frame row 28 (absolute 233). The soft shadow is on row 31 (absolute 236).
- Everything else (mantle, candles, sock, herbs, window, rugs) is outside the hole: x < 140, below y 180, or x >= 405.

## Animation-pass anchors (native; shipped = x4)
- **Chimney smoke:** put the smoke_puff_f* canvas at **(290,0)** [(1160,0)]. The chimney mouth is local (15,45) = scene (305,45), just above the chimney cap (cap top row is y 46). The top puffs leave through the canvas and screen top on purpose.
- **Roof cat:** put the cat_idle_f* canvas at **(202,64)** [(808,256)]. The cat sits on the roof ridge (y 78) at the same spot the old baked cat used.
- **Light overlays:** place each at its scene origin:

| overlay | scene | origin (native) | origin (shipped) |
|---|---|---|---|
| window_glow.png | exterior | (170,208) | (680,832) |
| door_glow.png | exterior | (216,201) | (864,804) |
| lantern_glow.png | exterior | (288,133) | (1152,532) |
| fire_glow.png | interior | (0,136) | (0,544) |

  - Each overlay holds the "lit" colours of exactly the pixels it brightens. Draw it with NORMAL blend at alpha 1.0 and the scene matches the old baked look pixel for pixel (checked when this pass was built: the interior is identical, and the exterior differs only where the smoke and cat are now sprites).
  - Z-order: background < glows < every sprite (fire, chair, hero, door, lantern, cat, smoke).
- **Trophy place burst:** put the canvas at **mount origin + (-8,-4)** [(-32,-16) shipped]. The flash centre is local (24,20) = the recess centre, mount (16,16). Dust puffs fall around the nameplate.
- **Interior entry:** drop_sack and loot_sack_dropped go at **(70,205)** [(280,820)], played with **flip_h = true** (the hero faces left, walking toward the chair). Feet row 30 = floor y 235, the same floor line as the chair.

## Arrival beat (scene order)
1. **Exterior:**
   - hero_walk_loot runs along the path to the doorstep. Stop at origin about (242,175): feet at y 205, on the doorstep.
   - Optionally play hero_idle_blink while the door plays cabin_door_open f0, f1, f2 at the door origin (236,134). Hold f2.
   - The hero walks into the doorway, drawn above the door frames. Fade or cut to the interior.
2. **Interior:**
   - hero_walk_loot (flip_h) comes in from the right edge to (70,205).
   - Play **hero_drop_sack f0-f3** (flip_h). **Screen bump on f2**, when the sack thuds.
   - Spawn loot_sack_dropped (flip_h) at the same origin and leave it there.
   - hero_walk (flip_h, no sack) goes from x 70 to x 10.
   - Play **hero_sit f0-f4** at (10,205), not flipped (he turns to face the fire as he hops in). **Screen bump on f3**, the plop.
   - f4 == hero_rock_f0, so continue straight into the hero_rock loop from **f1**.
- **Screen bump:** offset the camera/canvas 1 native px (4 shipped px) down for one frame (about 60-80 ms), then back. Only on drop_sack f2 and sit f3.
- Coin story: it bounces out of the sack (drop f1-f2), he catches it (drop f3), it is hidden in his fist while he walks, he tosses it on the hop (sit f2) and catches it on the plop (sit f3), and then he keeps flipping it in the rock loop.

## Trophy mount (32x40)
- **Recess**: origin **(8,8)**, size 16x16 [(32,32), 64x64]. Drop the existing 16x16 item PNG there at native size, or the 64x64 item at (32,32) on the 4x mount. The 1px sunk lip sits just outside, at x/y 7 and 24.
- **Nameplate**: blank gold strip covering y 32..39 and x 0..31 including the outline. The face is x 2..29, y 34..37.
- **Glint**: put plaque_glint_f* at **(8,32)** in mount space [(32,128)] so it sweeps the plate. You can also tween x from 0 to 16 for a longer sweep.

## Hero frames (32x32, all of them)
- Feet outline is on **row 30** in every walk and idle frame. Row 31 is the 1px soft shadow (#100e0c at 45% alpha). Baseline/pivot = **(16,30)** [(64,120..123)].
- The walk faces right. Flip H for left. The passing frames f1 and f3 bob up 1px.
  - Stride is about 8 px per step. Move about 32 native px/s at 8 fps (128 shipped px/s) to avoid foot sliding.
- Loot frames register exactly like the plain walk, so you can swap mid-step.

## Hero look (goblin scavenger)
- **Skin:** bright moss/lime ramp #c4e07a / #8cbc48 / #5a8a30 / #365a22. It is lighter and yellower than the enemy Greenskin olive (#9cc060 ramp) and nowhere near Nib's slate blue.
- **Body:** big pointy ear poking back through a hole in the hood, long nose, one squinting amber eye (#f0c040) under a heavy lid, toothy grin.
- **Gear:**
  - Hood and cloak in muted teal (#86b4a4 / #4f8a7c / #33605a / #1f3d3a), patched with old sacking (#a07a48 / #74562e) and stitches.
  - Brick-red scarf (#d0644a / #9a3428 / #5e1c18).
  - Two-tone rope belt (#d0b07a / #8a6a40) with a dangling knot, leather hip pouch with a brass clasp.
  - Ragged shorts, skinny shins, big bare green feet.
- **Telling him apart from Nib:** Nib faces front and is a slate-blue imp with horns, a mustard coat and a tail. The hero is a side-view, hooded green goblin with sweeping ears and bare feet.
- **Coin toss (hero_rock), frame-local positions:** f0 in the hand at (17,16), f1 rising edge-on at (19,14), f2 at the top showing the face with a glint at (21,12), f3 falling edge-on at (19,14).

## Frame timing (suggested)
| loop | frames | playback |
|---|---|---|
| hero_walk / hero_walk_loot | f0-f3 | 8 fps (125 ms) loop |
| hero_rock | f0 neutral, f1 back, f2 neutral, f3 forward | 4 fps (250 ms) loop |
| hero_idle_blink | f0 hold 1.5-3 s (randomise), f1 120 ms | loop |
| fire | f0-f2 | 6-7 fps (150 ms) straight loop |
| lantern_swing | f0 left, f1 centre, f2 right | **ping-pong** f0,f1,f2,f1 at 5 fps (200 ms) |
| cabin_door_open | closed, f0, f1, f2 | 12 fps (80 ms) one-shot, hold f2, then cut to the interior |
| plaque_glint | f0-f3 | 14 fps (70 ms) one-shot on hover. Repeat every ~2 s while hovered if you like. Use additive blend (CanvasItemMaterial blend_mode Add). |
| hero_drop_sack | f0 140, f1 140, **f2 220 (bump)**, f3 160 ms, then hold about 300 ms | **one-shot**. Then swap to loot_sack_dropped + hero_walk |
| hero_sit | f0 150, f1 120, f2 110, **f3 200 (bump)**, f4 250 ms | **one-shot**, then hero_rock loop starting at f1 |
| smoke_puff | f0-f2 | 260 ms per frame, straight **loop** (seamless: each frame rises a third of the puff spacing) |
| cat_idle | f0 hold 2-6 s (random); blink = f1 130 ms then back to f0; flick = f2, f3, f2 at 160 ms each then f0 | **idle state machine**: pick blink about 70% of the time and flick about 30% |
| trophy_place_burst | f0 60, f1 70, f2 80, f3 90, f4 100 ms | **one-shot** on placement. Additive blend. Optional 1px bump if the placement should feel heavy |

## Light flicker (engine tweens on the overlays' alpha, normal blend)
| overlay | alpha range | motion | notes |
|---|---|---|---|
| window_glow | 0.85-1.0 | slow sine, period 2.5-4 s (re-randomise each cycle), plus ±0.04 noise every 80-120 ms | firelight seen through glass: gentle |
| door_glow | 0.82-1.0 | same driver as window_glow with a 0.2-0.4 s phase lag (same fire inside) | when the door opens, tween to 1.0 over 0.2 s and hold |
| lantern_glow | 0.75-1.0 | faster sine, period 0.8-1.6 s, plus ±0.06 noise every 70-110 ms | optionally bias it brighter on the lantern's swing extremes |
| fire_glow | 0.75-1.0 | period 0.6-1.2 s random, plus ±0.06 noise every 60-100 ms | for sync, step it with fire_f* frame changes (+0.05 on f1) |
- Keep the noise stepped (snap new targets every 60-120 ms and lerp quickly) rather than smooth per-frame randomness, so it reads as fire, not strobe. Never drop below the minimums; under about 0.7 the pools visibly pop.
- Previews: review/light_flicker_demo.gif and review/fire_glow_flicker_demo.gif.

## Notes
- The goblin is about 27 px tall (ear tip to feet) and the door is 66 px tall, so at 1:1 he is a tiny scavenger. That is intentional: Nathan asked to keep him tiny. If you ever want a bigger read on the exterior only, draw him at 2x there. That breaks the pixel grid, so 1:1 is recommended.
- There is no text anywhere. The nameplate is blank on purpose.
- Rebuild: `python3 /workspace/swipe-assets/gen/home.py` (generator lives outside the repo).
