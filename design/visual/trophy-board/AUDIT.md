# AUDIT — Trophy Board redesign (cabin Trophy Hall → one sliding five-biome board)

- Repo: `Nathan-Elequin/swipe` on `playtest/latest` at `f0ca1efa`. Fresh clone: `/workspace/trophy-board/repo`. I only read it; nothing was pushed.
- Engine: Godot 4.7, GL Compatibility. Viewport 1680×1040 (`project.godot`). Cabin art is **420×260 native, shown at ×4** (`CabinKit.PX = 4`).
- Every raw hit with a line number is in **`AUDIT-grep-appendix.md`** (1,900 lines, grouped by topic). This file is the curated map: what each hit is and what happens to it.
- Legend: **DEL** delete · **REWIRE** keep the file but change call sites · **REUSE** keep and build on it · **KEEP** leave alone.

---

## 0. The five biomes (real ids and order)

`data/campaign.json` → `biomes[]`, read through `CampaignShell.biomes_of()`:

| idx | id | name | board items today (live, non-token, non-always-starter) | T1/T2/T3 | lore coverage |
|---|---|---|---|---|---|
| 0 | `b1` | Verdant Hollow | 14 | 6/5/3 | 14/14 |
| 1 | `b2` | Crystal Cavern | 14 | 5/6/3 | 7/14 |
| 2 | `b3` | Ashen Crypt | 14 | 6/5/3 | 4/14 |
| 3 | `b4` | Cinder Forge | 12 (danger_magnet is `hold`) | 5/5/2 | 5/12 |
| 4 | `b5` | Shadow Abyss | 11 | 4/5/2 | 5/11 |

How the counts were made: `catalog.json items[].pool` (1–5) maps to a biome through `campaign.json card_pools` (`"1":"b1"` … `"5":"b5"`). Pool 0 holds the starters (dagger, bandana, caltrops, helmet_hidden) and pool −1 the tokens; neither gets a board. `smoke_bomb` is pool 1, but it is an always-starter (`BucketRules.ALWAYS_STARTER_ITEMS`), and both the reveal screen and campaign drafts already exclude it. Endless (`rules.endless`) is not a board.

Lore is missing for 30 board items: b2 shuriken, signpost, hex, swift_sneaks, catapult, flying_saucer, bag_of_marbles; b3 ale_flagon, double_buckler, spinning_top, shardplate, lucky_nickel, pacemaker, chakram, orb, napalm, polymorph; b4 blood_chalice, sling, bag_of_holding, venom_veins, kiss_of_death, miasma; b5 ball_and_chain, tesla_coil, recycler, love_potion, stone_wall. The claimed hover needs a fallback line for these (see the copy table). Jam owns `data/lore.json`.

---

## 1. Trophy cabinets (five vertical cases): DEL

| What | Path : lines | Notes |
|---|---|---|
| Static model for cases, pages and pegs | `scripts/biome_cabinets.gd` (562 lines, all of it) | `CASES` 74–121 (id/name/tint/accent per biome, **REUSE these tint and accent hexes** for the board backdrops), `fixed_slots()` 385–402 (stable tier→name→id order, **REUSE the sort**), `case_state` 445, `peg_state` 477 (UNSEEN/SEEN/CLAIMED, **REUSE the enum idea**), `pips_lit` 439, `crossed_gate` 501, `bank_sequence` 505, hall-zoom math 521–557, `STUB_NAMES` 285. Move the sort and state helpers into the new `trophy_board_model.gd`, then delete the file. |
| Case node | `scripts/cabin/trophy_case.gd` (1094) | Whole file DEL. The twinkle code `_arm_twinkle` 788 and `_build_peg` 666 are worth reading before writing the slot. |
| Dumbwaiter lift | `scripts/cabin/dumbwaiter.gd` (446) | DEL. Its lever frames `hall/dumbwaiter_lever_f0..2` (32×64) can stand in for the board lever. |
| Hall room script | `scripts/cabin/room_hall.gd` (87) | REWRITE: becomes the board room. Delete `SideDoor`/`SignOutpost` handling 48–85 and `CABINETS_WALL` 7–33. |
| Cabin controller (hall parts) | `scripts/home_cabin.gd` | Signals `cabinet_gate_crossed` 17 and `shortcut_scene_wanted` 19 (never connected; DEL). Hall vars 160–217 (`_shelf_host`, `_hole`, `_shelf_fade`, `_prev_btn`, `_next_btn`, `_cordon`, `_pips`, `_room`, `_max_room`, `_by_bucket`, `_case_*`, `_trophy_cases`, `_dumbwaiter`, `_hall_zoom_*`, `_lore_panel`). Functions: `shelf_page` 717, `shelf_page_max` 721, `_collect_buckets` 2350, `_mount_cell` 2373, `_carve` 2380, `_place_nav` 2415, `_rebuild_pips` 2421, `_on_pip` 2425, `_on_nav` 2429, `_change_room` 2436, `_wipe_pan` 2468 (**REUSE the slide-with-dim pattern**), `_fade_shelf` 2532, `_rebuild_shelves` 2545, `_live_pool` 2571 (**REUSE**), `_group_cards_by_pool` 2582, `_shown_count` 2595, `_case_collected` 2625, `_biome_progress_lines` 2634, `_fill_biome_cases` 2647, `_claimed_subset` 2688, `_hall_banked_dict` 2697 (**REUSE**), `_hall_seen_dict` 2711 (**REUSE**), `_refresh_dumbwaiter` 2723, all `_on_trophy_*` 2739–2767, `consume_map_focus_pool` 2772, `_ensure_dumbwaiter` 2778, `_ensure_hall_zoom_dim` 2803, `_on_dumbwaiter_*` 2819–2841, `_hall_flip_to_item` 2875, `_case_opened_beat` 2917, hall zoom 2982–3096, `_show_lore_panel` 3097–3237 (**REUSE the parchment tooltip, minus the tier chip at +113–125**), `_place_biome_trophy` 3247, `_paint_locked_pool` 3287, case scroll 3344–3396, `_paint_cordon` 3949, `_mount_stem` 3974, `_mount_slot` 3982–4117, `_well_rect` / `_plate_rect` 4118–4135, `_play_burst` / `_play_new_burst` 4136–4195 (REUSE), `_set_glint` 4196, `focus_biome_case` 997, `cabinet_progress` 696 (rename and keep for letters). Input: hall-zoom branches in `_input` 4771–4810. |
| Hall layout | `data/cabin-layout.json` `rooms.hall` 487–651 | Keep `BackDoor` 504–524. DEL `SideDoor` 525–545, `SignOutpost` 546–566, `Gauge` 567–587, `ShelfPrev`/`ShelfNext` 588–629, `Shelf` 630–650. `extra.anchors.hall` 1581–1639: DEL `side_door`, `cases_bounds`, `case_glass`. ADD a `board` anchor block (see SCREEN). |
| Hall art | `assets/dungeon/home/cabinets/*` (54 PNG), `assets/dungeon/home/hall/dumbwaiter_*` (7), `rooms/cabinets_wall.png` (the room plate with the five cases painted in) | DEL once the board ships. KEEP `hall/lore_corner_brass.png`. `rooms/room_hall.png` has the old painted board frame and a chained right door; it becomes the source for the new plate (ASSETS A1). |
| Tests | `scripts/dev/biome_cabinets_selftest.gd`, `tools/qa/check_trophy_pegs_fit.py`, `scripts/dev/homecoming_ceremony_selftest.gd`, `scripts/dev/homecoming_live_repot.gd`, `tools/qa/check_cabinet_homecoming.py`, `tools/qa/run_homecoming_ceremony.sh` | DEL or replace with the board tests (PACKAGES). |
| Docs superseded | `design/trophy-hall/*`, `design/cabin-overhaul/SCREEN-trophy-hall.md` | Mark them superseded by `SCREEN-trophy-board.md`. Do not delete design history. |

## 2. Outpost room (mudroom): DEL

| What | Path : lines |
|---|---|
| Room script | `scripts/cabin/room_mudroom.gd` (250, all). Wall map, title, Space hint. |
| Room order | `home_cabin.gd:38` and `cabin_kit.gd:21` `ROOM_ORDER` contain `"mudroom"`. `cabin-layout.json extra.room_order` 1254–1261. |
| Room registry | `home_cabin.gd:5050` (`"mudroom": preload(...)` in `_build_rooms`). |
| Unlock pairing | `home_cabin.gd` 4399–4403 (`_read_v2` pairs hall and mudroom), 5481–5483 (`_unlock_spot` adds mudroom with hall), `_unlock_mudroom_with_hall` 6018–6025. |
| Nav | `_on_side_door` 5976–5989 (`"hall"` → mudroom branch), `_on_back_door` 6027–6029 (`"mudroom"`), `pan_to` 5337–5339, `_pan_unlocked` 5381–5383 (toast and refresh for mudroom), `show_menu` 855–856. |
| Loadout (S8) | `home_cabin.gd` var `mudroom_loadout` 60, defaults 4349, read 4404–4408, save 4475, `_mudroom_item_rows` 5819, `_refresh_mudroom` 5834, `_commit_mudroom_loadout` 5845, `_reroll_mudroom_hooks` 5863. `campaign_shell.gd` 55, 87–94, `roll_mudroom_hooks` 601, `set_mudroom_loadout` 623, `mudroom_loadout_of` 633, `_copy_state` 828–829. Consumer: `main.gd:6147–6166` (`_challenge_run_opening_drafts` seats loadout pegs). With the Outpost gone the loadout is always empty, and the opening draft falls back to normal pair offers. |
| Hotspot keys | `cabin_room.gd` 180 (`LeaveDoor`), 213–217 (`OutDoor`, `RerollJar`, mudroom `BackDoor`), 97 (mudroom bg special-case). `_on_hotspot` `home_cabin.gd` 5663 and 5677–5680 (`OutDoor`, `LeaveDoor`, `RerollJar`). |
| Debug | `debug_pose` `home_cabin.gd` 4667–4675 (`"mudroom"`). `scripts/dev/shot_harness.gd` (poses), `scripts/dev/cabin_nav_lock_probe.gd`. |
| Layout | `cabin-layout.json rooms.mudroom` 3–88, `extra.anchors.mudroom` 1699–1724. |
| Art | `assets/dungeon/home/mudroom/*` (5), `doors/door_sign_outpost.png`. Handoffs in `design/handoff/outpost-regen/*` and `design/handoff/mudroom-b/*`. |
| Copy | `player-copy.json` `room.mudroom.name` 4101, `cabin.room.mudroom` ~4107, `mudroom.exit.out` 4139, `mudroom.space` 4145, `mudroom.jar*`, `mudroom.hook`, `mudroom.exit.cabin`, `cabin.hot.door_outpost` 1754, `cabin.hall.sign_outpost` 1866, the back-door row 3516–3518. `player-copy.additions.json` 172, 338–340, 453–455. **`author-locks.json` 3325–3346 locks four of these.** Removing a locked row needs the lock entry removed in the same commit, or the author-lock check fails. |

## 3. Centre "Toward the Outpost" door in the main room: DEL

- `cabin-layout.json rooms.main` `RunDoor` 143–163 (native 250,130 44×66). Anchor `extra.anchors.main.run_door` 1550–1555.
- `room_main.gd` 3 (header comment) and 144–149 (`RunDoor` tag `cabin.hot.run_door` and lock).
- `home_cabin.gd`: `_on_hotspot` `"RunDoor"` 5675–5676 and the gate exception 5672, `_on_run_door` 5762–5773, `_play_run_door_open` 5774–5798, `debug_run_door_open` 6540, and the run-door `hs` lookup at 5778.
- Copy `cabin.hot.run_door` = "Toward the Outpost" (`player-copy.json` 1585–1588, locked 2026-11-05).
- **The door is painted into `rooms/room_main.png`**, at px ≈1000–1176 × 520–790. Deleting the hotspot leaves a painted, dead door, so the plate needs a repaint (ASSETS A2). `room_main.png` also paints the chained right door (`SideDoor` → hall). That door stays.
- `doors/run_door_*` PNGs are still used by the mudroom `LeaveDoor`. Both uses go away, so the PNGs can be deleted after A + B land.

## 4. PR #447 progress menu (`c74257b`): DEL

| What | Path : lines |
|---|---|
| UI | `scripts/ui/progress_menu.gd` (1405, all). Copy prefix `postrun.*`: 30 rows in `player-copy.json`. |
| main.gd wiring | `PROGRESS_MENU` const 47, var `progress_menu` 955, build 2091–2092. Calls: `_adventure_leave` 3221–3222, `_push_interrupt_home` 3277–3280, `_go_home_loss` 3951–3952, `_give_up` 4003–4004, `_classic_swipe_home` 3317–3318, tutorial return 31424–31425. `_open_progress_menu` 4097–4166, `_finalize_progress_menu_result` 4169–4207 (its `"start"` branch is the menu's "start next run" button; the map replaces it). |
| home_cabin.gd | `open_cabin_after_progress_menu` 924–963. `progress_menu_handled_return` meta in `show_menu` 871–872, `_resume_pending_bank_if_idle` 882 and `_play_arrive` 1947. `_ack_bank_presented` 390 (the menu's ack callback). |
| Tests/QA | `scripts/dev/progress_menu_selftest.gd`, `progress_menu_main_routes.gd`, `progress_menu_shots.gd`. `tools/qa/run_progress_menu.sh`, `run_progress_menu_main_routes.sh`, `run_progress_menu_shots.sh`, `check_progress_menu.py`. `banking_contract_selftest.gd` (PR #447 edited it, so re-check it). |
| Docs | `design/visual/SCREEN-progress-menu.md`, `playtest/repot/*/REQ-20261108-progress-menu*` (history; leave it). |

## 5. Journey A collection receipts / status (PR #492 era): DEL

| What | Path : lines |
|---|---|
| Model | `scripts/collection_journey.gd` (259). Statuses 12–16, `gate_projection` 104, `milestones_from_bank` 135, `cabinet_complete_milestone` 202, `quiet_run_summary` 238. **Carve out `item_status()` 62 first.** The in-run hotbar New! badge uses it (`main.gd` 29509–29539, `_apply_collection_item_badge`). Move it to `trophy_board_model.gd`; keep the New! badge, since it is the in-run "not home yet" teaching. |
| In-run strip | `scripts/ui/collection_quiet_strip.gd` (50). It is already dead: `main.gd:1656` sets `collection_quiet = null`, and `_sync_collection_quiet` 29543 returns. DEL the file, the var at 628, and the stub. |
| Milestones in banking | `main.gd` `_campaign_bank_from_hand_with_milestones` 3814–3893 (roster_totals 3836–3853, `milestones_from_bank` 3854, final-clear ordering 3859–3881). Collapse it back to `_campaign_bank_from_hand` (bank only). **Keep `recognize_final_dungeon_clear`.** It sets the durable `final_dungeon_cleared`, and other code reads it. |
| Tests | `scripts/dev/collection_journey_selftest.gd`, `collection_journey_milestones_selftest.gd`, `collection_a_notrun_cases.gd`, `collection_a_live_repot.gd`, `tools/qa/run_collection_journey.sh`. |
| Docs | `design/visual/SCREEN-collection-journey-a.md`. |

## 6. Banking and the existing homecoming ceremony: REUSE the plumbing, replace the FX

- **Ledger (authoritative):** `CampaignShell.bank()` `campaign_shell.gd` 441–461 writes `state.banked[id] = pool_string_at_bank_time`. `home_cabin.swipe_ids` 358 (cabin mirror `swiped`/`seen`), `sync_swiped_from_banked` 307, `mirror_swiped_into_banked` 327.
- **Presentation queue:** `home_cabin.bank_pending` (saved, 85–89, read 4447–4452) and `_bank_hold` (runtime, "counted but not shown yet", 179). `_restore_bank_hold_from_pending` 587. The board must render held ids as **not yet claimed** until the homecoming places them. The current code does this through `_hall_banked_dict()` 2697.
- **Ceremony ownership tokens (REUSE as-is):** `_begin_bank_ceremony` 403, `_owns_bank_ceremony` 412, `_release_bank_ceremony` 417, `_invalidate_bank_ceremony` 428, `_claim_homecoming_staging` 436, tween/FX tracking 453–579.
- **Current S7 FX to replace:** `_offer_bank_sequence` 3397, `stage_homecoming_bank` 3412, `_stage_homecoming_bank` 3416, `_play_bank_sequence` 3473–3605, `_bank_fx_bag_smoke` 3633, `_bank_fx_rays` 3717, `_bank_mount_global_center` 3786, `_bank_fx_arc_to_mount` 3811 (**REUSE the bezier**), `_bank_fx_loud_count` 3875 (DEL: no counter text), `_clear_bank_anim` 3939, `_bank_map_piece_beat` 3613 (DEL).
- **Run-end entry points (main.gd):** `_adventure_leave` 3192 (voluntary bank), `_push_interrupt_home` 3227 (Nib forced home; calls `begin_push_block_bank` 3245), `_go_home_loss` 3942 (death; `_campaign_abort`, nothing banked), `_give_up` 3997, `_classic_swipe_home` 3306, tutorial return around 31410. All six go through the progress menu today. All six must route to the new homecoming.
- **Cabin entry:** `open_cabin` 798 (walk-in builds the exterior and schedules `_play_arrive` 1758), `_show_exterior` 1702, `_on_door` 2326 → `_fade_to_interior` 2142 (hard-codes `"main"` at 2154–2155). `open_hall_after_push_block` 965 (DEL; merged into the homecoming).
- **Counters / house unlock:** `_credit_homecoming_counters` 680, `counts_as_successful_dungeon_return` 673, `_sync_progress_doors` 1412, `play_key_ring` 1135 (first successful return: Nib walks from main and unlocks the hall first at 1189–1196).

## 7. Unlock gates (campaign shell): REWIRE

`scripts/campaign_shell.gd`, a pure static class plus `user://campaign_save.json`:

| Function | Line | Today | After the redesign (see SCREEN §5) |
|---|---|---|---|
| `quota_of` | 134 | `cabinet_quota` 5 | unchanged (5 lights) |
| `cabinet_count` | 148 | counts `banked` entries whose **stored** pool string == pool | count **current** board membership ∩ banked (data-driven; survives Nathan moving items) |
| `biome_unlocked(i)` | 162 | `cabinet_count(prev) >= 5` (automatic) | `portal_opened(biomes[i].id)`: true after the lever pull, which needs 5 lit |
| `pool_unlocked` / `pool_open_for_bucket` | 172 / 182 | via biome_unlocked | unchanged (they follow biome_unlocked) |
| `shortcut_open(i)` / `can_start(i)` | 211 / 224 | **one-behind**: `can_start(i) = biome_unlocked(i+1)`, so 5 in Crystal Cavern lets you start at Crystal Cavern | `can_start(0)=true`; `can_start(i) = shortcuts.has(biomes[i].id)`, granted when board i−1 is **100%** |
| `can_push` | 232 | `biome_unlocked(next)` | unchanged (now needs the portal opened) |
| `push_needs_nib` | 245 | current board < 5 | `not biome_unlocked(next)`: also covers "5 lit, lever not pulled" |
| `stamp_map_piece` / `map_pieces` / `pencil_fresh` | 377 / 343 / 396 | stamped on Leave when ≥ 5 (deferred on Push-block) | stamped **only** by the lever pull; `map_pieces` becomes the "portal opened" list (key kept, no migration) |
| `next_after_pool` | 349 | b5 → Endless | unchanged; the b5 lever opens Endless |
| `cabinets_complete` | 469 | all five ≥ 5 → `won`, `endless_unlocked` | keep as the precondition. `endless_unlocked` is set on the b5 lever pull (not inside `bank()`). |
| `rows_for_biome` | 190 | biome deck = own pool's monsters until cabinets_complete | **conflict with Nathan's reveal copy**, see SCREEN §11 C3 |
| `bank()` | 441 | also sets `won`/`endless_unlocked`/`show_drawer` | bank only. The ending drawer moves after the b5 portal sequence. |
| `debug_bank_matching` / `debug_unlock_all_pools` | 536 / 559 | DEV cheats | update so they also open portals and grant shortcuts |

Callers in main.gd: `_campaign_bank_from_hand*` 3800–3893 (stamps 3826–3831, DEL), `_campaign_card_ok` 3741 (items from open pools: **items already mix across opened pools**), `_campaign_arm_delve` 3689 (`rows_for_biome`), `_finalize_progress_menu_result` 4176 (`can_start` clamp), `_rope_deeper` 3999 (`can_push`), `_on_campaign_start` 3467, `_begin_campaign_delve` 3602. The in-run Nib push-block copy `nib.push_block.1` ("Your {biome} cabinet's only at {n} of 5") needs new wording.

Map piece beat: `scripts/cabin/map_piece_beat.gd` (141). DEL, replaced by the portal sequence. Copy `nib.piece.*` (4 rows): DEL or retire.

## 8. Map nodes: REWIRE

- **Player map:** `scripts/cabin/held_map.gd` (1239). `TRAIL` 23–30 (cabin/start (816,236) → b1 (962,363) → b2 (648,473) → b3 (998,567) → b4 (659,672) → b5 (1020,798)), `ENDLESS_AT` 45, `WAX` 46, `POOL_SLUG` 55 (b2 slug is still `sunken_mire`), `START_BANNER` 67 (painted red "START HERE" on the plate). `present` 209, `_rebuild` 227–297 (**already three-way: `_add_locked` dark blob / `_add_stamp(launchable=false)` / `_add_stamp(launchable=true)` + `LaunchHit_<pool>`**), `_first_launchable_index` 299, `_add_start_banner` 308, `_add_stamp` 396 (the "known" variant still looks like a wax button: needs the flat no-hover treatment), `_add_locked` 448 (becomes fog), `_pulse_focus_stamp` 376, `RouteInk` (`_ink.solid`, `_ink.fresh`) used for the pencil reveal.
- **Wrapper:** `scripts/campaign_map.gd` (244) `start_asked` → `main._on_campaign_start` 3467. `show_drawer` 167 (won drawer). `scripts/cabin/map_overlay.gd` is the archived route sheet: KEEP and ignore.
- **Open from cabin:** main room `Map` hotspot (`cabin-layout.json` 201–221) and Space → `home_cabin.held_map_wanted` → `main._toggle_held_map` 3358. **This is the only run start once the Outpost is gone.**
- Assets: `assets/ui/map/held/map_in_hands_living.png` (1680×1040 plate, names painted), `assets/ui/map/stamps/stamp_<slug>_{idle,hover,press}.png` (112×112), `stamp_locked.png`, `overlays/map_flag.png` 40×56.
- Tests: `scripts/dev/held_map_launch_selftest.gd`, `scripts/dev/main_launch_gate_probe.gd`, `scripts/dev/campaign_shell_selftest.gd` (asserts one-behind `can_start`; must change).

## 9. New-pool reveal screen (after the tutorial): REUSE unchanged

- `scripts/bucket_reveal.gd` (506). `play(bucket_n, entries)` 223–291 (title `bucket.title`, sub `bucket.sub`, silhouettes then pop-in, "Onward" → `finished`). Owned by main: const 32, var 730, build 1947–1951.
- Entries: `main._bucket_entries(n)` 5102 / `_bucket_entry` 5148. Tutorial uses `_tutorial_play_unlock` 31000 → `_tutorial_unlock_entries` 31015 = `_bucket_entries(1)`.
- `_reveal_new_buckets` 5070 is disabled in campaign (`if _campaign_on: return`). The portal sequence calls `_bucket_reveal.play(i+1, _bucket_entries(i+1))` directly.

## 10. Lore / hover

- `data/lore.json` `items{id: {journal, footnotes[], name_ref, status}}` (44 entries). Loaded as `PlayerCopy.lore_pack` and read in `_show_lore_panel` (+80–90). Journal overlay Curiosities tab: `scripts/cabin/journal_overlay.gd` (KEEP).
- Copy: `cabin.tip.journal` "From {grandpa|poss} journal:", `cabin.tip.locked` "Still somewhere in {the_grumble}.", `cabin.tip.seen` "Seen in {the_grumble}. Not home yet.", `cabin.hall.lore_claimed` "Claimed".
- The current lore panel shows a rank chip (`COPY.tier_name`) and a "Wares of the Nth Depth" subline. **Drop both.**

## 11. Nib placement

- Sprite: built in `room_main.gd` 24–44 (`NibSprite` at native (216,172), anims idle/psst/talk/point/gasp/walk). Hotspot `Nib` in `cabin-layout.json` 402–422 (24×32 native).
- Art: `assets/dungeon/home/nib/*`, **96×128 px = 24×32 native** (busts 128×128 for the talk bar). The brief's "~48×48" does not match the shipped Nib. I kept 24×32 native so he stays the same character size.
- Code that assumes Nib lives in main: `_move_nib_x` 5392–5418, `nib_talk` 5582–5586, `play_key_ring` 1150–1175, `_on_nib` 5939, `_gate_on`/`_apply_gate` 5588–5599 (psst prompt), `_on_hotspot "Nib"` 5691.
- Dialog: `_dialog.say([keys], [choices], vars)`, `await _dialog.finished` (`scripts/cabin/cabin_dialog.gd`). Bubbles: `say_bubble(key)` 5577.

## 12. Room order and navigation

- `ROOM_ORDER` = loft, workshop, study, main, hall, mudroom → becomes loft, workshop, study, main, **hall** (hall is the right end).
- Keyboard: `_input` 4815–4823 sends `ui_left`/`ui_right` to `_arrow()` 5029 = **pan rooms**. In the hall, ←/→ must slide the board first and only pan to main from face 0 on ← (old `_on_nav` 2429 did the same). → on face 4 bumps.
- `rooms_unlocked` (cabin save): unlocked by the key ring (`_unlock_spot` 5420, `_sync_progress_doors` 1412).

## 13. Save files and flags

**`user://home_cabin.json`** (`home_cabin._save` 4460, `_read_v2` 4383, `_raw_save` preserves unknown keys):

| Key | Fate |
|---|---|
| `rooms_unlocked` containing `"mudroom"` | **migrate:** strip it on read (and stop the 4399–4403 pairing). If `return_room`/`_current_room` resolves to mudroom → `"hall"` (or `"main"` if the hall is locked). |
| `mudroom_loadout` | stop writing it. `_raw_save` keeps the stale value harmlessly; explicitly `erase` it on save. |
| `bank_pending` | KEEP: the homecoming queue. |
| `swiped`, `seen`, `new_unseen` | KEEP: seen drives the silhouette/seen state. |
| `key_ring_seen` | KEEP: the trigger for the Nib relocation (see SCREEN §9). |
| `lesson_five_finds_said`, `lesson_five_threshold_said`, `lesson_extract_haul_said` | KEEP the flags; their copy says "cabinet" (reword). |
| NEW `nib_in_hall: bool`, `board_face: int`, `board_viewed: [ids]`, `shortcut_badge_seen: [biome ids]` | add (default false / 0 / [] / []). |

**`user://campaign_save.json`** (`CampaignShell.normalize` 61, `_copy_state` 816):

| Key | Fate |
|---|---|
| `banked {id: pool}` | KEEP. Stop trusting the stored pool string for gate counts (use current membership). |
| `map_pieces` | KEEP: meaning becomes "portal opened for biome id". Old saves that already hold an id have that portal opened. **No change for them.** |
| `pencil_fresh` | KEEP: used for the map reveal animation after a lever pull. |
| `mudroom_loadout` | stop reading and writing. |
| `won`, `endless_unlocked`, `drawer_seen` | KEEP. Only *when* they get set changes. |
| NEW `shortcuts: [biome ids]`, `shortcut_fresh: [biome ids]`, `board_complete_seen: [pool ids]`, `migrated_board_v1: bool` | add. |

### Save-migration risks (old saves pointing at the Outpost or old flags)

1. **R1: Outpost as current or return room.** A save or `debug_pose` that lands in `"mudroom"` would `show_menu("mudroom")` with no room. Mitigation: `is_room_unlocked` already falls back to `"main"` in `show_menu` 849. Also strip `"mudroom"` in `_read_v2`, and guard `pan_to`/`_snap_to` against unknown ids.
2. **R2: Gate count drift.** Old `banked` values carry the pool string from bank time. If Nathan has moved an item since, the old `cabinet_count(b1)` and the new board count can disagree. Mitigation: switch the count to current membership. **Portals that are already open stay open** (they are latched in `map_pieces`). A board can show 4 lights with its portal open; the lever stays "spent". Acceptable; it is noted in the SCREEN.
3. **R3: Deferred stamp saves (Push-block crossed 5 without a Leave).** Today the portal is open through the count, but `map_pieces` lacks the next id. Under the new rule `biome_unlocked` would turn **false** for them. Mitigation (one-time `migrated_board_v1`): for every biome with old `cabinet_count(prev) >= 5` and a missing piece, **append it to `map_pieces` silently** so no player loses access. Lever = spent. (Alternative, if Nathan wants the ceremony replayed: leave it missing and the lever shows as ready. My pick is silent.)
4. **R4: Shortcut semantics change.** Old one-behind saves could start at b2 with 5 in b3. New rule: start at b2 needs 100% of b1. Mitigation in the same migration: **grandfather** every `i` where the old `can_start(i)` was true into `shortcuts` (no ceremony, `shortcut_badge_seen` pre-filled).
5. **R5: `bank_pending` from the old S7 queue.** Ids pending at upgrade replay through the new homecoming on the next hall entry. That is intended. Ensure the ids are still board items; drop any that are not.
6. **R6: `won` set early.** Old saves with `won` but without the ending drawer seen keep today's behaviour. Only new completions route the drawer after the b5 lever.
7. **R7: Locked author rows.** Deleting `cabin.hot.run_door`, `cabin.hall.sign_outpost`, `cabin.hot.door_outpost` and the Outpost back-door row requires editing `data/author-locks.json` 3325–3346 and `player-copy.csv`. `tools/qa/check_campaign_save_copy.py` also greps copy, so run it.
8. **R8: Tutorial-return flow.** The tutorial currently ends in `_open_progress_menu(tut_kind…)`. Remove it, and route to the cabin arrive (`play_arrive_splash` → `open_cabin(walk_in)`) with no homecoming items (tutorial items never credit).

## 14. Tests and QA that touch this (by package)

| File | Touches | Fate |
|---|---|---|
| `scripts/dev/banking_contract_selftest.gd` (155 hits) | bank ledger, stamps, push-block | UPDATE (Pkg D owns it) |
| `scripts/dev/campaign_shell_selftest.gd` (75) | gates, one-behind `can_start` | UPDATE (D) |
| `scripts/dev/homecoming_ceremony_selftest.gd`, `homecoming_live_repot.gd` | S7 FX | REPLACE (C) |
| `scripts/dev/biome_cabinets_selftest.gd`, `tools/qa/check_trophy_pegs_fit.py` | cases | REPLACE (B) |
| `scripts/dev/house_unlock_first_return_selftest.gd` | key ring, hall+mudroom pairing, progress menu | UPDATE (A/E) |
| `scripts/dev/cabin_nav_lock_probe.gd` | room nav incl. mudroom | UPDATE (A) |
| `scripts/dev/held_map_launch_selftest.gd`, `main_launch_gate_probe.gd` | map launch | UPDATE (D) |
| `scripts/dev/continuation_inventory_probe.gd`, `logic_qa.gd`, `shot_harness.gd` | mixed refs | UPDATE refs (A) |
| progress-menu and collection-journey tests (6 + 4 QA scripts) | deleted features | DEL (A) |
| `tools/qa/check_cabinet_homecoming.py`, `check_campaign_save_copy.py`, `check_biome_full_bg.py` | grep-based checks | UPDATE strings |
| `.github/workflows/tip-smoke.yml` → `scripts/dev/tip_smoke_selftest.gd` | tutorial → reveal → arrive | must stay green (R8) |
