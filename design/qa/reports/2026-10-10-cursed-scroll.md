# QA — 2026-10-10 Cursed Scroll

## Feature

- Name / id: Cursed Scroll (`cursed_scroll`)
- Spec: board Save 2026-10-10; Paper Fight `design/paper-fight/done/2026-10-10-cursed-scroll.md`; Nathan: after every Spin, Bleed, can die

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Name + sprite | Own `cursed_scroll` PNG | Registered in `dungeon_art.gd` ITEM_PNG; in hand during probe | json hand list | Pass |
| Tax after Spin | Bleed 1, unused, after Spin | hp 6→5, `lost_hp_this_combat` true | json `cursed_spin` | Pass |
| Bleed vs Block | Block does not stop it | hp 5→4 with blk 4 | json `cursed_bleed_vs_block` | Pass |
| Heal on click | HP to 6, card used up | 4→6, not still in hand | json `cursed_heal` | Pass |
| Breastplate flag | Did Lose HP | `lost_hp_this_combat` true after tax | json `cursed_spin` | Pass |
| Crossbow neighbor | 4 ATK, no HP≥4 gate | marks `ogre:hp6` | json `crossbow_marks` | Pass |
| Copy | Locked ability unchanged | Paint only | json `cursed_scroll_body` | Pass |
| Can die at 1 HP | Potion can save | Not driven this loop (Roster was open) | — | Notes |
| Errors | None after parse fix | none | editor log | Pass |

## Bugs

None in the shipped tax/heal.

## Balance notes

One unused scroll Bleeds 1 per Spin. Grief Jar in the same hand would Bleed another 1 on the same Spin. Count is 1.

## Player-facing copy issues

- Locked Ability: “At the start of each combat, lose 1 HP…” Shipped rule is every Spin while unused. Flag only. Roster was open with an unsaved rewrite of that sentence.

## What was fixed this loop

- Loop 1: implemented `heal_full` + `_apply_cursed_scrolls`. Probes passed. Death-at-1 not retested because Roster had unsaved cells.

## Next agent: start here

1. Ops stay `{}` on the board (locked). Runtime kind is `ITEM_OPS.cursed_scroll` → `heal_full`.
2. Tax is `_apply_cursed_scrolls` next to Grief Jar siphon, after Spin lands.
3. Leave Roster unsaved cells alone; Nathan Save is the copy write.
