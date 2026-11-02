---
id: REQ-20261101-decay-link-elegance
status: open
priority: high
branch: cursor/decay-link-elegance-3c47
tip_sha: 570fafe5
base: playtest/latest
created: 2026-11-02T01:40:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress → delve → fight with Zombie Decay (linked pair) on hotbar
---

# Decay LINK hotbar aura elegance (no purple blotch)

Cloud fix for Direction A LINK: tip was painting Decay with a near-solid violet StyleBox plate (`metal.lerp(COL_LINK, 0.85)` + fat READY-style `_draw_solid_ring`) that blotted out icon art. Now thin ~2px violet ring (no glow shadow), light border tint, TL `decay_pip`, and mid-edge `decay_chain.png` toward partner. Solo Decay gets pip + thin rim only.

## What to verify

- Decay pair idle: icon art fully readable; thin violet outer ring; TL diamond pip; chain glyph on the edge toward the partner (not covering icon center).
- Hover one linked card → partner keeps WARN dashed #E8553E; pip/chain may remain; no purple wash on either plate.
- Solo Decay mark (if it appears): pip ± thin violet rim — still no blotch.
- READY solid pulse, WARN dashed, CHOICE double thin, Hex mint, Toll crimson, Petrify hatch/stamps unchanged in spirit.
- Never show the word Tier.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight hub | Zombie Decay linked pair, neither hovered | thin violet LINK + TL pip + chain between/toward pair; icons readable (no purple fill) | 01-decay-link-idle.png |
| 02 | fight hub | Hover one Decay-linked card | partner WARN dashed red; pip/chain cues; no purple plate wash | 02-decay-partner-warn.png |
| 03 | fight hub | Recycler@1 or Magnet armed nearby (regression) | READY still solid pulsing gold | 03-ready-unchanged.png |

## Pass criteria

- Idle Decay matches Doop `01A` HOVER Decay Pair language (thin violet + pip + chain), not a filled purple wash.
- Icons remain readable on LINK cards.
- READY / WARN / CHOICE still look elegant / unchanged in spirit.

## Outbox path

`playtest/repot/outbox/REQ-20261101-decay-link-elegance/`

Cloud cannot F5/godot-mcp — local Cherry drain required. Optional still under `outbox/.../shots/` if easy.
