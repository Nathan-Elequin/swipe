---
id: REQ-20261119-feel-pass-b
status: open
priority: high
branch: cursor/feel-pass-b-layout-233e
created: 2026-11-19T05:20:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New / Middle Progress → Adventure fight on the wheel
---

# Feel pass B — layout / UI

Nothing moves during a spin; combo tracker is a left gutter rail; monster inspect is a compact parchment plate; stuck hover clears when the mouse leaves.

## What to verify

- Take arc stays visible as dimmed disabled Safe through ready and spinning; no pop when landing if it was already up; becomes live Take when an enemy is up.
- Wheel size and position (and Take arc seat) do not jump when pressing Spin or when the fight starts.
- Move arrows keep the same radius through the spin.
- Cascade tracker is a vertical rail left of the wheel, above the hotbar z, not overlapping the combat log or wheel.
- Monster hover inspect is a short parchment card (296 wide) with portrait + name/rank/pips header, call pill + ability; no tall centered column and no flavor line.
- Clicking an item while hovering an enemy does not leave the inspect stuck after the cursor leaves.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | wheel ready | Adventure, ready to Spin, Take shows Safe | Take arc visible dimmed Safe; wheel/hotbar stable | 01-ready-safe.png |
| 02 | wheel spinning | Press Spin, capture mid-spin | Take still Safe; wheel rect unchanged vs 01; arrows still seated | 02-spinning-stable.png |
| 03 | wheel fighting | Land on a monster | Take live; wheel rect still matches 01; compact inspect on hover | 03-fight-compact-inspect.png |
| 04 | cascade rail | Trigger a multi-step cascade (slash chain) | Vertical token rail in left gutter; no overlap with wheel/hotbar/log | 04-cascade-rail.png |

## Pass criteria

- All rows at 1680×1040.
- Wheel + Take seat do not visibly jump between 01–03.
- Inspect plate is clearly shorter than the old tall column.
- No player-facing "Tier" or "ATK" on the new plate.

## Outbox path

`playtest/repot/outbox/REQ-20261119-feel-pass-b/`
