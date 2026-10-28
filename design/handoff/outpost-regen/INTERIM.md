# Outpost regen — hybrid pipeline (Nathan lock 2026-10-28)

## Pipeline
- **Doop frames** are the fidelity north star. Canvas: https://doop.design/c/K5t2l_veMo
- **PixelLab** only for mount trophies, stamps, peg gear woven into those designs.

## Live Doop plates (this PR)
| Plate | Doop frame | Live path | Import |
|---|---|---|---|
| Cabinets wall | `rH8lfOM0GR` | `assets/dungeon/home/rooms/cabinets_wall.png` | Nearest (project default), `mipmaps/generate=false` |
| Map-in-hands mid | `O64xs1KB6E` | `assets/ui/map/held/map_in_hands.png` | Nearest (project default), `mipmaps/generate=false` |

Wire:
- Hall room loads `cabinets_wall.png` as its background plate (`room_hall.gd`).
- Held map loads `map_in_hands.png` instead of `map_close_v2` (`held_map.gd`). Wall hotspot + Space still open the same held map.
- Individual `cabinets/case_*`, trophies, stamps, peg gear: **unchanged** (PixelLab sprites-only pass next).

## Parked
`interim-pixellab/` — PixelLab pack v3 reference only. Do not reinstall as room/case plates.
