---
id: REQ-20261117-title-intro-frame
status: open
priority: normal
branch: cursor/title-intro-frame-ce61
created: 2026-11-17T07:30:00Z
created_by: cloud-agent-intro-frame
viewport: 1680x1040
entry: F5 playtest hub → Brand New (or wipe intro flag) so playtest intro runs; advance to the title-focus beats
---

# Title intro preview frame still

Installs `assets/ui/title/intro/intro_frame.png` (200×124 living trophy room, text-free) as a nearest-scaled backdrop behind the intro SubViewport title preview (`preview_mode = true`), per `design/visual/SCREEN-title.md` §5.

## What to verify

- On intro title beats, the framed preview well shows the painted hall still behind / around the live title SubViewport.
- Caption and Next / Skip / Back controls still work; no "Tier" or "ATK" on that surface.
- Art has no composited Spinheritance / menu text.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | playtest intro | open intro, advance to first title-focus beat | frame ~1176×736; painted hall still visible; live title preview inside; caption under frame | 01-intro-title-beat.png |
| 02 | playtest intro | same beat, look at letterbox edges of the SubViewport | still peeks in any uncovered px of the 1168×728 well (not a flat void) | 02-intro-letterbox.png |

## Pass criteria

- Both shots at 1680×1040.
- Still is nearest-scaled trophy-room painting (five windows, lantern, blank plates), text-free.
- SubViewport title preview still present (`preview_mode`).

## Outbox path

`playtest/repot/outbox/REQ-20261117-title-intro-frame/`
