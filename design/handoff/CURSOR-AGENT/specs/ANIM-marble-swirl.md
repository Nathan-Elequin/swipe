# ANIM: Marble swirl (red = Attack, blue = Block)

**Rule.** "Gain 0 Atk or 0 Block randomly. On Spin, increase these numbers by 1". The roll happens at **use**, so it can't be previewed.

**Look.**
- In the hand the marble slowly swirls *both* colours (a hint that it's undecided).
- On use it **swirls fast** and settles **red = Attack** or **blue = Block**, then flies to its target.
- On each Spin it grows one notch with a +1 tick.

## Hooks (real code)
- **Use / roll:** `main.gd::_apply_marble(it)` (~L10082). After the random pick, `await card.play_marble(is_atk)` *before* the value is applied, so the colour lands first.
  - Red: flies to `_item_fx_dest("atk")` (~L9328).
  - Blue: flies to `_hub_blk_pos()`.
- **Grow:** `_step_marbles()` (~L9956) is called in the `_on_spin` cascade. For each marble card, `card.marble_grow(n)` and a cascade-ticker token.
- **Create:**
  - `_apply_bag_marbles(it)` (~L9967): stagger-roll into the slots.
  - `_magicat_morph(it)` (~L10282): Magicat marbles use a cat's-eye base. Keep the same API.
- **Hover preview:** none. The intent plate shows a striped red/blue ghost badge "?" (see item-hover-preview).

## Layout
- The icon box stays 48×48. Frames are 24×24 at 2x.
- Fly-out uses the existing `_fly_courier(tex, from, to, 0.4)` (~L4349) with the settled-colour frame.

## Timing (ms)

| Event | Animation |
|---|---|
| Idle in hand | `marble_idle` 4f @ 180ms loop (slow two-tone swirl) |
| Use | `marble_swirl` 6f @ 40ms (240), then `marble_red` or `marble_blue` holds 120 with a 1→1.25→1 scale punch, then the courier (400) to the target |
| Grow on Spin | scale 1→1.15→1 (160); number dissolve (`_dissolve`); a 1px white rim flash |
| Bag of Marbles fill | each marble rolls in from the bag card, staggered 50ms (TW position + rotation) |

## Nodes
```
ItemCard
 └─ MarbleFx (AnimatedSprite2D 2x; anims: idle, swirl, red, blue, cat_idle, cat_swirl)  [PL]
```
No shader: the colours are baked in the frames.

## Assets

| File (`assets/dungeon/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `marble_idle_f0-3.png` | 24×24 | 4 | [PL] (base = current marble icon) |
| `marble_swirl_f0-5.png` | 24×24 | 6 | [PL] |
| `marble_red.png`, `marble_blue.png` | 24×24 | 1 each | [PL] (one gen, 2 variants) |
| `marble_cat_idle_f0-3.png` | 24×24 | 4 | [PL] (Magicat cat's-eye) |
| Palette | — | — | red uses `hurt #e07a7a` / `danger #8b1e1e`; blue uses `#6ec8e8` (the on_spin log colour) |

## QA
1. Bag of Marbles: shot of the hand filling (staggered).
2. Use a marble (seed rng). Shots at 120 / 300 / 600ms: swirl, settled colour, courier at the destination.
3. Spin: every marble grows with +1.
4. Magicat: morph into cat's-eye marbles keeps the numbers.
