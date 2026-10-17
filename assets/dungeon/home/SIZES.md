# Home / cabin art: sizes, anchors, timing

Style is Crypt Classic. Everything is drawn at native size and shipped at **4x nearest-neighbour**. All files are PNG RGBA. Coordinates below are in **native px**. Multiply by 4 for the shipped files (they are in brackets). Native copies are in `1x/` (outside the repo).
Godot import: Filter Off, Mipmaps Off. All sprite canvases are transparent except the two room backgrounds and the door frames.

| file | native | shipped | notes |
|---|---|---|---|
| cabin_exterior.png | 420x260 | 1680x1040 | full bleed, opaque. Night scene. The closed door is baked in. The lantern is NOT baked (only its bracket is). |
| cabin_door_closed.png | 52x66 | 208x264 | opaque door leaf. Pixel-identical to the baked door. |
| cabin_door_open_f0..f2.png | 52x66 | 208x264 | opaque. Leaf swings inward (hinge on the left) and shows a dark #120e0c room with a hearth glow. |
| lantern_swing_f0..f2.png | 16x16 | 64x64 | transparent. 15 px tall (hook to bottom outline). |
| cabin_interior.png | 420x260 | 1680x1040 | opaque. The firebox is empty and the chair is not in the background. |
| hero_walk_f0..f3.png | 32x32 | 128x128 | Goblin scavenger, faces right. |
| hero_walk_loot_f0..f3.png | 32x32 | 128x128 | same walk with a loot sack (a coin pokes out). |
| hero_rock_f0..f3.png | 32x32 | 128x128 | rocking chair baked in. A coin toss arcs in front of his nose. |
| hero_idle_blink_f0..f1.png | 32x32 | 128x128 | optional idle with a blink. |
| fire_f0..f2.png | 32x32 | 128x128 | hearth fire with the logs baked in. |
| trophy_mount.png / trophy_mount_hover.png | 32x40 | 128x160 | Same registration. The hover version only brightens the gold rim and nameplate. |
| plaque_glint_f0..f3.png | 16x8 | 64x32 | white/gold sweep, no dark pixels. Additive-friendly. |
| shelf_locked.png | 128x40 | 512x160 | Four dark mount silhouettes, a chain, a padlock and a board. Fills 4 mount slots (4 x 32). |
| item_seen_overlay.png | 16x16 | 64x64 | Grey frame with a clear centre. Lay it over the 16x16 recess. |

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

## Notes
- The goblin is about 27 px tall (ear tip to feet) and the door is 66 px tall, so at 1:1 he is a tiny scavenger. That is intentional: Nathan asked to keep him tiny. If you ever want a bigger read on the exterior only, draw him at 2x there. That breaks the pixel grid, so 1:1 is recommended.
- There is no text anywhere. The nameplate is blank on purpose.
- Rebuild: `python3 /workspace/swipe-assets/gen/home.py` (generator lives outside the repo).
