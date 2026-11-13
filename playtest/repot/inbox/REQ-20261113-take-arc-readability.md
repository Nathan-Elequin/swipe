---
id: REQ-20261113-take-arc-readability
status: open
priority: high
branch: playtest/latest
created: 2026-11-13T20:10:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → enter a fight with Block available and net Take > 0
---

# Take arc readability (arced word + upright icons)

Cloud ship of SCREEN-take-arc-readability with Nathan override: Take word stays arced; burst/shield upright at native 1×; Block shield always on (including 0) using ItemFace.SHIELD.

## What to verify

- Take / Safe word follows the bottom curve (per-glyph), size 26, dark ink, **no** dark outline, 1px cream (#f0e6d0) letterpress under each glyph.
- Burst at native 1×, upright, crisp 2px ink outline only (no scaled ink/gold halos or circle strokes).
- Hit / "?" / Block numbers use outline size 4 + #f0e6d8 fill at 22 (ItemFace.make_number look).
- Block shield (pip_block_s24_2x.png) always on the left third, including when Block is 0 — same pip as item cards.
- Band still curved; take_burst_global / block_pip_global still drive threat line / Huntsman.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Fight with Block ≥ 1 and Take ≥ 1 | Arced Take + upright burst with clean outline; shield on left with number | 01-take-arc-live.png |
| 02 | combat | Fight with Block = 0 (Safe or Take still showing) | Shield still visible on left with 0; no blank left third | 02-block-zero.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Each expect readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.

## Outbox path

`playtest/repot/outbox/REQ-20261113-take-arc-readability/`
