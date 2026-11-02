---
id: REQ-20261102-h3-b2-take-arc
status: superseded
priority: high
branch: playtest/latest
created: 2026-11-02T08:30:00Z
created_by: cloud-agent
superseded_by: REQ-20261102-h3-b2-take-arc-fix
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue into a fight with Moves (Adventure)
---

# H3-B2 cream Take arc + bigger hotbar (superseded)

Original wire for H3-B2. Tip layout was wrong after merge (Safe pill / Block on right / arrows into rim). **Drain `REQ-20261102-h3-b2-take-arc-fix` instead** — that request covers the corrected Doop match.

## What to verify

- Wheel + Sprout size/location unchanged vs `playtest/latest` feel.
- Standalone Take pill gone during a normal fight.
- Thick cream arc under the wheel exterior; one click ends combat / takes net damage.
- Split ~1/3 | divider | ~2/3. Block==0 → left blank, divider kept. Block>0 → whitish-blue pip + number only (no "Block" word).
- Right side uses player-copy Take / Safe (no invented Spin copy). Net number = max(0, incoming − block).
- Move arrows closer to the wheel; spins counter rides with the left arrow; inner arrow edge top-aligned with Take arc top.
- No Block badge nest inside the wheel hole.
- Hotbar 2×5 reads larger (reclaimed Take-row height).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Face a monster with Block 0, incoming > 0 | Arc under wheel; left blank + divider; Take {n} + burst; no hub Block nest; no standalone Take pill; bigger hotbar | 01-block0-take.png |
| 02 | combat | Gain Block > 0 while facing (Breastplate / Shield), still incoming after soak | Left shows whitish-blue pip + block number; right Take net; divider present | 02-block-positive.png |
| 03 | combat | Same fight, Moves available | Cream move arrows sit closer to wheel; spins counter on left; inner edge meets Take arc top | 03-arrows-aligned.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each expect readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-h3-b2-take-arc/`
