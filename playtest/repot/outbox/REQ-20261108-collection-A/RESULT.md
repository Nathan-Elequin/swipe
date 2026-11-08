---
id: REQ-20261108-collection-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T08:05:00-06:00
machine: Cherry
tip_sha: 0adc58ddc3d3cb39ed0d76cad73c9bb97901b070
godot: windowed isolated process (not MCP 6550), Godot 4.7.2-stable, viewport 1680x1040
branch_fixes: cursor/collection-a-notrun-journeys-e524
pixel_corrections: merged via #485 @ 0adc58dd
---

# Result

#485 merged into `playtest/latest` (`0adc58dd`). WIP-safe Cherry sync preserved local dirty files. This pass pushes the former NOTRUN journeys with **unit ≠ journey** honesty.

## Capability probe

| Route | Result |
|-------|--------|
| Tip | `0adc58dd` Merge #485 (= `origin/playtest/latest`) |
| Seat 6550 | Occupied PID 41644 — **not used** |
| Isolation | `APPDATA=…\collection-a-sandbox` only |
| Tip-smoke | SUCCESS on #485 head `71bf67d1` before merge |
| NOTRUN harness | `scripts/dev/collection_a_notrun_cases.gd` → `NOTRUN_PASS_DONE` |

## Exact tip / ancestry

| Fact | SHA |
|------|-----|
| Current tip | `0adc58dd` Merge PR #485 |
| Pixel-correction commits | `8b0c320b`, `71bf67d1` |
| Prior tip | `0c94a2c0` |

`59e8ca51` remains an ancestor of this tip (not reversed).

## 24 Journey A acceptance cases

**Honest counts after NOTRUN push: PASS 16 · PARTIAL 7 · NOTRUN 1 · FAIL 0.**

| case | unit | journey | verdict | proof |
|------|------|---------|---------|-------|
| 01 Tutorial handoff | surface | NOTRUN | **NOTRUN** | `_road_finish_to_cabin` opens tutorial summary — not full player tutorial (`N01`) |
| 02 Verdant nest start | — | PASS | **PASS** | Start→`_finalize_progress_menu_result`→ready settle (`N02`) |
| 03 Offer/reveal → seen | PASS | — | **PASS** | unit |
| 04 Acquire one missing | PASS | PASS | **PASS** | unit + quiet/New! combat |
| 05 Pass offered item | PASS | PASS | **PASS** | unit helper ≠ live offer-decline; catalogue seen shown |
| 06 Duplicate held | PASS | — | **PASS** | unit |
| 07 Banked repeat | PASS | — | **PASS** | unit |
| 08 Spend last missing | PASS | — | **PASS** | unit |
| 09 Quiet + Esc Back | — | PASS | **PASS** | quiet combat + Esc before/after |
| 10 Carried fifth ≠ banked | PASS | — | **PASS** | unit |
| 11 Checkpoint Head/Push | — | PARTIAL | **PARTIAL** | rope `open_exit`+campaign chips; ladder+gate live; climb/push not click-completed (`N03`) |
| 12 Push biome entry | — | PARTIAL | **PARTIAL** | Crystal splash present; not full Push-from-rope sequence (`N04`) |
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
| 24 Completed reload freedom | PASS | PARTIAL | **PARTIAL** | won=true Start settles; re-bank empty; full freedom suite incomplete (`N10`) |

Former NOTRUN remaining as pure NOTRUN: **01 only**.

## Spin copy gaps (unchanged — not production-final)

1. `postrun.collection.item_seen`
2. `run.collection.quiet_summary`
3. `run.collection.quiet_summary_threshold`
4. `postrun.milestone.heading`
5. `postrun.milestone.gate`
6. `postrun.milestone.cabinet_full`
7. `postrun.milestone.collection_complete`

## Screenshots (1680×1040)

Prior Pixel-correction shots retained. New/updated NOTRUN journey shots:

| file | case |
|------|------|
| `N01-tutorial-handoff.png` | 01 |
| `N02-nest-verdant-start.png` | 02 PASS |
| `N03-checkpoint-extract.png` | 11 PARTIAL |
| `N04-biome-entry-splash.png` | 12 PARTIAL |
| `N05-late-pool-scrape.png` | 20 PARTIAL |
| `N06-full-cabinet-ui.png` | 21 PARTIAL |
| `N07-final-dungeon-victory.png` | 22 PARTIAL |
| `N08-inheritance-handoff.png` | 23 PARTIAL |
| `N09-next-ordinary-verdant.png` | 18 PASS |
| `N10-completed-reload-freedom.png` | 24 PARTIAL |

Log: `notrun-journeys-stdout.log`.

## Remaining limits

- Case **01** still NOTRUN without a full tutorial playthrough.
- Cases **11/12/20–24** are PARTIAL — surface/fixture journeys, not complete player sequences.
- Case **17** remains unit-only for simultaneous milestones.
- reduced-motion / scaling absent.
- Spin placeholders not final; preference rewrite unapproved / untouched.

## Shots / store

Outbox `shots/` + store `media/collection-a-runtime/2026-11-08-notrun-journeys/`.
