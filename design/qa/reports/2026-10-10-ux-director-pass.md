# UX director pass — 2026-10-10

Independent visual pass on player chrome. No locked copy rewritten. No rules changed.

## Rubric (score each 1–5)

1. **Glanceability** — Attack / Block / HP / Defeat readable in under one second.
2. **Focus** — The facing owner and the hand are the brightest things; dead chrome stays quiet.
3. **One language** — Inspect, cards, tutorial, and log use the same keyword chips and metal plates.
4. **Affordance** — Hover, Shift, click, and spent/unusable look different from each other.
5. **Density** — Empty columns and overlapping tips do not steal the nest.
6. **Kind color** — Attack red, Block blue, HP rose, Defeat violet stay consistent.
7. **Portrait hierarchy** — 16×16 art sits in a well, nearest-neighbor, never stretched muddy.
8. **Motion** — Hover lift, playable pulse, inspect fade, hit flash — short, the same family.
9. **Type** — Titles outlined; body 15px; chips padded; Shift shows the sentence plus the math.
10. **Fun / impression** — Torch brown, gold bait, smug loot. Not a spreadsheet with a wheel.

Before this pass, title and fight both failed 2, 3, and 5: a tall empty parchment Inspect column, fly-tip overlapping the hand, keywords as color-only, Shift hiding ability, cards with no kind strip.

## What changed (mapped to the rubric)

| # | Change | Where |
|---|---|---|
| 1 | Keyword **bgcolor chips** (same grammar as tutorial) | `UxStyle.chip`, `_bb`, `_value_bb` |
| 2 | Inspect **shrinks to content** — no EXPAND_FILL parchment tower | `main.gd` right column, `hover_panel` |
| 3 | Inspect **hidden on title** | `_idle_inspect` |
| 4 | Item hover fills **persistent inspect** (portrait + chips); fly tip stays out of the hand | `_on_item_hovered` |
| 5 | Portrait **well** + gold hairline under title | `hover_panel.show_rule` |
| 6 | Idle inspect: dark plate + Attack/Block/HP/Defeat **legend** (chrome, not copy) | `show_placeholder` |
| 7 | **Shift** shows painted ability and hides the icon; equation still in the number slot | `item_card.show_formula` |
| 8 | Card **kind strip**, top highlight, drop shadow, stronger hover (1.09) | `item_card` |
| 9 | **Spent** stamp; unusable dim | `item_card.set_live` |
| 10 | Playable gold pulse stronger | `_apply_style` |
| 11 | Combat portrait **vignette + torch well + spotlight** | `combat_stage._draw` |
| 12 | Non-facing slices **dim to 0.70** | `boss_wheel` |
| 13 | Hearts **blush when HP ≤ 2** | `_refresh` hearts |
| 14 | Title **gold outline 64px**; overlay darker | `_build_overlay` |
| 15 | Pills **drop shadow** | `_sb` |
| 16 | Inspect fade-in 0.12s | `hover_panel` |
| 17 | Take-hit button **larger** while fighting | `_sync_buttons` |
| 18 | Cue label **gold** | `cue_label` |
| 19 | Hotbar gap **14px** | `hotbar_box` |
| 20 | Right column **292px**, shrink-begin | `main.gd` |
| 21 | Item inspect uses **item sprite** in the well | `_on_item_hovered` |
| 22 | Monster speech **chip-painted** if it was plain | `_fill_inspect_from_slice` |
| 23 | Card left border thicker (kind accent) | `_apply_style` |
| 24 | Number well still the live number unless Shift | (kept) |
| 25 | Hover SFX already on items — inspect no longer fights it with a second plate | fly tip gated |
| 26 | Metal plate language matches the Hornet **Attack/HP** plaque | inspect no brown parchment |
| 27 | Showcase ability font scales | `set_showcase` |
| 28 | Legend chips teach the palette before the first hover | idle inspect |
| 29 | Combat stage inner shadow (top/bottom bars) | `_draw` |
| 30 | Wheel focus vs periphery (line of sight) | dim 0.70 |

## Extra ideas still on the table (not this pass)

Tutorial `(Highglights hotbar)` typo is locked copy — needs an author override. Mill parchment stays Kenney. No new music bed.

## How to verify

Play frozen from title → Developer Test Hornet fight → hover each card → hold Shift → Take 4 still the facing prompt. Inspect should be a short dark plate, not a beige tower. Chips on Attack/HP. Cards show a colored left edge.
