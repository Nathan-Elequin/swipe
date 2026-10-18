# playtest-art-wiring

Status: PASS

Checkpoint: playtest-pass-2026-10-17 @ dfadbcd

## Commits

- `275cdf7` playtest-art-wiring(1): shift the loft cat four native pixels right while the belly rub plays
- `07a7734` playtest-art-wiring(2): keep the loft new tag on room build instead of the rub ending
- `0da821d` playtest-art-wiring(3): show the journal cover first and place intro shots under the memory tape
- `34fc4f7` playtest-art-wiring(4): register loft and journal shots 60 through 66
- this file, playtest-art-wiring(5)

## Files

- `scripts/cabin/room_loft.gd`
- `scripts/home_cabin.gd`
- `scripts/cabin/journal_overlay.gd`
- `scripts/dev/shot_harness.gd`
- `design/cli-runs/06-playtest-art-wiring/REPORT.md`

## Cat offset

Sleep stays at native `(176, 196)`. While `rub` plays, `cat_sleep.position` is native `(180, 196)` (`+4 * PX` on x). `animation_finished` puts it back and plays `z`. Frames `f0`–`f3`, loop off, speed `1000/180` (180 ms per frame). The loft Cat hotspot calls `play_rub()`.

## Well / screenshot z-order

Each memory photo is a `TextureRect` added before its tape well. Photo `z_index` 2, tape `z_index` 3, so the tape draws above the shot. Photo window is native `(10, 5, 100, 62)` inside the `120x72` well. Texture filter nearest, stretch keep-aspect centered. Sources: `cutscenes/intro_p1.png`, `cutscenes/intro_p2.png`. Memories is the third tab. Will stays on the desk overlay.

## Scribble rect

From `data/cabin-layout.json` `journal_pages.right`, relative to the spread at native `(20, 10)`:

- Lore rect, book-relative native: `x 196, y 18, w 166, h 204`
- Lore rect, screen native: `x 216, y 28, w 166, h 204` (pixels `864, 112, 664, 816`)
- Scribble: same origin, native `166x80` (pixels `664x320`)

Width matches the rect. Height `80` is inside `204`. No position or size change. The clamp in code is a no-op at these numbers.

Items have no lore rect in `journal_pages`. The items tab is the grid only, and the scribble stays hidden there. Unmet bestiary entries still show `journal_scribble` in that right rect.

## Cover

The cover already sat on the spread origin. `_refresh` hid it in the same call that opened the book, so it never showed. Opening the journal now leaves the cover up. A left click on the cover calls `open_spread()`, which hides it and shows the pages. The existing `text_journal` shot calls `open_spread()` so it still captures the open pages. A debug beat that asked for tab `will` opens Memories.

## Checks

Headless console exe only.

- `--headless --path . --import` — exit 0. No script parse errors. One `godot-mcp` line: port 6550 already in use (the open editor).
- `--headless --path . --quit` — exit 0. No script parse errors. Engine RID leak lines at shutdown only.
- `res://tools/qa/check_shot_cli.gd` — exit 0, `SHOT_COUNT 78`, `SHOT_CLI_OK`. Resolved: `60_loft`, `61_loft_cat_rub`, `62_journal_cover`, `63_journal_bestiary`, `64_journal_items`, `65_journal_memories`, `66_journal_unmet`.
- `res://scripts/dev/text_audit_selftest.gd` — exit 0, `SELFTEST_OK`.
- `res://scripts/dev/layout_check_selftest.gd` — exit 0, `LAYOUT_CHECK_SELFTEST ok`.
- `py -3 tools/qa/check_ui_pngs.py` — `checked 1032`, `failures 0`.

## Shots pending

Named shots are registered. Output dir is `res://design/cli-runs/06-playtest-art-wiring`. Windowed captures were not run. Pixel runs:

`--shots=60_loft,61_loft_cat_rub,62_journal_cover,63_journal_bestiary,64_journal_items,65_journal_memories,66_journal_unmet --shots-out=res://design/cli-runs/06-playtest-art-wiring`

`61_loft_cat_rub` poses rub frame `f2` (paused) at the rub origin.

## Gold boxes pending

None. Every `review_note` in `data/content-board.json` is empty.

## Deviations

- Cover click-to-open is the fix for the cover never appearing. See Cover.
- `text_journal` opens the spread before capture.
- Import wrote `.import` / `.uid` churn. Not committed. `png_check.json` was rewritten by the PNG check and was not committed.

## Questions

None.
