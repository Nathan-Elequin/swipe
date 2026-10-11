# QA — 2026-10-11 How to Play

## Feature

- Name / id: Direction A talk box (`talk_box.tscn`)
- Spec: `design/visual/SCREEN-how-to-play.md`

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Talk in column, not over wheel | column 1086, wheel (548,350) | talk at x 1112; wheel hub 548,350; gold ring around wheel | `talk_box_qa_v1.png` / `_right.png` | Pass |
| Nib sprite, not Goblin | `nib_talk.png` | Nib, green name | dump `face_tex` + screenshot | Pass |
| Skip + go every beat | `tutorial.skip` / beat go | Skip + I'm in (`tutorial.beat.01.go`) | screenshot | Pass |
| Spotlight | dashed gold around wheel | present | screenshot | Pass |
| No "Tier" | | none | screenshot | Pass |
| No TODO(copy) | | none | tree scan | Pass |
| Side-by-side | | `design/visual/qa/talk_box_qa_v1.png` | capture | Pass |

## Bugs

None that fail the bar.

1. **Repro** — first paint hid HUD (tutorial early-return in `_sync_overlay`) and the hand; fixed same loop.
2. **Likely file** — `main.gd` `_sync_overlay`
3. **Suggested fix** — already: show HUD + hand when tutorial is open
4. **Severity** — polish leftover: editor Log / On Click lines still sit under Skip in the column; go label is "I'm in" (copy) not mockup "Show me"

## Balance notes

Visual only.

## Player-facing copy issues

- `tutorial.beat.01.go` is "I'm in"; mockup says "Show me". Flag only.
- Progress ticks capped at 12 (parsed script has more pages).

## What was fixed this loop

- Loop 1: column talk box + Nib + spotlight; HUD was hidden.
- Loop 2: HUD + hand shown; ticks capped so the plate fits.
- Still left: authoring chrome in the column; no `ui_talkbox.png` / `ui_spotlight_ring.png` (drawn).

## Next agent: start here

1. Draft-gate v2.
2. Victory loot pile + Nib; defeat dashed hand.
3. Confirm `hand.spent` = Used with no TODO(copy).
