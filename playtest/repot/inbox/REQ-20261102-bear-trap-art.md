---
id: REQ-20261102-bear-trap-art
status: open
priority: normal
branch: cursor/bear-trap-art-e022
pr: 285
tip_sha: 68dcfe49
created: 2026-11-02T06:05:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New / Challenge (or Middle Progress) → fight with Bear Trap on the wheel
---

# Bear Trap art + snap callout

Wire unique Bear Trap wheel/facing PNGs and a one-shot jaws-snap overlay on the Attack callout.

## What to verify

- Bear Trap seat on the wheel shows the 24×24 trap art (open jaws), not a missing/generic fallback.
- Facing / callout idle shows the 48×48 open-jaws facing frame.
- When Bear Trap Attack fires (Spin/Move onto it), the callout plays snap f0→f3 once (~12 fps) over the portrait, then frees.
- Other monsters' callouts unchanged (no snap overlay).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Bear Trap seated on the wheel (from Kobold Trapper / deck) | wheel seat shows bear trap open jaws | 01-wheel-seat.png |
| 02 | fight | trigger Bear Trap Attack callout mid-snap (or settle frame) | callout portrait shows snap animation (shut jaws / flash), not a blank | 02-callout-snap.png |

## Pass criteria

- Both rows shot at 1680×1040 (or note if viewport differs).
- Wheel seat and callout clearly show Bear Trap art, not kobold / missing tex.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261102-bear-trap-art/`
