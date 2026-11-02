---
id: REQ-20261102-defeat-spotlight
status: open
priority: high
branch: cursor/defeat-spotlight-journal-9768
created: 2026-11-02T06:15:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → enter Verdant Hollow → die once (or force HP to 0)
---

# Defeat spotlight sequence

Hard blackout on defeat with soft warm cone on Sprout, full existing defeat anim + music, then Spin journal quote + monogram, then exactly two buttons (Limp home / Quick start). No Undo.

## What to verify

- On death: hard cut to black; only Sprout + soft shadow render under a soft-edged warm spotlight cone (not a hard clip).
- Existing Sprout defeat anim and defeat sting/music play fully (not cut short).
- After anim: italic journal quote fades/drifts up ~12px over ~2s; thin rule; monogram `— B.S.` from `defeat.journal.attrib`.
- Quote is one of `defeat.journal.01`–`.50` verbatim (Spin-locked).
- Then exactly two buttons fade in: **Limp home** and **Quick start**. No Undo control anywhere.
- Taps ignored until buttons appear.
- **Limp home** → existing loss homecoming to cabin.
- **Quick start** → new Verdant Hollow (`b1`) run, biome splash skipped, lands on dealing items into the hotbar.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | defeat mid-anim | Force defeat; capture ~0.8s into anim | Blackout + soft cone + Sprout mid-slump; no HUD/hotbar | 01-defeat-mid-anim.png |
| 02 | defeat quote | Wait until quote visible, before buttons | Italic quote + rule + `— B.S.`; Sprout held on floor | 02-defeat-quote.png |
| 03 | defeat buttons | After buttons fade in | Limp home (dark) + Quick start (cream); no Undo | 03-defeat-buttons.png |
| 04 | quick start deal | Click Quick start | No biome splash; item deal into hotbar begins (Verdant) | 04-quick-start-deal.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Soft spotlight edge readable (feathered cone/pool, not a hard triangle).
- No Undo on any defeat still.
- Quote text matches a locked `defeat.journal.NN` line byte-for-byte.

## Outbox path

`playtest/repot/outbox/REQ-20261102-defeat-spotlight/`
