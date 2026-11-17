---
id: REQ-20261117-juggernaut-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-17T00:20:00-06:00
machine: Cherry
tip_sha: f1b0fdb89ba12c2727a2cbb744fd45ecd18d39de
requested_tip_sha: 2343f3e6
godot: F5 playtest, godot-mcp Viewport.push_input + injected keys only
viewport: game window 1680x1040; MCP screenshot_game returned 1024x632
---

# Result

Checkout started at `2343f3e6` (Juggernaut A merge). During the shoot HEAD moved to `f1b0fdb8` (`Keep hovered pool-unlock cards in color.`), which still contains the A art. On-screen BuildStamp was `2343f3e6*` then `f1b0fdb8*`.

Input: godot-mcp `Viewport.push_input` mouse clicks and `godot_input` keys (Space, Enter, Escape). No computer-use, no `_dev_*`, Grant, DevChrome, or seeded seating.

Fresh `user://` wipe (backup `_repot_backup_20261117_juggernaut_A`, restored after Stop). Path: Skip intro → Crystal Cavern commitment → **Middle Progress** → Verdant `LaunchHit_start`. Re-rolls used the same Middle Progress / Continue flow.

## Attempts (Juggernaut never seated)

1. Middle Progress Verdant — wheel included **Ogre** (plus Wizard/Needleback/Goblin/Hornet/Eel). Did not freeze a native shot before the fight moved on.
2. Middle Progress Verdant — wheel **Eel / Golem / Wizard / Dragon / Dire Wolf / Hornet**. Faced **Golem**. MCP shot 1024×632 (not 1680×1040).
3. Give up → pause menu; later limp-home left `SceneTree.paused` true (recovered once by clearing pause so the cabin could move).
4–6. Middle Progress / Continue Verdant — **same** `next_run` seed `3614571837`. Deal ids for b1–b5 **do not include `juggernaut`**. Repeated first-six: `eel, dire_wolf, needleback, slime_boss, hornet_swarm, mimic`.

Juggernaut A textures on disk (not loaded in a fight this session):  
`res://assets/dungeon/extra/juggernaut.png`,  
`res://assets/dungeon/anim/wheel/juggernaut_wheel_idle_f0.png`–`f3`,  
`res://assets/dungeon/anim/facing/juggernaut_facing_idle_f0.png`–`f3`,  
`res://assets/dungeon/anim/slash/juggernaut_slash_f0.png`–`f3` + `juggernaut_slash_base.png`.

Music in Verdant fight: `res://assets/audio/music_verdant_hollow_loop.ogg`.  
`SceneTree.paused`: false in ready/fighting; true on intro, commitment, pause, and stuck limp-home.  
Dialogue keys: playtest intro Skip; commitment “How far do you want to go?”; biome splash Verdant Hollow “click anytime”. No Juggernaut callout keys.

| id | verdict | note |
|----|---------|------|
| 01 | fail | Never seated Juggernaut after 6 real Middle Progress / Continue Verdant attempts. Seeded b1–b5 deals omit `juggernaut`. No `01-juggernaut-wheel-idle.png`. |
| 02 | fail | Right-side callout never showed Juggernaut. No `02-juggernaut-callout.png`. |
| 03 | fail | Slash cut-in never played for Juggernaut. No `03-juggernaut-slash.png`. |
| 04 | fail | `extra/juggernaut.png` never on screen (journal Journal node was off-screen in another cabin room). No `04-juggernaut-extra.png`. |

## Blockers

- Middle Progress `next_run` deals for this seed have no Juggernaut on any biome, so re-rolling Verdant repeats the same mill.
- Limp home / Give up left `SceneTree.paused` true (same as earlier real-playthrough QA).
- `godot_exec` cannot `DirAccess`/`save_png` to the outbox; MCP `screenshot_game` stored a 1024×632 attachment, not 1680×1040.

## Shots

None under `shots/` (rows unmet).
