---
id: REQ-20261030-chatgpt-grandpa-map
status: superseded
superseded_by: REQ-20261030-held-map-label-clean
priority: high
branch: playtest/latest
created: 2026-10-30T19:10:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Continue / Brand New → cabin → open Grandpa's map (held map hotspot)
---

# REQ-20261030-chatgpt-grandpa-map

**Superseded** by [REQ-20261030-held-map-label-clean](../inbox/REQ-20261030-held-map-label-clean.md) (hide duplicate code Labels over painted ChatGPT plate). Do not drain this REQ; shoot the new label-clean rows instead.

**Screen:** Held Grandpa map (ChatGPT plate feel-test)  
**What shipped:** Replaced `assets/ui/map/held/map_in_hands_living.png` with Nathan's ChatGPT 1680×1040 plate. WaxStamp peel overlays unchanged. TRAIL Shadow + ENDLESS_AT nudged to painted badges; other Doop centres kept.  
**Viewport:** 1680×1040 · Nearest · no gameplay / no player-facing copy changes

## Outbox
`playtest/repot/outbox/REQ-20261030-chatgpt-grandpa-map/shots/`

## What to verify

- Held plate loads full-rect at 1680×1040 (hands baked in, parchment fills sheet).
- Existing wax-seal stamps still sit on the painted biome badges (Verdant → Crystal → Ashen → Cinder → Shadow; Endless bottom-left).
- Hover a unlocked stamp: peel tween still runs (idle → hover lift).
- Press a stamp: press flatten + peel still works; click still starts the run.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | held map | Cabin → open map from cabin | ChatGPT Grandpa plate full-screen (title, zig-zag badges, hands). No old Doop plate. | 01-open-map-plate.png |
| 02 | held map | same, hover Verdant Hollow stamp | Wax stamp peels up on hover; tip readable; stamp still over green badge | 02-verdant-peel-hover.png |
| 03 | held map | DEV fill cabinets if needed → hover Shadow Abyss stamp | Peel on purple badge; hit centre roughly on painted eye badge (not floating left) | 03-shadow-peel-align.png |
| 04 | held map | hover / look at Endless seal (bottom-left) | Endless seal overlay sits on the painted dark seal, not empty parchment far left | 04-endless-align.png |

## Pass criteria

- All four PNGs at 1680×1040.
- Plate is the ChatGPT art (readable title "Grandpa's Map of Mount Grumblegut").
- Peel still animates on hover (visible lift vs idle).
- Shadow + Endless overlays land on painted badges (±~40px ok).

## Copy / gameplay

No copy edits. No rule changes. Stamp filename slugs unchanged (b2 may still be `sunken_mire`).
