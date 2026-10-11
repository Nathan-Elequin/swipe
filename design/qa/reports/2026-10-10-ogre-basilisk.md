# QA — 2026-10-10 Ogre listen + Basilisk Gain/Keep

## Feature

- Name / id: Ogre (`ogre`), Basilisk (`basilisk`), Smoke Bomb order, Spider Egg gain
- Spec: Paper Fight `design/paper-fight/done/2026-10-10-ogre-basilisk.md` answers

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Ogre printed HP | 10, not player HP | Seated 10 while player 6 | json seated_hp | Pass |
| Listen on bleed | Ogre loses equal HP | Grief Jar bleed 1: player 6→5, Ogre 10→9 | json after_grief | Pass |
| Heal does not grow Ogre | Stay at 9 | Lantern heal player 5→6, Ogre 9 | json after_lantern | Pass |
| Listen on Done hit | Equal loss | Golem 3: player 6→3, Ogre 9→6 | json after_golem_done | Pass |
| Quiet Bell | Keep HP, stop listening | Silenced, ability blank, extra bleed Ogre stays 5 | json quiet_then_bleed | Pass |
| Delay slay other fight | Stay on wheel at 0 until that fight ends | During Golem slaying: Ogre hp 0 pending true; after: gone, victory | json pending_slay | Pass |
| Basilisk Queen egg | Appear then discard | Size 2 mid-spin, then hand `[smoke_bomb]` | json queen_egg | Pass |
| Smoke before Spin | Leave fight, item stays | phase ready, facing -1, hand `[shield]` | json smoke_before_spin | Pass |
| Attack vs Bleed | Grief Jar is bleed | Player HP dropped at BLK 0 | earlier Grief Jar log | Pass |
| No “Tier” | Player HUD | Weak/Tough/Deadly only | prior screenshots | Pass |
| Copy | Locked fields unchanged | Stale explainers flagged | board | Pass |
| Errors | No new script errors | Stale `face_t` only | editor log | Pass |

## Bugs

None that fail the answers.

## Balance notes

Ogre 10 HP vs player 6 means it outlasts one unblocked Golem swing. Two Ogres were not double-seated this loop; listen is per unsilenced slice.

## Player-facing copy issues

Flag only. Do not rewrite locked fields.

- `ogre` explainer still “HP is yours.” Ability is “When you lose HP, I lose equal HP.”
- `basilisk` Flow still describes Keep-only. Ability is Gain or Keep.
- Quiet Bell Flow still says “owner id.” Live rule is the facing enemy only.

## What was fixed this loop

- Loop 1: Ogre listens, delay-slay, Quiet keeps HP. Basilisk rejects Queen eggs with a banner. Smoke leaves, then gives the item, then Spins. Matched dumps. No second loop.

## Next agent: start here

1. `_hurt_ogres` / `_slay_pending_ogres` / `_slay_ogre_at`. Facing Ogre at 0 during fighting still goes through `_begin_slay` (Combat start / Crossbow path).
2. `_try_gain_item` + `_gain_blocked_now` (same as Basilisk Keep). Smoke clears facing before `_draw_unseen_item`.
3. Ogre board status is `live`. Explainer/Flow flags above are locked — do not rewrite.
