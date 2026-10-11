# QA checklists — Swipe

Use with `design/QA-PRINCIPLES.md`. Drive the game with godot-mcp (run, input/`godot_exec` clicks, screenshot, editor log) plus `tools/qa/qa_probe.gd`. Developer Test is the fast seat: title → Developer Test → click monster to seat, click item into hand → Play.

Evidence: screenshot under `design/qa/reports/evidence/`, or a probe dump / log line pasted in the report. No pass from reading code alone.

Player screens must not show the word **Tier**. Weak / Tough / Deadly only.

---

## New Item

### Setup

1. Run the game. Open **Developer Test**.
2. Seat a plain owner (Wizard or similar: no Goblin immune, no Dragon pierce) and add the new item to hand.
3. Play. Spin if needed so you face that owner.
4. Repeat extra seats listed under Edge cases.

### Verify

| Check | Expected | How to prove |
|---|---|---|
| Name + sprite | Own sprite, named object, not another card's pixels. | Screenshot of the card in hand. |
| Ability vs what happens | Matches board ability/Flow. Spend/keep matches ops. | Probe `hotbar` spent/keep; enemy HP / player HP / Block after use. |
| Targeting | Auto vs extra click (Throwing Knife style). Empty seat / last owner behaves as Flow. | Screenshot of the choose prompt, or probe if it auto-resolved. |
| Attack vs Bleed | If it deals Attack, monster HP drops (unless Goblin). If it Bleeds the player, Block does not stop it and bleed SFX plays. | Probe + log `atk` / `bleed`. |
| Block items | Player Block goes up by the printed amount. | Probe `blk`. |
| Defeat items | Combat ends without chipping HP to 0. Fail conditions still fail. | Probe: owner gone; or still there + `cannot` log. |
| Goblin | Attack damage does nothing. Defeat still works. | Seat Goblin, use the item. |
| Dragon | Only if the item is Block-related or you Resolve into Dragon: pierce still ignores Block. | Seat Dragon with Block. |
| Copy | Ability/explainer in game match locked board text. | Screenshot. Flag mismatches; do not rewrite. |
| Errors | No red errors. | `godot_editor_read` `get_log_messages` severity error. |

### Edge cases

- Player HP 1 and 0 (potion if they have it).
- Enemy HP 1; enemy HP higher than the item's Attack.
- Out of passes is mill-only; skip unless the item changes mill.
- Deadly pack: if the item can mill, confirm Deadly label, not "Tier 3".
- Hornet extra swings / Queen / empty alcove if Flow names them.

---

## New Monster

### Setup

1. Developer Test. Seat the new monster. Add Shield (Block 4) and Throwing Knife (Attack).
2. Play and face them.
3. Second fight: seat them with Dragon-level Block if their special cares about Block; or Goblin-style immune if relevant.

### Verify

| Check | Expected | How to prove |
|---|---|---|
| Sprite | Unique, named creature. | Screenshot. |
| Printed ATK/HP | Match catalog/board (formulas after spin/neighbors). | Probe wheel `atk`/`hp` after Spin. |
| Special | Flow happens. | Probe + screenshot of the tell. |
| Their Attack vs your Block | Block reduces Attack unless they pierce (Dragon). Unblocked hit plays connect SFX. | Probe `hp`/`blk`; log `take` / `ignores BLK`. |
| Attack vs Bleed | Their Attack is not Bleed. Bleed only if a card says bleed. | SFX/log. |
| Player Attack into them | HP drops unless they are Goblin-style immune or Anvil-style cap. | Probe. |
| Defeat paths | Da Boot / Sledge / Fangs still follow their own rules. | Extra seats if the special could block Defeat (`_defeat_blocked`). |
| Copy | Ability text locked; flag if HUD contradicts. | Screenshot. |
| "Tier" | Wheel/fight HUD show Weak/Tough/Deadly if rank is shown, never "Tier". | Screenshot. |
| Errors | No red errors. | Editor log. |

### Edge cases

- Last owner on the wheel.
- Neighbors: Lich HP+1, Commander ATK+2, Wraith copy, if they sit beside this monster.
- Player at 0 Block and at high Block.
- Tutorial skip: monster still works in Developer Test.

---

## Tutorial Step

### Setup

1. Run a **fresh** first-run (or the tutorial reset the game already uses). Do not start in Developer Test.
2. Walk only as far as the changed step.

### Verify

| Check | Expected | How to prove |
|---|---|---|
| The named click works | Talk box action is possible. No extra hidden click. | Screenshot of the step + probe `in_tutorial`, `tut.step`. |
| Game accepts it | Phase/hand/wheel change as the step describes. | Probe before/after. |
| Cue vs talk | HUD cue does not contradict Nib. | Screenshot. Flag copy; do not rewrite. |
| Cannot get stuck | A next action exists. Skip (if offered) still works. | Walk Skip once if this step can skip. |
| No "Tier" | | Screenshot. |
| Errors | None. | Editor log. |

### Edge cases

- Doing the wrong click first (should recover or ignore cleanly).
- Window focus lost mid-step (if you can reproduce).

---

## Core Gameplay change

Phase machine, Spin, Resolve, mill, Block math, extra swings, formulas, targeting.

### Setup

1. Headless parse smoke: Godot `--path <repo> --headless --quit-after 2` (does not replace in-game QA).
2. Developer Test seats that hit the change, plus one unchanged control fight (Shield vs Wizard).
3. If mill/draft changed: start Adventure/mill, not only Developer Test.

### Verify

| Check | Expected | How to prove |
|---|---|---|
| Control fight still works | Shield grants Block; Resolve spends Block against a non-Dragon. | Probe. |
| The changed rule | Matches the Paper Fight / board Flow. | Probe + screenshot. |
| Attack vs Bleed / Block / Dragon / Goblin / Defeat vs Slay | Unchanged unless the spec changed them. | The combat table in QA-PRINCIPLES. |
| Mill | Dungeon visible while drafting. Passes count down. Deadly/Tough/Weak, never "Tier". | Screenshot of mill with wheel behind. |
| Out of passes | Cannot Leave it. Must take the offer. | Probe `refusals_left` = 0 + screenshot. |
| Errors | None. | Editor log. |

### Edge cases

- 0 HP, 0 Block, last owner, empty alcove, Hornet double hit, extra item uses vs Harpy/Kobold if those systems moved.

---

## Copy / UI change

Wiring, fallbacks, layout, cues. Not rewriting locked strings.

### Setup

1. Run the screen that shows the string (title, mill, fight, tutorial, defeat, rest).
2. If it is a lookup change, confirm `PLAYER_COPY.text("key", fallback)` still hits the locked row.

### Verify

| Check | Expected | How to prove |
|---|---|---|
| Right screen | The string appears where it should. | Screenshot. |
| Locked text unchanged | Diff of `player-copy.json` / board locked fields is empty for prose. | Git diff. If you had to change a lookup key, say so. |
| No "Tier" on player screens | | Screenshot. |
| Unreadable | Contrast, overlap, cut-off. Fail if a number is hidden. | Screenshot. |
| Errors | None. | Editor log. |

### Edge cases

- Long locked strings (do not shorten them; flag overflow).
- Weak vs Deadly mill chrome.
