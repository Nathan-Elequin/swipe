# Alcove textures for the current hub (HUB_R 58)

Drop-in replacements for `assets/ui/wheel/`. Use them in fix W2 of FIXES-v2.md. Original art for Swipe; no third-party source.

- Each is 232×248 and shows the **top** alcove (seat 0) of an 8-seat wheel: an annular wedge from **r 58** (the current `HUB_R`) to r 300, ±22.5°, with a 4 px rim.
- The pivot is the wheel centre at (116, 300): `position = (-116, -300)` under the alcove root, `pivot_offset = (116, 300)`, `size = (232, 248)`, `rotation_degrees = 45·i`.

| File | Fill | Rim | Use |
|---|---|---|---|
| `ui_wheel_alcove_full_weak.png` | `#6A3E24` (UX.metal_wedge 1) | `#C08050` (METAL_BRONZE) | seated Weak monster |
| `ui_wheel_alcove_full_tough.png` | `#4A5560` (metal_wedge 2) | `#C5CDD8` (METAL_SILVER) | seated Tough monster |
| `ui_wheel_alcove_full_deadly.png` | `#6E5418` (metal_wedge 3) | `#E8C36A` (METAL_GOLD) | seated Deadly monster |
| `ui_wheel_alcove_full.png` | same as full_weak | | fallback only |
| `ui_wheel_alcove_empty.png` | `#120C09` | `#7A4E2B`, dashed | empty seat |
| `ui_wheel_alcove_valid.png` | `#2A1C10` | `#7A4E2B`, dashed | placement: empty and clickable |
| `ui_wheel_alcove_hover.png` | `#4A3416` | `#FFD84A` | placement: hovered empty seat |

The tier colour comes from the texture itself, so for seated monsters `modulate` is only used for alpha (fight dim, placement pulse) and the existing facing lighten.
