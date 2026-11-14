---
id: REQ-20261114-return-flow-v2
status: done
priority: high
branch: cursor/return-flow-v2-1368
tip_sha: 25b29156
created: 2026-11-14T10:10:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New (fresh save) for first cabin; separately Middle Progress / limp-home or clear dungeon 1 for first return
---

# Return flow v2 + trophy art match mock

Nathan-locked return flow after real-playthrough QA, plus trophy board art wired to the approved contact sheet / WIRING.md. Merged on top of playtest/latest including PR #518 (biome music + F11 DevChrome). Cloud cannot F5 with godot-mcp — local shots required. Headless board render + slot texture dump landed under `design/audit-shots/cursor/return-flow-v2/`.

## What to verify

- **First cabin (Brand New):** Nib visible in the entryway (main). Map pointer / pulse after welcome lines. Hall (trophy) already unlocked; study/workshop/loft still locked.
- **First return (win OR limp-home):** lands in trophy hall first. Satchel unpack: item lands → poof → THEN plinth lights (not early). After trophy beat: pan to entryway, visible Nib unlocks study→workshop→loft (no invisible key-runner, no hall re-unlock). Then continue-mission line + map pointer.
- **SceneTree not paused / no stuck black wipe** after limp-home or Crystal Cavern lever splash dismiss.
- **Trophy art matches mock:** every 128 cell on `plinth_claimed` / `plinth_empty` (compact `_s`); no `slot_recess_lit` squares; item seated on slab top; claimed gold pulse ring; parchment_tag NinePatch beside item, readable #4a2f1f text; `board_dais` at (152,812); placards Nearest; neighbour board never visible outside the frame (FaceViewport clips).
- **Music / F11:** cabin bed restores after portal splash (music_cabin); editor branch tag / map cheats stay behind F11 (PR #518 kept).
- No player-facing "Tier" / "ATK". No raw `🧪 playtest/latest` branch chrome in playtest F5.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | main | Brand New → first cabin after welcome | Nib visible in entryway; map pointer or pulse near Grandpa's map; hall door open; study locked | 01-first-cabin-entryway.png |
| 02 | hall | first limp-home or win return, mid unpack | satchel up; item flying or just landed; plinth still empty/silhouette until after poof | 02-satchel-before-claim.png |
| 03 | hall | same return, after first item poof | claimed item on plinth_claimed + gold ring; not square recess tile | 03-claimed-on-plinth.png |
| 04 | hall | hover/click a claimed item | parchment_tag beside item (not overlapping); readable dark-brown text; clamped on screen | 04-parchment-tag.png |
| 05 | hall | board slide left/right once | only current face inside frame; no blue neighbour board peeking at room edge | 05-board-clip-no-neighbour.png |
| 06 | main | after trophy beat + key unlock | study/workshop/loft unlocked; Nib visible; map pointer for continue mission | 06-post-unlock-map-pointer.png |
| 07 | hall | wide shot | board_dais under board; placard Nearest crisp | 07-dais-and-placard.png |

## Pass criteria

- All rows shot at 1680×1040 via Godot MCP (in-game, not editor FS).
- Real input only (no forced pose cheats) for 01–06.
- Slot children never show `slot_recess_*` textures.
- Tree not paused; cabin clickable after limp-home.
- No Tier/ATK in parchment or tips.

## Outbox path

`playtest/repot/outbox/REQ-20261114-return-flow-v2/`
