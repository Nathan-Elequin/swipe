# QA — 2026-10-10 hotbar unplayable look

## Feature

- Name / id: Hotbar greys and crosses currently unplayable items; Defeat cards show a skull instead of the word “Defeat”
- Spec: chat 2026-10-10 (Sledgehammer vs Golem ATK 3 still looked live). Copy/UI checklist.

## Result

PASS

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Unplayable grey + X | Fighting and `can_use` false greys the card and draws a diagonal cross | Golem ATK 3: Sledgehammer `deny` true, modulate `(0.62, 0.6, 0.56, 0.7)` | `evidence/2026-10-10-hotbar-unplayable.json` `golem.rows`; MCP `screenshot_game` of that fight | Pass |
| Playable stays live | Same card looks playable when the rule is met | Serpent ATK 5: Sledgehammer `can_use` true, `deny` false, white | same json `serpent.rows`; MCP screenshot vs Serpent | Pass |
| Skull, not “Defeat” | Hotbar number slot is a skull, not the word Defeat | `view_number` `""`, `mark` true on Boot and Sledgehammer | json `kind: DEFEAT` + screenshots | Pass |
| Control item | Shield still looks playable | Shield `can_use` true, number `4`, no X | json both fights | Pass |
| Click still blocked | Unplayable Sledgehammer does not spend; Golem stays | Log `On Item Use  cannot`; Golem HP 7; sledge `spent` false | json `after_click_sledge` | Pass |
| Locked text unchanged | No player-copy / board prose rewrite | Only `item_card.gd` / `_item_view` number / `_kind_mark` | git: no player-copy this pass | Pass |
| No “Tier” | Player fight HUD | Weak/Tough/Deadly not in this screenshot; no “Tier” | screenshot | Pass |
| Errors | No new parse/red errors | `face_t` errors are old (already fixed); this run launched | `godot_editor_read` errors | Pass |

## Bugs

None.

## Balance notes

Golem ATK 3 / HP 7 vs player HP 6. Serpent ATK 5 / HP 6. Sledgehammer playable only on Serpent. Boot unplayable on both (enemy HP not less than player HP).

## Player-facing copy issues

None. Inspect sheet still uses the word Defeat in the equation; only the hotbar number slot changed.

## What was fixed this loop

- Loop 1: `set_playable` / `set_petrified` were wiping the grey from `set_live`. Centralized `_sync_face()`. Empty Defeat number so the skull mark shows. Diagonal cross overlay when unplayable. First in-game pass matched the json and screenshots. No second loop.

## Next agent: start here

1. Unplayable look is `item_card.gd` `_sync_face` + `DenyPaint`. Do not let `set_playable(false)` set modulate to white.
2. Defeat / Fangs / last-match hotbar number is `""`; `_kind_mark("DEFEAT")` is `res://assets/icons/skull.svg`.
3. Grey/X only while `phase == "fighting"` and `not can_use` (mill stays full color).
