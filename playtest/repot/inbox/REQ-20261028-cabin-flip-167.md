---
id: REQ-20261028-cabin-flip-167
status: done
priority: high
pr: 167
tip_sha: 2b92c62e
branch: playtest/latest
created: 2026-10-28T15:00:00-05:00
created_by: pixel
viewport: 1680x1040
entry: F5 playtest hub → Continue or Middle Progress → cabin main (fireplace / Nib)
---

# Cabin flip + hall plate-only (#167)

Verify PR #167 on `playtest/latest`: trophy-hall double-draw removed; cabin walk graph flipped (fireplace center; left study→workshop→loft; right hall→Outpost→dungeon exit).

## What to verify

- Hall shows Doop `cabinets_wall` plate only — BiomeCabinets overlays are hit-only (slot icons ok); no second case frames, case name labels, or “? pool locked” text; shelf arrows + gauge chrome hidden.
- From main: left door → study → workshop → loft (ladder on the **left** of workshop after H-flip).
- From main: right path → trophy hall → Outpost (mudroom) → rightmost LeaveDoor and/or Space / wall map opens map-in-hands / delve path — player must walk through hall cabinets en route to Outpost (run door on main must **not** skip straight to delve).
- Outpost still named Outpost in chrome if shown; internal id may stay mudroom.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | main | Spawn at fireplace | Fireplace/Nib center; left door toward study; right SideDoor toward hall; painted RunDoor visible but does not skip to Outpost | 01-main-fireplace.png |
| 02 | study | From main, take left door | Study room; doors oriented for chain toward workshop (H-flip ok) | 02-study.png |
| 03 | workshop | From study, continue left chain | Ladder / loft access on the **left** side of the room | 03-workshop-ladder-left.png |
| 04 | loft | Climb ladder | Loft reachable; hatch back down works | 04-loft.png |
| 05 | main | Return to main, take right SideDoor (or RunDoor if it only starts hall path) | Enter trophy hall | 05-enter-hall.png |
| 06 | hall | Full hall view, no hover | Five open-frame cases from Doop plate; **no** overlapping case_*.png frames; **no** case title labels; **no** “? pool locked”; **no** shelf arrows / gauge bar | 06-hall-plate-clean.png |
| 07 | hall | Hover / focus one case slot if icons present | Slot icon or empty glass only — still no ghost frame stack | 07-hall-slot-hover.png |
| 08 | mudroom/Outpost | From hall, take right SideDoor | Outpost/loadout room; back door returns to hall | 08-outpost.png |
| 09 | mudroom/Outpost | Press Space **or** click wall map hotspot | Map-in-hands / held map overlay opens (diegetic) | 09-map-in-hands.png |
| 10 | mudroom/Outpost | Rightmost LeaveDoor | Leave-cabin / delve exit path starts (or confirm hotspot works) | 10-leave-door.png |

## Pass criteria

- All ten PNGs present under `playtest/repot/outbox/REQ-20261028-cabin-flip-167/shots/`.
- `06-hall-plate-clean.png` is the critical shot — fail the request if double-draw or chrome returns.
- Walk order matches: loft←workshop←study←main→hall→Outpost→exit.
- Tip SHA in RESULT.md is `playtest/latest` at shoot time (note if newer than `2b92c62e`).

## Outbox path

`playtest/repot/outbox/REQ-20261028-cabin-flip-167/`
