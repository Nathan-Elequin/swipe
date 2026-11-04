---
id: REQ-20261104-monster-atk-delta-sfx
status: open
priority: normal
tip_sha: a646a023
branch: cursor/monster-atk-delta-sfx-5b67
created: 2026-11-04T18:24:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → any fight with a monster that gains or loses Attack (Bandit echo, Sandbag cool-down, Commander buff, Vampire grow, etc.)
---

# Monster Attack delta SFX ≠ HP ticks

Live courier path `_play_stat_pulse` used to play `mon.leech_pulse` for both HP and ATK (pitch-only difference). ATK gain/loss now uses `wheel.num_tick_atk_up` / `wheel.num_tick_atk_down` → `pluck.wav` (pitch up / pitch down). HP still uses `mon.leech_pulse` with the same pitches as before. Wheel number-tick signals also use the new ATK keys; `wheel.num_tick_hp` still → `ui_tick`.

## What to verify

- Spawn or fight a monster that **gains** Attack: hear a short pluck pitched up — not the wet leech/HP pulse.
- Same (or another) monster **loses** Attack: hear the same pluck sample pitched down — still not the HP pulse.
- Heal or hurt a monster's **HP** via the courier heart: still the familiar `mon.leech_pulse` (unchanged).
- Player heal / player HP SFX unchanged (`heal.gain` path).

## Screenshots required

none — audio-only; verify by listening in F5.

## Pass criteria

- ATK up and ATK down are audibly different from each other (pitch) and from HP ticks (base sample).
- HP courier pulse still sounds like pre-change leech pulse.
- `RESULT.md` marks listen checks pass/fail with one line each; stamp tip_sha.
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261104-monster-atk-delta-sfx/`
