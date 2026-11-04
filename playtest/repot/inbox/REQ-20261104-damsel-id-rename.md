---
id: REQ-20261104-damsel-id-rename
status: open
priority: normal
branch: playtest/latest
created: 2026-11-04T19:45:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Brand New → fight until Damsel in Distress faces you (or Roster / content board peek)
---

# Damsel id rename (`damsel_in_distress`)

Catalog/script id renamed to `damsel_in_distress` (see `docs/migrations/2026-11-04-damsel-in-distress-id.md`). Same stats and ability. Art still uses `assets/dungeon/extra/damsel.png`; anim/SFX files were renamed to the new id. No balance changes.

## What to verify

- Damsel in Distress still appears in the mill / on the wheel with the damsel sprite (not missing art).
- Facing idle / slash / wheel breathe still play (paths now use `damsel_in_distress_*`).
- Ability still runs: neighbors attack left then right, then Heal 3.
- Inspect / Shift / call name still read Damsel (not “Two-Headed Serpent”).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat wheel | face Damsel in Distress | damsel sprite on facing seat; name plate says Damsel in Distress | 01-damsel-facing.png |
| 02 | combat | trigger her ability (Done with neighbors alive) | neighbors swing, then Heal 3; no missing slash frames | 02-damsel-ability.png |

## Pass criteria

- Both shots at 1680×1040.
- No missing-texture / pink fallback on Damsel.
- Log / plate still show Damsel in Distress, not Two-Headed Serpent.

## Outbox path

`playtest/repot/outbox/REQ-20261104-damsel-id-rename/`
