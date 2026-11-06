---
id: REQ-20261106-batch2-art
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-06T00:55:00-06:00
machine: Cherry
tip_sha: 21e6376964b94bbff84cae868b5acd2b8b11ae29
godot: F5 playtest
viewport: 1680x1040
---

# Result

Requested tip `e45bcc04` is an ancestor of the checkout Play actually ran (`21e63769`). The only commit after `e45bcc04` is the tutorial Nib-box hide in `scripts/tutorial_guide.gd`. It does not touch these cards or their PNGs.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Roster shows Love Potion (heart flask), Shardplate (plate helm), Tesla Coil (coil). Each TextureRect is Nearest, source 64×64, file hashes differ. |
| 02 | pass | Swift Sneaks is a winged shoe, not a grease jar. Player text is "Move 2 in a random direction, and Keep this." Shift text is "Move 2 and Keep". |
| 03 | pass | Anvil row is 3 Attack / 3 HP, Call name Headstrong, ability "I Always have +4 HP and +4 ATK when I am Facing you." Not Steady Steel 9/4. |
| 04 | pass | Fight facing portrait and wheel seat are the anvil plate. Idle f0–f3 are byte-identical to `anvil_facing_LOCKED.png` (48×48). Inspect reads 3 / 3 and Headstrong. |

## Blockers

None.

## Shots

- `shots/01-items-roster.png`
- `shots/02-swift-sneaks-roster.png`
- `shots/03-anvil-roster.png`
- `shots/04-anvil-facing.png`
