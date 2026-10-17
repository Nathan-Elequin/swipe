# assets/ui — map + rope exit additions

Same export spec as ASSETS.md: native 1x in `_src_1x/`, shipped integer 4x nearest. Godot import Filter off, Mipmaps off, Lossless. Text-free. Palette = hexes already in shipped UI art (#100e0c outline, wood #c08a58/#8a5a34/#5a3a24/#3a2414, parchment #f0e6d8/#e2d0b0, brass #e8c36a/#b08a3c, wax #d0644a/#9a3428/#5e1c18). Upper-left light, no dither/AA.

## New

| Path (4x) | Native | 9-slice L/T/R/B (4x) | Use |
|---|---|---|---|
| `assets/ui/map/map_close_x_normal.png` | 16x16 | - | MapOverlay CloseX normal |
| `assets/ui/map/map_close_x_hover.png` | 16x16 | - | CloseX hover |
| `assets/ui/map/map_close_x_pressed.png` | 16x16 | - | CloseX pressed (1 px down) |
| `assets/ui/map/route_dot_hover.png` | 2x2 | - | Route trail dot, hover state (between idle and lit) |
| `assets/ui/panel/parchment_panel_9.png` | 24x24 | 24/24/24/24 | Map description panel, sack peek panel. Content inset 36 px. |
| `assets/ui/rope/rope_sign_9.png` | 24x20 | 24/24/24/28 | RopeExit sign (replaces rope_sign_notice.png). Inner text rect = rect inset (28,28,28,32). |

## Reused (byte-identical copies of the swipe-fixes set, included so the zip is self-contained)

`button/btn_plank_{normal,hover,pressed,disabled}`, `button/btn_plank_primary_*`, `button/btn_dev_*`, `map/route_card_{idle,hover,selected}_9`, `map/route_seal_check`, `map/route_dot_{idle,lit}`, `map/map_close_v2`, `map/map_v2_points.json`, `panel/parchment_rule`. Margins as in ASSETS.md. Pins, flags, map hero, ladder, hole and torch are the existing `assets/dungeon/home/overlays/*` and `hero/*` (not included).

`rope/rope_sign_notice.png` is superseded by `rope/rope_sign_9.png`. Leave it in place until no code references it.
