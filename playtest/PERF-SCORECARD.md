# Perf Scorecard (v1)

Measurement-first. Capture numbers on Cherry (or itch Web Playtest) before any optimization PR.

Overlay lives in `scripts/frame_metrics.gd`. It attaches only when `PlaytestFlag.on()` (editor F5 or Web Playtest export). Release / public Web export does not get it.

## Cherry capture recipe (one F5)

1. Checkout this PR branch in boss-rush (`tools/dev/load-pr.ps1 <n>`), Stop Play, F5.
2. Press **F8** — overlay opens top-left (rolling frame ms + spike count + feel spans).
3. Set up the scene for the scenario (table below), then press the scenario key **or** click its button.
4. Play the beats the scenario names (Spins, Takes, item uses, draft picks).
5. Press the **same key** again (or **stop**) to dump capture.
6. Copy from Godot user data:
   - JSON: `%APPDATA%\Godot\app_userdata\<project>\perf\last_capture.json` (also `scenario_platform_sha.json`)
   - CSV twin: `last_capture.csv` beside it
   - Editor log prints `FRAME_METRICS <path>` and `FRAME_METRICS_DIR <dir>`
7. Fill one row in the blank table below from that JSON/`feel_spans` block. One scenario per row unless noted.

Web Playtest: same F8 / 1–7 flow; stop downloads JSON+CSV in the browser.

## Scenarios (keys 1–7)

| Key | Scenario id | Setup | What to do while REC |
|-----|-------------|-------|----------------------|
| 1 | `cabin_idle` | Cabin main, standing | Idle ~5–8 s |
| 2 | `fight_idle` | In a fight, plate up | Idle ~5–8 s facing a live monster |
| 3 | `attack_x5` | Fight ready | Use Attack items ~5 times |
| 4 | `spin_x5` | Wheel ready | Spin ~5 times (land callout each time) |
| 5 | `lunge_x5` | Fight | Take / resolve ~5 times |
| 6 | `transition_x3` | Cabin ↔ run door | Enter/leave combat or cabin ~3 times |
| 7 | `tut_brand_new_yes` | Hub → Brand New → Yes | Tutorial path through first Spin + item + Take |

## Scorecard columns

Fill after one capture. Do not invent ms — paste from JSON.

| Column | Source |
|--------|--------|
| scenario | `scenario` |
| sha | `sha` (dirty flag if `dirty`) |
| frame p50 / p95 / max (ms) | `frame_ms.p50` / `.p95` / `.max` |
| spikes >16.7 / >33.3 / >50 | `spikes.over_16_7` / `.over_33_3` / `.over_50` |
| spin→callout p50 / p95 | `feel_spans.spin_to_callout` |
| use-item resolve p50 / p95 | `feel_spans.use_item_resolve` |
| Take apply p50 / p95 | `feel_spans.take_apply` |
| draft→hotbar p50 / p95 | `feel_spans.draft_to_hotbar` |
| notes | hitch feel, spike tag from `spike_markers[].tag`, anything odd |

`n: 0` on a feel span means that verb was not exercised during the capture — re-run or leave blank.

## Blank table (paste after F5)

| scenario | sha | frame p50 | frame p95 | frame max | >16.7 | >33.3 | >50 | spin→callout p50/p95 | use-item p50/p95 | Take p50/p95 | draft→hotbar p50/p95 | notes |
|----------|-----|-----------|-----------|-----------|-------|-------|-----|----------------------|------------------|--------------|----------------------|-------|
| | | | | | | | | | | | | |

## Ranking ms / spike ROI later

1. Sort by `frame_ms.p95` and `spikes.over_50` across the same scenario + same machine.
2. Read `spike_markers` tags (`wheel`, `stage`, `place_fight_art`, feel-span names) before proposing a fix PR.
3. Instrument-only PRs stay measurement; do not stack speculative combat FX cuts here (SP-30 budgets already shipped).

## Out of scope (this slice)

- No feel timing changes
- No art stripping
- No new optimization PRs from this capture alone
