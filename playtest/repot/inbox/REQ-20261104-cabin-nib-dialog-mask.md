---
id: REQ-20261104-cabin-nib-dialog-mask
status: open
priority: high
pr: 378
tip_sha: 88f856df
branch: playtest/latest
created: 2026-11-04T18:35:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Continue / Middle Progress → cabin → Trophy Hall (or any room) → trigger a Nib talk line
---

# Cabin Nib talk-box masked well redesign

Cabin-only Nib dialog bar forked from shared `dialog_bar` (intro stills unchanged). Locked layout 2026-11-04: box **1356×164** at **x=162, y=804** (DIALOG_SAFE_CABIN 72), original `ui/dialog_box_9.png` wood 9-slice at **12-native / 48px** margins, body font **51** (min ~34), max_lines 1–2. `BustClip` (`clip_contents`) insets on parchment; bust TextureRect 128² offset so torso crops at well bottom. Shoulders must not overlap the wood border. Never `clip_contents` on `_box` (nameplate hangs above). No z_index changes. Choices float above the shortened bar (no always-on choice-height reserve).

## What to verify

- Open cabin talk (Trophy Hall Nib line is a good freeze target).
- Bust shoulders sit inside the parchment well — they do **not** overlap the wood border.
- Torso reads as cropped / masked at the bottom of the portrait well.
- Box is ~20% larger than the prior deep-pop mock (~1356×164, centered).
- Original wood 9-slice look is preserved (not thinned to bubble margins).
- Body text is ~50% larger with less empty parchment.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | trophy hall (or cabin main) | Freeze on a Nib talk line with bust + body text visible | Shoulders clear of wood; torso masked in well; box ~1356×164; wood frame; larger body text / tight parchment | 01-nib-talk-masked-well.png |
| 02 | same | If a choice prompt is available, freeze with choice tags visible | Choice tags float above the box and remain clickable; box height still ~164 (no empty choice-row parchment) | 02-nib-talk-choices-float.png |

## Pass criteria

- Shots at 1680×1040 (or note if viewport differs).
- PASS = (a) bust shoulders do not overlap wood border, (b) torso reads as cropped/masked inside well, (c) box ~20% larger than prior deep-pop mock (~1356×164), (d) original wood 9-slice look preserved, (e) body text ~50% larger / less empty parchment.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Stamp fulfilled `tip_sha` to the tip HEAD used for the shot.
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261104-cabin-nib-dialog-mask/`
