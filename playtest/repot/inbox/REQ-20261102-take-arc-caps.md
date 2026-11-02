---
id: REQ-20261102-take-arc-caps
status: open
priority: high
branch: cursor/take-arc-rounded-caps-e224
base: playtest/latest
created: 2026-11-02T19:50:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue into a fight with Moves (Adventure). Prefer Block > 0 (Shield / Breastplate) and incoming Take > 0 so the right third shows Take + burst.
---

# Take arc rounded caps + arced Take/burst

Cloud polish on the cream Take arc under the wheel. Ends are ovular disk caps (move-arrow tail style). "Take" / "Safe" word and the damage burst rotate along the arc midline instead of sitting flat horizontal. Block pip rotates when present. One click target unchanged. No player-facing copy edits.

## What to verify

- Arc tips are **rounded disks**, not square radial cuts — match move-arrow tail caps (ink/wood/face stack + outward highlight).
- **"Take" (or Safe) follows the cream band curve**; damage burst + number sit on the same arc rotation (not flat to the screen).
- When Block > 0, the left pip + number also tilt with the arc.
- Whole arc remains one click for Take / end beat; clicking near the rounded tips still registers.
- Move-arrow tails do **not** overlap / kiss the new caps (SWEEP nudged to 1.32).
- Hotbar / item cards / defeat / splash unchanged. Words still read Take / Safe (locked copy).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Block 0, incoming Take > 0 | Rounded left+right caps; Take word + burst arced along band; no flat horizontal label | 01-take-arced-caps.png |
| 02 | combat | Block > 0, still net Take | Left pip rotated with arc; divider; Take side arced | 02-block-pip-rotated.png |
| 03 | combat | Moves available, same fight | Caps clear of move-arrow tails; arrows still readable | 03-caps-clear-arrows.png |
| 04 | combat | Net Take 0 (Safe) | Safe word arced on right third; split chrome + rounded ends kept | 04-safe-arced.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each expect readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-take-arc-caps/`
