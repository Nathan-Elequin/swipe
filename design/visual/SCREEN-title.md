# SCREEN — Title (H3p-B final) · Spinheritance · Godot 4.7

Status: **locked by Nathan** (H3p-B + Sai + Grandpa Bartleby portrait). Reference PNG: `H3p-B-final.png` (1680×1040).
Doop: https://doop.design/c/F9TnhFdZAo (frame "H3p-B · FINAL (Sai + Bartleby) — ship").
The only title word on screen is **Spinheritance**, printed on the map. It is not a floating UI logo. There is no tagline.

## 1. Viewport & import rules
- Viewport **1680×1040**, matching `project.godot` (`stretch/mode=canvas_items`, `aspect=expand`). Every coordinate below is in viewport px, measured from the top-left corner.
- The project already uses **Nearest** (`default_texture_filter=0`). Keep these layers Nearest too. On import, set the preset to *2D Pixel*: Filter off, Mipmaps off, Compress **Lossless**.
- Recommended scene: `scenes/ui/title_screen.tscn` (a Control, full rect). Put the layers below in an `Art` Control, as TextureRects with `stretch_mode = KEEP` and `mouse_filter = IGNORE`.
- Place every layer by its **position** in the table. Each `title_*.png` in `exports/layers/` is pre-scaled and already cropped to its bounds, so leave its scale at 1.

## 2. Layers (z-order, back → front)
Files are in `exports/layers/`. Ship path: `res://assets/ui/title/<file>`.

| z | Node name | File | Position (x,y) | Size | Notes |
|---|---|---|---|---|---|
| 0 | RoomBG | title_room_bg.png | 0,0 | 1680×1040 | Plank wall (to y=590) plus floor stripes. Opaque. |
| 1 | PortraitBartleby | title_portrait_bartleby.png | 59,87 | 170×208 | Grandpa Bartleby on the wall, top-left (`portrait_big` 224×272 at 0.75, drop shadow baked in). Optional hover: `assets/dungeon/home/props/portrait_big_hover.png`. |
| 2 | Window | title_window.png | 266,4 | 948×584 | Frame, 4×2 mullions, mountain/cave view, cool glass tint and sill. |
| 3 | DoorJamb | title_door_jamb.png | 1020,0 | 660×792 | Jamb plus a soft warm halo (alpha). |
| 4 | DoorGlow | title_door_glow.png | 1250,40 | 320×550 | Backlight: radial #fffbea→#f7ad52→#5a240a, plus a lit threshold strip. |
| 5 | SproutSai | title_sprout_sai_silhouette.png | 1266,262 | 286×326 | Black silhouette of the real `sprout_idle_f0` holding in-game `sai.png`, warm rim baked in (see §5). |
| 6 | DoorPanel | title_door_panel.png | 1570,2 | 110×625 | Door swung **inward toward camera**, hinged on the right jamb. Lit edge baked in. |
| 7 | SpillDoor | title_spill_door_warm.png | 1120,590 | 560×210 | Warm floor and table spill. Blend Mix (alpha already ~18%). |
| 8 | SpillMoon | title_spill_window_moon.png | 180,590 | 1080×450 | Cool moonlight (#a9c2ff, ~8%). |
| 9 | Table | title_table.png | 0,588 | 1680×452 | Trapezoid tabletop with planks converging (#8b5833 / #5e3a1e lines, #b07a4a lip). |
| 10 | MapTitle | title_map_title_baked.png | 367,630 | 995×399 | **Diegetic logo**, see §4. |
| 11 | LootBag | title_loot_bag_spill.png | 1,760 | 408×280 | Burlap cloth, open Bag of Holding, purple glow, spill items and coins. |
| 12 | LootTray | title_loot_tray_grouped.png | 1297,626 | 383×414 | Leather tray, 3 themed rows (arms / treasure / oddities). |
| 13 | Nib | title_nib_lantern.png | 186,286 | 548×548 | Nib (`nib_lantern_f0` ×2.5) plus lantern glow. Sits **after the Window**, so he stands in front of it, inside the room. |
| 14 | FxVignette | title_fx_vignette_lamp.png | 0,0 | 1680×1040 | Warm lamp pool on the map plus an edge vignette. `mouse_filter = IGNORE`. |
| 15 | PressStart | (Label) | centered, y=1008 | — | See §6. `title_press_start.png` (748,1014, 178×10) is a reference only. |

`exports/layers/manifest.json` holds the same data in machine-readable form. I checked the stack: compositing layers 0–15 in this order reproduces `H3p-B-final.png` exactly (0 pixels differ by more than 12/255).

### Animate-ready split (optional)
For idle motion, build from native sprites instead of the baked layers. `exports/sprite_placements.json` gives the position, size and rotation of every native sprite.
- **Nib:** swap `nib_lantern_f0/f1` from `assets/dungeon/title/` at 2.5×, top-left (200,370). Flicker the lantern glow alpha 0.36–0.46.
- **Door glow:** pulse the modulate 0.95–1.05.
- **Bag:** loop the purple glow alpha.
- **Coins:** an occasional glint.

## 3. 9-slice
Nothing in the shipped title needs 9-slice. The one optional case is the leather tray (`title_loot_tray.png`, backing only), if you rebuild the tray at another size: use a NinePatchRect with margins 24 / 24 / 24 / 24 and keep the #c9a15a border. Every other piece is a fixed-size still.

## 4. Diegetic map logo
- Base art: `exports/sprites/title_map_wide.png` (452×208). This is `assets/dungeon/home/props/map_wall.png` (272×208) widened by **duplicating plain-parchment columns**: 90 columns at x=25 and 90 at x=250. That keeps the mountain/route drawing and pins undistorted, so no artwork is stretched.
- Logo: `assets/dungeon/title/logo.png` (720×160) at **1.2× = 864×192**. It's centered horizontally and sits at 24% of map height (map at 2.15× = 972×447).
- Printed look: the logo is drawn twice, once with **Multiply** blend and once at 60% opacity Normal on top, so the parchment tone shows through.
- Plane: the map wrapper is centered at (850,815) with `perspective 1500px · rotateX 30° · rotateZ 3°`. Godot has no CSS perspective for Controls, so **ship the baked `title_map_title_baked.png`**. If it ever has to be live, use a `Polygon2D` with the map texture and UVs on 4 corners, or a SubViewport → quad. If you go live, trace the 4 corners off `title_map_title_baked.png` (its bounds are 367,630 → 1362,1029, including the drop shadow).

## 5. Sprout + Sai silhouette (v2 — sil fix)
- Source is **real game art only**: `assets/dungeon/anim/player/sprout_idle_f0.png` (64×64) + `assets/dungeon/items/sai.png`. No teaser art, no invented ears or hand-drawn Sai.
- Native art: `exports/sprites/title_sprout_sai_sil.png` (58×64, pure black, 1-bit alpha). Drawn at **5× Nearest**, feet on the door threshold (abs y≈588).
- How it was built (`v2/build.py`):
  1. Alpha of `sprout_idle_f0` thresholded at 40 → #000. The ear stays as it is in the sprite (inside the hood outline, so the silhouette shows the hood point only — that is the real Sprout shape).
  2. `sai.png` (56×64 = 14×16 icon at 4×) downscaled 2× nearest to 28×32 → ~half Sprout's 64px height, alpha → #000, placed at native (42,25) in front of the body; a 13×4 px black grip bridges the hand to the handle.
  3. 5× Nearest upscale, then a 3px warm rim rgba(255,214,150,0.59) and a 2px rim where the Sai overlaps the body so the prongs read.
- To recreate live: TextureRect with `title_sprout_sai_sil.png`, scale 5, filter Nearest, outline shader #ffd696 @ 0.55.
- The tray's weapon row uses `spiked_flail` instead of `sai`, so the Sai appears only in Sprout's hand.

## 6. PRESS START
- Use a Label, not art. Text `PRESS START`, Silkscreen (or the project's pixel font), **16px**, letter-spacing ~6px, color **#e9cf98 @ 65% alpha**.
- Center horizontally. Top at **y=1008**, on the near table edge below the map.
- No outline or panel; keep it quiet. Optional slow alpha pulse 0.45↔0.65 over 1.6s.
- Hit area: the whole screen (any key, click or tap continues).
- The copy comes from `player_copy.gd` if a key exists. Don't add new player-facing words.

## 7. Theme notes
- `themes/swipe_theme.tres`: Label font color #f0e6d8, outline #100e0c. The PressStart Label overrides the color to #e9cf98 at 0.65 alpha, with no outline.
- Palette anchors:
  - Wall #4b2d18 / #331d0e, floor #2b170b / #1d0f06.
  - Jamb #3a2313, door #2a190e / #352013, window frame #22130a.
  - Door glow #fffbea → #ffe6a8 → #f7ad52 → #b85a1d → #5a240a.
  - Moon tint #a9c2ff, lamp #ffc878.
  - Burlap #ad8a58 / #9a7746 / #c2a06c (stroke #6e5230). Tray #4a2716, brass #c9a15a.
- No monsters on this screen. (The two red eye pixels in the window art's cave come from the existing `window_view` art.)

## 8. Asset naming (ship)
Put everything in `res://assets/ui/title/`. Layers use their `title_*.png` names as-is. Native sources go to `res://assets/ui/title/src/`: `title_sprout_sai_sil*.png`, `title_map_wide.png`, plus copies or links of `logo.png`, `portrait_big.png`, `nib_lantern_f0.png` and `window_view` art. See `ASSET-LIST.md`.
