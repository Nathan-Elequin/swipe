# QA — 2026-10-11 Queen one hit, Flail base 0, Crossbow, art

## Feature

- Name / id: Spider Queen, Spiked Flail, Crossbow, Bloody Wraps / Scythe / Bracer art
- Spec: board Flow (Queen one attack), notes (Flail base 0), review (Crossbow standard Attack), unique-art for Wraps/Scythe/Bracers

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Queen swings once | No ×2 even with weaker neighbor | `_hit_count` 1, incoming 3, Take 3 | json + screenshot | Pass |
| Queen eggs | Not on Queen Spin | No egg in hand vs Queen | json hand | Pass |
| Flail base 0 | 0 and unplayable before bleed | n 0 can_use false | json | Pass |
| Flail after bleed | +2 | n 2 after Grief Jar | json + screenshot | Pass |
| Crossbow vs Goblin | Can choose; Goblin takes 0 Attack | Marked; HP 1→1 | json | Pass |
| Wraps / Scythe / Bracer sprites | Named object, unique pixels | Wrap bundle, scythe, left/right cuffs | screenshot; hash dups none | Pass |
| No “Tier” | Player HUD | Weak/Tough/Deadly metals | screenshot | Pass |
| Copy | Locked explainers untouched | Queen explainer still “double hit” | board | Pass |
| Errors | No new script errors | Stale `face_t` only | editor log | Pass |

## Bugs

None that fail the Saves that shipped.

## Balance notes

Queen Take 3 with a Goblin neighbor. Flail 0 until the first HP loss.

## Player-facing copy issues

Flag only. Do not rewrite locked fields.

- `spider_queen` explainer still “double hit if a Neighbor is weaker.” Ability/Flow are one attack + eggs.
- Crossbow ops still contain locked `hp_max: 4`. Live code ignores it.

## What was fixed this loop

- Loop 1: Queen ×2 tell and extra swing removed. Flail is 2 × bleeds from 0. Crossbow can mark Goblin. New Wraps/Scythe/Bracer pixels. No second loop.

## Next agent: start here

1. Skeleton HP copy is Paper Fight only — `design/paper-fight/CURRENT.md`.
2. Queen `_hit_count` is 1. Eggs still `_apply_queen_eggs_on_spin`.
3. Flail `_item_view` `atk_hp_loss` is `2 * hp_loss_events`.
