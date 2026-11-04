---
id: REQ-20261104-fangs-t2-draft
status: open
priority: high
pr:
tip_sha:
branch: playtest/latest
created: 2026-11-04T19:10:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → road overlay → Yes (Nib tutorial) → play through Wizard/Shield/Golem/Take1 to B21
---

# Tutorial Slice C — Fangs as real Tier-2 draft

Cloud agent cannot F5. Cherry: Brand New → Yes through Golem clear on this PR branch (or `playtest/latest` after merge).

## What to verify

- After Golem leaves and Shark walks in / deck empty, **no** auto-grant of Fangs into the hotbar.
- B21.2 shows a draft UI like the Shield draft with **two different Tier-2 items**.
- Correct pick = **Fangs**; decoy = **Crossbow**.
- Draft subtitle shows **Tier 2** (not Tier 1).
- Prompt says **Take the Fangs.** Wrong pick nudges + error SFX and stays on the draft until Fangs.
- Correct pick plays take/commit SFX (confirm + cloth + chal.commit) and advances; only Fangs advances the rail.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | road combat | Brand New → Yes → past Take 1 / B21.1 Continue | Shark seated; draft open with Fangs + Crossbow; subtitle Tier 2; Fangs not yet in hotbar | 01-fangs-t2-draft.png |
| 02 | road combat | Same beat; click Crossbow first | Nudge / still on draft; Fangs still not committed | 02-crossbow-nudge.png |
| 03 | road combat | Click Fangs | Draft closes; Fangs in hotbar; rail advances past B21.2 | 03-fangs-taken.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Crossbow is never force-granted; Flail/Knucklers/Arrow Head/Boot/Breastplate/Shield/Sai are not the decoy.

## Outbox path

`playtest/repot/outbox/REQ-20261104-fangs-t2-draft/`
