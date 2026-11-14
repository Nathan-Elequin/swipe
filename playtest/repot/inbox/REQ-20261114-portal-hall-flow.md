---
id: REQ-20261114-portal-hall-flow
status: done
priority: high
branch: cursor/portal-hall-flow-8d6a
created: 2026-11-14T06:00:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → trophy hall with 5 Verdant lights ready → pull lever
---

# Portal hall flow — black screen, music, Nib, dais

Cloud ship for the A10 black-screen fix plus splash music, dev-strip hide, Nib scale/floor, BoardDais, and Nib pointer/pulse ring. Local Cherry must verify in Godot (no godot-mcp here).

## What to verify

- After lever → rumble → Crystal Cavern splash dismiss, the screen is the trophy hall (not black). Lever spent/down, five lights lit, board visible.
- Nib says: "Hear that rumble? Something down there just woke up."
- Splash starts Crystal Cavern music (~1.5s fade); dismiss crossfades cabin music (~1s).
- No Play Latest / Developer Test / Roster / Script strip in hall/cabin/Rope Exit/return.
- Nib ~1.5× larger, feet on floor under raised board; BoardDais node under the board.
- First-light / lever / hover-to-learn gestures show tutorial pointer + pulse ring; both clear when the line advances.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | After portal splash dismiss (5 lights banked, lever pulled) | Hall visible, no black ColorRect; board + 5 lights; lever down | 01-hall-after-splash.png |
| 02 | hall | Same beat, Nib talk up | Nib line about rumble; Nib ~1.5×; feet on floor/dais under raised board | 02-nib-rumble-line.png |
| 03 | hall | First-light or lever-ready gesture | Pointer from talk bar + pulse ring on target | 03-nib-pointer-ring.png |
| 04 | hall | Idle trophy hall | No Developer Test strip top-left; BoardDais under board | 04-hall-no-strip-dais.png |

## Pass criteria

- All rows 1680×1040.
- 01 must not be a black frame (A10 regression).
- Nib rumble copy matches Pixel's line verbatim.
- RESULT.md pass/fail per id.

## Outbox path

`playtest/repot/outbox/REQ-20261114-portal-hall-flow/`
