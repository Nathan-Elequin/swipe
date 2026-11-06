---
id: REQ-20261106-take-arc-bevel
status: open
priority: high
branch: playtest/latest
created: 2026-11-06T03:10:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue into a fight. Prefer Slime Boss with incoming Take ~10 so the right third shows Take + a large burst. For shot 03, gain Block > 0 (Shield / Breastplate) so the left third shows the Block pip.
---

# Take arc taller band, 2-tone bevel, square ends

F5 follow-up after #417. `BODY_W` 48 → 53 (~10% taller). Cream band has an outer ink + inner highlight bevel (carved / metal-rimmed), not a flat single stroke. Short engraved ticks at the square corners; engraved split divider. Block pip and take-damage burst stay fully inside. Hover still clearly brighter than idle. Take / Safe copy unchanged. No Tier. Wheel seats untouched.

Supersedes `REQ-20261106-take-arc-square-hug` — do not drain that request.

## What to verify

- Band is a bit taller than #417, still square radial cuts (no oval disks).
- Rim reads as a **bevel**: outer ink + gold just inside, inner cream highlight — not one flat stroke.
- Tiny corner ticks on the square ends; they do not crowd Take or the Block pip.
- Hover is **clearly brighter** than idle (fill + gold trim).
- Block pip + large Take 10 burst sit fully inside the band — no dungeon spill.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Slime Boss or any fight, incoming Take > 0, pointer **not** on the arc | Taller cream band; 2-tone bevel rim; square ends; idle (not hover-bright) | 01-idle-bevel.png |
| 02 | combat | Same fight, **hover** the Take arc | Clearly brighter fill/trim than 01; bevel still readable; square ends | 02-hover-bevel.png |
| 03 | combat | Block pip + large burst (Take 10 / Slime Boss, Shield or Breastplate so Block > 0) | Pip + burst fully inside; no dungeon spill; square ends; ticks not covering the pip | 03-block-burst-inside.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Shot 02 must be visibly brighter than 01 without guessing.
- Shot 01 must show a bevel (inner highlight + outer ink), not a single flat outline.
- Shot 03 must show both the Block pip and a large take-damage burst inside the band, with square ends.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261106-take-arc-bevel/`
