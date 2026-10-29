---
id: REQ-20261029-trophy-slots
status: open
priority: high
pr: 179
tip_sha: 06ae25cd
branch: cursor/trophy-slots-bcaf
created: 2026-10-29T09:15:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Continue or Middle Progress → cabin main → right SideDoor into trophy hall
---

# Trophy Hall per-biome case slot sprites

Installs PixelLab idle + rim-light hover trophies for all five biome cases (`trophy_<biome>.png` / `_hover.png`) and wires `BiomeCabinets.trophy_texture`. Filled cases (`collected > 0`) draw a TextureRect at `24×24 * case_scale` with Nearest; empty cases stay empty glass. Hover swaps to the gold rim-light alt. Does not touch stamps, peg gear, `case_*.png`, or `trophy_mount*`.

Slot pitch: `CASE_GLASS` centers step 60 native (240px at ×4). Doop SHIP-D cab lefts pitch 244px — within 4px; overlays keep `CASE_GLASS`.

## What to verify

- Hall cases with banked items show that biome’s pedestal trophy in the glass (Verdant wreath, Sunken vial, Ashen skull, Cinder jars, Shadow orb).
- Hovering a filled case swaps to the `_hover` rim light (#FFD84A / #F09A34) without silhouette jitter.
- Cases with zero collected items show no trophy (empty glass stays empty).
- Trophy pixels stay crisp Nearest — no bilinear blur; drawn at 24×24×`case_scale` (not the full 96px PNG at 1×).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | Middle Progress (or save with several banked cabinets) | Hall cases show biome trophies in filled slots | 01-hall-filled-trophies.png |
| 02 | hall | Hover a filled case glass | Rim-light hover trophy (gold edge) | 02-hall-trophy-hover.png |
| 03 | hall | Case with 0 collected (locked or empty unlocked) | Empty slots stay empty — no trophy sprite | 03-hall-empty-slots.png |
| 04 | hall | Close crop / full hall of a filled trophy | Nearest crisp — sharp pixels, no blur | 04-hall-trophy-nearest.png |

## Pass criteria

- All four PNGs under `playtest/repot/outbox/REQ-20261029-trophy-slots/shots/` at 1680×1040 (godot-mcp preferred).
- `01` shows at least one biome trophy seated in a filled case.
- `02` shows the hover rim light (not the unused AI hover alts).
- `03` has empty glass with no trophy overlay.
- `04` reads crisp Nearest at display scale.
- Tip SHA in RESULT.md is this PR’s tip at shoot time.

## Outbox path

`playtest/repot/outbox/REQ-20261029-trophy-slots/`
