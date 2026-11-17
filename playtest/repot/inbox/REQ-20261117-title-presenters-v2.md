---
id: REQ-20261117-title-presenters-v2
status: open
priority: high
pr: 554
tip_sha: deef5dc29aa681f7815c3288732f3f17bff5b6e2
branch: pixel/title-presenters-v2
created: 2026-11-17T07:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: fresh save → intro → title (no-save New Game / Settings / Feedback)
---

# Title presenters v2 — stronger present/bow

Batch-2 presenter frames (6 frames, hold last) for title rows + biome catalog presents. Pane dioramas replace face_bg crops in TitleBoard windows. Cloud agent cannot F5; Cherry fulfills with godot-mcp.

## Rules (verbatim)

- **Drive the game only with godot-mcp injected input** (mouse move/click/keys through the MCP). **Never OS-level / computer-use control of Nathan's screen.**
- **Fresh save.** Real player path only: **no `_dev_*`, no `preview_*` hooks, no Grant, no DevChrome hotkeys, no forced poses or forced milestones.**

## What to verify

- Title row presenters are goblin / gargoyle / lich with stronger bow/present (not subtle idle loops).
- On select, present plays once at 10 fps and holds the last frame.
- Gargoyle present frames have no dirt / ground pedestal under the gold claws.
- Window panes are tall 56×154 dioramas (not the old wide face_bg crop).
- Reduced motion: presenters stay on frame 0.
- No visible "Tier" or "ATK".

## Screenshots required

| id | room | setup | expect | filename |
|---|---|---|---|---|
| 01 | title | no save, at rest | New Game / Settings / Feedback; presenters on idle f0; panes visible in board windows | 01-title-rest.png |
| 02 | title | hover Settings (gargoyle) | idle loops; no dirt mound under gargoyle | 02-title-hover-gargoyle.png |
| 03 | title | press Feedback (lich) and hold before leave | present bow holds last frame | 03-title-present-hold.png |
| 04 | title | Settings → Reduce motion on, hover + press rows | presenters stay on f0 | 04-reduced.png |

## Pass criteria

- Every `expect` is readable from the PNG.
- No "Tier"/"ATK" text anywhere.
- No console errors.
- All rows shot at 1680×1040.

## Outbox path

`playtest/repot/outbox/REQ-20261117-title-presenters-v2/`
