# CURSOR PROMPT: Cabin overhaul, pass 1 (branch `cabin-overhaul-1`)

You are implementing the cabin-as-main-menu overhaul for **Swipe** (Godot 4.7, single scene `scenes/main.tscn`, code-built UI, viewport 1680x1040, web export).

The design is complete; **do not redesign**. Nathan's six decisions are final (SYSTEMS "Nathan's decisions"): gear is cosmetic only, a declined tutorial is never offered again except by the dummy, death shows the Caught sheet with Undo then "Limp home", in-run pause has Master only, the Will tab has "Read it again", and the left-hand drawer is a post-ending secret. These docs are your spec:
- `design/cabin-overhaul/SYSTEMS.md` (read first)
- `design/cabin-overhaul/SCREEN-*.md` (one per surface)
- `design/cabin-overhaul/STORY-BIBLE.md`
- `design/cabin-overhaul/JAM-FLAGS.md`
- `_pixel_extras/JAM-REVIEW.md` (Jam's copy review; already applied to the data files, read it for context only)
- `assets/dungeon/home/SIZES.md`

Function names and line numbers come from the audit (`_pixel_extras/cabin-overhaul-audit.md`). Line numbers drift; search by name.

## Hard rules
1. **Do not invent player-facing text beyond the provided keys.** Every visible string must come from `PLAYER_COPY.text(key, "")` / `fill()` using a key that exists in `data/player-copy.json` after the merge, or from catalog `name` / `lore.json` (and only where a SCREEN doc says so).
   - If you think a string is missing, use an empty fallback, add a `# TODO(copy): <key>` comment, and list it in the PR description. Do not write the English yourself.
   - The only exceptions are the editor-only buttons that already have hardcoded labels (Play Latest, Developer Test, Roster, Script).
2. **Never show the word "Tier"** to players. Monster grade = `journal.weak` / `journal.tough` / `journal.deadly` (or `tier.N.name`).
3. **Never overwrite existing copy or cues.** Use the merge tool (step 2). Do not hand-edit existing rows.
4. **One Seen/Swiped store:** `home_cabin.seen` / `home_cabin.swiped` in `user://home_cabin.json`. New fields go beside them (SYSTEMS §4). No second save file for collection.
5. **No Camera2D. No `change_scene`.** CabinRoot stays a child of Main; rooms pan by tweening `_rooms_host.position.x` (SYSTEMS §1.2).
6. **Web must keep working:**
   - No Quit on web (the bed gives `cabin.bed.web`; the pause Quit stays hidden via `OS.has_feature("web")`).
   - The first click unlocks audio (`AudioFx._input` 911); the intro waits for that click on web (SCREEN-intro.md).
   - Nothing under `_pixel_extras/` or `tools/` may ship.
7. Pixel art: every texture is drawn with NEAREST filtering (the project default), at 4x, from `res://assets/dungeon/home/...`. Positions in the docs are **native**; multiply by `PX = 4.0`. `_hover`/`_press` sprites are 2px larger, so place them at origin − (1,1) native.
8. Keep the existing handlers straight. Mode labels are inverted:
   - `gatehouse` → `_begin_run` (Classic mill)
   - `long_drop` → `_begin_adventure` (Challenge)
   - `shortcut` → `_quick_start`

## Step 0: unpack
1. `git checkout -b cabin-overhaul-1`
2. Unzip `swipe-cabin-overhaul.zip` **at the repo root**. It mirrors repo paths:
   - `assets/dungeon/home/{rooms,doors,props,hero,nib,ui,overlays,fx,cutscenes}/…` (490 new PNGs) and `assets/dungeon/home/SIZES.md` (replaced: old content + new sections).
   - `assets/audio/*.ogg` (58 new) + `assets/audio/CREDITS.txt`.
     - **If the repo's `CREDITS.txt` differs from the zip's**, keep the repo file and append only the zip's section that starts `Cabin overhaul (2026-10-17): new files`.
   - `data/lore.json`, `data/cabin-layout.json`, `data/player-copy.additions.json`, `data/sfx-map.additions.json`.
   - `tools/cabin/merge_cabin_data.py`, `tools/cabin/verify_cabin_package.py`.
   - `tools/audio/cabin_sfxgen.py`, `tools/audio/build_cabin_audio.py`, `tools/audio/cabin_manifest.json`. These are only needed to rebuild audio; they import the audio pass's `tools/audio/sfxgen.py` / `build_audio.py`.
   - `design/cabin-overhaul/*.md`.
   - `_pixel_extras/` (has a `.gdignore`): 1x art copies, review sheets/GIFs/mocks, generator scripts. **Move it outside the repo, or add `_pixel_extras/` to `.gitignore`**, and add `_pixel_extras/*` to the Web preset `exclude_filter` in `export_presets.cfg` (next to `design/home/*,tools/*`).
3. Open the editor once so the PNGs import. Check the import defaults: Filter off, Mipmaps off.

## Step 1: verify the package
`python3 tools/cabin/verify_cabin_package.py --audit _pixel_extras/cabin-overhaul-audit.md --extras _pixel_extras` (point both at the moved folder if you moved it; the audit is optional).
- It must print `0 errors`.
- WARNs about lore ids vs `data/catalog.json` are expected if the catalog changed since the audit. **Add a lore entry for any catalog item/monster the script reports as missing only by copying `"journal": ""`** (empty), and list the ids in the PR. Do not write the entries yourself.

## Step 2: merge data
`python3 tools/cabin/merge_cabin_data.py --dry-run`, read the SKIP lines, then run it for real.
- It appends copy rows (skipping existing keys) and merges cues/beds/states/radio into `data/sfx-map.json` without replacing anything.
- Run the verify script again (0 errors).
- Keep the `.additions.json` files in the PR so Jam can review the drafts.

## Step 3: save schema + API (scripts/home_cabin.gd)
1. Implement the v2 schema and migration in `_load`/`_save` (1424) exactly as in SYSTEMS §4. Preserve unknown keys.
2. Add `note_met`, `note_belly`, `is_swiped`, `cabinet_progress`, and make `swipe_ids` (97) return the NEW ids.
3. Call `home_cabin.note_met(id)` from `_make_monster` (3510), skipping when `in_tutorial`.
4. Add the drawer fields (`drawer_hint_said`, `drawer_opened`, `geode_on_mantel`, `drawer_stuck_index`) with the rest of v2. `gear_worn` is cosmetic: no run code may read it.
5. Load `data/lore.json` and `data/cabin-layout.json` once (Main `_ready` next to `_load_catalog` 641; pass them to `home_cabin.setup`).

## Step 4: CabinRoot structure (SYSTEMS §1)
1. Rename the node to `CabinRoot`. Keep `_ext_root` and replace `_int_root` with `_rooms_clip/_rooms_host` + 5 room Controls.
2. New scripts in `scripts/cabin/`:
   - `cabin_hotspot.gd`
   - `room_main.gd`, `room_hall.gd`, `room_study.gd`, `room_workshop.gd`, `room_loft.gd`
   - `cabin_dialog.gd`
   - `cutscene_player.gd`
   - `rope_exit.gd`
   - `sack_peek.gd`
   - overlay scripts for the map, radio, journal, will, and the cards
3. Build every room from `data/cabin-layout.json` (`rooms.<id>` entries: `node`, `file`, `origin`, `size`, `hotspot`, `hover`, `z`) and the anchors in `extra`. No hand-typed rects.
4. Move the existing shelf code (`_hole`, `_shelf_host`, `_rebuild_shelves`, `_wipe_pan` 973, `_on_nav`, `_screen_of_bucket` 733) into the hall room. The hole is now native `Rect2(100,24,260,160)`. Delete `_prev_btn`, `_next_btn`, `_pips` and `_back`.
5. Pan + toast + arrows (`_input` 1558, 1561–1567); Escape order (SYSTEMS §9). Always `set_input_as_handled()`.
6. `_mcp_state` (1431): add `room`, `beat`, `overlay`, `rooms_unlocked`, `tutorial_done`, `new_unseen`, `progress`.
7. `debug_pose(name)` must support every QA state in Step 10.

## Step 5: router + run flow (SYSTEMS §2, §3)
1. `_sync_overlay` (10817): `title` → `home_cabin.show_menu()` (or `play_intro()` on first boot); `rest` → `rope_exit.open(dungeons_cleared)`; `defeat` → the small Caught sheet (`title.lose`, score, `overlay_undo`, `overlay_btn` = `defeat.home` → `_go_home_loss`).
2. `Main._start_route(route)` (SYSTEMS §2.1). Delete `_open_home_from_title` (1739) and the pause "home" branch of `_on_pause_mode` (4017/4027). Hide `btn_start` outside `_authoring()`.
3. `_enter_dungeon_clear` (1695): Classic win → `_classic_swipe_home()` → win homecoming (no victory parchment).
4. `_player_down` (4942/4947): always `phase = "defeat"` (remove the death-after-clear victory). Death never swipes.
5. `_adventure_leave` (1717): keep the swipe; pass the `new_ids` it returns to `_open_home_cabin(true, "win", …)` (1758). `_on_home_cabin_closed` (1769) is no longer part of the menu loop.
6. `_tut_finished` (11217) / `_tut_skip` (11206): set `tutorial_done` / `tutorial_declined`, then back to the cabin (SYSTEMS §5). A declined tutorial is never offered again by Nib; only the workshop dummy offers it.

## Step 6: main room, map, radio, gear, Nib (SCREEN-main-room.md, SCREEN-nib-dialog.md)
- Tutorial gate state machine (SYSTEMS §5).
- The radio knobs call the existing settings setters (`set_master` … `set_ui`).
- The station changes `music_to(<bed>)` and is saved in `radio_station`.

## Step 7: hall, study, workshop, loft (their SCREEN docs)
- Tooltip journal block in `hover_panel.gd` `show_rule` (80) via an optional `journal` argument (SCREEN-trophy-hall.md).
- Hover is now connected for unseen mounts too (tag only).
- Bed = `get_tree().quit()` on desktop only.
- Study: the left-hand drawer (SYSTEMS §7.1, SCREEN-study "The left-hand drawer"): stuck/ajar/opened states, the drawer close-up, the note in the LetterCard, and the lucky geode on the main-room mantel (`LuckyGeode`, visible only when `geode_on_mantel`). Layout entries with `visible_when` are hidden unless that condition holds.
- Journal Will tab: the `journal.will.replay` tag (SCREEN-study).

## Step 8: homecoming, rope exit, sack peek, pause (their SCREEN docs)
- Homecoming win/loss sequences exactly as tabled. Escape fast-forwards.
- Rope exit replaces the rest parchment (z 80, child of Main).
- Sack peek: NEW items only, max 10 drawn.
- Pause: restyle `settings_menu.gd` and fix `_on_dim_input` (318). Add Give up (with a confirm) and Peek. Remove the start-over row.
- Hand glint on never-swiped hotbar cards (SYSTEMS §3.3).

## Step 9: cutscenes (SCREEN-intro.md, SCREEN-keyring.md, SCREEN-ending.md)
- One `cutscene_player.gd` for the intro and ending; the key ring is a scripted sequence in the cabin.
- Web: the intro waits for the first click (first boot only; a replay never waits).
- Intro replay from the Will tab (SYSTEMS §7.2): skippable, ends in the study, leaves `intro_seen` / `nib_first_done` alone.
- After the ending: the drawer unlatch cue + `drawer.hint` once (SCREEN-ending).

## Step 10: QA with godot-mcp
Run the game via godot-mcp and take a 1680x1040 screenshot of **each** state below. Use `home_cabin.debug_pose(...)` / `debug_seed(...)` or play to the state. Save them to `design/cabin-overhaul/qa/<state>.png` and attach them to the PR. Compare against `_pixel_extras/review/mocks/*.png` and `room_*_4x.png`.

| # | State | Check |
|---|---|---|
| 1 | fresh save → intro p1 (web build: no audio until click) | frame at (168,128), caption, Skip |
| 2 | intro p5 → main room, Nib `nib.first.1` | dialog box, bust talking |
| 3 | main room, tutorial gate (Nib psst + prompt bubble) | only main room, SideDoor chained |
| 4 | run door clicked → interrupt with 2 choices | Nib walked to 232 |
| 5 | map close-up, Long Drop selected, 3 deep flags | pins, hero marker, legend, Go/Back |
| 6 | radio close-up, knob hover, station 1 | the knobs move the real volumes; station changes the music |
| 7 | gear: helm + goggles + rope worn, hero rocking | overlays follow the frames |
| 8 | rope exit after belly 2, ladder hovered | labels, Peek |
| 9 | sack peek with 3 NEW | only unswiped ids |
| 10 | pause in-run, Give up confirm | Quit hidden on web |
| 11 | Caught sheet with Undo | no "Victory" anywhere |
| 12 | loss homecoming at L5 (peer into the empty sack) | moth, limp sack |
| 13 | first win homecoming: items on the rug, NEW cluster at the locked door | then the key ring starts |
| 14 | key ring: hall door unlocking (f1 + sparkle) | `rooms_unlocked` updates per door |
| 15 | trophy hall: NEW glow + tag + tooltip with journal | tooltip skin, footnote, `cabin.tip.new` |
| 16 | hall shelf page 2 via arrow; `ui_right` at the last page pans to the study | |
| 17 | study journal: bestiary page (met) and unmet page | Weak/Tough/Deadly, never "Tier" |
| 18 | study will close-up, seal broken | |
| 19 | workshop: Brag-o-Meter card, Patents card, dummy dialog | |
| 20 | loft: bed dialog (desktop) and `cabin.bed.web` (web), trunk letter | |
| 21 | ending p2 + main room `ending.continue` | |
| 22 | v1 save migrated (seen/swiped only) | intro once, no interrupt, key ring once |
| 23 | study before the ending: drawer clicked (rattle f1) + `drawer.stuck.1` | no keyhole, nothing opens |
| 24 | main room right after the ending: `drawer.hint` | unlatch cue played once |
| 25 | study after the ending: drawer ajar + knob glint | hover `cabin.hot.drawer_ajar` |
| 26 | drawer close-up, geode glowing, note LetterCard open | `drawer_note` text, Take + Close tags |
| 27 | main room with the lucky geode on the mantel | sparkle on arrival, `cabin.geode.line.1` |
| 28 | journal Will tab with "Read it again"; replay panel 1; back in the study | skippable, `intro_seen` unchanged |
| 29 | declined tutorial, then several run-door clicks and a loss | Nib never interrupts; the dummy still offers it |
| 30 | in-run pause | Master slider only |

**QA checklist** (tick each in the PR):
- [ ] `verify_cabin_package.py` prints 0 errors after the merge.
- [ ] No player-facing string without a copy key; grep the new scripts for quoted English (except editor labels).
- [ ] The word "Tier" appears in no visible text.
- [ ] Dying never swipes and never says "Victory". Classic win and rope climb swipe the held hand only.
- [ ] Cabinet total = live non-token items; gauge, Brag-o-Meter, milestones and ending all agree.
- [ ] `user://home_cabin.json` v2 round-trips; a v1 file migrates; unknown keys survive.
- [ ] Escape priority (SYSTEMS §9); pause never stacks on the cabin.
- [ ] `get_tree().paused` is true in the cabin and false in runs; the fire/cat tick in the cabin.
- [ ] Web export: builds, no Quit, audio starts on the first click, `_pixel_extras` and `tools` not in the pack.
- [ ] All hover/press sprites line up (no 1px jump) at 4x.
- [ ] Hotkeys F2/F3/F4 and the editor strip still work in the editor only.
- [ ] Tutorial (How to Play) still runs end to end from Nib and from the dummy.
- [ ] Gear never changes a run (grep run code for `gear_worn`: no hits).
- [ ] The drawer cannot open before `ending_seen`; the lucky geode adds nothing to the cabinet count.

## Scope
This is designed as **one Cursor pass**. If it must be split, split at Step 8/9:
- Pass 1 = Steps 0–8 (fully playable menu, homecoming, rope exit, pause).
- Pass 2 = Step 9 cutscenes. Until then, the intro/key ring/ending are skipped by setting the flags directly.

Do not split anywhere else, because the router, save and homecoming depend on each other.
