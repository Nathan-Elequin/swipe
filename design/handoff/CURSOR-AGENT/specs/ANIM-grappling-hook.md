# ANIM: Grappling Hook (rope-yank swap + draw)

**Item:** Grappling Hook (`grappling_hook`). "Swap a Neighboring Owner into this fight. Draw a Random Item."

## Hooks (real code)
- Ops kind `hook_swap`: `_mark_targets("hook_swap")` sets usability (~L13290). Use enters mark mode (`_use_item` ~L7013 groups `hook_swap` with the other mark kinds; `cue.mark` "Pick a neighbor.").
- `_can_mark(index, "hook_swap")` (~L12060): highlight valid neighbours.
- `_apply_mark(index)` (~L12065, branch ~L12096) does the swap and the draw. Wrap the state change: `await hook_fx.throw(from_card, to_slice)` → (state swap) → `await hook_fx.yank(facing_index, index)` → the draw goes through `_try_gain_item` / `_fly_courier`.

## Layout (1680×1040)
- **Rope:** from the hotbar card centre to `slice_portrait_global(target)`, with a 20px sag at the midpoint.
- **Hook head:** 24×24 native at 2x (48px) at the rope tip.
- **Swap:** both slice portraits move along an arc around the hub (radius = slice portrait radius) and trade places. When `combat_stage.visible`, the stage portrait cross-fades to the new monster (`combat_stage.show_monster(id, tier)`).

## Timing (ms)

| Phase | Animation |
|---|---|
| Throw | `hook_throw` 6f @ 40 (240): hook leaves the card; the rope (Line2D) extends with the tip |
| Catch | 80: the target slice shakes ±3px; rope goes taut (sag 0) |
| Yank | 320: both portraits travel the arc and swap (`TRANS_BACK` out); the wheel slices redraw on arrival; bonds re-tie (aura-threads diff) |
| Retract | 160: the rope reels back into the card |
| Draw | the existing courier (400) brings the random item; the card shows `play_transform` |
| Total | ≈ 1.2s (≈ 400ms at Shift ×3) |

## Nodes
```
HookFx (Node2D, top_level, z 13)  ← scripts/hook_fx.gd
 ├─ Rope (Line2D, texture rope_tile, TEXTURE_MODE_TILE, width 8)   [PL tile]
 └─ Head (AnimatedSprite2D: throw / taut)                           [PL]
```
The portrait swap is TW on temporary `TextureRect` ghosts made from `art.monster_still(id)`, while `wheel_view` hides the two real portraits.

## Assets

| File (`assets/dungeon/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `hook_throw_f0-5.png` | 24×24 | 6 | [PL] (base = the current grappling hook icon) |
| `hook_taut.png` | 24×24 | 1 | [PL] |
| `rope_tile.png` | 4×8 | 1 | [PL] (tileable) |

## QA
1. Face a monster with two neighbours, then use the Hook. Shot: mark highlights (`cue.mark`).
2. Click the right neighbour. Shots at 200 (throw), 360 (taut), 600 (mid-swap), 1100 (drawn item arriving).
3. The new facing monster's intent plate rebuilds; aura threads re-tie.
