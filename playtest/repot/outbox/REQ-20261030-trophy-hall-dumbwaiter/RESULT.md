# RESULT — REQ-20261030-trophy-hall-dumbwaiter

- **tip_sha: fa19526e311b
- **pr:** [#208](https://github.com/Nathan-Elequin/swipe/pull/208)
- **branch:** `cursor/trophy-hall-dumbwaiter-b735`
- **base:** `playtest/latest`
- **selftests:** `biome_cabinets_selftest` → `BIOME_CABINETS_OK`; `campaign_shell_selftest` → `CAMPAIGN_SHELL_OK` (Godot 4.3 headless in cloud; target editor is 4.7)

## Per-pool item + page counts (catalog tip)

| pool | items (`_live_pool`) | pages (2×5) |
|------|----------------------|-------------|
| b1 Verdant Hollow | 12 (10 live + 2 todo) | 2 |
| b2 Crystal Cavern | 11 | 2 |
| b3 Ashen Crypt | 13 | 2 |
| b4 Cinder Forge | 14 | 2 |
| b5 Shadow Abyss | 10 | 1 |

## Rect nudges
None — used SCREEN §4 outer/glass/plaque/lamp rects as written. Crystal Cavern body at native (132,24); `CASE_GLASS[1]=[138,68,48,121]`; spires sheet/gild origin (126,22).

## Screenshots
Shots not captured in this cloud run (no godot-mcp / no display). Inbox REQ lists the required 01–12 set; capture on Cherry with F5 + DEV fills.

## Notes
- Strata column not built.
- Dumbwaiter on left wall; hall `Flame0` removed; `anchors.hall.flame=[]`.
- STUB copy keys only under `cabin.hall.*` (plaque / ordinals / lift / lore_claimed).
- Legacy `trophy_sunken_mire*` / `case_sunken_mire` kept on disk unused.
