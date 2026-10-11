# Visual refresh — message board

Newest entry at the top. Cursor reads this at the start of every chat and does OPEN items addressed to Cursor.

---

## 2026-10-11 — Split main.gd into lane files
- From: Cursor
- To: Jam / Pixel / Nathan
- Status: DONE
- What: Pure refactor. `scripts/main.gd` is now boot/frame/input only. Logic moved along the three lanes (UI / Core / Content) via a stacked `extends` chain so `hp`, `phase`, and `_use_item` still live on Main. `ITEM_OPS` and `MONSTER_SPECIAL` moved to `scripts/content/content_defs.gd` with the same values. No gameplay, visual, copy, or balance changes. Map: `design/LANES.md`. Rule pointer: `.cursor/rules/lanes.mdc`.
- Files: `scripts/main.gd`, `scripts/lanes/game_state.gd`, `scripts/content/content_defs.gd`, `scripts/content/catalog_io.gd`, `scripts/core/fight_flow.gd`, `scripts/core/draft_flow.gd`, `scripts/core/run_flow.gd`, `scripts/core/tutorial_flow.gd`, `scripts/ui/hud_controller.gd`, `scripts/ui/authoring_ui.gd`, `design/LANES.md`, `.cursor/rules/lanes.mdc`

## 2026-10-11 — Direction A polish
- From: Cursor
- To: Jam / Pixel / Nathan
- Status: DONE
- What: Player screens hide the F5 log, Log button, and copy stamp; they return only in Developer Test. Defeat pointer matches the dim wheel (`#5A5048` @ 22%). `door.guard` on the bait card fills `{tier}` from `tier.N.name` (Weak this mill). Wired Pixel art: `vfx_glow_gold.png` at (128,90), victory title pop + 16 gold particles, `ui_talkbox.png` 9-slice (96/22/12/12, content 44/28), `ui_spotlight_ring.png` at (215,17) + seat ring, oak 9-slice in `themes/swipe_theme.tres` / column / pause. Wheel stayed at (548,350). No `data/` edits.
- Files: `scripts/main.gd`, `scripts/wheel_hud.gd`, `scripts/talk_box.gd`, `scripts/tutorial_guide.gd`, `scripts/end_plate.gd`, `scripts/draft_gate.gd`, `scripts/ux_style.gd`, `scripts/owner_plate.gd`, `scripts/inspect_plate.gd`, `scripts/settings_menu.gd`, `themes/swipe_theme.tres`
- QA: `design/visual/qa/talk_box_qa_v2.png` · `draft_gate_qa_v2.png` · `victory_qa_v2.png` · `defeat_qa_v2.png` · `pause_menu_qa_v2.png` · `design/qa/reports/2026-10-11-visual-polish.md`

## 2026-10-11 — Jam completion pass (Direction A)
- From: Jam
- To: Nathan / Pixel / Cursor
- Status: OPEN (copy asks + polish)
- What: Build watch confirmed Direction A complete (all screens + QA). Unlocked `door.guard` → owner wording in `data/player-copy.json`. Author-locked rows untouched — waiting on Nathan. Pixel: missing `vfx_glow_gold`, `ui_talkbox`, `ui_spotlight_ring`, nine-slice panels. Cursor: hide F5 authoring log on Adventure; dim defeat pointer; wire `door.guard`; victory particles when glow PNG lands.
- Files: `data/player-copy.json`, `design/visual/specs/COPY-FLAGS.md`
- QA: existing Direction A set under `design/visual/qa/`

---
## 2026-10-11 — Direction A complete
- From: Cursor
- To: Jam / Pixel / Nathan
- Status: DONE
- What: How to Play, draft-gate v2, victory loot+Nib, defeat dashed hand, and `hand.spent` = Used. No `data/` edits. Wheel stayed at (548,350). No player-facing `TODO(copy)` or the word Tier on plates.
- Spec items still unmatched:
  - `door.pass` locked as "Leave it" (no `{n}`); pips show remaining passes
  - `door.owner` / `door.shiny` still ALL CAPS (Jam changing to title case)
  - No `assets/vfx/vfx_glow_gold.png` — victory glow is drawn circles
  - Victory title pop + 16 gold particles not in the still
  - How to Play: no `ui_talkbox.png` / `ui_spotlight_ring.png`; ticks capped at 12; go copy is "I'm in"
  - F5 authoring log / copy stamp still sit in the column (Var, On Click, "Tier 2 lure" in the log)
  - Nine-slice panel PNGs still missing (StyleBoxFlat oak instead)
  - Defeat pointer stays bright gold on the dim wheel
- Files: see the four entries below
- QA: `design/visual/qa/talk_box_qa_v1.png` · `draft_gate_qa_v1.png` · `victory_qa_v1.png` · `defeat_qa_v1.png` · `hand_spent_qa_v1.png`

## 2026-10-11 — hand.spent
- From: Cursor
- To: Jam
- Status: DONE
- What: `hand.spent` is "Used". Tree scan on draft / victory / defeat showed no `TODO(copy)`. No `data/` edits.
- Files: `scripts/item_card.gd` (already wired)
- QA: `design/visual/qa/hand_spent_qa_v1.png` · `design/qa/reports/2026-10-11-hand-spent.md`

## 2026-10-11 — Defeat dashed hand
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: Empty dashed 140×190 hand slots, three empty hearts in the column, gold outline Again. Wheel `#5A5048` at 22%. No `data/` edits.
- Files: `scripts/wheel_hud.gd`, `scripts/end_plate.gd`, `scripts/main.gd`
- QA: `design/visual/qa/defeat_qa_v1.png` · `design/qa/reports/2026-10-11-defeat-hand.md`

## 2026-10-11 — Victory loot + Nib
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: Empty nest, this run's loot at 96×96 on the hub, smug Nib 160×160 in the gold column. Gate hides on win. No `data/` edits.
- Files: `scripts/wheel_hud.gd`, `scripts/end_plate.gd`, `scripts/boss_wheel.gd`, `scripts/main.gd`
- QA: `design/visual/qa/victory_qa_v1.png` · `design/qa/reports/2026-10-11-victory-loot.md`

## 2026-10-11 — Draft gate v2
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: Column `draft_gate.tscn`. No dim over the dungeon. Real Take. Leave outline + pass pips. Open arch silhouette with red eyes. Wheel (548,350). No `data/` edits.
- Files: `scenes/ui/draft_gate.tscn`, `scripts/draft_gate.gd`, `scripts/main.gd`
- QA: `design/visual/qa/draft_gate_qa_v1.png` · `design/qa/reports/2026-10-11-draft-gate.md`

## 2026-10-11 — How to Play
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: Column talk box (`talk_box.tscn`). Nib sprites, not Goblin. Skip + beat go. Dashed gold ring around the wheel. HUD stays visible. No `data/` edits.
- Files: `scenes/ui/talk_box.tscn`, `scripts/talk_box.gd`, `scripts/tutorial_guide.gd`, `scripts/main.gd`, `scripts/wheel_hud.gd`
- QA: `design/visual/qa/talk_box_qa_v1.png` · `design/qa/reports/2026-10-11-how-to-play.md`

## 2026-10-11 — Defeat
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: Column defeat plate (`title.lose` / `title.lose_sub` / `title.again` outline). Wheel at 22% `#5A5048`. Not the title card. No `data/` edits.
- Files: `scenes/ui/defeat.tscn`, `scripts/end_plate.gd`, `scripts/main.gd`
- QA: `design/visual/qa/defeat_qa_v1.png` · `design/qa/reports/2026-10-11-defeat.md`

## 2026-10-11 — Victory
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: Column victory plate (`title.win` / `title.win_sub` / gold Again). Wheel 50% alpha. No `data/` edits.
- Files: `scenes/ui/victory.tscn`, `scripts/end_plate.gd`, `scripts/main.gd`
- QA: `design/visual/qa/victory_qa_v1.png` · `design/qa/reports/2026-10-11-victory.md`

## 2026-10-11 — Title
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: `title_screen.tscn` replaces the old full-wash overlay. Ghost wheel, Pixelify logo, gold Play (`title.begin` = Play), oak secondaries, Nib. No `data/` edits.
- Files: `scenes/ui/title_screen.tscn`, `scripts/title_screen.gd`, `scripts/main.gd`
- QA: `design/visual/qa/title_screen_qa_v1.png` · `design/qa/reports/2026-10-11-title.md`

## 2026-10-11 — Pause
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: Soot 72% dim, oak modal, slider labels from `pause.master/music/sound`, gold Resume. Opens only after inspect closes. No `data/` edits.
- Files: `scenes/ui/pause_menu.tscn`, `scripts/settings_menu.gd`, `scripts/main.gd`
- QA: `design/visual/qa/pause_menu_qa_v1.png` · `design/qa/reports/2026-10-11-pause.md`

## 2026-10-11 — Inspect
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: Column inspect plate. One plate at a time (hides fight/placement). Value + tag match the card. Weak/Tough/Deadly. No `data/` edits.
- Files: `scenes/ui/inspect_plate.tscn`, `scripts/inspect_plate.gd`, `scripts/main.gd`
- QA: `design/visual/qa/inspect_plate_qa_v1.png` · `design/qa/reports/2026-10-11-inspect.md`

## 2026-10-11 — Fight
- From: Cursor
- To: Jam / Pixel
- Status: DONE
- What: Column owner plate + ButtonDanger resolve at the bottom. Hid combat_stage/face_box. No red wash. `cue.fighting`. Hand stays. Wheel (548,350). No `data/` edits.
- Files: `scenes/ui/fight.tscn`, `scripts/fight_plate.gd`, `scripts/main.gd`, `scripts/combat_stage.gd`, `scripts/boss_wheel.gd`, `scripts/wheel_hud.gd`
- QA: `design/visual/qa/fight_qa_v1.png` · `design/qa/reports/2026-10-11-fight.md`

## 2026-10-11 — Placement
- From: Cursor
- To: Jam, Pixel
- Status: DONE
- What: Column door + owner plate + `door.seat_hint`. Empty alcoves use `valid` + gold +. Floating gate hidden in seat mode. Torch line on empty-seat hover. Occupied seat shakes. No `data/` edits.

### Files
- `scenes/ui/owner_plate.tscn`, `scripts/owner_plate.gd`
- `scenes/ui/placement.tscn`, `scripts/placement_plate.gd`
- `scripts/wheel_hud.gd`, `scripts/boss_wheel.gd`, `scripts/main.gd`

### QA
- `design/visual/qa/placement_qa_v1.png`
- `design/qa/reports/2026-10-11-placement.md`

## 2026-10-11 — Wheel HUD v2 (alcoves + tags)
- From: Cursor
- To: Jam, Pixel
- Status: DONE
- What: Wired `assets/ui/wheel/ui_wheel_alcove_*.png` (seat 0 at top, pivot 116,300). Spin Pixelify 40, hub Pixelify 44. Hid trophy plaque and Kenney wall ground (soot). Hand tags from `hand.tag.atk/blk/heal/ko` — no TODO. No `data/` edits.

### Files
- `scripts/boss_wheel.gd`, `scripts/wheel_hud.gd`, `scripts/dungeon_bg.gd`, `scripts/main.gd`

### QA
- `design/visual/qa/wheel_hud_qa_v2.png`
- `design/qa/reports/2026-10-11-wheel-hud-v2.md`

### Unmatched
- Healing Potion still `?` with no HEAL tag (live kind PASSIVE / empty ops)
- `hand.spent` still missing

## 2026-10-11 — Wheel HUD
- From: Cursor
- To: Jam, Pixel
- Status: DONE (stop here — next chat resumes at **placement**)
- What: Direction A wheel chrome. `scenes/ui/wheel_hud.tscn` holds hearts, pointer, Spin, hand, column. Name chips off the ring. Hub is HP/BLK text. Wheel locked at (548, 350). No `data/` edits. Two tweak rounds (column clip, hub line).

### Files
- `scenes/ui/wheel_hud.tscn`, `scripts/wheel_hud.gd`
- `scripts/main.gd` — instantiates HUD; cue uses `cue.ready`; Spin stays visible while spinning
- `scripts/boss_wheel.gd` — alcove tiles, no names, hub vitals, Quart spin + streaks + seat shake

### QA
- `design/visual/qa/wheel_hud_qa_v1.png` (mockup left / build right)
- `design/qa/reports/2026-10-11-wheel-hud.md`

### Unmatched
- Alcove PNGs not in repo
- Spin streaks / landing shake not in the still
- Hand TODO tags from Part 1

## 2026-10-11 — Part 1 sprites + theme + hand-card
- From: Cursor
- To: Jam, Pixel
- Status: DONE (stop here — next chat resumes at **wheel**)
- What: Direction A sprites wired. Theme + fonts + nearest/snap on. Hand cards use `scenes/ui/hand_card.tscn`. Nib talk frames replace the Goblin face. No `data/` edits. Wheel chrome not restyled yet.

### Files
- `scripts/dungeon_art.gd` — `assets/sprites/` first; atlas / old PNG only as fallback
- `scripts/tutorial_guide.gd`, `scripts/combat_stage.gd`, `scripts/draft_gate.gd` — 4× board / 8× bait, Nib 128px
- `scripts/item_card.gd`, `scripts/main.gd`, `scenes/ui/hand_card.tscn`
- `scripts/player_copy.gd` — `need()` → `TODO(copy):<key>`
- `themes/swipe_theme.tres`, `assets/ui/fonts/` (Pixelify, Silkscreen, VT323, antialiasing off)
- `project.godot` — soot clear, nearest filter, snap 2D
- `tools/qa/qa_capture.gd` — side-by-side helper

### QA images (1680×1040; pair is mockup left / build right)
- `design/visual/qa/sprites_qa_v1.png`
- `design/visual/qa/sprites_nib_qa_v1.png`
- `design/visual/qa/sprites_nib_qa_pair.png`
- `design/visual/qa/hand_card_qa_v1.png`

### Missing sprites (fallback to old extras / atlas)
- `item:left_bracer`
- `item:caltrops`
- `item:cursed_scroll`
- `item:spider_egg`
- Damsel extra PNG unused: `two_headed_serpent` has `mon_two_headed_serpent_idle.png`

### TODO(copy) keys (Jam — do not have Cursor edit `data/`)
- `hand.tag.atk`
- `hand.tag.blk`
- `hand.tag.heal` (wired; this mill did not draw a Heal card)
- `hand.tag.ko`
- `hand.spent`

### Unmatched spec items
- Nine-slice PNGs `assets/ui/panels/ui_card_{weak,tough,deadly}.png` and `ui_panel_oak.png` are not in the repo — StyleBoxFlat oak + 6px metal borders instead
- Pixelify file is the variable font, not a static 700 cut
- New-card pop-in (x+60, 0.18s) and post-fight shrink/fade not wired
- 8-card row is 124px / gap 10, but the hotbar is still the old full-width box (not locked to x 32–1062 / hand x 547)
- Grief Jar still shows a heart mark next to 0 (spec: one value, no icon-as-stat)
- The Boot KO slot is empty until `hand.tag.ko` exists — the TODO string does not fit at 46px
- Wheel / Spin / inspect plate still the old look (next screens)
- Mockup left on `hand_card_qa_v1.png` is `wheel-ready_v1.png` (no separate hand-card mockup)

## 2026-10-11 — Superseded draft-gate prompt
- From: Jam
- To: Cursor
- Status: DONE
- What: Superseded: design/visual/specs/CURSOR-PROMPT-DRAFT-GATE.md (old draft-gate-only prompt). Build from design/visual/CURSOR-PROMPTS-A.md instead. Part 1 + hand-card used that file. Resume at **wheel**.

## 2026-10-11 — Art refresh: Direction A screen pack (Grok Bot, for Annie/Jam)
- Decision: Direction A "Torchlit Burrow" + Layout 1 "Side Door" (Annie). Wheel locked at centre (548,350), hand centred on x 547 (approved). Nathan's next review: final mockup.
- Added under design/visual/ (new files only):
  - style-guide.md (tokens and theme for themes/swipe_theme.tres)
  - SCREEN-{title,how-to-play,wheel,placement,fight,victory,defeat,pause,inspect,hand-card,draft-gate}.md, each with its own Cursor prompt
  - CURSOR-PROMPTS-A.md, README-A-screens.md, SPRITE-SOURCING.md
  - 13 mockups in mockups/ (*_v1.png; draft-gate_v2.png)
- Jam's answers applied:
  - New copy keys pause.master/music/sound ("Master"/"Music"/"Sound") and door.seat_hint ("Pick an empty spot."). Jam is also retexting the existing door.owner/door.shiny to "The owner"/"The bait". All are read via PLAYER_COPY, never hard-coded.
  - DOOR OPEN dropped.
  - {tier} filled from tier.N.name.
  - KO plum #A866C9 kept.
  - 8-card hands use 124 px cards; the hand cap is a game rule and isn't changed.
- SCREEN-draft-gate.md (v2) supersedes the positions and paths in specs/CURSOR-PROMPT-DRAFT-GATE.md (ui_palette.gd, assets/fonts/ → themes/swipe_theme.tres, assets/ui/fonts/).
- Sprites: SPRITE-SOURCING.md maps all 35 items and 29 monsters. 54 have Kenney CC0 bases with palette-A recolour notes; 10 plus Nib's final sheet are on the from-scratch list for Nathan (Aseprite or PixelLab). Damsel is on hold.
- Design files only: no game code, no data/ changes. The full refresh overrides CREATIVE-UX-PACK.md where they conflict.
- Doop: https://doop.design/c/Evbwm-9bMX (row "A · 00–12"). Affine: https://affine.elequin.io/workspace/b01380e1-f37a-4f4b-aada-298a05557360/TgahVDQ6Gp

## 2026-10-11 — Screens captured
- From: Cursor
- To: Jam, Pixel
- Status: DONE
- What: Handoff folders exist. 15 current screenshots at 1680×1040. INDEX written. Project rule `visual-handoff.mdc` is on (alwaysApply). No restyle this turn.
- Files:
  - `design/visual/screenshots/current/01-title.png`
  - `design/visual/screenshots/current/02-tutorial-first.png`
  - `design/visual/screenshots/current/03-tutorial-mid.png`
  - `design/visual/screenshots/current/04-draft-ask.png`
  - `design/visual/screenshots/current/05-draft-reveal.png`
  - `design/visual/screenshots/current/06-draft-placement.png`
  - `design/visual/screenshots/current/07-wheel-ready.png`
  - `design/visual/screenshots/current/08-wheel-spinning.png`
  - `design/visual/screenshots/current/09-fight-hit.png`
  - `design/visual/screenshots/current/10-fight-blocked.png`
  - `design/visual/screenshots/current/11-fight-slain.png`
  - `design/visual/screenshots/current/12-victory.png`
  - `design/visual/screenshots/current/13-defeat.png`
  - `design/visual/screenshots/current/14-pause.png`
  - `design/visual/screenshots/current/15-inspect.png`
  - `design/visual/screenshots/current/INDEX.md`
  - `design/visual/brief/` (empty, for Jam)
  - `design/visual/mockups/` (empty, for Pixel)
  - `design/visual/specs/` (empty, for SCREEN-*.md)
  - `design/visual/qa/` (empty, for mockup-vs-game)
  - `.cursor/rules/visual-handoff.mdc`

### Noticed (ugly / broken — do not treat as a redesign brief yet)

1. **Title is a lot of empty brown.** Faint wheel behind the overlay. Play looks like the quiet sibling next to How to Play / Quick Start / Adventure Mode.
2. **Editor chrome is in the player shot.** Log button, colored On Click / Var lines, Developer Test / Roster / Script, and the `copy: swipe-player-copy-…` stamp. Hide these before any player-facing mockup.
3. **Log can say `Tier 2 lure`.** That string is the authoring log, not the wheel HUD — still must never reach a player screen. Wheel chips in these shots use Weak/Tough/Deadly language (e.g. Anvil “Tough Blood”), not the word Tier.
4. **Draft gate fights the Log.** Take/Leave panel sits under the Log button. Ask mode has no separate Take button — you click the relic. Empty square above the card in ask mode.
5. **Name chips collide.** Ready wheel: two Lich chips stack; Hornet Swarm / Wraith / Golem labels sit on top of portraits and ATK pips.
6. **Pause dim is weak.** Settings sits as a left card; the wheel stays fully readable. Inspect can stay up on the right at the same time.
7. **How to Play talk box covers the wheel** on the first page. Nib’s face is the Goblin sprite. Mid-step gold frame around the wheel is clear.
8. **Fight hit** is a red wash over a collapsed one-owner ring (Wizard lightning into the hub). **BLOCKED** / **SLAIN** banners read. Hand disappears on BLOCKED. Victory/defeat overlays are the same title card with **Again**.
9. **Hand numbers look uneven.** Right Bracer shows an em dash, Smoke Bomb an X, several ATK 0s, Grief Jar a heart 0 in other shots.

### Open for Jam / Pixel (not Cursor yet)

- Jam: briefs go in `design/visual/brief/`. Do not rewrite `data/player-copy.json` from chat.
- Pixel: mockups in `design/visual/mockups/`, then a `design/visual/specs/SCREEN-<name>.md` before Cursor builds.

---

## How to log

```
## YYYY-MM-DD — short title
- From: Cursor | Jam | Pixel | Nathan
- To: …
- Status: OPEN | DONE | BLOCKED
- What:
- Files:
```
