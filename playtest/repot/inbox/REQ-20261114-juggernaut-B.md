---
id: REQ-20261114-juggernaut-B
status: open
priority: high
tip_sha: 8858ddc3
branch: cursor/juggernaut-b-art-4ea0
created: 2026-11-14T05:05:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → seat Juggernaut on the wheel (force or Challenge) → Spin to face
---

# Juggernaut B art swap (blond jock + blue heater)

Nathan locked Juggernaut monster art B. Cloud replaced the 17 tip PNG paths under `assets/dungeon/` (extra, facing idle f0–f3, slash base+f0–f3, wheel base/idle/breathe). Art only — no stats, abilities, or copy changes. Existing `.import` kept (Nearest via project default, no mipmaps). Cloud headless proof shot exists at agent artifacts; Cherry must capture **actual Godot MCP / F5 runtime** shots.

## What to verify

- Wheel seat + idle: blond hair, human face, blue heater shield read clearly at Tough seat size.
- Facing idle: same read at 64 facing — face, hair, blue heater (not old grey plate armor).
- Slash portrait: upper-body punch-in still shows blond jock + blue heater.
- Extra / bestiary still (`assets/dungeon/extra/juggernaut.png`): full-body vertical still matches B.
- No other monster art changed.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon wheel | Juggernaut on a wheel seat during / just after spin | Blond hair + blue heater readable on seat | 01-juggernaut-wheel-spin.png |
| 02 | dungeon wheel | Same seat idle (not spinning) | Idle breathe/idle frames still B art | 02-juggernaut-wheel-idle.png |
| 03 | combat facing | Land / face Juggernaut | Facing idle: face, hair, blue heater clear | 03-juggernaut-facing-idle.png |
| 04 | slash cut-in | Trigger Juggernaut slash portrait | Slash plate is B (not old grey armor) | 04-juggernaut-slash.png |
| 05 | bestiary / extra | Open bestiary or inspect still that uses `extra/juggernaut.png` | Tall still matches B | 05-juggernaut-extra-still.png |

## Pass criteria

- All rows shot at 1680×1040 (or note viewport).
- Face, hair, and blue heater are readable without guessing in 01–05.
- Old tip grey plate / bucket-helm Juggernaut must not appear.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261114-juggernaut-B/`
