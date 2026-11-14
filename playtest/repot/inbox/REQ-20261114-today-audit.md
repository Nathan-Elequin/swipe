---
id: REQ-20261114-today-audit
status: done
priority: high
tip_sha: e667b20c
created: 2026-11-14T05:45:00Z
created_by: pixel
viewport: 1680x1040
---

# Full audit of everything shipped Nov 13 (Pixel design audit)

Nathan wants Pixel to audit today's flow end to end from real local screenshots. Capture **evidence only**: do not fix anything, do not change copy, do not edit game code.

This REQ also drains these open inbox REQs in the same session. Write each one's own outbox as usual:
- REQ-20261114-flow-overhaul
- REQ-20261114-ladder-wipe
- REQ-20261114-juggernaut-B
- REQ-20261114-trophy-board-package-c
- REQ-20261114-trophy-board-package-e
- REQ-20261114-trophy-board-feedback-2
- any other REQ-20261114-* still open

## Setup
- Use a **fresh save** (back up and restore Nathan's real save after) for the first-return rows, then a save with 4/5 uniques for the lever rows. Use dev/debug hooks if they exist to reach states fast. Note which hook was used.
- 1680x1040. For anything fast (transitions, wipes, fades), capture a **burst**: at least 8 frames at ~100 ms spacing, or every frame via a tiny capture script.
- For every row also dump `audit/<id>-state.txt`. It should list the current scene, the visible CanvasLayers/Controls with their modulate/alpha and z_index, the active music key, the playing ambience keys, and any tween running.

## Rows
| id | flow moment | capture | why |
|----|-------------|---------|-----|
| A01 | dungeon clear, then Rope Exit, then ladder click | burst across wipe to exterior to Sprout walk-in | verify #511 (no dev strip, no right-slide, no old Sprout) |
| A02 | exterior to cabin interior, first return | stills every dialogue beat of Nib's key-ring/room unlock | music key must be cabin music |
| A03 | Nib hall walk to trophy post | burst while walking past/in front of the board | Nathan: Nib looks too small and floats in front of the board; we need his feet y vs the floor line vs the board base |
| A04 | first unpack (0 items and 1+ items) | stills each item landing + Nib lines | branch correctness after #511 |
| A05 | hover pulse on first placed item | 2 stills (pulsing / after hover) | |
| A06 | first board light + lever ring + Nib gesture | stills | we need to see what Nib's gesture points at; there is no arrow yet |
| A07 | click an item on the trophy board | stills: popup open, then mouse moved off, then 2s later | Nathan: popup lingers and can't be dismissed |
| A08 | board at 4/5 then 5/5 lights, lever bright | stills | |
| A09 | lever pull, rumble, new dungeon splash | burst from pull through the splash, plus the active music key per frame | Crystal Cavern music should fade in here (not yet built) |
| A10 | **after the splash** | burst for 5 s after the splash ends, plus a full state dump each second | Nathan: screen goes black, sounds and clicks still work; find which layer is covering (alpha, fade rect, camera) |
| A11 | biome title cards / splash titles (all biomes reachable) | one still each | Nathan: too hi-res and AI-looking; Pixel will redo |
| A12 | transition stage (Rope Exit) with 0, 1 and 3+ carried items incl. a new unique | stills | dead portal, arch lights, satchel, strip, star |
| A13 | dead portal click | burst | fizzle + shake |
| A14 | in combat: hotbar with a never-before-seen item | still + 6-frame burst of the sheen | Nathan: sheen is distracting |
| A15 | Juggernaut on wheel (idle + spin), facing, slash, bestiary | stills | skin must be plain tan |
| A16 | trophy board seen-but-unclaimed vs claimed vs unseen slots, close crop | stills | Pixel is redesigning slot states |
| A17 | anything else that looked wrong during the run | stills + one-line note | |

## Outbox
`playtest/repot/outbox/REQ-20261114-today-audit/`, containing:
- `shots/<id>-*.png`
- `audit/<id>-state.txt`
- `RESULT.md`: one line per row (captured or blocked, plus any observed bug, plain). For A10, name the covering node path if found.

Commit and push the outbox to `playtest/latest`. Commit only outbox files. Never stash Nathan's edits; if there are local edits, commit them as a WIP checkpoint first.
