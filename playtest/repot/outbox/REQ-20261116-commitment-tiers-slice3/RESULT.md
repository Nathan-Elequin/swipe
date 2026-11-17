---
id: REQ-20261116-commitment-tiers-slice3
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-17T00:45:00-06:00
machine: Cherry
tip_sha: bb1d1af9
godot: F5 playtest (headed), no DevChrome shortcuts
---

# Result

Real path: wiped `user://` (backup `_repot_backup_20261116_slice3`), F5, skip intro, pick Quick, Brand New, skip tutorial, launch Verdant Hollow, Give up after homecoming started, offramp opened. Nathan's save restored after the shoot.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Headed cabin overlay: "You finished your first run!", 1–5, four prompts, Anything else, Skip / Send / Keep playing / Go deeper / I'm done for now. `offramp_shown_quick` stamped true on show. |
| 02 | fail | Not shot on this pass. Assigned path was Quick only (no DevChrome). Deeper Crystal Cavern header still the old Xvfb plate. |
| 03 | pass | Thank-you card + Shadow Abyss carrot + Keep playing. Cabin behind it. |
| extra | pass | Rating 4 + typed "repot slice3 m test space here" (spaces and m landed). F2 did not open Feedback. Send posted (`feedback_sent_quick`); inline "Sent. Thank you." — the full thanks card is **I'm done for now**, not Send. Keep playing returned to cabin. Reload Continue: `should_offramp(quick)==false`, panel stayed closed. |

## Blockers

Computer-use on the desktop was aborted (SNAP overlay). Play was driven from godot-mcp: real F5 viewport shots at 1680×1040, button/keyboard injection, no Ctrl+Shift commitment cheats.

## Shots

- `shots/01-offramp-quick.png` (replaced cloud plate)
- `shots/02-offramp-deeper.png` (still Xvfb; not Cherry)
- `shots/03-offramp-thanks.png` (replaced cloud plate)
- `shots/04-offramp-typed.png` (rating + typed text)
- `shots/05-keep-playing-cabin.png`
- `shots/06-reload-no-reask.png`
