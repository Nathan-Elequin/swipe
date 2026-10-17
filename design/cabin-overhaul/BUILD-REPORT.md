# Cabin overhaul — Pass 1 build report

Branch: `cabin-overhaul-1`  
Date: 2026-10-17  
Pass 2 (2026-10-17): intro, key ring, and ending play for real. Replay from the Will tab does not touch `intro_seen`.

## Verify

`py -3 tools/cabin/verify_cabin_package.py --audit _pixel_extras/cabin-overhaul-audit.md --extras _pixel_extras`

- **0 errors**, 1 warning (sfx additions now overlap merged cues — expected after the real merge).
- Copy merge (dry-run then real): +209 copy rows skipped existing keys; `pause.ambience` / `pause.ui` skipped as already present. Added `pause.master` / `pause.music` / `pause.sound` to `data/player-copy.additions.json` so SCREEN-pause keys exist (labels match the old hardcoded Master / Music / SFX).
- Catalog vs lore: **44 items / 35 monsters, no mismatches.** Audit Appendix A also 44 / 35.

## Lore vs catalog mismatches

None. Every `lore.json` item id and monster id is in `data/catalog.json`.

## QA screenshots

Saved at 1680×1040 under `design/cabin-overhaul/qa/`. Cutscene states are skipped on purpose (Pass 2).

| # | State | File | Result |
|---|---|---|---|
| 1 | intro p1 | `01_intro_p1.png` | Frame, rain in the window, caption, Skip, `intro.next`. |
| 2 | intro p5 → Nib first | `02_nib_first.png` | Skip lands in the main room; dialog `nib.first.1`, bust talking, SideDoor chained. |
| 3 | main room, tutorial gate | `03_main_gate.png` | Nib psst + `nib.prompt` bubble; SideDoor chained. Bubble sits on the door (layout origin) and clips the last letters of the line. |
| 4 | run door → interrupt | — | Code path exists (`_on_run_door` + interrupt choices). Not screenshotted. |
| 5 | map close-up | `05_map.png` | Sheet + house pin + compass. Pin/Go/Back chrome is thin vs the mock. |
| 6 | radio close-up | `06_radio.png` | Close-up sheet; knobs call the live volume setters. |
| 7 | gear helm+goggles+rope | `07_gear.png` | `gear_worn` set; pegs hide worn pieces. Overlay frames on the sitting hero are incomplete. |
| 8 | rope exit belly 2 | `08_rope_exit.png` | Labels (`rope.cleared`, Climb / Deeper / Peek) draw. Background PNG is see-through over the mill. |
| 9 | sack peek 3 NEW | — | `sack_peek.gd` wired from pause Peek. Not screenshotted. |
| 10 | pause Give up confirm | — | Peek + Give up + confirm exist. Confirm sheet not screenshotted. |
| 11 | Caught + Undo | — | Defeat uses `title.lose` + `defeat.home` ("Limp home"). Not screenshotted. |
| 12 | loss homecoming L5 | — | Walk-in `_play_arrive` still runs; loss-only moth / limp sack table not finished vs SCREEN-homecoming. |
| 13 | first win + NEW at door | — | Win homecoming starts arrive; key ring is a stub (unlocks every room at once). |
| 14 | key ring hall unlock | `14_keyring_panel.png` | Panel `keyring_p1` with bust; Skip hidden. Door-unlock sequence is scripted in the cabin (not skipped). |
| 15 | trophy hall | `15_hall.png` | Shelves, gauge, page arrow, side doors. NEW glow/tooltip not exercised in this shot. |
| 16 | hall page 2 → study pan | — | Arrow pages shelves; `ui_right` on last page pans. Not screenshotted. |
| 17 | study + journal | `17_study.png`, `17_journal.png` | Study room and bestiary overlay. |
| 18 | will close-up | `18_will.png` | Will overlay opens. |
| 19 | workshop | `19_workshop.png` | Dummy, Brag-o-Meter, patents, loft ladder. |
| 20 | loft | `20_loft.png` | Bed, trunk, telescope, mannequin. Bed dialog / `cabin.bed.web` not clicked in this shot. |
| 21 | ending p2 | `21_ending_p2.png` | Deed/stamp panel + Skip. Finish still does cheer, `ending.continue`, then `drawer.hint`. |
| 22 | v1 save migrate | — | `_load`/`_save` v2 with unknown-key preserve. Not screenshotted with a planted v1 file. |
| 23 | drawer stuck | `23_drawer_stuck.png` | Study before ending. |
| 24 | drawer.hint after ending | — | Flag stub plays `drawer.hint` once. Not screenshotted. |
| 25 | drawer ajar | `25_drawer_ajar.png` | Study after ending. |
| 26 | drawer close-up | `26_drawer_open.png` | Overlay opens. |
| 27 | geode on mantel | `27_geode.png` | `geode_on_mantel` shows the layout `visible_when` prop. |
| 28 | Will "Read it again" | — | **Skipped (Pass 2).** Tag is on the Will tab; replay is the intro stub. |
| 29 | declined tutorial | — | `tutorial_declined` turns the gate off; dummy still offers it. Not screenshotted. |
| 30 | in-run pause | `30_pause_in_run.png` | **Master slider only.** Peek, Give up, Quit (hidden on web). Start-over row hidden. Still the old left panel, not the parchment board from SCREEN-pause. |

## QA checklist

- [x] `verify_cabin_package.py` prints 0 errors after the merge.
- [x] No player-facing string invented for the cabin. New scripts use `PLAYER_COPY` / `KIT.copy_text` / lore / catalog. Empty fallback + `# TODO(copy)` if a key is missing. Editor-only labels (Play Latest, Developer Test, Roster, Script) stay hardcoded.
- [x] The word "Tier" is not printed. Journal comment forbids it; grades use `journal.weak` / `journal.tough` / `journal.deadly`.
- [x] Dying never swipes (`_player_down` → `phase = "defeat"`). Classic win and rope climb swipe the held hand only.
- [x] Cabinet total = live non-token items (`cabinet_progress`). Gauge uses that pair. Ending / Brag-o-Meter still need a live playthrough to confirm they agree.
- [x] `user://home_cabin.json` v2 round-trips; unknown keys kept. v1 migrate is in `_load` (not screenshotted).
- [ ] Escape priority (SYSTEMS §9) — implemented in cabin `_input`; not fully playtested against every overlay stack.
- [x] Cabin `PROCESS_MODE_ALWAYS`; tree is paused on the title cabin. Fire ticks.
- [ ] Web export: `exclude_filter` includes `_pixel_extras/*,tools/*`. Quit hidden via `OS.has_feature("web")`. **Did not run an HTML5 export this pass.**
- [ ] Hover/press 1px offset — hotspots use origin − (1,1); not pixel-checked on every prop.
- [x] F2/F3/F4 and the editor strip still build in the editor only.
- [ ] Tutorial from Nib and from the dummy — code paths exist; not run end to end this pass.
- [x] Gear never changes a run (`gear_worn` only in `home_cabin.gd` / `room_main.gd`).
- [x] Drawer cannot open before `ending_seen`; geode is cosmetic (not in `cabinet_progress`).

## What shipped (Pass 1)

- Branch, `_pixel_extras/` gitignore, web `exclude_filter`, CREDITS append (repo file kept; zip section appended).
- Merge of `player-copy.additions.json` and `sfx-map.additions.json`.
- CabinRoot (`scripts/home_cabin.gd`) v2 save, rooms pan (`_rooms_host.position.x`), layout-driven rooms, overlays, rope exit, sack peek.
- Title → cabin menu. Challenge rest → rope exit. Defeat → Caught + Limp home.
- Mode inversion unchanged: `gatehouse` → Classic mill, `long_drop` → Challenge, `shortcut` → quick start.

## Pass 2 cutscenes

- `cutscene_player.gd` plays intro (5 panels) and ending (3 panels). Typing 40 chars/s. Skip / Escape fades out (intro and ending only).
- Web: intro panel 1 waits for the first click before auto-advance and `cabin.intro_start`.
- Will tab `journal.will.replay` calls `play_intro(true)`: skippable, no web wait, `intro_seen` / `nib_first_done` unchanged, ends in the study.
- Key ring is a cabin sequence (gasp, panel, four unlocks, pan). Cannot skip; click advances dialog. Rooms append to `rooms_unlocked` as each door opens.
- Ending finish: hero cheer twice, `ending.continue`, then 0.6 s later `cabin.drawer_unlatch` + `drawer.hint` once.

## Leftover bugs / polish (still Pass 1)

- CabinRoot first boot had size 0×0 (`set_anchors_preset` kept zero offsets). Fixed with `set_anchors_and_offsets_preset`.
- `nib.prompt` bubble clips.
- Map Go/Back/legend chrome is incomplete vs SCREEN-map.
- Gear overlays on the hero sprite are incomplete (pegs hide; sitting-hero layers do not follow walk frames).
- Pause is Master-only but still the old settings panel, not the SCREEN-pause board art.
- Rope exit labels work; the cave PNG does not hide the mill.
- Homecoming win/loss tables (moth, pops, NEW cluster, Escape fast-forward) are only partly on `_play_arrive`.
- Old gallery fields (`_prev_btn`, `_next_btn`, `_pips`, `_back`) still exist as unused vars.
- Existing `user://home_cabin.json` on this machine already had `tutorial_declined`; use `debug_pose("main_gate")` to see the psst state.

## Web

- No Quit on web (pause).
- `_pixel_extras/` and `tools/` excluded from the web pack.
- First-click audio unlock is still `AudioFx._input`. Intro wait-for-click is Pass 2.
- HTML5 export was not built this pass.
