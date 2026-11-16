---
id: REQ-20261116-biome-unlock-all
status: open
priority: high
tip_sha: pending
branch: cursor/biome-unlock-all-0c35
created: 2026-11-16T22:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: cabin trophy hall via F5 playtest hub → Continue (seeded save at each board's quota) — real mouse only, no dev hooks mid-run
---

# Biome unlock-all (portal + shortcut structure)

Every board lever unlock (b1→b2 Crystal, b2→b3 Ashen, b3→b4 Cinder, b4→b5 Shadow, b5→Endless) and board-complete shortcut sequences must use the Crystal Cavern structure. Soft-lock after Ashen splash (read_only map Space → peek_closed while sequence awaited closed) must stay fixed. Per-biome Nib lines from Spin.

## What to verify

- From a save with that board at quota (5 lights READY), pull the lever with the real mouse.
- Sequence: lever pull anim → clunk → rumble → splash (`portal_{slug}.png` + biome music) → land in **trophy hall** → rumble wake line → map fog/reveal → new-item bucket reveal (not Endless) → back to hall with input restored.
- No Developer Test / Play Latest / Roster / Script strip, no tutorial overlay, no stuck black wipe, `_busy` clear.
- Nib lines are the Spin per-biome keys (`nib.portal.{slug}.*`), not the shared Crystal dialogue on later biomes.
- Shortcut path (100% board) still uses `shortcut_{slug}.png` and the same map/hall structure.

## Screenshots required

Seed state via save file only, then real mouse. Log tip SHA, splash texture path, music state, and dialogue keys in RESULT notes.

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | b1 at quota; pull Verdant lever | Crystal splash art + crystal.1/.2 lines; music biome b2 | 01-portal-crystal-splash.png |
| 02 | hall | after Crystal splash dismiss | trophy hall visible; no dev strip; rumble wake | 02-portal-crystal-hall.png |
| 03 | map | Crystal map beat | fog cleared on Crystal; crystal.map line | 03-portal-crystal-map.png |
| 04 | reveal | Crystal bucket reveal | pool 2 cards; crystal.reveal.*; Onward works | 04-portal-crystal-reveal.png |
| 05 | hall | b2 at quota; pull Crystal lever | Ashen splash + ashen.* lines (not crystal dialogue) | 05-portal-ashen-splash.png |
| 06 | hall | after Ashen splash | hall land; no soft-lock; no tutorial/dev overlay | 06-portal-ashen-hall.png |
| 07 | map | Ashen map beat | Ashen revealed; continue/Space returns to hall | 07-portal-ashen-map.png |
| 08 | reveal | Ashen bucket reveal | pool 3; input restored after Onward | 08-portal-ashen-reveal.png |
| 09 | hall | b3 at quota; pull Ashen lever | Cinder splash + cinder.* | 09-portal-cinder-splash.png |
| 10 | hall | b4 at quota; pull Cinder lever | Shadow splash + shadow.* | 10-portal-shadow-splash.png |
| 11 | hall | b5 at quota; pull Shadow lever | Endless splash + endless.1/.2; **no** bucket reveal | 11-portal-endless-splash.png |
| 12 | hall | after Endless sequence | hall; endless unlocked; input free | 12-portal-endless-hall.png |
| 13 | splash | any board 100% shortcut (e.g. b1 complete) | shortcut_{slug}.png + shortcut lines | 13-shortcut-splash.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Soft-lock rows 05–08 must show hall control restored after Space/continue on the map.
- RESULT.md marks each id pass/fail with splash path, music id, and dialogue keys observed.
- Never show Tier / ATK on any frame.

## Outbox path

`playtest/repot/outbox/REQ-20261116-biome-unlock-all/`
