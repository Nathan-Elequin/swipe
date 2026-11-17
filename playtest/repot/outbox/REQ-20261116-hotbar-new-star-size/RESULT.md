---
id: REQ-20261116-hotbar-new-star-size
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-16T19:20:00-06:00
machine: Cherry
tip_sha: 9f1dd5c8d8b6d9e74638c6f82e92da9f7a42dcea
godot: F5 playtest, Brand New, godot-mcp viewport mouse/key only, no DevChrome / Grant / seeded save
viewport: 1680x1040
on_screen_sha: 9f1dd5c8*
---

# Result

Fresh `user://` wipe, F5, Skip intro, commitment **Crystal Cavern**, Brand New, Skip tutorial, Onward, cabin → map → `LaunchHit_start` Verdant. Build stamp `9f1dd5c8*`. Music in fight: `res://assets/audio/music_verdant_hollow_loop.ogg`. `SceneTree.paused` false during the ready fight.

Live NewStar nodes (six unclaimed hotbar uniques): size **28×28**, parent `NewStarHolder`, local pos `(146, -5)` on a 166×144 holder (~4 px top overhang). Texture `res://assets/ui/hud/new_star.png`.

| id | verdict | note |
|----|---------|------|
| 01 | pass | `01-new-star-corner.png` — ready fight, six Brand New uniques. Gold star is a small top-right mark; item art is readable. Not the old full-plate stretch. |
| 02 | fail | Never claimed a unique on the trophy board this session (first Verdant ended Give up / empty haul). No post-claim seat to shoot. |

## Dialogue keys observed (this REQ)

- `nib.first.1` `.2` `.3` `nib.first.map_point`
- Verdant enter splash (flavor, no portal key)
- `See that 'New!' mark?` (Nib teach, copy key not logged on the node)

## Blockers

- Claim-clear (row 02) needs a win unpack + board land.

## Shots

`playtest/repot/outbox/REQ-20261116-hotbar-new-star-size/shots/01-new-star-corner.png`
