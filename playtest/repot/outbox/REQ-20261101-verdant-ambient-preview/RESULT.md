---
id: REQ-20261101-verdant-ambient-preview
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-01T21:55:00-05:00
machine: Cherry
tip_sha: aeae5a52
godot: F5 playtest (godot-mcp)
---

# Result

| id | verdict | note |
|----|---------|------|
| 01 | pass | 1680×1040 wheel, ambient off: dry hall, no motes/haze/shaft. Pair baseline vs 02. |
| 02 | pass | Same wheel, ambient on: darker damp vignette, edge moss, shaft slot occupied (`LightShaft` present). Wheel strips, hub Sprout, hotbar, cue stay clear. |
| 03 | pass | Campaign b1 draft/seating (`phase=draft`): same kit behind filling wheel; seat names/pips readable. (Campaign auto-grants starter six — no pick-two overlay on this path.) |
| 04 | pass | Mid-spin (`_wheel_busy`): callout + motion; spores/fireflies still `emitting`; kit stays in the hall, does not cover wheel/hotbar. |
| c1 | skip | Movie Maker not run — would need a second Godot process while Play is live. |
| c2 | skip | Same. |

## Blockers

None for stills. Clips skipped (Movie Maker).

## Selftest

`godot --headless -s res://scripts/dev/biome_ambient_selftest.gd` → `BIOME_AMBIENT_SELFTEST ok` (shaft child present). `text_audit` skips `ambient_fx`; selftest confirmed no Label/RichTextLabel under the kit.

## Shots

All PNGs under `shots/` using the filenames from the request table (native viewport 1680×1040).
