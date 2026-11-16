---
id: REQ-20261116-homecoming-haul
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-16T17:05:00-06:00
machine: Cherry
tip_sha: ac22d09ea4917f5b3f8c818fa84c069934f1701d
godot: F5 playtest, Brand New, real mouse/Space, no DevChrome cheat bank
viewport_grab: 1550x960 window (logical layout 1680x1040)
on_screen_sha: ac22d09e*
---

# Result

Fresh Brand New. First Verdant run died (Take Berserker at 1 HP). Limp home → trophy hall (Verdant face) → Front Room. Music after return: `res://assets/audio/music_cabin.ogg`.

Homecoming model at hall land: `haul.kind=loss`, `haul.count=0`, `ordered_ids=[]`, `sack_vis=false`. Drafted items (Throwing Knife, Net, Breastplate, Boot, Fangs, Victory Flask, Arrowhead) did not enter the satchel.

## Dialogue keys observed

- `nib.board.first_look` — "Okay, let's see what you brought back from your first dungeon."
- `nib.board.first_empty` — "Empty-handed? That's all right. You'll get them next time…"
- Did **not** see `nib.home.loss.1/.2/.3` in the hall (those lines exist in player-copy; this return used first_look + first_empty).
- Did **not** see `nib.board.empty.1/.2` (0-new **win** path not reached).
- Did **not** see `nib.board.lever_ready.1/.2`.

| id | verdict | note |
|----|---------|------|
| 01 | fail | `01-empty-return.png` — no satchel, empty-handed Nib, but this was a **loss**, not a 0-new win. Keys: `nib.board.first_look` then `nib.board.first_empty`, not `nib.board.empty.*`. One gold pip was already lit on the five-light row before any item landed. |
| 02 | fail | Crystal 3+ unpack not reached. First return haul_count was 0. Extra: `loss-return.png` (same hall beat). |
| 03 | fail | Fifth Crystal light / lever READY not reached. |

## Extra (user asked)

- **Loss** — landed in trophy hall first (good). Nib was first_empty, not `nib.home.loss.*`. `SceneTree.paused` was **true** after the ceremony when Front Room idle (`front-room-after-loss.png`).
- **0-new win** — not reached.
- **3+ uniques / fifth light** — not reached; loss did not bank drafted uniques (`swiped_n=0`).

## Blockers

- One Brand New Verdant death in this session. Crystal/Ashen/Cinder fifth-lights need later wins. Did not Grant uniques or seed a save.
- After return, `tree.paused=true` (same class of stuck pause as REQ-20261114-real-playthrough-qa P07). Did not force-unpause.

## Shots

`playtest/repot/outbox/REQ-20261116-homecoming-haul/shots/`
