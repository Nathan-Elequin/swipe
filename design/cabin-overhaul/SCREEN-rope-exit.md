# SCREEN: Rope exit (re-skin of the Challenge `rest` phase)

Mock: `_pixel_extras/review/mocks/10_rope_exit.png`. GIFs: `rope_ladder_sway.gif`, `hero_climb.gif`.

This replaces the rest parchment (`overlay_continue` / `overlay_leave`). It appears when `_enter_dungeon_clear` (1695) sets `phase = "rest"` for Challenge and Quick Start. `_sync_overlay` (10817) hides `overlay` and calls `rope_exit.open(dungeons_cleared)`.

The script is `scripts/cabin/rope_exit.gd` (Control, full rect, **z 80**, the slot the overlay used). It is a child of Main, built in `_build_ui` next to `overlay`. It is **not** inside CabinRoot, because the cabin is hidden during runs. `PROCESS_MODE_ALWAYS` is not needed (the tree is not paused in rest).

## Node tree
```
RopeExit (Control, full rect, z 80, mouse STOP)
├── Bg          TextureRect overlays/rope_exit_bg.png (opaque, full screen)
├── Torch       AnimatedSprite2D overlays/torch_flame_f0..f2 @ 120 ms at native (384,92)
├── Ladder      AnimatedSprite2D overlays/rope_ladder_f0..f2 (0-1-2-1 @ 220 ms) at native (96,0) + hotspot
├── LadderHover TextureRect overlays/rope_ladder_hover.png (same origin, shown on hover)
├── Hole        TextureRect overlays/deeper_hole_idle.png | deeper_hole_glow_f0..f1 (500 ms) | deeper_hole_hover.png at native (250,214) + hotspot
├── Hero        Sprite2D hero/hero_idle_loot_f0..f1 at native (170,200) (facing right; blink f1 every 3 s)
├── SignLabel   Label rope.sign over the baked sign at native (20,120,57,31), 20 px, cream, autowrap
├── Headline    Label rope.cleared ({n} = dungeons_cleared), centred x 840, y 14*4, 44 px
├── Sub         Label rope.sub, centred, y 30*4, 24 px muted
├── ClimbLabel  Label rope.climb under the ladder, centred at native x 116, y 226; hover sub rope.climb_sub
├── DeeperLabel Label rope.deeper centred at native (298,200); hover sub rope.deeper_sub ({n} = dungeons_cleared + 1)
└── PeekTag     choice tag ui/choice_tag_* 84x16 native at (320,14): rope.peek → SackPeek (SCREEN-sack-peek)
```

## Placements and hotspots
| node | file | native rect (x,y,w,h) | 4x rect | hotspot native | hotspot 4x | hover file | z | note |
|---|---|---|---|---|---|---|---|---|
| RopeLadder | `overlays/rope_ladder_f0.png` | (96,0,40,226) | (384,0,160,904) | (92,0,48,226) | (368,0,192,904) | `overlays/rope_ladder_hover.png` | 3 | climb = _adventure_leave() |
| DeeperHole | `overlays/deeper_hole_idle.png` | (250,214,96,40) | (1000,856,384,160) | (250,214,96,40) | (1000,856,384,160) | `overlays/deeper_hole_hover.png` | 3 | jump = _adventure_continue() |
| Hero | `hero/hero_idle_loot_f0.png` | (170,200,32,32) | (680,800,128,128) | - | - | - | 4 |  |
| Sign | `None` | (20,120,57,31) | (80,480,228,124) | - | - | - | 0 | Label rope.sign drawn on the blank sign |

| Hotspot | Hover | Click |
|---|---|---|
| Ladder (92,0,48,226) | Show LadderHover, the ladder sways faster (110 ms), `rope.climb_sub` under ClimbLabel. Cue `cabin.hover`; `amb.rope_creak` loop while hovered. | **Climb home** (below) |
| Hole (250,214,96,40) | `overlays/deeper_hole_hover.png`, `rope.deeper_sub` | **Delve deeper** (below) |
| PeekTag | tag hover | Open the sack peek |

- Keyboard: `ui_left` = select Ladder, `ui_right` = select Hole, `ui_accept` = confirm. Escape opens pause as usual (pause shows Give up and Peek).
- Open: Bg fades in 0.3 s from the board, cue `amb.rope_creak` (loop, Ambience bus).

**Climb home:**
1. The hero walks (existing `hero_walk_loot`) to (100,200) over 0.5 s.
2. `hero/hero_climb_f0..f1` @ 160 ms while a Tween moves position.y from 200 to −40 over 1.6 s. Cue `cabin.rope_climb` every 0.32 s.
3. Fade to black 0.3 s.
4. `_adventure_leave()` (1717), unchanged: it swipes the hand, then `_open_home_cabin(true)` → win homecoming.

**Delve deeper** (`rope.deeper`):
1. The hero walks to (282,198) over 0.45 s.
2. A hop: Tween y −10 then +40, scale 1→0.6, modulate.a →0, over 0.5 s. Cue `cabin.hole_rumble`.
3. `_adventure_continue()` (1825), unchanged (bucket reveal, hall wipe, next belly).
4. `home_cabin.note_belly(dungeon_index + 1)`.

Both paths: `amb.rope_creak` stops, RopeExit hides.

## Copy and cues
**Copy:** `rope.sign`, `rope.cleared`, `rope.sub`, `rope.climb`, `rope.climb_sub`, `rope.deeper`, `rope.deeper_sub`, `rope.peek`

**Cues:** `amb.rope_creak`, `cabin.hover`, `cabin.click`, `cabin.rope_climb`, `cabin.hole_rumble`

## Code hooks
`_enter_dungeon_clear` (1695/1712), `_sync_overlay` (10817), `_adventure_leave` (1717), `_adventure_continue` (1825), `note_belly`. `title.rest`, `title.rest_sub`, `title.continue` and `title.leave` are no longer shown (flag to Jam).
