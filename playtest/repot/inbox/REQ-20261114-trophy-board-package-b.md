---
id: REQ-20261114-trophy-board-package-b
status: done
priority: high
tip_sha: bbeca0899cd5402aa31356122220119c1dc13263
branch: cursor/trophy-board-package-b-ddb5
created: 2026-11-14T02:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: cabin hall via F5 playtest hub → Continue (hall unlocked) or Middle Progress
---

# Trophy board Package B

New carousel trophy board in the hall (standalone scene/script set). Placeholder art at ASSETS paths. Package A may still be deleting cabinets in parallel — verify the board hosts cleanly.

## What to verify

- Hall shows one board ~80% room wide with shared frame + themed crest/plaque/backdrop per biome.
- ←/→, side rails, arrow clicks, keys 1–5, and five biome dots slide between faces (0.36s).
- Locked faces: silhouettes, padlock, five dark lights, no lever.
- Unseen = silhouette; seen = plain sprite; claimed = lit recess + aura. No Tier/ATK/counter text on the board.
- Five lights count unique claimed items for that biome; lever node present (ready/spent/locked).
- Pyramid rebuilds from pool data (tier 1 bottom, tier 3 top).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | fresh save, face 1 | Verdant board, empty/silhouettes, 0 lights | 01-hall-b1-fresh.png |
| 02 | hall | mid save (5 unique b1 banked), face 1 | 5 lights lit, lever ready | 02-hall-b1-mid.png |
| 03 | hall | same, press → | Crystal face; locked look if portal shut | 03-hall-b2-slide.png |
| 04 | hall | hover a claimed slot | Hover card from SCREEN copy table; no Tier chip | 04-hall-hover.png |
| 05 | hall | full b1 collection | Gold trim / complete face chrome | 05-hall-b1-full.png |

## Pass criteria

- All rows shot at 1680×1040.
- Board readable without guessing which face is showing.
- No "Tier" / "ATK" visible on the board or lore hover.

## Outbox path

`playtest/repot/outbox/REQ-20261114-trophy-board-package-b/`
