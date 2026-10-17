# SCREEN: The Loft (quit, telescope, letters, cat)

Room index 4, host x = 6720. Mock: `_pixel_extras/review/mocks/09_loft_bed_quit.png`. Hotspots: `_pixel_extras/review/room_loft_hotspots_2x.png`.

## Node tree
```
RoomLoft (Control, at host x 6720)         scripts/cabin/room_loft.gd
├── Bg          rooms/room_loft.png
├── Moon        rooms/room_loft_moon.png (moonlight shaft; alpha Tween 0.85↔1.0, 3 s)
├── CandleGlow  rooms/room_loft_candle_glow.png
├── Flame0      props/candle_flame_f0..f2 @ 140 ms
├── Bed         cabin_hotspot props/bed.png
├── Telescope   cabin_hotspot props/telescope.png
├── Trunk       cabin_hotspot props/trunk.png | props/trunk_open.png
├── Cat         cabin_hotspot AnimatedSprite2D props/cat_sleep_f0..f1 @ 900 ms
├── Hatch       cabin_hotspot (hatch baked in bg; hover doors/hatch_hover.png at hatch-(1,1)) → Workshop
└── LetterCard  (dialog_box 9-slice 220x170 native, centred) for letters
```

## Placements and hotspots
| node | file | native rect (x,y,w,h) | 4x rect | hotspot native | hotspot 4x | hover file | z | note |
|---|---|---|---|---|---|---|---|---|
| room_loft_moon | `rooms/room_loft_moon.png` | (152,40,129,191) | (608,160,516,764) | - | - | - | 1 | light overlay |
| room_loft_candle_glow | `rooms/room_loft_candle_glow.png` | (340,120,80,91) | (1360,480,320,364) | - | - | - | 1 | light overlay |
| Hatch | `None` | (14,200,48,16) | (56,800,192,64) | (13,199,50,18) | (52,796,200,72) | `doors/hatch_hover.png` | 2 | back down |
| Bed | `props/bed.png` | (290,166,96,40) | (1160,664,384,160) | (290,166,96,40) | (1160,664,384,160) | `props/bed_hover.png` | 3 | Grandpa's bed: Quit (desktop) / flavour line (web) |
| Telescope | `props/telescope.png` | (226,104,36,94) | (904,416,144,376) | (226,104,36,94) | (904,416,144,376) | `props/telescope_hover.png` | 3 | telescope at the round window: peek at Grumblegut (flavour + deepest belly) |
| Trunk | `props/trunk.png` | (96,184,42,28) | (384,736,168,112) | (96,184,42,28) | (384,736,168,112) | `props/trunk_hover.png` | 3 | trunk of letters: read unlocked letters (milestones) |
| Cat | `props/cat_sleep_f0.png` | (176,196,20,12) | (704,784,80,48) | (176,196,20,12) | (704,784,80,48) | - | 3 | click = purr + Zz (no hover art: cursor change only) |
| Flame0 | `props/candle_flame_f0.png` | (400,152,6,9) | (1600,608,24,36) | - | - | - | 4 |  |

| Hotspot | Hover | Click |
|---|---|---|
| Bed | `cabin.hot.bed` | **Desktop:** Nib dialog `cabin.bed.ask` with choices `cabin.bed.yes` → `quit_wanted` (Main calls `get_tree().quit()`, as `_btn_quit` does) and `cabin.bed.no`. **Web** (`OS.has_feature("web")`): Nib says `cabin.bed.web` and nothing quits. Cue `cabin.bed`. |
| Telescope | `cabin.hot.telescope` | Nib line `cabin.telescope.line` (`{n}` = `deepest_belly`), or `cabin.telescope.none` when 0. Cue `cabin.telescope`. |
| Trunk | `cabin.hot.trunk` | Lid opens (`props/trunk_open.png`, cue `cabin.trunk`). No letters unlocked: Nib line `cabin.trunk.empty`. Else the LetterCard opens with the newest unread letter (`lore.json` `letters[].title` / `.body`). Wheel / arrows page through the unlocked ones. Locked ones show `cabin.trunk.sealed`. Close tag `cabin.trunk.close`. Opening a letter adds its id to `letters_read`. |
| Cat | `cabin.hot.cat` | Line `cabin.cat.line` (Nib-less small bubble), existing cue `cabin.cat` + `amb.cat_purr` loop for 3 s. |
| Hatch | `cabin.hot.hatch` | Pan to the workshop |

- The trunk hover uses `props/trunk_open_hover.png` while it is open.
- A trunk with an unread unlocked letter pulses a `fx/new_tag.png` on its lid at trunk origin + (30,-2).
- The loft is reached only via the workshop ladder. `ui_right` in the loft does nothing (`_bump()`).

## Copy and cues
**Copy:** `cabin.room.loft`, `cabin.hot.bed`, `cabin.hot.telescope`, `cabin.hot.trunk`, `cabin.hot.cat`, `cabin.hot.hatch`, `cabin.bed.ask`, `cabin.bed.yes`, `cabin.bed.no`, `cabin.bed.web`, `cabin.telescope.line`, `cabin.telescope.none`, `cabin.trunk.empty`, `cabin.trunk.sealed`, `cabin.trunk.close`, `cabin.cat.line`

**Cues:** `cabin.hover`, `cabin.click`, `cabin.bed`, `cabin.telescope`, `cabin.trunk`, `cabin.cat`, `amb.cat_purr`, `cabin.scroll`, `cabin.pan`

## Code hooks
Quit = the same `get_tree().quit()` that `settings_menu.gd` `_btn_quit` uses, hidden behind the `OS.has_feature("web")` check (line 96 pattern). `lore.json` `letters` unlock at `unlock_pct` 25/50/75/100 of `cabinet_progress()`.
