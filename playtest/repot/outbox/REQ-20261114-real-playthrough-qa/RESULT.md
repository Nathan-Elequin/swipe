---
id: REQ-20261114-real-playthrough-qa
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T09:50:00-06:00
machine: Cherry
tip_sha: d59492c3ee3f01ab18af52be0906d7879983ae57
godot: F5 playtest, real mouse/key only, no time freeze, no _dev_* / preview_* / show_def
viewport_grab: 1550x960 window (logical layout 1680x1040)
---

# Checkout probe

- git HEAD: `d59492c3ee3f01ab18af52be0906d7879983ae57` (`playtest/latest`)
- Godot project path: `C:/Users/Natha/Documents/boss-rush/`
- On-screen build label: `d59492c3*` (trailing `*` because the working tree has untracked `.import` files)
- Import errors after rescan: none. Output panel only had old TextEdit gutter / DAP / one WASAPI note. No PNG corrupt.

# Result

| id | verdict | note |
|----|---------|------|
| P01 | pass | Playtest letter → framed hub → Brand New. Intro Skip, road caption, tutorial Yes/Skip. Shots: `P01-title.png`, `P01-hub.png`, `P01-after-brand-new.png`, `P01-tutorial-ask.png`. |
| P02 | pass | After Skip tutorial + Onward on the loot-reveal, cabin main: Nib is on the rug (anim `psst`), map hangs on the wall, Nib says “Here we are, Sprout…”. Dummy chrome still on: `🧪 playtest/latest`, copy stamp, Log. Shot: `P02-cabin-after-onward.png`, `P02-cabin-entry.png`. |
| P03 | pass | Space through Nib opened Grandpa’s map. Clicked `LaunchHit_start` (START HERE / Verdant Hollow). Music: `music_verdant_hollow_intro.ogg` then `music_verdant_hollow_loop.ogg`. Map also showed editor buttons Grant 3 uniques / Fill cabinet / Fresh campaign. Shots: `P03-map.png`, `P03-enter-verdant.png`. |
| P04 | fail | Hovering Boot/Flail opened inspect. Defeat is gold + icon + `[url=kw:defeated]`. Sweeping/warping the mouse on that meta never made `keyword_tip` visible (`visible=false` on every tip panel). A player cannot tell the word is hoverable except the gold color; no definition card appeared. |
| P05 | fail | First-sighting gold teach halo was not seen. What did play: Nib’s “See that New! mark?” line, then the Berserker slash intro (`P05-berserker-slash.png`). Mouse-down on Spin did nothing; Enter on a focused Spin did spin the wheel. |
| P06 | pass | Real play: draft splash, Spin (via Enter), TakeArc vs Golem, Fangs pick, then death. End-of-run: spotlight + “Limp home”. Shot: `P06-death.png`. |
| P07 | fail | Limp-home walk to the door, door opens, land in fireplace/main. Nib is visible by the broom (not an invisible key-runner). Both side doors still show padlocks. After landing, `SceneTree.paused` stayed true, so later cabin clicks did not change room. |
| P08 | fail | No satchel float/drift/land/poof played. After limp-home the tree was paused in `beat=idle`; no slot-light-before-item sequence. |
| P09 | fail | Never reached the trophy room as a player. Off-screen `TrophyBoard` plinths in the tree were all `res://assets/ui/trophy/plinth_empty.png`. |
| P10 | fail | Could not hover/click claimed vs silhouette parchment; not in that room. |
| P11 | fail | No board switch. |
| P12 | fail | Lever / Crystal Cavern splash never reached. |
| P13 | fail | No second Verdant enter. Cabin music after limp: `music_cabin.ogg` + fire + purr. |
| P14 | pass | Dummy/debug on screen the whole time: `BuildStamp/Sha` `d59492c3*`; `DevBranchTag` `🧪 playtest/latest` (`scripts/dev/branch_tag.gd`); copy stamp `copy: swipe-player-copy-v3-draftgate · 2026-11-08`; Log; map cheats Grant 3 uniques / Fill the Verdant Hollow cabinet / Fill every cabinet / Fresh campaign. Shot: `P14-dummy-labels.png`. Never saw “B2 is now open”. |
| P15 | fail | Nib taught the New! mark before Spin. Did not get a clean hotbar star before/after first use of a new item (died; return paused). |

## Save restore

Backup `user://_repot_backup_20261114_real_playthrough/`. After restore, SHA256 matched for home_cabin, campaign_save, bucket_progress, playtest_meta, playtest_anon, audio.

## Blockers

- Godot MCP `godot_input` has no absolute mouse click; clicks used `Viewport.push_input` mouse events plus keys. Hub/Skip/Onward/TakeArc worked that way. Spin needed keyboard Enter.
- Game window was 1550×960; content layout 1680×1040.
- After Limp home the tree stayed paused. Did not force-unpause.
