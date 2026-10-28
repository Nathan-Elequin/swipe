# Outpost regen — hybrid pipeline (Nathan lock 2026-10-28)

## Pipeline
- **Doop frames** are the fidelity north star (nearly shippable alone). Canvas: https://doop.design/c/K5t2l_veMo — frame D cabinets wall + map-in-hands frames.
- **PixelLab** is only for individual sprites / reusable tiles woven into those designs (mount trophies, stamps, peg gear) — not a from-scratch redesign that ignores Doop.

## This PR
- Lands **wire only**: Outpost (`mudroom`) wall hotspot + Space → same held-map open path. Spin Outpost copy keys unchanged (`mudroom.*` / `room.mudroom.name`).
- Does **not** install PixelLab cases / room layers / held parchment into live `assets/` paths.
- PixelLab pack v3 is parked under `interim-pixellab/` for reference only.

## Follow-up (Pixel)
Expect cleaned **Doop ship-strip plates** (1680×1040) for:
1. Cabinets wall
2. Map-in-hands

Install those as the real live art at stable paths (`cabinets/case_*`, mudroom layers, `assets/ui/map/held/…`). Hold claiming F5-ready visuals until those plates land.

PixelLab after that: trophies, stamps, peg gear only.
