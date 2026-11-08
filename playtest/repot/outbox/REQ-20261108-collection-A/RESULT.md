---
id: REQ-20261108-collection-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T08:30:00-06:00
machine: Cherry
tip_sha: 61b94b86dc3f23ef4ae88df28ad1997c8bce6425
base_tip: 4a103c42fae3ce2a1abcd1036aae70ae30a49f75
local_tip_smoke: TIP_SMOKE_OK
godot: windowed isolated process (not MCP 6550), Godot 4.7.2-stable, viewport 1680x1040
branch_fixes: cursor/collection-a-honesty-drain-e524
---

# Result — honesty drain (post-#487)

Owner/Pixel review of partial-close evidence. This pass fixes inflated journey labels, gate display, and collection_complete eligibility; rebuilds PARTIAL routes through authoritative transitions.

## Capability probe

| Route | Result |
|-------|--------|
| Base tip | `4a103c42` Merge #487 |
| Seat 6550 | Godot PID 41644 untouched |
| Isolation | `APPDATA=…\collection-a-sandbox` only; no preference mutation |
| WIP | dirty `data/*.json` preserved (no stash/reset/force) |
| Milestone selftest | `MILESTONE_SELFTEST_OK` |
| Honesty harness | `collection_a_notrun_cases.gd` → `HONESTY_DRAIN_DONE` |
| Local tip-smoke | run before PR merge |

## Honesty model (no end-to-end inflation)

Levels: **unit** · **fixture** · **integration** · **synthetic_input** (API/call path, not physical mouse).

| case | level | verdict | note |
|------|-------|---------|------|
| 01 Tutorial handoff | integration | **PARTIAL** | handoff kind=tutorial OK; second synthetic call still opens menu (non-replay incomplete) |
| 02 Verdant nest Start | integration | **PASS** | synthetic finalize → ready |
| 03 Offer/reveal→seen | unit | **PASS** | unit-only (prior live_repot / journey helper) — not re-claimed as journey |
| 04 Acquire one missing | integration | **PASS** | prior + late acquire covered in 20 |
| 05 Pass offered item | **unit** | **PASS** | **live mill offer-decline NOT exercised** — honesty fix |
| 06 Duplicate held | unit | **PASS** | unit-only |
| 07 Banked repeat | unit | **PASS** | unit-only |
| 08 Spend last missing | unit | **PASS** | unit-only |
| 09 Quiet + Esc Back | integration | **PASS** | prior synthetic_input Esc |
| 10 Carried fifth ≠ banked | unit | **PASS** | unit-only |
| 11 Checkpoint + haul | integration | **PASS** | Climb leave with carried missing → banked |
| 12 Push + haul | integration | **PASS** | Push to Crystal; haul still carried (not banked on Push) |
| 13 Loss / seen retained | unit+integration | **PASS** | prior |
| 14 Multi-item bank | unit+integration | **PASS** | prior |
| 15 Zero-new success | integration | **PASS** | prior |
| 16 Gate 4→5 | unit+integration | **PASS** | gate now **capped at quota** in milestone facts |
| 17 Simultaneous milestones | **unit** | **PASS** | unit-only — not journey |
| 18 Next ordinary Verdant | integration | **PASS** | |
| 19 Catalogue + cabin | integration | **PASS** | prior |
| 20 Late missing acquire | integration | **PASS** | authoritative bank + retain + named catalogue |
| 21 Last biome-item ceremony | integration | **PASS** | cabinet_full; gate capped; no replay; SHOT_OK |
| 22 Final clear distinct | integration | **PARTIAL** | `endless_unlocked`/`won` via `cabinets_complete`; UI still ordinary Made-it-home — **COPY_GAP** (no approved distinct final-clear summary) |
| 23 Full collection boundary | integration | **PASS** | neg incomplete MUST NOT complete; pos full roster → durable `collection_complete`; no replay |
| 24 Completed freedom | integration | **PASS** | re-bank empty; Start; cabin; no ceremony replay |
| RM reduced-motion | unit | **NOTRUN** | preference mutation forbidden |
| SC scaling | unit | **NOTRUN** | SCALE logs only |

**Counts this drain (honest):** integration PASS majority on 01–24 routes exercised; unit-only cases called out; **NOTRUN** = RM + SC; **PARTIAL** = 01 (replay), 22 (copy gap).

Live catalog roster (non-token live items across b1–b5) sums to **66** on this tip (not 67). Boundary tests use that authoritative total.

## Production fixes

1. **Gate display** — `milestones_from_bank` now stores capped `from`/`to` at unlock quota (5/5). Raw counts kept as `raw_from`/`raw_to`. Catalogue area `{count}/{total}` unchanged.
2. **collection_complete** — emits only when **full roster** is banked (`roster_complete`). Quota `won` / `cabinets_complete` alone does **not** emit it (fixes N08 showing Full collection at incomplete).
3. **Shot reporting** — `SHOT_OK` / `SHOT_FAIL` with byte size; retry on ERR_FILE_CANT_WRITE; success never claimed on err≠0.

## Spin copy gaps (listed, not invented)

1. `postrun.collection.item_seen`
2. `run.collection.quiet_summary`
3. `run.collection.quiet_summary_threshold`
4. `postrun.milestone.heading`
5. `postrun.milestone.gate`
6. `postrun.milestone.cabinet_full`
7. `postrun.milestone.collection_complete`
8. **NEW gap (case 22):** no approved distinct final-clear summary key (ordinary Made-it-home only)

## Screenshots

| file | case |
|------|------|
| `N01-tutorial-handoff.png` | 01 PARTIAL |
| `N02-nest-verdant-start.png` | 02 PASS |
| `N03-checkpoint-extract.png` / `N03b-…` | 11 PASS haul |
| `N04a-…` / `N04-…` | 12 PASS Push+haul |
| `N05-late-pool-scrape.png` | 20 PASS |
| `N06-full-cabinet-ui.png` | 21 PASS |
| `N07-final-dungeon-victory.png` | 22 PARTIAL COPY_GAP |
| `N08a-incomplete-66.png` | 23 neg incomplete |
| `N08-inheritance-handoff.png` | 23 pos complete |
| `N09-next-ordinary-verdant.png` | 18 PASS |
| `N10-completed-reload-freedom.png` | 24 PASS |

Log: `honesty-drain-stdout.log`.

## Remaining precise limits (not an arbitrary stop)

1. **01** — full in-dungeon tutorial playthrough unautomated; synthetic handoff non-replay still soft.
2. **05** — live mill offer-decline click path not driven (unit only).
3. **03/06–08/10/17** — remain unit-only evidence unless a later drain adds integration.
4. **22** — durable final-clear **flag** exists (`cabinets_complete` → won/endless); distinct player recognition blocked on **approved copy** (Jam/Spin), not missing harness route.
5. **RM / SC** — NOTRUN under no-preference-mutation + incomplete scale suite.
6. **Physical mouse/keyboard** — Esc/click paths from prior passes are synthetic_input where noted; this drain’s new routes are integration (API/production transitions), not claimed as physical input.
7. Spin placeholders still block final copy acceptance.

## Store

`docs/collection-journey-a/RUNTIME-VERIFY.md` + `media/collection-a-runtime/2026-11-08-honesty-drain/`.
