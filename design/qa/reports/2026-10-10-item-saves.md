# QA — 2026-10-10 item Saves

## Feature

- Name / id: Sai (`sai`), Right Bracer (`bracers`), Left Bracer (`left_bracer`), Crossbow (`crossbow`)
- Spec: content-board Save 2026-10-10 (ability / notes / review_note)

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Sai starts 2 | Fresh Sai shows 2 | 2 | probe `sai: 2` | Pass |
| Sai flips on any item use | After Shield, Sai is 4 | blk 4, sai 4 | probe `sai_after_shield: 4` | Pass |
| Sai carries inside a dungeon | Next fight still 4 | 4 | probe `sai_next_fight: 4` | Pass |
| Sai resets between dungeons | After `_prep_next_dungeon`, 2 | 2 | probe `sai_next_dungeon: 2` | Pass |
| Right Bracer = CCW neighbor ATK | Facing Skeleton, Wizard ATK 5 | 5 | probe `right_blk: 5`; card shows 5 | Pass |
| Left Bracer = CW neighbor ATK | Ogre ATK 4 | 4 | probe `left_blk: 4`; inspect Block 4 | Pass |
| Last owner | Both bracers unusable | false/false | probe `solo_right/left: false` | Pass |
| Crossbow no HP cap | Ogre HP 6 is a legal neighbor | `ogre:6` in marks | probe `xbow: wizard:2, ogre:6` | Pass |
| Goblin | Not an Attack target | Goblin absent from marks | probe facing Goblin neighbors: wizard, ogre | Pass |
| Left Bracer unique art | Own pixels, leans left | MD5 differs from Right Bracer | `0cbc…` vs `cf3c…` | Pass |
| Copy / Tier | No “Tier” on player fight HUD | Weak/Tough/Deadly not an issue here | screenshot | Pass |
| Errors | No red errors | none | editor log empty | Pass |

## Bugs

None in the shipped rules.

## Balance notes

Right Bracer 5 Block vs Wizard 5 ATK is a full stop on that neighbor’s printed Attack. Crossbow now tags any living neighbor except Goblin.

## Player-facing copy issues

- `warn.crossbow` in player-copy still talks about “4 HP or less.” Code now uses `warn.neighbor` for the empty-target case. Flag only; locked copy not edited.
- Longbow ability Save dropped the even-count sentence; Flow still requires even count. Not shipped. Paper Fight in `design/paper-fight/CURRENT.md`.

## What was fixed this loop

- Loop 1: Sai persist, bracer sides, Crossbow HP cap, Left Bracer card+sprite. Probes passed. No retest needed.

## Next agent: start here

1. Longbow even-count question in CURRENT.md — do not guess.
2. Net “classify as special like Crossbow” is a note, not a targeting change (ability still says facing owner).
