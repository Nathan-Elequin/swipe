---
id: REQ-20261114-today-audit
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T00:30:00-06:00
machine: Cherry
tip_sha: pending-commit
godot: F5 playtest via godot-mcp, viewport forced 1680x1040
branch: playtest/latest
---

# Result

Evidence only. Nathan's `user://` JSON was copied to `_repot_backup_20261114_today_audit` then restored (SHA match). Cabin `_persist_writes=false` during poses.

Hooks: `rope_exit.open_exit` / `apply_exit_mode`, `debug_pose(walk|hall)`, `play_key_ring`, `Homecoming._run`, bank 4–5 via `TrophyBoardModel.face_ids_flat` + `campaign.state.banked`, `BoardSequences.portal(0)`, `ability_slash.play`, `biome_splash.play_in`, `rope_exit._do_climb`.

| id | verdict | note |
|----|---------|------|
| A01 | fail | Climb burst overlapped leftover biome splash (Shadow Abyss card), not the ladder wipe. Hall later shows Developer Test strip. Exterior walk stills are under A01-walk_* / ladder-wipe. |
| A02 | captured | Keyring burst `A02-keyring_f00–f07`; music key `cabin` throughout. |
| A03 | captured | NibSprite (1408, 688) z=8 vs board (176,40)–(1504,816). Reads small, stands in front of the board. See `audit/A03-state.txt`. |
| A04 | captured | Empty-intent burst still showed unpack line (“Okay, let's see what you br”) because pending items were already on the board. Unpack burst `A04-unpack_f*`. |
| A05 | blocked | Did not isolate hover pulse vs after-hover; no dedicated pair. |
| A06 | captured | First-light Nib line on `A08-lights-5of5.png` (“That light up top just came on”). Nib is on the right; no arrow. Lever glow visible by Nib. |
| A07 | blocked | Did not click a slot then move off; popup linger not timed. |
| A08 | captured | `A08-lights-4of5.png` and `A08-lights-5of5.png`. Five-light shot shows extra claimed slots + first-light dialog. |
| A09 | captured | Burst `A09-lever-splash_f00–f15`. Music key stayed `cabin` (Crystal Cavern bed did not start). See `audit/A09-state.txt`. |
| A10 | captured | After hiding splash, screen is black (`A10-fade-cover.png`) with `playtest.latest` still visible. Covering node: `/root/Main/CabinRoot/@ColorRect@990` ColorRect `#0B0706` z=200 a=1.0 from `BoardSequences._fade`. Also CabinRoot itself is opaque black z=95. |
| A11 | captured | One still each: verdant, crystal, ashen, cinder, shadow. Hi-res painterly splash plates. |
| A12 | captured | 0 / 1 / 2 / 3+ carried stills. Dead portal + satchel_floor peeks + strip stars on 2-carried (`flow-overhaul/01`). |
| A13 | captured | 8-frame fizzle burst. Climb remained available (no blocking choice). |
| A14 | captured | Hotbar still + 6-frame sheen burst. Combat overlay was not on those frames (map/cabin contamination risk on later A14-hotbar-unseen). |
| A15 | fail | Wheel idle/spin shots are the held map, not the wheel. Slash cut-in did fire over the map: blond hair + blue heater readable (`juggernaut-B/04`). Extra still is the same slash, not `extra/juggernaut.png` full-body. |
| A16 | captured | Hall board stills show claimed gold frames, silhouette unseen slots, and mixed mid-row. Close crop not separate. |
| A17 | captured | Developer Test strip on trophy hall. Nib scale. Black fade after portal. Music stays cabin through Crystal splash. |

## Blockers

A05 and A07 need a live hover/click on a placed slot; MCP has no absolute mouse, and warp was not completed before Stop.

## Shots

`shots/` at 1680×1040. Per-row dumps under `audit/` (A03, A09, A10 plus this RESULT).
