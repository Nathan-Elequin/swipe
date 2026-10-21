Pixel's title teaser drop. The name is locked as **Spinheritance**.

**Added to `assets/dungeon/title/`**
- `title_still.png`: 1680x1040, drawn at 420x260 native and scaled 4x nearest. Opaque. "Loot river" composition. No lettering. Faces stay out of the hub hole and the logo, tagline and Click rects.
- `hill_strip.png`, `hall_strip.png`, `hall_strip_b.png`: 1680x1040, seamless on X, floor at native y=161.
- `logo.png`: 720x160 (180x40 native), transparent, hand-built pixel lettering. The p's bowl is a roulette wheel and the i's dot is a small wheel. Fits SCREEN's logo rect and the 210-native cap.
- Each PNG has a `.import` that matches the repo defaults: lossless (`compress/mode=0`), `mipmaps/generate=false`. Nearest filtering comes from the project setting.

**Docs**
- `design/visual/sizes/title-teaser.sizes.json`: native and shipped sizes, floor y, tiling, and the SCREEN rects including the logo rect.
- `design/visual/title-teaser/PIXEL-NOTES.md`: Pixel's locked calls, plus code follow-ups for `scripts/title_teaser.gd`. They cover hiding the code title label when `logo.png` exists, using the SCREEN rects instead of the centred stack, dropping the duplicate run door and lantern, Nib's scale and floor, and the timing bugs. None of them are fixed in this PR (art only).

**Checks (headless, in the worktree, Godot 4.7.2)**
- `--import`: exit 0
- `--quit`: exit 0, no script errors
- art check: `ART_CHECK checked=154 missing=0`. That covers every `dungeon_art.gd` PNG plus the 5 title files; the still loads at 1680x1040 and the logo at 720x160.
- `tools/qa/check_ui_pngs.py`: `checked 1093 failures 0`
- `tools/qa/check_title_teaser.py`: `PASS: title still is unique and sized`

Re-importing with Godot 4.7.2 rewrote about 1,350 unrelated `.import` files plus `project.godot` and `default_bus_layout.tres`. I reverted all of that, so only these 12 files are in the PR.
