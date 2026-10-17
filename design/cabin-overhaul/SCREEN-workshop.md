# SCREEN: The Workshop (tutorial replay, stats, credits, ladder to the loft)

Room index 3, host x = 5040. Mock: `_pixel_extras/review/mocks/08_workshop.png`. Hotspots: `_pixel_extras/review/room_workshop_hotspots_2x.png`.

"Loadout/prep" in this pass means the **gear rack is cosmetic** (it lives in the main room by the door, so the hero dresses on the way out). The workshop holds prep-adjacent objects instead:
- the dummy (practice = tutorial),
- the Brag-o-Meter (your record),
- Patents Pending (credits).

A real pre-run loadout does not exist in the game (audit §3, "Loadout / pre-run kit picker: NOT PRESENT"). **Nathan decided (decision 1): the gear rack is cosmetic only.** It never affects a run. The practice dummy here always offers the tutorial, even after the player declined Nib's offer (decision 2).

## Node tree
```
RoomWorkshop (Control, at host x 5040)     scripts/cabin/room_workshop.gd
├── Bg          rooms/room_workshop.png
├── Glow        rooms/room_workshop_glow.png (lamp; flicker 0.9↔1.0, 0.9 s)
├── Dummy       cabin_hotspot props/dummy.png (+ props/dummy_tilt_l.png / props/dummy_tilt_r.png)
├── BragOMeter  cabin_hotspot props/bragometer.png
│   └── BragGear AnimatedSprite2D props/brag_gear_f0..f3 @ 120 ms loop (speeds to 60 ms on hover)
├── Patents     cabin_hotspot props/patents.png
├── Ladder      cabin_hotspot doors/ladder_locked.png | doors/ladder_open.png (hover doors/ladder_hover.png at origin-(1,0))
├── SignLoft    doors/door_sign_loft.png
├── BackDoor    cabin_hotspot (doorway baked; hover doors/doorway_hover.png) → Study
└── Card        (shared parchment card: dialog_box 9-slice 200x150 native centred, for Brag / Patents)
```

## Placements and hotspots
| node | file | native rect (x,y,w,h) | 4x rect | hotspot native | hotspot 4x | hover file | z | note |
|---|---|---|---|---|---|---|---|---|
| room_workshop_glow | `rooms/room_workshop_glow.png` | (40,20,130,201) | (160,80,520,804) | - | - | - | 1 | light overlay |
| BackDoor | `None` | (6,132,32,63) | (24,528,128,252) | (2,126,40,69) | (8,504,160,276) | `doors/doorway_hover.png` | 2 | back |
| Ladder | `doors/ladder_locked.png` | (370,0,30,197) | (1480,0,120,788) | (369,0,32,197) | (1476,0,128,788) | `doors/ladder_hover.png` | 2 | to loft |
| SignLoft | `doors/door_sign_loft.png` | (348,120,18,14) | (1392,480,72,56) | - | - | - | 2 |  |
| Dummy | `props/dummy.png` | (48,150,32,50) | (192,600,128,200) | (48,150,32,50) | (192,600,128,200) | `props/dummy_hover.png` | 3 | training dummy: replay the How-to-Play tutorial |
| BragOMeter | `props/bragometer.png` | (186,112,48,46) | (744,448,192,184) | (186,112,48,46) | (744,448,192,184) | `props/bragometer_hover.png` | 3 | Brag-o-Meter: run stats (opens a parchment card) |
| BragGear | `props/brag_gear_f0.png` | (220,116,12,12) | (880,464,48,48) | - | - | - | 4 |  |
| Patents | `props/patents.png` | (290,36,54,42) | (1160,144,216,168) | (290,36,54,42) | (1160,144,216,168) | `props/patents_hover.png` | 3 | framed patents: credits |

| Hotspot | Hover | Click |
|---|---|---|
| Dummy | `cabin.hot.dummy` | Wobble: idle → tilt_l → tilt_r → tilt_l → idle @ 70 ms, cue `cabin.dummy`. Then the Nib dialog `cabin.dummy.ask` with choices `cabin.dummy.yes` → `tutorial_wanted`, and `cabin.dummy.no` → close. |
| BragOMeter | `cabin.hot.brag` | Card titled `cabin.brag.title` with lines `cabin.brag.delves` (`counters.delves`), `cabin.brag.homecomings` (`counters.hauls`), `cabin.brag.deepest` (`deepest_belly`), `cabin.brag.swiped` (`cabinet_progress`), `cabin.brag.met` (`met_monsters` / 35). Close tag `cabin.brag.close`. Cue `cabin.brag`. |
| Patents | `cabin.hot.patents` | Card `cabin.credits.title` + `cabin.credits.body` (multi-line). Close tag `cabin.credits.close`. Cue `cabin.scroll`. |
| Ladder | locked `cabin.hot.door_locked` / open `cabin.hot.door_loft` | Locked: `cabin.locked`. Open: pan to the loft (index 4); the toast reads `cabin.room.loft`. |
| BackDoor | `cabin.hot.back` | Pan to the study |

Card: `ui/dialog_box_9.png` NinePatchRect 200x150 native (800x600) centred at (110,55) native, over `ui/overlay_vignette.png`. Labels 30 px at 4x. Close = `ui/choice_tag_*` 80x16 at card bottom centre. Open Tween: scale 0.9→1, 0.15 s BACK OUT.

Note on the cabin "brag" stats: `delves` counts runs started from the map (Main `_start_route`); tutorial runs do not count.

## Copy and cues
**Copy:** `cabin.room.workshop`, `cabin.hot.dummy`, `cabin.hot.brag`, `cabin.hot.patents`, `cabin.hot.back`, `cabin.hot.door_locked`, `cabin.hot.door_loft`, `cabin.dummy.ask`, `cabin.dummy.yes`, `cabin.dummy.no`, `cabin.brag.title`, `cabin.brag.delves`, `cabin.brag.homecomings`, `cabin.brag.deepest`, `cabin.brag.swiped`, `cabin.brag.met`, `cabin.brag.close`, `cabin.credits.title`, `cabin.credits.body`, `cabin.credits.close`, `cabin.locked`

**Cues:** `cabin.hover`, `cabin.click`, `cabin.dummy`, `cabin.brag`, `cabin.scroll`, `cabin.pan`, `cabin.locked`, `speech.nib`

## Code hooks
`_start_tutorial` (11157) through `tutorial_wanted`; `_tut_finished` (11217) sets `tutorial_done` and returns to `show_menu("workshop")` (the room the player left from, saved as `return_room`).
