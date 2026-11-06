---
id: REQ-20261106-monster4-combat
status: open
branch: cursor/monster4-tip-combat-ec1e
base: playtest/latest
created: 2026-11-06
---

# Monster4 combat wire (huntsman, quicksand_crab, phantom, collector)

Cloud agent wired combat on tip. Local F5 verify — no Godot in cloud.

## Entry

F5 playtest hub → Roster / seeded fight so Huntsman, Quicksand Crab, Phantom, Collector appear.

## Screenshots required

| id | surface | setup | pass | filename |
|----|---------|-------|------|----------|
| 01 | fight | Face Across from Huntsman; Take shows Across + Straight Shot | Take-X includes Huntsman ATK | 01-huntsman-take.png |
| 02 | fight | Move beside Quicksand Crab (Swift Sneaks Move2) | Crab loses 4 HP after resolve | 02-crab-move-tax.png |
| 03 | fight | Spin Quicksand Crab in Adventure | +1 Move charge pip | 03-crab-spin-charge.png |
| 04 | fight | Use an item facing Phantom | 2 hotbar cards haze/shroud at end | 04-phantom-shroud.png |
| 05 | fight | Defeat a non-Collector while Collector lives | Bag of {name} in hotbar at pre-lethal HP | 05-collector-bag.png |

## Outbox

`playtest/repot/outbox/REQ-20261106-monster4-combat/`

## Gaps (honest)

- Huntsman radiating-line VFX not in tip — Take-X / intent peers only.
- Move charge peer = adventure `moves_left` bank (not Tesla Coil item Charge).
