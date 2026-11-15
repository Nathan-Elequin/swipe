---
id: REQ-20261115-tier-unpack-curtain
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T19:55:00-06:00
machine: Cherry
tip_sha: 8054461e6812ddec4431ae38885dc58c591a3fe1
godot: F5 playtest, real mouse (Viewport.push_input) + keyboard. No _dev_*, no Grant/Fill, no selftest, no frozen launch.
viewport_grab: 1550x960 window (logical layout 1680x1040)
no_progress_shortcut: true
---

# Result

Checkout `playtest/latest` @ `8054461e`. On-screen BuildStamp `8054461e*`. Brand New from a fresh save (playtest hub). `user://` was backed up to `_repot_backup_20261115_tier_unpack_curtain` and restored after the shoot.

Walked: playtest letter Skip → Brand New → intro Skip → tutorial Skip → Onward → cabin → Grandpa's map → LaunchHit_start (Verdant Hollow only; did not click Grant/Fill). Two real delves died before Rope Leave (Ogre Empath / Dire Wolf Kill Shot at 1 HP). Limp home empty-handed. Trophy hall satchel ceremony skipped (Nib: “Empty-handed?”). Then Crystal Cavern locked face for curtain shots.

| id | verdict | note |
|----|---------|------|
| 01 | fail | No mixed-metal unpack. Bank pending stayed `[]`. Shot is post-limp **Verdant Hollow** with silhouettes on empty plinths, lights `light_off.png`, auras hidden. No board-order fly, no bronze→silver→gold landings. `01-unpack-sequence.png`. |
| 02 | fail | Never reached a gold mid-swell. No item left the satchel. File is the same empty Verdant board (`02-gold-mid-swell.png`). |
| 03 | fail | No claimed bronze/silver/gold plinths or looping auras. Every slot `plinth_empty.png`, `Aura.visible=false`. `03-claimed-metals.png`. |
| 04 | pass | Crystal Cavern locked face: velvet curtain over the slot field (modulate alpha **0.82**), padlock in front, title placard **CRYSTAL CAVERN** and side arrows readable, biome dots visible, Nib dismissed. `04-locked-curtain.png`. |
| 05 | pass | Clicked the curtain (real mouse event). `locked_cues` = `cabin.locked`, `locked_click_count` = 1, one-shot `res://assets/audio/cab_locked.ogg`. Grab during jiggle/padlock nudge. Hover tip stayed (“Five different finds from Verdant Hollow”). Spam rate-limit 0.45s. `05-locked-jiggle.png`. |

## Slot lights / rumble

- Slot lights stayed `res://assets/ui/trophy_board/light_off.png` on every face (nothing landed, so nothing lit early).
- No rumble / shake loop in the playing AudioStreamPlayer list at any hall sample.

## Loaded texture paths (KIT.ui_tex)

- `res://assets/ui/trophy/plinth_claimed_bronze.png`
- `res://assets/ui/trophy/plinth_claimed_silver.png`
- `res://assets/ui/trophy/plinth_claimed_gold.png`
- `res://assets/ui/trophy/plinth_empty.png` (what the player actually saw)
- `res://assets/ui/trophy_board/aura_claimed_bronze_f0.png`
- `res://assets/ui/trophy_board/aura_claimed_silver_f0.png`
- `res://assets/ui/trophy_board/aura_claimed_gold_f0.png`
- `res://assets/ui/trophy_board/land_bronze_f0.png`
- `res://assets/ui/trophy_board/land_silver_f0.png`
- `res://assets/ui/trophy_board/land_gold_f0.png`
- `res://assets/ui/trophy_board/swoosh_bronze.png`
- `res://assets/ui/trophy_board/swoosh_silver.png`
- `res://assets/ui/trophy_board/swoosh_gold.png`
- `res://assets/ui/trophy_board/curtain_drape.png`
- `res://assets/ui/trophy_board/curtain_sway_f0.png`
- `res://assets/ui/trophy_board/curtain_jiggle_f0.png`

## Music / audio (hall, Crystal face)

- `res://assets/audio/music_cabin.ogg` (Music)
- `res://assets/audio/cabin_fire_loop.ogg` (Ambience)
- `res://assets/audio/cabin_cat_purr_loop.ogg` (Ambience)
- On locked click only: `res://assets/audio/cab_locked.ogg` (one shot)
- No persistent rumble loop

## Blockers

- Real Brand New path never extracted with loot, so the metal unpack sequence (board order, gold swell, claimed plinths/auras) could not play without Grant/Fill or a selftest. Those were disallowed.
- Game window grab 1550×960; content layout 1680×1040.

## Save restore

Backup `%APPDATA%\Godot\app_userdata\Spinheritance\_repot_backup_20261115_tier_unpack_curtain`. Restored after Stop Play.
