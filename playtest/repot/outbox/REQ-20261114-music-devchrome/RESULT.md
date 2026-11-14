---
id: REQ-20261114-music-devchrome
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T04:25:00-06:00
machine: Cherry
tip_sha: a041c697
godot: F5 playtest, real mouse/keys. No freeze, no DevChrome.set_enabled, no map Grant/Fill/Fresh.
viewport_grab: logical 1680x1040 (window 1550x960)
no_progress_shortcut: true
---

# Result

Checkout `playtest/latest` @ `a041c697`. BuildStamp `a041c697*`. Same Brand New session as return-flow-v2. `user://` restored after Stop Play.

| id | verdict | note |
|----|---------|------|
| 01 | pass | Cabin after limp / before map: no `🧪 playtest/latest`, no `copy: swipe-player-copy-…`. BuildStamp SHA + Feedback visible. Music `music_cabin.ogg`. Shot: `01-cabin-no-chrome.png`. |
| 02 | pass | Grandpa's map after return: no Grant 3 / Fill / Fresh. Shot: `02-map-no-cheats.png`. |
| 03 | pass | First map→Verdant: intro at 0s, loop at 1s/3s/6s, cabin not playing. Second map→Verdant after cabin: loop already on at splash 0s, still `music_verdant_hollow_loop.ogg` at +1/+3/+6s, never `music_cabin`. Shot: `03-verdant-music.png`. Dump: `state/03-music.txt`. |
| 04 | fail | Physical F11 is eaten by the Godot editor (window fullscreen). Injected F11 also did nothing: `scripts/main.gd` gates `KEY_F11` behind `_authoring()`, so playtest F5 never toggles DevChrome. `DevBranchTag` is not attached in this F5. CopyStamp missing. Shot `04-f11-chrome-on.png` is combat **without** chrome (SHA + Feedback only) — the F11-on state could not be produced. Extra `09-combat-no-chrome.png` same. |
| 05 | fail | Never reached map-with-cheats. Cheats stay behind `DevChrome.on()`; F11 cannot turn that on in playtest F5. No `05-f11-map-cheats.png`. |

## Music (also `state/03-music.txt`)

First enter (Brand New, after first cabin, splash, paused=false, SHA a041c697*):

- 0s: MusicB playing `music_verdant_hollow_intro.ogg` vol=-4; MusicA `music_cabin.ogg` playing=false vol=-82
- 1s: MusicA playing `music_verdant_hollow_loop.ogg` vol=-4; intro stopped
- 3s / 6s: same loop; cabin never playing

Second enter (after limp + cabin rooms + map click):

- 0s splash: MusicA playing `music_verdant_hollow_loop.ogg` vol=-4; MusicB intro playing=false; paused=false
- +1s pos≈15.3s loop
- +3s pos≈23.8s loop
- +6s pos≈36.4s loop

Cabin bed after limp: `music_cabin.ogg`. Walking rooms did not restart a second cabin start (same stream stayed up).

## Blockers

- F11 DevChrome is authoring-only. Playtest F5 cannot show branch tag / copy stamp / map cheats with a real F11.
- Windows F11 hits the editor, not the game.

## Save restore

Same backup `_repot_backup_20261114_return_flow_v2`; hashes verified in the sibling RESULT.
