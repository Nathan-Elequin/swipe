# QA report — Nib talk ink thinned

## Feature

- Name / id: Nib / speech-bubble outline too thick
- Spec it was built from: chat — previous halo made the opening How to Play line unreadable

## Result

PASS

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Right screen | Opening Nib line is readable on cream | Hairline outline (1) + 1px shadow; letters no longer blob | Screenshot this turn; `outline` 1 from godot_exec | Pass |
| Locked text unchanged | Opening sentence untouched | Same locked How to Play body | godot_exec text dump | Pass |
| No "Tier" | | Not on this step | Screenshot | Pass |
| Unreadable | Body must be legible | Opening paragraph reads clean | Screenshot | Pass |
| Errors | None from this change | DAP debugger noise only | editor log | Pass |

## Bugs

None.

## Balance notes

n/a — tutorial chrome only.

## Player-facing copy issues

None this loop. Light keyword colors (HP / Heal) on cream may still be weaker than dark body ink; do not thicken the halo back up.

## What was fixed this loop

- Loop 1/3: `ink_on_paper` outline 4–5 → 1; shadow outline dropped; shadow is 1px down at low alpha.

## Next agent: start here

1. If keywords on cream still wash out, darken paper-side chip hexes — do not grow outline_size.
