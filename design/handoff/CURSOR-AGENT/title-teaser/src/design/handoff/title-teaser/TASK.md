# title-teaser — Pixel owns the boot cinematic

Checkpoint: current main   Branch: main   Chat: this
## Read (in this order)
1. `design/handoff/title-teaser/PIXEL.md` — the brief. F5 is a dummy; do not match it.
2. `design/handoff/title-teaser/ART-REQUEST.md` — every file, size, pivot
3. `design/handoff/title-teaser/NAME.md` — do not letter until this is one word
4. `design/visual/title-teaser/SCREEN-title-still.md` — type + hub hole
5. `design/visual/title-teaser/storyboard.html` — beat order (Zen)
## Do
1. Draw the worlds and the still first (ART-REQUEST A + B). Picture must read: grandpa’s loot, spend some to keep the rest, mountain chase.
2. Draw Sprout / Nib / item floaters / monster runs (C–F) so motion is not combat postage stamps.
3. Pick lettering only after NAME.md is locked. Snatchwick is the recommendation, not an order to paint yet.
4. Drop PNGs in `assets/dungeon/title/`, 4× nearest, lossless, no mipmaps.
5. Return a one-page size list. Write `design/visual/sizes/title-teaser.sizes.json` when the files exist.
## Files you may touch
- `assets/dungeon/title/*.png` and their `.import`
- `design/visual/sizes/title-teaser.sizes.json`
- Notes under `design/visual/title-teaser/` if a rect disagreed
## Acceptance
- `title_still.png` is 420×260 native, 1680×1040 shipped, and reads inheritance + spend-to-keep + mountain
- Hill / hall strips are 420×260, floor at y=161, tile on X with no seam
- Sprout teaser run is readable at 48×48 native, facing right, feet-pivoted
- No live card PNG is reused or recolored
- No English on the still except the locked logo
## Do not
- Do not tidy or redraw the F5 dummy
- Do not edit `scripts/**` (Cursor wires)
- Do not redraw `assets/dungeon/items/` or `extra/`
- Do not letter until NAME.md is locked
- Do not replace `music_combat.ogg`
- Do not paint the rain / will knock
## Resolved decisions
- Boot: Feedback Tutorial → teaser → still + tagline + Click to continue → hub
- Tagline: `Use it, Lose it, or Lose your head`
- Camera: scroll, then swirl
- Brand New still plays the existing will cutscene
- Itch waits on `title_still.png` (and the strips if they are in the same drop)
