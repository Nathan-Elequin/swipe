# ASSET-LIST — Hotbar aura kit (Direction A)

Export: PNG, Nearest filter, no mipmaps. Godot import: Filter Nearest, Compress Lossless or none.

| Asset | Size | Notes | Path |
|---|---|---|---|
| aura_ready_ring_9slice.png | 48×48 (9-slice margins 16) | Solid #F2A93B ring | assets/ui/aura/ |
| aura_warn_ring_9slice.png | 48×48 | Dashed #E8553E | assets/ui/aura/ |
| aura_choice_ring_9slice.png | 48×48 | Double thin #7CC8F0 | assets/ui/aura/ |
| hatch_diag_8px.png | 16×16 tile | Diagonal lines #8A8F96 @ ~40% α | assets/ui/aura/ |
| stamp_gargoyle.png | 34×34 | G portrait placeholder until art | assets/ui/stamps/ |
| stamp_basilisk.png | 34×34 | B portrait / icon | assets/ui/stamps/ |
| duration_band_gargoyle.png | 64×8 | Segmented #B9A58A top band | assets/ui/aura/ |
| duration_rim_basilisk.png | 9-slice | Dotted scale rim #9DB86E | assets/ui/aura/ |
| decay_chain.png | 24×12 | Link glyph between cards (optional draw) | assets/ui/aura/ |
| decay_pip.png | 10×10 | TL diamond #8E72F2 | assets/ui/aura/ |

Code API (suggested; CA may rename to match tip style):
- `set_aura_role(READY|WARN|CHOICE|off)` replacing overloaded `set_aura`
- `set_decay_link(on, partner_card?)`
- `set_petrified(on, source: GARGOYLE|BASILISK|…)`
- Keep `set_toss_pick` / migrate to CHOICE
- `set_danger` → Toll-only lethal; Hex@1 uses mint face via `set_num_color` / face fill
