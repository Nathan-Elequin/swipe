# QA — 2026-10-11 Victory loot + Nib

## Feature

- Name / id: Direction A victory loot pile + smug Nib
- Spec: `design/visual/SCREEN-victory.md` (close the gap from `2026-10-11-victory.md`)

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Empty nest | no seats, no hub numbers, 50% wheel | nest_empty true; modulate.a 0.5; loot on hub | dump + `victory_qa_v1_right.png` | Pass |
| Loot pile 6× | this run's sprites 96×96 around hub | 4 item texes (this mill's hand) heaped on hub | dump `loot`: 4 | Pass |
| Nib smug 160×160 | frame 2 / `nib_smug.png` | 160×160 visible | dump `nib` | Pass |
| Copy | `title.win` / `title.win_sub` / `title.again` | Successfully Swiped / store this stuff / Again | dump | Pass |
| Wheel centre | (548,350) | 236,38 size 624 | dump | Pass |
| No TODO(copy) / no Tier on plates | | none on labels | tree scan | Pass |
| Side-by-side | | `design/visual/qa/victory_qa_v1.png` | capture | Pass |

## Bugs

None that fail the bar.

1. **Repro** — gold glow is drawn circles, not `assets/vfx/vfx_glow_gold.png` (file not in repo). Title pop + 16 gold particles not in the still.
2. **Likely file** — `wheel_hud.gd` `_draw_loot_glow`
3. **Suggested fix** — drop in the PNG when Pixel adds it
4. **Severity** — polish

## Balance notes

Visual only. Forced `phase = victory` from an Adventure mill with 4 hand items.

## Player-facing copy issues

None on the plate. F5 authoring log under Again can print "Tier 2 lure" — editor chrome, not a player label.

## What was fixed this loop

- Loop 1: loot layer 840×600, 96×96 drop, nest_empty, smug Nib, hide gate on win.
- Still left: `vfx_glow_gold.png`; title particle pop; authoring log.

## Next agent: start here

1. Defeat dashed hand (if this report is read alone).
