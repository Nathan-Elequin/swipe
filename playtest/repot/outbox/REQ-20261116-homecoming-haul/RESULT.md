---
id: REQ-20261116-homecoming-haul
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-16T19:20:00-06:00
machine: Cherry
tip_sha: 9f1dd5c8d8b6d9e74638c6f82e92da9f7a42dcea
godot: F5 playtest, Brand New, godot-mcp viewport mouse/key only, no cheat bank
viewport: 1680x1040
on_screen_sha: 9f1dd5c8*
---

# Result

Loss #1 (logged): Verdant Dungeon 1, 6-monster wheel (Golem / Ogre / Goblin / Berserker / Eel / Vampire). Used Breastplate (blk 2), Throwing Knife ATK 3, Sai (Golem 7→2). Fangs first try stuck in `phase=slaying` until Undo. Neighbor-pick for Poison Flask did not land. Escape → Give up → confirm. Cabin music `music_cabin.ogg`. Haul empty; drafted uniques did not bank.

## Dialogue keys observed

- `nib.board.first_look` — "Okay, let's see what you brought back from your first dungeon."
- `nib.board.first_empty` — "Empty-handed? That's all right…"
- Did **not** see `nib.home.loss.*` or `nib.board.empty.*` (0-new **win** not reached).
- Did **not** see `nib.board.lever_ready.*`.

| id | verdict | note |
|----|---------|------|
| 01 | fail | `01-empty-return.png` — no satchel, empty-handed Nib, but this was a **loss/Give up**, not a 0-new win. Keys: first_look then first_empty. All five pips `light_off.png` (no gold pip before a land). |
| 02 | fail | Crystal 3+ unpack not reached. Extra: `loss-return.png`. |
| 03 | fail | Fifth Crystal light / lever READY not reached. |

## Extra

- After keyring, Front Room `beat=idle`, `SceneTree.paused=false` (`front-room-after-loss.png`).
- Give-up from an in-fight neighbor prompt did **not** stamp `playtest_commitment.run_count` / `reached_quick` (still 0 / false, tier 2). Offramp did not open.

## Blockers

- Did not win Verdant this session; Crystal/Ashen/Cinder fifth-lights not reachable. Did not Grant uniques.
