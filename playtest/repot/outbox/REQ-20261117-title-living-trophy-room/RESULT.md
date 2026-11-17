---
id: REQ-20261117-title-living-trophy-room
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-17T01:10:00-06:00
machine: Cherry
tip_sha: 75e83ad39d321f22e9fae01cdc3f1b512bede64d
requested_tip_sha: f1b0fdb89ba12c2727a2cbb744fd45ecd18d39de
godot: F5 playtest, godot-mcp Viewport.push_input + injected keys only
viewport: game window 1680x1040; native Viewport PNG saves 1680x1040; MCP screenshot_game preview was ~1024x632
---

# Result

Checkout `playtest/latest` @ `75e83ad3`. On-screen BuildStamp `75e83ad3*` then `f3690fbe*` after Continue (dirty marker from uncommitted local files, not a branch switch).

Input: godot-mcp `Viewport.push_input` mouse and `godot_input` keys. No computer-use, no `_dev_*`, Grant, DevChrome, or forced poses. Brand New / Continue / Middle Progress / Skip / picker clicks only.

Fresh `user://` wipe at start (backup `_repot_backup_20261117_title_juggernaut`, SHA256 restored after Stop).

**Black band:** yes. Living trophy title and commitment picker both paint a solid black strip from y=832 to 1040 (`BackdropFloor`).

**Gargoyle dirt base:** yes. Settings-row presenter is a gargoyle standing on a brown rock/dirt mound (visible in `03`, `06`, `08`, `09`). `_maybe_crop_gargoyle` leaves offset at zero.

Music: intro `res://assets/audio/music.ogg` (`music_state` draft); title hub `res://assets/audio/music_title.ogg`; Verdant fight `res://assets/audio/music_verdant_hollow_loop.ogg`.
`SceneTree.paused`: true on intro / title / picker; false in cabin, map, and ready fight.
Dialogue keys: `playtest.intro.05` (shot 01); picker “How far do you want to go?”; Nib arrive “Welcome home, Sprout…”; Verdant splash `click anytime`; Nib New-mark talk in 05 (`Press Space to continue`).

| id | verdict | note |
|----|---------|------|
| 01 | fail | Intro.05 mock is the old Playtest Brand New/Middle/Continue/Feedback plate, not the living trophy no-save title. Native 1680×1040. |
| 02 | fail | First boot after picker is still framed study-B hub (Brand New / Middle Progress / Feedback). No New Game / Settings / biome board. Native 1680×1040. |
| 03 | pass | After a save exists, living trophy title: Settings tag hover-lit; goblin/gargoyle/lich presenters. Native 1680×1040. |
| 04 | fail | Three commitment cards at 1680×1040; middle card hovered. Copy keys raw (`biome.name.verdant`, `picker.pick.quick`). Rings are not clearly green/silver/gold. Black band at bottom. |
| 05 | pass | Ready Verdant fight, green Quick ring top-left, ticker “Goal: Finish your first solo run and come home.” clear of wheel/arrows/hand (Nib New-mark overlay is on). Native 1680×1040. |
| 06 | pass | Continue / Settings / Feedback; Start over visible; green goal ring; Verdant named, other biomes dimmed with names. Native 1680×1040. |
| 07 | fail | Title Settings shows the same 5 sliders (Master/Music/Ambience/SFX/UI). Fresh wipe left them at 0; Music drag did not read on the jukebox in the PNG. Native 1680×1040. |
| 08 | pass | Confirm modal, Keep my save focused, Keep clicked (save kept). Native 1680×1040. |
| 09 | fail | Reduce motion clicked, then Continue hovered; still is too close to 03 to prove “no movement, stylebox only.” Native 1680×1040. |

## Blockers

- No-save boot still uses framed hub + intro mock, so 01/02 cannot show the living trophy title until a save exists.
- `goal_ring_quick.png` failed to load on first Quick pick (`ERR_CANT_OPEN` `.ctex`).
- MCP `screenshot_game` still downsamples; native shots used `Viewport.get_texture().get_image().save_png` to `user://` then copied into the outbox.

## Shots

All table PNGs under `shots/` at 1680×1040.
