---
id: REQ-20261116-biome-unlock-all
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-16T17:05:00-06:00
machine: Cherry
tip_sha: ac22d09ea4917f5b3f8c818fa84c069934f1701d
godot: F5 playtest, Brand New, real mouse/Space, no debug_pose / Grant / quota seed
viewport_grab: 1550x960 window (logical layout 1680x1040)
on_screen_sha: ac22d09e*
---

# Result

Nathan asked for real play to each board's fifth light (Verdant → Crystal → Ashen → Cinder → Shadow → Endless). This session: Brand New → skip intro/tutorial → Verdant enter splash → one fight → death → limp home → Verdant trophy hall → Front Room. No lever pull. No portal splash.

Build: `ac22d09e*`. Verdant enter music: `music_verdant_hollow_loop.ogg`. Cabin after return: `music_cabin.ogg`.

## Dialogue keys observed (this session)

- Playtest intro Skip (no copy key logged).
- Verdant enter splash (flavor, not `nib.portal.*`).
- `nib.board.first_look`, `nib.board.first_empty` on first return.
- No `nib.portal.crystal.*` / `ashen.*` / `cinder.*` / `shadow.*` / `endless.*`.
- No shortcut keys.

| id | verdict | note |
|----|---------|------|
| 01 | fail | Verdant board never at quota; lever not pulled. No `portal_crystal.png`. |
| 02 | fail | Crystal splash never played. First return did land in **trophy hall** (see homecoming `01-empty-return.png`) with no Developer Test / Roster / Script strip. |
| 03 | fail | Crystal map beat not reached. |
| 04 | fail | Crystal bucket reveal not reached. Pool-1 reveal on Brand New skip-tutorial used Onward (not a portal reveal). |
| 05 | fail | Ashen splash not reached. |
| 06 | fail | Ashen hall land not reached. |
| 07 | fail | Ashen map / Space not reached. |
| 08 | fail | Ashen reveal not reached. |
| 09 | fail | Cinder splash not reached. |
| 10 | fail | Shadow splash not reached. |
| 11 | fail | Endless splash not reached. |
| 12 | fail | Endless hall not reached. |
| 13 | fail | No board at 100%; no `shortcut_{slug}.png`. |

## Blockers

- Real-player path: first Verdant run died; haul_count 0 so no fifth light. Did not seed quota saves (`debug_seed` / Continue-at-quota). Later biomes not reachable in this session.
- After first return, `SceneTree.paused` stayed true in Front Room.

## Shots

None under this outbox `shots/` — portal/shortcut beats never appeared. Cross-ref homecoming `01-empty-return.png` (Verdant hall after limp home) and `front-room-after-loss.png`.
