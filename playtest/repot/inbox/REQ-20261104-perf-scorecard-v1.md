---
id: REQ-20261104-perf-scorecard-v1
status: open
priority: normal
pr: 392
tip_sha: 3726d60a
branch: cursor/perf-scorecard-instrumentation-be0a
created: 2026-11-04T19:20:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → Yes (tutorial) OR Middle Progress into a fight
---

# Perf scorecard instrumentation v1

Extends the existing F8 `FrameMetrics` overlay (playtest/editor only) with feel-span timers, `tut_brand_new_yes` scenario, JSON+CSV dump, and `playtest/PERF-SCORECARD.md`. Instrument only — no FX/feel timing changes.

## What to verify

- F8 toggles the overlay; it is absent / inert outside playtest+editor (`PlaytestFlag`)
- Overlay shows rolling frame ms, spike count (>50), and feel span lines after Spin / item / Take / draft
- Keys 1–7 arm scenarios; key **7** is `tut_brand_new_yes`; same key stops and writes `user://perf/last_capture.json` + `.csv`
- Capture JSON includes `frame_ms.p50` / `p95` and `feel_spans.{spin_to_callout,use_item_resolve,take_apply,draft_to_hotbar}`
- No combat feel/timing change vs tip without the overlay open

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat or cabin | F5 → F8 overlay open, idle | Overlay visible top-left with sha + rolling ms; no HUD/combat layout shift | 01-overlay-idle.png |
| 02 | fight | Arm scenario 4 `spin_x5`, Spin once so callout lands, still REC | Overlay shows REC spin_x5 + spin_to_callout span line | 02-spin-span-rec.png |
| 03 | fight or draft | Stop capture (same key); open `user://perf` or paste log path | `FRAME_METRICS` path in output; optional shot of overlay summary line with avg/p50/p95 | 03-capture-summary.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Overlay readable; scenarios 1–7 present on the panel.
- `RESULT.md` notes whether `last_capture.json` was written (path + scenario id) — file copy into outbox optional.
- Fail if feel/combat timings changed with overlay closed, or if overlay appears on a non-playtest release export (N/A if Cherry only has playtest F5).

## Capture recipe

See `playtest/PERF-SCORECARD.md` (Cherry steps + blank scorecard table). Nathan/Pixel fills the table after one F5; no optimization PR from this REQ.

## Outbox path

`playtest/repot/outbox/REQ-20261104-perf-scorecard-v1/`
