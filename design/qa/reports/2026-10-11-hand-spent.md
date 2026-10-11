# QA — 2026-10-11 hand.spent / no TODO(copy)

## Feature

- Name / id: Copy/UI — `hand.spent` = Used; no `TODO(copy)` on Direction A screens
- Spec: Copy / UI checklist in `design/qa/CHECKLISTS.md`; Jam added `hand.spent` in `player-copy.json`

## Result

PASS

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Right screen | Spent stamp on a hand card | first hotbar card `spent=true`, lab "Used" vis=true | exec dump | Pass |
| Locked text unchanged | no `data/` edits this chat | none | this chat did not write under `data/` | Pass |
| No "Tier" on player plates | Weak/Tough/Deadly only | Tough chip; no plate "Tier" | draft-gate / victory / defeat scans | Pass |
| No TODO(copy) | none on labels/buttons | todos [] on draft, victory, defeat trees | tree walk | Pass |
| Unreadable | Used stamp readable | dump + `design/visual/qa/hand_spent_qa_v1.png` | screenshot | Pass |
| Errors | none blocking play | old main.gd match parse from an earlier reload; live run captured | editor log | Pass |

## Bugs

None.

## Balance notes

Visual / copy wiring only. Forced `hotbar[0].spent = true` on the mill ask screen, then `_refresh()`.

## Player-facing copy issues

None. `hand.spent` text is "Used". `hand.tag.atk/blk/heal/ko` also exist now.

## What was fixed this loop

- Loop 1: confirmed `COPY.need("hand.spent")` → Used; no TODO on the three remaining Direction A screens.
- Still left: F5 authoring log can still print the word Tier (`On Draft Tier 2 lure`). That is editor chrome.

## Next agent: start here

1. Direction A visual pack is complete. Next work is Pixel specs or Jam copy (`door.pass` `{n}`, `door.owner` / `door.shiny` title case).
