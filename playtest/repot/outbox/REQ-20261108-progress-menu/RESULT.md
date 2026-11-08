# REQ-20261108 progress menu — acceptance receipt

**Capture / validation head:** filled at push time (see `SHA=` lines in logs below).

## Shot labels

| Prefix | Meaning |
|--------|---------|
| `FIXTURE-*` | Synthetic/example roster only — **not** catalog acceptance |
| `CATALOG-*` | Full catalog + `dungeon_art` Nearest icons — Pixel first-pass candidate (not installed/accepted) |

### CATALOG paths

- `playtest/repot/outbox/REQ-20261108-progress-menu/shots/CATALOG-01-collection-b1.png`
- `playtest/repot/outbox/REQ-20261108-progress-menu/shots/CATALOG-02-next-goal.png`
- `playtest/repot/outbox/REQ-20261108-progress-menu/shots/CATALOG-03-overview.png`
- `playtest/repot/outbox/REQ-20261108-progress-menu/shots/CATALOG-04-death.png`
- `playtest/repot/outbox/REQ-20261108-progress-menu/shots/CATALOG-05-tutorial.png`

## Logs (raw)

- `source-check.log` — `PROGRESS_MENU_OK`
- `selftest.log` / `selftest.runner.log` — `PROGRESS_MENU_CEREMONY_OK`
- `main-routes.log` / `main-routes.receipt.log` — `PROGRESS_MENU_MAIN_ROUTES_OK` (bounded main.tscn)
- `banking-head.log` — head banking totals (not green; ATTR/L1 catalog-vs-suite)
- `banking-base-3a4be900.log` — base comparison (worse assert fail count)

## Flags

- Missing Spin overallCollection / `postrun.collection.overall` — Overview flags; no invented aggregate
- UNCOVERED: full nest/arm delve settle after Start; live Leave hotbar bank; mid-menu disk reload

## Hold

No merge. Pixel first-pass sent to Nathan; source re-review ongoing.
