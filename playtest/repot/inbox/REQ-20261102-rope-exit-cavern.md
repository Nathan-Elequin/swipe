---
id: REQ-20261102-rope-exit-cavern
status: open
priority: normal
branch: cursor/rope-exit-cavern-shell-da39
pr: 320
tip_sha: c4eaa3f7
created: 2026-11-02T21:35:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New or Middle Progress → clear a dungeon / reach rest so Rope Exit opens
---

# Rope Exit cavern-shell plates

Tip+wire of the ChatGPT cavern pack: full-screen chamber BG, right-wall locked gate (frame + chains), hatch on the shaft. Climb / Delve chrome unchanged. Socket-fill gameplay deferred (empty sockets only).

## What to verify

- Rope Exit opens on the new painted cavern BG (not the old cozy board room).
- Right wall shows the arched gate with chains + padlock (locked look). No bright "open" cyan fill by default.
- Wooden hatch sits over the green ceiling shaft.
- Title band, Climb, and Delve planks stay readable and clickable; hotspots still fire climb / deeper.
- Legacy ladder / hole / torch sprites are not painted on top of the cavern (hidden).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope exit | after a clear; chrome visible | cavern BG fills the view; green shaft + hatch readable at top-center | 01-arrival-bg.png |
| 02 | rope exit | same | right-wall gate frame + X chains/padlock visible; sockets empty | 02-gate-locked.png |
| 03 | rope exit | same | hatch over shaft; Climb + Delve planks readable, not covered by gate | 03-hatch-chrome.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-rope-exit-cavern/`
