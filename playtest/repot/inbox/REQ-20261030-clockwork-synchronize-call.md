---
id: REQ-20261030-clockwork-synchronize-call
status: open
priority: normal
branch: playtest/latest
created: 2026-10-30T22:05:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → Adventure fight with Clockwork Knight on the wheel
---

# REQ-20261030-clockwork-synchronize-call

**Screen:** Combat wheel monster callout / inspect for Clockwork Knight  
**What shipped:** Restore Synchronize on `clockwork_knight` in `data/catalog.json` after Cherry commit `c99b58c6` stomped it back to Disassemble. Fields match `4490d8ff` / tip content-board (call name Synchronize, 5 HP / 4 Attack, neighbor match rule). No combat-logic changes — `_clockwork_synchronize` already live.  
**Viewport:** 1680×1040 · Nearest · no invented copy

## Outbox
`playtest/repot/outbox/REQ-20261030-clockwork-synchronize-call/shots/`

## What to verify

- Clockwork Knight seat call / inspect reads **Synchronize**, not Disassemble.
- Ability line matches: neighbors gain HP until equal, then Attack until equal (on Defeat).
- Plate numbers show 5 HP / 4 Attack (not the old Disassemble 7 HP split).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Clockwork Knight active / inspect or callout visible | Call name reads Synchronize (not Disassemble) | 01-clockwork-synchronize-call.png |

## Pass criteria

- PNG at 1680×1040.
- 01: visible call name Synchronize on Clockwork Knight.

## Copy / gameplay

Catalog/board restore only. No main.gd Synchronize logic edits in this PR.
