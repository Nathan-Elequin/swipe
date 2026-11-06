---
id: REQ-20261106-scale-four-art
status: open
priority: normal
branch: cursor/scale-four-cards-bcdd
created: 2026-11-06T00:00:00-06:00
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Roster / dungeon with pool so Venom Veins, Kiss of Death, Glass Asp, Imp appear (dev deck or seeded pool)
---

# Scale-four art + catalog (venom_veins, kiss_of_death, glass_asp, imp)

Pixel-locked stills + facing idle for Glass Asp / Imp; item stills for Venom Veins / Kiss of Death. Catalog rows + ITEM_PNG/MONSTER_PNG wired. Combat ops intentionally stubbed (`flags.dev`).

## What to verify

- Roster / inspect shows all four cards with locked art (Nearest, no blur).
- Glass Asp fight facing uses 64×64 facing idle (coiled asp, no companion figure).
- Imp fight facing uses 48×48 burrow-green facing idle.
- Item hotbar/inspect shows Venom Veins and Kiss of Death unique art (not poison_flask).
- Spawned Mark-3 flask (once combat lands) must reuse live poison_flask art — not a second flask PNG.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | roster | Open Roster, find Venom Veins + Kiss of Death | Unique item art, readable names | 01-items-roster.png |
| 02 | roster | Open Roster, find Glass Asp + Imp | Unique monster stills; Asp 9/2, Imp 2/2 | 02-monsters-roster.png |
| 03 | fight | Face Glass Asp | Facing idle coiled green asp, no companion | 03-glass-asp-facing.png |
| 04 | fight | Face Imp | Facing idle burrow-green imp | 04-imp-facing.png |

## Pass criteria

- All four PNGs present; every `expect` readable.
- Wrong art, blurry filter, or missing catalog row = fail with the id.

## Outbox path

`playtest/repot/outbox/REQ-20261106-scale-four-art/`
