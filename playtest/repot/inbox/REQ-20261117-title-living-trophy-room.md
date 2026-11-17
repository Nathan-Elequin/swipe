---
id: REQ-20261117-title-living-trophy-room
status: done
priority: high
pr: 547
tip_sha: f1b0fdb89ba12c2727a2cbb744fd45ecd18d39de
branch: pixel/title-visual-layer
created: 2026-11-17T06:00:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: fresh save (clear user:// save + site data) → launch → intro → title
---

# Title living trophy room — visual verify

Living trophy room title redesign (art + board, progress icons, goal ring, ticker, presenters, settings panel extraction, picker card visuals). Cloud agent cannot F5; Cherry fulfills with godot-mcp.

## Rules (verbatim)

- **Drive the game only with godot-mcp injected input** (mouse move/click/keys through the MCP). **Never OS-level / computer-use control of Nathan's screen.**
- **Fresh save.** Real player path only: **no `_dev_*`, no `preview_*` hooks, no Grant, no DevChrome hotkeys, no forced poses or forced milestones.**

## What to verify

- Title board, biome windows, progress icons, menu tags, presenters, Start over, goal ring, progress ticker, New Game picker cards, title Settings panel, intro preview still, start-over confirm, reduced motion.

## Screenshots required

| id | room | setup | expect | filename |
|---|---|---|---|---|
| 01 | intro | fresh save, play to the preview still | preview shows the no-save title | 01-intro-preview.png |
| 02 | title | no save | New Game / Settings / Feedback; no Start over; no goal icon; all biomes but Verdant dimmed with names | 02-title-nosave.png |
| 03 | title | hover each row | tag hover + presenter idle; hover sound | 03-title-hover.png |
| 04 | picker | New Game | 3 cards with green/silver/gold rings; hover rises the card | 04-picker.png |
| 05 | combat | pick Quick → real path into the first fight; hover the corner ring | green ring; ticker opens top-left, clear of wheel/arrows/hand | 05-ticker-combat.png |
| 06 | title | quit to title (save now exists) | Continue replaces New Game; Start over visible; goal ring visible | 06-title-save.png |
| 07 | settings | Settings from the title; move Music | same 5 sliders as Esc; jukebox reflects the value | 07-settings.png |
| 08 | title | Start over | confirm modal, Keep focused; press Keep (do NOT wipe) | 08-start-over.png |
| 09 | title | Settings → Reduce motion on, hover rows | no movement, stylebox swap only | 09-reduced.png |

## Pass criteria

- Every `expect` is readable from the PNG.
- No "Tier"/"ATK" text anywhere.
- No console errors.
- All rows shot at 1680×1040.

## Outbox path

`playtest/repot/outbox/REQ-20261117-title-living-trophy-room/`
