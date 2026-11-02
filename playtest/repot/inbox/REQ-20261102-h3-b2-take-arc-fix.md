---
id: REQ-20261102-h3-b2-take-arc-fix
status: open
priority: high
pr: 298
tip_sha: 7dab8652
branch: cursor/hub-b2-take-arc-fix-9d33
created: 2026-11-02T17:40:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue into a fight with Moves (Adventure). Prefer a fight where Undo is available and Block can go > 0 (Shield / Breastplate).
---

# H3-B2 Take arc layout fix (Doop match)

Tip `playtest/latest` after PR #293 shipped a broken Hub B2: Safe read as a tan pill over the wheel hole, Block floated on the right, move-arrow tips overlapped the gold rim, Undo sat under the control. This branch flips the arc sweep to visual left→right, pulls arrows out just enough to clear the rim while staying closer than pre-B2, and keeps Undo clear of the arc.

## What to verify

- Thick cream **split arc under the wheel exterior** (not a standalone pill, not inside the hub hole).
- Vertical divider: left ~1/3 Block pip only (blank when Block==0; whitish-blue pip + number when Block>0; no "Block" word). Right ~2/3 Take {n}+burst or Safe — content centered in that side.
- One click on the whole arc takes net damage / ends the beat.
- No Block badge nest in the wheel hole; no floating Block off to the right of the wheel.
- Move arrows closer than pre-B2 but **tips clear of the gold rim**; spins counter rides the left arrow and stays readable (not covered by the Take arc).
- When Undo is shown, it is visible and clickable (not under the arc).
- Hotbar stays the bigger 2×5; wheel + Sprout size/position unchanged.
- Safe (net 0) still uses the split-arc chrome (blank-or-pip | divider | Safe), not a floating tan pill.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Face a monster, Block 0, incoming > 0 | Arc under wheel; left blank + divider; Take {n} + damage icon on the right; no hub Block nest; no standalone Take pill | 01-block0-take.png |
| 02 | combat | Gain Block > 0 (Shield / Breastplate), still incoming after soak | Left third shows whitish-blue pip + block number; right shows Take net; divider present; Block not floating right of wheel | 02-block-positive-left.png |
| 03 | combat | Same fight, Moves available | Arrow tips clear of gold rim; spins counter on left arrow readable; arrows still closer than old outer pad | 03-arrows-clear-rim.png |
| 04 | combat | After an undoable action (use an item), Undo visible | Undo fully visible/clickable below or beside the arc — not covered by Safe/Take chrome | 04-undo-clear.png |
| 05 | combat | Block ≥ incoming so net Take is 0 (Safe) | Split-arc chrome still present (left blank-or-pip \| divider \| Safe on the right); no tan pill over the wheel hole | 05-safe-split-arc.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each expect readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-h3-b2-take-arc-fix/`
