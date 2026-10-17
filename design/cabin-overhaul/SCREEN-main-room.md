# SCREEN: Main room ("The Front Room"), plus the Map and Radio close-ups

This is the main menu. Room index 0, host x = 0. Mock: `_pixel_extras/review/mocks/01_main_room_first_visit.png`, `02_main_room_nib_interrupt.png`, `06_main_map_close.png`, `07_main_radio_settings.png`, `15_main_keyring_unlock.png`, `19_main_lucky_geode.png`. Hotspot map: `_pixel_extras/review/room_main_hotspots_2x.png`.

Script: `scripts/cabin/room_main.gd` (`extends Control`). It builds itself from `data/cabin-layout.json` → `rooms.main`.

## Node tree
```
RoomMain (Control, 1680x1040, at host x 0)
├── Bg            TextureRect rooms/room_main.png (opaque)
├── FireGlow      TextureRect rooms/room_main_fire_glow.png  (alpha flicker Tween 0.85↔1.0, 0.6 s, loop)
├── Fire          AnimatedSprite2D "burn" = existing fire_f0..f2 (as today, 1000/150 fps)
├── Map           cabin_hotspot  props/map_wall.png
├── Radio         cabin_hotspot  props/radio.png
│   └── Firefly   AnimatedSprite2D props/radio_firefly_f0..f3 @ 180 ms loop (own small hotspot → tooltip radio.gloria)
├── GearRack      TextureRect props/gear_rack.png (not clickable)
│   └── Gear_helm / Gear_cap / Gear_goggles / Gear_rope   cabin_hotspot props/gear_<id>.png (hidden while worn)
├── PortraitSmall cabin_hotspot props/portrait_small.png
├── LuckyGeode    cabin_hotspot props/lucky_geode.png on the mantel (visible only when geode_on_mantel; SYSTEMS §7.1)
├── RunDoor       cabin_hotspot doors/run_door_closed.png  (hover doors/run_door_hover.png at opening-(4,8))
├── SideDoor      cabin_hotspot doors/side_door_locked.png | doors/side_door_closed.png (hover doors/side_door_hover.png at origin-(4,8))
├── SignHall      TextureRect doors/door_sign_hall.png (above SideDoor)
├── Hero          Sprite2D (chair) existing hero_rock frames + gear overlay children (see Gear)
│   └── GearLayers  Sprite2D x3 (belt rope < eyes goggles < head cap/helm), same frame index as the hero
├── Nib           AnimatedSprite2D nib/* + cabin_hotspot hit (hover nib/nib_idle_hover.png)
├── PromptBubble  small dialog_box 9-slice (58x22 native) + Label nib.prompt; only in the tutorial gate state
└── KeyRing       AnimatedSprite2D props/key_ring_f0..f2 (only during the key-ring cutscene)
```

## Placements and hotspots (from layout.json)
| node | file | native rect (x,y,w,h) | 4x rect | hotspot native | hotspot 4x | hover file | z | note |
|---|---|---|---|---|---|---|---|---|
| room_main_fire_glow | `rooms/room_main_fire_glow.png` | (0,136,185,101) | (0,544,740,404) | - | - | - | 1 | light overlay |
| RunDoor | `doors/run_door_closed.png` | (250,130,44,66) | (1000,520,176,264) | (246,122,52,74) | (984,488,208,296) | `doors/run_door_hover.png` | 2 |  |
| SideDoor | `doors/side_door_locked.png` | (370,132,32,63) | (1480,528,128,252) | (366,124,40,71) | (1464,496,160,284) | `doors/side_door_hover.png` | 2 | to Trophy Hall |
| SignHall | `doors/door_sign_hall.png` | (377,110,18,14) | (1508,440,72,56) | - | - | - | 2 |  |
| Map | `props/map_wall.png` | (148,30,68,52) | (592,120,272,208) | (148,30,68,52) | (592,120,272,208) | `props/map_wall_hover.png` | 3 | Grandpa's map: pick mode/route (opens overlays/map_close) |
| Radio | `props/radio.png` | (150,124,44,72) | (600,496,176,288) | (150,124,44,72) | (600,496,176,288) | `props/radio_hover.png` | 3 | the Snatchwick Melodeon = Settings (opens overlays/radio_close) |
| RadioFirefly | `props/radio_firefly_f0.png` | (166,126,12,16) | (664,504,48,64) | - | - | - | 4 |  |
| GearRack | `props/gear_rack.png` | (300,92,64,18) | (1200,368,256,72) | - | - | - | 3 |  |
| Gear_helm | `props/gear_helm.png` | (301,100,18,18) | (1204,400,72,72) | (301,100,18,18) | (1204,400,72,72) | `props/gear_helm_hover.png` | 4 | take/hang helm; slot head |
| Gear_cap | `props/gear_cap.png` | (315,100,18,18) | (1260,400,72,72) | (315,100,18,18) | (1260,400,72,72) | `props/gear_cap_hover.png` | 4 | take/hang cap; slot head |
| Gear_goggles | `props/gear_goggles.png` | (329,100,18,18) | (1316,400,72,72) | (329,100,18,18) | (1316,400,72,72) | `props/gear_goggles_hover.png` | 4 | take/hang goggles; slot eyes |
| Gear_rope | `props/gear_rope.png` | (343,100,18,18) | (1372,400,72,72) | (343,100,18,18) | (1372,400,72,72) | `props/gear_rope_hover.png` | 4 | take/hang rope; slot belt |
| LuckyGeode | `props/lucky_geode.png` | (68,105,16,13) | (272,420,64,52) | (66,102,20,17) | (264,408,80,68) | `props/lucky_geode_hover.png` | 4 | lucky geode on the mantel: hidden until geode_on_mantel; click = flavour line (no mechanic) |
| PortraitSmall | `props/portrait_small.png` | (80,40,30,36) | (320,160,120,144) | (80,40,30,36) | (320,160,120,144) | `props/portrait_small_hover.png` | 3 | small portrait of Grandpa on the chimney breast: Nib quips |
| Nib | `nib/nib_idle_f0.png` | (216,172,24,32) | (864,688,96,128) | (216,172,24,32) | (864,688,96,128) | `nib/nib_idle_hover.png` | 5 | Nib by the door (tutorial prompt / chat) |
| Fire | `fire_f0.png` | (76,164,32,32) | (304,656,128,128) | (72,150,40,46) | (288,600,160,184) | - | 4 | existing fire_f0..2 (clicking the fire = Nib/hero flavour line) |
| Hero | `hero_rock_f0.png` | (10,205,32,32) | (40,820,128,128) | (10,205,32,32) | (40,820,128,128) | - | 5 | hero in the chair (existing sprites); click = coin flip flavour |

- Chair anchor (existing `_rock`): native (10,205) = 4x (40,820). The existing `_sack` spot is (70,205).
- The Hero row has a 32x32 hotspot: click = `nib.chair` (Nib's line). If gear is worn, the same click takes it off again (see Gear).

## Hotspot behaviour
| Hotspot | Hover tag | Click |
|---|---|---|
| RunDoor | `cabin.hot.run_door` | Tutorial gate (SYSTEMS §5). Otherwise: if `last_route == ""`, open the Map; else plays `doors/run_door_open_f0..f2` (0.08 s each, cue `cabin.door_creak` + existing `ui.door_open`), fades to black (existing `_fade`, 0.25 s), then `route_chosen(last_route)`. Shift-click / right-click = open the Map. |
| Map | `cabin.hot.map` | Gate state: Nib says `map.first_only`. Else opens the **Map close-up** (below). Cue `cabin.scroll`. |
| Radio | `cabin.hot.radio` | Opens the **Radio close-up**. Cue `cabin.radio_on`. |
| Firefly (Gloria) | `radio.gloria` | Same as Radio. |
| Gear_* | `cabin.gear.<id>` with second line `cabin.gear.wear`, third `cabin.gear.flavour` | Wear it (Gear below). Cue `cabin.gear_take`. |
| Hero (chair) | `cabin.hot.chair` | If gear worn: hang the last-worn piece back up (`cabin.gear.hang`, cue `cabin.gear_hang`). Else Nib: `nib.chair`. |
| LuckyGeode (after `drawer.take`) | `cabin.hot.geode` | Nib `cabin.geode.line.1/2` (rotating), cue `cabin.geode_chime`, a 2° wobble Tween. Cosmetic only. Arrival: `doors/unlock_sparkle_f0..f3` centred on it, then Nib `drawer.taken.nib`. |
| PortraitSmall | `cabin.hot.portrait_small` | Nib: `nib.portrait`. |
| Fire | `cabin.hot.fire` | Nib: `nib.fire`. Fire sprite plays a 0.3 s brighter flare (FireGlow modulate 1.25). Existing cue `cabin.fire_start`. |
| Nib | `cabin.hot.nib` | Gate state: `nib.interrupt.2` + choices. Else the next of `nib.idle.1..6` (saved `nib_idle_index`). Cue `speech.nib_chuckle` on lines 1, 4 and 6. |
| SideDoor | locked: `cabin.hot.door_locked`; open: `cabin.hot.door_hall` | Locked: `cabin.locked` (Nib bubble), `_bump()` (638), cue `cabin.locked`. Open: swap to `doors/side_door_open.png`, pan to the hall (SYSTEMS §1.2). |

## Nib states (AnimatedSprite2D "nib")
| anim | frames | fps / timing | when |
|---|---|---|---|
| idle | nib/nib_idle_f0 (hold 2.6–4.0 s random), nib_idle_f1 (0.12 s) | Timer-driven | default |
| psst | nib/nib_psst_f0..f1 | 280 ms loop | tutorial gate; plus PromptBubble bob Tween y ±2 native, 0.6 s |
| talk | nib/nib_talk_f0..f2 | 90 ms, random order | while a Nib line types |
| point | nib/nib_point.png | still | while the Map or door is mentioned (`nib.interrupt.*`, `map.first_only`) |
| gasp | nib/nib_gasp.png | 0.5 s | interrupt start (cue `speech.nib_gasp`), milestones |
| walk | nib/nib_walk_f0..f3 | 8 fps + Tween position.x | interrupt: 216 → 232 native in 0.4 s, back again after the dialog |

## Gear (cosmetic only, saved in `gear_worn`)
**Nathan decision 1: the gear is cosmetic only.** It changes how the hero looks in the cabin, homecomings and rope exit art. It gives no stats or perks and run code never reads `gear_worn`.
- Slots: head (helm or cap), eyes (goggles), belt (rope). Clicking a peg piece:
  1. The piece flies on a Tween (0.25 s, QUAD OUT, parabola peak −16 native) from its peg to the hero's head/eyes/belt.
  2. The peg shows empty (the piece is hidden; the rack art already has the peg).
  3. If the slot was taken, the old piece flies back to its peg first.
- The hero layers: `hero/gear/<piece>/<family>_f<n>.png`. Each is a full 32x32 (or 48x40 wide) overlay with the same frame index as the base hero family (`hero_rock`, `hero_walk`, `hero_walk_loot`, `hero_walk_sad`, `hero_idle_blink`, `hero_idle_loot`, `hero_sit`, `hero_drop_sack`, `hero_cheer`, `hero_climb`, `hero_sack_shake`, `hero_sack_dump`).
  - Draw order: rope < goggles < cap/helm.
  - Every frame swap of the hero also swaps the overlay texture (one helper `_set_hero_frame(family, i)` in home_cabin.gd that sets all layers).
- Gear frames shipped (one file per family frame, per piece):
- `hero/gear/helm/hero_rock_f0.png` .. f3 (4 frames): 32x32 [128x128]. helm overlay for hero_rock: same canvas/origin/flip as the base frame, draw ABOVE it
- `hero/gear/cap/hero_rock_f0.png` .. f3 (4 frames): 32x32 [128x128]. cap overlay for hero_rock: same canvas/origin/flip as the base frame, draw ABOVE it
- `hero/gear/goggles/hero_rock_f0.png` .. f3 (4 frames): 32x32 [128x128]. goggles overlay for hero_rock: same canvas/origin/flip as the base frame, draw ABOVE it
- `hero/gear/rope/hero_rock_f0.png` .. f3 (4 frames): 32x32 [128x128]. rope overlay for hero_rock: same canvas/origin/flip as the base frame, draw ABOVE it
  (The same pattern exists for all 12 families under each piece folder; see SIZES.md.)
- In-run, the hero is not drawn (the run view has no hero sprite), so gear only shows in the cabin and homecomings. That is final: no in-run gear.

## Map close-up (route / mode picker)
Overlay root `MapOverlay` (Control, z 6 inside `_overlays`):
```
MapOverlay
├── Veil        TextureRect ui/overlay_vignette.png (full screen, click = close)
├── Sheet       TextureRect overlays/map_close.png at native (30,14)
├── Title       Label map.title, centred x 840 (4x), y (14+12)*4
├── Pin_gatehouse / Pin_long_drop / Pin_shortcut   TextureButton idle/hover/selected
├── HeroMarker  AnimatedSprite2D overlays/map_hero_f0..f1 @ 400 ms, above the selected pin
├── DeepFlags   5 x TextureRect overlays/map_flag.png | overlays/map_flag_unreached.png
├── Legend      Label map.legend in the legend box
├── Desc        Label map.route.<id>.desc (pin hover or selected), at map-local (170,106) width 150 native
├── Mode        Label map.route.<id>.mode under each pin name, small, muted (Jam's subtitles: Classic / Adventure Mode / Quick Start)
├── Go          choice tag (ui/choice_tag_*) map.go     at native (300,224) 80x16
└── Back        choice tag map.back                     at native (210,224) 80x16
```
- `overlays/map_close.png` at native (30,14,360,232) = 4x (120,56,1440,928)
- Pins (map-local tip points): {"gatehouse": [92, 168], "long_drop": [184, 92], "shortcut": [268, 150]}. The pin texture origin = map origin + tip − (6,19). Hit rect = the pin texture plus its label (Label under the tip, 28 px font at 4x).
- Deep flags (map-local tips on the Long Drop path): [[184, 104], [184, 124], [186, 146], [182, 168], [186, 190]]. Flag *k* (belly k+1) uses `overlays/map_flag.png` if `deepest_belly >= k+1`, else `overlays/map_flag_unreached.png`. Flag origin = map origin + tip − (2,13). Hover on any flag = tag `map.deepest` (`{n}` = `deepest_belly`). Bellies beyond 5 show only in that tooltip.
- Legend box (map-local): [16, 188, 120, 32].
- Open: Sheet scale Tween 0.92→1.0 + modulate.a 0→1, 0.18 s, BACK OUT. Cue `cabin.scroll`. Close: reverse, 0.12 s, cue `cabin.scroll`.
- Pin click: selects it (texture `_selected`), HeroMarker hops to it (Tween position, 0.22 s, parabola −10 native), cue `cabin.map_pin`, `last_route` saved. Go: close the map, then play the RunDoor open sequence and `route_chosen(route)`. Double-click a pin = Go.
- Pin ↔ handler: gatehouse → `_begin_run`, long_drop → `_begin_adventure`, shortcut → `_quick_start` (the inversion is noted in SYSTEMS §2.1).

## Radio close-up (Settings)
```
RadioOverlay
├── Veil        ui/overlay_vignette.png
├── Body        overlays/radio_close.png at native (60,30)
├── Title       Label radio.title (above the body, y (30-14)*4)
├── Gloria      AnimatedSprite2D overlays/gloria_f0..f3 @ 180 ms, in the big tube
├── Knob0..4    radio knob controls (Master, Music, Ambience, SFX, UI)
├── KnobLabel0..4  Label pause.master, pause.music, pause.ambience, pause.sound, pause.ui
├── Dial        Control over the station dial; Needle TextureRect overlays/radio_needle.png
├── StationName Label radio.station.<n> under the dial; small caption radio.station
├── StationKnob hotspot at the station knob
└── Close       choice tag radio.close (native (180,216) 80x16, centred under the body)
```
- `overlays/radio_close.png` at native (60,30,300,200) = 4x (240,120,1200,800)
- Knob centres (radio-local): [[48, 150], [96, 150], [144, 150], [192, 150], [240, 150]]. Each knob is a 24x24 TextureRect at centre − (12,12).
  - Frame = `round(volume * 8)` → `overlays/radio_knob_f0..f8.png`; hover uses `overlays/radio_knob_hover_f0..f8.png`.
  - Drag vertically (up = louder) or use the wheel; one step = 1/8.
  - Each step plays cue `cabin.radio_knob` and the existing `ui.slider_tick`, then calls the same setters as the pause sliders: `_audio.set_master` / `set_music` / `set_ambience` / `set_sfx` / `set_ui` (saved to `user://audio.json` as today). Finer values: hold Shift to step 1/32 (frame still rounds to /8).
- Station dial (radio-local rect): [66, 70, 168, 26]. Needle x = dial.x + 6 + station * (dial.w − 12) / 3. Station knob centre: [262, 84].
  - Clicking the dial or the knob = next station (wrapping).
  - Needle Tween 0.3 s CUBIC OUT, cue `cabin.radio_tune` + `amb.radio_static` for 0.4 s, then `sfx.music_to(bed)` (SYSTEMS §10). Saved to `radio_station`.
- Tube rect (radio-local): [138, 14, 24, 34]. Hover Gloria = tag `radio.gloria`.
- Open cue `cabin.radio_on`; close cue `cabin.click`.

## Copy keys used on this screen
**Copy:** `cabin.room.main`, `cabin.hot.run_door`, `cabin.hot.map`, `cabin.hot.radio`, `cabin.hot.nib`, `cabin.hot.fire`, `cabin.hot.chair`, `cabin.hot.portrait_small`, `cabin.hot.door_locked`, `cabin.hot.door_hall`, `cabin.gear.helm`, `cabin.gear.cap`, `cabin.gear.goggles`, `cabin.gear.rope`, `cabin.gear.wear`, `cabin.gear.hang`, `cabin.gear.flavour`, `cabin.hot.geode`, `cabin.geode.line.1`, `cabin.geode.line.2`, `drawer.hint`, `drawer.taken.nib`, `map.route.gatehouse.mode`, `map.route.long_drop.mode`, `map.route.shortcut.mode`, `cabin.locked`, `nib.prompt`, `nib.first.1`, `nib.first.2`, `nib.first.3`, `nib.interrupt.1`, `nib.interrupt.2`, `nib.interrupt.yes`, `nib.interrupt.no`, `nib.interrupt.no_reply`, `nib.tutorial_done`, `nib.idle.1`, `nib.idle.2`, `nib.idle.3`, `nib.idle.4`, `nib.idle.5`, `nib.idle.6`, `nib.portrait`, `nib.fire`, `nib.chair`, `map.title`, `map.route.gatehouse`, `map.route.gatehouse.desc`, `map.route.long_drop`, `map.route.long_drop.desc`, `map.route.shortcut`, `map.route.shortcut.desc`, `map.go`, `map.back`, `map.deepest`, `map.legend`, `map.first_only`, `radio.title`, `radio.station`, `radio.station.0`, `radio.station.1`, `radio.station.2`, `radio.station.3`, `radio.gloria`, `radio.close`, `pause.master`, `pause.music`, `pause.ambience`, `pause.sound`, `pause.ui`

**Cues:** `cabin.hover`, `cabin.click`, `cabin.locked`, `cabin.door_creak`, `ui.door_open`, `cabin.scroll`, `cabin.map_pin`, `cabin.radio_on`, `cabin.radio_knob`, `cabin.radio_tune`, `amb.radio_static`, `ui.slider_tick`, `cabin.gear_take`, `cabin.gear_hang`, `cabin.fire_start`, `amb.fire`, `speech.nib`, `speech.nib_chuckle`, `speech.nib_gasp`, `speech.nib_psst`, `cabin.pan`, `cabin.room_sign`, `cabin.geode_chime`, `cabin.drawer_unlatch`

## Code hooks
- `_sync_overlay` (10817): `title` → `home_cabin.show_menu()`.
- `_begin_run` (1666) / `_begin_adventure` (1677) / `_quick_start` (1993) via `Main._start_route`.
- `_start_tutorial` (11157) via `tutorial_wanted`; `_tut_finished` (11217) / `_tut_skip` (11206) set the flags.
- `settings_menu.gd` setters stay the single owner of volume; the radio only calls them.
- `_bump` (638) for locked doors; `_input` (1558) for Escape/arrows; `_mcp_state` (1431) adds `room`/`overlay`.
- First visit: after the intro, if `nib_first_done == false`, the dialog plays `nib.first.1..3` then enters the gate state.
