---
id: REQ-20261106-take-arc-square-hug
status: superseded
priority: high
pr: 417
branch: playtest/latest
created: 2026-11-06T02:50:00Z
created_by: cursor-cloud
superseded_by: REQ-20261106-take-arc-bevel
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue into a fight. Prefer Slime Boss with incoming Take ~10 so the right third shows Take + a large burst. For shot 03, gain Block > 0 (Shield / Breastplate) so the left third shows the Block pip.
---

# Take arc square ends, stronger hover, hugging band (superseded)

Nathan F5 follow-up after #417 asked for a taller band + bevel. **Drain `REQ-20261106-take-arc-bevel` instead.**

Nathan greenlit via Cabin Nib: drop the rounded oval disk end-caps, make hover obviously brighter, and shrink the cream band so the Block pip and take-damage burst sit fully inside it with zero overflow onto the dungeon background. `BODY_W` 84 → 48. Icons scale to `ICON_MAX` 40. Ends are square radial cuts. Take / Safe copy unchanged. No Tier. Wheel seat art untouched.

Supersedes `REQ-20261102-take-arc-caps` (rounded disks) — do not drain that request.

## What to verify

- Ends are **square radial cuts**, not pill / oval disks. No circular caps at the left or right tip.
- Idle cream is the usual wood/gold/cream stack. Hover is **clearly brighter** (fill + gold trim) and the rim reads thicker / slightly larger. Pressed is a bit darker with a thicker rim. Theme stays StyleBoxEmpty + custom `_draw`.
- Band is shorter than the old 84px strip. Block pip and take-damage burst (including a large Take 10 burst) sit **fully inside** the cream band — no spill onto the dungeon bg.
- Player-facing words still read Take / Safe. No “Tier” anywhere. Wheel seats unchanged. One click still ends the beat.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Slime Boss or any fight, incoming Take > 0, pointer **not** on the arc | Idle Take arc; square ends (no oval disks); Take word on the right | 01-idle-take.png |
| 02 | combat | Same fight, **hover** the Take arc | Clearly brighter fill/trim than 01; thicker or slightly larger rim; still square ends | 02-hover-take.png |
| 03 | combat | Block pip + large burst (Take 10 / Slime Boss, Shield or Breastplate so Block > 0) | Pip + burst fully inside the band; no dungeon spill; no end caps | 03-block-burst-hug.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Shot 02 must be visibly brighter than 01 without guessing.
- Shot 03 must show both the Block pip and a large take-damage burst inside the band, with square ends.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261106-take-arc-square-hug/`
