---
id: REQ-20261116-hotbar-new-star-size
status: done
priority: high
tip_sha: 2d9af6f4
branch: cursor/hotbar-new-star-size-4b54
created: 2026-11-16T23:20:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Brand New → skip intro / reach a fight with unclaimed uniques in the hotbar
---

# Hotbar NewStar size — PanelContainer stretch fix

Cloud ship: `set_new_star` no longer parents the 28×28 TextureRect on the PanelContainer root (that stretched it to the full card art). Star lives under `NewStarHolder`; position recomputed after layout with stylebox margin inset. Headless selftest asserts size/corner after process frames. Cloud cannot F5 — local Cherry shots required.

## What to verify

- Unclaimed unique in the hotbar: gold `new_star` is a **small** 28×28 mark at the top-right corner of the plate (slight overhang ~4 px), both between fights and mid-fight.
- The star must **not** cover the item art / icon center (the bug was a giant pixel star filling the whole card).
- Claimed unique / Toll / Token-pool cards still show no star.
- Chrome hatch / hotbar panel do not clip the corner overhang.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | Brand New, unclaimed unique in hotbar (mid-fight OK) | NewStar tiny top-right; icon art fully readable | 01-new-star-corner.png |
| 02 | ready | same seat after claim (or Continue with that id banked) | NewStar gone | 02-star-cleared.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Optional: compare to headless proof under `playtest/repot/outbox/REQ-20261116-hotbar-new-star-size/shots/01-new-star-corner.png` (card row only, not full HUD).

## Outbox path

`playtest/repot/outbox/REQ-20261116-hotbar-new-star-size/`
