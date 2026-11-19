---
id: REQ-20261119-inspect-v2
status: open
priority: high
pr: 561
tip_sha: a9a53c54
branch: cursor/inspect-v2-dark-minimal-bdb3
created: 2026-11-19T08:10:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New (fresh save) → Adventure → fight on the wheel with minion, elite, and boss seats visible
---

# Inspect v2 — dark minimal monster plate

On-wheel monster hover inspect is a small dark plate (facing-callout colors): name + ability pill + ability sentence only. No portrait, rank word, or HP/attack pips. Clearly smaller than the #559 parchment card.

## What to verify

- Hovering a wheel monster shows a dark plum / near-black plate with thin light border (matches the right-side facing callout colors).
- Plate shows only: white bold name, ability pill (icon + call name), ability sentence with keyword color highlights.
- No Minion/Elite/Boss rank word, no portrait sprite, no heart/sword HP-attack numbers on the hover plate.
- Plate sits beside the hovered seat; stuck-hover still clears when the cursor leaves.
- Keyword capsules may still be light parchment — note only; not a fail.
- Item hotbar hovers are unchanged.

## Screenshots required

Input: **godot-mcp injected only** (never OS mouse/keyboard). Viewport **1680×1040**. Fresh Brand New save.

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | wheel fighting | Adventure fight; hover a **Minion** (tier 1) seat on the wheel | Dark compact plate: name + pill + sentence; no portrait/rank/stats | 01-hover-minion.png |
| 02 | wheel fighting | Same fight; hover an **Elite** (tier 2) seat | Same dark minimal plate; elite metal rim OK | 02-hover-elite.png |
| 03 | wheel fighting | Same fight; hover a **Boss** (tier 3) seat | Same dark minimal plate; boss metal rim OK | 03-hover-boss.png |
| 04 | wheel fighting | Hover a non-facing seat while the **right-side facing callout** is up | Plate next to callout for style compare — same dark family, hover clearly smaller | 04-plate-vs-callout.png |

## Pass criteria

- All rows at 1680×1040.
- Each hover plate is dark (light text on dark), not parchment.
- No portrait / rank / HP-ATK chrome on the hover plate in any shot.
- 04 shows the hover plate and the facing callout in the same frame for color match.
- No player-facing "Tier" or "ATK" on the plate.

## Outbox path

`playtest/repot/outbox/REQ-20261119-inspect-v2/`
