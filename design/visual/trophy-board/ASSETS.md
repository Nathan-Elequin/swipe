# ASSETS — Trophy Board redesign

Companion to `SCREEN-trophy-board.md`. Rules from `design/visual/_COMMON.md`:
- **Native size** is the PixelLab canvas. **Stored size** is the PNG on disk (native ×4, nearest-neighbour; ×8 where noted). Integer scales only. No text baked into any art (all words come from `PLAYER_COPY`).
- **[PL]** = PixelLab art. **[TW]** = code only (tween, modulate or shader), with no file.
- **Style anchor (paste into every PL prompt):** *"Crypt Classic pixel art, hard 1-px dark outline, no anti-aliasing, no dithering gradients, limited palette, top-left torch light, flat 3/4 front view, transparent background."*
- **Palettes** (from the trophy-hall commission): WOOD #1E120C #2B1A12 #4A2F1F #5C3A22 #7A4E2B #8A5A32 · BRASS #8A6A2E #C4A574 #E8C36A #FFD84A · LINEN #2E2B26 #5A564E #7A766C #9C978C #B8B2A4 · IRON #1E120C #3A3A3E #6E6E6E #C9CED6 · FLAME #A8322A #F09A34 #FFD84A · outline #100e0c.
- **Per-biome accents** (add to WOOD/BRASS for themed pieces):
  - verdant #2F5A2A #4E8A3A #8CC56A #D8F0A0
  - crystal #2A4A60 #7FA9C4 #B4D6EA #DCEEF7 (GLACIAL)
  - ashen #2E2B26 #5A564E #9C978C #C9CED6 + bone #E6DCC2
  - cinder #3A1A10 #A8322A #F09A34 #FFD84A
  - shadow #140E1E #2E2140 #5A3E7A #9C7AD0
- **Slugs:** `verdant` (b1), `crystal` (b2), `ashen` (b3), `cinder` (b4), `shadow` (b5), `endless`. These match `assets/ui/biome_splash/bg_*`.
- **Board UI root:** `res://assets/ui/trophy_board/`, loaded with `KIT.ui_tex("trophy_board/...")`. Room plates and Nib frames stay in `res://assets/dungeon/home/` because `KIT.load_tex` and every existing room plate and Nib frame live there (deviation from "assets/ui/…", see the report). Map pieces go in `res://assets/ui/map/trophy/`.
- Update `assets/dungeon/home/SIZES.md` and add `assets/ui/trophy_board/SIZES.md` with these rows.

---

## A. Room plates (repaints) — priority 1, they unblock the look

| ID | File | Native → stored | Frames | Notes |
|---|---|---|---|---|
| A1 | `assets/dungeon/home/rooms/room_trophy.png` (replaces `room_hall.png` in `cabin-layout.json` hall `plate`) | 420×260 → 1680×1040 | 1 | Same room shell, floor, ceiling beams and left doorway (native x 8–40) as `room_hall.png`. **Remove:** the painted board frame (≈ native 86–374 × 8–198) and the chained right door. Plain plank back wall with soft wall-sconce pools at native (40,60) and (380,60). The area behind the board (native 44–376 × 10–204) can stay simple, since the board covers it. Floor line ≈ native y 197. WOOD + LINEN + FLAME glow. |
| A1g | `assets/dungeon/home/rooms/room_trophy_glow.png` | 420×260 → 1680×1040 | 1 | Additive warm sconce glow layer (like `room_hall_glow.png`). [TW] flicker. |
| A2 | `assets/dungeon/home/rooms/room_main.png` (repaint in place) | 420×260 → 1680×1040 | 1 | **Remove the centre "to the Outpost" door** (≈ px 1000–1176 → native 250–294). Paint wall and shelf continuity: a small coat rack or plank wall. Keep the right chained door and all other hotspot anchors pixel-identical, so `cabin-layout.json` main hotspots don't move. |
| A3 | delete `rooms/cabinets_wall.png`, `cabinets/*`, `doors/*outpost*`, mudroom plate and props | — | — | Package A removes them once nothing references them. |

## B. Board (`assets/ui/trophy_board/`)

| ID | File | Native → stored | Frames | Palette / notes |
|---|---|---|---|---|
| B1 | `board_frame.png` | 332×194 → 1328×776 | 1 | Shared frame for all faces. Dark oak (WOOD) with brass corner caps (BRASS). **Transparent face window** at native (12,22,308,154). Top band 22 px with a centred recess for the plaque. Bottom band 18 px with a dark inset groove for the dots (native 132–252 × 180–198). Side rails 12 px, carved, each with a small socket for the cog at native (6,58). Two stubby feet at the bottom corners. |
| B2 | `rail_cog.png` | 12×12 → 48×48 | 1 | Brass cog. [TW] rotates 90° per slide, so the art must be 4-fold symmetric. |
| B3 | `face_bg_{verdant,crystal,ashen,cinder,shadow}.png` | 308×154 → 1232×616 | 1 ×5 | **Tinted backdrop**, painted as the inside back of a display case lined with that biome's material: moss cloth and roots / pale blue crystal velvet / grey bone-carved stone / ember-lit iron plate / deep violet starry cloth. Low contrast and darker in the middle 280×120, so silhouettes read. Leave the top-left 36×36 plain for the crest and the top 30 px plain for the lights. |
| B4 | `crest_{slug}.png` | 24×24 → 96×96 | 1 ×5 | Brass shield with the biome sigil: leaf / crystal shard / skull / anvil and flame / crescent eye. BRASS + one biome accent. |
| B5 | `plaque_{slug}.png` | 120×24 → 480×96 | 1 ×5 | Header plaque "designed to theme". Brass plate with biome trim: vines / ice-rime edge / bone ends / riveted iron with an ember / shadow tendrils. Keep a **flat light brass centre** at native (14..106, 6..18) for code text (ink #1c120c). |
| B6 | `padlock.png` | 40×48 → 160×192 | 1 | Big iron padlock with a brass keyhole, for locked faces. IRON + BRASS. |
| B6h | `padlock_hover.png` | 40×48 → 160×192 | 1 | +1 brightness ramp on the outline. |
| B7 | `light_off.png`, `light_on.png` | 12×16 → 48×64 | 1 + 1 | Small brass sconce with a glass bulb. Off is dark glass (#2B1A12 glass, #8A6A2E cap); on is gold #FFD84A / #E8C36A with a white hot spot. |
| B7f | `light_flash_f0..f3.png` | 12×16 → 48×64 | 4 @ 16 fps | Off → overbright (white core and 1-px rays clipped to the canvas) → on. f3 = `light_on`. |
| B8 | `lever_locked.png` | 16×32 → 64×128 | 1 | Brass lever up, with an iron catch-chain over the handle. Dull: BRASS darks only. |
| B8r | `lever_ready.png` | 16×32 → 64×128 | 1 | Lever up, no chain, handle knob bright #FFD84A. |
| B8p | `lever_pull_f0..f4.png` | 16×32 → 64×128 | 5 @ 12 fps | Handle arcs from top to bottom: f0 = up, f4 = down. f4 is also `lever_pulled`. |
| B8g | `lever_glow.png` | 32×48 → 128×192 | 1 | Soft pixel halo (3 stepped rings #FFD84A at 3 alphas, no gradient). [TW] pulse 1.2 s. Centred on the lever. |
| B9 | `arrow_{l,r}_{idle,hover,press}.png` | 12×20 → 48×80 | 6 | Brass chevron on a wood tab. Draw both directions separately to keep the top-left light (don't mirror). Can derive from `ui/shelf_arrow_*` (64×48) but re-cut to 12×20. |
| B10 | `dot_{locked,idle,current,hover}.png` | 8×8 → 32×32 | 4 | Brass stud. Locked = iron with no shine. Idle = dull brass. Current = bright brass with a gold ring. Hover = idle +1. |
| B10n | `dot_new_pip_f0..f1.png` | 4×4 → 16×16 | 2 @ 2 fps | Red-gold gem (#A8322A / #FFD84A), blinking. |
| B11 | `slot_recess_dark.png`, `slot_recess_lit.png` | 32×32 → 128×128 | 2 | Shallow inset niche. Dark = unlit (seen and unseen). Lit = brass rim with a warm inner bounce at the bottom edge (claimed). Must sit on any of the 5 backdrops, so keep it neutral (WOOD + BRASS). |
| B11c | `slot_recess_dark_s.png`, `slot_recess_lit_s.png` | 20×20 → 80×80 | 2 | Compact-mode versions. |
| B12 | `aura_claimed_f0..f5.png` | 32×32 → 128×128 | 6 @ 8 fps loop | Gold glint aura **behind** the item: an irregular ring of 1-px sparkles and a soft stepped halo, transparent in the middle 16×16. BRASS. |
| B12c | `aura_claimed_s_f0..f5.png` | 20×20 → 80×80 | 6 @ 8 fps | Compact version. |
| B13 | `twinkle_f0..f3.png` | 8×8 → 32×32 | 4 @ 12 fps | Four-point star glint, placed on a random corner of a claimed sprite every 3–6 s. |
| B14 | `board_trim_gold.png` | 332×194 → 1328×776 | 1 | Gold-leaf overlay for the frame only (transparent face window), used when a face is 100%. [TW] clockwise reveal via shader mask (`trim_sweep.gdshader`, a 0–1 angle uniform) or 4 strips. |
| B15 | `satchel_idle.png` | 48×40 → 192×160 | 1 | **Grandpa's satchel**: worn brown leather (WOOD + #A8322A stitching hint), brass buckle, flap closed, a short strap loop on top. Mouth at native (24,5). |
| B15o | `satchel_open_f0..f3.png` | 48×40 → 192×160 | 4 @ 12 fps | Flap flips back, the bag puffs, and a gold glow appears in the mouth. |
| B15c | `satchel_close_f0..f2.png` | 48×40 → 192×160 | 3 @ 12 fps | Flap drops, bag settles. |
| B16 | `rise_glint_f0..f5.png` | 24×24 → 96×96 | 6 @ 15 fps | Upward sparkle burst behind the rising item. BRASS + white. |
| B17 | `poof_f0..f4.png` | 24×24 → 96×96 | 5 @ 20 fps | Puff of pale dust (LINEN light ramp) with 3 gold sparks. Ends fully transparent. |
| B18 | `dust_fall_f0..f2.png` | 4×4 → 16×16 | 3 @ 8 fps | Falling dust mote / grit for the rumble. LINEN. |
| B19 | — | — | — | **[TW]** silhouette (`modulate (0.04,0.03,0.025,0.92)`), seen/claimed swaps, slide, shake, bezier fly, skip button (existing button style, Open Sans 18, alpha 0.4/0.85), hover card (existing parchment lore panel). |
| reuse | `res://assets/dungeon/home/fx/fly_spark_f0..2.png`, `fx/dust_puff_f0..2.png` | existing | | Fly trail and board-top dust puff. |

## C. Splashes (`assets/ui/trophy_board/splash/`), biome_splash layout

| ID | File | Native → stored | Frames | Notes |
|---|---|---|---|---|
| C1 | `portal_{crystal,ashen,cinder,shadow}.png` | 420×208 → 1680×832 | 1 ×4 | **Painted portal splash.** A torn-open passage at the bottom of the previous biome, with the new biome's light pouring through. Grandpa's lantern-lit stair in the foreground. Crystal: blue ice-light through a cracked root wall. Ashen: a bone arch grinding open in blue-grey fog. Cinder: an iron gate glowing orange. Shadow: a violet rift with stars. Keep the bottom 40 native px darker (the Nib bar overlaps). |
| C1e | `portal_endless.png` | 420×208 → 1680×832 | 1 | The abyss floor cracking open to a bottomless dark, with faint gold motes rising. |
| C2 | `shortcut_{crystal,ashen,cinder,shadow}.png` | 420×208 → 1680×832 | 1 ×4 | **Grandpa's shortcut.** A hidden narrow passage behind a loose board or rock, with a brass rope rail, an old pinned note (no text) and the new biome's light at the far end. Warm and secret, not dramatic. |
| note | | | | PixelLab can't make a 420-wide canvas in one go: generate at 210×104 and export **×8** (still integer, matches the 1680×832 slot), or tile two 210×208 halves. Placeholder for any missing file: the matching `ui/biome_splash/bg_*.png` with a [TW] tint. |

## D. Map (`assets/ui/map/trophy/`), on the 1680×1040 held-map sheet

| ID | File | Native → stored | Frames | Notes |
|---|---|---|---|---|
| D1 | `fog_{crystal,ashen,cinder,shadow}.png` | 48×32 → 192×128 | 1 ×4 | Parchment-coloured drifting fog bank covering the node and its painted name, so the plate shows nothing. Ink-wash style that matches the map plate: LINEN light ramp plus #C4A574. Four variants avoid visible repetition. |
| D1x | `fog_clear_f0..f5.png` | 48×32 → 192×128 | 6 @ 10 fps | Fog thins and breaks apart, ending empty. One shared set. |
| D2 | `node_glow_f0..f3.png` | 40×40 → 160×160 | 4 @ 6 fps loop | Gold ring glow under a startable wax stamp (the stamps are 112×112). |
| D3 | `start_pointer.png` | 12×16 → 48×64 | 1 | Inked hand-drawn arrow, red-brown (#A8322A, outline #100e0c). [TW] bounce 8 px at 1.6 Hz. |
| D4 | `badge_start_here.png` | 40×12 → 160×48 | 1 | Small paper tag with a pin. **Blank centre** for `map.badge.start_here` (EB Garamond SemiBold 22, ink). |
| D5 | `path_dash.png` | 6×2 → 24×8 | 1 | Ink dash tile (#5C3A22 core, #2B1A12 edge) for the `Line2D` shortcut path (`texture_mode TILE`). Drawn with [TW] by tweening the points. |
| D6 | — | — | — | **[TW]** Known state = existing wax stamp `idle` with `modulate (0.62,0.58,0.52)`, no hit. |

## E. Nib (`assets/dungeon/home/nib/`), 24×32 native like every existing Nib frame

| ID | File | Native → stored | Frames | Notes |
|---|---|---|---|---|
| E1 | `nib_react_f0..f3.png` | 24×32 → 96×128 | 4 @ 10 fps, once | Small hop and clap: f0 anticipation squash, f1 up 2 px with hands together, f2 land, f3 = idle. Feet row 30 like the idle frames. |
| E2 | `nib_watch.png` | 24×32 → 96×128 | 1 | Nib turned 3/4 toward the board (looking left), hands behind his back. Alternates with the idle frames in the hall. |
| reuse | `nib_walk_f0..3`, `nib_idle_f0..1`, `nib_talk_f0..2`, `nib_gasp`, `nib_point`, `nib_bust_*` | existing | | Relocation walk, talk, rumble gasp, pointing at the lever. |

**Totals:** 2 plates (+1 glow); 5+5+5 themed board pieces (backdrop, crest, plaque); about 65 board UI/FX frames; 9 splashes; about 23 map frames; 5 Nib frames.

**PixelLab batch order:** A1, A2 → B1, B3, B5, B4 → B7, B8, B11, B12 → B15–B17 → D1–D5 → E1, E2 → C1, C2. Placeholders (package B) use flat `ColorRect` and `StyleBoxFlat` with the same rects, so code never waits on art.

---

## F. Audio for Reel (cues go in `data/sfx-map.json`; files in `res://assets/audio/<file>.ogg`)

Format: same cue schema as `cabin.hole_rumble` (`files`, `bus`, `db`, `pitch`, `cooldown_ms`, `max_voices`, `priority`, optional `loop`). Play with `KIT.cue(sfx, &"id")`. Loops use `sfx.loop_start(&"amb.x", fade)` and `loop_stop`.

| Cue id | Bus | Length | Description | Placeholder (existing cue to alias until Reel delivers) |
|---|---|---|---|---|
| `amb.trophy_room` | Ambience (loop) | 30–60 s seamless | **Room bed.** Quiet hall: slow wood creaks, faint clock tick, distant wind past a window, an occasional soft brass ping. Sits under the cabin music at −14 dB. Starts on hall enter, crossfades out on leave (0.8 s). | `amb.fire` at −20 |
| `board.slide` | SFX | 0.35 s | Heavy wooden panel sliding on a rail, with a cog click at the end. | `cabin.item_whoosh` |
| `board.bump` | UI | 0.15 s | Wood knock at the end of travel. | `cabin.locked` |
| `board.hover_slot` | UI | 0.05 s | Tiny glass tick (cooldown 60 ms). | `ui.hover_menu` |
| `board.satchel_in` | SFX | 0.4 s | Leather bag lifted and set down. | `cabin.item_pop` |
| `board.satchel_rustle` | SFX | 0.3 s | Leather flap and rummage. | `cabin.item_pop` |
| `board.satchel_out` | SFX | 0.3 s | Bag set aside. | — |
| `board.rise_glint` | SFX | 0.5 s | Rising shimmer (pitch ±5%). | `cabin.glint` |
| `board.whoosh` | SFX | 0.5 s | Soft airy flight. | `cabin.item_whoosh` |
| `board.poof` | SFX | 0.3 s | Dusty "poof" with a small sparkle tail. Satisfying, not loud. | `cabin.item_burst` |
| `board.light_chime` | SFX | 0.8 s | Bell chime. **5 variants** rising a scale step each (`light_chime_1..5`), or one file pitched in code by +1 semitone per light. | `cabin.shelf_chime` |
| `board.lever_ready` | Stings | 1.0 s | Warm "ta-da" glow swell when the 5th light lands. | `sting.unlock` |
| `board.lever_clunk` | SFX | 0.5 s | Big brass lever thrown, with a ratchet and clunk. | `cabin.stamp_thunk` |
| `board.rumble` | SFX | 1.6 s | Deep earth rumble with falling grit and a groan of beams. | `cabin.hole_rumble` |
| `sting.portal_open` | Stings | 3–4 s | **Portal stinger.** A deep opening swell and a choir-ish bloom, ending on an open, unresolved chord. Has to work under Nib's lines (no melody peak after 1.5 s). Optionally 4 tinted versions per biome. | `sting.bucket` |
| `board.complete_chime` | Stings | 1.5 s | Gold-leaf shimmer sweep and a resolved chime (100% board). | `sting.unlock` |
| `sting.shortcut` | Stings | 2–3 s | Playful "secret found" motif: a plucky rising figure and a door-creak tail. | `sting.unlock` |
| `board.path_draw` | SFX | 1.2 s | Quill scratching across parchment. | `cabin.map_pin` |
| `board.fog_clear` | SFX | 0.9 s | Breathy wind dissolve. | — |
| `board.badge_pop` | UI | 0.2 s | Paper tag pinned. | `cabin.map_pin` |
| `nib.react` | speech | 0.3 s | Nib's small delighted "hup!" (2–3 variants). | — |
| music | Music | — | **No new bed.** The cabin bed continues. Duck −8 dB (`sfx.duck_music(-8)`, `unduck(0.6)`) during the rumble, portal and shortcut stingers. Reel may optionally add a `cabin_trophy` variant bed (the same theme on music-box timbre) under `music.beds` in `sfx-map.json`. | |
