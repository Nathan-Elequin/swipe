---
id: REQ-20261108-collection-A
status: done
fulfilled_by: cloud-cursor
fulfilled_at: 2026-11-08T09:15:00-06:00
machine: cloud-worker
base_tip: ca47949782fd67f54e0e37591ac7f03a4bb69595
branch_fixes: cursor/collection-a-true-final-clear-e524
runtime_watermark: ca479497*
godot: windowed isolated process (not MCP 6550 / not owner 41644), Godot 4.7.2-stable, viewport 1680x1040
sandbox: %TEMP%/collection-a-sandbox
final_clear: tip-clear eligible → Leave (not mere b5 Leave)
local_tip_smoke: TIP_SMOKE_OK
milestone_selftest: MILESTONE_SELFTEST_OK
---

# Result — true final-clear (clear event ≠ early return)

No all-24 claim. No owner F5. No preference mutation. Seat 6550 untouched. WIP/saves preserved.

## Contract fix

`final_dungeon_cleared` now requires `run.final_clear_eligible`, set only by `CampaignShell.note_tip_dungeon_cleared` from `_commit_dungeon_clear` when the active run is on the last tip biome.

Mere Leave / bank from b5 without that clear commit does **not** recognize. Push-block (`stamp_crosses=false`) and give-up abort also do not mark.

## N07 evidence (pos / neg)

| shot | claim |
|------|-------|
| `N07-early-return-no-final.png` | NEG: b5 Leave without tip-clear → no Final dungeon cleared line; flag stays false. Also push-block + abort proven clean in log. |
| `N07-final-dungeon-victory.png` | POS: tip-clear eligible → Leave sets flag + milestone; Abyss unlocked (not Locked); incomplete collection; no Full collection; approved Made-it-home summary. |

Log lines:
- `N07_NEG early_leave_final=false flag=false push_block_final=false flag=false abort_flag=false`
- `N07_POS … abyss_unlocked=true has_final=true … abyss_locked=false COPY_GAP_summary=true`

**COPY_GAP** `postrun.summary.final_clear` remains (non-final Spin placeholder on milestone only).

## ca479497 retest / mapping

- Base tip `ca479497` (merge of #490).
- Runtime watermark `ca479497*` (dirty tree: pre-existing `.import` churn + this branch WIP; exact tip SHA is ca479497 before branch commits).
- Prior evidence watermark `d1656f47*` superseded for this lane.

## Also exercised

| case | verdict | note |
|------|---------|------|
| 01 tutorial | PASS | reachable `tutorial_done` reload; full in-dungeon rails still unautomated |
| 05 offer-decline | PASS | live `_make_item` → seen; decline clears pending without bank/swipe. Full mill click UI unautomated |
| 23 N08 | PASS | fixture bank path (not physical acquisition) |
| RM / SC | NOTRUN | no preference mutation; scale log-only |

## Remaining limits (genuine)

1. Full interactive mill click offer-decline UI (case 05 is production `note_seen` path, not mouse click).
2. Full in-dungeon tutorial rails.
3. Physical N08 acquisition journey.
4. RM preference path (mutation banned).
5. SC full UI scale suite.
6. COPY_GAP `postrun.summary.final_clear`.
7. No all-24 acceptance claim.

## Tip-smoke

`TIP_SMOKE_OK` on this checkout before merge packaging.
