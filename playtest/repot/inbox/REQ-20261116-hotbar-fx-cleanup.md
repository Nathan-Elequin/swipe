---
id: REQ-20261116-hotbar-fx-cleanup
status: open
priority: normal
tip_sha: pending
branch: cursor/hotbar-fx-cleanup-f16c
created: 2026-11-16T21:56:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → skip intro / reach a fight with unclaimed uniques in the hotbar (include Revival Potion)
---

# Hotbar FX cleanup — sparkle / swirl / NewStar

Cloud ship: Rare fleck sparkles removed; armed auto-fire swirl is rim-only and quieter; NewStar clipped-parent fix so fresh unclaimed uniques show the star mid-fight.

## What to verify

- Tier-3 (Deadly) hotbar seats still get the diagonal rarity sweep, but no random `deadly_sparkle` flecks.
- Revival Potion (and active Danger Magnet) during a fight: subtle rotating rim glint only — no three orbiting dots; rarity sweep still readable (not heavy grey).
- Brand New / unclaimed unique in the hotbar: gold `new_star` 28×28 at top-right, both between fights and mid-fight.
- After that unique is claimed on the trophy board, the star is gone. Toll / Token-pool cards never get a star.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Brand New, mid-fight, Deadly item in hotbar | rarity sweep only — no fleck sparkles on the plate | 01-no-flecks.png |
| 02 | fight | Revival Potion armed mid-fight | quiet rim glint, no orbiting dots; plate not 60% grey | 02-armed-swirl.png |
| 03 | fight | Brand New unclaimed unique in hotbar | NewStar visible top-right mid-fight | 03-new-star-fight.png |
| 04 | ready | same unique after trophy claim (or Continue with that id banked) | NewStar gone on that seat | 04-star-cleared.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261116-hotbar-fx-cleanup/`
