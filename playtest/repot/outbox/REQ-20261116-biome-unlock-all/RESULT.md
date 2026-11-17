---
id: REQ-20261116-biome-unlock-all
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-16T19:20:00-06:00
machine: Cherry
tip_sha: 9f1dd5c8d8b6d9e74638c6f82e92da9f7a42dcea
godot: F5 playtest, Brand New, real path, no quota seed / Grant
viewport: 1680x1040
on_screen_sha: 9f1dd5c8*
---

# Result

Nathan asked for a real player path to each board's fifth light. This session: Brand New → Verdant enter → one fight → Give up → trophy hall → Front Room. No lever pull. No portal splash.

Build `9f1dd5c8*`. Verdant music: `music_verdant_hollow_loop.ogg`. Cabin: `music_cabin.ogg`.

## Dialogue keys observed

- `nib.first.*`, `nib.first.map_point`
- Verdant enter splash (not `nib.portal.*`)
- `nib.board.first_look`, `nib.board.first_empty`
- No `nib.portal.crystal/ashen/cinder/shadow/endless.*`
- No shortcut keys

| id | verdict | note |
|----|---------|------|
| 01 | fail | Verdant board never at quota. No `portal_crystal.png`. |
| 02 | fail | Crystal splash never played. First return did land in trophy hall (homecoming `01-empty-return.png`) with no Roster/Script strip on that hall frame (pause menu later showed Dev Test / Roster / Script — that is Escape chrome, not the hall land). |
| 03 | fail | Crystal map beat not reached. |
| 04 | fail | Crystal bucket reveal not reached. Pool-1 Onward was Brand New skip-tutorial, not a portal reveal. |
| 05 | fail | Ashen splash not reached. |
| 06 | fail | Ashen hall not reached. |
| 07 | fail | Ashen map not reached. |
| 08 | fail | Ashen reveal not reached. |
| 09 | fail | Cinder splash not reached. |
| 10 | fail | Shadow splash not reached. |
| 11 | fail | Endless splash not reached. |
| 12 | fail | Endless hall not reached. |
| 13 | fail | No board at 100%; no `shortcut_{slug}.png`. |

## Blockers

- Real-player path: first Verdant did not win; haul_count 0. Did not seed quota saves.
- No portal shots under this outbox `shots/`. Cross-ref homecoming `01-empty-return.png` and pause-lights `02-front-room-unpaused.png`.
