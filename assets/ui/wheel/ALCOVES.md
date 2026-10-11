# Wheel alcove textures (Direction A, palette A)

Original art, made from scratch for Swipe (no third-party source). Drawn on the 4× art grid (1 art px = 4 screen px), then exported pre-scaled to 232×216, so a TextureRect shows them at scale 1.

Each file is the **top alcove (seat 0)**: an annular wedge, r 96–300, spanning −112.5° to −67.5°, with a 4 px inner stroke.

| File | State | Fill | Stroke |
|---|---|---|---|
| `ui_wheel_alcove_empty.png` | empty seat | empty `#120C09` | edge `#7A4E2B`, dashed |
| `ui_wheel_alcove_full.png` | occupied / taken | seat-wood `#5A3A22` | edge `#7A4E2B` |
| `ui_wheel_alcove_facing.png` | facing the player (fight) | edge `#7A4E2B` | gold `#FFD84A` |
| `ui_wheel_alcove_hover.png` | seat hover (ready) / hovered empty (placement) | `#4A3416` | gold `#FFD84A` |
| `ui_wheel_alcove_valid.png` | placement: empty and clickable (SCREEN-placement) | `#2A1C10` | edge `#7A4E2B`, dashed |

## Placement in wheel_hud.tscn
- For each seat i (0 = top, clockwise), put the TextureRect at `position = wheel_centre - Vector2(116, 300)` (that's (432, 50) with the locked centre (548, 350)), set `pivot_offset = Vector2(116, 300)` and `rotation_degrees = 45 * i`. Parent it under the rotating wheel root.
- Fight dimming (the other 7 at 45 %) is `modulate.a = 0.45`. No separate texture.
- Placement pulse: tween `modulate` on the `valid` alcoves (0.9 s). The gold "+" is a Silkscreen 30 label at the seat point, not part of the texture.
- Draw the rim ring (r 306, 8 px edge) and the hub (r 96) on top, as before.
- Nearest filter. At 45°, 135°, etc. the texture is rotated off the pixel grid, so those diagonal edges step a little. If that reads badly, use the `_draw()` polygon option from SCREEN-wheel.md with these same colours.
