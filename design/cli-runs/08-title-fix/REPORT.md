# 08-title-fix — REPORT

## Status

**DONE** — `scripts/title_teaser.gd` follows PIXEL-NOTES; headless beat dump green (`TITLE_BEATS OK`). No itch export, no Godot window, no push.

## Commits

| Commit | Message |
|---|---|
| `5cc4874` | `title-fix(0): checkpoint + CLI prompt` (pre-existing) |
| `de3a4bb` | `title-fix(1): SCREEN layout, Nib floor, beat timing, grab/spend` |
| `e236503` | `title-fix(2): headless beat dump and asserts` |
| `666775a` | `title-fix(3): beats script uid from Godot` |
| `2486ef6` | `title-fix(4): fix still-hold hang in debug_capture` |
| *(this)* | `title-fix(5): beats.json + REPORT` |

## Files touched

- `scripts/title_teaser.gd`
- `tools/qa/title_teaser_beats.gd`
- `tools/qa/title_teaser_beats.gd.uid`
- `design/cli-runs/08-title-fix/beats.json`
- `design/cli-runs/08-title-fix/REPORT.md`

Not touched: `scripts/main.gd`, `scripts/dungeon_art.gd`, `data/**`, PNGs, `.import`, `project.godot`, player-facing copy.

## Per-fix summary

1. **Title layout** — Replaced centred VBox with absolute SCREEN rects (logo/tagline/Click). Logo drawn at texture size, width-capped at 840, centred in `(340,80,1000,160)` → `[480,80,720,160]`. `_title` hidden when `logo.png` exists. `_music_lab` editor-only, bottom-right.
2. **Duplicate door/lantern** — Removed `_door` load/blit and the lantern-item blit beside Nib. Hill strip carries cabin/door/window.
3. **Nib** — Texture-native size, feet pivot on floor `y=644`, planted at strip door `x=204`, scrolls with snapped hill pan; `nib_lantern` anim ~3 fps when frames exist.
4. **Sizes/frames** — Motion items 96×96; monsters integer texture multiples (~128 / ~192 / dragon ≥256). Loads `item_*_f*` / `mon_*_f*` via `_seq()`, falls back to `art.item_tex` / `art.monster_still`. Item bob ~4 fps, monsters ~10 fps.
5. **Timing** — Constants: `T_THRESHOLD/T_GRAB=2`, `T_SPEND/T_HALL_B=5`, `T_SWIRL=8.5`, `T_WHITE=11`, `T_WHITE_PEAK=12.2`, `T_STILL=13`. Grab crossing `ix <= hx+20`; spend one-shots boot@5.6 / helmet@7.0 (force-ready then spend). Monsters never before threshold; ease into chase slots; no drift. Hall B at `T_HALL_B`. Swirl independent of whiteout.
6. **Facing/pans** — Dragon/ogre `flip_h` when using card art (teaser `mon_*` never flipped). Strip pans and actor x/y snap to 4 px.
7. **Beat dump** — `_rec` recorder on `_blit` / `_blit_strip`; `debug_capture(t)`; `tools/qa/title_teaser_beats.gd` writes `beats.json` and asserts (a)–(i).

## Checks

| Check | Result |
|---|---|
| `--headless --path . --import` | exit 0 (RID-leak noise only; import churn reverted) |
| `--headless --path . --quit` | exit 0; no SCRIPT ERROR / parse errors (RID leaks expected) |
| `-s res://tools/qa/title_teaser_beats.gd` | **TITLE_BEATS OK** exit 0 |
| `py -3 tools/qa/check_title_teaser.py` | PASS exit 0 |
| `py -3 tools/qa/check_ui_pngs.py` | failures 0 (audit-shots rewrite reverted) |
| `-s res://tools/qa/check_shot_cli.gd` | **SHOT_CLI_OK** exit 0 |

## Beat-dump summary

Samples at 1.0 / 3.6 / 5.7 / 7.1 / 9.5 / 11.6 / 13.5:

- t&lt;2: hill only, no monster blits
- 3.6: ≥1 held catch; 5.7: 4 held catches; hall_b in use
- 7.1: boot gone; 8.0: helmet gone
- 9.5: swirl, hero near centre
- 13.5: logo blit `[480,80,720,160]`, `_title` hidden, still_a=1
- All strip/actor x/y on 4 px grid; dragon h≥256; dragon/ogre flip_h; skeleton chase offset stable (±0) across 6.5–8.0

Full JSON: `design/cli-runs/08-title-fix/beats.json`.

## Left undone

- No live teaser sprite sheets under `assets/dungeon/title/` (`sprout_*`, `nib_lantern_*`, `item_*`, `mon_*`). Fallback card/hero art is used; motion reads are dummies until Pixel drops those frames. Logic and asserts pass on fallbacks.
- No F5 / windowed visual review (hard constraint: headless only).

## Questions

### [Jam]

1. `game_title` / `title.overlay` fallback is still **"Swipe"** (`data/script-names.json`, `project.godot`, COPY key). Nathan locked the name as **Spinheritance**. Code must not change player-facing copy; please wire Spinheritance when ready. Logo PNG already reads Spinheritance, so with logo present the wrong label is hidden.

### [Pixel]

1. Optional teaser frame sheets (`sprout_run/grab/throw`, `nib_lantern`, `item_<id>_f*`, `mon_<id>_f*`) are still missing from `assets/dungeon/title/`. Code will pick them up via `_seq()` when they land; no wiring change needed beyond the files.

### [Nathan]

None.
