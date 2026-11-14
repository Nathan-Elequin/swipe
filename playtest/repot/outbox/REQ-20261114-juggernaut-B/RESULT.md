---
id: REQ-20261114-juggernaut-B
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T00:30:00-06:00
machine: Cherry
tip_sha: a40c1bb1
godot: F5 playtest via godot-mcp, viewport 1680x1040
branch: playtest/latest
---

# Result

Seated Juggernaut in memory (`_tut_seat_monster`) but the Game dock was still showing the held map when idle/spin were saved.

| id | verdict | note |
|----|---------|------|
| 01 | fail | `01-juggernaut-wheel-spin.png` is Grandpa's map, not a wheel seat. |
| 02 | fail | `02-juggernaut-wheel-idle.png` is the same map. |
| 03 | fail | `03-juggernaut-facing-idle.png` captured before slash; not a 64 facing idle. |
| 04 | pass | Slash cut-in over the map: blond hair, human face, blue heater with a white cross. Not grey plate. Skin tan. `04-juggernaut-slash.png`. |
| 05 | fail | `05-juggernaut-extra-still.png` is the slash cut-in, not `assets/dungeon/extra/juggernaut.png` full-body still. |

## Pass criteria

- Face/hair/blue heater readable on 04 only.
- Wheel/facing/extra not captured on the intended surfaces.

## Blockers

Need overlay+wheel visible (cabin/map hidden) before seating. Slash `ability_slash.play` did run.

## Shots

All PNGs under `shots/`.
