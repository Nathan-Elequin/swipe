---
id: REQ-20261117-keyword-bold-no-underline
status: open
priority: high
tip_sha: 62533141
branch: cursor/keyword-bold-no-underline-9b52
created: 2026-11-17T04:55:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue into a fight with Commander (or any monster/item with Neighbor / Always / Defeated / Flee / Poison chips)
---

# Keyword chips bold, no underline

Tooltip keywords (Neighbors, Always, Defeated, Flee, Poison, etc.) must match Attack/HP chip weight: bold + existing keyword ink, with the inline icon unchanged, and **no** underline. Hover/autoshow stack still works.

Central change: `UxStyle.chip_bbcode` (feeds inspect plates, item cards, combat log, tutorial talk, speech). RTLs keep `meta_underlined = false`.

## What to verify

- Commander (or similar) inspect body: Neighbors / Always / Defeated / Flee are **bold**, keep their ink, **no** underline; icons unchanged.
- "+2 Attack" / "3 HP" still bold + colored as before (unchanged path).
- Item plate / hotbar showcase ability with Keep / Poison / Neighbor: same bold-no-underline chips.
- Hovering a chip still opens the parchment keyword card / autoshow stack.
- Combat log line with Spin / Flee: bold chip, no underline, hover still works.
- Tutorial talk box keyword (if reachable): bold, no underline.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Inspect Commander (or Flee + Neighbor monster); hover a keyword | chips bold + colored, no underline; parchment tip open | 01-commander-keyword-bold.png |
| 02 | fight | Hotbar / inspect item with Keep or Poison | item ability chips bold, no underline | 02-item-keyword-bold.png |
| 03 | fight | Combat log line with Spin or Flee chip | log chip bold, no underline | 03-log-keyword-bold.png |

## Pass criteria

- All rows shot at 1680×1040.
- No `[u]` underline visible on tooltip keywords.
- Keyword ink colors unchanged from pre-change (gold / purple / etc.).
- Hover tips still appear.

## Outbox path

`playtest/repot/outbox/REQ-20261117-keyword-bold-no-underline/`
