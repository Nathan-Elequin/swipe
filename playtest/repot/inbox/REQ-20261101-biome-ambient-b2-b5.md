---
id: REQ-20261101-biome-ambient-b2-b5
status: open
priority: high
branch: cursor/biome-ambient-b2-b5-55d1
base: playtest/latest
tip_sha: 895dcb2f
created: 2026-11-02T01:50:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → enter each biome delve (b2 Crystal / b3 Ashen / b4 Cinder / b5 Shadow) → wheel seating
---

# Biome ambient FX b2–b5 (Crystal / Ashen / Cinder / Shadow)

Cloud ship extending `scripts/fx/biome_ambient.gd` so Crystal Cavern, Ashen Crypt, Cinder Forge, and Shadow Abyss get the same 4-slot ambient kit as Verdant (V0 haze · V1 far · V2 accent · V3 near edges). Data-driven via `BIOMES`. Shaft stays OFF for b2–b5; Verdant (b1) shaft + look stay as tip. CPUParticles2D only. F10 / `--ambient=on|off`. No player-facing copy. No itch export. Cloud cannot F5 — Cherry drains this inbox.

## What to verify

- Each biome off/on pair at the wheel: off = dry hall; on = biome signature readable in ~2 s without covering wheel / hotbar / cue / draft.
- **b2 Crystal** — cool mist + sparse sharp cyan/ice glints + edge frost flecks; no shaft.
- **b3 Ashen** — dusty brown haze + readable falling ash (not fire); no shaft.
- **b4 Cinder** — heat haze + rising orange embers/soot (direction flip vs Verdant); no shaft.
- **b5 Shadow** — heavy top crush + rare dim violet motes; sparse; no shaft.
- Verdant (b1) still looks like today's tip preview if you spot-check (not required in this shot table).
- Endless / cabin / map: still no ambient.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | b2 wheel | Crystal Cavern, ambient off (`--ambient=off` or F10) | dry hall baseline, no mist/glints | 01_wheel_b2_ambient_off.png |
| 02 | b2 wheel | Crystal Cavern, ambient on | cool mist + sharp glints + edge frost; wheel readable; no shaft | 02_wheel_b2_ambient_on.png |
| 03 | b3 wheel | Ashen Crypt, ambient off | dry hall baseline | 03_wheel_b3_ambient_off.png |
| 04 | b3 wheel | Ashen Crypt, ambient on | dusty haze + falling ash readable; dry crypt not fire; wheel clean | 04_wheel_b3_ambient_on.png |
| 05 | b4 wheel | Cinder Forge, ambient off | dry hall baseline | 05_wheel_b4_ambient_off.png |
| 06 | b4 wheel | Cinder Forge, ambient on | heat haze + rising embers/soot; orange accent; wheel clean; no shaft | 06_wheel_b4_ambient_on.png |
| 07 | b5 wheel | Shadow Abyss, ambient off | dry hall baseline | 07_wheel_b5_ambient_off.png |
| 08 | b5 wheel | Shadow Abyss, ambient on | heavy crush vignette + rare dim violet motes; sparse; wheel readable | 08_wheel_b5_ambient_on.png |

## Pass criteria

- All stills 1680×1040.
- Each on-shot shows the biome signature without eating the wheel.
- Off/on pairs prove the toggle.
- Selftest `scripts/dev/biome_ambient_selftest.gd` prints `BIOME_AMBIENT_SELFTEST ok`.
- text_audit does not flag ambient_fx group over copy.

## Outbox path

`playtest/repot/outbox/REQ-20261101-biome-ambient-b2-b5/`
