---
id: REQ-20261114-trophy-board-feedback-2
status: open
priority: high
tip_sha: da66c5ab
branch: cursor/trophy-board-feedback-2-1592
created: 2026-11-14T03:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Continue / Middle Progress → walk right into trophy hall
---

# Trophy board feedback-2 (Fix A + painted placards + depth)

Cloud ship of the trophy-feedback-2 kit with Nathan's mock review on top: VGAP 24, thinned-lip face BGs, oak recess filled, lights/lever +24 px, rematted ~160 px placards (LINEAR), hall depth layers (wall wash, drop shadow, floor shadow/pool, oak stand).

Headless composites are under `design/visual/trophy-board/feedback-2-shots/`. Local F5 shots should confirm the live Godot view matches.

## What to verify

- Painted placard reads clearly (~160 px tall), no empty plaque recess behind it, LINEAR soft edges.
- Lights and lever sit 24 px lower; ≥16 px gap from lights to the top pyramid row.
- Pyramid VGAP is 24 (tighter than the old 40).
- Face backdrop lip is the thinned 24 px themed lip (corner tufts only).
- Depth layers read: wall drop shadow, warm shaft, oak stand with brass feet, floor contact shadow + warm pool (feet not hidden by dots/rug).
- Face name comes from the painted placard only (no EB Garamond label). Hover/tooltip still has `face.name`.
- No Tier / ATK shown. Gameplay unchanged.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | hall | face b1 Verdant Hollow | painted placard, no recess, lights clear of sign, stand feet visible | 01-b1-verdant.png |
| 02 | hall | slide to b2 Crystal Cavern | placard recentred, crystal lip, depth still readable | 02-b2-crystal.png |
| 03 | hall | slide to b3 Ashen Crypt | same chrome; ashen placard | 03-b3-ashen.png |
| 04 | hall | slide to b4 Cinder Forge | same chrome; cinder placard | 04-b4-cinder.png |
| 05 | hall | slide to b5 Shadow Abyss | same chrome; shadow placard; stand/shadow clear of rug | 05-b5-shadow.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261114-trophy-board-feedback-2/`
