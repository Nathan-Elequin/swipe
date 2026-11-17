---
id: REQ-20261116-commitment-tiers-slice3
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-16T19:20:00-06:00
machine: Cherry
tip_sha: 9f1dd5c8d8b6d9e74638c6f82e92da9f7a42dcea
godot: F5 playtest (headed), godot-mcp input only, no DevChrome shortcuts
---

# Result

This drain re-ran Brand New with commitment **Crystal Cavern** (tier 2), then a Verdant Give-up homecoming. Row 02 (deeper Crystal Cavern header) still needs a run that **entered Crystal** and then homecoming.

Prior Cherry Quick path (tip `bb1d1af9`) already replaced rows 01/03 with headed shots. Those files remain.

After this Give-up, `playtest_commitment.run_count` stayed 0 and `reached_quick` stayed false — offramp did **not** open. `playtest_offramp.visible=false`.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Existing headed `01-offramp-quick.png` from the Quick run (bb1d1af9). Not re-shot this drain. |
| 02 | fail | Crystal Cavern / deeper panel not reached. `02-offramp-deeper.png` is still the old Xvfb plate. This drain never entered biome index ≥ 1. |
| 03 | pass | Existing headed `03-offramp-thanks.png` from the Quick run. |

## Blockers

- Deeper offramp needs a finished Crystal Cavern run (win or lose) after the player has already picked the Crystal / deeper commitment. This drain died in Verdant Hollow.
