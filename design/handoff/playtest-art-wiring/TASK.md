# playtest-art-wiring — wire Pixel's Oct 17 playtest art
Checkpoint: playtest-pass-2026-10-17 @ dfadbcd   Branch: playtest-art-wiring   Worktree: boss-rush-wt\playtest-art-wiring
## Read
- `.cursor/rules/swipe-design-loop.mdc`
- `design/visual/HANDOFF-2026-10-17-playtest.md`
- `design/visual/HANDOFF-2026-10-17-playtest-SIZES.md` (sizes, registration, well window)
## Facts
- Assets from PR #11 are on this branch at the handoff paths, stored 4x nearest: `props/cat_rub_f0..f3.png` (16x16 native, 64x64 stored), `overlays/journal_cover.png` (380x240 / 1520x960), `overlays/journal_scribble.png` (166x80 / 664x320), `overlays/journal_photo_tape_a/b.png` (120x72 / 480x288).
- Journal code already exists (cover, tabs bestiary/items/memories, scribble, wells, replay). Loft cat already has a `rub` animation on the sleep cat's AnimatedSprite2D.
## Do
1. Cat: the rub frames must draw at loft origin (180,196) native (heads line up with the sleep cat at (176,196)). E.g. offset the sprite +4 native px (x PX) only while `rub` plays, reset when back to `z`. Play f0-f3 once at 180 ms per frame, then back to the sleep loop. Click Cat hotspot in the loft triggers it.
2. Memories tab: paste the intro screenshots (`assets/dungeon/home/cutscenes/intro_p1.png`, `intro_p2.png`; scaled nearest to fit) into the two wells, inside each well's transparent photo window = native rect x10-109, y5-66 of the 120x72 well (100x62). The tape-well PNG must draw ABOVE the pasted screenshot (screenshot node below the well node / lower z). Memories is the third tab; Will stays on the desk (no Will in the book).
3. Scribble: confirm `journal_scribble` sits inside the unmet lore rect (the `_right` lore rect from `journal_spread` layout data) for unmet bestiary entries and for unmet items if items have a lore rect; it must not overflow the rect (166x80 native). Fix position/size only if it overflows; report the rect numbers.
4. Cover: shows first, at the spread origin, before the spread; hides when the spread opens. Leave as is unless broken.
5. Shot harness: add named shots `60_loft`, `61_loft_cat_rub` (mid-rub, frame f2), `62_journal_cover`, `63_journal_bestiary`, `64_journal_items`, `65_journal_memories`, `66_journal_unmet` (an unmet bestiary entry showing the scribble). Register them in the shot table so `--shots=60_loft,...` works; output to `res://design/cli-runs/06-playtest-art-wiring`.
6. Checks (HEADLESS ONLY, Nathan's Godot editor is open, do not launch a windowed Godot): Godot console exe `--headless --path . --import` and `--quit` (no new parse errors), `scripts/dev/check_shot_cli` style check that the new shot names resolve, text_audit selftest, layout_check selftest, `py -3 tools/qa/check_ui_pngs.py`. Pixel will run the windowed shots later.
## Files you may touch
- `scripts/**`, `scenes/**`, `.import` files for existing assets, `design/cli-runs/06-playtest-art-wiring/**`
## Do not
- No copy edits (`data/player-copy.json` untouched). No PNG edits. No new fonts. Do not push, do not merge. Do not commit project.godot / default_bus_layout.tres / .import churn of unrelated files / .uid noise.
## Done
- Commit each step as `playtest-art-wiring(n): ...`.
- Write `design/cli-runs/06-playtest-art-wiring/REPORT.md`: status PASS/BLOCKED, commits, files, the cat offset approach, well/screenshot z-order, scribble rect numbers, check results, shots pending, questions tagged [Pixel]/[Jam]/[Nathan].
