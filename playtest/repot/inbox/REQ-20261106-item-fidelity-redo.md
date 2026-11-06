---
id: REQ-20261106-item-fidelity-redo
status: open
priority: normal
branch: cursor/item-fidelity-redo-7b7d
created: 2026-11-06T16:40:00-06:00
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Roster (and a fight/hotbar with these six items via dev deck or seeded pool)
---

# Item fidelity redo — revision 2 (approved redos installed)

Nathan approved all six revision2 REDO icons. Live `assets/dungeon/items/<id>.png` now hold the approved `_64` nearest-4× exports (native 16 stored as 64). Cloud agent could not run Godot; local Cursor drains this request with real in-game shots + `RESULT.md`. Do **not** attach the contact sheet or approved archive PNGs as “in-game” evidence.

## What to verify

- Roster / inspect shows Venom Veins, Kiss of Death, Shardplate, Swift Sneaks, Love Potion, Tesla Coil with chunky pixel art (established item grid), sharp Nearest edges, no blur / smoothing.
- Swift Sneaks reads as winged sneakers (not a grease jar); catalog id remains `swift_sneaks`.
- Hotbar and fight item cards for these six use the same art (no leftover detailed64 silhouette).
- Poison Flask, Imp, Glass Asp, Anvil, and parked fairy bottle art are unchanged.
- Viewport 1680×1040.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | roster | Open Roster; find Venom Veins + Kiss of Death | Chunky pixel icons; readable names; Nearest | 01-venom-kiss-roster.png |
| 02 | roster | Find Shardplate + Love Potion + Tesla Coil | Chunky plate / heart vial / coil; Nearest | 02-shard-love-tesla-roster.png |
| 03 | roster | Find Swift Sneaks | Winged sneaker pixel art (not grease jar) | 03-swift-sneaks-roster.png |
| 04 | fight | Seed hotbar with at least three of the six; open fight | Hotbar icons match roster redos; no blur | 04-hotbar-fight.png |

## Pass criteria

- All four shots at 1680×1040 from the running game (F5 / godot-mcp), not fixtures.
- Each `expect` readable without guessing.
- Wrong art, blurry filter, grease-jar Swift Sneaks, or contact-sheet stand-in = fail that id.

## Outbox path

`playtest/repot/outbox/REQ-20261106-item-fidelity-redo/`
