---
id: REQ-20261103-spinning-top-art
status: open
priority: normal
branch: cursor/spinning-top-art-wire-ebbe
pr: 331
tip_sha: ef9fcf50
created: 2026-11-03T17:24:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New / Challenge → draft or fight so Spinning Top can appear on the hotbar / item pool
---

# Spinning Top item art + live pool

Wire unique Spinning Top PNG (warm red/gold/orange bands, no blue), ITEM_PNG map, catalog `flags.art`, and `runtime.json` items so it enters the live item pool.

## What to verify

- `assets/dungeon/items/spinning_top.png` shows on the hotbar / inspect (not rotate.svg fallback).
- Palette is warm wood + red/gold/orange bands — no blue (blue reads Block; this is ATK).
- Spinning Top can appear in the live item pool / draft (runtime items includes `spinning_top`).
- Fairy In A Bottle still hidden / art:false (untouched).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight or draft | Spinning Top in hand / hotbar (force via Roster or lucky draft) | card art is wooden top with red/gold/orange bands, not rotate icon and not blue bands | 01-hotbar-spinning-top.png |
| 02 | inspect | open inspect on Spinning Top | same warm toy-top PNG fills the art slot | 02-inspect-spinning-top.png |

## Pass criteria

- Both rows shot at 1680×1040 (or note if viewport differs).
- Art clearly reads as Spinning Top; no blue bands; not the rotate.svg fallback.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261103-spinning-top-art/`
