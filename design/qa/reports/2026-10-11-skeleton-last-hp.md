# QA — 2026-10-11 Skeleton last-faced HP after On Spin

## Feature

- Name / id: Skeleton (`skeleton`)
- Spec: board Flow + Paper Fight `design/paper-fight/done/2026-10-11-skeleton-last-hp.md`

## Result

PASS

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| First fight | HP 3 | Skeleton HP 3, last_mob_hp 3 | json + screenshot | Pass |
| Queen eggs then store | Store Queen HP after eggs | Queen HP 5, last_mob_hp 5 | json | Pass |
| Smoke still counts | Skeleton copies that owner | After Smoke, Skeleton HP 5 | json + screenshot | Pass |
| Ogre Empath | Store Ogre HP after Grief | Ogre HP 9, last_mob_hp 9 | json | Pass |
| Copy | Locked ability/explainer | Unchanged | board | Pass |
| No “Tier” | Player HUD | Weak/Tough/Deadly metals | screenshot | Pass |
| Goblin neighbor | Attack vs immune still | Goblin HP 1 untouched | first-fight screenshot | Pass |
| Errors | No new script errors | Stale `face_t` / WASAPI only | editor log | Pass |

## Bugs

None.

## Balance notes

Queen with one egg: 5 HP stored. Ogre after one Grief bleed: 9 HP stored. First Skeleton: 3.

## Player-facing copy issues

None for Skeleton. Queen explainer still says “double hit if a Neighbor is weaker” (locked, flagged in the 2026-10-11 Queen report).

## What was fixed this loop

- Loop 1: store `last_mob_hp` after On Spin effects, not at fight start. No second loop.

## Next agent: start here

1. `_store_last_faced_hp()` in `scripts/main.gd` runs at the end of `_on_spin` (and before on-spin slay returns).
2. Skeleton still reads `last_mob_hp` in `_try_eval_stat_formula` when you land on it.
3. Do not rewrite locked Skeleton copy.
