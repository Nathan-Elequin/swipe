---
id: REQ-20261104-trophy-hall-dialog-z
status: open
priority: high
pr: TBD
tip_sha: e7c5a302
branch: playtest/latest
created: 2026-11-04T18:20:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Continue / Middle Progress → cabin → key-ring hall tour into Trophy Hall
---

# Trophy Hall dialog above dust sheets

Cabin dialog root default `z_index` raised from 7 → 40 so Nib's talk box sits above locked TrophyCase dust sheets (`_sheet_clip.z_index = 9` inside hole z≈3 → effective ~12). Sheet z left alone (must still cover door/gild). Bed/Telescope one-off `z_index = 40` assignments kept. No player-facing copy changes.

## What to verify

- During the key-ring hall tour, when Nib speaks in Trophy Hall with dust sheets drawn, the dialogue plate/text is fully readable.
- Dust sheet columns must not cut through or sit on top of Nib's text.
- Sheets still cover locked door/gild as before (do not lower sheet z).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | trophy hall | Freeze on key-ring hall tour Nib line while dust sheets are visible over locked case | Dialogue fully readable above dust sheets; no sheet columns cutting text | 01-trophy-hall-dialog-over-sheets.png |

## Pass criteria

- Shot at 1680×1040 (or note if viewport differs).
- PASS = dialogue fully readable above dust sheets (no sheet columns cutting text).
- `RESULT.md` marks 01 pass/fail with one line of evidence.
- Stamp fulfilled `tip_sha` to the tip HEAD used for the shot.
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261104-trophy-hall-dialog-z/`
