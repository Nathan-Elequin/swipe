---
id: REQ-20261108-collection-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T07:35:00-06:00
machine: Cherry
tip_sha: 59e8ca511259155995eef52b98b21850fbae027e
godot: windowed isolated process (not MCP 6550), Godot 4.7.2-stable, viewport 1680x1040
branch_fixes: cursor/collection-a-runtime-verify-e524
---

# Result

Runtime acceptance evidence for Collection Journey A on tip `59e8ca51` (exact match to `origin/playtest/latest` at drain start). Headless rails are labeled **HEADLESS**. Mouse/keyboard/screenshot proof is labeled **RUNTIME**.

## Capability probe

| Route | Result |
|-------|--------|
| Godot binary | `C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot.exe` → `4.7.2.stable.official.ed1daf0bf` |
| Seat 6550 | Occupied by Nathan's editor PID 41644 — **not used** |
| Headless `collection_journey_selftest.gd` | **COLLECTION_JOURNEY_OK** (28 PASS) |
| `check_progress_menu.py` | **PROGRESS_MENU_OK** (93/93 after QA-check fix) |
| Headed shots | Second Godot `--display-driver windows` + disposable `APPDATA=…\collection-a-sandbox` |
| Isolation | Live Spinheritance SHA-256 unchanged before/after (home_cabin / campaign_save / playtest_meta / bucket_progress / audio) |

## Commands

```
# HEADLESS rail
Godot --headless --path <repo> --script res://scripts/dev/collection_journey_selftest.gd
# → COLLECTION_JOURNEY_OK @ 59e8ca51

# RUNTIME shots (isolated APPDATA; does not steal 6550)
$env:APPDATA = "$env:TEMP\collection-a-sandbox"
Godot --display-driver windows --path <repo> --script res://scripts/dev/collection_a_live_repot.gd
# → LIVE_REPOT_DONE; log: live-stdout.log
```

## Exact SHA

`59e8ca511259155995eef52b98b21850fbae027e` — ancestor of inbox's older `4a169677` tip; includes Collection A merges + buckler fix. Inbox `tip_sha` updated to this SHA.

## Screenshots (1680×1040 RUNTIME)

Driver: `scripts/dev/collection_a_live_repot.gd`. Every PNG below is 1680×1040.

| id | verdict | note |
|----|---------|------|
| 01 | PASS | Seen (The Boot / Fangs) shows Spin placeholder recognized line + hatch border; banked cells read Collected. `01-catalogue-seen-vs-banked.png`. |
| 02 | PASS | Overview summary `New item types added: 1.` Totals truthful. `02-return-receipt-overview.png`. |
| 03 | PASS | Crystal Cavern (Locked) badge; grid is `?` / Locked placeholders only — **no future item names** (MVP fix this drain). `03-area-locked.png`. |
| 04 | PASS | Quiet strip visible: banked 4/5 · held new 1 · threshold cue (Spin placeholders). `04-inrun-quiet-strip.png`. |
| 05 | PASS | Overview keeps gate line `Route open — 4→5/5 … Next: Crystal Cavern` after Skip. `05-milestone-gate.png`. |
| 06 | PASS | Trophy hall (not fireplace); Verdant case focused; `bank_pending=0` (no S7 replay). `06-cabin-optional-focus.png`. |
| 07 | PASS | Re-bank adds nothing; receipt already-committed; seen retained. `07-reload-idempotent.png`. |
| 08 | PASS | Loss: no bank credit; seen retained; death summary. `08-loss-seen-retained.png`. |

## Input / reload (RUNTIME)

| id | verdict | note |
|----|---------|------|
| keyboard | PASS | `ui_accept` advances Next → Collection. `input-keyboard-next.png`. |
| mouse | PASS | Click Next → Collection. `input-mouse-next.png`. |
| focus / Tab | PASS | `ui_focus_next` moves focus between footer controls. |
| Back / Esc | PASS | Esc dismisses progress menu (MVP fix this drain). `input-focus-back.png`. |
| Skip | PASS | Skip leaves durable gate/overview facts. |
| reload / idempotence | PASS | Second bank of same id adds nothing; phantom bank id dropped on `load_all()`; cabin pending does not resurrect phantoms. |
| reduced-motion | NOTRUN | No project reduce-motion setting found. |

## 24 Journey A acceptance cases

Authority: store `docs/collection-journey-a/approved-A-build.md`. Map to HEADLESS selftest ids and/or RUNTIME shots.

| case | verdict | proof |
|------|---------|-------|
| 01 Tutorial handoff | NOTRUN | No tutorial-finish surface exercised this drain |
| 02 Before-run objective / Verdant start | NOTRUN | No nest-start shot this drain (see progress-menu baseline NEST shots @ older tip) |
| 03 Offer/reveal → seen | PASS | HEADLESS `status_seen_after_offer` |
| 04 Acquire one missing | PASS | HEADLESS `status_carried` + RUNTIME 04 quiet / New! path |
| 05 Pass offered item | PASS | HEADLESS `seen_survives_spend` / catalogue seen |
| 06 Duplicate held | PASS | HEADLESS `provisional_dup_collapses` / `held_qty_two` |
| 07 Banked repeat | PASS | HEADLESS `banked_repeat_status` / `banked_repeat_no_provisional` |
| 08 Spend last missing copy | PASS | HEADLESS `after_last_spend_zero_provisional` + seen persists |
| 09 In-run quiet + optional catalogue Back | PASS | RUNTIME 04 + Esc dismiss + keyboard/mouse |
| 10 Carried fifth ≠ banked fifth | PASS | HEADLESS `gate_banked_four` / `gate_not_open_on_carry` / `would_cross_on_bank` |
| 11 Checkpoint Head home / Push | NOTRUN | No checkpoint extract UI exercised |
| 12 Push into new biome entry | NOTRUN | No Crystal entry splash this drain |
| 13 Failed run / seen retained | PASS | HEADLESS `loss_keeps_seen` + RUNTIME 08 |
| 14 Successful multi-item bank | PASS | RUNTIME 01/02/07 + HEADLESS bank helpers |
| 15 Zero-new success fast path | PASS | RUNTIME 01 summary `No new item types added.` |
| 16 Gate 4→5 route unlock | PASS | HEADLESS milestones + RUNTIME 05 |
| 17 Simultaneous milestones | PASS | HEADLESS `milestone_gate_present` + `milestone_cabinet_full_at_roster` |
| 18 Next ordinary Verdant run | NOTRUN | No post-receipt Start→nest settle this drain |
| 19 Catalogue hierarchy + optional cabin | PASS | RUNTIME 01/03/06 |
| 20 Late missing identities ordinary play | NOTRUN | No late-pool scrape this drain |
| 21 Full biome cabinet recognition | NOTRUN | Helper PASS HEADLESS; no 14/14 UI ceremony shot |
| 22 Final-dungeon victory ≠ inheritance | NOTRUN | No final-biome victory surface |
| 23 Full collection / neutral handoff | NOTRUN | No full-collection banking |
| 24 Completed reload freedom | PARTIAL | RUNTIME 07 reload/idempotence PASS; full post-completion freedom NOTRUN |

**Counts:** PASS 15 · PARTIAL 1 · NOTRUN 8 · FAIL 0 (of 24).

## Copy audit

| Key | Status in code | Production? |
|-----|----------------|-------------|
| `postrun.collection.item_seen` | fallback `[Spin copy: Recognized — not banked yet]` | **No** |
| `run.collection.quiet_summary` | fallback Spin placeholder | **No** |
| `run.collection.quiet_summary_threshold` | fallback Spin placeholder | **No** |
| `postrun.collection.item_new` / `item_collected` / `item_missing` / `area_locked` | authored in `player-copy.json` | Yes |
| `postrun.summary.success_new` / `death` / `postrun.cabin` / `postrun.skip` / `cabin.tip.new` | authored | Yes |

Placeholders were **not** treated as final.

## Baseline vs new

| Item | Class |
|------|-------|
| Locked tab showed real Crystal item names (pre-fix) | **Baseline FAIL → fixed this drain** |
| Esc on progress menu was a no-op (pre-fix) | **Baseline FAIL → fixed this drain** |
| `check_progress_menu.py` quiet_stamp string stale vs `CAMPAIGN_SHELL.cabinet_count` | **Baseline FAIL → fixed this drain** |
| `run_collection_journey.sh` CRLF broke Git bash `pipefail` | **Baseline tooling FAIL → CRLF normalized** |
| Spin copy gaps for seen/quiet keys | Baseline known; still placeholders |
| reduced-motion | No setting — NOTRUN (not a regression) |
| Cases 01/02/11/12/18/20–23 | Coverage gaps (NOTRUN), not new code fails |

## MVP fixes landed this drain

1. Locked Collection grids use anonymous `?` / Locked placeholders (no spoiler names/icons).
2. Esc/Back dismisses the progress menu and restores the caller.
3. Quiet strip `z_index` raised so New! badges do not bury the line.
4. Progress-menu QA check accepts `CAMPAIGN_SHELL.cabinet_count` / milestone bank helpers.
5. `run_collection_journey.sh` LF-normalized for Windows Git bash.

## Blockers / remaining limits

- Eight Journey A cases still **NOTRUN** without longer campaign/tutorial/final-biome play (listed above).
- reduced-motion: no project setting to exercise.
- Spin must author the three placeholder keys before copy is production-final.
- Review-ready for the **REQ screenshot matrix + rails + Esc/spoiler MVP**, not for claiming every A01–A24 surface played end-to-end.

## Shots

All PNGs under `shots/` using the REQ filenames (plus input-* extras from the live driver).
