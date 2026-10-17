# SYSTEMS: the cabin becomes the main menu

Swipe, Godot 4.7, viewport 1680x1040. Branch `cabin-overhaul-1`. Every function name and line number below comes from `cabin-overhaul-audit.md` (2026-10-17). Line numbers drift, so search by name.

Words used here:
- **native** = the 420x260 art grid.
- **4x** = shipped pixels. Every rect is given as native, and as 4x where it matters.
- **cabinet** = the trophy hall shelves. **swiped** = brought home.
- **belly** = one Challenge dungeon (`dungeon_index + 1`).

## Nathan's decisions (2026-10-17, final)
These answer the six open questions from pass 1. They are not up for redesign.
1. **Gear rack is cosmetic only.** Wearing gear changes how the hero looks in the cabin and homecomings. It changes nothing in a run: no stats, no perks, no run effect, nothing saved except `gear_worn`.
2. **Tutorial decline is final.** Nib asks once. After `nib.interrupt.no` he never interrupts again (no psst, no prompt bubble, no re-ask on later door clicks or losses). The workshop practice dummy still offers the tutorial any time (`cabin.dummy.ask`).
3. **Death shows the small Caught sheet** (`title.lose`, keeps `overlay_undo` working), then `defeat.home` ("Limp home") → loss homecoming.
4. **In-run pause has the Master slider only.** The radio in the main room keeps all five volumes.
5. **Intro replay:** a "Read it again" tag (`journal.will.replay`) on the journal's Will tab replays the intro (§7.2, SCREEN-study, SCREEN-intro).
6. **The left-hand drawer is a post-ending secret** (§7.1, SCREEN-study "The left-hand drawer"). Before the ending it stays stuck and keeps the joke; after the ending it unlatches and holds Grandpa's rocks, a last note and the lucky geode (a mantel cosmetic).

## 1. Architecture

### 1.1 Where CabinRoot lives
There is no new main scene and no `change_scene`. `scripts/home_cabin.gd` stays as the script, and its node is renamed `CabinRoot`.

| Rule | Detail |
|---|---|
| Parent | Still added in `Main._build_ui` (1019–1025), in the same slot. |
| Draw order | z 95, full rect. |
| Process | `PROCESS_MODE_ALWAYS`, so the fire and cat keep ticking while `get_tree().paused`. |
| Signals | `closed`, `item_hovered`, `item_unhovered` stay. `inspect_wanted` stays dead. Add the new signals in §1.4. |
| Exterior | `_ext_root` is kept and used only for homecoming walk-ins (`_play_arrive` 433). |
| Old interior | `_int_root` (old single interior) is replaced by `_rooms_host` (§1.2). |
| Layout | Read from `res://data/cabin-layout.json`, a copy of `layout.json` shipped in this package. No rect is typed into code. |

```
CabinRoot (ColorRect, home_cabin.gd, z 95, ALWAYS, mouse STOP)
├── _ext_root            (existing exterior; homecoming arrivals only)
├── _rooms_clip          (Control, full rect, clip_contents = true)
│   └── _rooms_host      (Control, position (0,0), size (8400,1040) = 5 x 1680)
│       ├── RoomMain     (Control, x 0)      scripts/cabin/room_main.gd
│       ├── RoomHall     (Control, x 1680)   scripts/cabin/room_hall.gd  (owns the old _hole/_shelf_host)
│       ├── RoomStudy    (Control, x 3360)   scripts/cabin/room_study.gd
│       ├── RoomWorkshop (Control, x 5040)   scripts/cabin/room_workshop.gd
│       └── RoomLoft     (Control, x 6720)   scripts/cabin/room_loft.gd
├── _toast               (TextureRect ui/room_toast.png + Label, top centre, z 4)
├── _hover_tag           (NinePatchRect ui/tooltip_parchment_9.png + Label, z 5, IGNORE)
├── _overlays            (Control, full rect, z 6): map, radio, journal, will, brag card, patents card, letter card, sack peek
├── _dialog              (cabin_dialog.gd, z 7): Nib box + choices
├── _cutscene            (cutscene_player.gd, z 8): intro / key ring / ending
├── _editor_strip        (VBox top-left, only if Main._authoring()): Play Latest / Developer Test / Roster / Script
└── _fade                (existing ColorRect)
```

### 1.2 Side-pan, no Camera2D
- Room `i` sits at `x = i * 1680`. A pan tweens `_rooms_host.position.x` to `-i * 1680`.
  - 0.45 s, `TRANS_SINE`, `EASE_IN_OUT`. Use the same tween style as `_wipe_pan` (973).
  - Cue `cabin.pan` at the start and `cabin.room_sign` when `_toast` drops in.
- There is no Camera2D. `fly_tip` (z 110), speech (z 96) and pause (z 120) are top_level and would ignore a camera.
- During a pan the hotspots are disabled (`_rooms_host.mouse_filter = IGNORE` until the tween finishes). `_current_room` updates at the end.
- `ui_left`/`ui_right` in `_input` (1561–1567):
  - In the hall they **page the shelves first** (existing `_on_nav` ±1). At the first or last shelf page they pan to the neighbouring room.
  - In every other room they pan to the neighbour, but only if that room is unlocked; otherwise `_bump()` (638) plus `cabin.locked`.
- `_toast` shows the copy key `cabin.room.<id>`:
  - Tween `position.y` from -26*4 to 0 (0.18 s, BACK, OUT), hold 1.2 s, then back up.
- Texture cost: five opaque 1680x1040 room backgrounds.
  - Load the hall, study, workshop and loft backgrounds the first time the player pans toward them (`ResourceLoader.load_threaded_request` when the key ring finishes). Only `rooms/room_main.png` is needed at boot.

### 1.3 Shared hotspot behaviour (`scripts/cabin/cabin_hotspot.gd`)
`extends TextureRect`. It is built from one layout entry `{node, file, origin, size, hotspot, hover, z, note}`.

| Event | Behaviour |
|---|---|
| Hit area | A child `Control` sized to `hotspot` (relative to the room), `mouse_filter STOP`, `mouse_default_cursor_shape = CURSOR_POINTING_HAND`. |
| mouse_entered | Swap to the hover texture at `origin - (1,1)` (hover/press files are 2px larger). Cue `cabin.hover` (pitch is randomised by the map). Show `_hover_tag` 12px (4x) above the hotspot rect, text = its `cabin.hot.*` key. |
| mouse_exited | Back to idle, hide the tag. |
| pressed (left button up inside) | Swap to `_press` for 0.06 s, cue `cabin.click`, then emit `activated(node_name)`. |
| Locked | Shows the locked art with no hover swap. The tag reads `cabin.hot.door_locked`. A click plays `cabin.locked` and `_bump()`, and Nib's small bubble says `cabin.locked`. |
| Busy (`_beat != "idle"`, dialog up, overlay up, pan running) | Hover tags still show; clicks are ignored. |

Every hover/press pair below is in `assets/dungeon/home/`. A prop without its own `_press` file (doors, Nib) uses the hover file plus `modulate = Color(0.85,0.85,0.85)` for 0.06 s.

### 1.4 New CabinRoot API (called from Main)
| Function / signal | Purpose |
|---|---|
| `show_menu(room := "main")` | Interior, idle beat. Replaces the title parchment. Plays `music_cabin()` or the saved radio station. |
| `hide_for_run()` | `loop_stop_all`, hide, **no** `closed` emit. Main unpauses. |
| `play_homecoming(kind: String, new_ids: Array, held_ids: Array)` | `kind` is `"win"` or `"loss"`. See SCREEN-homecoming.md. |
| `play_intro()` / `play_key_ring()` / `play_ending()` | Cutscenes. |
| `signal route_chosen(route: String)` | `"gatehouse"`, `"long_drop"` or `"shortcut"`. |
| `signal tutorial_wanted()` | Nib "Show me how" or the dummy's "Show me again". |
| `signal quit_wanted()` | The loft bed, desktop only. |
| `swipe_ids(ids) -> Array` | **Changed:** now returns the ids that were not swiped before (the NEW ones). Same single store. |
| `note_seen(id)` | Unchanged (87). |
| `note_met(monster_id)` | New. Feeds the bestiary. |
| `note_belly(n)` | New. Updates `deepest_belly`. |
| `is_swiped(id) -> bool` | New. Used by the hand glint and the sack peek. |
| `cabinet_progress() -> Vector2i` | New. Returns (home, total) over live non-token items (§3.1). |

## 2. Router: `_sync_overlay` (10817) and friends

Today the overlay shows when `phase in ["title","victory","defeat","rest"]`, unless the cabin, the tutorial or the bucket-unlock is up. New behaviour:

| phase | Old | New |
|---|---|---|
| `title` | Parchment with 5 mode buttons | `overlay.visible = false`; `home_cabin.show_menu()` if not already visible. Boot (`_ready` 480) goes through `play_intro()` first when `intro_seen == false`. |
| `rest` | Parchment Continue / Leave | `overlay.visible = false`; `rope_exit.open(dungeons_cleared)` (SCREEN-rope-exit.md). `overlay_continue` / `overlay_leave` are never shown again. |
| `victory` | Classic win parchment, or Challenge death-after-clear | Only reached by a Classic win, and the overlay stays hidden: `_enter_dungeon_clear` goes straight to the homecoming (§3.3). `_player_down` never sets `victory` again. |
| `defeat` | "Defeated" parchment + Again | Kept as a small **Caught** sheet (Nathan decision 3): `overlay_title` = `title.lose`, `overlay_score` (`title.dungeons_cleared`, Challenge only), `overlay_undo` (only if the undo stack is non-empty). `overlay_btn` text = `defeat.home` and calls `_go_home_loss()`. Mode buttons, `overlay_sub` and `btn_start` stay hidden. |

Other routing changes:
- `_on_home_cabin_closed` (1769) is no longer used for the menu flow. Keep it for `close_cabin` (141) from MCP or debug only.
  - The Leave path now ends in `show_menu()`, not `phase = "title"` plus the parchment. Specifically: `_cabin_from_leave` → `_reset_run()`, `phase = "title"`, and `_sync_overlay` then calls `show_menu()`, which is a no-op because the cabin is already visible after the homecoming.
- `_open_home_from_title` (1739) and `_on_pause_mode("home")` (4027) are deleted. You are always home between runs. Pause "Give up" replaces the mid-run home button.
- `btn_start` ("New", play chrome): hidden unless `_authoring()`. Starting over mid-run is now pause → Give up → the map.

### 2.1 Starting a run from the cabin
`CabinRoot.route_chosen(route)` → `Main._start_route(route)`:
1. `home_cabin.hide_for_run()`, then `get_tree().paused = false`.
2. `home_cabin.counters.delves += 1`, `last_route = route`, `_save()`.
3. Mode labels are inverted on purpose (audit §12.5):

| route | Calls | Mode |
|---|---|---|
| `gatehouse` | `_begin_run()` (1666) | Classic mill, `adventure = false`. |
| `long_drop` | `_begin_adventure()` (1677) | Challenge. |
| `shortcut` | `_quick_start()` (1993) | Challenge with auto loot. |

4. `home_cabin.note_belly(1)`. These functions already call `_reset_run`, which calls `start_music()`.

## 3. Swipe and cabinet rules

### 3.1 What counts
- **Cabinet total:** every catalog item with `status == "live"`, excluding tokens (`bucket == -1`, today only `spider_egg`). Retired or hold items never count and never get a shelf (the same filter `_rebuild_shelves` uses).
  - Bucket-locked items **do** count toward the total. The shelf shows their row as locked.
- **Home:** `swiped ∩ total`. The gauge, the Brag-o-Meter, the milestones and the ending all read `cabinet_progress()`.

### 3.2 When items come home
| Event | Swipe? | Then |
|---|---|---|
| Challenge clear → rope exit → **Climb home** | `_adventure_leave` (1717) is unchanged: `swipe_ids(hotbar ids)`, the only Swiped write. It now captures the return value as `new_ids`. | `_open_home_cabin(true)` → `play_homecoming("win", new_ids, held_ids)` |
| Classic win (wheel empty, `not adventure`, not tutorial) | **New:** `_enter_dungeon_clear` (1695) calls `_classic_swipe_home()`, which does the same `swipe_ids` collection as `_adventure_leave`. | sting `sting.clear` → `play_homecoming("win", …)`. No victory parchment. |
| Challenge clear → **Delve deeper** | No | `_adventure_continue` (1825), unchanged. Then `note_belly(dungeon_index + 1)`. |
| Death (`_player_down` 4942) | No. Death loses everything. | `phase = "defeat"` **always** (remove the `dungeons_cleared >= 1 → victory` branch at 4946–4947). `sting.defeat`, `music_defeat`. `_advance_bucket_counter` still runs for Challenge, as today. Caught sheet → `defeat.home` → `_go_home_loss()`. |
| Pause → Give up → confirm | No | `_reset_run()`, `phase = "title"`, `play_homecoming("loss", [], [])`. No `_advance_bucket_counter`, because no dungeon ended. |
| How to Play finished or skipped | No | Back to the cabin (§5). |

- `_go_home_loss()` = `_reset_run()`, `phase = "title"`, `_open_home_cabin(true)` with `kind = "loss"`.
- `_open_home_cabin(walk_in)` (1758) gains a `kind` argument. `open_cabin` (113) forwards it to `_play_arrive` (433), which branches into the win or loss arrival.
- NEW = ids in the held hand that `swipe_ids` added for the first time, in hand order, de-duplicated, tokens removed. Every NEW id also goes into `new_unseen` (§4) so its shelf glows until hovered.
- Milestones: after a win homecoming, if progress crosses 25/50/75 % and that value is not in `milestones_said`, Nib says `nib.milestone.25`/`.50`/`.75` and the matching letter unlocks in the loft trunk (`letter_25` …). 100 % triggers the ending (§7) and `letter_100`.

### 3.3 Sack peek and the hand glint
- **Sack peek** (rope exit and pause): lists held ids where `not is_swiped(id)`, tokens excluded, de-duplicated, at most 10 slots. `sack.new_count` gives the full count.
- **Hand glint:** each hotbar card whose `card_id` is not swiped and is not a token gets a `fx/hand_glint_f0..f4` AnimatedSprite2D:
  - Additive, 12 fps, one-shot.
  - Fired by a per-card `Timer` with a random 4–7 s wait.
  - Add it where `main.gd` instantiates `item_card.gd` for the hotbar. The audit does not name that builder; search `item_card` in `main.gd`.
  - Cue: none (visual only, so it doesn't nag).

## 4. Save: `user://home_cabin.json` v2
This is still one file and one store: `seen` and `swiped` stay exactly where they are. Everything new sits beside them. `bucket_progress.json` and `audio.json` are untouched, and the radio station is cabin state, not audio state.

```json
{
  "version": 2,
  "seen": ["throwing_knife"],
  "swiped": ["throwing_knife"],
  "new_unseen": ["lantern"],
  "intro_seen": true,
  "nib_first_done": false,
  "tutorial_done": false,
  "tutorial_declined": false,
  "rooms_unlocked": ["main"],
  "key_ring_seen": false,
  "ending_seen": false,
  "deepest_belly": 0,
  "met_monsters": ["golem"],
  "last_route": "",
  "radio_station": 0,
  "gear_worn": {"head": "", "eyes": "", "belt": ""},
  "letters_read": [],
  "bestiary_read": [],
  "will_read": false,
  "drawer_hint_said": false,
  "drawer_opened": false,
  "geode_on_mantel": false,
  "drawer_stuck_index": 0,
  "milestones_said": [],
  "nib_idle_index": 0,
  "counters": {"delves": 0, "homecomings": 0, "hauls": 0, "losses": 0}
}
```

| Field | Written when |
|---|---|
| `new_unseen` | Added by `swipe_ids`. An id is removed the first time its mount is hovered or clicked in the hall. |
| `rooms_unlocked` | `["main"]` until the key ring plays, then `["main","hall","study","workshop","loft"]`. |
| `key_ring_seen` | Set after the key-ring cutscene. The cutscene is due when `counters.hauls >= 1 and not key_ring_seen`. |
| `deepest_belly` | `note_belly(n)`: max of the bellies entered. Gatehouse counts as 1. |
| `met_monsters` | `note_met(id)`, called from `_make_monster` (3510), same place pattern as `note_seen`. Skips tutorial runs (`in_tutorial`). |
| `nib_first_done` | Set after Nib's three welcome lines (`nib.first.1-3`) play once. Migration: true for v1 players. |
| `gear_worn` | Main-room gear rack. One id per slot (head: helm or cap; eyes: goggles; belt: rope). **Cosmetic only** (decision 1): never read by run code. |
| `drawer_hint_said` | Set when Nib says `drawer.hint` (once, right after the ending; §7.1). |
| `drawer_opened` | Set the first time the left-hand drawer opens (needs `ending_seen`). Stops the glint; the hover becomes `cabin.hot.drawer_open`. |
| `geode_on_mantel` | Set by `drawer.take`. Shows `LuckyGeode` on the main-room mantel and hides it in the drawer close-up. |
| `drawer_stuck_index` | Rotates `drawer.stuck.1..3` (like `nib_idle_index`). |
| `counters.hauls` | Win homecomings. `homecomings` = all homecomings. `losses` = loss homecomings. |

**Migration in `_load` (next to `_save` 1424):**
1. No file → defaults above. This is a fresh player: the intro plays, only the main room is open, and Nib interrupts.
2. File without `version` (v1 `{seen, swiped}`) → keep both arrays, fill the defaults, then:
   - `intro_seen = false`: veterans see the new story once.
   - `tutorial_declined = true`: no forced interrupt for people who already play. `nib_first_done = true`.
   - `counters.hauls = 1 if swiped.size() > 0`, so the key ring plays on their first menu visit and the rooms open.
   - `deepest_belly = 0`, `met_monsters = []`. They fill as they play; the bestiary simply starts fresh.
   - Drawer fields default to false / 0 (a v1 save can't have seen the ending).
3. Write `version: 2` on the next `_save()`.
4. Unknown future keys are preserved on load and save (merge into a Dictionary, don't rebuild it).

`_mcp_state` (1431) must also report `room`, `beat`, `overlay`, `rooms_unlocked`, `tutorial_done`, `new_unseen.size()` and `cabinet_progress()`, so godot-mcp can pose and screenshot every state. Keep `debug_seed` and `debug_pose`, and add `debug_pose("homecoming_win")` etc. (list in CURSOR-PROMPT.md).

## 5. Nib interrupt state machine (tutorial gate)

```
               ┌──────────── tutorial_done == true OR tutorial_declined == true ───────────┐
               │                                                                           ▼
[menu idle] ─ click RunDoor ─► tutorial_done || declined ? ──yes──► open Map (SCREEN-main-room) ─► route_chosen
                                       │no
                                       ▼
                         INTERRUPT: Nib walks 216→232 (nib_walk, 0.4s), gasp
                         dialog nib.interrupt.1 → nib.interrupt.2 + choices
                         ┌──────── nib.interrupt.yes ────────┐   ┌──── nib.interrupt.no ─────┐
                         ▼                                    │   ▼
                  tutorial_wanted → Main._start_tutorial      │  tutorial_declined = true, save
                  (11157). CabinRoot.hide_for_run()           │  dialog nib.interrupt.no_reply
                         │                                    │  → open Map
          _tut_finished (11217): tutorial_done = true         │
          _tut_skip (11206):     tutorial_declined = true     │
                         ▼                                    │
                 show_menu("main") + Nib says nib.tutorial_done (finished only)
```

- **Declining is final (decision 2).** Once `tutorial_declined == true`, Nib never interrupts again: no psst loop, no prompt bubble, no re-ask on later door clicks or after losses. The practice dummy is the only way back into the tutorial.
- While `tutorial_done == false and tutorial_declined == false`, Nib loops `nib_psst` and shows the `nib.prompt` bubble.
- Clicking Nib in that state plays `nib.interrupt.2` with the same choices.
- After that, clicking Nib cycles `nib.idle.1..6` (`nib_idle_index`, saved).
- The map hotspot in the gate state does not open; Nib says `map.first_only`.
- The workshop dummy always offers the tutorial again (`cabin.dummy.ask`). Finishing it sets `tutorial_done`.
- `_tut_skip` / `_tut_finished` stop setting `phase = "title"` plus the parchment. They set the flag, `_reset_run()`, `phase = "title"`, and `_sync_overlay` → `show_menu()`.
- The tutorial's own Skip button (hidden today, `tutorial_guide.gd` 186–188) stays as is. That is not part of this pass.

## 6. Room unlock state machine
```
LOCKED_ALL (rooms_unlocked == ["main"]) ── first win homecoming completes (counters.hauls becomes 1)
     │                                       and key_ring_seen == false
     ▼
KEY_RING (cutscene, SCREEN-keyring.md): Nib finds the ring, then 4 doors unlock in order
     hall → study → workshop → loft. Each unlock: pan to that door's room (the door lives on the
     previous room's right wall), play side_door_unlock_f0..f3 / ladder_unlock_f0..f3, sting.unlock,
     Nib line keyring.door.<room>. rooms_unlocked appends that room immediately (so a crash mid-way keeps progress).
     ▼
OPEN (all 5) ── key_ring_seen = true, save. Pans freely; arrows work.
```
- Loss homecomings never trigger the key ring. Nib consoles the player instead.
- The SideDoor in main is drawn with `doors/side_door_locked.png` (chains) while `hall` is not unlocked. The same holds for the hall→study and study→workshop doors and the workshop ladder (`doors/ladder_locked.png`).

## 7. Ending
When a win homecoming leaves `cabinet_progress()` at total/total and `ending_seen == false`:
- After the shelf flights finish, `play_ending()` runs (SCREEN-ending.md).
- Then `ending_seen = true`, `letter_100` is unlocked, and the menu returns to the main room with `ending.continue` as the button.
- Play continues as normal afterwards. The hall gauge tooltip reads `cabin.hall.full`.
- Right after `ending.continue` closes the scene, the drawer unlatches offscreen (§7.1).

### 7.1 The left-hand drawer (post-ending secret; decision 6)
No new mechanic: one hotspot, three save flags, the existing dialog, LetterCard and pan.
```
STUCK (ending_seen == false)
  click → props/desk_drawer_rattle f0,f1,f2,f0 @ 60 ms, cue cabin.drawer_stuck, Nib drawer.stuck.<1..3> (drawer_stuck_index)
  the existing joke lines stay: will.p5, keyring.door.study, letter_100 ("Mind the left-hand drawer.")
      │ ending.continue closes the ending (ending_seen = true)
      ▼
UNLATCH (once): cue cabin.drawer_unlatch (offscreen clunk) 0.6 s after the main room shows,
  then Nib drawer.hint, drawer_hint_said = true
      ▼
AJAR (ending_seen and not drawer_opened): props/desk_drawer_ajar + fx/drawer_glint on the knob
  (5f @ 70 ms, wait 2.5–4 s), hover cabin.hot.drawer_ajar
      │ click
      ▼
OPEN: props/desk_drawer_open f0..f3 @ 90 ms + cue cabin.drawer_open → DrawerOverlay (SCREEN-study)
  first time: drawer_opened = true, Nib drawer.open.nib
  note → LetterCard with lore.json drawer_note (cabin.scroll)
  lucky geode / drawer.take → geode_on_mantel = true, close, pan to main, LuckyGeode pops in
  (doors/unlock_sparkle, cue cabin.geode_chime), Nib drawer.taken.nib
      ▼
OPENED (drawer_opened): plain props/desk_drawer, hover cabin.hot.drawer_open, click reopens the close-up
```
- If the player closes the drawer without taking the geode, it stays in the drawer (`drawer.take` is offered on every reopen).
- The lucky geode is cosmetic: clicking it on the mantel plays `cabin.geode.line.1/2` (rotating), cue `cabin.geode_chime`. It changes nothing in a run.
- The drawer is in the study, so it only exists after the key ring. The ending needs a full cabinet, which needs the hall, so the study is always open by then.

### 7.2 Intro replay (decision 5)
- Journal → Will tab → choice tag `journal.will.replay` on the left page under the portrait.
- Click: close the journal (cue `cabin.book_close`), then `cutscene_player.play(INTRO, {replay = true})`.
- A replay is always skippable (Escape or `intro.skip`). It never waits for the web audio click (audio is already unlocked), and it does not touch `intro_seen` or `nib_first_done`. Nib's `nib.first.*` lines do not play.
- On finish or skip: fade back to the **study** (not the main room) and resume the saved radio station bed.

## 8. Audit §3: every button gets an object (or a reason)
| Today (audit §3) | Now |
|---|---|
| `overlay_title` / `overlay_sub` (`title.overlay`, `title.sub`) | Gone from the menu. The intro and room signs carry the name. Keys untouched in the copy file. |
| `overlay_tut` How to Play | **Nib** in the main room (interrupt / click) and the **Training Dummy** in the workshop. |
| `overlay_dive` Quick Start | **Map** pin "Grandpa's Shortcut". |
| `overlay_btn` Classic (`title.begin`) | **Map** pin "The Gatehouse". |
| `overlay_adventure` Challenge (`title.adventure`) | **Map** pin "The Long Drop". |
| `overlay_home` | Removed: you are always home. |
| Editor Play Latest / Dev Test / Roster / Script | `_editor_strip`, only in `_authoring()`. The plain hardcoded labels stay because they are not player-facing. |
| Rest `overlay_continue` / `overlay_leave` | **Rope exit**: the hole (Delve deeper, `rope.deeper`) and the rope ladder (Climb home). |
| Win `overlay_title`/`sub`/`score`/`btn` | Win homecoming. "Again" = click the run door. |
| Lose sheet | Small **Caught** sheet kept for `overlay_undo`, plus `defeat.home`. |
| `overlay_undo` | Kept on the Caught sheet only. |
| `btn_start` "New" | Hidden outside the editor. Use pause → Give up. |
| Pause `_title`, `_hint` | Pause board heading = `pause.settings`. `_hint` stays empty. |
| Pause 5 volume sliders | Cabin: **radio knobs** (all five). In-run pause board: **Master slider only** (Nathan decision 4). |
| Pause `_btn_resume` | Pause board, first tag. |
| Pause `_btn_quit` (desktop only) | Pause board tag (desktop only) **and** the loft **bed** (desktop). On web the bed gives Nib's `cabin.bed.web`. |
| Pause `_play` start-over row (How to Play, Quick Start, mill, Challenge, Home) | Replaced by **Give up** (→ loss homecoming) and **Peek in the sack**. Picking a different mode = Give up → Map. |
| Pause `_on_dim_input` (318, dead) | Fixed: click outside `overlays/pause_board.png` = Resume. Test `not board_rect.has_point(event.position)` instead of `x < 0`. |
| Cabin `_back` Exit (`title.leave`) | Removed. Cabin is the menu; quit = bed. `title.leave` is now unused (flag to Jam). |
| Cabin `_door_hit` | Exterior door is only used inside the homecoming walk-in (no click). |
| Gallery doors / pips (`_on_nav` / `_on_pip`) | Hall **shelf arrows** (`ui/shelf_arrow_*`) call `_on_nav(±1)`. Pips removed (room toast + arrows). Room-to-room = real doors. |
| Credits (missing) | **Patents Pending** board in the workshop. |
| Settings (Escape only) | **Radio** in the main room. Escape in the cabin (nothing open, main room) opens the pause board too. |

## 9. Escape (`ui_cancel`) priority inside CabinRoot `_input` (1558)
1. Cutscene → skip to the end (intro/ending only; the key ring cannot be skipped, but each beat advances on click).
2. Dialog with choices → do nothing. Dialog without choices → advance.
3. Overlay (map/radio/journal/will/drawer/cards/sack) → close it with its close cue. A replayed intro counts as a cutscene (rule 1).
4. Room other than main → pan to main.
5. Main room idle → `settings_ui.open_menu()` (235) in cabin mode: Resume, Master slider, Quit (desktop). Give up and Peek are hidden.

Always `set_input_as_handled()`.

## 10. Audio
- New cues: `data/sfx-map.additions.json`, merged into `data/sfx-map.json` `cues` without overwriting. Music beds are added under `music`.
- Radio station `radio_station` 0..3 maps to beds `cabin`, `station_waltz`, `station_tune`, `ending`. Copy is `radio.station.0..3`.
  - Changing the station = `sfx.music_to(<bed>)` plus `cabin.radio_tune`, with `amb.radio_static` for 0.4 s.
  - `show_menu()` plays the saved station instead of always `music_cabin()`.
- Web: AudioFx `_input` (911) already unlocks on first gesture and restarts beds.
  - The intro starts silent on web: panel 1 waits for a click (`intro.next`), and that click is the unlock gesture.
  - `sting.intro` and the `cabin.intro_start` music fire on that click.
- `sfx.speak(&"nib", text)` for every Nib line (existing speech ticks), plus `speech.nib_psst` / `speech.nib_gasp` / `speech.nib_chuckle` as one-shots where noted.
