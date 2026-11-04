---
id: REQ-20261104-intro-ambush-panel
status: open
priority: normal
branch: playtest/latest
created: 2026-11-04T02:40:00-05:00
created_by: cursor-cloud
viewport: 1680x1040
entry: Brand New / first-run intro cutscene (or any path that plays the intro panels)
---

# Intro ambush cutscene panel

Art-only: new `assets/dungeon/home/cutscenes/intro_ambush.png` (1280×720 Crypt Classic). Does not replace `intro_p4.png` or `intro_p5.png`. Spin wires the path; until then this file just needs to import cleanly.

## What to verify

- PNG imports in Godot with Nearest / lossless (same as sibling cutscenes).
- File exists at `res://assets/dungeon/home/cutscenes/intro_ambush.png`.
- When Spin’s tutorial path is live, the ambush panel shows this art (not a missing-texture fallback).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | intro cutscene | Brand New → watch through to ambush panel (or load texture in inspector if intro path not wired yet) | panel reads as the ambush scene; no pink missing texture; sharp nearest pixels | 01-intro-ambush.png |

## Pass criteria

- Shot at 1680×1040 (or note if viewport differs).
- `01` shows the new panel art, not a broken import.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261104-intro-ambush-panel/`
