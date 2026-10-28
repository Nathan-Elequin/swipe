# Repot schema

## Inbox request: `playtest/repot/inbox/REQ-<slug>.md`

```yaml
---
id: REQ-20261028-cabin-flip-167
status: open
priority: high          # high | normal | low
pr: 167                 # optional
tip_sha: 2b92c62e       # tip this was verified against when written
branch: playtest/latest # where shots should be taken from after sync
created: 2026-10-28T15:00:00-05:00
created_by: pixel-cloud
viewport: 1680x1040
entry: cabin main (fireplace) via F5 playtest hub → Continue / Middle Progress
---

# Title

One line what shipped.

## What to verify

Bullet list of behaviors / visuals. Pass/fail only — no redesign.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | main | spawn at fireplace | left door = study path; right = hall path; run door does NOT skip to Outpost | 01-main.png |
| 02 | hall | walk right from main | Doop cabinets plate only — NO stacked case_*.png frames, names, or "? pool locked"; no shelf arrows/gauge | 02-hall-plate.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261028-cabin-flip-167/`
```

Filename convention: `REQ-YYYYMMDD-<short-slug>.md` matching `id`.

## Outbox: `playtest/repot/outbox/<id>/RESULT.md`

```yaml
---
id: REQ-20261028-cabin-flip-167
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-28T16:00:00-05:00
machine: Cherry
tip_sha: <sha of checkout when shot>
godot: F5 playtest
---

# Result

| id | verdict | note |
|----|---------|------|
| 01 | pass | … |
| 02 | fail | ghost case labels still visible upper-left |

## Blockers

None / what stopped a shot.

## Shots

All PNGs under `shots/` using the filenames from the request table.
```

## Cloud agent duty (every ship)

Before opening/updating the PR (or in the same PR), add or update one inbox request covering:

1. What changed (one paragraph).
2. Exact screenshot table (room, setup, expect, filename).
3. Pass criteria.

If the change needs no visual check (pure data, copy keys for Spin only), still write a request with `screenshots required: none` and a one-line “verify by …” note — or skip only when the PR body says `repot: skip` with reason.
