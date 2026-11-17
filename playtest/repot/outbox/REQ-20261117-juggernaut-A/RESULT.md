---
id: REQ-20261117-juggernaut-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-17T01:10:00-06:00
machine: Cherry
tip_sha: 75e83ad39d321f22e9fae01cdc3f1b512bede64d
requested_tip_sha: c78a64fe
godot: F5 playtest, godot-mcp Viewport.push_input + injected keys only
viewport: game window 1680x1040; no fight shots (Juggernaut never dealt)
---

# Result

Checkout `playtest/latest` @ `75e83ad3`. Input: godot-mcp `Viewport.push_input` only. No computer-use, `_dev_*`, Grant, DevChrome, seeded seating, or forced poses.

Retry note followed: **wiped `user://` JSON before every re-roll** (backup `_repot_backup_20261117_title_juggernaut`, SHA256 restored after Stop). Each attempt: Skip intro → living-trophy **Middle Progress** → map / `campaign_save.json` `next_run`.

Juggernaut A textures on disk (not loaded in a fight this drain):  
`res://assets/dungeon/extra/juggernaut.png`,  
`res://assets/dungeon/anim/wheel/juggernaut_wheel_idle_f0.png`–`f3`,  
`res://assets/dungeon/anim/facing/juggernaut_facing_idle_f0.png`–`f3`,  
`res://assets/dungeon/anim/slash/juggernaut_slash_f0.png`–`f3` + `juggernaut_slash_base.png`.

Music: title `res://assets/audio/music_title.ogg` on hub; no Verdant fight this REQ.
`SceneTree.paused`: true on intro/title; false on the Middle Progress map. Did not Give up / limp home this drain, so no pause-stuck observation.
Dialogue keys: playtest intro Skip; no Juggernaut callout.

## Attempts (fresh save each time; Juggernaut never in next_run deals)

Cap 15. Stopped after **4** independent seeds because all five biome deals (50 ids/attempt) omitted `juggernaut` every time — he is not in this mill, so further rerolls will not seat him.

1. seed `823658030` — b1 `dire_wolf,eel,slime_boss,wizard,ogre,needleback,goblin,berserker,golem,hornet_swarm`; b2 `eel,dragon,mimic,berserker,hornet_swarm,golem,wizard,dire_wolf,goblin,vampire`; b3–b5 no juggernaut.
2. seed `34949597` — b1 `needleback,golem,eel,hornet_swarm,goblin,ogre,vampire,berserker,wizard,mimic`; b2 `dragon,berserker,needleback,golem,mimic,eel,goblin,hornet_swarm,wizard,slime_boss`; b3–b5 no juggernaut.
3. seed `72592983` — b1 `dire_wolf,golem,ogre,goblin,slime_boss,eel,mimic,hornet_swarm,wizard,berserker`; b2 `wizard,vampire,goblin,ogre,needleback,hornet_swarm,golem,mimic,dragon,eel`; b3–b5 no juggernaut.
4. seed `4095188532` — b1 `hornet_swarm,wizard,golem,eel,mimic,berserker,goblin,slime_boss,needleback,dire_wolf`; b2 `dragon,goblin,vampire,eel,wizard,golem,needleback,ogre,berserker,hornet_swarm`; b3–b5 no juggernaut.

| id | verdict | note |
|----|---------|------|
| 01 | fail | Never seated. No `01-juggernaut-wheel-idle.png`. |
| 02 | fail | Callout never showed Juggernaut. No `02-juggernaut-callout.png`. |
| 03 | fail | Slash never played. No `03-juggernaut-slash.png`. |
| 04 | fail | `extra/juggernaut.png` never on screen. No `04-juggernaut-extra.png`. |

## Blockers

- Campaign `next_run` mill (Middle Progress, buckets 3) never deals `juggernaut` across four fresh seeds / 200 seat ids. Catalog `pool` is 2.0; campaign deals repeatedly use goblin/eel/golem/wizard/ogre/berserker/mimic/hornet/needleback/dire_wolf plus dragon/vampire/slime_boss.
- Did not spend the remaining 11 of 15 once that pattern was clear.

## Shots

None under `shots/` (rows unmet). Diagnostic `_hub.png` not part of the table.
