---
id: REQ-20261114-package-d-board-gates
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-13T22:10:00-06:00
machine: Cherry
tip_sha: 80e7d6aa
godot: F5 playtest via godot-mcp, viewport 1680x1040
branch: playtest/latest
---

# Result

Shot on `playtest/latest` `80e7d6aa` (request named Package D `027132f2`). Extra `rumble_mid.png` was captured during the lever sequence (shake tween `last_shake_created=true`).

| id | verdict | note |
|----|---------|------|
| 01 | pass | Five lights lit; lever READY gold; padlock absent. `01-lever-ready.png`. |
| 02 | pass | Crystal portal splash (`Crystal Cavern` + cave art) with Nib “Did you feel that? Something just opened up in the Grumble.” `02-portal-splash.png`. |
| 03 | pass | After portal: Crystal revealed (Known stamp, `can_start(1)=false`); Ashen+ still fogged; Verdant START HERE (`can_start(0)=true`); `map_pieces` includes `b2`. `03-map-known-crystal.png`. |
| 04 | pass | Extract with 5/5 chip; Push blocked; Nib `nib.push_block.lever`: “Not yet. There's a lever at home with your name on it.” `04-push-block-lever.png`. |
| 05 | pass | After 100% + shortcut grant: dashed path, Crystal “Start here” badge, `can_start(1)=true`. `05-shortcut-crystal.png`. |

## Audio

Hall ambience `amb_trophy_room.ogg` played on the Ambience bus while the board was up. Lever sequence created a rumble shake. One-shot board cues (`board.lever_clunk`, `board.rumble`, light chimes) are short; they were not still `playing` on the later sample.

## Pass criteria

- 1680×1040.
- Lever / padlock / fog / splash are final art (not magenta).
- No Outpost door or cabinet cases in hall/map frames. Map still shows editor “Fill … cabinet” cheat labels (dev overlay, not playtest chrome).

## Blockers

First map capture landed on a leftover full-screen fade (`z_index` 200 ColorRect). Hidden for `03`/`05` so the held map was readable. Sequence itself does fade to black between beats.

## Shots

Required PNGs under `shots/`. Extra: `rumble_mid.png`.
