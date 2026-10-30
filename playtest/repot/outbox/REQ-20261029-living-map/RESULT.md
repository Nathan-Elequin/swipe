---
id: REQ-20261029-living-map
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-29T13:10:00-05:00
machine: Cherry
tip_sha: 7ec9aeb6
godot: F5 playtest
---

# Result

Shots at 1680×1040 from F5 playtest on `playtest/latest`. `campaign_shell` seed/consume checks run in-process: 1/2/2/2/3 unique Deadlies, consume matches seeded telegraph (`failed: []`).

| id | verdict | note |
|----|---------|------|
| 01 | pass | Fresh + Fill Verdant Hollow. No Gulpwyrm/Bogmother ink. Verdant 1 sprite (spider), Sunken 2 (basilisk + prism). Unmapped biomes have no sprites. |
| 02 | pass | After ~3s, lane `position.x` changed (spider 1024→981 then back along the lane). Feet on parchment, Nearest. |
| 03 | fail | Hover lift is 14px and the gold DEADLY chip shows. Catalog name "Basilisk" is in the tag node but not readable on the parchment (plank blends). |
| 04 | pass | Fill every cabinet: 10 unique sprites, lanes filled 1/2/2/2/3, no overlaps, no Deadly repeats. No "Tier" on the plate. |
| 05 | pass | M in Verdant fight opens the same living map read-only (`ro: true`). M close returns to phase ready, HP 6, same wheel (Cultist/Bandit/Amalgam/Fairy/Hired Hand/Goblin). |
| 06 | pass | Delve opens straight into the fight hub. No "Deadly bosses are in this delve" screen exists. `_campaign_telegraph` is data-only (`["amalgam"]` for this run) and matches `next_run.deals`. |

## Blockers

None.

## Shots

All six PNGs under `shots/` at 1680×1040.
