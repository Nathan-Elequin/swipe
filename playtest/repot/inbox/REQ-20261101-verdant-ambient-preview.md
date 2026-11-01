---
id: REQ-20261101-verdant-ambient-preview
status: done
priority: high
branch: cursor/verdant-ambient-preview-0417
base: playtest/latest
tip_sha: b1d9b90a
created: 2026-11-01T21:40:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → Verdant Hollow (b1) delve → draft or wheel
---

# Verdant Hollow ambient FX preview (V0–V3 + yankable light shaft)

Cloud ship of the recommended 4-layer Verdant ambient kit plus one thin diagonal light shaft. Shaft is its own `LightShaft` child under `BiomeAmbient` with `const SHAFT_ENABLED := true` (also `BIOMES.b1.shaft`) so flipping false / deleting that child restores kit-without-shaft. b1 only. CPUParticles2D only. F10 / `--ambient=on|off`. No player-facing copy. No itch export.

## What to verify

- Ambient off (F10 or `--ambient=off`) looks pixel-identical to today's dry hall.
- Ambient on: damp mist + canopy, far spores, gold fireflies (#E8D36A), edge-only dark moss fall — reads "damp, mossy, alive" within ~2 s.
- Thin soft diagonal light shaft from top-left is visible but low-alpha; does not fight the wheel.
- Nothing sits on wheel strips, hub Sprout, hotbar, cue, draft cards, or trophy.
- Mid-spin: ambience stays calm (does not freeze; does not fight the wheel).
- Non-b1 / Endless / cabin / map: no ambient layers.
- F10 toggles; `--ambient=off` forces off for paired shots.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | b1 wheel | ambient off (`--ambient=off` or F10) | dry hall baseline, no motes/haze/shaft | 01_wheel_b1_ambient_off.png |
| 02 | b1 wheel | ambient on | mist+canopy, spores, fireflies, shaft, edge moss; wheel clean | 02_wheel_b1_ambient_on.png |
| 03 | b1 draft | ambient on during draft | same kit behind/beside draft cards; cards readable | 03_draft_b1_ambient_on.png |
| 04 | b1 wheel mid-spin | ambient on, wheel spinning | calm drift; no freeze; wheel stays clearest | 04_wheel_b1_midspin_on.png |

## Clips (if Movie Maker feasible on Cherry)

| id | setup | expect | filename |
|----|-------|--------|----------|
| c1 | `--ambient=off` 8 s | static dry hall | clips/verdant_ambient_off.avi (or .mp4) |
| c2 | `--ambient=on` 8 s | damp drift readable in motion | clips/verdant_ambient_on.avi (or .mp4) |

## Pass criteria

- All stills 1680×1040.
- Off/on pair shows the damp read without covering play UI.
- text_audit does not flag ambient_fx group over copy.
- Selftest `scripts/dev/biome_ambient_selftest.gd` prints `BIOME_AMBIENT_SELFTEST ok`.

## Outbox path

`playtest/repot/outbox/REQ-20261101-verdant-ambient-preview/`
