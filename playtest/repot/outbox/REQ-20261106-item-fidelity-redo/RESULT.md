---
id: REQ-20261106-item-fidelity-redo
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-06T17:30:00-06:00
machine: Cherry
tip_sha: cdc0cda7d0a6e49a4a86b38a233614502f2a682f
branch_shot: playtest/latest
godot: F5 playtest (godot-mcp, editor already open)
viewport: 1680x1040
requested_tip: ae30539e10bb93c2a7df80e5a9149b96c202c4cf
requested_branch: cursor/item-fidelity-redo-7b7d
---

# Result

Shots are the running game viewport saved at native 1680×1040. The request named `cursor/item-fidelity-redo-7b7d` at `ae30539e`. That branch was not checked out, so local gameplay and copy edits stayed put. The tested commit is `cdc0cda7d0a6e49a4a86b38a233614502f2a682f` on `playtest/latest`. These PNGs are in-game frames, not the approved contact sheet or archive exports.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Roster, items. Kiss of Death and Venom Veins on screen. Icons are `assets/dungeon/items/kiss_of_death.png` and `venom_veins.png`, 64×64, texture filter nearest, drawn in the art cell. |
| 02 | pass | Same roster. Love Potion (heart vial), Shardplate (plate), Tesla Coil (coil). Same live paths, nearest. |
| 03 | pass | Swift Sneaks only. Icon is `swift_sneaks.png`, nearest. It reads as a winged sneaker, not a grease jar. |
| 04 | pass | Fight open (Imp faced, Take showing). Hotbar holds all six. Each card icon is the matching live `assets/dungeon/items/<id>.png`, nearest, and the same paths as roster. |

## Runtime proof

In the running game, roster `TextureRect`s and hotbar item-card icons reported:

- resource path `res://assets/dungeon/items/<id>.png` for all six
- `texture_filter` nearest (enum 1)
- source size 64×64

Fight shot is a real combat layout (portrait, Take, six hotbar cards), not a fixture image.

## File checks (not a substitute for the shots)

- `py -3 tools/qa/check_item_fidelity.py` — exit 0. Live PNG SHA-256 matches approved `export64` for all six, and those bytes are an exact nearest 4× of `native16`. `ITEM_PNG` points at the live path.
- `git diff` against `cdc0cda7` is empty for `poison_flask.png`, `fairy_in_a_bottle.png`, Imp facing idle, Glass Asp facing idle, and Anvil wheel idle. Those files were not rewritten in the dirty worktree. Imp, Glass Asp, and Anvil are also visible on the wheel shots from the other request. Poison Flask and the fairy bottle were not given their own in-game shot; their “unchanged” check is the clean diff only.

## Blockers

None.

## Shots

- `shots/01-venom-kiss-roster.png`
- `shots/02-shard-love-tesla-roster.png`
- `shots/03-swift-sneaks-roster.png`
- `shots/04-hotbar-fight.png`
