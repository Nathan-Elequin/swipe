---
id: REQ-20261114-return-flow-v2
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T04:25:00-06:00
machine: Cherry
tip_sha: a041c697
godot: F5 playtest, real mouse/keys (computer-use + game viewport). No time freeze, no _dev_*, no cheat buttons, no DevChrome.set_enabled.
viewport_grab: logical 1680x1040 (Godot Game window chrome 1550x960)
no_progress_shortcut: true
---

# Result

Checkout `playtest/latest` @ `a041c697`. On-screen BuildStamp `a041c697*`. Brand New from a fresh save. `user://` backed up to `_repot_backup_20261114_return_flow_v2` and restored (hashes match).

| id | verdict | note |
|----|---------|------|
| 01 | pass | First cabin after welcome/Onward: Nib in the entryway, map pointer/pulse at Grandpa's map, hall door open, study padlock still on. Music `music_cabin.ogg`. No `🧪` / copy stamp. Plinths in tree: `plinth_empty.png`, no `slot_recess_*`. Shot: `01-first-cabin-entryway.png`. Tree paused during Nib dialog (expected). |
| 02 | fail | First return via real limp-home after dying empty-handed. Landed in the **trophy hall first** (pass vs old fireplace land). Nib: “Empty-handed?” — satchel never opened, no item in the air, no poof, no slot light. Shot is the empty hall after that line (`02-satchel-before-claim.png`), not a 3-frame unpack. Could not get a claimed item without winning a run or keeping loot; did not use a fill/grant cheat. |
| 03 | fail | No claimed plinth / gold ring. All visible slot Plinth textures stayed `res://assets/ui/trophy/plinth_empty.png`. Missing `03-claimed-on-plinth.png`. |
| 04 | fail | Clicked the Fangs silhouette (unclaimed). A parchment strip appeared beside it; text was cut off at the bottom. Mouse-off and a rug click did **not** hide the tag (`vis` stayed true). Shot: `04-parchment-tag.png`. No claimed-item tag to test. |
| 05 | fail | One still of the framed board (`05-board-clip-no-neighbour.png`): wooden **VERDANT HOLLOW** sign, dais, silhouettes on dusty slabs. Crystal Cavern face is locked (padlock). Board chevron click while `SceneTree.paused==true` jumped too fast to grab 3 mid-slide frames; Crystal Cavern art clipped inside the frame with Nib still in the room. Neighbour board did not peek at the room edge in the still. |
| 06 | fail | After the keys beat, study/workshop/loft doors were unlocked (padlocks gone). Walking hall→main worked even while paused. Shot `06-post-unlock-map-pointer.png`: Front Room, unlocked doors, **Nib.visible=false**, wall map node `visible=true` but not readable on screen, leftover parchment from the hall, no continue-mission pointer. |
| 07 | pass | Wide hall: `board_dais` under the board, placard nearest, silhouettes. Shot: `07-dais-and-placard.png`. |

## Extra shots from the drain brief (not in the REQ table)

| extra | verdict | note |
|-------|---------|------|
| land-trophy-first | pass | Limp-home opened into the trophy hall, not the fireplace. |
| SceneTree after limp | fail | `paused=true` after limp + Nib dialog. Some PROCESS_ALWAYS clicks still worked (doors, map, board chevron). Same class as prior QA P07. |
| unpack 3 frames | fail | Empty-handed; no air / poof / slot-lit sequence. Slot never lit (nothing to claim). |
| board mid-slide 3 frames | fail | Could not catch mid-slide; paused + instant swap. |
| lever + Crystal splash +2s/+5s | fail | Crystal Cavern still cloud-locked on the map. Never reached the workshop lever on this Brand New path after limp. Did not Grant/Fill. |
| second Verdant music | pass | See sibling REQ music dump. Biome loop held through +6s. Extra shot `08-verdant-second-enter.png`. |

## Slot / parchment dump (visible trophy children)

Hall after limp, SHA `a041c697*`, music `res://assets/audio/music_cabin.ogg`, paused=true:

- Slot Plinth: `res://assets/ui/trophy/plinth_empty.png` (no `slot_recess_lit` / `slot_recess`).
- Aura: none visible on empty slots.
- Sprite: silhouette item textures on empty slabs (Fangs etc.), not claimed art.
- Parchment tag after Fangs click: visible, text clipped, stayed up after mouse-off.

## Blockers

- Empty-handed limp skips unpack, so claimed-glow / 3-frame unpack cannot pass on this path without a win or a REQ-allowed progress shortcut (none used).
- `SceneTree.paused` stuck true after limp dialog until leaving for the second Verdant enter (splash unpaused).
- Viewport window chrome 1550×960; `get_viewport().get_texture()` is 1680×1040.

## Save restore

Backup `%APPDATA%\Godot\app_userdata\Spinheritance\_repot_backup_20261114_return_flow_v2`. After Stop Play, SHA256 matched:

- home_cabin.json `7B5066D7418F6D8C386AFE39DDF24D0D0B56FF0552B21B6B644A88D9ADDEEE48`
- campaign_save.json `62612FCADF4E3826E83DF48869DE72D63572BB4D08A1D3D321D1F8FC7CBCB54C`
- bucket_progress.json `50FC018FB6625F2C6A9FDBBC3CE71FCD0B594994500AD1AD75968FACB471985A`
- playtest_meta.json `BC9714F75CEB2F34E17ED409A16C54BEACC251404A770F84DD990B851727C2EA`
- playtest_anon.json `DF3BC46BF4A5562020B5E2352B67567CC463F6DFB7CF5A080833460C80321219`
- audio.json `D2100D115DC8212063322704C7F435FE8BEA8F9061A15E1239BE5EB261CCC1C5`
