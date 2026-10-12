# Three work lanes

Swipe used to keep almost every rule in `scripts/main.gd`. That file is now a short boot script. The rest of the loop lives in smaller files so three people (or three agents) can edit at the same time without stepping on each other.

Read this before you pick a file. Existing rules still apply: author locks, content board, Paper Fight, unique art, QA, visual handoff.

Before implementing anything, read `data/content-board.json` and `data/catalog.json` on the current `origin/main`. These hold Nathan's saved edits from the in-game F5 editor and are the source of truth for content. Never overwrite or reformat his saved fields. Respect `author_lock`.

## How the scripts fit together

`scenes/main.tscn` still runs `scripts/main.gd`. That script **extends** a chain of other scripts. The running scene is one object. It has every variable and every function from every layer.

So a function in `fight_flow.gd` can call `_refresh()` even though `_refresh` is written in `hud_controller.gd`. You do not pass a `game` object around. You do not change `hp` to `game.hp`. Write the call the same way as before.

Chain, parent first:

1. `scripts/lanes/game_state.gd` — shared variables and paths
2. `scripts/content/content_defs.gd` — item-ops fallback and monster specials
3. `scripts/content/catalog_io.gd` — catalog load, card factories, formulas
4. `scripts/core/fight_flow.gd` — fight resolution
5. `scripts/core/draft_flow.gd` — mill / door / seat
6. `scripts/core/run_flow.gd` — title, reset, adventure
7. `scripts/core/tutorial_flow.gd` — How to Play steps
8. `scripts/ui/hud_controller.gd` — screens, HUD, inspect, cues
9. `scripts/ui/authoring_ui.gd` — F5 log, Roster, Script, Developer Test
10. `scripts/main.gd` — `_ready`, `_process`, `_unhandled_input`

QA tools that read `current_scene.hp` / `phase` / `_use_item()` still talk to Main. That is on purpose.

---

## 1. UI / Text / UX

Screens, HUD, menus, fonts, theme, and player-facing copy **lookups**. Jam still owns the words in `data/player-copy.json`. This lane wires keys and draws the screen. It does not rewrite locked strings.

### Owns (edit freely)

| Path | What it is |
|---|---|
| `scripts/ui/hud_controller.gd` | Title/victory/defeat/inspect/hand/cues, build UI, refresh, feel |
| `scripts/ui/authoring_ui.gd` | F5 log, copy stamp, Roster/Script/card editor chrome, Developer Test grid |
| `scripts/title_screen.gd` | Title scene |
| `scripts/talk_box.gd` | How to Play talk box look |
| `scripts/tutorial_guide.gd` | Vignette, hole, Nib frames (look, not step order) |
| `scripts/wheel_hud.gd` | Hearts, Spin, hand row, column |
| `scripts/boss_wheel.gd` | Wheel drawing |
| `scripts/draft_gate.gd` | Door plate look |
| `scripts/owner_plate.gd` | Owner column plate |
| `scripts/placement_plate.gd` | Seat column plate |
| `scripts/fight_plate.gd` | Fight column plate |
| `scripts/inspect_plate.gd` | Inspect plate |
| `scripts/end_plate.gd` | Victory / defeat plates |
| `scripts/settings_menu.gd` | Pause |
| `scripts/item_card.gd` | Hand card look |
| `scripts/hover_panel.gd` | Floating inspect |
| `scripts/speech_bubble.gd` | Owner speech bubble |
| `scripts/ux_style.gd` | Shared colors / chips |
| `scripts/ui_palette.gd` | Barlow Semi Condensed for names and body; Nunito for numbers |
| `scripts/player_copy.gd` | Lookup helpers only. Do not change JSON text from chat. |
| `scripts/dungeon_art.gd` | Sprite registration |
| `scripts/dungeon_bg.gd` | Soot ground |
| `scripts/combat_stage.gd` | Fight portraits (look) |
| `scripts/trophy_mount.gd` | Skull count mount |
| `scripts/audio_fx.gd` | SFX / music |
| `scenes/ui/` | All player UI scenes |
| `themes/swipe_theme.tres` | Theme |
| `assets/ui/` `assets/fonts/` `assets/ui/fonts/` | Art and fonts this lane shows |
| `design/visual/` | Mockups, screen specs, QA stills |
| `design/HANDOFF.md` | Visual message board (every chat logs here) |

`data/player-copy.json` is **Jam’s file**. This lane reads it. Chat does not restyle the strings. See `author-lock.mdc`.

### Do not own

Item ops, monster specials, catalog numbers, fight math, mill order, adventure halls, How to Play **step sequence**.

---

## 2. Core gameplay

Adventure / run flow, How to Play **order**, turn / fight / draft orchestration, game state, how the systems fit together.

### Owns (edit freely)

| Path | What it is |
|---|---|
| `scripts/core/run_flow.gd` | New run, Adventure halls, pause-mode routing, overlay primary |
| `scripts/core/draft_flow.gd` | Mill, Take/Leave, seat, bribe, starter kit seating |
| `scripts/core/fight_flow.gd` | Spin, items, Done, ops interpreter, monster specials, targeting |
| `scripts/core/tutorial_flow.gd` | How to Play waits, focus, forced mill / combat |
| `scripts/review_stage.gd` | Review helper used by the run |
| `design/paper-fight/` | Write here before a new rule |

### Do not own

Card numbers and ops tables (content). Screen layout, fonts, theme, copy wording (UI).

---

## 3. Content & balance

Items, monsters, stats, abilities, tier rules, data definitions.

### Owns (edit freely)

| Path | What it is |
|---|---|
| `scripts/content/content_defs.gd` | `ITEM_OPS` fallback and `MONSTER_SPECIAL` table. Same values as the old `main.gd` consts. |
| `scripts/content/catalog_io.gd` | Load catalog/runtime, `_make_item` / `_make_monster`, formulas, pools, tier pick, Roster merge |
| `scripts/monster_lines.gd` | Speech / reminder lookup (data, not the bubble look) |
| `scripts/draft_lines.gd` | Door owner lines |
| `scripts/author_lock.gd` | Lock ledger I/O |
| `scripts/content_editor.gd` | F5 card sheet (fields this lane saves) |
| `scripts/roster_editor.gd` | F5 Roster |
| `scripts/script_editor.gd` | F5 How to Play script editor (the script rows, not the talk-box look) |
| `data/catalog.json` | Runtime card table |
| `data/runtime.json` | Which cards are in the mill |
| `data/content-board.json` | Authoring sheet (written by Save) |
| `data/author-locks.json` | Lock ledger (written by Save) |
| `design/content-board.html` | HTML board if the JSON is missing |

`data/player-copy.json` is **not** this lane. Jam owns the wording.

Do not change locked `name` / `ability` / `explainer` / numbers from chat. See `author-lock.mdc`.

---

## Shared files

Touch these **one lane at a time**, and change the smallest thing that works.

| Path | Why it is shared | Who edits it, and how |
|---|---|---|
| `scripts/main.gd` | Boot, frame, input only | The lane whose hook it is. Add a one-line call, do not grow this file. |
| `scripts/lanes/game_state.gd` | Every `var` the scene keeps (`hp`, `phase`, `wheel`, `hotbar`, …). Paths and preloads. Balance caps used to init state (`HP_MAX`, `STARTER_COUNT`, `REFUSALS_MAX`, `DRAFT_ROUNDS`, `HAND_MAX`). The long stub list at the bottom exists so Godot 4.7 can compile a parent that calls a method written in a child file. The stub is never the live code — Main uses the real function. | Content if you are changing a cap or a preload for a card. Core if you add a new run flag. UI if you add a node reference. If you add a **new** function that an ancestor will call, add a matching stub here too. One field, one lane. |
| `scenes/main.tscn` | Still just Main + `main.gd` | Almost never. |
| `project.godot` | Autoloads, window, theme defaults | The lane that needs the setting. |
| `design/LANES.md` | This map | Update when you add a file a lane will own. |
| `design/HANDOFF.md` | Visual board | Every chat, Cursor logs. |
| `.cursor/rules/*.mdc` | Standing orders | New policy only. Do not bury a card change here. |

If two lanes need the same new variable, add it in `game_state.gd` in one edit, then each lane uses it from its own file.

---

## How to route a new task

1. **Player-facing words or a screen look** (font, theme, plate, cue key, sprite on a card) → **UI**. Read `data/player-copy.json` / the board; do not invent new wording. If Pixel left an OPEN `design/visual/specs/SCREEN-*.md`, that is UI.
2. **What happens when the player clicks** (new phase, targeting, spend, tutorial step order, adventure hall) → **Core**. Paper Fight first unless he skipped it or the board Save already says what happens when cards collide.
3. **A card’s numbers, ops, special, tier, or pool membership** → **Content**. Ingest the board Save. Implement Flow in `catalog_io.gd` / `content_defs.gd` and, if the `ops.kind` is new, the match arm in `fight_flow.gd` (that second file is Core — do the content data first, then a separate Core edit for the new kind).
4. **Both a new kind and a new plate** → Content data, then Core interpreter, then UI look. Three small edits, not one mixed file.
5. **Unsure** → say which two files you would touch and stop. Do not guess a collision with Hornet, Queen, or Block.

`scripts/main.gd` is not the place for a new rule.

---

## Could not split cleanly

These stay mixed on purpose. Behavior is identical to the old single file.

- **`_item_view` lives in Core (`fight_flow.gd`)** even though the hand card shows its numbers. The interpreter and the printed number use the same function. Splitting it would risk the card showing 4 and the hit dealing 3.
- **`_item_rule` / inspect paint live in UI (`hud_controller.gd`)** even though they read ops. They only format text and colors. The numbers still come from `_item_view`.
- **Balance caps (`HP_MAX` and the other counts) live in `game_state.gd`** because `var hp: int = HP_MAX` has to see them. Content may change those numbers with a small shared-file edit.
- **Scene preloads live in `game_state.gd`** so every layer can instance the same scenes. Adding a new UI scene is a one-line preload there plus the UI script/scene files.
- **`scripts/tutorial_guide.gd` is UI look; `tutorial_flow.gd` is step order.** A How to Play copy change is UI (and Jam’s JSON). A new wait/focus step is Core.

---

## Paper Fight and QA

Unchanged. New or changed rules still go through `design/paper-fight/`. After a gameplay or content change, run QA per `qa-verify.mdc`. This refactor did not change any rule.
