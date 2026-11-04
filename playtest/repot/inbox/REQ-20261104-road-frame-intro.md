---
id: REQ-20261104-road-frame-intro
status: open
priority: high
branch: cursor/road-frame-intro-fa3e
created: 2026-11-04T07:45:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New
---

# Road-frame intro hook (PR1)

Brand New now runs intro p1–p3, then approach (intro_p4) → ambush (intro_ambush) → Yes/Skip overlay before any Nib tutorial line. Yes starts the existing tip tutorial; Skip (and mid-tutorial Skip) goes pool-1 reveal → intro_p5 arrive → free cabin walk-in (cabin_exterior).

## What to verify

- After intro p3, approach panel uses `intro_p4.png` with caption "Nib walks you home…"
- Ambush switches to `intro_ambush.png` (Pixel #363), then captions, then overlay title exactly "Go through the tutorial with Nib?" with Yes / Skip — no Nib portrait/VO
- Yes starts the current tip tutorial; corner Skip is always available during it
- Skip from overlay or mid-tutorial: pool-1 reveal → intro_p5 arrive splash → free cabin; run door does not nag "Show me how"
- Dummy still offers tip replay after arrive
- Live cabin BG after arrive is `cabin_exterior.png`, not the cutscene panel

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | road | Brand New → through p3 → approach | intro_p4 walk-home panel + A1 caption | 01-approach-p4.png |
| 02 | road | after approach auto/advance | intro_ambush.png ambush panel + A2 caption | 02-ambush.png |
| 03 | road | after A2 | overlay title + Yes/Skip, no Nib bust | 03-overlay-o1.png |
| 04 | cabin | Skip path → after reveal+arrive | free cabin interior; exterior walk-in used cabin_exterior | 04-arrive-cabin.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Ambush shot shows Pixel Crypt Classic `intro_ambush.png`, not intro_p4.
- Overlay has no Nib portrait.

## Outbox path

`playtest/repot/outbox/REQ-20261104-road-frame-intro/`
