# SCREEN: Grandpa's Map (mode select) — two courses into the mountain

Mockups: `design/visual/mockups/map-routes.png` (Challenge selected, Classic hovered), `map-routes-classic-selected.png` (Classic selected, Challenge hovered).
Layout: `design/visual/layouts/map-routes.layout.json` (every clickable + text rect, font max/min, max lines, z, 9-slice, contrast, keepout check = pass).
Source: `scripts/cabin/map_overlay.gd`. Viewport 1680x1040, 4 px grid, safe area 32.

## What the player sees
- Map sheet `assets/ui/map/map_close_v2.png` at (120,56). 75% #100e0c scrim behind it hides the cabin, its hover tags and the dev strip.
- **Two routes drawn on the map, equal weight**. Each route = trail dots + pin + parchment route tag, all one hit group:
  - **Classic** `gatehouse` -> `main._begin_run()`: cabin -> base trail -> Gatehouse pin. Tag (320,656,224,104) directly above the pin.
  - **Challenge** `long_drop` -> `main._begin_adventure()`: cabin -> up the slope -> peak pin -> down the shaft past the belly flags. Tag (184,220,224,104) with dotted leader to the peak pin.
  - Tag text: line 1 route name (`map.route.<id>`, 40->20 px, 1 line), line 2 mode (`map.route.<id>.mode`, 32->16 px, 1 line). Tags are the same size.
- **ONE way to pick**: click a route (tag, pin or anywhere within 16 px of its trail). It's a radio group (ButtonGroup), so exactly one route is selected. Selecting doesn't start a run. The panel is display-only and nothing else selects a mode.
- States (whole route changes together):
  - idle: `route_card_idle_9` + `route_dot_idle` + pin `_idle`
  - hover: `route_card_hover_9` + `route_dot_hover` (new) + pin `_hover`, plus pointer cursor and `cabin.hover` sfx. Hover previews the route in the Panel and reverts on exit.
  - selected: `route_card_selected_9` + `route_dot_lit` (Tween draw-on 0.4 s) + pin `_selected` + `route_seal_check` at the tag's top-right.
- **Description panel** (992,204,512,508) `assets/ui/panel/parchment_panel_9.png` (new, 9-slice 24/24/24/24). FitLabelBoxes: Name 48->24 (1 line), Mode 32->16 (1), rule, Body `map.route.<id>.desc` 32->20 (6 lines, top-left), Footer `map.deepest` 28->20 (Challenge only, when deepest > 0).
- **Confirm** PrimaryButton plank (992,724,512,108). Label = `map.go.named` with {mode} = selected mode (DRAFT J-03). Until Jam approves it, show `map.go`. Enter = confirm.
- **Close X** (1452,108,64,64) `map_close_x_{normal,hover,pressed}` (new). Same as Back/Esc/scrim click. HoverTag `map.back`.
- Title `map.title` (336,114,1096,56) 40->24, 1 line. Legend `map.legend` (592,914,400,34) 28->20, under the mountain base.
- **Quick Start**: DevButton tag (164,122,148,44) in the paper's top-left corner, label `map.route.shortcut.mode`, calls `main._quick_start()`. Visible only when `OS.is_debug_build()` and DevFlags.quick_start are both true. It is not a route: no pin, no trail, not in the radio group. Remove the shortcut pin/trail/label from the map.
- Hero marker `overlays/map_hero_f*` fixed at the cabin (148,776), z 58, below every tag, panel and label. It never moves over text.

## Rules / keepouts
- Every text rect and clickable sits inside the paper (>=12 px from the edge), stays >=12 px from any trail dot, keeps clear of the fold (1440,836,88,124) and the close X, and sits >=8 px from every other clickable/panel/legend. All of this is verified in layout `keepout_check`.
- z: scrim 50 < sheet 55 < trails/pins/flags 56-57 < hero 58 < tags/panel 60 < labels 65 < buttons 70 < hover tags 80 < dev tag 90.
- No text baked into art. All text is FitLabelBox from player-copy keys (fit order: shrink by 2 px to min -> wrap to max lines -> ellipsis + HoverTag).

## Contrast (WCAG)
Ink #3a2414 on parchment #f0e6d8 11.8:1 / #e2d0b0 9.6:1 / plank face #d9c79c 8.7:1. Mode red #5e1c18 on #f0e6d8 10.3:1. Wood-dark #5a3a24 on #d9c79c 6.1:1. Ink on map paper ~#d6c89a 8.7:1. Cream #fff3d6 on #8a5a32 5.3:1 (if a cream-on-plank variant is used). Exception: the dev tag (#f0e6d8 on slate #6a7282) is 3.9:1. It's dev-only and never ships.
