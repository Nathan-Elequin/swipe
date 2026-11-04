---
id: REQ-20261104-cabin-under-road
status: open
priority: high
branch: cursor/cabin-under-road-ba88
tip_sha: cd67cda2
created: 2026-11-04T18:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New
---

# Cabin under road (CA-A)

Brand New approach → ambush → Yes/Skip overlay must show **no cabin chrome and no cabin music**. Cabin exterior + cabin theme return only on post-tutorial arrive splash (`intro_p5`) then free walk-in (`cabin_exterior`).

## What to verify

- During approach (`intro_p4`), ambush (`intro_ambush`), and Yes/Skip overlay: solid black around the framed art — **no** cabin interior/exterior/BG showing through; Press space / overlay title readable
- No cabin/station music bed during those beats (intro bed OK on p1–p3; combat bed OK from ambush into tutorial)
- After Yes (complete tutorial) or Skip: pool-1 reveal → `intro_p5` arrive → free cabin; cabin music starts at arrive; live BG is `cabin_exterior.png` on walk-in
- Replay intro from journal still shows full cabin under p1–p5 (unchanged)

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | road | Brand New → through p3 → approach | intro_p4 on solid black; no cabin rooms visible at edges | 01-approach-no-cabin.png |
| 02 | road | ambush beat | intro_ambush on solid black; caption readable | 02-ambush-no-cabin.png |
| 03 | road | Yes/Skip overlay | overlay title readable; no cabin chrome behind | 03-overlay-readable.png |
| 04 | cabin | Skip → after arrive splash → walk-in | free cabin; exterior used cabin_exterior | 04-arrive-cabin.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Shots 01–03 show no cabin room art outside the cutscene frame.
- Shot 04 shows live cabin after arrive.

## Outbox path

`playtest/repot/outbox/REQ-20261104-cabin-under-road/`
