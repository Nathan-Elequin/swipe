---
id: REQ-20261108-collection-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T07:57:00-06:00
machine: Cherry
tip_sha: 0c94a2c06409369590d8b1f7a79eef8f28be2fa9
godot: windowed isolated process (not MCP 6550), Godot 4.7.2-stable, viewport 1680x1040
branch_fixes: cursor/collection-a-notrun-cases-e524
pixel_correction_commit: 8b0c320b779856ce5ce3d4143a0c1a938faf15d9
tip_smoke: TIP_SMOKE_OK @ 8b0c320b
pixel_corrections: 2026-11-08-pixel-corrections
dirty_watermark: 0c94a2c0*
---

# Result

Pixel contact-sheet corrections applied on this drain. Matrix honesty, quiet/New! layout, catalogue unseen anonymity, Esc before/after, Verdant cabin focus, tip/ancestry, and Spin copy-gap list are updated below.

## Capability probe

| Route | Result |
|-------|--------|
| Godot binary | `C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot.exe` → `4.7.2.stable.official.ed1daf0bf` |
| Seat 6550 | Occupied by Nathan's editor PID 41644 — **not used** |
| Headless `collection_journey_selftest.gd` | **COLLECTION_JOURNEY_OK** (unit/fixture rail) |
| Headed shots | Second Godot `--display-driver windows` + disposable `APPDATA=…\collection-a-sandbox` |
| Isolation | Live Spinheritance userdata not written (sandbox profile only) |
| Tip watermark in shots | `0c94a2c0*` (exact tip + dirty uncommitted Pixel-correction WIP) |

## Exact tip / ancestry (corrected)

| Fact | SHA |
|------|-----|
| Exact accepted tip this drain | `0c94a2c06409369590d8b1f7a79eef8f28be2fa9` (= `origin/playtest/latest`) |
| Tip merge | `0c94a2c0` Merge PR #484 |
| Fulfillment commit on #484 | `724d12f6` |
| Earlier evidence commit (screenshot watermark in prior sheet) | `88ecc149` |
| Pre-merge playtest tip before #484 | `59e8ca51` |

**Ancestry (corrected, was reversed earlier):** `59e8ca51` **is an ancestor of** tip `0c94a2c0` (not the other way around). Tip-smoke SUCCESS on #484 ≠ runtime acceptance; this RESULT is the runtime evidence.

Dirty state captured: branch `cursor/collection-a-notrun-cases-e524` with uncommitted MVP layout/anonymity/focus harness edits at shoot time (`0c94a2c0*` watermark).

## Fixture class legend

| Class | Meaning |
|-------|---------|
| **unit** | Headless selftest / disposable state fixture. Does **not** prove offer-decline, nest Start, or simultaneous milestone journey. |
| **journey** | Actual runtime surface with headed 1680×1040 shot and/or synthetic input assertions on the live UI. |
| **synthetic input** | `InputEventAction` / scripted click — not physical keyboard/mouse hardware. |

## Commands

```
# UNIT rail
Godot --headless --path <repo> --script res://scripts/dev/collection_journey_selftest.gd

# JOURNEY shots (isolated APPDATA; does not steal 6550)
$env:APPDATA = "$env:TEMP\collection-a-sandbox"
Godot --display-driver windows --path <repo> --script res://scripts/dev/collection_a_live_repot.gd
# → LIVE_REPOT_DONE; log: pixel-corrections-stdout.log
```

## Screenshots (1680×1040 JOURNEY)

Driver: `scripts/dev/collection_a_live_repot.gd`. Every PNG below is 1680×1040 unless noted.

| id | verdict | note |
|----|---------|------|
| 01 | PASS | Verdant catalogue: banked=Collected; recognized=`[Spin copy: Recognized — not banked yet]`; **unseen=`?` + Not yet collected** (no identity leak). Roster bind live: b1 cabinet + `_pool_roster` → **4/15** banked/roster in fixture; overview totals source **x/67**. `01-catalogue-seen-vs-banked.png`. |
| 02 | PASS | Overview `New item types added: 1.` `02-return-receipt-overview.png`. |
| 03 | PASS | Locked Crystal tab anonymous (`?` / Locked) — no future names. `03-area-locked.png`. |
| 04 | PASS | **Occupied wheel + phase=combat + New! badge**; quiet strip row **above** hotbar; `overlap=false` `above_hotbar=true` `badges=1`. `04-inrun-quiet-strip.png`. |
| 05 | PASS | Milestone overview shows Spin gate + This-return placeholders; Skip keeps durable facts. `05-milestone-gate.png`. |
| 06 | PASS | Cabin before → Verdant (`Case_b1`) brighter than Crystal (`Case_b2` dim 0.42) → after hide. `06-cabin-before.png` / `06-cabin-optional-focus.png` / `06-cabin-after.png`. |
| 07 | PASS | Re-bank idempotent; seen retained. `07-reload-idempotent.png`. |
| 08 | PASS | Loss: no bank credit; seen retained. `08-loss-seen-retained.png`. |

## Input / reload (JOURNEY; synthetic labeled)

| id | verdict | note |
|----|---------|------|
| keyboard | PASS | **synthetic** `ui_accept` advances Next → Collection. `input-keyboard-next.png`. |
| mouse | PASS | **synthetic** click Next → Collection. `input-mouse-next.png`. |
| focus / Tab | PASS | **synthetic** `ui_focus_next` moves footer focus. |
| Esc / Back | PASS | **synthetic** `ui_cancel`: before menu visible → after menu dismissed + focus free. `input-esc-before.png` / `input-esc-after.png` (plus continuity `input-focus-back.png`). Arrival-only cabin shot is **not** used as Esc proof. |
| Skip | PASS | Skip leaves durable gate/overview facts. |
| reload / idempotence | PASS | Second bank adds nothing; phantom dropped on `load_all()`. |
| reduced-motion | NOTRUN | No project reduce-motion setting. Scaling/reduced-motion absent. |

## 24 Journey A acceptance cases

Authority: store `docs/collection-journey-a/approved-A-build.md`.

**Honest counts: PASS 14 · NOTRUN 9 · PARTIAL 1 · FAIL 0.**

| case | unit | journey | verdict | proof |
|------|------|---------|---------|-------|
| 01 Tutorial handoff | — | NOTRUN | **NOTRUN** | No real tutorial-finish journey; N01 fixture only |
| 02 Before-run objective / Verdant start | — | NOTRUN | **NOTRUN** | No nest Start→settle journey; N02 fixture only |
| 03 Offer/reveal → seen | PASS | — | **PASS** | unit `status_seen_after_offer` (not a live offer-decline path) |
| 04 Acquire one missing | PASS | PASS | **PASS** | unit carried + journey quiet/New! combat shot 04 |
| 05 Pass offered item | PASS | PASS | **PASS** | unit `seen_survives_spend` **does not** prove live offer-decline; journey catalogue seen cell still shown |
| 06 Duplicate held | PASS | — | **PASS** | unit provisional collapse |
| 07 Banked repeat | PASS | — | **PASS** | unit banked-repeat |
| 08 Spend last missing copy | PASS | — | **PASS** | unit after-last-spend |
| 09 In-run quiet + optional catalogue Back | — | PASS | **PASS** | journey 04 quiet + Esc before/after |
| 10 Carried fifth ≠ banked fifth | PASS | — | **PASS** | unit gate helpers |
| 11 Checkpoint Head home / Push | — | NOTRUN | **NOTRUN** | N03 rope PARTIAL labels ≠ Head home/Push journey |
| 12 Push into new biome entry | — | NOTRUN | **NOTRUN** | N04 splash fixture ≠ ordinary Push journey |
| 13 Failed run / seen retained | PASS | PASS | **PASS** | unit + journey 08 |
| 14 Successful multi-item bank | PASS | PASS | **PASS** | unit + journey 01/02/07 |
| 15 Zero-new success fast path | — | PASS | **PASS** | journey overview no-new path |
| 16 Gate 4→5 route unlock | PASS | PASS | **PASS** | unit milestones + journey 05 overview |
| 17 Simultaneous milestones | PASS | — | **PASS** | **unit only** — helpers do **not** establish simultaneous milestone sequence in one real return |
| 18 Next ordinary Verdant run | — | NOTRUN | **NOTRUN** | No post-receipt Start→nest journey |
| 19 Catalogue hierarchy + optional cabin | — | PASS | **PASS** | journey 01/03/06 (Verdant focus proven vs Crystal) |
| 20 Late missing identities ordinary play | — | NOTRUN | **NOTRUN** | N05 fixture ≠ ordinary late scrape |
| 21 Full biome cabinet recognition | — | NOTRUN | **NOTRUN** | N06 helper UI ≠ 14/14 ceremony journey |
| 22 Final-dungeon victory ≠ inheritance | — | NOTRUN | **NOTRUN** | N07 fixture only |
| 23 Full collection / neutral handoff | — | NOTRUN | **NOTRUN** | N08 fixture only |
| 24 Completed reload freedom | PASS | PARTIAL | **PARTIAL** | journey 07 reload/idempotence PASS; full post-completion freedom NOTRUN |

Remaining NOTRUN journey cases: **01, 02, 11, 12, 18, 20, 21, 22, 23** (+ **24 PARTIAL**). Reduced-motion/scaling absent.

## Spin copy gaps (exact full list — not production-final)

Visible `[Spin copy:…]` in catalogue, quiet strip, and milestone route/This-return. **Do not treat as final.** No new wording invented.

| Key | Fallback shown | Surface |
|-----|----------------|---------|
| `postrun.collection.item_seen` | `[Spin copy: Recognized — not banked yet]` | Catalogue recognized cell (shot 01) |
| `run.collection.quiet_summary` | `[Spin copy: {pool} banked {banked}/{quota} · held new {provisional}]` | Quiet strip (shot 04) |
| `run.collection.quiet_summary_threshold` | `{line} · [Spin copy: banks home to open route]` | Quiet strip threshold append (shot 04) |
| `postrun.milestone.heading` | `[Spin copy: This return]` | Milestone overview (shot 05) |
| `postrun.milestone.gate` | `[Spin copy: Route open — {from}→{to}/{quota} banked. Next: {next}]` | Milestone gate line (shot 05) |
| `postrun.milestone.cabinet_full` | `[Spin copy: Cabinet complete {count}/{total} — display only]` | Milestone (when cabinet_full fires; unit) |
| `postrun.milestone.collection_complete` | `[Spin copy: Full collection — reserved inheritance entry]` | Milestone / N08 (when complete fires) |

**Authored (reuse OK — not Spin gaps):** `postrun.collection.item_new`, `item_collected`, `item_missing`, `area_locked`, `postrun.summary.success_new`, `postrun.summary.death`, `cabin.tip.new`, and other existing keys used by overview/locked tabs.

## Roster totals bind

| Source | Value observed |
|--------|----------------|
| `progress_menu._pool_roster("b1").size()` | **15** (Verdant roster) |
| `CAMPAIGN_SHELL.cabinet_count(state, "b1")` | **4** in shot-01 fixture (4 banked) |
| Overview `Item types collected: x/67` | **67** = live all-pool roster uniques (not old 14/64 fixture audit) |
| Overview Verdant `collection: x/15` | matches `_pool_roster("b1")` |

Old 14/64 fixture audit is **retired**; bind to these live sources.

## MVP fixes this Pixel-correction pass

1. Quiet strip parented in `HotbarColumn` **above** hotbar cards (not competing z with New!).
2. Unseen unlocked-pool catalogue cells anonymous (`?` name + no icon) until seen.
3. Cabin `focus_biome_case` strongly dims siblings so Verdant reads over Crystal art glow.
4. Esc evidence is before/action/after with synthetic-input labeling + screensize logs.
5. RESULT matrix corrected to **14 PASS / 9 NOTRUN / 1 PARTIAL** with unit vs journey columns.

## Blockers / remaining limits

- Nine Journey A cases still **NOTRUN** without longer real tutorial/nest/checkpoint/Push/late/cabinet/final/inheritance play (listed above).
- Case **24 PARTIAL** — reload rails OK; full post-completion freedom not journey-proven.
- Case **17** remains PASS on **unit** only — not a simultaneous real-return sequence.
- reduced-motion / UI scaling: absent — NOTRUN.
- Spin must author the seven placeholder keys above before copy is production-final.
- Preference rewrite concern remains **separately unapproved** — settings not mutated.
- Tip-smoke ≠ runtime acceptance; exact-head + tip-smoke required before any further merge to `playtest/latest`.

## Shots

All PNGs under `shots/` (REQ 01–08, input-*, esc before/after, cabin before/after, plus retained N01–N08 fixture stills). Pixel-accessible mirror: store `media/collection-a-runtime/2026-11-08-pixel-corrections/`.
