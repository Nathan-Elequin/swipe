---
id: REQ-20261108-progress-menu
status: open
priority: high
branch: cursor/progress-menu-return-9880
base: playtest/latest
created: 2026-11-08
created_by: cursor-agent
viewport: 1680x1040
entry: post-run progress menu (every return)
supersedes: REQ-20261107-cabinet-homecoming-restore
---

# Post-run progress menu — local drain checklist

**Supersedes** `REQ-20261107-cabinet-homecoming-restore` for between-run presentation acceptance. Cabin remains; automatic S7 cabinet homecoming is **not** required for return UX.

## Spec

`design/visual/SCREEN-progress-menu.md`

## Source / engine (cloud OK when Godot present)

```bash
python3 tools/qa/check_progress_menu.py   # expect PROGRESS_MENU_OK
GODOT=… ./tools/qa/run_progress_menu.sh   # isolated XDG; expect PROGRESS_MENU_CEREMONY_OK shape
./tools/qa/run_banking_contract.sh
./tools/qa/run_tip_smoke.sh
```

## Local screenshot / input matrix (isolated Godot profile — not Nathan live)

| id | setup | expect | evidence |
|----|-------|--------|----------|
| P1 | Win Leave with ≥2 new uniques | Overview → played area stagger → Next Goal; counts update | 1680×1040 shot |
| P2 | Win duplicates-only | `postrun.summary.success_none`; no arrival stagger | shot |
| P3 | Death / loss | death summary; no new credit | shot |
| P4 | Tutorial Yes-complete | tutorial summary; empty credit | shot |
| P5 | Non-b1 haul while b1 under quota | no Verdant five-finds teaching invent; area tab truthful | shot |
| P6 | Cross b1 4→5 | requirement met / next destination; can_start rules honored; quiet `stamp_map_piece` without auto S7 FX | shot |
| P7 | Skip Recap mid-stagger | presentation jumps; pending acked; ledgers unchanged | note |
| P8 | Visit Cabin then leave | cabin optional; no ceremony replay | note |
| P9 | Start New Run | only `can_start` destinations; D2 same-run ≠ fresh start | note |
| P10 | Reload with leftover pending | menu/cabin resume without double-bank | save inspect |
| P11 | Push-block return | menu appears; no unlock/map celebration invent; no map-piece stamp | note |
| P12 | Existing save | historical collected; no arrival replay | note |

## Unavailable / do not claim

- Full headed H11-style cabin cancel under live tree (out of scope for this menu REQ)
- Windows userdata isolation (use separate Cherry test profile)
- Cherry / machine sync / public upload while offline

## Pass criteria for merge (Pixel)

- Design screenshot + Spin copy keys reviewed
- Engine selftest + banking/tip regressions green
- No fake credit; no duplicate banking; cabin optional
