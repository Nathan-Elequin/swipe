---
id: REQ-20261101-biome-enter-splash
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-01T16:20:00-05:00
machine: Cherry
tip_sha: dda565ce
godot: F5 playtest (godot-mcp) on playtest/latest (includes dda565ce)
viewport: 1680x1040
---

# Result

| id | verdict | note |
|----|---------|------|
| 01 | pass | Live F5 map→Verdant hold. Chrome Verdant Hollow / Dungeon 1 / Delves: 3, Sprout ×5, narration bar, leaf + `click anytime`. No Tier. No "Click to continue". 1680×1040. |
| 02 | pass | After skip + nest settle. Splash gone; wheel at rest in the hall. 1680×1040. |
| music | pass | After `_reset_run` no longer calls `start_music()` while `_splash_busy`. Re-enter audio_log: one `music_to` `verdant_hollow_intro` at splash; skip/nest did not re-fire; intro→loop later is the bed handoff, not a second enter. |
| mid-dissolve skip | pass | Skipper clicked at alpha ≈0.12; splash play_out; nest locked then cleared. |
| leave | pass | `_give_up` / dissolve: `BiomeWipe` only, no `BiomeSplash`. |

## Blockers

None.

## Shots

- `shots/01-verdant-splash.png`
- `shots/02-wheel-after-nest.png`
