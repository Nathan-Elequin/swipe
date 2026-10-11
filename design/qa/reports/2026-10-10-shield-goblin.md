# QA report — Shield vs Goblin

## Feature

- Name / id: Shield (`shield`) and Goblin (`goblin`)
- Spec it was built from: `design/qa/CHECKLISTS.md` New Item + New Monster demo after Cursor enabled godot-mcp. Catalog: Shield Gain 4 Block (`ops.kind` blk, n 4). Goblin "I cannot take Attack damage." Defeat still works.

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| MCP in this chat | `godot_*` tools | namespace `project-0-boss-rush-godot-mcp` ready | this session | Pass |
| Developer Test seat | Goblin on wheel, Shield + Knife in hand | Goblin ATK 3 HP 1; hotbar knife + shield; phase `devtest` then `ready` | `qa_probe` dump after `_open_dev_test` / `_dev_enter` | Pass |
| Shield grants Block | Block +4, item spent | `blk` 0 → 4 after `_use_item` Shield; knife still in hand | probe dump uid 1 | Pass |
| Knife ATK vs Goblin | Goblin HP unchanged; log `no ATK dmg` | HP stayed 1 after ATK 3 throw; log `Var no ATK dmg` and `ATK 3 → enemy HP 1` | probe dump after `_choose_option` throw; screenshot fight; in-game Log panel | Pass |
| Defeat still works | Da Boot (enemy HP < player HP) ends the fight | phase `slaying` then `victory`; wheel size 0; player HP still 6 | probe dump after Boot; `step_until` report phase `victory` | Pass |
| Sprites | Unique Goblin + Shield | Goblin portrait on wheel/stage; Shield round face on the spent card | screenshot_game during fight | Pass |
| No player-facing "Tier" | Weak/Tough/Deadly or nothing | Inspect "Goblin / Attack 3 HP 1 / No Attack"; no "Tier" | screenshot_game | Pass |
| Errors | None | "No error messages (cursor 0)." | `godot_editor_read` get_log_messages severity error | Pass |
| Frozen toss visuals | Cards leave the hand | While frozen, Knife and Shield still drew in the hotbar after spend | screenshot_game | Note (animation needs thawed time) |

## Bugs

None that fail the rules. Frozen Play holds toss/slay animation; numbers and phase were already correct.

## Balance notes

Goblin ATK 3 / HP 1. Shield 4 Block covers the 3 Attack if you Resolve. Knife ATK 3 does nothing. Boot always works here (HP 1 < player 6). One fight, Developer Test, not a mill run.

## Player-facing copy issues

Inspect special line is "No Attack" (call name). Locked ability is "I cannot take Attack damage." Not rewritten. Flag only if you want those to match word-for-word.

## What was fixed this loop

- Loop 1: no code changes. Verified live.
- Still left: name-chip centering (Hornet Swarm / Goblin "No Attack" ovals) is a separate layout pass.

## Next agent: start here

1. Keep Godot Editor open on this repo so `project-0-boss-rush-godot-mcp` stays connected.
2. After a gameplay or content change, run the matching checklist with `godot_exec` + `qa_probe.dump`; do not claim pass from reading GDScript.
3. Layout of wheel name/call capsules was not in this demo — fix in `scripts/boss_wheel.gd` `_draw_slice_title` if Nathan names it again.
