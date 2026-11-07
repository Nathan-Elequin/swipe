---
id: REQ-20261106-title-framed-B
status: open
priority: high
pr: 440
tip_sha: 050c9cf8
branch: cursor/title-framed-b-9249
created: 2026-11-07T00:10:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub boot (framed title B — quiet #15120f, cabin left, menu right)
---

# Title framed B (approved)

Nathan approved final mockup B. Cloud ship cannot F5 / godot-mcp. Cherry must capture **actual Godot runtime** screenshots (not the Doop study PNG, not a contact sheet) and write RESULT.

Approved reference (art/layout target, not a runtime pass): `design/visual/mockups/study-B-1680x1040.png`.
Implementation doc: `design/visual/SCREEN-title-framed.md`.

## What to verify

- Quiet opaque ground `#15120f`; compact framed cabin LEFT; live **Spinheritance** + menu RIGHT.
- Cabin uses `assets/ui/title/cabin-vignette-native.png` at exact 2× 680×440 nearest inside frame bbox ~162,300,688,448 at 1680×1040.
- Selection is flat warm fill + left gold stripe + small triangle — **not** giant gold-bordered rectangles.
- No controls over the image; no floating logo/tagline/extra props.
- Copy exact: Brand New / Start from scratch.; Middle Progress / A few dungeons in.; Continue / Last save.; Feedback.
- Brand New / Middle Progress / Continue / Feedback still route (do **not** delete saves while testing Continue).
- Keyboard/controller focus loop includes Feedback; focused row shows selection; bounds do not jump.
- Continue only when a save exists (unchanged availability).
- Readable at 1680×1040, 1920×1080, and 1280×720 (B retained when readable; deliberate compact reflow only if needed). Art never nonuniform-scaled.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | title | F5 boot hub @ 1680×1040, Brand New focused | Matches study B within reason; framed cabin left; title+3 rows+Feedback right; quiet surround | 01-hub-1680x1040.png |
| 02 | title | Same, Arrow-down to Middle Progress | Selection moves; warm fill+stripe+triangle on Middle; Brand New idle | 02-focus-middle.png |
| 03 | title | Focus Feedback via keyboard/controller | Feedback in loop; outline/bright text; no layout shift | 03-focus-feedback.png |
| 04 | title | Viewport 1920×1080 | B composition centered; quiet surround; no clip; art still 2× nearest | 04-hub-1920x1080.png |
| 05 | title | Viewport 1280×720 | Readable helpers; B if fit else compact vertical reflow; all actions present | 05-hub-1280x720.png |
| 06 | title | Continue visible with a real save present | Continue row shown; activating loads save (do not wipe) | 06-continue-available.png |
| 07 | title | Fresh profile / no save if easy | Continue hidden; focus skips it Brand New→Middle→Feedback | 07-continue-hidden.png |

## Pass criteria

- Shots are **Godot runtime** PNGs under `playtest/repot/outbox/REQ-20261106-title-framed-B/shots/`.
- Each `expect` readable without guessing.
- Do **not** mark this request `done` from cloud.
- Do **not** treat the approved study PNG or an HTML contact sheet as a runtime pass.

## Outbox path

`playtest/repot/outbox/REQ-20261106-title-framed-B/`
