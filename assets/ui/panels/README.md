# Panels, talk box, spotlight ring, loot glow (Direction A, palette A)

Original art, made for Swipe (no third-party source). These are drop-in textures for the theme and scenes already built; they don't change any layout. All are drawn at screen size (no scaling needed). Use the nearest filter.

## NinePatchRect / StyleBoxTexture margins (px)

| File | Size | patch_margin_left | top | right | bottom | Use |
|---|---|---|---|---|---|---|
| `assets/ui/panels/ui_panel_oak.png` | 96×96 | 32 | 32 | 32 | 32 | PanelOak (column, pause modal): 8 px edge, 4 px inset line, oak, rivets 10 px in |
| `assets/ui/panels/ui_panel_oak_gold.png` | 96×96 | 32 | 32 | 32 | 32 | victory column (PanelOak with gold border) |
| `assets/ui/panels/ui_panel_oak_plain.png` | 36×36 | 12 | 12 | 12 | 12 | PanelOak without rivets: matches the style guide's 12 px 9-slice; add ui_rivet.png as 4 TextureRects |
| `assets/ui/panels/ui_rivet.png` | 12×12 (not 9-slice) | — | — | — | — | corner rivet for ui_panel_oak_plain, at 18 px from each outer corner |
| `assets/ui/panels/ui_plate_inset_edge.png` | 24×24 | 6 | 6 | 6 | 6 | PlateInset, edge border |
| `assets/ui/panels/ui_plate_inset_weak.png` | 24×24 | 6 | 6 | 6 | 6 | PlateInset, Weak tier |
| `assets/ui/panels/ui_plate_inset_tough.png` | 24×24 | 6 | 6 | 6 | 6 | PlateInset, Tough tier |
| `assets/ui/panels/ui_plate_inset_deadly.png` | 24×24 | 6 | 6 | 6 | 6 | PlateInset, Deadly tier |
| `assets/ui/panels/ui_card_weak.png` | 32×32 | 8 | 8 | 8 | 8 | hand card, Weak |
| `assets/ui/panels/ui_card_tough.png` | 32×32 | 8 | 8 | 8 | 8 | hand card, Tough |
| `assets/ui/panels/ui_card_deadly.png` | 32×32 | 8 | 8 | 8 | 8 | hand card, Deadly |
| `assets/ui/ui_talkbox.png` | 128×64 | 96 | 22 | 12 | 12 | How to Play talk box (tail inside the top-left corner, centred 75 px from the left edge) |

Set axis_stretch to Stretch (or Tile; the centres are flat colour, so both look the same).

Talk box: the top margin (22) includes the 16 px tail, so set the content margin top to 22 + 22 padding = 44 and the others to 6 + 22 = 28. The tail sits at x 59–91, so keep the box at least 128 px wide. The portrait well is centred 75 px from the talk box's left edge, which matches the mockup.

## Plain textures

- `assets/ui/ui_spotlight_ring.png`: 666×666, gold dashed ring, r 328, 6 px, dash 10/8. Centre it on the wheel centre (548,350): position (548−333, 350−333). Pulse with modulate.
- `assets/ui/ui_spotlight_ring_seat.png`: 106×106, the same ring at r 48 for one-seat beats. Centre it on the seat point. Don't scale the big ring down, or the stroke thins out.
- `assets/vfx/vfx_glow_gold.png`: 840×600, gold `#FFD84A` radial from 25 % alpha to 0. Drawn on the 4× grid with a 4×4 ordered dither, so it reads as pixel art with no banding rings. Centre it at (548,390): position (128,90). Blend mode normal (or add for a stronger glow).
