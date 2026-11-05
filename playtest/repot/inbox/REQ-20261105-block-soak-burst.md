---
id: REQ-20261105-block-soak-burst
status: open
priority: high
branch: playtest/latest
created: 2026-11-05T23:53:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → combat vs Hornet Swarm with 2 Block
---

# Block soak burst is cream spark, not red

Nathan picked candidate B (cream spark). Full Block soak (`incoming == 0`) still shows the raw hit number, flashes blue, shows the shield chip, and now plays `intent_claw_soak_f0-3.png` (cream/steel). Unblocked hits still use the existing red `intent_claw_burst_f0-3.png`. Shield chip PNG was not replaced.

## What to verify

- Hornet Swarm plate: two badges, each still **2**.
- Take with 2 Block: badge 1 stays **2**, flashes blue, cream/steel spark (not the red star burst).
- Badge 2 (unsoaked) still uses the red hit burst.
- Red burst files and `intent_chip_shield.png` look as they did before.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Seat Hornet Swarm, Spin, plate up before Take | two claw badges, each reads **2** | 01-hornet-plate.png |
| 02 | combat | Same fight, 2 Block, Take; shoot while badge 1 fires | badge 1 still **2**; cream/steel soak spark (not red star); shield chip ok | 02-soak-burst.png |
| 03 | combat | Same Take, badge 2 lands (or a fight with 0 Block) | red hit burst still plays on an unsoaked hit | 03-red-burst-still.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261105-block-soak-burst/`
