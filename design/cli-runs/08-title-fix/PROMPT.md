# 08-title-fix: make scripts/title_teaser.gd follow PIXEL-NOTES (Cursor CLI task)

Task id: `title-fix`. Commit each step as `title-fix(n): <what>` (step 0, the checkpoint plus this prompt, is already committed). Work ONLY in this worktree: `C:\Users\Natha\Documents\boss-rush-wt\title-fix`.
At the end, write `design/cli-runs/08-title-fix/REPORT.md`. It must cover: status, commits, files touched, per-fix summary, anything left undone and why, check results, beat-dump summary, and questions tagged [Pixel]/[Jam]/[Nathan] (put copy flags under [Jam]).

Read first: `design/visual/title-teaser/PIXEL-NOTES.md`, `design/visual/title-teaser/SCREEN-title-still.md`, `design/handoff/title-teaser/PIXEL.md` (beat order), `design/visual/sizes/title-teaser.sizes.json`.

## Hard constraints (read twice)
- **Don't export or push to itch.** No butler, no web export, no export presets, nothing that uploads anywhere.
- **Don't open the Godot window.** Nathan's editor is open on the main folder. Run Godot headless only (`--headless`), one Godot process at a time. Never launch the editor or a windowed game, on this worktree or anywhere else.
  - Console exe: `C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
  - "godot-mcp port 6550 already in use" is expected noise. So are RID-leak lines at exit.
- Do not push, merge, rebase, stash, reset, force, or touch other worktrees or branches. The parent opens the PR.
- Do not read or print `.art-ping.env`, or any env/secret file.
- Edit ONLY:
  - `scripts/title_teaser.gd`
  - new `tools/qa/title_teaser_beats.gd` (and its `.uid` if Godot makes one)
  - files under `design/cli-runs/08-title-fix/`
- Do NOT touch: `scripts/main.gd`, `scripts/dungeon_art.gd`, anything under `data/`, any PNG, any `.import`, `project.godot`, `default_bus_layout.tres`, or `design/audit-shots/**`.
- `--import` rewrites hundreds of unrelated `.import` files and `project.godot` on Godot 4.7.2. Revert that churn with `git checkout -- <paths>` before every commit. Never commit it.
- **Don't change any player-facing copy strings**: keys, fallbacks, or text. Keep `COPY.text(...)` keys and fallbacks exactly as they are. If copy looks wrong, list it under [Jam] in REPORT. Known item for that list: `game_title` is still "Swipe" (`data/script-names.json`, `project.godot`) but Nathan locked the name as "Spinheritance". Do not fix it.
- Keep fallbacks working when a texture is missing (`_opt` returns null). Missing layers must stay on today's dummy path.
- Shipped viewport is 1680x1040 and native is 420x260 (4x). Floor line is native y=161, which is shipped 644.

## Beat clock (PIXEL.md, locked)
0-2 s threshold (hill), 2-5 s grab, 5-8.5 s spend, 8.5-11 s swirl, 11-13 s whiteout into the still.
Use named constants: `T_THRESHOLD=2.0`, `T_GRAB=2.0`, `T_SPEND=5.0`, `T_HALL_B=5.0` (its own constant), `T_SWIRL=8.5`, `T_WHITE=11.0`, `T_WHITE_PEAK=12.2`, `T_STILL=13.0`.
Whiteout runs from `T_WHITE` to the peak, then the still fades in by `T_STILL`. The swirl must not wait for the whiteout.

## Fixes (one commit each where practical)
1. **Title layout uses the SCREEN rects** (shipped px). Replace the centred VBox stack with absolutely placed labels. Keep the same FitLabelBox, font sizes, colours and copy keys.
   - Logo rect `(340,80,1000,160)`, tagline `(260,250,1160,80)`, Click `(340,920,1000,80)`.
   - When `logo.png` exists, hide the code `_title` label entirely.
   - Draw the logo at its own texture size. It is already 4x: 720x160 today.
   - Cap the logo width at 840 shipped (210 native). If it is wider, scale it down uniformly to 840.
   - Centre the logo horizontally inside the logo rect and vertically in its 160 px height. Today's logo lands at x=480, y=80, not y=125.
   - Without a logo, `_title` goes in the logo rect.
   - Keep `_music_lab` editor-only, out of those rects (for example bottom-right).
2. **Drop the duplicate run door and lantern** on the hill: remove the `_door` blit and the lantern-item blit next to Nib. `hill_strip.png` already paints the cabin, the run door and the lit window. `_door` can go entirely if nothing else uses it.
3. **Nib's scale and floor.**
   - Draw Nib at the texture's own pixel size (textures are already 4x): `nib_lantern_f*` when present, otherwise `nib_idle_f0`. No fixed 96x96 squash. Keep aspect.
   - Pivot is the centre of the feet on floor y=644.
   - Plant Nib at the hill's cabin door, native x≈51 (shipped 204) in strip space, so he scrolls with the hill pan and stays at the door ("does not follow").
   - Animate `nib_lantern_f0..fN` if there are several frames (~3 fps).
4. **Sizes and frames.**
   - Items in motion (flying in, held/orbiting, thrown, swirling) draw at 96x96 shipped (24 native).
   - Monsters keep the texture aspect ratio and use an integer multiple of the texture size. Targets by drawn height: about 128 for small monsters, about 192 for ogre and spider_queen. Dragon is at least 256 tall (64+ native): for example the 128x144 card at 2x is 256x288.
   - Load ALL frames: `item_<id>_f0..fN` and `mon_<id>_f0..fN` through `_seq()`. Fall back to the single `art.item_tex` / `art.monster_still` texture.
   - Animate items around 4 fps (bob) and monsters around 10 fps.
5. **Timing.**
   - Swirl starts at `T_SWIRL=8.5`: hero glides to the centre, and remaining held loot and the monsters orbit.
   - **Grab shows the item.** Catch items (pocketwatch, lantern, grimoire, healing_potion) and the two spend items (da_boot, helmet) fly in from the right during 2-5 s.
     - Use a crossing test, `ix <= hx + 20`, not a narrow window that frame-skips can miss.
     - Each catch triggers the grab animation at that moment.
     - Caught items stay visibly attached: orbit or hold next to Sprout.
     - Misses (lucky_nickel, sledgehammer) fly past and leave.
   - **Spend actually fires.** Use time-based one-shots that cannot be skipped. If a spend item isn't held yet when its beat comes, force it held first.
     - Boot is thrown at about 5.6 s with the throw/swipe animation. It flies back-left into the nearest chasing monster, that monster flashes "hit" and is knocked back, and the boot leaves the screen (gone).
     - Helmet is used at about 7.0 s (block animation if available) and then leaves the screen (gone).
     - Kept loot stays.
   - **Hall B** swaps at `T_HALL_B`, not at `T_SPEND`'s old 8.5.
   - **Monsters.** Never spawn or draw a monster before `T_THRESHOLD`; nothing on the hill.
     - Stagger their entry from off-screen left (behind Sprout) inside the hall.
     - Each eases in over about 0.6 s to a fixed chase slot behind the hero (x = hero_x minus a per-monster gap, all on the floor line), then holds that slot with a small bob. No drift.
     - Ogre, hornet_swarm, spider_queen and dragon enter during the spend beat (they crowd in).
6. **Facing and pans.**
   - Monsters face right (toward Sprout, who faces right). The card art for `dragon` and `ogre` faces left, so draw those two flipped horizontally (negative-width rect, or `draw_set_transform`). Teaser `mon_*` files are authored facing right and are never flipped.
   - Sprout is never flipped.
   - Pans snap to 4 shipped px: floor every strip pan to a multiple of 4.
   - Snap actor draw positions to the 4 px grid too.
7. **No copy changes** (see constraints).

## Beat dump (headless "captures") — required
Godot `--headless` can't render pixels, so record draw calls instead.

- Add a debug recorder to `title_teaser.gd`. When a `_rec: Array` is non-null, `_blit` and `_blit_strip` append `{tex: resource_path, rect: [x,y,w,h], flip_h: bool, mod: [r,g,b,a]}`, in draw order. Zero behaviour change when `_rec` is null.
- Add `debug_capture(t: float) -> Dictionary`. It fast-forwards from `open_teaser` in fixed 1/60 s steps through `_process` logic (so one-shots fire), runs the draw logic once into the recorder, and returns:
  - `{t, blits, white, still_a, hall_strip_in_use, title_visible, labels:[{name, rect, visible}], logo_rect}`
- Add `tools/qa/title_teaser_beats.gd` (`extends SceneTree`):
  - Build `art` the way `main.gd` does: `preload("res://scripts/dungeon_art.gd").new()`, then `setup()` if it exists.
  - Create the teaser with `setup(art, null)` and set its size to 1680x1040.
  - Capture t = 1.0, 3.6, 5.7, 7.1, 9.5, 11.6, 13.5.
  - Write JSON to `design/cli-runs/08-title-fix/beats.json`.
  - Assert, printing each result:
    - (a) no monster blit at t<2;
    - (b) logo blit rect == [480,80,720,160] and `_title` hidden at 13.5;
    - (c) at least one held catch item is drawn at 3.6 and at 5.7;
    - (d) the boot is gone by 7.1 and the helmet by 8.0;
    - (e) hall B is in use at 5.7;
    - (f) at 9.5 the swirl is on (hero near the centre);
    - (g) every strip and actor blit x/y is a multiple of 4;
    - (h) dragon blit height >= 256 and dragon/ogre have flip_h true;
    - (i) a monster's offset from the hero varies by no more than ±12 px between 6.5 and 8.0 (no drift; sample several times).
  - Print `TITLE_BEATS OK` or `TITLE_BEATS FAIL <list>`, and exit non-zero on failure.

## Checks (headless; run in this order and paste results into REPORT)
1. `--headless --path . --import`, exit 0. Then revert the unrelated churn.
2. `--headless --path . --quit`, exit 0, with no SCRIPT ERROR or parse errors.
3. `--headless --path . -s res://tools/qa/title_teaser_beats.gd`, `TITLE_BEATS OK`.
4. `py -3 tools/qa/check_title_teaser.py` and `py -3 tools/qa/check_ui_pngs.py`. Revert `design/audit-shots/**` if they rewrite it.
5. `--headless --path . -s res://tools/qa/check_shot_cli.gd` stays green (it shouldn't be affected).

Commit the beat dump and REPORT as the last step. Do not push.
