---
id: REQ-20261104-tutorial-noon-engine
status: open
priority: high
branch: cursor/tutorial-noon-engine-bugs-faa4
tip_sha: 4e318148
created: 2026-11-04T19:10:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → Yes (tip tutorial)
---

# Tutorial noon engine bugs (Slice A)

Cloud ship — cannot F5 here. Cherry: Brand New → Yes on this branch tip. Engine fixes only (no Nib copy rewrite, no Fangs draft redesign, no Goblin Breastplate branch rails beyond the crash stop).

## What to verify

- Sai teach (B10.2) and Breastplate teach (B15.1–2): spotlight/arrow OK; hotbar cards stay in the normal static look until the player actually hovers (no inverted/formula/fly-tip fake hover).
- Shield draft take (B12.2): plays the same take/commit SFX as core gameplay (confirm + cloth + chal.commit), not silent.
- Goblin choice after Breastplate or Shield: no runtime crash on hint; Take prompt advances (nudge shows “(click Take)”).
- Continue beats (e.g. B15.1 Breastplate intro): Next is visible and clickable after type finishes; Space still works.
- Item / Take / choice / draft beats still hide Next and require the action.
- Optional: if Breastplate is missing/spent on `item:breastplate`, rails re-grant/unspend so the beat is not soft-locked.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | tip fight | Brand New→Yes → land Wizard → advance to Sai “Click it” (B10.2); do not mouse the hotbar | Sai spotlight/arrow only; other hotbar cards static (no formula/fly tip open) | 01-sai-no-false-hover.png |
| 02 | tip fight | Advance to Breastplate continue line (B15.1); do not mouse the card | Next visible/clickable; Breastplate not fake-hovered | 02-breastplate-continue-next.png |
| 03 | tip draft | Golem shield draft — take Shield | Take SFX audible (confirm/cloth/commit); Shield lands in hotbar | 03-shield-take-sfx.png |

## Pass criteria

- Shots at 1680×1040 when possible.
- 01–02: no fly-tip / formula chrome without a real mouse hover.
- 02: Next click advances (not only Space).
- 03: note in RESULT whether take SFX played (audio may not show in PNG).
- Goblin Breastplate/Shield crash: if time, play to Goblin choice, use Breastplate, confirm no debugger break and Take is armed.

## Outbox path

`playtest/repot/outbox/REQ-20261104-tutorial-noon-engine/`
