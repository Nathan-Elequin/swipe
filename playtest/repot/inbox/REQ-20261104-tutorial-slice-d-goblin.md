---
id: REQ-20261104-tutorial-slice-d-goblin
status: open
priority: high
pr: 387
tip_sha: b9f1e97653a2
branch: playtest/latest
created: 2026-11-04T19:15:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → road overlay → Yes (Nib tutorial) → play to Goblin choice (B26)
---

# Tutorial Slice D — Goblin Boot | Breastplate | Take 3 converge

Cloud agent cannot F5. Cherry: Brand New → Yes, try each Goblin choice once on this PR branch (or after merge to `playtest/latest`).

## What to verify

- At Goblin choice (after Boot / Breastplate teach lines): **only Boot, Breastplate, and Take** are legal. Shield is nudged off ("Not the Shield…"); no Shield spotlight.
- Boot teach line shows Boot with an arrow; "block some of his damage" spotlights **Breastplate only**; "The choice is yours." opens Boot + Breastplate + Take.
- **Boot path:** Boot spends, Goblin defeated, no HP loss; B27a lines; Shield still unused; then Shark/Fangs → Harpy A → Dragon → Move → Harpy B Shield → Flail Dragon.
- **Breastplate path:** Block 2 of Goblin's 3 → Take 1 HP; Breastplate Keeps; B27c lines (not Take/Flail copy); no `tut.hint` crash; "(click Take)" nudge shows; same spine converge; Shield unused into Harpy B.
- **Take 3 path:** take full hit; B27b Ow/Flail lines; same spine converge; Shield unused.
- Arrow Head still from start; Flail usable on Dragon on all three paths (matrix: Flail ≥ 6).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | road combat | Brand New → Yes → Goblin B26.1 | Breastplate spotlight only; block-some-damage line | 01-goblin-breastplate-spotlight.png |
| 02 | road combat | Advance to B26.2 choice | Boot + Breastplate + Take highlighted; Shield not spotlighted | 02-goblin-choice-three.png |
| 03 | road combat | Choice → Boot | Goblin defeated; Boot spent; B27a / no HP loss from Goblin | 03-path-boot.png |
| 04 | road combat | Choice → Breastplate → Take | Took 1 HP; Keep on Breastplate; B27c copy; no crash | 04-path-breastplate.png |
| 05 | road combat | Choice → Take only | Took 3; B27b Ow / Flail lines | 05-path-take3.png |
| 06 | road combat | Any path → Harpy B after Move | Shield still available (saved); ensure teach works | 06-converge-harpy-b-shield.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- Each of the three Goblin choices completes without debugger break / soft-lock.
- After B27*, Shark/Fangs teach and rest of spine run for all three.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261104-tutorial-slice-d-goblin/`
