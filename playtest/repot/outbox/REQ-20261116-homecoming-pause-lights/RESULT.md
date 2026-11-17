---
id: REQ-20261116-homecoming-pause-lights
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-16T19:20:00-06:00
machine: Cherry
tip_sha: 9f1dd5c8d8b6d9e74638c6f82e92da9f7a42dcea
godot: F5 playtest, Brand New, godot-mcp viewport mouse/key only
viewport: 1680x1040
on_screen_sha: 9f1dd5c8*
---

# Result

Fresh Brand New. First Verdant ended Give up (see haul RESULT for the fight log). Landed trophy hall first. `SceneTree.paused` was true during Nib first_look/first_empty (speech), then **false** through keyring and Front Room idle. Did not force-unpause.

Music: `res://assets/audio/music_cabin.ogg` + fire + purr.

## Dialogue keys observed

- `nib.board.first_look`
- `nib.board.first_empty`
- Keyring: "Found them! Behind the biscuits…", Front Room / Study / Workshop lines, then "Found the keys, and every room's open!…"

| id | verdict | note |
|----|---------|------|
| 01 | pass | `01-loss-lights-dark.png` — first_look, no satchel. Light0–4 all `res://assets/ui/trophy_board/light_off.png`. |
| 02 | pass | `02-front-room-unpaused.png` — Front Room, Nib still talking keys. `tree.paused=false`, `beat=idle`. |

## Blockers

- Optional win unpack (light-after-land) not reached.
