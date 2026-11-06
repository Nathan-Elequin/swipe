---
id: REQ-20261106-monster4-art
status: open
priority: normal
branch: cursor/monster4-tip-catalog-1001
created: 2026-11-06T00:00:00-06:00
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Roster / dungeon with pool so Huntsman, Quicksand Crab, Phantom, Collector appear (dev deck or seeded pool)
---

# Monster4 art + catalog (huntsman, quicksand_crab, phantom, collector)

Pixel-locked stills + facing idle for four NEW monsters. Catalog rows + MONSTER_PNG wired. Combat ops intentionally stubbed (`flags.dev`). Phantom/collector idle = facing plate duplicated f0–f3 (gens deferred).

## What to verify

- Roster / inspect shows all four cards with locked art (Nearest, no blur).
- Huntsman fight facing uses 48×48 facing idle.
- Quicksand Crab / Phantom / Collector fight facing uses 64×64 facing idle.
- Phantom + Collector idle frames are identical (facing plate dupe) until real idle gens land.
- Stats: Huntsman 2/3 T1 pool 4; Crab 10/5 T2 pool 2; Phantom 4/5 T3 pool 4; Collector 12/6 T3 pool 5.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | roster | Open Roster, find Huntsman + Quicksand Crab | Unique stills; Huntsman 2/3, Crab 10/5 | 01-huntsman-crab-roster.png |
| 02 | roster | Open Roster, find Phantom + Collector | Unique stills; Phantom 4/5, Collector 12/6 | 02-phantom-collector-roster.png |
| 03 | fight | Face Huntsman | 48×48 facing idle | 03-huntsman-facing.png |
| 04 | fight | Face Quicksand Crab | 64×64 facing idle | 04-quicksand-crab-facing.png |
| 05 | fight | Face Phantom | 64×64 facing (idle frames identical) | 05-phantom-facing.png |
| 06 | fight | Face Collector | 64×64 facing (idle frames identical) | 06-collector-facing.png |

## Pass criteria

- All four PNGs present; every `expect` readable.
- Wrong art, blurry filter, or missing catalog row = fail with the id.

## Outbox path

`playtest/repot/outbox/REQ-20261106-monster4-art/`
