# QA report — Barlow card / capsule / speech text

## Feature

- Name / id: UI/Text/UX lane — Barlow Semi Condensed on item titles, monster names, ability titles, detailed descriptions; wrap titles; Shift replaces standing card text; one-line shrinking capsules; readable Shift speech bubble
- Spec it was built from: Nathan's chat rulings 2026-10-12 + Must-keep UX in `design/visual/style-guide.md` §10 (updated this turn)

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Item types | Every catalog item's `card_color` matches display kind; Hook/Flask UTILITY | 42 items; `HOOK_KIND=UTILITY FLASK_KIND=UTILITY` | `tools/qa/check_item_types.gd` `ITEM_TYPE_OK` | Pass |
| Card size on Shift | 140×210 does not grow | `SHIFT_SIZE before=(140.0, 210.0) after=(140.0, 210.0)` | `check_item_types.gd` | Pass |
| Title never clips | `title_clip=false`, wrap on | Grappling Hook `title_wrap=3` `title_clip=false` | `SHIFT_TEXT` dump | Pass |
| Shift replaces standing text | Detail visible, number hidden, no extra box | `detail_visible=true` `num_visible=false` `formula_box_visible=false` `formula_box_h=0` | `SHIFT_TEXT` + `CARD_TEXT` for sai/helmet/shield/smoke_bomb/net/medallion | Pass |
| Named cards stay 210 | Sai, Helmet, Shield, Smoke Bomb, Net, Medallion | all six `off=(140,210) on=(140,210)` | `check_fixes_v2.gd` `CARDS_OK` | Pass |
| Speech font | Barlow or Nunito, not pixel | `SPEECH_FONT res://assets/ui/fonts/BarlowSemiCondensed-Regular.ttf` | `check_fixes_v2.gd` | Pass |
| Capsules one line | name and ability have no `\n`; may shrink | Golem 18; Hornet Swarm name 17 / Double Strike 18; no newlines | `CAPSULE` lines + `WHEEL_OK seats=5` | Pass |
| Wheel stacks | heart left, sword right, capsule under sprite, width ≤ 112 | 5 seated boxes; Hornet cap 110×50 | `check_fixes_v2.gd` `FIXES_V2_OK` | Pass |
| Hand still usable | spinning IGNORE → fight STOP; Shield Block | `USE_OK blk 0 -> 4`; `HAND_USE_OK` | `check_hand_use.gd` | Pass |
| Layers / boot | scripts load; title; Goblin no ATK dmg | 10 lane files OK; `BOOT_OK` HP 6; Goblin `no_atk_dmg` | `check_layers.gd` / `check_boot.gd` | Pass |
| Locked copy unchanged | no `data/` prose edits | no `data/` in this branch | git | Pass |
| No "Tier" on player screens | Weak / Tough / Deadly only | `THREAT t=1/2/3 name=Weak/Tough/Deadly` | `check_fixes_v2.gd` `GATE_OK` | Pass |
| In-editor stills | 1680×1040 Shift on/off | dummy renderer; no godot-mcp | none | Note |

## Bugs

None that failed a check. Godot `--quit-after 2` still prints the existing RID / ObjectDB leak warnings on shutdown. Those were already on `origin/main`.

## Balance notes

No combat math, ops, formulas, or catalog numbers changed. Shield still grants Block in `check_hand_use`. Goblin still `no_atk_dmg` in `check_boot`.

## Player-facing copy issues

None. Did not edit `data/player-copy.json` or author-locked board/catalog fields.

## What was fixed this loop

- Loop 1/3: Barlow fonts + wrap + Shift-replace + one-line capsules + speech font. Headless suite green. Silenced a `speech_bubble.tscn` missing-file log in the probe (script is instantiated directly).
- Still left: in-editor 1680×1040 shots need Godot Editor + godot-mcp or a display.

## Next agent: start here

1. In Play, look at a long item name (Grappling Hook, Counting Beads): the title should wrap, not ellipsis.
2. Hold Shift on Sai / Helmet: the `ATK` / `BLK` line should swap for the formula in that same slot. Card size stays 140×210.
3. On the wheel, Hornet Swarm and Clockwork Knight names stay one line (smaller type if needed). Shift speech should read in Barlow, not pixel.
