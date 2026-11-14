---
id: REQ-20261114-trophy-art-wire
status: open
priority: high
branch: cursor/trophy-art-wire-b998
created: 2026-11-14T06:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → trophy hall board; combat for hotbar star; extract to Rope Exit for satchel spill
---

# Trophy art wire — plinths, signs, dais, pulse, parchment, star, satchel

Pixel's approved trophy art batch is wired into the hooks from #512 / #513. Local Cherry must shoot proof (no godot-mcp on this cloud agent).

## What to verify

- Hall board: claimed cells show full-colour items on `plinth_claimed` slabs; unclaimed show silhouettes on dusty `plinth_empty` slabs. No old square recess frames.
- Items rest on the slab top face (transparent bottom padding nudged down). Slabs draw below the cell into the row gap.
- Biome signs: all five placards (`placard_b1`…`b5`) are the new 120 px wood signs, Nearest, centred on whole pixels.
- Click a cell: parchment tag opens (NinePatchRect, 24 px margins).
- Combat hotbar: never-used unique shows `new_star` 28×28 top-right (no New! text).
- Rope Exit: open satchel + floor grid cells at 76 px pitch; spill looks right at 0 / 1 / 5 items.
- Board dais at (152, 812); Nib's feet on the floor in front (about y 904–940) on every hall walk path.
- Pulse ring uses the 4-frame sheet when Nib points at a target.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall / trophy board | Middle Progress, Verdant face with mix of claimed + unclaimed | claimed slabs + full colour; dusty slabs + silhouettes; no square recess | 01-board-mixed-plinths.png |
| 02 | hall / trophy board | flip through all five biomes | each sign reads as the new 120 px placard (Verdant / Crystal / Ashen / Cinder / Shadow) | 02-signs-all-biomes.png |
| 03 | hall / trophy board | click a claimed item | parchment tag open near the cell | 03-parchment-tag.png |
| 04 | combat hotbar | ready with an unbanked never-used unique | 28×28 gold star top-right of that seat | 04-hotbar-star.png |
| 05 | rope exit | extract with 0 carried items | open satchel visible; empty floor (no strip) | 05-satchel-0.png |
| 06 | rope exit | extract with 1 carried item | one floor-grid cell + item; satchel open | 06-satchel-1.png |
| 07 | rope exit | extract with 5 carried items | five cells on one row at 76 px pitch | 07-satchel-5.png |
| 08 | hall | Nib in hall after first return / Middle Progress | Nib feet on floor in front of the dais (y ≈ 904–940), not standing mid-dais | 08-nib-on-floor-dais.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each expect readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261114-trophy-art-wire/`

## Texture paths loaded

- `assets/ui/trophy/plinth_claimed.png` / `plinth_empty.png` / `_s` variants
- `assets/ui/trophy/parchment_tag.png`
- `assets/ui/trophy/pulse_ring.png` / `pulse_ring_sheet.png`
- `assets/ui/trophy/board_dais.png`
- `assets/ui/hud/new_star.png`
- `assets/ui/rope_exit/satchel_open.png` / `floor_grid_cell.png`
- `assets/ui/trophy_board/placard_b1.png` … `placard_b5.png`
