---
id: REQ-20261108-collection-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T08:17:00-06:00
machine: Cherry
tip_sha: 526b71754ed7d864bd843b83357da6560d06260d
godot: windowed isolated process (not MCP 6550), Godot 4.7.2-stable, viewport 1680x1040
branch_fixes: cursor/collection-a-partial-close-e524
pixel_corrections: merged via #485 @ 0adc58dd; #486 @ 526b7175
---

# Result

#486 tip-smoke SUCCESS and merged into `playtest/latest` (`526b7175`). WIP-safe Cherry sync preserved dirty `data/*.json` (no stash/reset/force). This partial-close pass upgrades Climb/Push journeys with **unit ≠ journey** honesty.

## Capability probe

| Route | Result |
|-------|--------|
| Tip | `526b7175` Merge #486 (= `origin/playtest/latest` at sync) |
| Seat 6550 | Untouched — windowed second process only |
| Isolation | `APPDATA=…\collection-a-sandbox` only; no preference mutation |
| Tip-smoke | SUCCESS on #486 before merge; local `tip_smoke_selftest.gd` re-run on this branch |
| PARTIAL-close harness | `scripts/dev/collection_a_notrun_cases.gd` → `NOTRUN_PASS_DONE` |

## Exact tip / ancestry

| Fact | SHA |
|------|-----|
| Current tip base | `526b7175` Merge PR #486 |
| Prior tip | `0adc58dd` Merge PR #485 |
| Pixel-correction | `8b0c320b`, `71bf67d1` |

`59e8ca51` remains an ancestor of this tip (not reversed).

## 24 Journey A acceptance cases

**Honest counts after partial-close: PASS 18 · PARTIAL 6 · NOTRUN 0 · FAIL 0.**

| case | unit | journey | verdict | proof |
|------|------|---------|---------|-------|
| 01 Tutorial handoff | surface | PARTIAL | **PARTIAL** | `_road_finish_to_cabin` kind=tutorial summary OK — full tutorial playthrough still out of sandbox reach (`N01`) |
| 02 Verdant nest start | — | PASS | **PASS** | Start→`_finalize_progress_menu_result`→ready settle (`N02`) |
| 03 Offer/reveal → seen | PASS | — | **PASS** | unit |
| 04 Acquire one missing | PASS | PASS | **PASS** | unit + quiet/New! combat |
| 05 Pass offered item | PASS | PASS | **PASS** | unit helper ≠ live offer-decline; catalogue seen shown |
| 06 Duplicate held | PASS | — | **PASS** | unit |
| 07 Banked repeat | PASS | — | **PASS** | unit |
| 08 Spend last missing | PASS | — | **PASS** | unit |
| 09 Quiet + Esc Back | — | PASS | **PASS** | quiet combat + Esc before/after |
| 10 Carried fifth ≠ banked | PASS | — | **PASS** | unit |
| 11 Checkpoint Head/Push | — | PASS | **PASS** | active run + 5/5 → `can_push=true`; Climb/`_adventure_leave` opens Head home menu (`N03`/`N03b`) |
| 12 Push biome entry | — | PASS | **PASS** | `_rope_deeper` with `can_push` → Crystal splash; pool_now=b2 (`N04`/`N04a`) |
| 13 Loss / seen retained | PASS | PASS | **PASS** | unit + shot 08 |
| 14 Multi-item bank | PASS | PASS | **PASS** | |
| 15 Zero-new success | — | PASS | **PASS** | |
| 16 Gate 4→5 | PASS | PASS | **PASS** | |
| 17 Simultaneous milestones | PASS | — | **PASS** | **unit only** |
| 18 Next ordinary Verdant | — | PASS | **PASS** | post-receipt Start→Verdant ready (`N09`) |
| 19 Catalogue + cabin | — | PASS | **PASS** | |
| 20 Late missing identities | — | PARTIAL | **PARTIAL** | catalogue unseen=`?` / recognized named; fixture state not ordinary scrape (`N05`) |
| 21 Full cabinet ceremony | PASS | PARTIAL | **PARTIAL** | cabinet_full UI shown; not live 14/14 ceremony (`N06`) |
| 22 Final ≠ inheritance | — | PARTIAL | **PARTIAL** | Shadow Abyss win without inheritance text (`N07`) |
| 23 Full collection handoff | — | PARTIAL | **PARTIAL** | Spin `collection_complete` placeholder; authored story OOS (`N08`) |
| 24 Completed reload freedom | PASS | PARTIAL | **PARTIAL** | won=true Start settles + cabin opens; re-bank empty; full freedom suite incomplete (`N10`) |

Former pure NOTRUN cleared to PARTIAL (**01**). Climb (**11**) and Push (**12**) upgraded to journey PASS via `CAMPAIGN_SHELL.begin_run` + live rope paths.

## Spin copy gaps (listed, not invented — not production-final)

1. `postrun.collection.item_seen`
2. `run.collection.quiet_summary`
3. `run.collection.quiet_summary_threshold`
4. `postrun.milestone.heading`
5. `postrun.milestone.gate`
6. `postrun.milestone.cabinet_full`
7. `postrun.milestone.collection_complete`

## Screenshots (1680×1040)

| file | case |
|------|------|
| `N01-tutorial-handoff.png` | 01 PARTIAL |
| `N02-nest-verdant-start.png` | 02 PASS |
| `N03-checkpoint-extract.png` | 11 PASS rope |
| `N03b-head-home-progress.png` | 11 PASS Head home |
| `N04a-push-rope-before.png` | 12 PASS Push rope |
| `N04-biome-entry-splash.png` | 12 PASS Crystal splash |
| `N05-late-pool-scrape.png` | 20 PARTIAL |
| `N06-full-cabinet-ui.png` | 21 PARTIAL |
| `N07-final-dungeon-victory.png` | 22 PARTIAL |
| `N08-inheritance-handoff.png` | 23 PARTIAL |
| `N09-next-ordinary-verdant.png` | 18 PASS |
| `N10-completed-reload-freedom.png` | 24 PARTIAL |

Log: `partial-close-stdout.log`.

## Remaining limits

- Case **01** stays PARTIAL — tutorial handoff surface only; full in-dungeon tutorial playthrough not automated here.
- Cases **20–24** stay PARTIAL — fixture/unit+surface journeys; ordinary late scrape / live 14/14 ceremony / final-clear / authored inheritance / full freedom suite remain out of sandbox reach.
- Case **17** remains unit-only for simultaneous milestones.
- reduced-motion / scaling absent.
- Spin placeholders not final; preference rewrite unapproved / untouched.

## Shots / store

Outbox `shots/` + store `media/collection-a-runtime/2026-11-08-partial-close/`.
