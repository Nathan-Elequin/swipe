# REQ-20261101-verdant-ambient-preview — outbox

Cloud agent shipped the kit on `cursor/verdant-ambient-preview-0417`. This environment has no Godot binary, so stills/clips are **not** captured here. Local Cursor on Cherry fulfills via the matching inbox request.

## Expected shots

| file | notes |
|------|-------|
| `shots/01_wheel_b1_ambient_off.png` | `--ambient=off` |
| `shots/02_wheel_b1_ambient_on.png` | default / `--ambient=on` |
| `shots/03_draft_b1_ambient_on.png` | draft with ambient |
| `shots/04_wheel_b1_midspin_on.png` | mid-spin |
| `clips/verdant_ambient_off.avi` | 8 s Movie Maker if feasible |
| `clips/verdant_ambient_on.avi` | 8 s Movie Maker if feasible |

## Selftest

```
godot --headless --path . -s res://scripts/dev/biome_ambient_selftest.gd
```

Expect: `BIOME_AMBIENT_SELFTEST ok`

## Yank the shaft alone

1. `scripts/fx/biome_ambient.gd` → `const SHAFT_ENABLED := false`
2. or set `BIOMES.b1.shaft = false`
3. or delete the `LightShaft` child at runtime / from the scene tree

No other layer needs to change.
