---
id: REQ-20261114-trophy-two-state-satchel
status: done
priority: high
branch: cursor/trophy-two-state-popup-hotbar-satchel-fc61
created: 2026-11-14T06:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → trophy hall board; then extract to Rope Exit
---

# Trophy two-state slots, parchment tag, hotbar star, open satchel

Nathan's locked design pass: board slots are only unclaimed (silhouette) or claimed (bright plinth + glow); click opens a small parchment tag (not the combat fly tip); combat hotbar shows a tiny gold star instead of New!/sheen; Rope Exit spills haul onto the floor in front of an open satchel.

## What to verify

- Unlocked Verdant board: no colored-in "seen" look — only dark silhouettes vs full-color claimed on plinths. No nameplates on slots.
- Click a claimed item: parchment tag at click, name + ability only; mouse leave / Esc / click elsewhere closes it; brief shine on the plinth.
- Click an unclaimed silhouette: tag opens, no shine.
- Combat hotbar: never-used unique shows a small gold star top-right (no New! text, no looping sheen). Star gone after first use.
- Rope Exit: no bottom wood strip; open satchel by the dead portal; carried items in a floor grid (≤5 per row, ~56px); gold star on new uniques. Header text unchanged.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall / trophy board | Middle Progress, Verdant face with mix of claimed + unclaimed | plinths; silhouettes vs full color; no nameplates; no third "seen" look | 01-board-two-state.png |
| 02 | hall / trophy board | click a claimed item | parchment tag near click with name + one line; plinth shine | 02-board-tag-claimed.png |
| 03 | combat hotbar | ready with an unbanked never-used unique | tiny gold star top-right of that seat; no New! text | 03-hotbar-star.png |
| 04 | rope exit | extract with 3+ carried items, at least one new | open satchel by portal; floor spill grid; no bottom strip; stars on new | 04-rope-satchel-grid.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each expect readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261114-trophy-two-state-satchel/`

## Texture paths loaded (Pixel drop)

- `assets/ui/trophy/plinth_claimed.png`
- `assets/ui/trophy/plinth_empty.png`
- `assets/ui/trophy/parchment_tag.png` (9-slice, 6 px margins)
- `assets/ui/hud/new_star.png` (fallback: `assets/ui/trophy_board/unique_star.png`)
- `assets/ui/rope_exit/satchel_open.png` (fallback: `assets/dungeon/home/overlays/satchel_floor.png`)
- `assets/ui/rope_exit/floor_grid_cell.png` (optional pad under spill icons)
