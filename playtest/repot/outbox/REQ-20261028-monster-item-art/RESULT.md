---
id: REQ-20261028-monster-item-art
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-10-28T23:55:00-05:00
machine: Cherry
tip_sha: 90602a0fc712d2f07edfc8e7275c059ba2be5c36
godot: F5 playtest
viewport: 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` @ `90602a0f` (PR #174 already merged). Entry: F5 playtest, skip intro, `qa_staging_fight` with Sandbag / Scorpion / Oligarch / Harpy. Slash shots used `ability_slash.play` at ~300 ms. Item shot: Orb, Flying Saucer, Spiked Shield, Chaos Stone (`mute_stone`) vs Sandbag with 0 Block so Orb is not Safe. All PNGs 1680×1040.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Four wheel seats show new full-body 24px art: tan Sandbag, Scorpion, Oligarch in green, Harpy with wings. Readable, not cropped stand-ins. |
| 02 | pass | Fight Sandbag is a tan bag with eyes, facing left/front. |
| 03 | pass | Fight Scorpion; pincers point LEFT toward the player. |
| 04 | pass | Oligarch slash mid-play: red-haired elf in royal green gown, faces LEFT, coin toss in the cut-in. |
| 05 | pass | Harpy faces LEFT in the fight portrait and in the cut-in. Cut-in is a winged portrait with a talon swipe, not a full-body idle copy. |
| 06 | pass | Hand shows new Orb, Flying Saucer, red Spiked Shield (attack face), and Chaos Stone. Art is sharp. Orb is grey (skull overlay) because incoming Take is not Safe. |

## Blockers

None.

## Shots

All six PNGs under `shots/` at 1680×1040 using the request filenames.
