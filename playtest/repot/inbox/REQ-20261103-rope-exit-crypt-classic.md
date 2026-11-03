---
id: REQ-20261103-rope-exit-crypt-classic
status: open
priority: high
branch: cursor/rope-exit-crypt-classic-08c4
tip_sha: 29459ab1
created: 2026-11-03T22:10:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New (or Middle Progress) → clear a dungeon / reach rest so Rope Exit opens
---

# Rope Exit Crypt Classic + lifetime tally wall

Replaces ChatGPT painterly cavern plates with Crypt Classic pixel art (1680×1040, same density as cabin interiors). Wires hatch + gate frame overlays. Adds a dynamic wall-tally system driven by a new persisted `lifetime_dungeons_cleared` save field (not per-run `dungeons_cleared`). At ≥50 clears, Bartleby chalk replaces stroke groups. Painterly chains / gate_open stay on disk but stay hidden.

## What to verify

- Chamber BG is Crypt Classic pixel art (stone blocks, green shaft, no ChatGPT painterly look). Nearest, exact 1680×1040 — no stretch-from-1536.
- Wooden hatch sits over the green ceiling shaft.
- Gate frame alone on the right clear zone (no painterly chains / open cyan plate).
- Brand New / zero lifetime clears → empty tally rect (no chalk strokes).
- After forcing ~23 lifetime clears (`rope_exit.set_tally_debug(23)` from shot harness / console, or save field) → ~4 groups of chalk marks matching `design/visual/rope-exit-crypt/preview_tally_23.png`.
- `set_tally_debug(50)` (or lifetime ≥50) → Bartleby chalk portrait fills the wall rect; stroke groups hidden. Match `preview_tally_50_bartleby.png`.
- Climb and Delve planks / hotspots still work.
- No new player-facing toast / copy strings.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope exit | Brand New clear → rest; chrome visible | Crypt Classic BG fills 1680×1040; green shaft readable; not ChatGPT painterly | 01-bg-crypt-classic.png |
| 02 | rope exit | same | hatch over shaft (top-center); gate frame on right; no chains / open plate | 02-hatch-gate-frame.png |
| 03 | rope exit | lifetime / debug tally = 0 | wall rect empty (softened rock only); no strokes | 03-tally-0.png |
| 04 | rope exit | `rope_exit.set_tally_debug(23)` then open | ~23 chalk marks in 2-row ledger; matches preview density | 04-tally-23.png |
| 05 | rope exit | `rope_exit.set_tally_debug(50)` then open | Bartleby chalk portrait in wall rect; no stroke groups | 05-tally-50-bartleby.png |
| 06 | rope exit | Climb / Delve hover + click | planks readable; climb / deeper still fire | 06-climb-delve.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Clear `set_tally_debug(-1)` after forced shots so save-driven tallies resume.

## Outbox path

`playtest/repot/outbox/REQ-20261103-rope-exit-crypt-classic/`
