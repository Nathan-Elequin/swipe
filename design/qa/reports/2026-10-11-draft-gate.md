# QA — 2026-10-11 Draft gate v2

## Feature

- Name / id: Direction A draft gate (`draft_gate.tscn`)
- Spec: `design/visual/SCREEN-draft-gate.md`, `design/visual/specs/DRAFT-GATE-SPEC.md`

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Column plate, no dim | Gate in 1086×28 560×952; overlay off | col 1086,28 560×952; overlay.visible false | dump + `draft_gate_qa_v1.png` | Pass |
| Wheel locked | (548,350) | hub 236+312, 38+312 | dump `wheel` [236,38,624,624] | Pass |
| Take button | `door.take` gold | Take it, ButtonGold | screenshot | Pass |
| Leave + pass count | Leave text + 3 pips | Leave it (locked copy, no `{n}`); 2 torch pips / 1 hollow | screenshot + dump | Pass |
| Guard chip | Weak/Tough/Deadly, no "Tier" | Tough chip in `door.guard` | dump `guard_pill` | Pass |
| Silhouette + red eyes | Open arch, black owner | Open doors, silhouette + eyes | `draft_gate_qa_v1_right.png` | Pass |
| No TODO(copy) | | none | tree scan | Pass |
| Side-by-side | | `design/visual/qa/draft_gate_qa_v1.png` | capture | Pass |

## Bugs

None that fail the bar.

1. **Repro** — F5 authoring log (Var / On Click) still sits under Leave.
2. **Likely file** — `main.gd` tools_slot
3. **Suggested fix** — hide the live log on Adventure mill; leave it for Developer Test
4. **Severity** — polish

## Balance notes

Visual only. Mill lure was Tough / Knucklers on the captured ask.

## Player-facing copy issues

- `door.pass` is locked as "Leave it" with no `{n}`. Pips carry the remaining passes. Jam's `where` field still says `{n} = passes left`.
- `door.owner` / `door.shiny` still ALL CAPS. Spec says Jam is changing them to title case.

## What was fixed this loop

- Loop 1: open arch (`_doors = 0`), cue Pixelify 46, 300×230 actor, gold outline Leave.
- Loop 2: lighter arch fill so the black silhouette reads.
- Still left: `{n}` in Leave; ALL CAPS owner/bait labels; authoring log in the column.

## Next agent: start here

1. Victory loot pile + Nib (if this report is read alone).
2. Do not edit `data/` for `door.pass`.
