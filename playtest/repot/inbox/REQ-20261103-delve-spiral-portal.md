---
id: REQ-20261103-delve-spiral-portal
status: open
priority: high
tip_sha: pending
branch: playtest/latest
created: 2026-11-03T23:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → campaign run → clear a dungeon → Rope Exit rest (gate on the right)
---

# Delve spiral portal behind GateFrame

Spiral portal under the diegetic Delve gate on Rope Exit. Must sit **behind** GateFrame (posts/lintel clip the swirl). BiomeAmbient palettes b1–b5; sealed when no next biome.

## What to verify

- Portal stack is behind GateFrame — wooden posts and lintel visibly cover the left/right edges of the void and motes (not a sticker on top of the arch).
- Soft floor contact / drop shadow under the aperture onto the cavern floor.
- Campaign with a next biome (b1→b2…→b5): spiral uses that biome’s BiomeAmbient mote/void colours; idle swirl reads as a teleport.
- Hover the gate: spiral speeds up / densifies / brightens (tween).
- No next biome (end of campaign / adventure / non-campaign / endless): dim sealed portal, no bright swirl.
- Painterly `rope_exit_gate_open` stays hidden; Crypt Classic cavern BG + gate frame stay.
- Left signs remain flavor only; Climb=hatch; Delve=gate.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | rope exit | campaign, next biome Crystal (b2), idle (no hover) | glacial-blue spiral inside arch; posts clip edges; floor shadow under aperture | 01-idle-crystal.png |
| 02 | rope exit | same, hover Delve gate | faster/denser/brighter spiral; still clipped by posts | 02-hover-crystal.png |
| 03 | rope exit | adventure or non-campaign clear, or last biome with no next | dim sealed void; no bright motes; still behind frame | 03-sealed.png |
| 04 | rope exit | campaign next = Verdant or Cinder (not Crystal) | palette matches that biome ambient (green or ember), not Crystal blues | 04-other-biome.png |

## Pass criteria

- All rows shot at 1680×1040.
- Layering readable without guessing: GateFrame on top of portal.
- Idle vs hover difference obvious; sealed has no bright swirl.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261103-delve-spiral-portal/`
