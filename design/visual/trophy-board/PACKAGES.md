# PACKAGES — Trophy Board redesign: parallel cloud-agent split

Base: `Nathan-Elequin/swipe` @ `playtest/latest` (f0ca1efa). Each package = one branch and one PR into `playtest/latest`.
Specs: `SCREEN-trophy-board.md` (behaviour, layout, copy), `ASSETS.md` (art and audio ids), `AUDIT.md` (what exists, with line numbers; raw hits in `AUDIT-grep-appendix.md`).
**Hard rules for every agent:**
- Never show "Tier" or "ATK".
- All strings go through `PLAYER_COPY.text(key, fallback)` and are added to `data/player-copy.json`.
- Integer scales only.
- Respect `Engine.time_scale`.
- Art loads must fall back to placeholders (`ColorRect`/`StyleBoxFlat` of the same rect) when the PNG is missing.
- **Put new logic in new files.** Edits to `home_cabin.gd` (6.8k lines) and `main.gd` (31k lines) must be thin call-sites, to keep merges clean.
- Run every touched selftest headless with Godot 4.7.2 (`tools/qa/run_*.sh` pattern).

## Order

```
Wave 1 (parallel):  A  Delete + cabin-save migration      B  Board scene + model      D  Gates, map states, sequences
                         │                                  │                            │ (merges after B; wires to B's signals)
Wave 2 (parallel):  C  Homecoming (needs A + B)           E  Nib relocation, reduce-motion, audio hooks (needs B; rebases on A)
```

Strict dependencies:
- **C after A.** Both rewrite the main.gd run-end paths: A removes the progress menu, C fills in `_go_home`.
- **C, D-wiring and E after B.** They consume the model API and the board node.
- A, B and D(core) are file-disjoint except for one-line hooks, listed per package.
- Merge order: **A → B → D → C → E**.

### Shared contract (B owns it. Agents in A, C, D and E code against it from day one; B must implement exactly this.)

```gdscript
# scripts/cabin/trophy_board_model.gd   (class_name TrophyBoardModel, all static, no nodes)
static func board_ids(rules: Dictionary, items_by_id: Dictionary, pool_id: String) -> Array[String]  # membership rule, SCREEN §3
static func faces(rules: Dictionary, items_by_id: Dictionary) -> Array[Dictionary]                  # {pool_id, name, slug, index, rows:{3:[],2:[],1:[]}}
static func layout(face: Dictionary) -> Dictionary                                                   # {mode:"normal"/"compact", slot:int, rects:{id:Rect2}}  (face-local px)
static func claimed_unique(state: Dictionary, face: Dictionary) -> int
static func lights_lit(rules: Dictionary, state: Dictionary, face: Dictionary, held := []) -> int     # latched 5 if portal open
static func lever_state(rules, state, face) -> StringName                                             # &"locked" / &"ready" / &"spent"
static func is_complete(state, face) -> bool
static func slot_state(cabin_seen: Dictionary, state: Dictionary, id: String, held := []) -> StringName  # &"unseen" / &"seen" / &"claimed"
static func item_status(...)        # moved from CollectionJourney for the hotbar New! badge

# scripts/cabin/trophy_board.gd   (class_name TrophyBoard extends Control; child of room "hall")
signal face_changed(index: int)
signal lever_pulled(face_index: int)
signal slot_clicked(card_id: String)
signal wants_pan_left()               # ← on face 0
func setup(rules, items_by_id, campaign_state, cabin_seen, hold: Array) -> void
func refresh() -> void
func current_face() -> int
func slide_to(index: int, instant := false) -> void        # returns after the tween; await board.slide_done
func slot_global_center(card_id: String) -> Vector2
func place_claimed(card_id: String, fx := true) -> void     # used by C
func flash_light(face_index: int, light_index: int) -> void # used by C
func set_lever_ready_fx(on: bool) -> void
func play_gild(face_index: int, instant := false) -> void   # used by D
func handle_nav(dir: int) -> bool                            # true = consumed (home_cabin._input calls this when in hall)
var reduce_motion := false
```

Campaign shell additions (D owns them): `portal_opened(state, biome_id)`, `open_portal(rules, state, face_pool_id)` (= `stamp_map_piece` + endless), `grant_shortcut(rules, state, biome_id)`, and `state.shortcuts` / `shortcut_fresh` / `board_complete_seen` / `migrated_board_v1`.

---

## A. Delete Outpost, centre door, cabinets, PR #447 menu and Journey A; cabin-save migration

**Goal:** remove every piece named in Nathan's locked decision #1. Afterwards the game still runs, and run ends land at the cabin exterior and then the hall (or main, if the hall is locked), with banking unchanged. **Nothing new is drawn yet.** The hall shows an empty room with a placeholder label `TrophyBoard` (B fills it in).

**Files touched**
- `scripts/main.gd`:
  - Replace `_open_progress_menu` / `_finalize_progress_menu_result` / `progress_menu_handled_return` with one `_go_home(kind, new_ids, held_ids, push_block)` that does the existing ledger work and then `home_cabin.open_cabin(true, …)`. All 6 callers (AUDIT §4).
  - Remove the Journey A milestone receipts; keep the ledger in `_campaign_bank_from_hand_with_milestones` (rename it to `_campaign_bank_from_hand`).
  - Remove the mudroom-loadout use at about 6147.
  - The tutorial end goes to `play_arrive_splash` (R8).
- `scripts/home_cabin.gd`:
  - `ROOM_ORDER` drops mudroom.
  - Delete mudroom vars and funcs, `_unlock_mudroom_with_hall`, `open_cabin_after_progress_menu`, `open_hall_after_push_block`, `focus_biome_case`, `_fill_biome_cases`, the hall gauge and plaque, and the cabinet ceremony FX (keep the `_bank_hold` / `bank_pending` data plumbing and the ceremony-gen tokens).
  - `_fade_to_interior(target)` gets a target parameter.
  - Strip "mudroom" in `_read_v2` and erase `mudroom_loadout` in `_save` (R1).
- Delete `scripts/cabin/room_mudroom.gd`, `scripts/biome_cabinets.gd` (B re-implements its `fixed_slots` order), `scripts/ui/progress_menu.gd` and `scripts/collection_journey.gd`. Move `CollectionJourney.item_status` to a temporary `scripts/cabin/trophy_board_status.gd` shim (B absorbs it).
- `scripts/cabin/room_main.gd`: remove the RunDoor (144–149). `scripts/cabin/cabin_room.gd` hotspot keys.
- `data/cabin-layout.json`: drop mudroom 3–88, main RunDoor 143–163, hall cabinet/gauge/outpost-door nodes (keep BackDoor), `room_order`, mudroom anchors.
- `data/player-copy.json` / `.csv`, `data/author-locks.json` 3325–3346: delete the rows listed in SCREEN §12 "Remove".
- Assets: delete `rooms/cabinets_wall.png`, `cabinets/*`, mudroom and outpost door art, progress-menu UI art. Only delete if `rg` finds no remaining reference.
- Tests: delete the progress-menu and collection-journey selftests, shots and `tools/qa/run_progress_menu*.sh` / `check_progress_menu.py` / `run_collection_journey.sh`. Update `cabin_nav_lock_probe.gd`, `house_unlock_first_return_selftest.gd` (no mudroom pairing), `continuation_inventory_probe.gd`, `logic_qa.gd`, `shot_harness.gd` and `check_campaign_save_copy.py`.

**Depends on:** nothing. Do not touch `campaign_shell.gd` (D) or `held_map.gd` (D).

**Acceptance**
1. `rg -n 'mudroom|Outpost|outpost|progress_menu|ProgressMenu|CollectionJourney|journey_a|RunDoor|biome_cabinets|BiomeCabinets' scripts data` → only migration code and comments that say "removed".
2. Every one of the 6 run-end paths reaches the cabin exterior; clicking the door enters the hall (or main if the hall is locked); banking results match the old ledger (`run_banking_contract.sh` green).
3. Tutorial → reveal → arrive still works (`tip_smoke_selftest.gd` green; this is CI).
4. An old save with `rooms_unlocked:["main","hall","mudroom"]`, `return_room:"mudroom"` and a `mudroom_loadout` loads into main/hall with no errors, and the next save has no mudroom keys.
5. The main room shows no centre door hotspot. The hall has no cabinets and no right door hotspot.
6. Headless boot of `main.tscn` with no errors and no warnings mentioning deleted paths.

**Selftest:** `scripts/dev/legacy_removal_selftest.gd`. It loads fixture saves (`tests/fixtures/save_mudroom.json`, `save_progress_menu_mid.json`), runs `_read_v2` and `normalize`, asserts the stripped keys and room fallback, and greps `ROOM_ORDER` and `cabin-layout.json` for removed ids.

---

## B. Board scene and model (placeholder art)

**Goal:** the carousel board from SCREEN §2–§5, §10 working in the hall with placeholders. It is data-driven and covers hover cards, locked faces, lights and lever states (the lever emits `lever_pulled` only), dots and pips, arrows, rails, keys and wheel, and slides.

**Files touched (new):** `scripts/cabin/trophy_board_model.gd`, `scripts/cabin/trophy_board.gd`, `scripts/cabin/trophy_board_face.gd`, `scripts/cabin/trophy_board_slot.gd`, `assets/ui/trophy_board/SIZES.md`, `scripts/dev/trophy_board_model_selftest.gd`, `scripts/dev/trophy_board_shots.gd`, `tools/qa/run_trophy_board.sh`.
**Files touched (edit):**
- `scripts/cabin/room_hall.gd`: rewrite to host `TrophyBoard`.
- `scripts/home_cabin.gd`: thin calls only. Build the board in hall setup; `_input` hall branch → `board.handle_nav`; `board.wants_pan_left` → existing pan; `_show_lore_panel` loses the tier chip and depth subline; persist `board_face` and `board_viewed`.
- `scripts/dev_bucket_overlay.gd`: on save call `home_cabin.rebuild_board()` and flag layouts that overflow compact mode.
- `data/cabin-layout.json` hall: the board rect and the `room_trophy.png` plate (keep `room_hall.png` until A1 lands).
- `data/player-copy.json`: `board.*` keys.
- Absorb A's `trophy_board_status.gd` shim (`item_status`) and update the hotbar badge caller in main.gd (one line).

**Depends on:** none for the code. It merges after A (rebasing onto A's hall and room_hall edits is small).

**Acceptance**
1. `faces()` with the current catalog gives b1..b5 sizes 14/14/14/12/11 with rows (top/mid/bottom) 3-5-6, 3-6-5, 3-5-6, 2-5-5, 2-5-4. No retired, hold, token or always-starter ids.
2. Moving an item's pool in the pools editor and saving moves it on the board with no restart. A synthetic pool of 9 tier-1 items switches to compact mode. 60 items fails loudly.
3. Slot rects match SCREEN §2/§3 to the pixel (b1 bottom row x 384–1296, y 608; top row x 624–1056, y 272).
4. Unseen = silhouette, with no name on hover. Seen = sprite with the name. Claimed = lit recess, aura and lore. Locked face = all silhouettes, padlock, 5 dark lights, no lever.
5. Lights: banking 5 distinct ids gives 5 lit. Banking the same id twice does not add a light. With `map_pieces` holding the next id, the face is latched at 5 and the lever is spent.
6. Nav: ←/→ slide (0.36 s), ← on face 0 pans to main, → on face 4 bumps, keys 1–5, dots, arrows, rails, wheel (with invert). `board_face` persists across reload.
7. No visible text on the board except the plaque name. `rg -n 'Tier|ATK' scripts/cabin/trophy_board*` is empty.
8. Shots at 1680×1040 for each face × {fresh save, mid save, full save}.

**Selftest:** `trophy_board_model_selftest.gd` (pure: membership, row order, layout rects, lights and latch, lever state, slot state, compact overflow) + `trophy_board_shots.gd` (15 PNGs to `user://shots/trophy_board/`).

---

## C. Homecoming sequence

**Goal:** SCREEN §6. Exterior → click → straight into the hall. Satchel, then per item rise, fly, poof and light (2.0 s each, in board order, minimal slides). Skip button. Nothing-new Nib line. After it: lever prompt, or hand-off to D's shortcut sequence.

**Files touched (new):** `scripts/cabin/homecoming.gd` (`class_name Homecoming`, a node that owns the timeline and takes `board`, `cabin`, `sfx`), `scripts/dev/homecoming_board_selftest.gd`, `tools/qa/run_homecoming_board.sh`.
**Files touched (edit):**
- `scripts/home_cabin.gd`: `open_cabin(walk_in, kind, new_ids, held_ids)` → after `_fade_to_interior("hall")`, `Homecoming.run(...)`. Delete the old `_play_bank_sequence` / `_bank_fx_*` (keep only the bezier helper, moved into homecoming.gd).
- `scripts/main.gd`: fill in A's `_go_home` with `kind`, `new_ids` and `held_ids`, and drop the arrive-in-main default.
- Remove `homecoming_ceremony_selftest.gd`, `homecoming_live_repot.gd`, `run_homecoming_ceremony.sh`, `check_cabinet_homecoming.py` (replaced).

**Depends on:** A (merged), B (merged, or the contract stub).

**Acceptance**
1. Win with 2 new b1 items: exterior → click → hall, face b1. Two items each about 2.0 s ±0.1 (measured at `time_scale` 1). Each reaches its exact `slot_global_center`. Poof, then the slot becomes claimed. A light flashes only when the unique count rises. Chimes rise in pitch.
2. Items from b1 and b2 in one return: b1 items first, one slide right, then b2. Never a slide back.
3. Skip mid-sequence: all remaining items placed instantly, the board ends on the last item's face, and `bank_pending` is empty after the save.
4. Quit mid-sequence (kill the tween and reload): unplaced ids are still in `bank_pending` and replay.
5. Win with nothing new: no satchel, `nib.board.empty.*` line. Loss: `nib.home.loss.*`.
6. When the 5th unique lands, the board slides to that face, `lever_state == ready`, the glow is on, the Nib line plays, and **nothing auto-pulls.**
7. `Engine.time_scale = 2` halves the durations. `reduce_motion` gives fade placement and no fly.
8. The first-ever successful return still runs the key-ring tour in main, then hands off to the hall (E adds the Nib walk).

**Selftest:** `homecoming_board_selftest.gd` (SceneTree). It builds a cabin with a fixture state, runs `Homecoming` at `time_scale` 8, and asserts the order of placed ids, the face-change count (minimal), the light flashes, the `bank_pending` drain, the skip path and the reduce-motion path.

---

## D. Gates, lever→portal sequence, 100% shortcut, map node states

**Goal:** SCREEN §5.1, §7, §8 and the campaign-save migration (AUDIT R2–R6).

**Files touched (new):** `scripts/cabin/board_sequences.gd` (portal and shortcut timelines: rumble, splash, map beat, reveal call, gild), `scripts/cabin/map_path_line.gd` (dashed `Line2D` draw-in), `scripts/dev/board_gates_selftest.gd`, `tools/qa/run_board_gates.sh`.
**Files touched (edit):**
- `scripts/campaign_shell.gd`:
  - `biome_unlocked` = `portal_opened` (i ≥ 1); `can_start` = `shortcuts`; `push_needs_nib` follows `biome_unlocked`.
  - `bank()` no longer sets `won` / `show_drawer`; that moves to after the b5 lever or full collection.
  - New helpers per the contract.
  - `normalize` + one-time `migrated_board_v1` (silent `map_pieces` backfill; grandfather old `can_start` into `shortcuts` + `shortcut_badge_seen`).
  - `cabinet_count` → board count through `TrophyBoardModel.board_ids`.
- `scripts/cabin/held_map.gd`: `_rebuild` three states (fog / known flat with no hit / startable with glow). `present()` opts `read_only`, `reveal`, `shortcut_reveal`. Pointer and badge for `shortcut_fresh`; clear them on launch. Endless tips reworded ("Opens when you pull the last lever"); `TIP_ENDLESS_SEALED_SUB` goes into player-copy.
- `scripts/ui/biome_splash.gd`: allow an art override and a Nib line list (or a thin `PortalSplash` subclass).
- `scripts/main.gd` (thin): expose `bucket_reveal_for(i)` for the sequence. Push-block line `nib.push_block.lever` when 5 are lit but the lever is unpulled. Optional `rows_for_biome` change pending Nathan (C3; do not change without a decision).
- `scripts/home_cabin.gd` (thin): `board.lever_pulled` → `BoardSequences.portal(i)`; on return, check `is_complete && !board_complete_seen` → `BoardSequences.shortcut(i)`.
- Update `campaign_shell_selftest.gd`, `banking_contract_selftest.gd`, `held_map_launch_selftest.gd` and `main_launch_gate_probe.gd` to the new rules.

**Depends on:** B's contract (code against the stub; merge after B).

**Acceptance**
1. A fresh save can start only at Verdant Hollow. b2..b5 are fogged, with no hover or cursor.
2. 5 unique b1 → lever ready. Push deeper in a run is still blocked with `nib.push_block.lever` until the pull. After the pull: `map_pieces` has b2, b2 is shown as **Known** (flat, no hit) and still not startable, and Push works.
3. The pull sequence plays in order: lever → rumble (1.4 s) → portal splash + 2 Nib lines → map fog clear + ink → the **same** `bucket_reveal.play(2, entries)` as the tutorial path (assert the same function and args) + Nib lines → back in the hall with the lever spent.
4. Claim all 14 b1 → gild → shortcut splash → map path drawn from the start to the b2 node, node glow, pointer and badge. b2 is now startable, and launching from it clears the badge.
5. The b5 lever opens Endless (`endless_unlocked`). b5 at 100% gives no shortcut and plays `nib.board.complete_final`. All five at 100% then runs the drawer once.
6. Migration fixtures:
   - (a) old save with 5 in b1 but no map piece (push-block deferred) → b2 open, lever spent;
   - (b) old one-behind start at b3 → b3 still startable, no ceremony;
   - (c) 4 lights with an open portal → lever spent.
7. Reduce motion: no shake, the map path appears whole.

**Selftest:** `board_gates_selftest.gd`. A pure state-table test of `biome_unlocked`, `can_start`, `push_needs_nib`, `lights_lit` latch and migration across 8 fixture saves, plus a SceneTree pass that runs `BoardSequences.portal(0)` at `time_scale` 8 with a spy on `bucket_reveal.play` and `held_map.present` opts.

---

## E. Nib relocation, reduce-motion setting, room audio hooks, pips polish

**Goal:** SCREEN §9 and §11, and audio from ASSETS §F.

**Files touched (new):** `scripts/cabin/nib_host.gd` (resolves the main or hall Nib, react/watch/gasp helpers), `scripts/dev/nib_relocation_selftest.gd`.
**Files touched (edit):**
- `scripts/home_cabin.gd`:
  - `nib_in_hall` save key. The end of `play_key_ring` gets the walk to the hall plus `nib.board.move.*`.
  - Short catch-up walk-in for old saves.
  - `nib_talk`, `_move_nib_x`, `_on_nib` and react all route through `NibHost`.
  - Hide the main-room Nib after the move.
  - `amb.trophy_room` loop start/stop on hall enter and leave.
  - `reduce_motion` save key, forwarded to the board, Homecoming and BoardSequences.
- `scripts/cabin/room_main.gd` / `room_hall.gd`: Nib sprite and hotspot by flag. `data/cabin-layout.json` gets the hall Nib anchor (386,172,24,32).
- `scripts/settings_menu.gd`: a "Reduce motion: on/off" toggle on the `invert_scroll` pattern (signal; main.gd connects it like 1900).
- `data/sfx-map.json`: all `board.*`, `amb.trophy_room`, `sting.portal_open`, `sting.shortcut` and `nib.react` cues, **aliased to the placeholder files** in ASSETS §F until Reel delivers.
- `data/player-copy.json`: `nib.board.*`, `nib.portal.*`, `nib.shortcut.*`, the push-block rewords and the lesson rewords.

**Depends on:** B merged (board node), A merged (main room without the RunDoor). It is independent of C and D but supplies their copy and cues. If C or D lands first they use fallback strings and `cabin.*` cue ids; E swaps those ids in one pass.

**Acceptance**
1. Fresh save: Nib is in main through the tutorial. The first successful return plays the key ring → Nib walks through the side door into the hall → 2 lines → homecoming. After reload Nib is in the hall, and main has no Nib sprite or hotspot.
2. Save with `key_ring_seen` and no `nib_in_hall`: the next hall entry plays the short walk-in once.
3. Nib reacts on every light, the lever ready moment, the gild and the rumble (gasp). Clicking him cycles `nib.idle.*`.
4. The settings toggle persists. With it on: no shake anywhere in the cabin, instant or fade placement, cross-fade slides, a static aura and a static pointer.
5. All new cue ids resolve (`audio_fx` logs no "missing cue"). Room ambience fades in on hall entry and out on leave. Music ducks during the stingers.
6. `text_audit.gd` passes on the new copy (no "Tier", no "cabinet", no "Outpost").

**Selftest:** `nib_relocation_selftest.gd` runs fixture saves through `play_key_ring` at `time_scale` 8 and asserts the Nib host room, the sprite visibility and the one-time flag; then toggles `reduce_motion` and asserts the board, Homecoming and BoardSequences flags and that the shake tween is never created.

---

## Art and audio (not cloud agents)

- **PixelLab batch** (Pixel): ASSETS A → B → D → E → C order. Drop-in paths are fixed, so code needs no change when the art lands.
- **Reel:** ASSETS §F. Replace the aliased placeholder files; ids stay stable.
- Final integration pass after art: shots via `trophy_board_shots.gd` + `biome_splash_shots.gd`, reviewed against SCREEN §2.
