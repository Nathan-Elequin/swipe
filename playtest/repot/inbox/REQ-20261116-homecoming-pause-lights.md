---
id: REQ-20261116-homecoming-pause-lights
status: open
priority: high
tip_sha: pending
branch: cursor/homecoming-pause-lights-e27b
created: 2026-11-16T23:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → die in Verdant → Limp home → trophy hall first-look → key tour → Front Room idle
---

# Homecoming stuck pause + pre-lit pip

Fixes from Cherry QA on REQ-20261116-homecoming-haul (build ac22d09e): SceneTree stayed paused after first loss return, and lights must never light before an item lands.

## What to verify

- Fresh Brand New. Die in Verdant → Limp home.
- Land trophy hall first. First return may say `nib.board.first_look` then `nib.board.first_empty` (intended first-return beat; not a copy bug).
- Five-light row stays fully dark while empty-handed (no gold pip before any land).
- After ceremony + key tour (or skip to Front Room idle): `get_tree().paused == false`. Doors / map / board clicks work without forcing unpause.
- Optional win unpack: each arch light turns on only after that item’s satchel land/poof — never from banked/pending credit alone.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | first loss return, empty-handed first_look/first_empty | all five lights dark; no satchel | 01-loss-lights-dark.png |
| 02 | main | after ceremony, Front Room idle | Nib/map usable; note tree.paused=false in RESULT | 02-front-room-unpaused.png |

## Pass criteria

- Both shots at 1680×1040 (or note viewport).
- RESULT.md lists tip SHA, dialogue keys, paused=false after idle, lights dark on empty loss.
- No DevChrome force-unpause.

## Outbox path

`playtest/repot/outbox/REQ-20261116-homecoming-pause-lights/`
