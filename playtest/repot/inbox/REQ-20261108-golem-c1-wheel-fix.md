---
id: REQ-20261108-golem-c1-wheel-fix
status: open
priority: high
pr: pending
tip_sha: b4d0eb8c
branch: playtest/latest
created: 2026-11-08T08:55:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → land a Golem seat (tutorial golem OK)
---

# Golem C1 wheel loader + 48n seat fix

Follow-up to #459 (C1 clay boulder). Wheel loader preferred armored `golem_wheel_idle_f0..f3`; C1 base/breathe were 24n and never reached. Live seats are now 48n facing copies (Weak/Tough → 96 on screen). Facing/slash were already C1.

## What to verify

- Wheel Golem is bare clay boulder + tiny dopey face — **no** armor/helmet/gold pauldrons.
- Seat reads at Weak/Tough size class (~96px on screen), not the old tiny 24n look.
- Facing idle and slash cut-in still C1 clay (unchanged intent).
- Juggernaut / shield reward untouched.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | dungeon wheel | Seat a Golem on the ring (tutorial or force) | Bare clay boulder, no armor; seat ~96px Weak class | 01-golem-wheel-clay.png |
| 02 | combat facing | Land / face Golem | Same clay design at 48 facing | 02-golem-facing-clay.png |
| 03 | slash cut-in | Trigger Golem slash portrait if reachable | Dopey clay head, no soldier armor | 03-golem-slash-clay.png |

## Pass criteria

- All rows shot at 1680×1040 (or note viewport).
- Shot 01 must not show the old blue/gold armored golem.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261108-golem-c1-wheel-fix/`
