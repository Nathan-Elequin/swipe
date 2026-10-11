# QA report — Editor-owned monster speech

## Feature

- Name / id: Editor-owned player text (`MONSTER_SPEECH` removed; empty Speech stays empty)
- Spec it was built from: chat — Wizard still said “My spellbook was in that pile” after the Speech field was cleared and Saved

## Result

PASS

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Wizard hover / inspect | No spellbook line; Speech field is blank | Inspect title “Wizard” + HP/ATK only; `_monster_rule` speech `""` | screenshot_game; `design/qa/reports/evidence/2026-10-10-editor-owned-speech.json` | Pass |
| Goblin still uses board Speech | “I cannot take Attack damage.” / call “Evasive” | Live ability and inspect speech match the board; call “Evasive” | probe dump in evidence json | Pass |
| Save is immediate | Stamp a line, then stamp empty, inspect follows | `TEST LINE FROM SAVE` then `""` on the same live Wizard | evidence json `save_stamp` | Pass |
| Locked text unchanged | Do not refill Wizard ability | Board/catalog Wizard `ability` still `""` | no writes to `data/content-board.json` / `player-copy.json` | Pass |
| No “Tier” on player screens | Weak/Tough/Deadly or nothing | Ready HUD: Spin, HP/ATK chips, no Tier | screenshot_game | Pass |
| Errors | None from this change | Only DAP `!scope_list.has(_current_frame)` | `get_log_messages` severity error | Pass |

## Bugs

None this loop.

## Balance notes

None. Copy wiring only.

## Player-facing copy issues

`data/player-copy.csv` still has a leftover `card.monster.wizard.ability` row with the old spellbook sentence. The fight HUD does not read that row. Left it alone (locked copy). Flag only.

## What was fixed this loop

- Loop 1: removed `MONSTER_SPEECH` and the “must start with I / My” overwrite. Empty Speech = no balloon and no inspect sentence. Call name / Shift line / item explainer no longer auto-fill from code dictionaries. Re-test: Wizard inspect blank; Goblin still speaks from the board.
- Still left: none for this request.

## Next agent: start here

1. If a monster has a blank Speech and Nathan wants a line, he types it in Edit card → Speech (or Roster Speech) and Saves. Do not put a fallback back in `main.gd`.
2. Do not rewrite locked Wizard `ability`.
3. Item inspect sentences now come only from Ability. Empty Ability = no paragraph (the math line still uses Callout explainer / ops).
