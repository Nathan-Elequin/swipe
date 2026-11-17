---
id: REQ-20261117-callout-matches-wheel
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-17T00:20:00-06:00
machine: Cherry
tip_sha: f1b0fdb89ba12c2727a2cbb744fd45ecd18d39de
requested_tip_sha: 2343f3e6
godot: F5 playtest, godot-mcp Viewport.push_input + injected keys only
viewport: game window set 1680x1040; captured frame 1024x632
---

# Result

Same session as REQ-20261117-juggernaut-A. Input: godot-mcp injection only. Fresh save, Middle Progress, Verdant (then Continue). No `_dev_*` / Grant / forced poses.

## Log

- Tip SHA: `f1b0fdb8` (session began on `2343f3e6`).
- Music (fight): `res://assets/audio/music_verdant_hollow_loop.ogg`.
- `SceneTree.paused`: false while facing Golem in fighting; true on hub/intro/pause/limp-home.
- Golem callout (when faced): `combat_stage.card_id=golem`, `_mode` idle then run, `_idle` = `golem_facing_idle_f0.png`–`f3`, sprite `golem_facing_idle_f0.png`.
- Wheel seats that fight: Golem on the bottom slice, same brown full-body as the right callout (see 1024×632 capture).

| id | verdict | note |
|----|---------|------|
| 01 | fail | Juggernaut never seated (same mill seed as the sibling REQ; b1–b5 deals omit him). No `01-juggernaut-wheel-and-callout.png`. |
| 02 | fail | Ogre sat on attempt-1 wheel but the fight moved on before a 1680×1040 capture. Later seeded deals still list Ogre on b2–b5; map only offered Verdant `LaunchHit_start` / `b1`. No `02-ogre-wheel-and-callout.png`. |
| 03 | fail | Faced Golem with matching wheel seat + right callout (blond-brown golem, same idle plate) but the saved file is **1024×632**, not 1680×1040. `shots/03-golem-wheel-and-callout.png`. |

## Blockers

- Viewport capture path downscaled; exec `save_png` was denied (`DirAccess`) then the game was not running.
- Juggernaut absent from this Middle Progress `next_run` seed.
- Map shortcuts never showed b2–b5 on Continue after limp home (only Verdant pins).

## Shots

`playtest/repot/outbox/REQ-20261117-callout-matches-wheel/shots/03-golem-wheel-and-callout.png`
