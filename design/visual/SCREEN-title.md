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
| 5 | SproutSai | title_sprout_sai_silhouette.png | 1244,115 | 291×460 | Black Sprout with the Sai raised, warm rim baked in (see §5). |
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

## 5. Sprout + Sai silhouette
- Native art: `exports/sprites/title_sprout_sai_sil.png` (128×160, pure black, 1-bit alpha). In the frame it's drawn at **3.2×**, with the feet on the door threshold (local y≈535).
- `title_sprout_sai_sil_rim.png` (130×162) is the same art with a 1px warm outline (rgba 255,214,150,0.55) baked in, for use with no shader.
- The shipped layer has the rim from three offset drop-shadows of ±3px at 0.45–0.6 alpha. To recreate it live, use an outline shader (`modulate=black`, outline #ffd696 @ 0.55, 1 texel).
- How it was built:
  1. Start from the alpha of `02_sprout_teaser` (newest Sprout, 128×128), thresholded at 40, placed at (0,+40). Remove the coin sparkles.
  2. Add both **goblin ears** as pixel wedges: the near ear juts back-left out of the hood, and the far ear pokes up behind the hood (kept clear of the prongs).
  3. Draw a **Sai** on the raised fist, axis x=87:
     - Long centre tine (monouchi), 4px wide, pointed tip, y 7–73.
     - Guard bar, ±9px.
     - Two side prongs (yoku), 3px wide, running up to y=52 with flared tips.
     - Handle (tsuka) 5px wide, y 74–96, then a pommel.
     - Fist block over the handle.
  4. Result: one solid black shape in which the three-prong Sai reads at a glance against the glow. No scythe parts remain.
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
