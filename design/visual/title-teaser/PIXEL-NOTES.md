# Pixel notes: title teaser (locked calls)

Drop on 2026-10-20: `title_still.png`, `hill_strip.png`, `hall_strip.png`, `hall_strip_b.png`, `logo.png` in `assets/dungeon/title/`. Sizes: `design/visual/sizes/title-teaser.sizes.json`. Name locked by Nathan: **Spinheritance**.

## Locked art calls

- **Monsters face right** in the motion strips. This supersedes "facing left" in ART-REQUEST §F.
- **Gold is `#FFD84A`** (Torchlit bait gold), with 3-4 tone ramps lit from the upper-left and 1px `#100e0c` outlines.
- **Grandpa appears only through his objects**: hat, portrait, sack, and the loot. Never alive.
- **Items are 24 px native in motion** (96 shipped). **Dragon is 64+ px native.**
- **Pans snap to 4 shipped px** (1 native px). No sub-pixel scroll on the strips.
- **The logo is a separate file.** `title_still.png` has no lettering. When `logo.png` exists, the code title label must hide; today `_build_labels()` still adds the "Swipe" `_title` label even with a logo.
- **Logo width cap is 210 native (840 shipped).** It matches `minf(sz.x * 0.5, ...)` in `_draw_still()`. The shipped logo is 180x40 native and fits SCREEN's logo rect.
- **Title, tagline and Click must use the SCREEN rects** (`design/visual/title-teaser/SCREEN-title-still.md`), not the centred VBox stack: logo `(340,80,1000,160)`, tagline `(260,250,1160,80)`, Click `(340,920,1000,80)`. `_draw_still()` currently places the logo at `y = sz.y * 0.12` (125), but the rect top is 80.
- **Drop the duplicate run door and lantern.** `hill_strip.png` already paints the cabin, the run door and the lit window. The code still blits `run_door_open_f0` and the lantern item over the hill.
- **Nib's scale and floor bug:** Nib is blitted at a fixed 96x96 at `sz.y * 0.48`, so he is not on the floor (y = 161 native / 644 shipped) and not at the 32x32-native (128 shipped) cameo scale. Pivot should be the centre of the feet on the floor line.

## Timing bugs (code vs the locked beat order in PIXEL.md)

Symptoms as reported. Pointers are where to look in `scripts/title_teaser.gd`, not a diagnosis.

- **Swirl starts late:** `T_SWIRL = 11.0`, but the beat is 8.5-11 s. The swirl now starts when the whiteout should.
- **Spend never fires:** the Boot and Helmet are never seen thrown. The toss in `_step_hero` (`_t >= T_GRAB + 1.2`) only applies to spend items that are already `held`. Check where `held` is set (the catch in the draw loop) against that one-shot timing.
- **Grab is empty:** Sprout's grab plays with nothing caught in hand.
- **Hall B arrives late:** it swaps at `T_SPEND = 8.5`. The halls should change when the spend beat starts (5 s).
- **Monsters spawn on the hill and drift:** chasers appear during the threshold/hill beat and slide instead of entering from behind in the hall.
- **Only `_f0` frames load for items and monsters:** `item_*` and `mon_*` are looked up only as `_f0.png` (`_item_tex`, `_mon_tex`, `_spawn_actors`), so `_f1` bobs and `mon_*_f1..f3` run cycles are never used. Sprout and Nib use `_seq()`, which does load `_f0.._fN`.
