# QA — 2026-10-10 Quiet Bell facing-only, Grief Jar HP tell, Bracer arrows

## Feature

- Name / id: Quiet Bell (`quiet_bell`), Grief Jar hotbar, Left/Right Bracer sprites
- Spec: chat — Quiet Bell silences only the facing enemy; Grief Jar hotbar shows Block plus HP-loss coloring/icon; bracer arrows point with the named hand

## Result

PASS

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Quiet Bell targeting | Only the facing enemy loses its unique ability | Facing Goblin `silenced: true`, ability blank; other Goblin `silenced: false`, ability still “I cannot take Attack damage.” | `evidence/2026-10-10-quiet-bell-grief-bracers.json` | Pass |
| Attack into silenced Goblin | Attack damage now lands | Throwing Knife 3: HP 1 → 0, slay | json throw_3_into_silenced_goblin | Pass |
| Other Goblin still immune | Attack does nothing | `_deal_atk(3)` HP 1 → 1, `hit_killed: false` | json throw_3_into_remaining_unsilenced_goblin | Pass |
| Quiet Bell vs Golem | Unplayable (no unique ability) | Crossed out on Golem fight | MCP screenshot_game | Pass |
| Grief Jar hotbar | Block number plus HP-loss heart/color | Heart icon + number 2 after Spin; log bleed 1 and BLK 2 | screenshot after tween; json grief_jar | Pass |
| Bracer arrows | Left points left on the left; Right points right on the right | Sprites match after swap | MCP screenshot on ready and fight | Pass |
| Attack vs Bleed | Grief Jar Spin is bleed (Block does not stop it) | Log `bleed 1 → 5` with BLK 0 | screenshot log | Pass |
| Goblin always-check | Unsilenced Goblin ignores Attack | HP unchanged on remaining Goblin | json | Pass |
| No “Tier” | Player fight HUD | Weak/Tough/Deadly metals only | screenshot | Pass |
| Copy | Locked Quiet Bell Ability unchanged | Ability still “Remove your Enemy's unique ability” | board | Pass |
| Errors | No new script errors | Game ran. Stale `face_t` parse errors are old timestamps | `godot_editor_read` get_log_messages error | Pass |

## Bugs

None that fail the bar.

## Balance notes

Two Goblins: silencing one does not tax the other. Grief Jar still bleeds 1 on Spin (player 6 → 5) and stores Block 2.

## Player-facing copy issues

Flag only. Do not rewrite locked fields.

- Quiet Bell Flow still says “That owner id loses its unique ability.” Live rule is the facing enemy only, matching Ability (“your Enemy”).

## What was fixed this loop

- Loop 1: Silence is a flag on that wheel slice. Bracer PNGs swapped. Grief Jar shows an HP heart next to its Block number. All three matched the running game. No second loop.

## Next agent: start here

1. `_is_silenced(s: Dictionary)` reads `s["silenced"]`. Quiet Bell sets that on `wheel[facing_index]` only.
2. Grief Jar `_item_view` `loss_icon`; `item_card.set_loss_icon`.
3. Ogre listen-for-loss and Basilisk Gain+Keep are Paper Fight only — see `design/paper-fight/CURRENT.md`. Do not implement until Nathan answers.
