# UI anim assets (`assets/ui/anim/`)

Import: Filter Nearest (project default), mipmaps off, Lossless (`compress/mode=0`). Shark loop chip is Tween/`_draw` only (`UxStyle.draw_multi_tag`) — no PNG.

## Final PixelLab art

Overwrite landed at the same paths as the old placeholders. Loaders still use `res://assets/ui/anim/...` by path.

### Intent plate

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

### Hotbar shimmer / hover chips

| File | Native | Frames | Notes |
|---|---|---|---|
| `deadly_sparkle_f0.png` … `deadly_sparkle_f3.png` | 8×8 | 4 | Final PixelLab run4. Deadly sparkle. Do not overwrite. |
| `intent_chip_plus.png` | 8×8 | 1 | Final PixelLab run4. Hover-preview plus chip. Do not overwrite. |

### Spin cascade ticker

| File | Native | Frames | Notes |
|---|---|---|---|
| `ticker_token_frame.png` | 12×12 | 1 | Brass stamp ring; empty middle for the icon |
| `ticker_token_stamp_f0.png` … `ticker_token_stamp_f3.png` | 12×12 | 4 | Press-down + ink tick |
| `ticker_ff.png` | 12×8 | 1 | Gold ▶▶ chevrons |

### Poison pop (pass 4) — final PixelLab art

| File | Native | Frames | Notes |
|---|---|---|---|
| `poison_badge_drip_f0.png` … `f3.png` | 8×8 | 4 | Slice/hub drip loop. Green. PixelLab Task 5 reroll, then palette-swapped (no new gens) onto the `#7dba7d` / `#8dcb8d` family by `design/handoff/CURSOR-AGENT/rerolls/recolor_poison.py`. Nathan: poison is green. |
| `poison_burst_f0.png` … `f3.png` | 24×24 | 4 | Tick burst. Green. Same palette swap: `#3d6b3f` / `#5a965c` / `#7dba7d` / `#8dcb8d` / `#b2e0b0` / `#d8f0d0`. Nathan: poison is green. |
| `heart_drip_f0.png` … `f3.png` | 12×12 | 4 | Player heart drip |
| `poison_lock.png` | 6×6 | 1 | Plague Doctor Always padlock. Green (`#7dba7d` / `#8dcb8d`). PixelLab 2026-10-21. Nathan: poison is green. |

### Petrify (pass 4) — final PixelLab art

| File | Native | Frames | Notes |
|---|---|---|---|
| `petrify_shatter_f0.png` … `f4.png` | 30×30 | 5 | Stone shatter over card |

### Aura threads (pass 4) — final PixelLab art

| File | Native | Frames | Notes |
|---|---|---|---|
| `aura_glyph_sword.png` | 8×8 | 1 | Commander |
| `aura_glyph_wisp.png` | 8×8 | 1 | Lich |
| `aura_glyph_drop.png` | 8×8 | 1 | Plague Doctor |
| `aura_glyph_lock.png` | 8×8 | 1 | Always padlock end |
| `aura_glyph_shield.png` | 8×8 | 1 | Bodyguard |
