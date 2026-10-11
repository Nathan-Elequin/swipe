# QA principles — Swipe

How Cursor should test this game. Nathan does not paste a trigger sentence. The project rule `.cursor/rules/qa-verify.mdc` is always on (`alwaysApply: true`). After a gameplay or content change, the agent runs the matching checklist, writes a report, fixes failures, and loops up to 3 times.

Testing tool: satelliteoflove **godot-mcp** (addon `addons/godot_mcp`, MCP server `@satelliteoflove/godot-mcp`). Testing and verifying only. Never write or edit code or scenes through it.

## What "broken" vs "acceptable" means

**Broken (FAIL the report):** wrong combat numbers; wrong spend/keep; a rule from the board/Flow does not happen; a crash or red error; player-facing "Tier"; Attack treated as Bleed or the reverse; Block stopping Bleed; Dragon blocked or playing Block SFX; Goblin taking Attack damage; Da Boot / Sledgehammer / Fangs failing their Defeat path or being treated as "deal damage until 0 HP"; mill hiding the dungeon; a tutorial step that cannot be finished; unreadable HP/ATK/Block/cue.

**Acceptable (PASS WITH NOTES):** small animation timing; a pixel-nudge of layout that still shows the numbers; art that matches the named object but is not Nathan's favorite; balance that is not an always-win or always-lose.

Until Nathan answers the interview, treat the line above as the bar. Visual polish is a note, not a fail, unless a number or cue is missing or unreadable.

## Logic vs visuals

1. Logic (numbers, spend, targeting, phase) is the fail bar.
2. Visuals fail only when the player cannot read the state, the wrong sprite is on the card, or a cue contradicts the numbers.
3. One screenshot of the happy path plus one per failed visual check. Do not screenshot every checkbox.

## Combat rules that always get a check

These are live in `scripts/core/fight_flow.gd` (still methods on Main). Re-verify them when the change can touch them. See `design/LANES.md`.

| Rule | Expected | Proof |
|---|---|---|
| Attack vs Bleed | Attack hits monster HP (or is blocked / ignored). Bleed is `_bleed`: purple flash, bleed SFX, player HP down, Block does not stop it. | State dump + SFX/log. Screenshot if the tell is the question. |
| Block | Stops incoming Attack. Remaining Block drops. Unblocked Attack damages player HP and plays connect SFX (`chop`), not Block SFX. | `hp`, `blk` before/after + log `take`. |
| Dragon | Attack ignores Block. Player HP drops by Dragon ATK even with Block. No Block SFX (`_play_attack_blocked`). Log: `ignores BLK`. | Fight Dragon with Block > 0. |
| Goblin | Cannot receive Attack damage. HP unchanged. Defeat items still work. Log: `no ATK dmg`. | Attack Goblin, then (if in scope) a Defeat item. |
| Da Boot | Defeat if enemy HP < player HP. Combat ends. Not "deal HP damage." Fail if enemy HP ≥ player HP. | Developer Test: Boot vs a weaker owner, then vs a stronger one. |
| Sledgehammer | Defeat if enemy ATK ≥ 5. Combat ends. Fail if ATK < 5. | Same pattern. |
| Fangs | Take their hit (Block still works on that hit), Defeat, then Heal equal to the HP they had (cap 6). If that hit would kill you: Healing Potion, then Fangs heal. Not Slay-by-chipping HP. | State: enemy gone, player HP = min(6, hp_after_hit + stored). |
| Slay | Owner leaves because HP hit 0 (or the fight ended). Defeat paths jump to `_begin_slay` without requiring HP = 0 from Attack. | Do not merge these in the report. |

## Draft mill

- Player-facing rank is **Weak / Tough / Deadly** (`player_copy.gd` `tier_name`). Never the word **Tier** on mill, wheel, fight HUD, tutorial talk, or cues.
- Authoring editors (Roster, card sheet, Developer Test subtitles) may still say Tier. That is not a player-screen fail.
- The dungeon / wheel stays visible while drafting.
- Passes: the Leave-it / out-of-passes control matches remaining passes (`door.pass`, `door.pass_one`, `door.pass_none`). Out of passes means they cannot skip the offer.

## Tutorial

A step is clear if the player can do the named action without a hidden extra click, and the talk box matches what the game will accept. If they can get stuck with no next action, that is a FAIL.

## Copy

Never rewrite `data/player-copy.json` text or author-locked board/catalog strings. Flag the key, the current line, and why it is wrong. Nathan Saves the rewrite in the Script editor or Roster.

## Balance

No hard win-rate target until Nathan sets one. Flag **always dies** / **never dies** / **unusable as written** with the numbers you saw (HP, ATK, Block, items in hand). If you simulate, say how many fights and what you seated. Default: the Developer Test cases in the checklist, not a 100-run Monte Carlo.

## Performance and errors

- Red errors, parse errors, and crashes: FAIL. Zero tolerance.
- Warnings: note them. Fail only if they fire every frame or block play.
- Frame drops: WARN unless the game is unplayable.

## When to stop vs ask Nathan

After 3 QA loops (implement or fix → test → report), stop and ask. Do not invent a fourth reading of the rule. Paper Fight still wins for a new or ambiguous gameplay rule before the first implement.

## What the report is for

A future Cursor agent, not a player-facing recap. The last section is always **Next agent: start here** — three bullets that work with no other chat.

## Decision log

| Date | Choice |
|---|---|
| 2026-10-10 | Install satelliteoflove godot-mcp for testing only. Never edit code/scenes through it. |
| 2026-10-10 | `qa-verify.mdc` `alwaysApply: true`. Nathan does not say a trigger sentence. QA runs after gameplay or content changes. |
| 2026-10-10 | Never rewrite player-copy or author-locked text; flag only. |
| 2026-10-10 | Never show "Tier" on player screens; use Weak / Tough / Deadly. |
| 2026-10-10 | Always-check combat list: Attack vs Bleed, Block, Dragon, Goblin, Da Boot, Sledgehammer, Fangs vs Slay. |
| 2026-10-10 | Up to 3 test-fix loops, then ask Nathan. |
| 2026-10-10 | Report format locked in `design/qa/REPORT-TEMPLATE.md`. |
| 2026-10-10 | Defaults until interview overrides: logic is the fail bar; visual polish is notes unless unreadable; no win-rate %; screenshots = happy path + each fail; errors/crashes fail, frame drops warn. |
