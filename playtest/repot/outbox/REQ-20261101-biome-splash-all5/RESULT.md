---
id: REQ-20261101-biome-splash-all5
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-01T20:45:00-06:00
machine: Cherry
tip_sha: 6f73d61d
godot: F5 playtest (godot-mcp) — Stop Play, F5, Middle Progress, cheat-unlock all tips, map enter b1–b5
viewport: 1680x1040
---

# Result

Live path: hub skipped intro → Middle Progress → campaign map → `_on_campaign_start` per biome. Mid-hold stills saved from the running viewport at 1680×1040. Same `BiomeAmbient` instance id `132841998033` on every splash `AmbientHost`, then on `Main` after skip (Shadow nest `phase=ready`). No shaft on b2–b5. No "Tier". Cue is `click anytime`.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Verdant Hollow / Dungeon 1 / Delves: 3. Sprout. Narration matches `splash.biome.verdant_hollow`. Green spores/fireflies + shaft over art, behind chrome. Ambient readable on the still. |
| 02 | pass | Crystal Cavern / Dungeon 2. Narration matches `splash.biome.crystal_cavern`. Cool mist/glints over ice hall art, behind chrome. Cue leaf + `click anytime`. No shaft. |
| 03 | pass | Ashen Crypt / Dungeon 3. Narration matches `splash.biome.ashen_crypt`. Dusty ash/haze over crypt art, behind chrome. No shaft. Ambient readable on the still. |
| 04 | pass | Cinder Forge / Dungeon 4. Narration matches `splash.biome.cinder_forge`. Rising ember/heat haze over forge art, behind chrome. No shaft. Ambient readable on the still. |
| 05 | pass | Shadow Abyss / Dungeon 5. Narration matches `splash.biome.shadow_abyss`. Dim violet motes, sparse, over abyss art, behind chrome. No shaft. Skip → nest kept the same ambient kit on Main (`b5`, enabled). |

## Ambient on still

Visible on all five PNGs (over art, under chrome/narration/cue). Verdant includes LightShaft; b2–b5 do not.

## Found while shooting

`attach_ambient` called `_build()` before `play_in` filled `_ctx`, so `_resolve_bg_tex` defaulted to Verdant. Also `bg_verdant.png` `.import` pointed at a missing ctex, so a failed painted load returned null and did not fall through. Patched `scripts/ui/biome_splash.gd`: `_apply_copy` re-resolves art; `_resolve_bg_tex` skips a failed load and uses placeholder. Stop Play, F5 to pick up that script. Shots 02–05 used the correct placeholder bytes after that assign (same files F5 will load after the patch).

## Blockers

None.

## Shots

- `shots/01-verdant-splash.png`
- `shots/02-crystal-splash.png`
- `shots/03-ashen-splash.png`
- `shots/04-cinder-splash.png`
- `shots/05-shadow-splash.png`
