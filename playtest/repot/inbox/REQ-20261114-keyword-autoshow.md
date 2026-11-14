---
id: REQ-20261114-keyword-autoshow
status: open
priority: high
pr: 520
branch: cursor/keyword-autoshow-stack-37d8
tip_sha: a041c697
created: 2026-11-14T10:00:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New (fresh save) → Skip tutorial → enter Verdant Hollow fight
---

# Keyword cards auto-show on inspect

Inspecting an item or monster (hotbar hover, draft pick, wheel seat/monster, boss) now shows every keyword definition card for that thing at once, stacked beside the plate like Slay the Spire. No word-hover required. Combat log line hover still shows that line's cards. F1 keyword defs editor unchanged.

## What to verify

- Fresh save. Real mouse only (no `_dev_*` / `preview_*` / forced `show_def`).
- Hotbar item with 1 keyword: stack of one parchment card appears with the plate; text fully readable (no clip/ellipsis).
- Hotbar item with 3+ keywords: stacked cards, same width, grow in height; two columns if too tall; never covers the wheel or the plate; stays inside 1680×1040.
- Draft pick inspect: same autoshow.
- Wheel monster seat inspect: same autoshow.
- Boss inspect: same autoshow.
- First-sighting: unseen keyword's card in the stack gets gold pulse + `new_star` once, then marked in `seen_keywords`.
- Combat log: hover a line that names a keyword → that line's cards appear; leave → gone.
- No "Tier" / "ATK" labels on the cards. No player-copy rewrites.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | fresh save, hover hotbar item with 1 keyword (e.g. Boot / Defeat) | one parchment card beside plate; full def visible | 01-hotbar-one-kw.png |
| 02 | fight | hover hotbar item with 3+ keywords | stacked cards; no wheel/plate overlap; no clipped text | 02-hotbar-many-kw.png |
| 03 | fight | draft pick with keywords | stack beside draft inspect plate | 03-draft-pick.png |
| 04 | fight | hover wheel monster seat | stack beside monster plate | 04-wheel-monster.png |
| 05 | fight | boss / high-tier monster inspect | stack beside boss plate | 05-boss.png |
| 06 | fight | first-sighting unseen keyword (clear `seen_keywords` or Brand New) | gold pulse + new_star on that card in the stack | 06-first-sighting.png |
| 07 | fight | hover combat log line that includes a keyword chip | that line's parchment card(s) visible | 07-log-line.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs). If the Play window framebuffer is smaller, scale design rects by `framebuffer/viewport` before cropping.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261114-keyword-autoshow/`
