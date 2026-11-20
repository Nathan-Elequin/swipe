---
id: REQ-20261120-carry3-b-ui
status: open
priority: high
pr: pending
tip_sha: pending
branch: cursor/carry-3-b-ui-622f
created: 2026-11-20T00:50:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Adventure / Continue → clear a dungeon with >3 items into Rope Exit
---

# Carry-3 B UI (bag + overlay + reminder)

Wire Pixel's layout B bag UI onto Carry-3 logic (PR #564). Cloud agent cannot F5 — local Cherry shoots these.

## What to verify

- ≤3 items: no room bag; portal walks through as before.
- >3 items: closed bag (`bag_idle` / hover) appears near the gate; badge shows packed count when >0.
- Click bag → fullscreen overlay; `mark_bag_opened_this_transition`; leave pool + 3 bag slots; click toggles membership.
- Delve unlocked at ≤3 packed (`delve_normal`); locked at >3 (`delve_locked_badged`).
- Esc / scrim closes overlay without committing portal; selection kept for this transition.
- First portal click without opening bag → reminder; Okay opens overlay; No, continue commits current (empty → carry 0) and delves.
- Packed ≤3 Delve commits and walks through portal.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope exit | clear with ≤3 items | no Carry-3 room bag | 01-no-bag-under-cap.png |
| 02 | rope exit | clear with ≥4 items, bag idle | bag_idle visible near gate; badge absent at 0 packed | 02-room-bag-idle.png |
| 03 | rope exit | hover bag | bag_hover | 03-room-bag-hover.png |
| 04 | overlay | open bag, pack 2 of 6 | keeping · 2 of 3; Delve READY; leave chips on pool | 04-overlay-ready-2.png |
| 05 | overlay | pack 4 | Delve locked badged; locked caption | 05-overlay-locked-4.png |
| 06 | reminder | portal without opening bag | dim + reminder panel + Open bag / No, continue | 06-reminder.png |

## Pass criteria

- All rows at 1680×1040.
- Nearest-filter art readable; no Tier/ATK in UI.
- RESULT.md marks each id pass/fail.

## Outbox path

`playtest/repot/outbox/REQ-20261120-carry3-b-ui/`
