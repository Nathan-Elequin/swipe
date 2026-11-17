---
id: REQ-20261117-title-menu-flow
status: open
priority: high
branch: cursor/title-menu-playtest-flow-5c66
created: 2026-11-17T05:50:00Z
updated: 2026-11-17T06:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub after Nathan intro (or skip to title once intro seen)
merged_visuals: playtest/latest (#547 Living trophy room)
---

# Title menu flow + copy (logic) on Living trophy room visuals

Playtest title menu wired into Pixel #547 seams: trophy board, biome progress icons, presenters, goal rings, progress ticker, shared SettingsPanel, picker cards. Logic/copy from #549; visual nodes/assets from #547.

## What to verify

- No save → New Game + Settings + Feedback on the trophy-room title; Continue and Start over hidden; New Game focused; board shows Verdant entered / others gray.
- With save → Continue focused + Start over under the menu; New Game hidden; goal ring visible when a tier is chosen.
- New Game opens commitment picker (not after intro) with presenter + goal-ring cards.
- Picker card shows title, biome, short goal (time included); hover/focus tooltip shows the longer `.line`.
- Start over confirm → Wipe it / Keep my save → wipe → back to no-save title; `swipe_pt_anon` kept.
- Title Settings opens the Living trophy SettingsScreen (shared SettingsPanel = same toggles/sliders as Esc); Back closes.
- Hover goal ring in a run → progress ticker top-left (icons + %).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | title | no save (Start over or fresh profile) | Trophy board; New Game top; Settings + Feedback; no Continue / Start over | 01-title-no-save.png |
| 02 | title | save exists | Continue focused; Start over visible; New Game hidden; biomes reflect progress | 02-title-with-save.png |
| 03 | title | save → Start over | confirm dialog with Wipe it / Keep my save | 03-start-over-confirm.png |
| 04 | title | Settings from title | SettingsScreen + shared panel (sparkles/invert/reduce + 5 sliders); Back | 04-title-settings.png |
| 05 | picker | New Game → picker; hover/focus a card | presenter + ring; title + biome + goal; tooltip = longer line | 05-picker-card-tooltip.png |
| 06 | combat | after pick; hover corner goal ring | green/silver/gold ring; ticker opens top-left | 06-ticker-combat.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
