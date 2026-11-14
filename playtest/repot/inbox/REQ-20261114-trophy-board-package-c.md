---
id: REQ-20261114-trophy-board-package-c
status: open
priority: high
tip_sha: b204581a
branch: cursor/trophy-board-package-c-6d6e
created: 2026-11-14T03:00:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → finish a run (win with new uniques) → cabin exterior → click door
---

# Package C — Trophy Board homecoming

Post-run exterior → click → fade straight into the trophy hall. Satchel rise / fly / poof / light flash for newly claimed items, then lever READY prompt and hand-off to Package D BoardSequences for 100% shortcuts. Nothing auto-pulls the lever.

## What to verify

- After any run end (win bank or Nib push-block home), exterior shows; door click fades into the hall (main walk skipped). Left from the board still pans to main.
- New unique items play in board order (~2.0 s each, no speed-up): satchel jostle → rise+glint → fly to live slot center → poof → claimed. Light flash + chime only when unique lights rise.
- Skip (bottom right) jumps remaining items to claimed; board ends on last item's face; bank_pending empty after save.
- Nothing new: hall still shows; Nib says `nib.board.empty.*` (win) or `nib.home.loss.*` (loss). No satchel.
- Fifth light → after items finish, board slides to that face, lever READY glow + Nib lines; lever does **not** auto-pull. Pulling runs Package D portal.
- Biome dots show new pips for unviewed fresh claims.
- Reduce motion (if set on cabin): fade placement, no fly.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | exterior | post-run arrive | cabin exterior, door glow / clickable | 01-exterior.png |
| 02 | hall | after door click, first item mid-fly | satchel at bottom, item in flight toward slot | 02-homecoming-fly.png |
| 03 | hall | after sequence, 5 lights on a face | lever READY glow, claimed slots lit, optional pip on other dots | 03-lever-ready.png |
| 04 | hall | win with nothing new | hall idle, no satchel, Nib line if visible | 04-empty-return.png |

## Pass criteria

- All rows shot at 1680×1040.
- No "Tier" / "ATK" on screen.
- Slot fly targets match the live board layout (not a stale hardcoded pyramid).

## Outbox path

`playtest/repot/outbox/REQ-20261114-trophy-board-package-c/`
