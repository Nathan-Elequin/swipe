---
id: REQ-20261117-title-menu-flow
status: open
priority: high
branch: cursor/title-menu-playtest-flow-5c66
created: 2026-11-17T05:50:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub after Nathan intro (or skip to title once intro seen)
---

# Title menu flow + copy (logic)

Playtest title menu: New Game XOR Continue, Settings, Feedback, Start over confirm, tier picker only from New Game. Settings reuses Esc settings_menu. Picker cards show title / biome / short goal; longer `.line` is tooltip.

## What to verify

- No save → New Game + Settings + Feedback; Continue and Start over hidden; New Game focused.
- With save → Continue focused + Start over; New Game hidden.
- New Game opens commitment picker (not after intro).
- Start over confirm → wipe → back to no-save title; `swipe_pt_anon` kept.
- Title Settings opens the same board as Esc (volume + toggles); Back closes.
- Picker card shows title, biome, goal+time; hover/focus tooltip shows the longer `.line`.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | title | no save (Start over or fresh profile) | New Game top; Settings + Feedback; no Continue / Start over | 01-title-no-save.png |
| 02 | title | save exists | Continue focused; Start over visible; New Game hidden | 02-title-with-save.png |
| 03 | title | save → Start over | confirm dialog with Wipe it / Keep my save | 03-start-over-confirm.png |
| 04 | title | Settings from title | same settings board + Master slider; Back label | 04-title-settings.png |
| 05 | picker | New Game → picker; hover/focus a card | title + biome + goal; tooltip = longer line | 05-picker-card-tooltip.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261117-title-menu-flow/`
