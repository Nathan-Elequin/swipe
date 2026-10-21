# Intent plate placeholders

PixelLab final art is not in yet. These flat-palette PNGs keep layout and timing wired. Overwrite the same paths; loaders use `res://assets/ui/anim/...` by path.

| File | Native | Frames | Notes |
|---|---|---|---|
| `intent_claw_idle.png` | 16×16 | 1 | Dark-red badge + three claw rakes; empty centre for the number |
| `intent_claw_lit_f0.png` … `intent_claw_lit_f3.png` | 16×16 | 4 | Lit flash |
| `intent_claw_burst_f0.png` … `intent_claw_burst_f3.png` | 24×24 | 4 | Burst overflows the 64×64 badge |
| `intent_claw_flame_idle.png` | 16×16 | 1 | Pierce / Dragon flame rim |
| `intent_claw_flame_burst_f0.png` … `intent_claw_flame_burst_f3.png` | 24×24 | 4 | Flame burst |
| `intent_chip_shield.png` | 8×8 | 1 | Block soak chip |
| `intent_chip_drop.png` | 8×8 | 1 | Drop / poison chip |
| `intent_chip_flee.png` | 8×8 | 1 | Flee footprints chip |

Import: Filter Nearest (project default), mipmaps off, Lossless (`compress/mode=0`). Shark loop chip is Tween/`_draw` only (`UxStyle.draw_multi_tag`) — no PNG.
