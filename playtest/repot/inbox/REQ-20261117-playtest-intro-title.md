---
id: REQ-20261117-playtest-intro-title
status: open
priority: high
tip_sha: b028e2111bb3
branch: cursor/playtest-intro-title-rewrite-05d5
created: 2026-11-17T07:20:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest → wipe intro-seen (or fresh user://) → watch Nathan's playtest intro before the title
---

# Playtest intro matches new title screen

Rewrote Nathan's first-open playtest intro (shorter, 8 beats) and replaced the old Brand New / Middle Progress mock menu with a static with-save title screenshot.

## What to verify

- Intro still plays before the title; Skip / Back / Done still work.
- Beats are the new 8 lines (no Brand New / Middle Progress wording).
- Title beats show `assets/ui/title/intro_menu_preview.png` (Continue + trophy board + Start over; no Middle Progress).
- Caption under the still reads "Your progress, right on the title screen."
- F2 beat still opens the real Feedback panel.
- After Done/Skip, the living-trophy title appears (Continue when a save exists).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | intro | beat 04 (title still) | framed with-save title preview; Continue on top; caption under still | 01-intro-title-still.png |
| 02 | intro | beat 07 (F2) | Feedback / F2 panel visible with talk box | 02-intro-f2.png |
| 03 | title | after Done/Skip | live title screen (not the still) | 03-after-intro-title.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- No Brand New / Middle Progress text in the talk box or still.
- Skip and Back still work on a second pass.

## Outbox path

`playtest/repot/outbox/REQ-20261117-playtest-intro-title/`
