---
id: REQ-20261114-trophy-board-final-art
status: done
priority: high
branch: cursor/trophy-board-final-art-35b7
created: 2026-11-14T02:35:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Continue / Middle Progress → cabin fireplace (main) → walk right into Trophy Hall
---

# Trophy board final art (placeholders → PixelLab ship)

Final art from the 2026-11-13 trophy-board ship zip overwrote Package B placeholders: board frame, crests, plaques, face backdrops, lights, lever, padlock, dots, arrows, aura, satchel, poof, splashes, map/trophy pieces, Nib react/watch frames, and repainted `room_main` / `room_trophy` plates. Package A (`cd40c6bc`) already removed Outpost/cabinets/center `RunDoor`. This PR only lands final trophy-board art + SIZES merges on top.

## What to verify

- Main room center is log wall + peg rail (coat/hat/scarf), not a painted run door sprite on top of the plate.
- Trophy Hall uses `room_trophy` plate; board shows final oak frame, verdant face bg, crest, plaque, lights, lever, dots, arrows (Nearest, crisp pixels).
- Claimed slots show aura; locked face shows padlock.
- No Linear blur / mipmaps on board or plate textures.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | main | spawn at fireplace | Center wall is log planks + peg rail; no overlapping `run_door` sprite; right SideDoor still present | 01-main-log-wall.png |
| 02 | hall | walk right from main into Trophy Hall | Final board frame + verdant face + crest/plaque; Nearest pixels; no placeholder flat colors | 02-hall-board.png |
| 03 | hall | same, claimed items visible if save has any | Claimed slots show gold aura / lit recess; silhouettes for unseen | 03-hall-claimed-aura.png |
| 04 | hall | page or face with locked later biome if available | Padlock centered on locked face; dots/arrows readable | 04-hall-locked-face.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261114-trophy-board-final-art/`
