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

---

# Cabin overhaul additions (2026-10-17, branch cabin-overhaul-1)

Same rules: native px, shipped 4x Nearest, RGBA, Filter Off, Mipmaps Off. Everything new lives in sub-folders, so nothing above is renamed or overwritten.
Room backgrounds are opaque 420x260 (1680x1040). Every placement below is the native top-left inside its own room, which is the same as the room-local position of the node; multiply by 4. 
`_hover` / `_press` files are 2px larger on each axis (a 1px rim all round), so place them at origin - (1,1) native [-(4,4) shipped].
Room layout data, including every hotspot, is in `_pixel_extras/layout.json`. The SCREEN-*.md docs repeat it as tables.

## cutscenes/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| cutscenes/ending_p1.png | 1 | 320x180 | 1280x720 | cutscene panel 320x180 (place at panel_frame origin + (8,8)) |
| cutscenes/ending_p2.png | 1 | 320x180 | 1280x720 | cutscene panel 320x180 (place at panel_frame origin + (8,8)) |
| cutscenes/ending_p3.png | 1 | 320x180 | 1280x720 | cutscene panel 320x180 (place at panel_frame origin + (8,8)) |
| cutscenes/intro_p1.png | 1 | 320x180 | 1280x720 | cutscene panel 320x180 (place at panel_frame origin + (8,8)) |
| cutscenes/intro_p2.png | 1 | 320x180 | 1280x720 | cutscene panel 320x180 (place at panel_frame origin + (8,8)) |
| cutscenes/intro_p3.png | 1 | 320x180 | 1280x720 | cutscene panel 320x180 (place at panel_frame origin + (8,8)) |
| cutscenes/intro_p4.png | 1 | 320x180 | 1280x720 | cutscene panel 320x180 (place at panel_frame origin + (8,8)) |
| cutscenes/intro_p5.png | 1 | 320x180 | 1280x720 | cutscene panel 320x180 (place at panel_frame origin + (8,8)) |
| cutscenes/keyring_p1.png | 1 | 320x180 | 1280x720 | cutscene panel 320x180 (place at panel_frame origin + (8,8)) |
| cutscenes/panel_frame.png | 1 | 336x196 | 1344x784 | walnut frame 336x196; centre on screen: origin (42,32); panel at (50,40) origin (42,32) [168,128] |
| cutscenes/rain_f*.png | 3 | 320x180 | 1280x720 | rain layer 3f @ 90ms; intro_p1 clips it to P1_WINDOW, intro_p2 shows it full |

## doors/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| doors/door_sign_hall.png | 1 | 18x14 | 72x56 | little painted sign nailed above each locked door; also the key-ring tags |
| doors/door_sign_loft.png | 1 | 18x14 | 72x56 | little painted sign nailed above each locked door; also the key-ring tags |
| doors/door_sign_study.png | 1 | 18x14 | 72x56 | little painted sign nailed above each locked door; also the key-ring tags |
| doors/door_sign_workshop.png | 1 | 18x14 | 72x56 | little painted sign nailed above each locked door; also the key-ring tags |
| doors/doorway_hover.png | 1 | 40x70 | 160x280 | gold rim for the open doorway back (rooms 1-4), place at BACK_DOOR origin-(4,6) |
| doors/hatch_hover.png | 1 | 50x18 | 200x72 | loft floor hatch (way back down), place at HATCH-(1,1) origin (13,199) [52,796] |
| doors/ladder_hover.png | 1 | 32x197 | 128x788 | gold rim, place at ladder origin-(1,0) origin (369,0) [1476,0] |
| doors/ladder_locked.png | 1 | 30x197 | 120x788 | ladder to the loft (workshop), 30x197 origin (370,0) [1480,0] |
| doors/ladder_open.png | 1 | 30x197 | 120x788 | ladder to the loft (workshop), 30x197 origin (370,0) [1480,0] |
| doors/ladder_unlock_f*.png | 4 | 30x197 | 120x788 | board falls (f0->f1), shackle pops, chain drops, f3 rim glow origin (370,0) [1480,0] |
| doors/run_door_closed.png | 1 | 44x66 | 176x264 | front (run) door leaf, pixel-identical to the baked one origin (250,130) [1000,520] |
| doors/run_door_hover.png | 1 | 52x75 | 208x300 | gold rim around the run-door frame; place at opening-(4,8) origin (246,122) [984,488] |
| doors/run_door_open_f*.png | 3 | 44x66 | 176x264 | opens toward the hall-side hinge; f2 shows night + Grumblegut origin (250,130) [1000,520] |
| doors/side_door_closed.png | 1 | 32x63 | 128x252 | side door 32x63 (same canvas in rooms main/hall/study) |
| doors/side_door_hover.png | 1 | 40x72 | 160x288 | gold rim, place at door origin-(4,8) |
| doors/side_door_locked.png | 1 | 32x63 | 128x252 | side door 32x63 (same canvas in rooms main/hall/study) |
| doors/side_door_open.png | 1 | 32x63 | 128x252 | side door 32x63 (same canvas in rooms main/hall/study) |
| doors/side_door_unlock_f*.png | 4 | 32x63 | 128x252 | key-ring unlock: f0 jiggle, f1 shackle pops (flash), f2 chain slack/lock drops, f3 free + rim glow |
| doors/unlock_sparkle_f*.png | 4 | 32x32 | 128x128 | centre (16,16) on the padlock |

## fx/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| fx/coin_f*.png | 4 | 8x8 | 32x32 | spinning coin, 4f @ 80ms |
| fx/drawer_glint_f*.png | 5 | 12x12 | 48x48 | post-ending hint on the drawer knob: 5f @ 70ms, then wait 2.5-4 s; centre (6,6) on the knob origin (211,163) [844,652] |
| fx/dust_puff_f*.png | 3 | 24x12 | 96x48 | floor dust on thuds, 3f @ 80ms |
| fx/fly_spark_f*.png | 3 | 12x12 | 48x48 | rides on the flying item, 3f @ 80ms loop |
| fx/fly_trail.png | 1 | 6x6 | 24x24 | CPUParticles2D texture for the flight trail |
| fx/hand_glint_f*.png | 5 | 16x16 | 64x64 | never-swiped hand glint over the 16x16 icon, 5f @ 60ms then wait 3.5-5s |
| fx/moth_f*.png | 2 | 8x8 | 32x32 | moth out of the empty sack, 2f @ 100ms |
| fx/new_burst_f*.png | 6 | 48x48 | 192x192 | NEW item pop, centre (24,24); 6f @ 60ms; ADD blend ok |
| fx/new_tag.png | 1 | 14x8 | 56x32 | red corner ribbon on NEW mounts: mount origin + (22,-2) |
| fx/shelf_new_glow_f*.png | 4 | 40x48 | 160x192 | NEW mount halo, place at mount origin-(4,4); 4f @ 160ms loop until clicked |

## hero/gear/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| hero/gear/cap/hero_cheer_f*.png | 2 | 32x32 | 128x128 | cap overlay for hero_cheer: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_climb_f*.png | 2 | 32x32 | 128x128 | cap overlay for hero_climb: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_drop_sack_f*.png | 4 | 32x32 | 128x128 | cap overlay for hero_drop_sack: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_idle_blink_f*.png | 2 | 32x32 | 128x128 | cap overlay for hero_idle_blink: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_idle_loot_f*.png | 2 | 32x32 | 128x128 | cap overlay for hero_idle_loot: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_rock_f*.png | 4 | 32x32 | 128x128 | cap overlay for hero_rock: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_sack_dump_f*.png | 5 | 48x40 | 192x160 | cap overlay for hero_sack_dump: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_sack_shake_f*.png | 6 | 48x40 | 192x160 | cap overlay for hero_sack_shake: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_sit_f*.png | 5 | 32x32 | 128x128 | cap overlay for hero_sit: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_walk_f*.png | 4 | 32x32 | 128x128 | cap overlay for hero_walk: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_walk_loot_f*.png | 4 | 32x32 | 128x128 | cap overlay for hero_walk_loot: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/cap/hero_walk_sad_f*.png | 4 | 32x32 | 128x128 | cap overlay for hero_walk_sad: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_cheer_f*.png | 2 | 32x32 | 128x128 | goggles overlay for hero_cheer: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_climb_f*.png | 2 | 32x32 | 128x128 | goggles overlay for hero_climb: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_drop_sack_f*.png | 4 | 32x32 | 128x128 | goggles overlay for hero_drop_sack: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_idle_blink_f*.png | 2 | 32x32 | 128x128 | goggles overlay for hero_idle_blink: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_idle_loot_f*.png | 2 | 32x32 | 128x128 | goggles overlay for hero_idle_loot: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_rock_f*.png | 4 | 32x32 | 128x128 | goggles overlay for hero_rock: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_sack_dump_f*.png | 5 | 48x40 | 192x160 | goggles overlay for hero_sack_dump: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_sack_shake_f*.png | 6 | 48x40 | 192x160 | goggles overlay for hero_sack_shake: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_sit_f*.png | 5 | 32x32 | 128x128 | goggles overlay for hero_sit: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_walk_f*.png | 4 | 32x32 | 128x128 | goggles overlay for hero_walk: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_walk_loot_f*.png | 4 | 32x32 | 128x128 | goggles overlay for hero_walk_loot: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_walk_sad_f*.png | 4 | 32x32 | 128x128 | goggles overlay for hero_walk_sad: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_cheer_f*.png | 2 | 32x32 | 128x128 | helm overlay for hero_cheer: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_climb_f*.png | 2 | 32x32 | 128x128 | helm overlay for hero_climb: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_drop_sack_f*.png | 4 | 32x32 | 128x128 | helm overlay for hero_drop_sack: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_idle_blink_f*.png | 2 | 32x32 | 128x128 | helm overlay for hero_idle_blink: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_idle_loot_f*.png | 2 | 32x32 | 128x128 | helm overlay for hero_idle_loot: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_rock_f*.png | 4 | 32x32 | 128x128 | helm overlay for hero_rock: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_sack_dump_f*.png | 5 | 48x40 | 192x160 | helm overlay for hero_sack_dump: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_sack_shake_f*.png | 6 | 48x40 | 192x160 | helm overlay for hero_sack_shake: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_sit_f*.png | 5 | 32x32 | 128x128 | helm overlay for hero_sit: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_walk_f*.png | 4 | 32x32 | 128x128 | helm overlay for hero_walk: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_walk_loot_f*.png | 4 | 32x32 | 128x128 | helm overlay for hero_walk_loot: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_walk_sad_f*.png | 4 | 32x32 | 128x128 | helm overlay for hero_walk_sad: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_cheer_f*.png | 2 | 32x32 | 128x128 | rope overlay for hero_cheer: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_climb_f*.png | 2 | 32x32 | 128x128 | rope overlay for hero_climb: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_drop_sack_f*.png | 4 | 32x32 | 128x128 | rope overlay for hero_drop_sack: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_idle_blink_f*.png | 2 | 32x32 | 128x128 | rope overlay for hero_idle_blink: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_idle_loot_f*.png | 2 | 32x32 | 128x128 | rope overlay for hero_idle_loot: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_rock_f*.png | 4 | 32x32 | 128x128 | rope overlay for hero_rock: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_sack_dump_f*.png | 5 | 48x40 | 192x160 | rope overlay for hero_sack_dump: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_sack_shake_f*.png | 6 | 48x40 | 192x160 | rope overlay for hero_sack_shake: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_sit_f*.png | 5 | 32x32 | 128x128 | rope overlay for hero_sit: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_walk_f*.png | 4 | 32x32 | 128x128 | rope overlay for hero_walk: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_walk_loot_f*.png | 4 | 32x32 | 128x128 | rope overlay for hero_walk_loot: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_walk_sad_f*.png | 4 | 32x32 | 128x128 | rope overlay for hero_walk_sad: same canvas/origin/flip as the base frame, draw ABOVE it |

## hero/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| hero/hero_cheer_f*.png | 2 | 32x32 | 128x128 | f0 crouch, f1 jump (new item burst / full cabinet); 140/260 ms, Tween y -4px on f1 |
| hero/hero_climb_f*.png | 2 | 32x32 | 128x128 | rope-ladder climb, 2f @ 160 ms + Tween position.y up |
| hero/hero_idle_loot_f*.png | 2 | 32x32 | 128x128 | idle holding the sack (rope exit, homecoming before the dump) |
| hero/hero_sack_dump_f*.png | 5 | 48x40 | 192x160 | WIN: 48x40 canvas, place at hero origin-(8,8). f0 grab, f1 hug, f2 tip (items pop from DUMP_MOUTH), f3 shake, f4 done. 120/200/260/260/300 ms |
| hero/hero_sack_empty_limp.png | 1 | 6x7 | 24x28 | the empty sack left on the floor after the loss shake (6x7 native; place its bottom-left on the floor at hero origin + (14,24)) |
| hero/hero_sack_shake_f*.png | 6 | 48x40 | 192x160 | LOSS: 48x40 canvas, place at hero origin-(8,8). f0 grab, f1-f3 shake upside-down (one moth on f2), f4 peer in, f5 slump. 120/160/160/160/400/500 ms |
| hero/hero_walk_sad_f*.png | 4 | 32x32 | 128x128 | loss walk-in: head down, ears droop, no sack; 8 fps loop |

## nib/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| nib/nib_bust_blink.png | 1 | 32x32 | 128x128 | dialogue portrait blink |
| nib/nib_bust_f*.png | 3 | 32x32 | 128x128 | dialogue-box portrait 32x32: mouth 0/1/2 |
| nib/nib_gasp.png | 1 | 24x32 | 96x128 | hands up, eyes wide (milestones, ending) |
| nib/nib_idle_f*.png | 2 | 24x32 | 96x128 | Nib idle: f0 hold 2600-4000ms, f1 blink 120ms. 24x32, feet row 30 |
| nib/nib_idle_hover.png | 1 | 26x34 | 104x136 | hover for clicking Nib (canvas 26x34, place at Nib origin-(1,1)) |
| nib/nib_idle_press.png | 1 | 26x34 | 104x136 | press |
| nib/nib_point.png | 1 | 24x32 | 96x128 | points at the door / map |
| nib/nib_psst_f*.png | 2 | 24x32 | 96x128 | "psst" beckon (tutorial prompt) 2f @ 280ms |
| nib/nib_talk_f*.png | 3 | 24x32 | 96x128 | talk mouth cycle 90ms (random 0/1/2) while text types |
| nib/nib_walk_f*.png | 4 | 24x32 | 96x128 | walk 8 fps |

## overlays/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| overlays/deeper_hole_glow_f*.png | 2 | 96x40 | 384x160 | idle pulse 2f @ 500ms origin (250,214) [1000,856] |
| overlays/deeper_hole_hover.png | 1 | 96x40 | 384x160 | hover origin (250,214) [1000,856] |
| overlays/deeper_hole_idle.png | 1 | 96x40 | 384x160 | the hole deeper origin (250,214) [1000,856] |
| overlays/drawer_close.png | 1 | 240x160 | 960x640 | the left-hand drawer, looking down into it: ~60 geodes, the Rightful Heir Latch baked on the near side (centre on screen: origin (90, 50)) origin (90,50) [360,200] |
| overlays/drawer_note.png | 1 | 44x30 | 176x120 | Grandpa's folded note (hotspot); place at drawer-local DRAWER_NOTE; click opens the LetterCard with lore drawer_note |
| overlays/gloria_f*.png | 4 | 12x18 | 48x72 | Gloria in the big tube, 4f @ 180ms |
| overlays/journal_spread.png | 1 | 380x240 | 1520x960 | journal open spread (centre on screen: origin (20, 10)) origin (20,10) [80,40] |
| overlays/journal_tab_bestiary.png | 1 | 18x30 | 72x120 | bookmark tab |
| overlays/journal_tab_bestiary_hover.png | 1 | 18x30 | 72x120 | hover |
| overlays/journal_tab_items.png | 1 | 18x30 | 72x120 | bookmark tab |
| overlays/journal_tab_items_hover.png | 1 | 18x30 | 72x120 | hover |
| overlays/journal_tab_will.png | 1 | 18x30 | 72x120 | bookmark tab |
| overlays/journal_tab_will_hover.png | 1 | 18x30 | 72x120 | hover |
| overlays/lucky_geode_big.png | 1 | 36x30 | 144x120 | the lucky geode in the drawer (hotspot); place at drawer-local DRAWER_GEODE; hidden once geode_on_mantel |
| overlays/lucky_geode_glow_f*.png | 3 | 44x38 | 176x152 | halo behind lucky_geode_big, 0-1-2-1 @ 220ms; drawer-local DRAWER_GEODE_GLOW |
| overlays/map_close.png | 1 | 360x232 | 1440x928 | Grandpa's map close-up (centre on screen: origin (30, 14)) origin (30,14) [120,56] |
| overlays/map_flag.png | 1 | 10x14 | 40x56 | deepest-belly flag (base local (2,13)) |
| overlays/map_flag_unreached.png | 1 | 10x14 | 40x56 | unreached marker (optional) |
| overlays/map_hero_f*.png | 2 | 16x16 | 64x64 | paper hero marker above the active pin, 2f @ 400ms |
| overlays/map_pin_gatehouse_hover.png | 1 | 14x20 | 56x80 | push pin 14x20, TIP at local (6,19) |
| overlays/map_pin_gatehouse_idle.png | 1 | 14x20 | 56x80 | push pin 14x20, TIP at local (6,19) |
| overlays/map_pin_gatehouse_selected.png | 1 | 14x20 | 56x80 | push pin 14x20, TIP at local (6,19) |
| overlays/map_pin_long_drop_hover.png | 1 | 14x20 | 56x80 | push pin 14x20, TIP at local (6,19) |
| overlays/map_pin_long_drop_idle.png | 1 | 14x20 | 56x80 | push pin 14x20, TIP at local (6,19) |
| overlays/map_pin_long_drop_selected.png | 1 | 14x20 | 56x80 | push pin 14x20, TIP at local (6,19) |
| overlays/map_pin_shortcut_hover.png | 1 | 14x20 | 56x80 | push pin 14x20, TIP at local (6,19) |
| overlays/map_pin_shortcut_idle.png | 1 | 14x20 | 56x80 | push pin 14x20, TIP at local (6,19) |
| overlays/map_pin_shortcut_selected.png | 1 | 14x20 | 56x80 | push pin 14x20, TIP at local (6,19) |
| overlays/page_flip_f*.png | 3 | 180x224 | 720x896 | page turn 3f @ 70ms (right->left; flip_h for left->right) |
| overlays/pause_board.png | 1 | 200x180 | 800x720 | pause notice board (centre on screen: origin (110, 40)) origin (110,40) [440,160] |
| overlays/radio_close.png | 1 | 300x200 | 1200x800 | radio close-up (Settings) (centre on screen: origin (60, 30)) origin (60,30) [240,120] |
| overlays/radio_knob_f*.png | 9 | 24x24 | 96x96 | knob at 0.0% (centre local 12,12) |
| overlays/radio_knob_hover_f*.png | 9 | 24x24 | 96x96 | hover version |
| overlays/radio_needle.png | 1 | 3x26 | 12x104 | station needle 3x26 |
| overlays/rope_exit_bg.png | 1 | 420x260 | 1680x1040 | rope exit full-screen scene, opaque origin (0,0) [0,0] |
| overlays/rope_ladder_f*.png | 3 | 40x226 | 160x904 | rope ladder sway 0-1-2-1 @ 220ms origin (96,0) [384,0] |
| overlays/rope_ladder_hover.png | 1 | 40x226 | 160x904 | hover (centre frame + gold rim) origin (96,0) [384,0] |
| overlays/sack_peek_bg.png | 1 | 360x210 | 1440x840 | sack peek (escape + pause) (centre on screen: origin (30, 25)) origin (30,25) [120,100] |
| overlays/sack_slot_glow.png | 1 | 36x36 | 144x144 | ring behind a NEW item in the sack |
| overlays/torch_flame_f*.png | 3 | 12x14 | 48x56 | wall torch 3f @ 120ms origin (384,92) [1536,368] |
| overlays/wax_seal.png | 1 | 28x26 | 112x104 | intact seal |
| overlays/wax_seal_broken.png | 1 | 28x26 | 112x104 | broken seal |
| overlays/will_close.png | 1 | 260x220 | 1040x880 | the will, unrolled (centre on screen: origin (80, 20)) origin (80,20) [320,80] |

## props/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| props/bed.png | 1 | 96x40 | 384x160 | Grandpa's bed: Quit (desktop) / flavour line (web) origin (290,166) [1160,664] |
| props/bed_hover.png | 1 | 98x42 | 392x168 | hover (canvas +2px, place at origin-(1,1)) origin (289,165) [1156,660] |
| props/bed_press.png | 1 | 98x42 | 392x168 | press (canvas +2px, place at origin-(1,1)) origin (289,165) [1156,660] |
| props/brag_gear_f*.png | 4 | 12x12 | 48x48 | spinning cog: place at bragometer origin + BRAG_GEAR; 4f @ 120ms loop |
| props/bragometer.png | 1 | 48x46 | 192x184 | Brag-o-Meter: run stats (opens a parchment card) origin (186,112) [744,448] |
| props/bragometer_hover.png | 1 | 50x48 | 200x192 | hover (canvas +2px, place at origin-(1,1)) origin (185,111) [740,444] |
| props/bragometer_press.png | 1 | 50x48 | 200x192 | press (canvas +2px, place at origin-(1,1)) origin (185,111) [740,444] |
| props/candle_flame_f*.png | 3 | 6x9 | 24x36 | candle flame 6x9, 3f @ 140ms random start |
| props/cat_sleep_f*.png | 2 | 20x12 | 80x48 | loft cat breathing, 2f @ 900ms origin (176,196) [704,784] |
| props/desk_drawer.png | 1 | 32x9 | 128x36 | top-left desk drawer, pixel-identical to the baked front (stuck until ending_seen) origin (202,166) [808,664] |
| props/desk_drawer_ajar.png | 1 | 34x11 | 136x44 | post-ending idle: front dropped 1px, warm light in the gap (34x11) origin (201,165) [804,660] |
| props/desk_drawer_ajar_hover.png | 1 | 36x13 | 144x52 | hover (canvas +2px, place at origin-(1,1)) origin (200,164) [800,656] |
| props/desk_drawer_hover.png | 1 | 34x11 | 136x44 | hover (canvas +2px, place at origin-(1,1)) origin (201,165) [804,660] |
| props/desk_drawer_open_f*.png | 4 | 40x22 | 160x88 | open: 4f @ 90ms then hold f3 while the close-up is up (40x22, place at (198,163)) origin (198,163) [792,652] |
| props/desk_drawer_press.png | 1 | 34x11 | 136x44 | press (canvas +2px, place at origin-(1,1)) origin (201,165) [804,660] |
| props/desk_drawer_rattle_f*.png | 3 | 36x12 | 144x48 | stuck click: f0,f1,f2,f0 @ 60ms (36x12, place at (200,166)); dust specks on f1/f2 origin (200,166) [800,664] |
| props/dummy.png | 1 | 32x50 | 128x200 | training dummy: replay the How-to-Play tutorial origin (48,150) [192,600] |
| props/dummy_hover.png | 1 | 34x52 | 136x208 | hover (canvas +2px, place at origin-(1,1)) origin (47,149) [188,596] |
| props/dummy_press.png | 1 | 34x52 | 136x208 | press (canvas +2px, place at origin-(1,1)) origin (47,149) [188,596] |
| props/dummy_tilt_l.png | 1 | 32x50 | 128x200 | click wobble: f0 idle, tilt_l, tilt_r, tilt_l, idle @ 70ms origin (48,150) [192,600] |
| props/dummy_tilt_r.png | 1 | 32x50 | 128x200 | click wobble: f0 idle, tilt_l, tilt_r, tilt_l, idle @ 70ms origin (48,150) [192,600] |
| props/gear_cap.png | 1 | 18x18 | 72x72 | gear piece on peg 1 (slot head) origin (315,100) [1260,400] |
| props/gear_cap_hover.png | 1 | 20x20 | 80x80 | hover (canvas +2px, place at origin-(1,1)) origin (314,99) [1256,396] |
| props/gear_cap_press.png | 1 | 20x20 | 80x80 | press (canvas +2px, place at origin-(1,1)) origin (314,99) [1256,396] |
| props/gear_goggles.png | 1 | 18x18 | 72x72 | gear piece on peg 2 (slot eyes) origin (329,100) [1316,400] |
| props/gear_goggles_hover.png | 1 | 20x20 | 80x80 | hover (canvas +2px, place at origin-(1,1)) origin (328,99) [1312,396] |
| props/gear_goggles_press.png | 1 | 20x20 | 80x80 | press (canvas +2px, place at origin-(1,1)) origin (328,99) [1312,396] |
| props/gear_helm.png | 1 | 18x18 | 72x72 | gear piece on peg 0 (slot head) origin (301,100) [1204,400] |
| props/gear_helm_hover.png | 1 | 20x20 | 80x80 | hover (canvas +2px, place at origin-(1,1)) origin (300,99) [1200,396] |
| props/gear_helm_press.png | 1 | 20x20 | 80x80 | press (canvas +2px, place at origin-(1,1)) origin (300,99) [1200,396] |
| props/gear_peg_empty.png | 1 | 18x18 | 72x72 | placeholder (empty peg = hide the piece; the peg is baked in the rack) |
| props/gear_rack.png | 1 | 64x18 | 256x72 | peg rack by the door (not clickable itself) origin (300,92) [1200,368] |
| props/gear_rope.png | 1 | 18x18 | 72x72 | gear piece on peg 3 (slot belt) origin (343,100) [1372,400] |
| props/gear_rope_hover.png | 1 | 20x20 | 80x80 | hover (canvas +2px, place at origin-(1,1)) origin (342,99) [1368,396] |
| props/gear_rope_press.png | 1 | 20x20 | 80x80 | press (canvas +2px, place at origin-(1,1)) origin (342,99) [1368,396] |
| props/journal.png | 1 | 44x24 | 176x96 | Grandpa's journal on the lectern: opens the bestiary/compendium origin (104,130) [416,520] |
| props/journal_hover.png | 1 | 46x26 | 184x104 | hover (canvas +2px, place at origin-(1,1)) origin (103,129) [412,516] |
| props/journal_new.png | 1 | 44x24 | 176x96 | journal with a red NEW ribbon (a monster you met has no read entry yet) origin (104,130) [416,520] |
| props/journal_new_hover.png | 1 | 46x26 | 184x104 | hover (canvas +2px, place at origin-(1,1)) origin (103,129) [412,516] |
| props/journal_press.png | 1 | 46x26 | 184x104 | press (canvas +2px, place at origin-(1,1)) origin (103,129) [412,516] |
| props/key_ring_f*.png | 3 | 30x28 | 120x112 | in-room key ring: f0 still, f1/f2 jingle swing |
| props/lucky_geode.png | 1 | 16x13 | 64x52 | bonus cosmetic: Grandpa's lucky geode on the mantel (bottom row on the mantel line y116) origin (68,105) [272,420] |
| props/lucky_geode_hover.png | 1 | 18x15 | 72x60 | hover (canvas +2px, place at origin-(1,1)) origin (67,104) [268,416] |
| props/lucky_geode_press.png | 1 | 18x15 | 72x60 | press (canvas +2px, place at origin-(1,1)) origin (67,104) [268,416] |
| props/map_wall.png | 1 | 68x52 | 272x208 | Grandpa's map: pick mode/route (opens overlays/map_close) origin (148,30) [592,120] |
| props/map_wall_hover.png | 1 | 70x54 | 280x216 | hover (canvas +2px, place at origin-(1,1)) origin (147,29) [588,116] |
| props/map_wall_press.png | 1 | 70x54 | 280x216 | press (canvas +2px, place at origin-(1,1)) origin (147,29) [588,116] |
| props/mountain_model.png | 1 | 30x32 | 120x128 | bell-jar model of Grumblegut: shows deepest belly reached (tooltip) origin (336,28) [1344,112] |
| props/mountain_model_hover.png | 1 | 32x34 | 128x136 | hover (canvas +2px, place at origin-(1,1)) origin (335,27) [1340,108] |
| props/mountain_model_press.png | 1 | 32x34 | 128x136 | press (canvas +2px, place at origin-(1,1)) origin (335,27) [1340,108] |
| props/patents.png | 1 | 54x42 | 216x168 | framed patents: credits origin (290,36) [1160,144] |
| props/patents_hover.png | 1 | 56x44 | 224x176 | hover (canvas +2px, place at origin-(1,1)) origin (289,35) [1156,140] |
| props/patents_press.png | 1 | 56x44 | 224x176 | press (canvas +2px, place at origin-(1,1)) origin (289,35) [1156,140] |
| props/portrait_big.png | 1 | 56x68 | 224x272 | big portrait over the desk: opens the will origin (176,22) [704,88] |
| props/portrait_big_hover.png | 1 | 58x70 | 232x280 | hover (canvas +2px, place at origin-(1,1)) origin (175,21) [700,84] |
| props/portrait_big_press.png | 1 | 58x70 | 232x280 | press (canvas +2px, place at origin-(1,1)) origin (175,21) [700,84] |
| props/portrait_small.png | 1 | 30x36 | 120x144 | small portrait of Grandpa on the chimney breast: Nib quips origin (80,40) [320,160] |
| props/portrait_small_hover.png | 1 | 32x38 | 128x152 | hover (canvas +2px, place at origin-(1,1)) origin (79,39) [316,156] |
| props/portrait_small_press.png | 1 | 32x38 | 128x152 | press (canvas +2px, place at origin-(1,1)) origin (79,39) [316,156] |
| props/radio.png | 1 | 44x72 | 176x288 | the Snatchwick Melodeon = Settings (opens overlays/radio_close) origin (150,124) [600,496] |
| props/radio_firefly_f*.png | 4 | 12x16 | 48x64 | Gloria in the tube; place at radio origin + RADIO_TUBE.xy; 4f @ 180ms ping-pong |
| props/radio_hover.png | 1 | 46x74 | 184x296 | hover (canvas +2px, place at origin-(1,1)) origin (149,123) [596,492] |
| props/radio_press.png | 1 | 46x74 | 184x296 | press (canvas +2px, place at origin-(1,1)) origin (149,123) [596,492] |
| props/telescope.png | 1 | 36x94 | 144x376 | telescope at the round window: peek at Grumblegut (flavour + deepest belly) origin (226,104) [904,416] |
| props/telescope_hover.png | 1 | 38x96 | 152x384 | hover (canvas +2px, place at origin-(1,1)) origin (225,103) [900,412] |
| props/telescope_press.png | 1 | 38x96 | 152x384 | press (canvas +2px, place at origin-(1,1)) origin (225,103) [900,412] |
| props/trunk.png | 1 | 42x28 | 168x112 | trunk of letters: read unlocked letters (milestones) origin (96,184) [384,736] |
| props/trunk_hover.png | 1 | 44x30 | 176x120 | hover (canvas +2px, place at origin-(1,1)) origin (95,183) [380,732] |
| props/trunk_open.png | 1 | 42x28 | 168x112 | trunk with the lid up (shown while the letters card is open) origin (96,184) [384,736] |
| props/trunk_open_hover.png | 1 | 44x30 | 176x120 | hover (canvas +2px, place at origin-(1,1)) origin (95,183) [380,732] |
| props/trunk_press.png | 1 | 44x30 | 176x120 | press (canvas +2px, place at origin-(1,1)) origin (95,183) [380,732] |
| props/will.png | 1 | 36x14 | 144x56 | the will on the desk: opens overlays/will_close origin (226,146) [904,584] |
| props/will_hover.png | 1 | 38x16 | 152x64 | hover (canvas +2px, place at origin-(1,1)) origin (225,145) [900,580] |
| props/will_press.png | 1 | 38x16 | 152x64 | press (canvas +2px, place at origin-(1,1)) origin (225,145) [900,580] |

## rooms/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| rooms/room_hall.png | 1 | 420x260 | 1680x1040 | hall room background, opaque 420x260 origin (0,0) [0,0] |
| rooms/room_hall_glow.png | 1 | 91x175 | 364x700 | light overlay: NORMAL blend, alpha 1.0, above bg / below sprites origin (20,40) [80,160] |
| rooms/room_loft.png | 1 | 420x260 | 1680x1040 | loft room background, opaque 420x260 origin (0,0) [0,0] |
| rooms/room_loft_candle_glow.png | 1 | 80x91 | 320x364 | light overlay: NORMAL blend, alpha 1.0, above bg / below sprites origin (340,120) [1360,480] |
| rooms/room_loft_moon.png | 1 | 129x191 | 516x764 | light overlay: NORMAL blend, alpha 1.0, above bg / below sprites origin (152,40) [608,160] |
| rooms/room_main.png | 1 | 420x260 | 1680x1040 | main room background, opaque 420x260 origin (0,0) [0,0] |
| rooms/room_main_fire_glow.png | 1 | 185x101 | 740x404 | light overlay: NORMAL blend, alpha 1.0, above bg / below sprites origin (0,136) [0,544] |
| rooms/room_study.png | 1 | 420x260 | 1680x1040 | study room background, opaque 420x260 origin (0,0) [0,0] |
| rooms/room_study_glow.png | 1 | 170x66 | 680x264 | light overlay: NORMAL blend, alpha 1.0, above bg / below sprites origin (180,110) [720,440] |
| rooms/room_workshop.png | 1 | 420x260 | 1680x1040 | workshop room background, opaque 420x260 origin (0,0) [0,0] |
| rooms/room_workshop_glow.png | 1 | 130x201 | 520x804 | light overlay: NORMAL blend, alpha 1.0, above bg / below sprites origin (40,20) [160,80] |

## ui/

| file | frames | native | shipped | notes / anchor |
|---|---|---|---|---|
| ui/choice_tag_hover.png | 1 | 64x16 | 256x64 | choice / button tag, 9-slice margins 8,4,8,4 |
| ui/choice_tag_idle.png | 1 | 64x16 | 256x64 | choice / button tag, 9-slice margins 8,4,8,4 |
| ui/choice_tag_press.png | 1 | 64x16 | 256x64 | choice / button tag, 9-slice margins 8,4,8,4 |
| ui/dialog_box_9.png | 1 | 48x48 | 192x192 | NinePatchRect / StyleBoxTexture, patch margins 12,12,12,12 (native) = 48 shipped |
| ui/dialog_next_f*.png | 2 | 8x8 | 32x32 | next-arrow bob 2f @ 300ms |
| ui/gauge_fill.png | 1 | 164x5 | 656x20 | TextureProgressBar progress |
| ui/gauge_under.png | 1 | 164x5 | 656x20 | TextureProgressBar under (trophy hall plinth) |
| ui/nameplate_9.png | 1 | 48x14 | 192x56 | 9-slice margins 6,0,6,0 |
| ui/overlay_vignette.png | 1 | 420x260 | 1680x1040 | full-screen veil under every close-up overlay origin (0,0) [0,0] |
| ui/room_toast.png | 1 | 120x26 | 480x104 | room-name sign that drops in from the top on room change |
| ui/shelf_arrow_left.png | 1 | 16x12 | 64x48 | cabinet page arrow (calls the existing _on_nav(-1/+1)) origin (124,185) [496,740] |
| ui/shelf_arrow_left_hover.png | 1 | 18x14 | 72x56 | hover (canvas +2px, place at origin-(1,1)) origin (123,184) [492,736] |
| ui/shelf_arrow_left_press.png | 1 | 18x14 | 72x56 | press (canvas +2px, place at origin-(1,1)) origin (123,184) [492,736] |
| ui/shelf_arrow_right.png | 1 | 16x12 | 64x48 | cabinet page arrow (calls the existing _on_nav(-1/+1)) origin (320,185) [1280,740] |
| ui/shelf_arrow_right_hover.png | 1 | 18x14 | 72x56 | hover (canvas +2px, place at origin-(1,1)) origin (319,184) [1276,736] |
| ui/shelf_arrow_right_press.png | 1 | 18x14 | 72x56 | press (canvas +2px, place at origin-(1,1)) origin (319,184) [1276,736] |
| ui/slider_fill_9.png | 1 | 64x8 | 256x32 | grabber_area style, margins 4,0,4,0 |
| ui/slider_grabber.png | 1 | 12x14 | 48x56 | HSlider grabber |
| ui/slider_grabber_hover.png | 1 | 12x14 | 48x56 | grabber_highlight |
| ui/slider_track_9.png | 1 | 64x8 | 256x32 | HSlider slider style, margins 4,0,4,0 |
| ui/speech_tail.png | 1 | 10x8 | 40x32 | tail under the dialogue box pointing at the speaker |
| ui/tooltip_parchment_9.png | 1 | 32x32 | 128x128 | trophy-hall tooltip, 9-slice margins 10 |

## Overlay origins (native, on the 420x260 screen)

- `overlays/map_close.png` at (30,14) [120,56]
- `overlays/radio_close.png` at (60,30) [240,120]
- `overlays/journal_spread.png` at (20,10) [80,40]
- `overlays/will_close.png` at (80,20) [320,80]
- `overlays/drawer_close.png` at (90,50) [360,200]
- `overlays/sack_peek_bg.png` at (30,25) [120,100]
- `overlays/pause_board.png` at (110,40) [440,160]

## Key anchors

```json
{
 "room_order": [
  "main",
  "hall",
  "study",
  "workshop",
  "loft"
 ],
 "room_px": 1680,
 "map_pins": {
  "gatehouse": [
   92,
   168
  ],
  "long_drop": [
   184,
   92
  ],
  "shortcut": [
   268,
   150
  ]
 },
 "map_deep_flags": [
  [
   184,
   104
  ],
  [
   184,
   124
  ],
  [
   186,
   146
  ],
  [
   182,
   168
  ],
  [
   186,
   190
  ]
 ],
 "map_legend": [
  16,
  188,
  120,
  32
 ],
 "map_origin": [
  30,
  14
 ],
 "radio_knobs": [
  [
   48,
   150
  ],
  [
   96,
   150
  ],
  [
   144,
   150
  ],
  [
   192,
   150
  ],
  [
   240,
   150
  ]
 ],
 "station_dial": [
  66,
  70,
  168,
  26
 ],
 "station_knob": [
  262,
  84
 ],
 "radio_tube": [
  138,
  14,
  24,
  34
 ],
 "journal_pages": {
  "left": [
   22,
   18,
   166,
   204
  ],
  "right": [
   196,
   18,
   166,
   204
  ]
 },
 "journal_portrait": [
  62,
  34,
  64,
  64
 ],
 "journal_tabs": {
  "bestiary": [
   366,
   30
  ],
  "items": [
   366,
   66
  ],
  "will": [
   366,
   102
  ]
 },
 "will_text": [
  40,
  34,
  180,
  150
 ],
 "will_seal": [
  112,
  186
 ],
 "sack_slots": [
  [
   78,
   70
  ],
  [
   122,
   70
  ],
  [
   166,
   70
  ],
  [
   210,
   70
  ],
  [
   254,
   70
  ],
  [
   78,
   118
  ],
  [
   122,
   118
  ],
  [
   166,
   118
  ],
  [
   210,
   118
  ],
  [
   254,
   118
  ]
 ],
 "pause_buttons": [
  [
   36,
   46
  ],
  [
   36,
   72
  ],
  [
   36,
   98
  ],
  [
   36,
   124
  ]
 ],
 "pause_sliders": [
  24,
  150,
  152
 ],
 "overlay_origins": {
  "overlays/map_close.png": [
   30,
   14
  ],
  "overlays/radio_close.png": [
   60,
   30
  ],
  "overlays/journal_spread.png": [
   20,
   10
  ],
  "overlays/will_close.png": [
   80,
   20
  ],
  "overlays/drawer_close.png": [
   90,
   50
  ],
  "overlays/sack_peek_bg.png": [
   30,
   25
  ],
  "overlays/pause_board.png": [
   110,
   40
  ]
 },
 "dump_mouth": [
  40,
  34
 ],
 "wide_offset": [
  -8,
  -8
 ],
 "keyring_tags": [
  [
   114,
   126
  ],
  [
   142,
   134
  ],
  [
   170,
   134
  ],
  [
   198,
   126
  ]
 ],
 "p1_window": [
  210,
  30,
  64,
  52
 ],
 "p1_drip": [
  186,
  22,
  186,
  110
 ],
 "gear_slots": {
  "helm": "head",
  "cap": "head",
  "goggles": "eyes",
  "rope": "belt"
 },
 "rack_pegs": [
  [
   10,
   9
  ],
  [
   24,
   9
  ],
  [
   38,
   9
  ],
  [
   52,
   9
  ]
 ],
 "drawer_note": [
  156,
  26
 ],
 "drawer_geode": [
  52,
  60
 ],
 "drawer_geode_glow": [
  47,
  56
 ],
 "drawer_latch": [
  108,
  134
 ],
 "drawer_knob": [
  217,
  169
 ],
 "lucky_geode_mantel": [
  68,
  105
 ]
}
```
