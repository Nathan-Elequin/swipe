# REQ-20261028-cabin-flip-167

Tip: `e3c959b5b9babe0c5de9c18c5634d45904ddde47` (`e3c959b5`)
#167 parent: `2b92c62e` Cabin flip + hall plate overlay
Branch: `playtest/latest`
Shots: `playtest/repot/outbox/REQ-20261028-cabin-flip-167/shots/` (1680×1040)

Room order live: loft → workshop → study → main → hall → mudroom.
RunDoor from main pans to hall (not Outpost). Hall SideDoor → mudroom. Mudroom BackDoor → hall.

## Per-id

| id | result | note |
| --- | --- | --- |
| 01-main-fireplace | PASS | Fireplace/Nib center; left door study; right door hall. RunDoor does not skip to Outpost. |
| 02-study | PASS | Left of main. |
| 03-workshop-ladder-left | PASS | Ladder on left after H-flip (`x=80`, `flip_h=true`). |
| 04-loft | PASS | Loft via ladder room. |
| 05-enter-hall | PASS | Right of main is trophy hall. |
| 06-hall-plate-clean | FAIL (critical) | Plate is on screen, no `case_*.png` overlay textures, ShelfPrev/Next/Gauge hidden. Chrome still visible: biome case titles, `?` / `POOL LOCKED` on locked cases, item-name labels + `trophy_mount` plaques in glass, yellow next-piece / S marks. |
| 07-hall-slot-hover | FAIL | Slot hover opened inspect (Counting Beads), not icon/glass only. No extra `case_*.png` ghost stack. |
| 08-outpost | PASS | Hall right door → Outpost. BackDoor returned to hall. |
| 09-map-in-hands | PASS | Space/wall path opened map-in-hands plate with hands. |
| 10-leave-door | PASS | Rightmost LeaveDoor (`x=1480`) on Outpost. |

**Counts:** 8 PASS / 2 FAIL. Critical fail: hall chrome (06).

## Overlay tree (hall)

Hit-only `Case_b1`…`Case_b5` Controls. No `case_*.png` TextureRects. Mounts still draw `trophy_mount.png` + FitLabelBox names.
