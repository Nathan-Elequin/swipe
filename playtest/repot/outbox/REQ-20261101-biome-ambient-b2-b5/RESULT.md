---
id: REQ-20261101-biome-ambient-b2-b5
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-01T20:05:00-05:00
machine: Cherry
tip_sha: 307b0f48
godot: F5 playtest (godot-mcp) — Middle Progress, cheat-unlock, wheel seating, F10-equivalent set_enabled off/on
viewport: 1680x1040
---

# Result

| id | verdict | note |
|----|---------|------|
| 01 | pass | Crystal wheel, ambient off. Dry ice hall. No mist/glints/shaft. 1680×1040. |
| 02 | pass | Same seating, ambient on. Cool mist + cyan ice glints + edge frost flecks. No LightShaft. Wheel and hotbar readable. Pair hash differs from 01. |
| 03 | pass | Ashen wheel, ambient off. Dry crypt hall. |
| 04 | pass | Ambient on. Dusty brown haze + falling ash specks (not fire). No shaft. Wheel clean. |
| 05 | pass | Cinder wheel, ambient off. Dry forge hall. |
| 06 | pass | Ambient on. Heat haze + rising orange embers/soot on the edges. No shaft. Wheel and hotbar readable. |
| 07 | pass | Shadow wheel, ambient off. Dry abyss hall. |
| 08 | pass | Ambient on. Heavier top crush + rare dim violet motes. Sparse. Wheel readable. No shaft. |

Selftest: `BIOME_AMBIENT_SELFTEST ok` (headless `scripts/dev/biome_ambient_selftest.gd`). Live b5: `ambient_fx` group skip; text_audit `_sprite_hits` returned 0 ambient copy flags; no Label/RichTextLabel under the kit (selftest). Shaft node absent on b2–b5.

## Blockers

None.

## Shots

All PNGs under `shots/` using the request filenames (1680×1040).
