# Font revert and text collision

Labels, buttons, rich text, and fit boxes use the project theme font again (Godot’s default face). Nothing loads `assets/ui/fonts/swipe_pixel.fnt` or `Jersey10-Regular.ttf`. `assets/ui/fonts/` is not in the tree. Sizes stay on the values from `ac767cd` when the line fits, including odd sizes such as 13 and 15. Colours and outlines on those labels are unchanged. `data/player-copy.json` was not edited.

Fit boxes still shrink, then wrap with `AUTOWRAP_WORD_SMART`, then ellipsis. Measurement does not treat a mid-word break as a fit. A word wider than the box falls through to ellipsis.

Dialog and cutscene bars keep a fixed portrait column on the left, body text in the remaining rect (max 3 lines), and “Click to continue” on its own row at the bottom right. The bar sits inside a 32px margin with an opaque dark panel. Text controls are carved so their rects do not cover a sibling portrait, sprite, or other text. The text audit flags those overlaps, not only other labels. A full-screen backdrop that already contains the text is not counted.

## Files changed

- `scripts/ui/fit_label_box.gd`
- `scripts/ui/text_reserve.gd` (new)
- `scripts/ui/text_reserve.gd.uid`
- `scripts/dev/text_audit.gd`
- `scripts/dev/shot_harness.gd`
- `scripts/cabin/cutscene_player.gd`
- `scripts/cabin/cabin_dialog.gd`
- `scripts/main.gd` (command-line `--text-targets` only)
- `design/visual/layouts/rope-exit.layout.json`
- `design/visual/layouts/rope-exit-sack-peek.layout.json`
- `design/visual/layouts/map-routes.layout.json`
- `design/visual/layouts/map-routes-classic-selected.layout.json`

## Audit

Before this pass, `design/audit-shots/cursor/text_audit.json` (2026-10-17 17:39) stored `"failures": []`. That file did not record sprite or portrait hits.

After, `design/cli-runs/01-font-revert/text_audit.json` (2026-10-17 18:08) on intro panel 1, intro panel 3, combat with the card and monster tooltip open, and the item hand:

`failures: []` (zero hits).

## Screenshots

- `design/cli-runs/01-font-revert/13a_intro_panel1.png`
- `design/cli-runs/01-font-revert/13b_intro_panel3.png`
- `design/cli-runs/01-font-revert/text_combat_tips.png`
- `design/cli-runs/01-font-revert/text_item_hand.png`

## Not changed

The tan scroll in the intro loft is painted into `assets/dungeon/home/cutscenes/intro_p3.png` (scribbles and a broken seal). It is not an empty Control. Removing it would erase that painting. No separate blank tan rectangle was left on the dialog.
