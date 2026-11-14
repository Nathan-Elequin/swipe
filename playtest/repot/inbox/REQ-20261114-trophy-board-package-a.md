---
id: REQ-20261114-trophy-board-package-a
status: done
branch: cursor/trophy-board-package-a-ca3c
tip_sha: 654e6678
priority: high
created_by: cloud-agent
viewport: 1680x1040
note: Branch tip includes Package B TrophyBoard (rebuild_board); Package A removes cabinets / progress menu / mudroom.
entry: cabin exterior → door → hall (or main if hall locked)
created: 2026-11-14
agent: cloud
---

# Package A — Outpost / cabinets / progress menu removed

Cloud agent cannot F5. Local Cursor: verify on this branch tip.

## Screenshots required

| id | setup | filename |
|----|-------|----------|
| main-no-run-door | Cabin main room after first return unlock | main_no_run_door.png |
| hall-board | Trophy hall with Package B TrophyBoard (carousel), no cabinets, no right Outpost door | hall_trophyboard.png |
| exterior-arrive | Run end → exterior walk-in (Leave with haul) | exterior_arrive.png |

## Pass criteria

1. Main room has no clickable centre “Toward the Outpost” door hotspot.
2. Hall shows room_trophy plate + live TrophyBoard carousel; no five cabinets; no Outpost door hotspot.
3. Run end (Leave) lands at cabin exterior; clicking door enters hall (or main if hall locked).
4. No crash / missing resource warnings for deleted mudroom, cabinets_wall, progress_menu paths.
