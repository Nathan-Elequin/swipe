---
id: REQ-20261104-intro-polish-slice-b
status: open
priority: high
pr: 376
tip_sha: pending
branch: playtest/latest
created: 2026-11-04T18:24:30Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New → intro p1–p3 → road approach/ambush
---

# Intro polish (Slice B)

Caption timing, F2 tip placement, intro p1–p3 copy tone, and post-tutorial arrive without full-screen Nib dialog.

## What to verify

- Approach / ambush captions auto-advance ~40% slower than before; click / Space still advances immediately.
- Playtest “Right-click… or F2…” tip sits top-left and does not overlap the bottom caption / dialog bar (hidden while cutscene, road, tutorial, or cabin dialog is up).
- Intro panels 1–3 use the updated narration (rain/loft, knock, Grumble) — same Pixel art panels.
- After tutorial Yes wrap (or Skip): pool-1 reveal → intro_p5 arrive splash → free cabin walk-in with **no** full-screen standard Nib dialog covering the room. Wrap lines stay on the small tutorial talk block.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | road | Brand New → through p3 → approach caption | A1 caption readable; F2 tip not on the caption bar | 01-approach-caption.png |
| 02 | road | ambush captions | A2 lines on ambush panel; tip not overlapping bar | 02-ambush-caption.png |
| 03 | intro | Brand New panel 1 | loft/rain narration; intro_p1 art unchanged | 03-intro-p1.png |
| 04 | cabin | finish Yes path or Skip → after arrive splash | free cabin exterior/interior; no full-screen Nib dialog veil | 04-arrive-free-cabin.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261104-intro-polish-slice-b/`
