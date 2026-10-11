# QA — 2026-10-10 Saves redesigns

## Feature

- Name / id: Damsel in Distress, Berserker 3/4/8, Commander flee, Ogre live HP, Spider Egg
- Spec: Paper Fight `design/paper-fight/done/2026-10-10-saves-redesigns.md` answers

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Damsel Done | Neighbors hit left then right as full Done; Block carries; they stay; Heal 3; Damsel leaves | Wizard 5 then Golem 3 after Shield 4; HP 6→5→2→5; wheel Wizard+Golem | `evidence/2026-10-10-saves-redesigns.json` damsel | Pass |
| Damsel die-first | (not run this loop; Shield kept HP above 0) | — | note | Notes |
| Berserker cycle | 3 then 4 then 8 on every Spin; fire at 8 | seated 3; after other-fight step 4; 8 fire true; then 3; then 4 | json berserker | Pass |
| Commander flee | First Done: they stay, shuffle, Spin | Log “Commander flees”; fled_once true; still on wheel; Spin | json commander | Pass |
| Ogre live HP | Matches player HP; gone at 0 | 4 then 6 after heal; stripped at 0 | json ogre | Pass |
| Spider Egg | Egg on other Spin; no egg on Queen Spin; discard +2/+2 | Egg in hand vs Wizard; Queen spin hand empty, Queen 5/5 | json queen_egg; MCP screenshot | Pass |
| Egg Attack | Number 2 on black card | Screenshot: Spider Egg 2 | MCP screenshot_game | Pass |
| Unique art | Damsel not the serpent sprite; Egg is an egg | damsel.png / spider_egg.png | files + screenshot | Pass |
| No “Tier” | Player fight HUD | Weak/Tough/Deadly metals only | screenshot | Pass |
| Locked copy | Not rewritten | Stale explainers flagged below | git | Pass |
| Errors | None new | Launch succeeded; old `face_t` log is stale | editor errors | Pass |

## Bugs

None that fail the answers.

## Balance notes

Damsel unblocked incoming was 8 (Wizard 5 + Golem 3) vs 6 HP — dies without Block, as answered. Two-owner wheel makes Commander buff both sides of the same neighbor (8+2+2=12). Existing wrap math, not new.

## Player-facing copy issues

Flag only. Do not rewrite locked fields.

- `two_headed_serpent` explainer still “two Items, no Attack.” Ability is the Damsel sentence.
- `berserker` explainer still “Attack and HP plus Defeat.”
- `commander` Flow still “Base ATK + 1” while Ability is +2 and flee.
- `spider_queen` Ability is empty. Explainer still “double hit if a Neighbor is weaker.”

## What was fixed this loop

- Loop 1: Implemented the five answers. Damsel, Berserker, Commander flee, Ogre, Egg all matched dumps. No second loop.

## Next agent: start here

1. Damsel is still id `two_headed_serpent`. Done runs `_damsel_resolve` (full `_owner_attack` per living neighbor, skip empty, Heal 3, then slay Damsel).
2. Queen eggs: `_apply_queen_eggs_on_spin`. Item `spider_egg` / `egg_hurt`. Hand cap `HAND_MAX` 50. Queen Ability is still blank on the board.
3. Commander first leave is `_try_commander_flee` (Done, Slay, neighbor kill). `fled_once` tints the wedge. Restore HP to at least 1 so they do not immediately slay again.
