# 07-cabin-wiring: wire the unwired cabin PNGs (Cursor CLI task)

Task id: `cabin-wiring`. Commit each step as `cabin-wiring(n): <what>`. Work ONLY in this worktree. Do not merge, push, stash, reset, or force anything.
Write `design/cli-runs/07-cabin-wiring/REPORT.md` at the end (status, checkpoint, commits, files, shots, audit summary, deviations, questions tagged [Pixel]/[Jam]/[Nathan], what Nathan should look at, ## ART-REQUEST entries).

## Why
A read-only audit found PNGs that Pixel delivered per `assets/dungeon/home/SIZES.md` but that no game code ever loads. Wire them in so they actually show up. The PNGs are final; your job is code (GDScript / scenes / shot harness) only.

## Hard constraints
- Animation via AnimatedSprite2D/SpriteFrames, frame-swapping TextureRect/Sprite2D, or Tweens only. No shaders, no new nodes types beyond stock Godot, no new dependencies, no new fonts.
- Nearest filtering (match how existing cabin textures are drawn; use `KIT.load_tex(...)`, `KIT.tex_rect(...)`, `KIT.nine(...)`, `KIT.tex_style(...)` helpers in `scripts/cabin/cabin_kit.gd` and `_home(...)` in `scripts/home_cabin.gd`). Native→shipped scale is 4x (`KIT.pt()` / `PX`).
- Do NOT change any player-facing copy, `data/player-copy.json`, fonts, font sizes, or existing text layout.
- Do NOT redraw, edit, recolor, stretch or resave any PNG. If an asset doesn't fit (wrong size/anchor/frames, or no sensible place), add a `## ART-REQUEST` entry in REPORT.md (path, native size, 4x Nearest, pivot, loop, palette notes, what's wrong) and skip it.
- Do NOT touch these files at all (another session has uncommitted edits in them; touching them would block a fast-forward): `scripts/main.gd`, `scripts/dungeon_art.gd`, `scripts/ux_style.gd`, `scripts/item_card.gd`, `scripts/ability_slash.gd`, `scripts/boss_wheel.gd`, `scripts/combat_log.gd`, `scripts/combat_stage.gd`, `scripts/content_editor.gd`, anything under `data/` (catalog.json, content-board.json, runtime.json, author-locks.json, recent-edits.json, player-copy*.json, cabin-layout.json is OK to READ; editing data/cabin-layout.json is also forbidden), `design/audit-shots/**`, and any `.import` file. If a hook you need only exists in one of those files, report it as a question instead.
- Allowed to edit: `scripts/home_cabin.gd`, `scripts/cabin/*.gd`, `scripts/settings_menu.gd`, `scripts/dev/shot_harness.gd` (and other `scripts/dev/*` shot plumbing), scenes under `scenes/` that are cabin-only, plus your REPORT.md.
- Keep behaviour identical when a texture is missing (`KIT.load_tex` returns null): fall back to today's behaviour.
- Skip, don't wire: `props/gear_peg_empty.png` (doc calls it a placeholder; empty peg = hide piece) and the old root `fire_glow.png` (superseded by `rooms/room_main_fire_glow.png`). List both in REPORT as dead.
- One Godot process at a time. The Godot console exe is `C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`; use `--headless`. A "godot-mcp port 6550 in use" message is expected noise. An editor may be open on the main folder; never open the editor on this worktree.

## What each unwired asset is for (audit table) — wire all of these
| Asset(s) | Intended use / where |
|---|---|
| `doors/run_door_open_f0-2` (3f, 44x66, origin (250,130)) | Main-room front (run) door opening animation when the player leaves for a run (f2 shows night + Grumblegut). Play before the existing run transition; don't delay it more than ~300 ms total. |
| `doors/side_door_open.png` (32x63, same canvas as side_door_closed) | Side door open state in rooms main/hall/study (`room_main.gd`, `room_hall.gd`, `room_study.gd`): show it briefly when the player walks through an unlocked side door (and/or as its open state), then the existing room change. |
| `fx/coin_f0-3` (8x8, 4f @80ms) | Spinning coin in the loot-fly / homecoming sequence (e.g. the coin bounce/catch or coins tossed with the dump). |
| `fx/dust_puff_f0-2` (24x12, 3f @80ms) | Floor dust on thuds: wherever `_bump()` fires for a floor thud (sack drop/dump, sit plop), spawn one puff at the feet/sack on the floor line. |
| `fx/fly_spark_f0-2` (12x12, 3f @80ms loop) | Rides on the item while it flies from the sack to its trophy mount (homecoming fly; see `debug_win_fly` in home_cabin.gd and the 21b shot). |
| `fx/fly_trail.png` (6x6) | CPUParticles2D texture for that same flight trail (stock CPUParticles2D is allowed for this one). |
| `fx/new_burst_f0-5` (48x48, centre (24,24), 6f @60ms, ADD blend ok) | NEW item pop when a newly-found item lands on its mount (pairs with `fx/new_tag.png`). |
| `hero_drop_sack_f0-3` (root home/, 32x32) + `hero/gear/{cap,goggles,helm,rope}/hero_drop_sack_f0-3` | Interior arrival: sack slides off and plops (SIZES "Interior entry": at (70,205), flip_h=true, timings f0 140/f1 140/f2 220 (bump)/f3 160 ms, hold ~300 ms, then `loot_sack_dropped` + hero_walk). Use the existing `_set_hero_frame(family,i)` so gear overlays layer automatically (it tries `hero/<family>_f<i>` then root `<family>_f<i>`). If the current homecoming flow (hero_sack_dump/shake) already replaced this beat, find the sensible spot (e.g. a non-win / plain return where the sack is set down) or report why not. |
| `chair_settle_f0-3` (root home/, not in SIZES) | Optional: inspect the frames (Read the PNGs). If they're clearly the empty chair settling/rocking after the hero stands up, play them on stand-up from the chair (`_show_empty_chair` path); otherwise skip and report. |
| `overlays/deeper_hole_glow_f0-1` (96x40, origin (250,214), 2f @500ms) | Idle pulse on the "deeper" hole in the rope exit (`scripts/cabin/rope_exit.gd`, `_hole` uses deeper_hole_idle/hover). Pulse while idle; hover still shows hover. |
| `overlays/page_flip_f0-2` (180x224, 3f @70ms, right->left; flip_h for left->right) | Journal page turn in `scripts/cabin/journal_overlay.gd`; the `cabin.page_flip` sound cue already plays (line ~417) — play the flip anim at the same time over the page being turned. |
| `overlays/radio_knob_hover_f0-8` (24x24, 9 frames matching radio_knob_f0-8) | Radio knob hover version in `scripts/cabin/radio_overlay.gd` (`_refresh_knob`): when hovered show `radio_knob_hover_f<frame>`. |
| `props/desk_drawer_open_f0-3` (40x22 at (198,163), 4f @90ms then hold f3 while the close-up is up) | Desk drawer opening in the study (`room_study.gd` + drawer logic in home_cabin.gd `drawer_opened` etc.). |
| `props/desk_drawer_rattle_f0-2` (36x12 at (200,166); f0,f1,f2,f0 @60ms) | Stuck drawer click (before ending_seen) — play with the existing unlatch/stuck cue. |
| `props/dummy_tilt_l.png` / `dummy_tilt_r.png` (32x50, origin (48,150)) | Training-dummy click wobble: idle, tilt_l, tilt_r, tilt_l, idle @70ms (`_on_dummy` in home_cabin.gd / workshop hotspot). |
| `ui/slider_track_9`, `ui/slider_fill_9` (64x8, 9-slice margins 4,0,4,0), `ui/slider_grabber`, `ui/slider_grabber_hover` (12x14) | HSlider style: `slider` = track, `grabber_area`/`grabber_area_highlight` = fill, `grabber` / `grabber_highlight` icons. Apply to the settings/pause sliders (`settings_menu.gd _add_slider`) and any radio sliders. Add a helper in cabin_kit.gd. Keep slider sizes/positions unchanged. |
| `ui/speech_tail.png` (10x8) | Tail under the dialogue box pointing at the speaker (dialog box is built with `ui/dialog_box_9.png`; see `cabin_dialog.gd` and home_cabin.gd ~3356). Place at the box bottom edge toward the speaker (Nib/hero), overlapping the border by 1 native px. |
| `props/trunk_open_hover.png`, `props/journal_new_hover.png`, `props/desk_drawer_ajar_hover.png` (each canvas +2px, place at origin-(1,1)) | Hover swaps: room code already swaps the idle texture to trunk_open / journal_new / desk_drawer_ajar (`room_loft.gd` ~79, `room_study.gd` ~59/70) but leaves the old hover. Set the matching hover texture whenever that state's idle texture is set (and restore the normal hover when it reverts). |
| `item_seen_overlay.png` (16x16) | Grey frame over the 16x16 recess for items the player has already seen (`seen`/`note_seen` in home_cabin.gd; trophy shelf mounts / sack slots). Find where seen vs unseen recesses are drawn and lay it on top for seen-but-not-owned (or whatever the existing seen state means). Report your interpretation. |

## Shots
Add or extend `--shots` entries in `scripts/dev/shot_harness.gd` for the affected cabin states (use the next free numbers in the 60s/70s; e.g. `67_run_door_open_f2`, `68_side_door_open`, `69_drawer_rattle`, `70_drawer_open`, `71_dummy_tilt`, `72_radio_knob_hover`, `73_journal_page_flip`, `74_deeper_hole_glow`, `75_homecoming_fly_spark`, `76_new_burst`, `77_drop_sack`, `78_settings_sliders`, `79_dialog_speech_tail`, `80_trunk_open_hover`...). Follow the existing pattern (`_shot_fns[...]` / the cabin hero list). Keep the shot-list self-check passing (`res://tools/qa/check_shot_cli.gd` prints SHOT_COUNT N and SHOT_CLI_OK; it will grow). Do NOT run windowed shots yourself; the parent will.

## Verify before finishing (headless)
`--headless --path . --import`, `--headless --path . --quit` (no SCRIPT ERROR / Parse Error), `py -3 tools/qa/check_ui_pngs.py`, `--script res://scripts/dev/text_audit_selftest.gd` (SELFTEST_OK), `--script res://scripts/dev/layout_check_selftest.gd`, `--script res://tools/qa/check_shot_cli.gd`. Revert any `.import`/`project.godot` churn the import causes before committing (`git checkout -- '*.import' project.godot` only for files you didn't intend to change). Then write REPORT.md and commit it.

## SIZES.md excerpt (authoritative specs; read the full file at assets/dungeon/home/SIZES.md for anything else)
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


[... rows excerpted from later sections ...]
| loot_sack_dropped.png | 32x32 | 128x128 | the sack left on the floor: same canvas, origin and flip as drop_sack f3, without the hero. |
| doors/run_door_closed.png | 1 | 44x66 | 176x264 | front (run) door leaf, pixel-identical to the baked one origin (250,130) [1000,520] |
| doors/run_door_hover.png | 1 | 52x75 | 208x300 | gold rim around the run-door frame; place at opening-(4,8) origin (246,122) [984,488] |
| doors/run_door_open_f*.png | 3 | 44x66 | 176x264 | opens toward the hall-side hinge; f2 shows night + Grumblegut origin (250,130) [1000,520] |
| doors/side_door_closed.png | 1 | 32x63 | 128x252 | side door 32x63 (same canvas in rooms main/hall/study) |
| doors/side_door_hover.png | 1 | 40x72 | 160x288 | gold rim, place at door origin-(4,8) |
| doors/side_door_locked.png | 1 | 32x63 | 128x252 | side door 32x63 (same canvas in rooms main/hall/study) |
| doors/side_door_open.png | 1 | 32x63 | 128x252 | side door 32x63 (same canvas in rooms main/hall/study) |
| doors/side_door_unlock_f*.png | 4 | 32x63 | 128x252 | key-ring unlock: f0 jiggle, f1 shackle pops (flash), f2 chain slack/lock drops, f3 free + rim glow |
| fx/coin_f*.png | 4 | 8x8 | 32x32 | spinning coin, 4f @ 80ms |
| fx/dust_puff_f*.png | 3 | 24x12 | 96x48 | floor dust on thuds, 3f @ 80ms |
| fx/fly_spark_f*.png | 3 | 12x12 | 48x48 | rides on the flying item, 3f @ 80ms loop |
| fx/fly_trail.png | 1 | 6x6 | 24x24 | CPUParticles2D texture for the flight trail |
| fx/new_burst_f*.png | 6 | 48x48 | 192x192 | NEW item pop, centre (24,24); 6f @ 60ms; ADD blend ok |
| fx/new_tag.png | 1 | 14x8 | 56x32 | red corner ribbon on NEW mounts: mount origin + (22,-2) |
| fx/shelf_new_glow_f*.png | 4 | 40x48 | 160x192 | NEW mount halo, place at mount origin-(4,4); 4f @ 160ms loop until clicked |
| hero/gear/cap/hero_drop_sack_f*.png | 4 | 32x32 | 128x128 | cap overlay for hero_drop_sack: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/goggles/hero_drop_sack_f*.png | 4 | 32x32 | 128x128 | goggles overlay for hero_drop_sack: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/helm/hero_drop_sack_f*.png | 4 | 32x32 | 128x128 | helm overlay for hero_drop_sack: same canvas/origin/flip as the base frame, draw ABOVE it |
| hero/gear/rope/hero_drop_sack_f*.png | 4 | 32x32 | 128x128 | rope overlay for hero_drop_sack: same canvas/origin/flip as the base frame, draw ABOVE it |
| overlays/deeper_hole_glow_f*.png | 2 | 96x40 | 384x160 | idle pulse 2f @ 500ms origin (250,214) [1000,856] |
| overlays/deeper_hole_hover.png | 1 | 96x40 | 384x160 | hover origin (250,214) [1000,856] |
| overlays/deeper_hole_idle.png | 1 | 96x40 | 384x160 | the hole deeper origin (250,214) [1000,856] |
| overlays/journal_spread.png | 1 | 380x240 | 1520x960 | journal open spread (centre on screen: origin (20, 10)) origin (20,10) [80,40] |
| overlays/journal_tab_bestiary.png | 1 | 18x30 | 72x120 | bookmark tab |
| overlays/journal_tab_bestiary_hover.png | 1 | 18x30 | 72x120 | hover |
| overlays/journal_tab_items.png | 1 | 18x30 | 72x120 | bookmark tab |
| overlays/journal_tab_items_hover.png | 1 | 18x30 | 72x120 | hover |
| overlays/journal_tab_will.png | 1 | 18x30 | 72x120 | bookmark tab |
| overlays/journal_tab_will_hover.png | 1 | 18x30 | 72x120 | hover |
| overlays/page_flip_f*.png | 3 | 180x224 | 720x896 | page turn 3f @ 70ms (right->left; flip_h for left->right) |
| overlays/radio_knob_f*.png | 9 | 24x24 | 96x96 | knob at 0.0% (centre local 12,12) |
| overlays/radio_knob_hover_f*.png | 9 | 24x24 | 96x96 | hover version |
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
| props/gear_peg_empty.png | 1 | 18x18 | 72x72 | placeholder (empty peg = hide the piece; the peg is baked in the rack) |
| props/journal_new.png | 1 | 44x24 | 176x96 | journal with a red NEW ribbon (a monster you met has no read entry yet) origin (104,130) [416,520] |
| props/journal_new_hover.png | 1 | 46x26 | 184x104 | hover (canvas +2px, place at origin-(1,1)) origin (103,129) [412,516] |
| props/trunk_open.png | 1 | 42x28 | 168x112 | trunk with the lid up (shown while the letters card is open) origin (96,184) [384,736] |
| props/trunk_open_hover.png | 1 | 44x30 | 176x120 | hover (canvas +2px, place at origin-(1,1)) origin (95,183) [380,732] |
| rooms/room_main_fire_glow.png | 1 | 185x101 | 740x404 | light overlay: NORMAL blend, alpha 1.0, above bg / below sprites origin (0,136) [0,544] |
| ui/dialog_box_9.png | 1 | 48x48 | 192x192 | NinePatchRect / StyleBoxTexture, patch margins 12,12,12,12 (native) = 48 shipped |
| ui/dialog_next_f*.png | 2 | 8x8 | 32x32 | next-arrow bob 2f @ 300ms |
| ui/slider_fill_9.png | 1 | 64x8 | 256x32 | grabber_area style, margins 4,0,4,0 |
| ui/slider_grabber.png | 1 | 12x14 | 48x56 | HSlider grabber |
| ui/slider_grabber_hover.png | 1 | 12x14 | 48x56 | grabber_highlight |
| ui/slider_track_9.png | 1 | 64x8 | 256x32 | HSlider slider style, margins 4,0,4,0 |
| ui/speech_tail.png | 1 | 10x8 | 40x32 | tail under the dialogue box pointing at the speaker |
