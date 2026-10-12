# Swipe / boss-rush — control plane, data plane, and Godot runtime

This document is a model-agnostic reconstruction of how the game is authored and shipped. Cursor, Claude, Grok, and any other chat client are interchangeable **control-plane clients**. They are not the source of truth. Disk JSON plus Godot GDScript are.

Repo: `C:\Users\Natha\Documents\boss-rush`  
Engine: Godot 4.7.x, GDScript, `gl_compatibility`, main scene `res://scenes/main.tscn` (`scripts/main.gd`).  
Product name in `project.godot`: **Swipe**. Informal repo name: **boss-rush**.

A successor agent that does not use Cursor still has a complete loop if it can: (1) read/write the JSON ledgers, (2) patch GDScript, (3) treat in-engine Save as an authoritative write, (4) obey the change-control rules encoded in `.cursor/rules/*.mdc` (those files are policy, not engine code).

---

## 1. Three planes

```
┌─────────────────────────────────────────────────────────────────┐
│ CONTROL PLANE (human + agent)                                   │
│  Chat messages, screenshots, AskQuestion answers, F5 Play       │
│  Policy: .cursor/rules/*.mdc + user rules (portable as markdown)│
└────────────────────────────┬────────────────────────────────────┘
                             │ writes / reads
┌────────────────────────────▼────────────────────────────────────┐
│ DATA PLANE (source of truth on disk)                            │
│  data/content-board.json   authoring sheet (Roster SoT)         │
│  data/catalog.json         runtime card definitions             │
│  data/runtime.json         mill/dungeon membership order        │
│  data/author-locks.json    write-protect ledger                 │
│  data/player-copy.json     HUD/cue strings (Jam copy)           │
│  design/paper-fight/       gameplay change-control records      │
│  assets/                   sprites, SFX, BGM                    │
└────────────────────────────┬────────────────────────────────────┘
                             │ loaded at boot; rewritten on Save
┌────────────────────────────▼────────────────────────────────────┐
│ RUNTIME PLANE (Godot process)                                   │
│  F5 Play / exported binary                                      │
│  scripts/main.gd  thin boot; logic in scripts/{content,core,ui} │
│  Lane map: design/LANES.md                                      │
│  In-game editors: Roster, card sheet, Script editor             │
│  Live RAM: wheel[], hotbar[], catalog{}, monsters_by_id{}       │
└─────────────────────────────────────────────────────────────────┘
```

**Invariant:** Nathan does not paste rules into chat as the durable copy. He Saves in the F5 editors (or the HTML board). The agent reads those files. Chat is commentary, screenshots, and answers to Paper Fight questions.

---

## 2. Control plane — where input actually arrives

There is no application API for “author a card.” Input is unstructured human traffic that an agent must classify.

### 2.1 Channels (priority)

| Priority | Channel | What it is | What the agent must do |
|---|---|---|---|
| 1 | **In-engine Save** | Roster / card editor / Script editor / HTML board wrote JSON | Treat disk as already-decided copy. Do not ask him to retype it. |
| 2 | **This chat + screenshots** | Intent, UX complaints, Paper Fight answers, “F5 this” | Classify: feel vs rule vs copy vs art. Rules go through Paper Fight unless skipped. |
| 3 | **`review_note` on a card** | Gold box in Roster: notes for the agent | After Save, implement that note; do not ignore it because the next message is about something else. |
| 4 | **Policy files** | `.cursor/rules/*.mdc` and Cursor User Rules | These are standing orders. A non-Cursor agent must load the same text. |

### 2.2 Cursor-specific wiring (optional)

If the client is Cursor Agent:

- Workspace rules with `alwaysApply: true` are injected every turn: Paper Fight, content-board ingest, author-lock, unique art.
- User rules add voice, git, and “he does not paste rules — you write them.”
- Tools: `Read` / `Write` / `StrReplace` / `Grep` / `Shell` against the workspace; Godot is invoked as an external process (`Godot_v4.7.2-stable_win64.exe --path <repo> --headless --quit-after 2` for a parse/boot smoke).
- `AskQuestion` is the structured multiple-choice control used during Paper Fight. A non-Cursor agent must still **stop and wait** after asking equivalent questions; do not implement in the same turn.

None of that is required to run the game. Required: filesystem + Godot.

### 2.3 Classification of a human message

Every inbound message is one or more of:

1. **Authoring Save already on disk** — he Saved then closed (or the JSON mtime is new). Ingest board; ship behavior if Flow/Notes are unambiguous.
2. **Gameplay rule change** — new item/monster/special/formula/targeting/spend/phase. Paper Fight first unless he said skip / just ship it / F5 this, or the board Save already settles collisions.
3. **Feel / layout / art / copy** — implement the same turn. Guess, build, say what changed. F5 is enough; HTML5 export is not required.
4. **Screenshot of a bug or UX** — treat the pixels as ground truth for what he saw, including unsaved editor state.
5. **Override of author_lock** — only if he clearly names the keys. Chat may not restyle locked copy.

---

## 3. Data plane — file contracts

All durable game data lives under the repo. Godot `res://` maps to the project root. Editors write via `ProjectSettings.globalize_path()` then `FileAccess`, with a `.tmp` + rename in `author_lock.write_json` to avoid truncated files.

### 3.1 `data/content-board.json` — authoring source of truth

Document id: `boss-rush-content-board`.

Arrays: `items[]`, `monsters[]`. Each card is a flat dict:

| Field | Role |
|---|---|
| `id` | Stable snake_case key (`throwing_knife`, `hornet_swarm`). Runtime identity. |
| `kind` | `item` \| `monster` |
| `name` | Player-facing title |
| `ability` | First-person / card sentence |
| `explainer` | Short hover / Shift line |
| `flow` | Implementer spec (“How it works”). Maps to catalog `defined`. |
| `notes` | Exceptions for chat. Maps to catalog `exceptions`. |
| `ops` | Item rules object. Executed by `main.gd` `_ops_of` / `_apply_ops`. Empty `{}` on monsters. |
| `atk_base`, `hp_base` | Printed combat numbers (monsters). `null` = use catalog / formula. |
| `atk_formula`, `hp_formula` | String formulas evaluated at spin/sync. Blank = use base. |
| `rarity` | `starter` \| `uncommon` |
| `tier` | 1 bronze, 2 silver, 3 gold |
| `count` | Copies in the pool (not Attack) |
| `priority` | Draw/offer order, lower sooner (not HP) |
| `status` | `live` \| `todo` \| `hold` \| `retired` |
| `review` | `rough` → `refined` → `polish` → `finished` |
| `review_note` | Agent work queue from the gold box |
| `author_lock`, `locked_fields[]`, `locked_at` | Write-protect stamp from Save |
| `contradiction_ids` | Named collisions (e.g. Wraith vs Commander) |

**Status machine:** Save of Flow / Notes / formulas while `status == live` flips the row to `todo` (`roster_editor.gd` `_gather_row`). After the agent implements and verifies, set `live` again. `hold` / `retired` are skipped unless he named them. Leftover `todo` from an old HTML board is **not** a mandate to rebuild the whole roster.

**Alternate SoT:** `design/content-board.html` (Zen Browser). Same schema conceptually. Use only if `content-board.json` is missing.

### 3.2 `data/catalog.json` — runtime card table

Loaded at `_ready` into `catalog`, then indexed as `monsters_by_id` / `items_by_id`.

Monster rows nest combat stats:

```json
"atk": { "base": 3, "formula": "optional string" },
"hp":  { "base": 7, "formula": "optional string" }
```

Item rows carry `ops` (same object as the board).

Field mapping on merge (`main.gd` `_merge_catalog_card`):

| Board | Catalog |
|---|---|
| `ability` | `ability` |
| `explainer` | `explainer` |
| `flow` | `defined` |
| `notes` | `exceptions` |
| `atk_base` / `atk_formula` | `atk.base` / `atk.formula` |
| `hp_base` / `hp_formula` | `hp.base` / `hp.formula` |
| `ops` | `ops` (items) |
| lock flags | copied through |

Empty `atk_base` on the board **does not clear** an existing catalog `atk.base`. Only a non-null board value overwrites. Formulas: non-empty string writes `formula`; empty string erases it so the printed base is used.

Catalog also holds `combat_flow[]`, `contradictions[]`, `keywords`, `rulings[]` — design memory, not all of it executed.

### 3.3 `data/runtime.json` — membership, not stats

Two id lists: `items[]`, `monsters[]`. This is which cards may appear in mill/dungeon order. Roster Save appends new ids and prunes `retired`/`hold`. Stats do **not** live here.

### 3.4 `data/author-locks.json` — write-protect ledger

Rebuilt on every Roster/Script Save (`AUTHOR_LOCK.rebuild_ledger`). Keys:

- `cards["item:id"]` / `cards["monster:id"]` → `{ name, fields[], locked_at }`
- `script["copy.key"]` → `{ cat, where, text, locked_at }`

**Policy:** An agent must not rewrite locked `name`, `ability`, `explainer`, `flow`, `notes`, `ops`, numbers, rarity, tier, count, priority, or locked script `text`. No Title Case, keyword paint, or “cleanup.” `status` is not locked. His in-engine Save may change locked text; chat may not, unless he overrides named keys in that turn.

### 3.5 `data/player-copy.json` — HUD / cue strings

Loaded by `scripts/player_copy.gd`. Lookup: `PLAYER_COPY.text("cue.ready", fallback)`. The Script editor Saves rows here and stamps `author_lock` per row. Card ability text is **not** this file; that lives on the board/catalog.

### 3.6 Other data

| Path | Role |
|---|---|
| `data/player-copy.csv` | Export/import sibling of copy JSON |
| `design/paper-fight/CURRENT.md` | Active gameplay review |
| `design/paper-fight/TEMPLATE.md` | Empty fight form |
| `design/paper-fight/done/*.md` | Closed fights (dated slug) |
| `design/idea-bank/BANK.md` | Unused idea remainder |
| `assets/dungeon/` | 16×16 sprites; `ITEM_PNG` / `MONSTER_PNG` in `dungeon_art.gd` |
| `scripts/dungeon_art.gd` | Texture registry; extras beat atlas stems |

---

## 4. Write path — F5 editors back to disk

Godot Editor **Play (F5)** instantiates `main.tscn`. That process can write the repo. Closing the game after Save is sufficient; he does not need to say “check the board.”

### 4.1 Roster (`scripts/roster_editor.gd`)

- Open: in-game control (paused tree, `PROCESS_MODE_ALWAYS`).
- Grid of all items or all monsters. Ctrl+S / Save all / Save.
- `_flush_visible` gathers rows → merges into `content-board.json` by id → `AUTHOR_LOCK.write_json` → `rebuild_ledger` → updates `runtime.json` ids → emits `committed(items, monsters)`.
- `main.gd` `_on_roster_committed` merges every card into catalog, `_write_catalog()`, `_apply_live_card` so the **current** wheel/hand updates without restart.
- Dirty Flow/Notes/formulas set `status` to `todo`.
- Placeholders must not be persisted (`ATK`, `HP`, `blank = use ATK`, review-note boilerplate). Combat numbers are `atk_base`/`hp_base`, not `count`/`priority`.

### 4.2 Card sheet (`scripts/content_editor.gd`)

Opened from Roster double-click or inspect right-click (`open_card`). Same fields, one card. `saved` → `_on_content_saved` → merge + write catalog + apply live.

### 4.3 Script editor (`scripts/script_editor.gd`)

Edits `player-copy.json` rows. Save stamps author_lock on changed `text`.

### 4.4 HTML board (`design/content-board.html`)

Optional Zen-browser authoring. Same JSON. If he used this instead of F5, it is still SoT.

### 4.5 Live apply

`_apply_live_card` walks `wheel[]`, `hotbar[]`, `pending_monster`, `pending_item` and restamps matching `card_id`. Then `_sync_wheel_stats()` re-evaluates formulas (Lich/Commander neighbor passes, Wraith copy, etc.). F5 Play is the verification environment. HTML5 export is not part of the loop unless requested.

---

## 5. Read path — what an agent does every turn

Encoded in `.cursor/rules/content-board.mdc` and `author-lock.mdc`. Portable procedure:

1. Read `data/author-locks.json`.
2. Read `data/content-board.json`.
3. For each non-`hold`/`retired` card whose **player-facing** fields changed: use that text; do not rewrite locked fields.
4. For each card whose **behavior** fields (Flow, Notes, ops, formulas) disagree with `scripts/main.gd` (and helpers): that card is a ship queue.
   - If Flow + Notes already say what happens in collisions (Hornet extra swings, Queen, Wraith copy, Commander last, Dragon pierce, Goblin unhittable-by-ATK, Mimic gift, empty seats, tutorial): implement.
   - If Ability vs Flow vs Notes disagree, or the rule is new/ambiguous: **Paper Fight**. Do not invent.
5. After shipping, set those cards to `live` on board and catalog. Do not strip locks.
6. If nothing needs code, do not mention the ingest.

Screenshots of **unsaved** Roster rows: interpret intent, place values in the correct fields, write JSON. Warn him not to Save the drifted editor over the write (Esc to discard).

---

## 6. Change control — Paper Fight

Gameplay changes are gated. Feel/art/copy are not.

Procedure (`design/paper-fight/RUBRIC.md`):

1. Overwrite `CURRENT.md` from `TEMPLATE.md`. Fill every heading.
2. Restate: what he clicks, when, what number, whether the card is spent.
3. Place on the live game (nearest existing card; copy-once vs live-updating; auto vs click-target).
4. Collision list: at least Hornet, Queen, Wraith, Commander/Lich, Dragon, Goblin, Mimic, Slime, empty alcove, last owner, tutorial, Developer Test.
5. Generous vs stingy reading. If both fit the sentence, **ask**; do not pick.
6. Stop. Do not implement in that turn.
7. After answers: implement that reading. Move CURRENT to `design/paper-fight/done/YYYY-MM-DD-slug.md`.

Skip if: copy/art/audio only; he named an exact existing number; board Save already settles collisions; he said skip / just ship it / F5 this.

Worked example: `design/paper-fight/_example-copy-the-owner.md`.

---

## 7. Runtime architecture (Godot)

### 7.1 Process

- Editor Play (F5) or `godot --path <repo>`.
- `scenes/main.tscn` is an empty full-rect Control with `main.gd`.
- Almost all UI is constructed in code (`_build_ui`), not in the scene tree.
- Display: 1680×1040, `canvas_items` stretch, expand aspect, `gl_compatibility`.

### 7.2 Phase machine

Typical loop: `title` → mill `draft` (ask/seat) → `ready` → `spinning` → `fighting` → owner removed → `ready` … → `victory` / `defeat` / `rest`. File map: `design/LANES.md`. `scripts/main.gd` only boots. Draft is `draft_flow.gd`, fight is `fight_flow.gd`, adventure is `run_flow.gd`.

Developer Test (`devtest`) seats monsters/items by click without mill.

Paused overlays: title, rest, victory, defeat. Roster/Script/card editors pause the tree (`get_tree().paused = true`) while remaining `PROCESS_MODE_ALWAYS`.

### 7.3 Item execution

Items do not have unique classes. `_ops_of(item)` returns the `ops` dict (board/catalog), with a hardcoded `ITEM_OPS` fallback in `scripts/content/content_defs.gd` if JSON is empty.

`_apply_ops` (`scripts/core/fight_flow.gd`) is a `match` on `ops.kind`: `atk`, `blk`, `choose`, `defeat_hp`, `defeat_atk`, `mark_poison`, `heal_keep`, `skip_swing`, etc. Adding a new item is: unique sprite, board row + ops, catalog merge, interpreter arm if `kind` is new, Paper Fight if the rule is new.

### 7.4 Monster formulas

`_sync_wheel_stats` → `_apply_formulas_to` → `_try_eval_stat_formula`. Formula strings are data (`atk.formula` / `hp.formula` on catalog, mirrored from the board). Aliases include `last_mob_hp`, `player_hp_on_spin`, `num_items_at_combat_start`, `1 + mobs_defeated`, `monsters_still_in_play`, `own_hp`, etc. Unknown strings must not silently invent; warn and fall back to printed base.

Neighbor modifiers (Lich HP+1, Commander ATK+2, Wraith copy) are **late passes** after base/formula, order-sensitive. Do not hardcode combat stats per id if the roster already has a formula; Clockwork-style bugs happened when code ignored the roster.

### 7.5 Presentation modules

| Script | Responsibility |
|---|---|
| `boss_wheel.gd` | Wheel draw: slices, portraits, ATK/HP badges, hub HP/BLK, names |
| `item_card.gd` | Hand/hotbar card widget |
| `hover_panel.gd` | Inspect plate |
| `draft_gate.gd` | Mill offer UI |
| `combat_stage.gd` | Fight staging |
| `dungeon_art.gd` | PNG registry |
| `audio_fx.gd` | SFX / BGM |
| `tutorial_guide.gd` | Forced first-run |

### 7.6 Art rule (`unique-art.mdc`)

Every item and monster has its own sprite. No pixel duplicates. Pack title/filename must name the object (chain ≠ torch). Register in `ITEM_PNG` / `MONSTER_PNG`. Prefer CC0 16×16 nearest-neighbor; hand-draw if needed. Photoreal photos are rejected.

---

## 8. Agent implementation loop (Godot changes)

1. Ingest board + locks (section 5).
2. If gameplay: Paper Fight, wait.
3. Patch `scripts/main.gd` and the smallest related script. Prefer catalog-driven formulas over new id-hardcoded branches.
4. If new card: JSON rows + unique PNG + `dungeon_art.gd` + ops/formula + runtime id if it should mill.
5. Set shipped cards `status: live`.
6. Smoke: Godot headless `--quit-after 2` catches parse errors. He verifies in F5 Play.
7. Do not git commit unless asked. Do not rewrite locked copy.

Feel/layout: same-turn guess-and-build is expected. After a build: where it is, what the code does, what to notice in Play. One leftover question only if it would change the next tweak.

---

## 9. Reconstructing this without Cursor

Minimum viable control plane:

1. A filesystem watcher or explicit “ingest” step on `data/*.json`.
2. A chat or ticket where the human can attach screenshots and answer collision questions.
3. A stop-the-line for Paper Fight (no code until answers).
4. A write-protect check against `author-locks.json` before any copy edit.
5. Godot 4.7 to F5 and to headless syntax-check.
6. Policy files copied out of `.cursor/rules/` into whatever system prompt the new agent uses.

You do not need: Cursor Composer, MCP, Linear, Calendar, or a particular LLM. You do need: the JSON contracts, the GDScript interpreter, and the rule that **Save on disk outranks chat dictation**.

---

## 10. Known failure modes (do not reintroduce)

1. **Column drift in Roster** — Copies/Priority look like ATK/HP. Combat stats belong in `atk_base`/`hp_base`. Headers must share pixel widths with cells; do not persist placeholders.
2. **Hardcoded formulas ignoring catalog** — e.g. Clockwork ATK computed as “owners left” while roster said 4/7.
3. **Empty board `atk_base` not updating catalog** — merge only writes when board value is non-null; hydrate on load from catalog when board is null.
4. **Chat restyling locked ability text** — forbidden without a named override.
5. **Implementing a new rule in the same turn it was first heard** — Paper Fight first.
6. **Reusing sprites** — unique-art rule.
7. **Treating leftover HTML `todo` as a full-roster rebuild** — only this Save or a named request.
8. **Saving unsaved drifted Roster over a corrected JSON write** — he must Esc-discard, then reopen.

---

## 11. Quick path map for a cold agent

```
Human Saves in F5 Roster
  → data/content-board.json + author-locks.json + runtime.json
  → signal committed
  → catalog.json + RAM wheel/hotbar

Human talks in chat / screenshot
  → classify feel vs rule
  → rule: CURRENT.md + questions + wait
  → code: scripts/*.gd + assets
  → status live
  → Human F5 to verify

Human F5 is both the editor host and the player build.
Close after Save is the ingest trigger. Chat is not the SoT.
```
