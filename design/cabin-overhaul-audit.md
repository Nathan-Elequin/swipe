# Cabin overhaul audit — Swipe (Godot 4.7)

Read-only audit for a diegetic home-cabin menu overhaul. No game code, scenes, or data were changed. Gold boxes on `data/content-board.json` were empty.

**Engine:** Godot 4.7, GL Compatibility, project name `Swipe`.  
**Date of audit:** 2026-10-17.  
**Rule of this repo:** almost nothing is a `.tscn`. The playable game is one Control scene that builds every overlay in GDScript.

---

## 1. Scene map and flow

### Top-level scenes

| Path | Root node | Root script | Role |
|---|---|---|---|
| `res://scenes/main.tscn` | `Main` (`Control`, full rect) | `res://scripts/main.gd` | **The entire game.** Only playable scene. |
| `res://addons/godot_mcp/ui/status_panel.tscn` | editor addon UI | `addons/godot_mcp/ui/status_panel.gd` | Godot editor MCP panel. Not player-facing. |

There are **no** title, cabin, run, pause, win, lose, settings, credits, or tutorial scenes on disk.

`scenes/main.tscn` is four nodes of data: a `Control` named `Main` with `script = ExtResource("res://scripts/main.gd")`. Everything else is `Something.new(); add_child(...)` in `Main._ready()` → `_build_ui()` (`scripts/main.gd` 467–484, 667–1046).

### Main scene in `project.godot`

```
run/main_scene="res://scenes/main.tscn"
```

(`project.godot` line 15.)

### Scene changes

**NOT PRESENT:** `change_scene`, `change_scene_to_file`, `change_scene_to_packed`. Grep of `*.gd` is empty.

The game never leaves `Main`. Modes are a string `phase` on `Main` (`scripts/main.gd` 269) plus overlay visibility.

Known `phase` values set in `main.gd`:

| `phase` | Meaning | Set by |
|---|---|---|
| `"title"` | Parchment title overlay | `_ready` 480; cabin close 1776; tutorial skip/finish 11213/11222 |
| `"draft"` | Filling the wheel / mill / challenge setup | `_begin_run` 1668; `_begin_adventure` 1683; `_run_challenge_setup` 2487 |
| `"ready"` | Wheel full, waiting for Spin | `_finish_mill` 3325; `_challenge_begin_play` 2601; `_start_tutorial` 11183 |
| `"spinning"` | Wheel animating | `_on_spin` 4543 |
| `"fighting"` | Faced owner, items or Done | (spin resolve) |
| `"slaying"` | Owner swinging / leave visuals | `_on_done` path 4785 |
| `"rest"` | Between Challenge dungeons (Continue / Leave) | `_enter_dungeon_clear` 1712 |
| `"victory"` | Classic mill cleared, or Challenge death after ≥1 dungeon | `_enter_dungeon_clear` 1707; `_player_down` 4947 |
| `"defeat"` | HP 0 with no prior Challenge clear | `_player_down` 4947 |
| `"devtest"` | Editor Developer Test | `_dev_enter` 1497 |

### How the player moves between surfaces

All of these `add_child` onto `Main`. None of them change scenes.

| Surface | How you get there | How you leave |
|---|---|---|
| **Title parchment** | Boot (`phase = "title"`). Cabin `closed` after Leave. Tutorial skip/finish. Pause “start over” modes that reset. | Buttons on overlay (see §3). |
| **Home cabin** | Title **Home** → `_open_home_from_title` 1739. Pause **Home** → `_on_pause_mode("home")` 4027. Challenge **Leave** → `_adventure_leave` 1717 then `_open_home_cabin(true)` 1735. | Interior **Exit** / Escape on exterior → `close_cabin` 141. Escape on interior goes back to exterior first (`home_cabin.gd` 1569–1581). |
| **How to Play** | Title / pause **How to Play** → `_start_tutorial` 11157. | Tutorial `finished` / `skipped` → title. **Does not open Home.** |
| **Adventure Mode** (label) | Title / pause **Adventure Mode** → `_begin_run` 1666. **This is the classic 8-seat mill.** `adventure = false`. | Wheel empty → `_enter_dungeon_clear` → `phase = "victory"` (not rest, not cabin). Overlay **Again** restarts mill. |
| **Quick Start** | Title / pause **Quick Start** (`title.dive_in`) → `_quick_start` 1993. Sets `adventure = true`, seats Challenge dungeon, auto-picks opening loot, skips pick-two UI. | Same as Challenge Mode. |
| **Challenge Mode** (label) | Title / pause **Challenge Mode** → `_begin_adventure` 1677. Sets `adventure = true`. | Dungeon clear → `phase = "rest"` (Continue / Leave). HP 0 → `_player_down`. |
| **Draft gate** | Classic mill only: `_run_mill` 3147 → `_open_petitioner` 3291 → `_present_gate`. Overlay `draft_gate` (`scripts/draft_gate.gd`). | Take / Pass; after `DRAFT_ROUNDS` (4) → `_finish_mill` → `phase = "ready"`. |
| **Boss fights** | Not a separate scene. Same wheel. Spin (`_on_spin` 4487) faces one owner. Challenge: click a seat first (`challenge_aim`). | Owner HP 0 / leave → `_clear_after_fight` / `_challenge_after_fight`. Wheel empty → `_enter_dungeon_clear`. |
| **Win parchment** | Classic mill: all owners gone → `phase = "victory"`. Challenge: die after `dungeons_cleared >= 1` → still `phase = "victory"` (`_player_down` 4946–4947). | Overlay primary **Again** → `_on_overlay_primary` 1544. |
| **Loss parchment** | `_player_down` when not (Challenge and ≥1 dungeon cleared). | Same **Again**. |
| **Rest parchment** | Challenge dungeon clear only (`_enter_dungeon_clear` 1706–1714). | **Continue** `_adventure_continue` 1825. **Leave** `_adventure_leave` 1717 (walk into cabin). |
| **Settings / pause** | Escape (`ui_cancel`) → `settings_ui.open_menu` 4006. | Resume / Escape / click-dim (broken, see §3) / pick a start-over mode. |

Name trap: the button that says **Adventure Mode** (`title.begin`) starts `_begin_run`, which is the original mill (`adventure = false`). The button that says **Challenge Mode** (`title.adventure`) starts `_begin_adventure` (`adventure = true`, multi-dungeon).

### Autoloads / singletons

`project.godot` `[autoload]`:

| Autoload | Script | Owns |
|---|---|---|
| `MCPGameBridge` | `res://addons/godot_mcp/game_bridge/mcp_game_bridge.gd` | Editor MCP bridge only. Not game state. |

**NOT PRESENT as autoloads:** audio, save, copy, catalog, cabin, player progress. Those are children or `preload` statics on `Main`:

| Object | Where it lives | Owns |
|---|---|---|
| `PLAYER_COPY` | `preload` static `scripts/player_copy.gd` | `data/player-copy.json` lookup |
| `art` (`DungeonArt`) | `add_child` in `_ready` 474–476 | Atlas, item/monster PNGs, `home_tex` |
| `sfx` (`AudioFx`) | `add_child` in `_build_ui` 1011–1013 | Buses, cues, `user://audio.json` |
| `home_cabin` | `add_child` 1019–1025 | Cabin overlay + `user://home_cabin.json` |
| `settings_ui` | `add_child` 1014–1018 | Pause overlay |
| `tut` | `add_child` 923–928 | How to Play / Nib talk box |
| Catalog / runtime | dictionaries on `Main` | Loaded from JSON, not a singleton |

---

## 2. Current home cabin implementation

### Scene path

**NOT PRESENT as a `.tscn`.** Runtime class `scripts/home_cabin.gd` (`extends ColorRect`). Instantiated in `Main._build_ui` 1019–1025:

```
home_cabin = HOME_CABIN.new()
add_child(home_cabin)
home_cabin.setup(art, sfx)
home_cabin.closed.connect(_on_home_cabin_closed)
home_cabin.inspect_wanted.connect(_on_cabin_inspect)
home_cabin.item_hovered.connect(_on_cabin_item_hovered)
home_cabin.item_unhovered.connect(_on_cabin_item_unhovered)
```

Self: full-rect `ColorRect`, `z_index = 95`, `process_mode = PROCESS_MODE_ALWAYS`, `mouse_filter = STOP`, nearest-neighbor, black fill (`home_cabin.gd` 72–80).

Native art is 420×260, shipped at 4× (`const PX := 4.0`, line 11). That matches the 1680×1040 viewport.

### Node tree (full, as built in `_build`)

Godot names are whatever `.name` is set to. Unnamed nodes get engine defaults (`Control`, `Button`, …). Variable names are what code uses.

```
home_cabin (ColorRect, script home_cabin.gd, z=95)
├── _ext_root (Control, full rect, IGNORE)
│   ├── bg (TextureRect, full rect)          cabin_exterior
│   ├── window_glow (TextureRect)            overlay at native (170,208)
│   ├── door_glow (TextureRect)              (216,201)
│   ├── lantern_glow (TextureRect)           (288,133)
│   ├── _smoke (AnimatedSprite2D)            (290,0) anim "puff"
│   ├── _cat (TextureRect)                   (202,64) size 64×60
│   ├── _door (TextureRect)                  (236,134) size 52×66
│   ├── _lantern (AnimatedSprite2D)          (297,139) anim "swing"
│   ├── Hero (Sprite2D, named "Hero")        walk / idle
│   └── _door_hit (Button, flat, empty)      (232,126) size 60×74
├── _int_root (Control, full rect, IGNORE, starts hidden)
│   ├── bg (TextureRect)                     cabin_interior
│   ├── fire_glow (TextureRect)              (0,136)
│   ├── _fire (AnimatedSprite2D)             (76,164) anim "burn"
│   ├── _sack (Sprite2D)                     loot_sack_dropped, (70,205), flip_h
│   ├── _rock (AnimatedSprite2D)             (10,205) anim "rock"
│   ├── _hole (Control, STOP, clip)          native Rect2(140,20,260,160)
│   │   ├── _shelf_host (Control, IGNORE)    rebuilt per room
│   │   │   └── per item: wrap (Control, STOP)
│   │   │       ├── mount (TextureRect, named "mount")
│   │   │       ├── item (TextureRect)
│   │   │       ├── glint (AnimatedSprite2D, additive) anim "glint"
│   │   │       ├── lab (Label, card name)
│   │   │       └── optional burst (AnimatedSprite2D) anim "burst"
│   │   ├── _cordon (TextureRect, IGNORE)
│   │   └── _shelf_fade (ColorRect, IGNORE)
│   ├── _prev_btn (Control, z=6)             gallery door left
│   │   ├── rim (ColorRect)
│   │   ├── pic (TextureRect)
│   │   └── hit (Button, full rect)
│   ├── _next_btn (Control, z=6)             gallery door right (same children)
│   ├── _pips (HBoxContainer, IGNORE, z=5)   one Button per room
│   └── _back (Button, z=5)                  "Exit" at (24,24) 160×52
└── _fade (ColorRect, full rect, IGNORE)     black fade exterior↔interior
```

**AnimationPlayer:** NOT PRESENT.  
**AnimatedSprite2D names (animation ids, not node names):**

| Node var | Animation | Frames (stems under `assets/dungeon/home/`) | Speed / loop |
|---|---|---|---|
| `_lantern` | `"swing"` | lantern_swing_f0, f1, f2, f1 | 5 fps, loop |
| `_smoke` | `"puff"` | smoke_puff_f0..f2 | 1000/260 fps, loop |
| `_fire` | `"burn"` | fire_f0..f2 | 1000/150 fps, loop |
| `_rock` | `"rock"` | hero_rock_f1, f2, f3, f0 | 4 fps, loop |
| plaque glint | `"glint"` | plaque_glint_f0..f3 | 4/1.2 fps idle, 4/0.4 hovered |
| place burst | `"burst"` | trophy_place_burst_f0..f4 | one-shot, then `queue_free` |

Hero walk / sit / drop are **not** AnimatedSprite2D. `_hero.texture` is swapped per frame in tweens (`_walk_hero`, `_play_arrive`, `_play_drop`, `_play_sit`).

Cat is a TextureRect state machine in `_tick_cat` 1373–1405 (`hold` / `blink` / `flick`), not an AnimatedSprite2D.

### Signals

| Signal | Emitted | Connected on Main |
|---|---|---|
| `closed` | `close_cabin` 148 | `_on_home_cabin_closed` 1769 |
| `inspect_wanted(card_id)` | **never emitted** | `_on_cabin_inspect` 1782 (dead) |
| `item_hovered(card_id, slot)` | mount `mouse_entered` 1239–1245 | `_on_cabin_item_hovered` 1808 → `fly_tip.show_rule` |
| `item_unhovered` | mount exit, room change, close, back to exterior | `_on_cabin_item_unhovered` 1819 |

Door: `_door_hit.pressed` → `_on_door` 760.  
Exit: `_back.pressed` → `close_cabin` 296.  
Gallery: hit `pressed` → `_on_nav` ±1. Pips → `_on_pip` → `_on_nav`.

### Enter / leave today

**Enter from title / pause (no walk-in):** `_open_home_from_title` 1739 → `_open_home_cabin(false)` 1758.

- Hides fight hover plates.
- `home_cabin.open_cabin(items_by_id, tex_by_item, _buckets_revealed, walk_in)` 1762.
- Hides title overlay.
- `get_tree().paused = true` 1765. Cabin has `PROCESS_MODE_ALWAYS`, so it still ticks.

`open_cabin` 113–138: shows overlay, `_show_exterior()`, `_rebuild_shelves()`. If `walk_in == false`, `_beat = "rest"` (exterior, click the door yourself). Plays `cloth`, `cabin.open`, `music_cabin()`.

**Enter from Leave (walk-in):** `_adventure_leave` 1717.

1. Requires `adventure and phase == "rest"`.
2. Collects `hotbar[].card_id` and `home_cabin.swipe_ids(ids)` 1726–1727. **This is the only Swiped write.**
3. Hides overlay, waits 0.45s, `_cabin_from_leave = true`, `_open_home_cabin(true)`.
4. `open_cabin(..., walk_in=true)` plays `_play_arrive` 433: pan from the right, walk the cubic path, door open frames, fade to interior, walk to fire, drop sack, sit, rock.

**Clicking the door (`_on_door` 760–780):** if already interior, arriving, or busy, return. Else play `cabin_door_open_f0..f2` (0.08s each), set door glow open, `_fade_to_interior`, hide hero, show rocking, `_beat = "rock"`. **No walk-in on a title Home click.** You skip the arrival and sit already rocking.

**Leave cabin:**

- Interior **Exit** button → `close_cabin` immediately (does **not** go to exterior first).
- Escape on interior → `_show_exterior` (door closed again).
- Escape on exterior → `close_cabin`.
- `close_cabin` 141–148: stop loops, `cabin.close`, hide, `closed.emit()`.
- `_on_home_cabin_closed` 1769: unpause. If `_cabin_from_leave`, `_reset_run()` and `phase = "title"`. Then `_refresh()`.

### Camera, viewport, scaling, canvas layers

| Thing | Status |
|---|---|
| `Camera2D` / `Camera3D` | **NOT PRESENT.** Full-rect Control. “Pan” = `_ext_root.position` tween (arrive 447–451) and `_shelf_host.position.x` wipe (`_wipe_pan` 973). Screen bump = `offset_top/bottom = 4` on the ColorRect (`_bump` 638). |
| Viewport | `project.godot` 25–26: **1680×1040**. |
| Stretch | `window/stretch/mode="canvas_items"`, `aspect="expand"` (27–28). |
| Integer scale | **NOT PRESENT** as a project setting. Cabin hardcodes `PX = 4.0`. Global texture filter is nearest (`textures/canvas_textures/default_texture_filter=0`). |
| `CanvasLayer` | **NOT PRESENT** anywhere in game scripts. Draw order is `z_index` on Controls. |

**z_index stack (designer-relevant):**

| z | Owner |
|---|---|
| 0 | `dungeon_bg`, `wheel_view` |
| 4 | combat log |
| 5 | cabin pips / Exit; cue label |
| 6 | cabin gallery doors; hearts; trophy plaque |
| 7 | tray |
| 8 | Log button; dungeon deck |
| 11–13 | face / hypno inspect |
| 16 | Spin / Done / hotbar |
| 20 | challenge pick-two |
| 40 | draft gate |
| 60 | white flash |
| 70 | hall wipe; tutorial vignette |
| 80 | title/rest/win/lose overlay; copy stamp |
| 95 | **home cabin** |
| 96 | speech bubble |
| 100 | knight walk-off courier |
| 110 | fly inspect tip (cabin hover uses this) |
| 120 | pause / settings |
| 141 | keyword definition tip |

Pause is 120, cabin is 95: **Escape during cabin is handled by cabin first** (`_input` on cabin, 1558) so pause does not open over the cabin unless cabin is hidden.

### Art files present vs code fallbacks

Present under `assets/dungeon/home/` (60 PNGs): exterior, interior, door closed/open×3, lantern×3, smoke×3, cat×4, fire×3, glows×4, hero walk / loot / idle / sit / drop / rock, loot sack, trophy_mount + hover, plaque glint×4, place burst×5, shelf_locked, item_seen_overlay.

**Code looks for these and they are NOT PRESENT:**

| Stem | Used when | Fallback |
|---|---|---|
| `gallery_door_left` / `gallery_door_right` | `_make_gallery_door` 702–707 | `cabin_door_closed`, flip_h on left |
| `gallery_cordon` | locked bucket row 1090 | `shelf_locked` |
| `trophy_mount_seen` / `_unseen` / `_seen_hover` | `_mount_stem` 1133 | plain `trophy_mount` + modulate |

Shelf layout: room 0 = all bucket-0 (starter) items in 3 rows. Rooms 1+ = three buckets per screen (`_screen_of_bucket` 733). Locked if `bucket > buckets_open` (`_buckets_revealed` from `user://bucket_progress.json`). Spider Egg (`bucket -1` / token) has **no shelf**. Retired / hold skipped.

---

## 3. Every menu, button and choice

Runtime paths are unnamed. Table uses **Main variable → constructed child**, plus the copy key.

### Title / rest / win / lose overlay (`overlay`, ColorRect, z=80)

Built in `_build_overlay` 1049–1126. Shown when `phase` is `title`, `victory`, `defeat`, or `rest` (`_sync_overlay` 10817), unless cabin or tutorial or bucket-unlock is up.

| Screen | Control | Does | Copy key | Handler |
|---|---|---|---|---|
| Title | `overlay_title` Label | Headline “Swipe” | `title.overlay` | `_sync_overlay` 10855 |
| Title | `overlay_sub` Label | Subtitle | `title.sub` | 10856 |
| Title | `overlay_tut` Button | How to Play | `title.how_to_play` | `_start_tutorial` |
| Title | `overlay_dive` Button | Quick Start (copy still keyed `title.dive_in`) | `title.dive_in` | `_quick_start` |
| Title | `overlay_btn` Button | Classic mill | `title.begin` | `_on_overlay_primary` → `_begin_run` |
| Title | `overlay_adventure` Button | Challenge Mode | `title.adventure` | `_begin_adventure` |
| Title | `overlay_home` Button | Open cabin, no walk-in | `title.home` | `_open_home_from_title` |
| Title (editor) | `overlay_latest` | Play Latest | **NO COPY KEY** (“Play Latest”) | `_play_latest` |
| Title (editor) | `overlay_dev` | Developer Test | **NO COPY KEY** | `_open_dev_test` |
| Title (editor) | `overlay_roster` | Roster editor | **NO COPY KEY** | `_open_roster` |
| Title (editor) | `overlay_script` | Script editor | **NO COPY KEY** | `_open_script` |
| Rest | `overlay_title` | “Another hall” | `title.rest` | 10859 |
| Rest | `overlay_sub` | Dungeon N behind you | `title.rest_sub` `{n}` | 10860 |
| Rest | `overlay_continue` | Next dungeon, keep hand | `title.continue` | `_adventure_continue` |
| Rest | `overlay_leave` | Swipe hand, walk home | `title.leave` | `_adventure_leave` |
| Win | `overlay_title` | Classic: “Kept it”. Challenge death-after-clear: “Victory” | `title.win` / `title.adventure_win` | 10861–10866 |
| Win | `overlay_sub` | Classic only | `title.win_sub` | 10867 |
| Win/Lose | `overlay_score` | “Dungeons cleared: N” if `adventure` | `title.dungeons_cleared` `{n}` | 10850–10853 |
| Win/Lose | `overlay_btn` | Restart same style of run | `title.again` | `_on_overlay_primary` |
| Win/Lose | `overlay_undo` | Undo last fight (if stack) | **NO COPY KEY** (“Undo”) | `_on_undo` |
| Lose | `overlay_title` | “Caught” | `title.lose` | 10870 |
| Lose | `overlay_sub` | Classic only | `title.lose_sub` | 10874 |
| Title+overlay | `btn_start` (in play chrome, not overlay) | Visible whenever overlay is visible; text **“New”** | **NO COPY KEY** | `_on_new` → mill or Challenge restart |

`overlay_btn` is **hidden on rest** (10847). Continue/Leave row is **only on rest** (10845). Title mode buttons hidden off title (10831–10837).

### Pause / Escape (`settings_ui`, ColorRect, z=120)

`scripts/settings_menu.gd`. `open_menu` 235 pauses the tree.

| Control | Does | Copy key | Writes |
|---|---|---|---|
| `_title` | “Settings” | `pause.settings` | — |
| `_master` HSlider 0–100 | Master volume | **NO COPY KEY** (hardcoded “Master”) | `_audio.set_master` → `user://audio.json` `master` |
| `_music` HSlider | Music | **NO COPY KEY** (“Music”) | `set_music` → `music` |
| `_ambience` HSlider | Ambience | `pause.ambience` | `set_ambience` → `ambience` |
| `_sfx` HSlider | SFX | **NO COPY KEY** (“SFX”) | `set_sfx` → `sfx` |
| `_ui_vol` HSlider | UI | `pause.ui` | `set_ui` → `ui` |
| `_hint` | Escape resumes… | `pause.hint` | — |
| `_btn_resume` | Close pause | `pause.resume` | — |
| `_btn_quit` | `get_tree().quit()` | `pause.quit` | Hidden on web (`OS.has_feature("web")`, line 96) |
| `_play` label | “Start over” | `pause.start_over` | — |
| `_btn_how` | How to Play | `title.how_to_play` | `mode_picked("tutorial")` |
| `_btn_dive` | Quick Start | `title.dive_in` | `"dive"` |
| `_btn_begin` | Classic mill | `title.begin` | `"begin"` |
| `_btn_adventure` | Challenge | `title.adventure` | `"adventure"` |
| `_btn_home` | Cabin | `title.home` | `"home"` |
| editor “Play Latest” | | **NO COPY KEY** | `"latest"` |
| editor “Developer Test” | | **NO COPY KEY** | `"dev"` |
| editor “Roster” / “Script” | | **NO COPY KEY** | `roster_pressed` / `script_pressed` |

No graphics, fullscreen, language, difficulty, or accessibility toggles.

Dim-click-to-close (`_on_dim_input` 318) only closes if `event.position.x < 0`, which never happens on a full-rect overlay. **Dead.** Escape works (`_unhandled_input` 324).

`Main._on_pause_mode` 4017 maps those mode strings onto the same start functions as the title.

### In-run chrome (not a menu, but buttons)

| Control | Copy key | Handler | When visible |
|---|---|---|---|
| `btn_spin` | `combat.spin` | `_on_spin` | `phase == "ready"` |
| `btn_done` | `combat.take_hit` `{n}` or `combat.safe` | `_on_done` | fighting, enemy up |
| `btn_challenge_begin` | `challenge.begin` | `_challenge_begin_play` | Challenge after opening picks |
| `btn_place` / `btn_bribe` | **NO COPY KEY** | mill leftovers | `visible = false` always (`_sync_buttons` 10786) |
| `btn_undo` / `btn_redo` | **NO COPY KEY** | `_on_undo` / `_on_redo` | fighting/ready/slaying, Challenge scope |
| `log_btn` | **NO COPY KEY** (“Log”) | `_toggle_log` | play field |
| `choice_box` pills | `combat.knife_throw` / `combat.knife_nick`; other options hardcoded from `ops.label` | `_choose_option` / `_feed_cube` | pending choice / cube / merchant |
| challenge pick-two | `challenge.pick_open` / `challenge.pick_loot` | `challenge_draft_ui.chosen` | Challenge draft |
| draft gate Take / Pass | `door.take` `{n}`, `door.pass` `{n}`, `door.pass_none` | `_on_gate_send` / `_on_gate_refuse` | classic mill |

### Cabin

| Control | Copy key | Handler |
|---|---|---|
| `_back` “Exit” | `title.leave` (fallback “Exit”; saved text is **“Leave”**) | `close_cabin` |
| `_door_hit` | none | `_on_door` |
| gallery doors / pips | none | `_on_nav` / `_on_pip` |

No dedicated `cabin.*` copy keys.

### Surfaces that do not exist

| Screen | Status | Hook if you add it |
|---|---|---|
| Credits | **NOT PRESENT** | Title overlay row, or a cabin plaque. No `title.credits` key. |
| Difficulty | **NOT PRESENT** | Would have to change `_pick_tier` / `_challenge_roll_tier` / bucket unlock. No setting saved. |
| Compendium (named) | **NOT PRESENT** as a list UI | Cabin shelves **are** the collection. |
| Loadout / pre-run kit picker | **NOT PRESENT** as a persistent loadout | Challenge opening pick-two is the only pre-run choice. Classic mill is the draft gate. |
| Confirm dialog (`AcceptDialog` / `ConfirmationDialog`) | **NOT PRESENT** | Quit is immediate. Start-over from pause is immediate. Knife / cube / merchant use `choice_box` pills. |
| Collection gallery besides cabin | Trophy **plaque** on the wheel (`trophy_mount.gd`) is kill count only. |

Editor-only (stripped in web via `OS.has_feature("editor")` / `_authoring()`): Roster, Script, Developer Test, Play Latest, F2/F3/F4, copy stamp, right-click Edit card.

---

## 4. Run lifecycle

### Where a run starts

| Mode | Function | After reset |
|---|---|---|
| Classic mill (“Adventure Mode”) | `_begin_run` 1666 | `_reset_run` (sets `adventure = false`), `phase = "draft"`, `_run_mill` |
| Challenge | `_begin_adventure` 1677 | `_reset_run` then `adventure = true`, `_reveal_new_buckets`, `_fill_challenge_pools`, 6-seat wheel, `_run_challenge_setup` |
| Quick Start | `_quick_start` 1993 | Challenge flags, seat dungeon, `_challenge_auto_opening_loot`, skip pick UI, `phase = "ready"` |
| How to Play | `_start_tutorial` 11157 | Fixed 3 owners + 4 items, `phase = "ready"`, `tut.open()` |

`_reset_run` 1553 clears HP, Block, wheel, hotbar, mill flags, Challenge deck, speech, and **does not** clear cabin Seen/Swiped or bucket unlocks.

### What defines floors / bosses / order

**NOT PRESENT:** a floor table, named bosses, or a fixed dungeon order file.

Playable ids come from `data/runtime.json`:

- `items: [...]` 43 ids (excludes retired Dagger / Bandana / old Helmet; includes Cursed Scroll note vs comments).
- `monsters: [...]` 35 ids.

Pools are further filtered by:

1. `status` live (retired/hold skipped in cabin; pools use runtime list).
2. `BucketRules.parse(card.bucket) <= _buckets_revealed` (`_bucket_open` 2065).
3. `ModePool.allows(card, ADVENTURE or CHALLENGE)` (`scripts/mode_pool.gd`).

Classic mill (`_fill_pools` 2257): 8 seats. Cardinals NESW get starters (`_seat_night_watch` 3162, `STARTER_COUNT = 4`). Then up to `DRAFT_ROUNDS = 4` gate packs (`refusals_left = 3`). Tier odds in catalog `draft.tier_odds` 0.4 / 0.35 / 0.25.

Challenge (`_fill_challenge_pools` 2311, `_challenge_seat_dungeon` 2495):

- `CHALLENGE_SEATS = 6` face-up owners.
- `CHALLENGE_DECK_N = 6` face-down refill ids in `challenge_deck` (crate UI `dungeon_deck.gd`).
- After dungeon 1, two openers upgrade (`_upgrade_two_openers` 3207). Banner `adventure.scarier`.
- Opening loot: one pick-two per seated owner (`_challenge_run_opening_drafts`), unless Quick Start auto-picks.
- Hand cap `CHALLENGE_HAND = 10`.
- You **click who you fight**, then Spin (`challenge_aim`). Classic mill Spin is random among live seats (magnet / tutorial can force).

There is no “boss at the end of the floor.” Clearing the wheel **is** clearing the dungeon.

### After each owner / after each dungeon

After a fight:

- Classic: `_clear_after_fight` → neighbors close, `phase = "ready"`, maybe auto-spin. If `_monsters_left() == 0` → `_enter_dungeon_clear`.
- Challenge: `_challenge_after_fight` 2828 vacates the hole, may draw from `challenge_deck`, then same empty-wheel check.

`_enter_dungeon_clear` 1695:

- Music sting `sting.clear`, `music_title`.
- Tutorial or **not** `adventure` → `phase = "victory"` (classic mill win parchment). **No Swiped write.**
- Challenge → `dungeons_cleared += 1`, `_advance_bucket_counter` (writes `user://bucket_progress.json`), `phase = "rest"`.

Continue 1825: `dungeon_index += 1`, maybe bucket reveal cinema, `_play_hall_wipe` (knight walks off, bg pan), `_prep_next_dungeon` (HP full, Block 0, **hotbar kept**, spent flags cleared), new 6-seat dungeon.

### Win and loss

**Win (classic mill):** wheel empty while `not adventure` → `_enter_dungeon_clear` → `phase = "victory"`. Overlay `_sync_overlay` 10861. Audio `sting.victory` is **not** on this path; `_enter_dungeon_clear` plays `sting.clear`.

**Win (Challenge, odd):** die after at least one dungeon cleared → `_player_down` 4942 sets `phase = "victory"` and `sting.victory` / `music_victory`. Overlay uses `title.adventure_win`.

**Loss:** `_player_down` otherwise → `phase = "defeat"`, `sting.defeat`, `music_defeat`. Challenge death also `_advance_bucket_counter` (unlocks still move). **Death does not swipe.**

HP hits 0 in `_owner_attack` 4844 / egg 4887. `_try_potion` 8617: if a live Healing Potion is in hand, spend it, heal 3, toss it, survive. If that fails, later `_player_down`.

No dedicated win/lose **signals**. Call chain is functions + `_refresh` → `_sync_overlay`. Audio events: `sting.clear`, `sting.victory`, `sting.defeat`.

### What the player carries

In-run inventory is `Main.hotbar: Array` of Dictionaries, not a Resource.

Created by `_make_item` 3545:

```
uid, card_id, name, ops, ability, explainer, log_hint, card_color,
spent, keep_after, siphon_blk, pack_tier, pack_kind,
petrified, echo_copy, alt_n, magnet_mode, magnet_seq
```

**Add:** `_make_item` (always `home_cabin.note_seen(id)` 3553–3554), then `hotbar.append` from mill take, Challenge pick, Mimic/Queen gifts (`_try_gain_item` 6564), tutorial kit, Dev Test.

**Remove:** `_remove_item_now` 5906 (filter by `uid`). Spend/toss `_toss_item`. Challenge discard when hand is full (`_challenge_discard_one` 2688). Cube feed, Cleric steal, Basilisk famine, etc. `_discard_spent_items` after a fight.

Hand limit: 50 classic (`HAND_MAX`), 10 Challenge.

Wheel seats are a separate `wheel: Array` of monster/empty dicts (`_make_monster` 3510). Not carried between classic runs. Challenge Continue keeps **items only**; new owners are drawn.

### Mid-run exit / retreat

**NOT PRESENT** as “return to cabin from a fight.”

What exists:

| Action | When | Effect |
|---|---|---|
| Pause → any start-over mode | Anytime Escape | `_reset_run` + new mode. Hand is **not** swiped. |
| Pause Quit | Desktop only | Process exits. |
| Leave | **Only** Challenge `phase == "rest"` | Swipes current hand, walk-in cabin, then title. |
| Continue | Same rest | Does **not** swipe. Keeps hand. |
| Monster flee (Cowardly King, Commander, Goblin, etc.) | Combat specials | Leaves a seat, not the dungeon. |
| How to Play skip | Tutorial | Title, no swipe. |

You cannot bank items mid-dungeon.

---

## 5. Items, cards and catalog

### Data files

| Path | Role |
|---|---|
| `data/catalog.json` | Runtime card truth `Main` loads (`CATALOG_PATH`, `_load_catalog` 641). Items + monsters + combat_flow notes. |
| `data/content-board.json` | In-game Roster / Edit card Save. Same cards + `flow`, `notes`, `review_note`, locks. Inspect still reads **catalog** fields after Save (editors write both). |
| `data/runtime.json` | Which ids enter pools. |
| `data/player-copy.json` | UI / Nib / door / taunt prose. **Not** card names. |
| `data/player-copy.csv` | Generated twin of copy + `card.*` snapshot. |
| `data/author-locks.json` | Locked field ledger. |
| `scripts/main.gd` `ITEM_OPS` 71, `MONSTER_SPECIAL` 126 | Hardcoded fallbacks if catalog `ops` missing. |
| `scripts/mode_pool.gd` | `mode_pool`: `all` / `adventure` / `challenge`. |
| `scripts/bucket_rules.gd` | Bucket 0–12 or Token (`-1`). Always-starter: `smoke_bomb`. |

**Specials** are not a third file. Monster call/reminder live on the card (`call_name`, `reminder`). `scripts/monster_lines.gd` only reads those fields.

### Catalog schema

Top-level keys: `id`, `authority`, `combat_flow`, `item_use_flow`, `draft`, `items[]`, `monsters[]`, `keywords`, `named_variables`, `player`, `poc`, `rulings`, `contradictions`, `source_file`, `source_written`, `tier_count_targets`, `wheel`.

**Item row (typical):** `id`, `name`, `ability`, `explainer`, `log_hint`, `card_color`, `rarity`, `tier`, `count`, `priority`, `bucket`, `mode_pool`, `ops`, `status`, `type` (`"I"`), flags, locks, `call_name`/`reminder` usually empty.

**Monster row:** same plus `atk: {base, formula?, on?}`, `hp: {base, formula?, on?}`, `call_name`, `reminder`, `type` (`"M"`).

Inspect / wheel never read `review_note`.

### Counts (catalog.json)

| | live | todo | retired | total |
|---|---|---|---|---|
| Items | 37 | 3 (smoke_bomb, poison_flask, healing_potion) | 4 (dagger, helmet_hidden, bandana, caltrops) | 44 |
| Monsters | 32 | 3 (hornet_swarm, wraith, mimic) | 0 | 35 |

Item `card_color`: atk 13, blk 9, defeat 5, utility 5, heal 4, (empty/retired) 4, chaos 2, smoke 1, egg 1.

Item rarity: uncommon 31, starter 13. Monster rarity: uncommon 29, starter 6.

Mode pool: most `all`. Adventure-only items: smoke_bomb, spider_egg, danger_magnet. Adventure-only monsters: lich, spider_queen, clockwork_knight. Challenge-only monster: harpy.

Cabin shelves skip retired/hold/token. Tokens: spider_egg (`bucket -1`).

Icon paths: `scripts/dungeon_art.gd` `ITEM_PNG` / `MONSTER_PNG` win over atlas stems. Full id tables are **Appendix A**.

---

## 6. Save system

**No save slots. No run save. No checkpoint.** Three independent `user://` JSON files plus editor-side `res://` writes.

| File | Written by | When | Schema |
|---|---|---|---|
| `user://home_cabin.json` | `home_cabin.gd` `_save` 1424 | First time an id is Seen (`note_seen` 87) or Swiped (`swipe_ids` 97) | `{ "seen": [id, …], "swiped": [id, …] }` |
| `user://bucket_progress.json` | `Main._save_bucket_progress` 2040 | Dungeon ended (Challenge clear **or** Challenge death) `_advance_bucket_counter` 2059; Roster unlocks reset | `{ "dungeons_ended": int, "revealed": int }` |
| `user://audio.json` | `audio_fx.gd` `_save` 1010 | Any volume slider | `{ "version": 2, "master", "music", "ambience", "sfx", "ui" }` all linear 0–1 |

`FileAccess.open` user path. Desktop: `%APPDATA%/Godot/app_userdata/Swipe/` (Godot userdata). Web: IndexedDB-backed `user://`.

**NOT PRESENT:** slot picker, continue-run, player name, settings besides volume, tutorial-complete flag, credits-seen, difficulty.

### Seen / unlocked / collected / tutorial

| Flag | Where | How it becomes true |
|---|---|---|
| **Seen** | `home_cabin.seen` | `_make_item` → `note_seen` when an item is instantiated into a run (offered/held). Skips `spider_egg`. Persists in `home_cabin.json`. |
| **Swiped** | `home_cabin.swiped` | Only `_adventure_leave` ids still in `hotbar`. One slot per id. Death / Continue / classic mill victory do **not** swipe. |
| **Bucket unlocked** | `_buckets_revealed` | `dungeons_ended` on Challenge rest or Challenge death. Reveal cinema `_reveal_new_buckets` 2070 when `dungeons_ended > revealed`. Cabin locked rows use this same counter (`open_cabin` passes `p_buckets`). |
| **Tutorial done** | **NOT PRESENT** | `_tut_finished` just goes to title. How to Play every time. |
| Authoring locks | `author-locks.json` | Editor Save, not player progress. |

`home_cabin.debug_seed` / `debug_pose` exist for MCP / Playtest, not players.

---

## 7. Tutorial and Nib

### How How to Play starts

`_start_tutorial` 11157:

1. `_tut_boot` so `_reset_run` does not close tut.
2. Seats Wizard/Golem/Goblin at N/E/S (`slots [0,2,4]`).
3. Hands Sai, Helmet, the Boot, Knucklers. (Legacy `BEATS` still mention Shield/Flail; live beats come from copy.)
4. `phase = "ready"`, `in_tutorial = true`, `tut.open()`.

`tut` is `scripts/tutorial_guide.gd`, `add_child` at z=70, top_level. **Not a scene.**

Skip: `tut.skipped` → `_tut_skip` 11206 (audio `tut.skip`, title). The Skip **button is created then `visible = false`** (tutorial_guide.gd 186–188). Copy key `tutorial.skip` is unused on screen.

Complete: last beat `finished.emit()` → `_tut_finished` 11217 → title. **No save flag.**

### Step logic

`tut.open` → `_load_beats` 401.

1. If `tutorial.beat.01.body` contains `(Click` or `(Highlight`, parse the whole body as a Nib script (`_parse_nib_script` 441): lines of dialogue, `(Click …)` / `(Highlight …)` direction lines, `---` branch markers (`boot` / `take` / `join`).
2. Else `_legacy_beats` 410: `const BEATS` 619 (18 hardcoded steps) overlaid with `tutorial.beat.NN.body/hint/go`.

Each beat sets `wait` (`continue`, `spin`, `done`, `hover_item`, `item:shield`, …), `focus_tag`, `force_id`, `nib` (face scale), `tiny`, `branch`. `advance` 244 skips beats whose `branch` does not match `choice`. `Main` blocks clicks until `tut.wait` matches (`_unhandled` / item / spin checks, e.g. 4681, 5435).

Dungeon-2 staging (`_tutorial_stage_dungeon2` 11256) sniffs Nib’s spoken text for “pick loot” / “six monsters” / “venture deeper” and rebuilds a fake Challenge board under the vignette.

### Nib sprites, scenes, dialogue

| Piece | Path / code |
|---|---|
| Sprite | `res://assets/dungeon/extra/nib.png` via `DungeonArt.nib_frames()` (`dungeon_art.gd` 305). Fallback: goblin / dwarf_f atlas frames. **Single still**, bobbed in `_process` 309–313 (5 fps cycle of whatever frames exist). |
| Scene | **NOT PRESENT.** Portrait is a `TextureRect` `_face` inside `_talk` PanelContainer (`tutorial_guide.gd` `_build_talk` 121). |
| Lines | `data/player-copy.json` keys `tutorial.beat.*.body`. Speaker label `tutorial.speaker` (“Nib”). |
| Advance | Continue button `_go` emits `continued` → `Main._tut_on_continue` 11195 → `tut.advance`. Or the player does the `wait` action. |
| Audio | `sfx.speak(&"nib", text)` on each beat (264). |

### Reusable dialogue box / portrait?

**Two systems, not one:**

1. **Nib How-to box** — `tutorial_guide.gd`. Named speaker, portrait, hint, Continue. Tutorial-only. `mouse_filter` on the talk panel is STOP; vignette holes are a canvas shader.
2. **Comic balloon** — `scripts/speech_bubble.gd`. No portrait. Tail toward a mouth point. Used for **owners** at the draft gate / combat (`Main.speech_box`). Keywords via `keyword_tip.gd`. z=96.

Cabin has **no** Nib dialogue. There is no shared Dialogue resource, no portrait scene, no typewriter node (AudioFx `speak` / `speak_progress` exist for SFX, the Labels snap to full text).

If the overhaul wants Nib in the cabin, hook either: instance `tutorial_guide`’s talk chrome, or extend `speech_bubble` with `nib_frames()`. New copy keys under `tutorial.*` or a new `cabin.nib.*` prefix.

---

## 8. Compendium / collection / trophy shelf

### What exists

| Thing | What it is |
|---|---|
| **Home cabin shelves** | The collection. Bucketed item mounts. Seen / Swiped / locked. |
| **Wheel trophy plaque** | `scripts/trophy_mount.gd` on the play field. Skull + number of **slain this dungeon**. Hardcoded caption `"Slain"` (line 83) despite the file comment “Number only — no English.” Not persistent. |
| Named Compendium / Codex / Gallery scene | **NOT PRESENT.** |

### Data the cabin reads

- `items_by_id` (catalog) + `tex_by_item`.
- `buckets_open` = `_buckets_revealed`.
- `seen` / `swiped` from `user://home_cabin.json`.
- Card `status`, `bucket`, `name`. Display name is **catalog `name`**, not a copy key.

Unlock: Seen when `_make_item` runs; Swiped only on Leave; bucket rows when Challenge dungeons end.

### Hover / inspect

Cabin mounts: `Control.mouse_entered` / `exited` (not Area2D, not Rect2 pickup in `_process`).

`Main._on_cabin_item_hovered` 1808:

1. `_cabin_item_from_id` builds a fake hotbar dict (ability, explainer, ops, color).
2. `_item_rule` 9654 builds title/value/equation/body/warn.
3. `fly_tip.show_rule(...)` (`hover_panel.gd` `show_rule` 80). `fly_tip` is a top_level HoverPanel, z=110, `accept_clicks = false`.
4. `_place_fly(slot)` 10086 docks it to the mount.

Locked / unseen mounts do not connect hover (only `if is_seen` at 1206). Unseen silhouettes are not inspectable.

Right-click Edit on fly_tip is off (`accept_clicks = false`). `inspect_wanted` is unused, so cabin cannot open the editor from a mount.

Keyword hover: `UxStyle.wire_def_hover` on inspect body if it contains `[url=kw:…]`. `keyword_tip.gd` docks a “Always” definition. Same as combat inspect.

---

## 9. Input

### Input map

`project.godot` has **no `[input]` section.** The game uses Godot 4 built-ins:

| Action | Default (Godot 4) | Used for |
|---|---|---|
| `ui_cancel` | Escape, controller B | Pause (`Main._unhandled_input` 3996); close pause; cabin interior→exterior or close; close editors |
| `ui_left` / `ui_right` | arrows | Cabin room pan (`home_cabin.gd` 1561–1567) |
| `ui_accept` | Enter / Space | Dev Test enter (3966) |

No custom `pause` action. No click-to-pause.

Editor keys (not input map): F2 Roster, F3 Script, F4 Play Latest (`_unhandled_input` 3970–3994).

### Mouse

Combat: `boss_wheel.gd` `_gui_input` on slices; `item_card.gd` `gui_input`; `dungeon_deck.gd` hover; `draft_gate.gd` door `gui_input`.

Cabin:

- Door: invisible `Button` (`_door_hit`).
- Gallery: invisible `Button` over the door graphic.
- Mounts: `Control.mouse_filter = STOP` + `mouse_entered` / `exited`.
- **NOT PRESENT:** `Area2D`, `CollisionShape2D`, or manual `Rect2.has_point` hit tests in the cabin. (`_well_rect` / `_plate_rect` are layout math for the sprite, not picking.)

`Main._unhandled_input` bails if settings/content/roster/script are up, then opens pause on `ui_cancel`. Cabin handles `ui_cancel` in `_input` (higher, and `set_input_as_handled`), so pause does not stack on cabin.

---

## 10. Audio hooks

### Manager

`scripts/audio_fx.gd`, child of Main (not an autoload). `setup()` 58: create buses if missing, load `data/sfx-map.json`, load `user://audio.json`, 16-voice pool, A/B music, loop players.

**Buses** (`default_bus_layout.tres` + runtime `_ensure_layout` 70):

| Bus | Effect | Default linear |
|---|---|---|
| Master | HardLimiter −1 dB | 1.0 |
| Music | Amplify “Duck” | 0.85 |
| Stings | follows Music volume | 1.0 |
| Ambience | LowPass 20 kHz | 0.8 |
| SFX | Compressor | 1.0 |
| UI | — | 0.9 |

`project.godot` does **not** set `audio/buses/default_bus_layout`. The `.tres` is the authored layout; `AudioFx` also creates buses at runtime if absent.

### How cues play

- Legacy: `sfx.play("click", db, pitch)` 307 — Kenney ids in `_streams`.
- Map: `sfx.play_event(&"cabin.open")` 337 — looks up `data/sfx-map.json` `cues`.
- Music beds: `start_music`, `music_title`, `music_cabin`, `music_deadly`, `music_victory`, `music_defeat`, `music_to`.
- Loops: `loop_start(&"amb.cat_purr")`, `loop_stop_all`.
- Speech ticks: `speak(&"nib", text)`.
- Pause duck: `on_pause(true/false)`.
- Web first click: `_input` 911 unlocks and restarts beds (`OS.has_feature("web")`).

Cabin events used: `cabin.open`, `cabin.close`, `cabin.sack`, `cabin.sit`, `cabin.step`, `cabin.rock`, `cabin.fire_start`, `cabin.trophy`, `cabin.glint`, `cabin.cat`; loops `amb.cat_purr`; bed `music_cabin()`.

### Audio pass files

| Path | Status |
|---|---|
| `data/sfx-map.json` | **Present** (version 1, cues, buses, lookup, music). |
| `design/audio/AUDIO-SPEC.md` | Present |
| `design/audio/CURSOR-PROMPT.md` | Present |
| `design/audio/PACK-README.md` | Present |
| `design/audio/audio-director.md` | Present |
| `design/audio-director.md` | Present (copy at design root) |
| `assets/audio/*.ogg` / `.wav` | Present (loaded via `path_prefix` `res://assets/audio/`) |
| `tools/audio/` | Present; **excluded from web export** (`tools/*`) |

---

## 11. Copy

### Structure

`data/player-copy.json`:

```
{
  "id": "swipe-player-copy-v3-draftgate",
  "updated": "2026-10-10",
  "instructions": "...",
  "rows": [
    { "cat": "Title", "key": "title.overlay", "where": "...", "text": "...",
      "author_lock": true, "locked_at": "2026-10-07" }
  ]
}
```

**Not nested objects.** Flat `rows[]`. Lookup is `PLAYER_COPY.text(key, fallback)` (`player_copy.gd` 45): scans `by_key[key].text`. `fill(key, {n: 3})` replaces `{n}`.

Key convention: `surface.slot` with dots. Categories (`cat`): Title, Pause, Tutorial, Door, Cues, Combat, Inspect, Warns, Taunts. Card names are **not** in this file; Roster Save writes them to catalog/board. CSV snapshot keys look like `card.item.throwing_knife.name` but inspect does not read those.

234 rows. Taunts are 100 of them (`taunt.{id}.1..5` plus `taunt.default.1..5`).

### Lookup in code

`const PLAYER_COPY := preload("res://scripts/player_copy.gd")` then `PLAYER_COPY.text("title.home", "Home")`. Cabin uses the same via `COPY`.

### Keys used by menus, tutorial/Nib, win/loss, collection

**Title / modes / rest / win / lose**

`title.overlay`, `title.sub`, `title.how_to_play`, `title.dive_in`, `title.begin`, `title.adventure`, `title.home`, `title.rest`, `title.rest_sub`, `title.continue`, `title.leave`, `title.win`, `title.win_sub`, `title.lose`, `title.lose_sub`, `title.again`, `title.adventure_win`, `title.dungeons_cleared`, `adventure.scarier`, `challenge.begin`, `challenge.pick_open`, `challenge.pick_loot`, `challenge.click_target`, `challenge.spin_confirm`, `challenge.full_hand`, `challenge.begin_cue`.

**Pause**

`pause.settings`, `pause.hint`, `pause.resume`, `pause.quit`, `pause.start_over`, `pause.ambience`, `pause.ui`. (Master / Music / SFX labels are hardcoded.)

**Tutorial / Nib**

`tutorial.speaker`, `tutorial.skip` (unused on screen), `tutorial.nudge_wait`, `tutorial.nudge_item`, `tutorial.beat.01..18.body|go|hint`. Live How to Play may ignore 02–18 as separate beats if 01.body is a full Nib script.

**Collection (cabin)**

No `cabin.*` keys. Exit button uses `title.leave`. Plaque names are catalog `name`. Trophy “Slain” is hardcoded.

**Also on those screens’ neighbors (cues / combat / inspect / door / warns)** — used while a run is up, not on the parchment:

`cue.starters`, `cue.force`, `cue.ask`, `cue.steal`, `cue.seat`, `cue.filling`, `cue.ready`, `cue.fighting`, `cue.mark`, `cue.devtest`, `combat.spin`, `combat.safe`, `combat.take_hit`, `combat.blocked`, `combat.slain`, `combat.knife_throw`, `combat.knife_nick`, `inspect.title`, `inspect.idle`, `inspect.empty_title`, `inspect.empty_place`, `inspect.empty`, `inspect.shift`, `inspect.placeholder`, `warn.spent`, `warn.boot`, `warn.neighbor`, `warn.sledge`, `warn.poison`, `warn.crossbow`, `door.title`, `door.shiny`, `door.owner`, `door.help`, `door.hook`, `door.take`, `door.pass`, `door.pass_none`, `door.seat`, `door.guard`, `tier.1.name`, `tier.2.name`, `tier.3.name`.

Code fallbacks **without** a row: `combat.cant_gain`, `challenge.loot`, `door.pass_one`.

Full key list with `where` is **Appendix B**. Taunt keys (`taunt.*`) are draft-gate balloons, not cabin.

---

## 12. Constraints and risks

### Web export

`export_presets.cfg` preset 0 **Web** only. No Windows/Linux/macOS preset.

- Path: `build/web/index.html`
- `export_filter=all_resources`
- `include_filter=*.txt,*.json` (so `data/sfx-map.json` and copy/catalog ship)
- `exclude_filter=design/home/*,tools/*` — **does not exclude `assets/dungeon/home/`** (cabin art ships)
- `variant/thread_support=false`
- PWA off
- `html/canvas_resize_policy=2` (adaptive)
- Viewport 1680×1040, stretch expand — letterboxing/pillarboxing as window changes; **not** integer snap
- Quit hidden on web
- Roster / Script / Dev Test hidden (`_authoring()`)
- Audio: first gesture unlock in `AudioFx._input`
- `user://` on itch is per-browser, not a file the player can copy

No written texture-memory budget. Cabin already adds two 1680×1040 opaque room backgrounds plus overlays. Five full-bleed rooms at 4× is five of those unless you atlas or stream.

### Fragile points for a menu overhaul

1. **Single scene, code-built UI.** A designer `.tscn` will not appear unless `Main` instances it. `change_scene` would unload run state (hotbar, pools, audio).
2. **`phase` + overlay visibility is the router.** Title is not a node tree you can “go back” to; `_refresh` → `_sync_overlay` shows/hides one ColorRect.
3. **Pause vs cabin vs overlay z-index and `get_tree().paused`.** Cabin sets paused=true. Pause also sets paused=true. Cabin eats Escape. Breaking process_mode will freeze the fire/cat or let the wheel tick under the cabin.
4. **`ui_cancel` is overloaded** (pause, editors, cabin rooms). A new room-exit must `set_input_as_handled`.
5. **Mode label inversion** (`title.begin` = mill, `title.adventure` = Challenge). Replacing the parchment with door-props must keep those handlers straight.
6. **Leave is the only Swipe write.** A cabin “Start run” that skips rest will never mount new trophies unless you also call `swipe_ids`.
7. **Seen is coupled to `_make_item`.** Opening the catalog in a cabinet without instantiating items will not mark Seen unless you call `note_seen`.
8. **Bucket lock is Challenge-progress, not cabin.** Classic mill / How to Play do not increment `_dungeons_ended`. A player who only ever mills sees bucket 0.
9. **Missing gallery-door / seen-mount art.** Room-to-room already fakes doors with the exterior door sprite.
10. **`inspect_wanted` is dead.** Hover uses `fly_tip`. A click-to-inspect cabinet needs a new connection.
11. **Exit copy.** Button uses `title.leave`, whose saved text is “Leave” with fallback “Exit”.
12. **Audio bed.** `music_cabin()` / `loop_stop_all` on close. A 5-room hub that stays up while starting a run must decide when to `start_music()` (currently on `_reset_run` and `_ready`).
13. **Web size.** Extra full-screen PNGs and OGG beds ride along in the itch zip (`all_resources`).
14. **MCP `_mcp_state`** on cabin (1431) is for Playtest; keep `visible` / `_beat` if tools still pose the cabin.

### Recommendation: where `CabinRoot` should live

Do **not** make a second main scene. Keep `run/main_scene = res://scenes/main.tscn`.

**Put `CabinRoot` here:**

1. Add `res://scenes/cabin_root.tscn` (or keep building it in `home_cabin.gd`) as a **child of `Main`**, same slot `home_cabin` occupies today: after `settings_ui` is created, `z_index` 95, `PROCESS_MODE_ALWAYS`, full rect.
2. On boot, `phase == "title"` should **show CabinRoot instead of the parchment overlay** (or show a short parchment *inside* a room). `_sync_overlay` 10817 is the switch: today `show = phase in (title, victory, defeat, rest)`. Change title (and maybe rest/win/lose) to cabin rooms; keep `overlay` only if you still want a paper sheet for “Caught”.
3. **Replace the current main menu by routing the five title actions to diegetic hotspots** that call the same handlers: `_start_tutorial`, `_quick_start`, `_begin_run`, `_begin_adventure`, `_open_home_cabin` (already home). Pause can stay as Escape overlay (volumes + start-over) until those exist in-world.
4. **Five side-panning rooms:** reuse `_wipe_pan` / `_on_nav` / `ui_left`/`ui_right`. Easiest: one `Control` host of width `5 * 1680`, five room Controls at x = 0,1680,3360,…; tween `position.x`. That is the same trick as `_shelf_host` (973–999) and the exterior arrive pan (447). Do **not** add a Camera2D unless you also move every HUD `top_level` node; fly_tip, speech, pause, and tutorial are top_level and ignore a camera.
5. **Keep `Main` as the run owner.** Starting a run: `close_cabin()` / hide CabinRoot, `_begin_*`, `paused = false`. Returning from Leave: already `_open_home_cabin(true)` then `_on_home_cabin_closed` → title. After overhaul, that close should land in CabinRoot, not parchment.
6. **Collection room** can keep the current `_hole` + `_rebuild_shelves` code; other rooms are new art + buttons. Do not invent a second Seen/Swiped store.

Existing paper: `design/paper-fight/done/2026-10-17-home-cabin.md` (rules already shipped). Art sizes: `assets/dungeon/home/SIZES.md`. Shelf brief: `design/home-cabin-shelf-brief.md`.

---

## Open questions for the designer

1. Is the cabin the **only** title, or does a parchment still cover win/lose/rest?
2. Which five rooms, and which of today’s buttons live in which room (How to Play, Quick Start, mill, Challenge, collection, settings)?
3. Does starting a run from a door **Leave-swipe** first, or only Challenge rest Leave (current rule)?
4. Should How to Play still skip Home, or does Nib meet you in a cabin room?
5. Are gallery doors new drawings (`gallery_door_left/right`, `trophy_mount_seen`), or do we keep faking the exterior door?
6. Does a 5-room pan stay at 1680×1040 per room (web weight), or is one scrolling interior cheaper?
7. Settings: stay on Escape, or become a cabin object (radio, book)? Web still cannot Quit.
8. Should dying in Challenge after a clear still say “Victory”, or is that parchment going away with the overhaul?
9. Collection inspect: hover fly-tip (current) vs click-to-pin vs a lectern? Locked silhouettes stay unreadable?
10. New copy: `cabin.*` keys, and stop reusing `title.leave` for Exit?

---

## Appendix A — Every item and monster id

Display-name **key** is the CSV snapshot id. Live inspect uses catalog `name`, not that key. Icon is `ITEM_PNG` / `MONSTER_PNG` when present, else atlas stem in `dungeon_art.gd`.

### Items

| id | name | copy key | color | rarity | status | bucket | icon |
|---|---|---|---|---|---|---|---|
| throwing_knife | Throwing Knife | `card.item.throwing_knife.name` | atk | starter | live | 0 | `assets/dungeon/items/throwing_knife.png` |
| shield | Shield | `card.item.shield.name` | blk | starter | live | 0 | `assets/dungeon/items/shield.png` |
| sai | Sai | `card.item.sai.name` | atk | starter | live | 3 | `assets/dungeon/items/sai.png` |
| medallion | Medallion | `card.item.medallion.name` | blk | starter | live | 0 | `assets/dungeon/items/medallion.png` |
| helmet | Helmet | `card.item.helmet.name` | blk | starter | live | 0 | `assets/dungeon/items/helmet.png` |
| da_boot | The Boot | `card.item.da_boot.name` | defeat | starter | live | 0 | `assets/dungeon/items/boot.png` |
| grimoire | Grimoire | `card.item.grimoire.name` | atk | uncommon | live | 9 | `assets/dungeon/items/grimoire.png` |
| bloody_gauntlets | Bloody Wraps | `card.item.bloody_gauntlets.name` | atk | uncommon | live | 1 | `assets/dungeon/items/bloody_gauntlets.png` |
| breastplate | Breastplate | `card.item.breastplate.name` | blk | uncommon | live | 3 | `assets/dungeon/items/breastplate.png` |
| bracers | Right Bracer | `card.item.bracers.name` | blk | starter | live | 1 | `assets/dungeon/items/bracers.png` |
| left_bracer | Left Bracer | `card.item.left_bracer.name` | blk | starter | live | 1 | `assets/dungeon/items/left_bracer.png` |
| smoke_bomb | Smoke Bomb | `card.item.smoke_bomb.name` | smoke | uncommon | todo | 3 | `assets/dungeon/items/smoke_bomb.png` |
| knucklers | Knucklers | `card.item.knucklers.name` | atk | starter | live | 0 | `assets/dungeon/items/knucklers.png` |
| fangs | Fangs | `card.item.fangs.name` | defeat | uncommon | live | 9 | `assets/dungeon/items/fangs.png` |
| poison_flask | Poison Flask | `card.item.poison_flask.name` | utility | uncommon | todo | 6 | `assets/dungeon/items/poison_flask.png` |
| cursed_scroll | Cursed Scroll | `card.item.cursed_scroll.name` | heal | uncommon | live | 5 | `assets/dungeon/items/cursed_scroll.png` |
| spider_egg | Spider Egg | `card.item.spider_egg.name` | egg | uncommon | live | token (−1) | `assets/dungeon/items/spider_egg.png` |
| spiked_flail | Spiked Flail | `card.item.spiked_flail.name` | atk | starter | live | 8 | `assets/dungeon/items/spiked_flail.png` |
| healing_potion | Healing Potion | `card.item.healing_potion.name` | heal | uncommon | todo | 10 | `assets/dungeon/items/healing_potion.png` |
| crossbow | Crossbow | `card.item.crossbow.name` | atk | uncommon | live | 2 | `assets/dungeon/items/crossbow.png` |
| sledgehammer | Sledgehammer | `card.item.sledgehammer.name` | defeat | uncommon | live | 9 | `assets/dungeon/items/sledgehammer.png` |
| pocketwatch | Pocketwatch | `card.item.pocketwatch.name` | atk | uncommon | live | 10 | `assets/dungeon/items/watch.png` |
| double_axe | Double Axe | `card.item.double_axe.name` | atk | uncommon | live | 5 | `assets/dungeon/items/double_axe.png` |
| victory_flask | Victory Flask | `card.item.victory_flask.name` | heal | uncommon | live | 0 | `assets/dungeon/items/victory_flask.png` |
| grappling_hook | Grappling Hook | `card.item.grappling_hook.name` | utility | uncommon | live | 2 | `assets/dungeon/items/grappling_hook.png` |
| spiked_shield | Spiked Shield | `card.item.spiked_shield.name` | blk | uncommon | live | 4 | `assets/dungeon/items/spiked_shield.png` |
| grief_jar | Grief Jar | `card.item.grief_jar.name` | blk | uncommon | live | 5 | `assets/dungeon/items/grief_jar.png` |
| longbow | Longbow | `card.item.longbow.name` | atk | uncommon | live | 6 | `assets/dungeon/items/longbow.png` |
| lantern | Lantern | `card.item.lantern.name` | heal | uncommon | live | 4 | `assets/dungeon/items/lantern.png` |
| mirror_shard | Mirror Shard | `card.item.mirror_shard.name` | blk | uncommon | live | 10 | `assets/dungeon/items/mirror_shard.png` |
| echo_bell | Echo Bell | `card.item.echo_bell.name` | chaos | uncommon | live | 7 | `assets/dungeon/items/echo_bell.png` |
| quiet_bell | Quiet Bell | `card.item.quiet_bell.name` | utility | uncommon | live | 2 | `assets/dungeon/items/quiet_bell.png` |
| net | Net | `card.item.net.name` | utility | uncommon | live | 0 | `assets/dungeon/items/net.png` |
| iron_chain | Chain | `card.item.iron_chain.name` | atk | uncommon | live | 7 | `assets/dungeon/items/iron_chain.png` |
| counting_beads | Counting Beads | `card.item.counting_beads.name` | atk | uncommon | live | 0 | `assets/dungeon/items/counting_beads.png` |
| last_match | Paci-Fist | `card.item.last_match.name` | defeat | uncommon | live | 8 | `assets/dungeon/items/last_match.png` |
| measuring_tape | Scythe | `card.item.measuring_tape.name` | defeat | uncommon | live | 3 | `assets/dungeon/items/measuring_tape.png` |
| mute_stone | Chaos Stone | `card.item.mute_stone.name` | chaos | uncommon | live | 6 | `assets/dungeon/items/mute_stone.png` |
| arrow_head | Arrow Head | `card.item.arrow_head.name` | atk | uncommon | live | 7 | `assets/dungeon/items/arrow_head.png` |
| danger_magnet | Danger Magnet | `card.item.danger_magnet.name` | utility | uncommon | live | 4 | `assets/dungeon/items/danger_magnet.png` |
| dagger | Dagger | `card.item.dagger.name` | (empty) | starter | retired | 0 | atlas `weapon_knife` (no ITEM_PNG) |
| helmet_hidden | Helmet | `card.item.helmet_hidden.name` | (empty) | starter | retired | 0 | (none unique) |
| bandana | Bandana | `card.item.bandana.name` | (empty) | starter | retired | 0 | (none unique) |
| caltrops | Caltrops | `card.item.caltrops.name` | (empty) | uncommon | retired | 0 | `assets/dungeon/items/caltrops.png` (PNG exists; card retired) |

### Monsters

| id | name | call name | copy key | rarity | status | bucket | icon |
|---|---|---|---|---|---|---|---|
| wizard | Wizard | | `card.monster.wizard.name` | starter | live | 0 | `assets/dungeon/extra/wizard.png` |
| golem | Golem | | `card.monster.golem.name` | starter | live | 0 | `assets/dungeon/extra/golem.png` |
| goblin | Goblin | Evasive | `card.monster.goblin.name` | starter | live | 0 | `assets/dungeon/extra/goblin.png` |
| skeleton | Skeleton | HP Echo | `card.monster.skeleton.name` | starter | live | 1 | `assets/dungeon/extra/skeleton.png` |
| hornet_swarm | Hornet Swarm | Double Strike | `card.monster.hornet_swarm.name` | starter | todo | 0 | `assets/dungeon/extra/hornet_swarm.png` |
| lich | Lich | Siphon | `card.monster.lich.name` | starter | live | 2 | `assets/dungeon/extra/lich.png` |
| ogre | Ogre | Empath | `card.monster.ogre.name` | uncommon | live | 1 | `assets/dungeon/extra/ogre.png` |
| vampire | Vampire | Bloodlust | `card.monster.vampire.name` | uncommon | live | 1 | `assets/dungeon/extra/vampire.png` |
| berserker | Berserker | Outburst | `card.monster.berserker.name` | uncommon | live | 0 | `assets/dungeon/extra/berserker.png` |
| dire_wolf | Dire Wolf | Kill Shot | `card.monster.dire_wolf.name` | uncommon | live | 0 | `assets/dungeon/extra/dire_wolf.png` |
| bandit | Bandit | Hoarder | `card.monster.bandit.name` | uncommon | live | 0 | `assets/dungeon/extra/bandit.png` |
| leech_league | Leech League | Blood Rise | `card.monster.leech_league.name` | uncommon | live | 3 | `assets/dungeon/extra/leech_league.png` |
| wraith | Wraith | Neighbor's Wrath | `card.monster.wraith.name` | uncommon | todo | 5 | `assets/dungeon/extra/wraith.png` |
| mimic | Mimic | Treasure | `card.monster.mimic.name` | uncommon | todo | 4 | `assets/dungeon/extra/mimic.png` |
| two_headed_serpent | Damsel In Distress | Guarded by Monsters | `card.monster.two_headed_serpent.name` | uncommon | live | 2 | `assets/dungeon/extra/damsel.png` |
| slime_boss | Slime Boss | Body Slam | `card.monster.slime_boss.name` | uncommon | live | 0 | `assets/dungeon/extra/slime_boss.png` |
| spider_queen | Spider Queen | Egg Layer | `card.monster.spider_queen.name` | uncommon | live | 3 | `assets/dungeon/extra/spider.png` |
| commander | Commander | War Cry | `card.monster.commander.name` | uncommon | live | 8 | `assets/dungeon/extra/commander.png` |
| dragon | Dragon | Firebreather | `card.monster.dragon.name` | uncommon | live | 0 | `assets/dungeon/extra/dragon.png` |
| needleback | Needleback | Spiky | `card.monster.needleback.name` | uncommon | live | 4 | `assets/dungeon/extra/needleback.png` |
| gelatinous_cube | Gelatinous Cube | Devour Item | `card.monster.gelatinous_cube.name` | uncommon | live | 7 | `assets/dungeon/extra/gelatinous_cube.png` |
| gargoyle | Gargoyle | Petrify | `card.monster.gargoyle.name` | uncommon | live | 6 | `assets/dungeon/extra/gargoyle.png` |
| harpy | Harpy | Impatient | `card.monster.harpy.name` | uncommon | live | 6 | `assets/dungeon/extra/harpy.png` |
| kobold_trapper | Kobold Trapper | Trap Card | `card.monster.kobold_trapper.name` | uncommon | live | 7 | `assets/dungeon/extra/kobold_trapper.png` |
| clockwork_knight | Clockwork Knight | Disassemble | `card.monster.clockwork_knight.name` | uncommon | live | 8 | `assets/dungeon/extra/clockwork_knight.png` |
| basilisk | Basilisk | Famine | `card.monster.basilisk.name` | uncommon | live | 7 | `assets/dungeon/extra/basilisk.png` |
| hollow | Twins | Doubly Troubled | `card.monster.hollow.name` | uncommon | live | 5 | `assets/dungeon/extra/hollow.png` |
| beggar | Beggar | Leftie | `card.monster.beggar.name` | uncommon | live | 9 | `assets/dungeon/extra/beggar.png` |
| wick | Wick | Death Toll | `card.monster.wick.name` | uncommon | live | 9 | `assets/dungeon/extra/wick.png` |
| anvil | Anvil | Tough Blood | `card.monster.anvil.name` | uncommon | live | 5 | `assets/dungeon/extra/anvil.png` |
| bodyguard | Bodyguard | Protector | `card.monster.bodyguard.name` | uncommon | live | 2 | `assets/dungeon/extra/bodyguard.png` |
| cowardly_king | Cowardly King | Guards! | `card.monster.cowardly_king.name` | uncommon | live | 9 | `assets/dungeon/extra/cowardly_king.png` |
| merchant | Merchant | Fair Trade | `card.monster.merchant.name` | uncommon | live | 4 | `assets/dungeon/extra/merchant.png` |
| juggernaut | Juggernaut | Blockhead | `card.monster.juggernaut.name` | uncommon | live | 8 | `assets/dungeon/extra/juggernaut.png` |
| cleric | Cleric | Health Insurance | `card.monster.cleric.name` | uncommon | live | 6 | `assets/dungeon/extra/cleric.png` |

Cabin does **not** mount monsters. Nib is `assets/dungeon/extra/nib.png` (not a card).

---

## Appendix B — Every `player-copy.json` key

234 rows. `id = swipe-player-copy-v3-draftgate`, `updated = 2026-10-10`.

**Title (26):** `title.overlay`, `title.sub`, `title.how_to_play`, `title.dive_in`, `title.begin`, `title.adventure`, `title.home`, `challenge.begin`, `challenge.pick_open`, `challenge.pick_loot`, `challenge.click_target`, `challenge.spin_confirm`, `challenge.full_hand`, `challenge.begin_cue`, `title.rest`, `title.rest_sub`, `title.continue`, `title.leave`, `title.adventure_win`, `title.dungeons_cleared`, `adventure.scarier`, `title.win`, `title.win_sub`, `title.lose`, `title.lose_sub`, `title.again`.

**Pause (7):** `pause.settings`, `pause.hint`, `pause.resume`, `pause.quit`, `pause.start_over`, `pause.ambience`, `pause.ui`.

**Tutorial (58):** `tutorial.speaker`, `tutorial.skip`, `tutorial.nudge_wait`, `tutorial.nudge_item`, plus `tutorial.beat.01` … `18` each with `.body`, `.go`, `.hint`.

**Door (13):** `door.title`, `door.shiny`, `door.owner`, `door.help`, `door.hook`, `door.take`, `door.pass`, `door.pass_none`, `door.seat`, `door.guard`, `tier.1.name`, `tier.2.name`, `tier.3.name`.

**Cues (10):** `cue.starters`, `cue.force`, `cue.ask`, `cue.steal`, `cue.seat`, `cue.filling`, `cue.ready`, `cue.fighting`, `cue.mark`, `cue.devtest`.

**Combat (7):** `combat.spin`, `combat.safe`, `combat.take_hit`, `combat.blocked`, `combat.slain`, `combat.knife_throw`, `combat.knife_nick`.

**Inspect (7):** `inspect.title`, `inspect.idle`, `inspect.empty_title`, `inspect.empty_place`, `inspect.empty`, `inspect.shift`, `inspect.placeholder`.

**Warns (6):** `warn.spent`, `warn.boot`, `warn.neighbor`, `warn.sledge`, `warn.poison`, `warn.crossbow`.

**Taunts (100):** `taunt.default.1`–`5`; then `.1`–`.5` for `throwing_knife`, `shield`, `sai`, `medallion`, `helmet`, `da_boot`, `grimoire`, `bloody_gauntlets`, `breastplate`, `bracers`, `smoke_bomb`, `knucklers`, `fangs`, `poison_flask`, `spiked_flail`, `healing_potion`, `crossbow`, `sledgehammer`, `pocketwatch`. Later items have no taunt rows.

---

## Appendix C — Main children created at runtime (`_ready` / `_build_ui`)

Order matters for input and draw (later children are on top unless `z_index` says otherwise):

1. `art` (`dungeon_art.gd`)
2. `dungeon_bg`
3. `_ui_root` MarginContainer (play field: hearts, trophy, cue, tray, wheel, dungeon deck, challenge draft, buttons, hotbar)
4. `inspect` HoverPanel (hidden)
5. `overlay` title parchment
6. `_copy_stamp` (editor)
7. `fly_tip` HoverPanel
8. `tut` tutorial_guide
9. `combat_stage`
10. `face_box`
11. `hypno_stage` / `hypno_box`
12. `speech_box`
13. `ability_fx` / `ability_slash`
14. `draft_gate`
15. `_courier`
16. `fx_flash` / `_hall_wipe`
17. `sfx` AudioFx
18. `settings_ui`
19. `home_cabin`
20. `_bucket_reveal`
21. editor: `content_ed`, `roster_ed`, `script_ed`

That list is the practical “scene tree” for the overhaul. `CabinRoot` should stay item 19 (or replace it) and steal title duty from item 5.
