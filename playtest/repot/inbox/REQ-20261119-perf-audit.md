---
id: REQ-20261119-perf-audit
status: open
priority: high
branch: perf/wheel-fit-memo-tex-cache
created: 2026-11-19T00:00:00-06:00
created_by: pixel
viewport: 1680x1040
entry: fresh save → F5 → real player path into the first dungeon fight
---

# Perf audit — hitch check on a real GPU (item click, spin, item use, monster effects)

Nathan (Nov 19 playtest): lag after clicking or selecting an item, after Spin, after using an item,
and after most monster effects. The headless audit found the CPU causes and fixed them on this branch.
This request checks the result on a real GPU, the part a headless run can't see.

## Rules

- Use a fresh save (move `%APPDATA%\Godot\app_userdata\Spinheritance` aside and restore it afterwards), then F5.
- Play the real player path from the title. No dev hooks, QA staging, or skip keys.
- Use **godot-mcp injected input only**. No OS mouse or keyboard, no computer-use, and don't take over Nathan's screen.
- Captures must be 1680×1040.
- Don't change feel. The spin stays at 1.56s cubic in-out with a full lap, and the wheel never moves or resizes.

## Measure

Run every scenario twice: once on `origin/playtest/latest` (before) and once on this branch (after).
Log frame times to a file. Use godot-mcp's runtime script or eval if it has one. Otherwise use the
existing F8 FrameMetrics capture, which only measures and doesn't touch combat; its JSON/CSV is written
to `user://perf/last_capture.*`. Record `Performance.TIME_PROCESS`, frame delta, `OBJECT_NODE_COUNT`,
`OBJECT_ORPHAN_NODE_COUNT` and `RENDER_TOTAL_DRAW_CALLS_IN_FRAME` for each frame.

| id | action (injected input) | report |
|----|-------------------------|--------|
| 01 | hover and click a hotbar item (select it) 5x | worst frame ms, count of frames over 33 ms |
| 02 | Spin 5x (hub Spin button) | worst frame from click to land, spikes over 33 ms |
| 03 | use a strike item (Boot, Sledge, Flail or Knife) 5x | worst frame during resolve |
| 04 | Take on a monster that dies (slay), 5x | worst frame at the kill |
| 05 | monster effects: let 3 different on-spin abilities fire (Poison, Juggernaut, Leech or any others) | worst frame per effect |
| 06 | play one full dungeon, then note node count at start vs end | node growth (combat log rows are expected to grow) |

## Pass criteria

- After the change, no frame over 50 ms in rows 01–05 once the first instance of each FX has played. A first-time FX upload hitch is allowed but must be noted.
- Write before/after numbers for each row in `RESULT.md`, plus any frame over 50 ms with its action.
- Attach the raw frame logs.

## Outbox path

`playtest/repot/outbox/REQ-20261119-perf-audit/`
