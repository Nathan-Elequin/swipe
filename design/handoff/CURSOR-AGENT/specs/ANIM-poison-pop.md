# ANIM: Poison pop (pending drop → tick burst)

**Goal.** Poison is a *lump* that waits, not damage every turn:
- Monster poison fires when *that monster* is spun.
- Your poison fires on your next Spin.

Make the waiting visible (a slow drip) and the tick unmistakable (a burst, a number that flies, hearts that drain).

## Hooks (real code)

**Gain.**
- `main.gd::_gain_player_poison(n)` (~L8188): hub badge fill-up.
- `_add_monster_poison(index, n)` (~L8003): slice badge fill-up.
- Sources:
  - Ale Flagon (`heal_poison` ~L7281)
  - Poison Frog `_apply_poison_frog_on_spin` / `_poison_frog_on_hit` (~L10350/10362)
  - Miasma
  - Poison Flask
  - Plague Doctor `_sync_plague_poison` (~L8044); its "Always" lock is `_plague_locks_poison`

**Waiting.**
- `boss_wheel.gd::_draw_poison_badge(font,pos,s,big)` (~L2033): add the drip loop here.
- Hub: `hub_poison` and the doomed-heart tint in `_draw_hub_heart_arc` (~L444/456). Add a hub poison badge next to the hearts.

**Tick.**
- `_tick_monster_poison()` (~L8169) → `_chip_hp(index, n)` (~L7968). Insert `await poison_pop.burst_slice(facing_index, n)` before the chip.
- `_tick_player_poison()` (~L8198) already punches doomed hearts (`_punch_heart`) and waits 220ms. Replace that wait with `await poison_pop.burst_hub(n)`.
- **Clear:** `_clear_monster_poison` (~L8144): badge empty "glug".

## Layout (1680×1040)
- **Slice badge:** existing position from `_draw_poison_badge`. 32×32 on screen (8×8 native at 4x).
- **Hub badge (new):** right of the heart arc, at `hub_hearts_global() + (54, 0)`, 48×48 (12×12 at 4x). Also mirror it as a 32px drop after the top-left heart row (x ≈ 232, y ≈ 27).
- **Burst:** centred on the badge, 96×96 (24×24 at 4x).
- **Flying number:** from the badge to `hp_global(i)` (monster) or the doomed hearts (player).

## Timing (ms)

| Event | Animation |
|---|---|
| Gain | badge pops 0→1.2→1 (160); number ticks up 1 per 60 |
| Wait (idle) | 4-frame drip @ 150ms, looping, plus a 2px bob |
| Plague "Always" | padlock glyph on the badge corner; no drip (it can't change) |
| Tick | badge swells 1→1.4 (100) → burst 4f @ 50ms (200) → "−n" in `hurt` flies to its target (240, `TRANS_QUAD` in) → hearts drip one by one (80 each, `heart_drip` 4f) or the slice HP ticks via `play_hp_ticks(i, from, to)` |
| Clear | badge shrinks to 0 (120) with a single "glug" bubble |
| Total, player 2 poison | ≈ 100 + 200 + 240 + 160 = 700ms (about 233ms at Shift ×3) |

## Nodes
```
PoisonPop (Node2D under Main, top_level)        ← scripts/poison_pop.gd
 ├─ Burst (AnimatedSprite2D) [PL]
 ├─ Num (Label, hurt colour, outline 3) [TW]
 └─ Drips (pool of AnimatedSprite2D, heart_drip) [PL]
```
Slice and hub badges stay `_draw` calls with a frame index from `_clock` **[PL frames, drawn with draw_texture_rect]**. The ticker token for the poison step uses `poison_badge` (see the cascade ticker spec).

## Assets

| File (`assets/ui/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `poison_badge_drip_f0-3.png` | 8×8 | 4 | [PL] (base is the existing `tex_poison`) |
| `poison_burst_f0-3.png` | 24×24 | 4 | [PL] |
| `heart_drip_f0-3.png` | 12×12 | 4 | [PL] |
| `poison_lock.png` | 6×6 | 1 | [PL] (with the aura glyph sheet) |

## QA
1. Ale Flagon, then Spin. Shots at the burst frame and +300ms: hub badge burst, "−3" flying, hearts dripping.
2. Miasma on a 4-monster wheel: every slice shows a drip badge. Spin one: only that slice bursts; the others keep dripping.
3. Plague neighbours show the padlock, with no burst on their own spin (Always 2 stays).
4. Hold Shift: the same sequence at ×3.
