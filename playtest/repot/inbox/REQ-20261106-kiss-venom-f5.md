---
id: REQ-20261106-kiss-venom-f5
status: open
priority: high
branch: playtest/latest
created: 2026-11-06T20:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New or Middle Progress → unlock pools → dungeon draft / combat
---

# Kiss of Death + Venom Veins mill + combat

Runtime mill sync so Kiss/Veins draft; Kiss usable with random 4 Poison + Lifelink; Veins HP-loss → +1 Poison + Mark-3 Poison Flask.

## What to verify

- With all cabinets unlocked, Kiss of Death and Venom Veins appear as draft options (they were missing from `data/runtime.json`, not gated by `flags.dev`).
- Kiss of Death is clickable in a fight (`can_use`); random living enemy gets 4 Poison and Lifelink (Wraith peer on Defeat).
- Venom Veins stays unplayable; each player HP loss grants 1 player Poison and a hand Poison Flask pre-marked at 3 (same poison_flask art).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat draft | pools unlocked, draft gate open | Kiss of Death and/or Venom Veins visible as a draft option at least once across rolls | 01-draft-kiss-or-veins.png |
| 02 | combat | Kiss in hand, living enemies on wheel | Kiss playable; after use one enemy shows Poison 4 and Lifelink call | 02-kiss-used.png |
| 03 | combat | Venom Veins in hand; take HP damage | Player Poison +1 and a Mark-3 Poison Flask appear in hand | 03-veins-flask.png |

## Pass criteria

- All rows shot at 1680×1040 (or note viewport).
- Each expect readable without guessing.
- `RESULT.md` marks each id pass/fail.

## Outbox path

`playtest/repot/outbox/REQ-20261106-kiss-venom-f5/`
