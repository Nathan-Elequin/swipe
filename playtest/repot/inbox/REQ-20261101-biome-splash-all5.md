---
id: REQ-20261101-biome-splash-all5
status: done
priority: high
branch: cursor/biome-splash-all5-ambient-aeec
base: playtest/latest
tip_sha: 876100c7
created: 2026-11-02T02:00:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → campaign map → enter each tip biome (b1–b5)
---

# Biome-enter splash for all 5 tip biomes + ambient on splash

Cloud ship: same Verdant splash transition for Crystal / Ashen / Cinder / Shadow (placeholder art OK). Narration keys Spin-locked for all five. Missing key would leave narration Label blank (no skip, no filler). Shared `BiomeAmbient` kit reparents onto the splash (over art, behind chrome), then detaches into the delve with no rebuild flash. Shaft still Verdant-only. Cloud cannot F5 — Cherry drains this inbox. Headless stills may land under outbox/shots/; confirm ambient readable in-game.

## What to verify

- Entering each of b1–b5 from the campaign map shows the splash (art 1680×832, Sprout, chrome biome/dungeon/delves, narration bar, leaf + `click anytime`).
- Narration matches Spin keys byte-for-byte (Verdant / Crystal / Ashen / Cinder / Shadow).
- Biome ambient particles are visible **on the splash still** (over the painted/placeholder art, behind chrome/narration/cue), then continue into the wheel/draft without a restart flash.
- Click anytime dismisses; fade ~0.2s then wheel nest ~0.45s; music once at splash appear.
- Endless / leave / push-deeper: no splash.
- No "Tier" / invented words on the splash.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | biome splash | map → Verdant enter; capture mid-hold | Verdant splash + green ambient spores/fireflies over art | 01-verdant-splash.png |
| 02 | biome splash | map → Crystal enter; mid-hold | Crystal splash + cool mist/glints over art | 02-crystal-splash.png |
| 03 | biome splash | map → Ashen enter; mid-hold | Ashen splash + dusty ash ambient over art | 03-ashen-splash.png |
| 04 | biome splash | map → Cinder enter; mid-hold | Cinder splash + rising ember ambient over art | 04-cinder-splash.png |
| 05 | biome splash | map → Shadow enter; mid-hold | Shadow splash + dim violet motes over art | 05-shadow-splash.png |

## Pass criteria

- Shots at 1680×1040.
- Each expect readable in the PNG (ambient visible on the still, not only after nest).
- `RESULT.md` marks each id pass/fail.
- Note in RESULT whether ambient was readable on each still.

## Outbox path

`playtest/repot/outbox/REQ-20261101-biome-splash-all5/`
