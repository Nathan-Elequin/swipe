---
id: REQ-20261116-homecoming-haul
status: open
priority: high
tip_sha: pending
branch: cursor/homecoming-haul-model-90d6
created: 2026-11-16T22:30:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New (or wipe save) → clear Verdant → Crystal Cavern → return with uniques; no DevChrome / no cheat bank
---

# Homecoming haul model — Nib return lines + lever-ready

Return-from-dungeon haul counting and lever-ready detection now share one model (`Homecoming.build_haul`). Cloud cannot F5; local Cherry must confirm real-player acceptance.

## What to verify

- Fresh save (no middle progress, no dev bank cheats).
- Return with 0 new uniques (win): Nib `nib.board.empty.*`, no satchel.
- Loss return: Nib `nib.home.loss.*`.
- Return with several Crystal (b2) uniques: satchel unpack, count matches, all land on Crystal face.
- Mixed Verdant + Crystal haul: board order (Verdant first), then low→high rarity within a face.
- Fifth unique on Crystal: after last light, board slides to Crystal, lever READY FX, `nib.board.lever_ready.1` then `.2`. Log tip SHA + keys shown.
- Same fifth-light → lever-ready on Ashen (b3) and Cinder (b4) if reachable.
- Tokens / duplicates do not inflate the unpack count or light the wrong slot early.
- Slot never lit before the item lands; returns still land in the trophy hall first.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | fresh save, win return with 0 new | no satchel; Nib empty line | 01-empty-return.png |
| 02 | hall | return with 3+ Crystal uniques mid-unpack | satchel + fly to Crystal slots | 02-b2-unpack.png |
| 03 | hall | after 5th Crystal light | Crystal face, lever READY glow, lever_ready lines | 03-b2-lever-ready.png |

## Pass criteria

- All rows shot at 1680×1040 (or note viewport).
- RESULT.md lists tip SHA, dialogue keys observed, pass/fail per id.
- No DevChrome / cheat bank for the acceptance path.

## Outbox path

`playtest/repot/outbox/REQ-20261116-homecoming-haul/`
