---
id: REQ-20261102-defeat-seal-bs
status: open
priority: high
branch: cursor/defeat-seal-bs-a9b6
created: 2026-11-02T17:40:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → enter Verdant Hollow → die once
---

# Defeat spotlight wax seal next to B.S.

Wax seal left of the B.S. attribution under the defeat journal quote: fades in intact with the quote, then crossfades to broken before Limp home / Quick start appear. No Undo. No Tier.

## What to verify

- Seal sits left of `— B.S.`, centered under the quote (AttribRow HBox, separation 10).
- Intact seal (`wax_seal.png`) fades in with the quote/monogram beat.
- After quote drift (~2s): intact→broken crossfade (~0.4s); optional small scale punch.
- Broken seal stays visible when **Limp home** and **Quick start** are on screen.
- No Undo control. No Tier / ATK labels on this surface.
- Nearest filter; existing overlay art only.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | defeat quote→seal | Die once; capture mid/crossfade of intact→broken next to B.S. | Seal left of B.S.; crossfade readable; quote still up | 01-quote-seal-break.png |
| 02 | defeat buttons | After buttons settle | Broken seal still left of B.S.; Limp home + Quick start; no Undo | 02-buttons-broken-seal.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Seal left of B.S., centered under quote.
- Broken seal visible with both buttons; no Undo; no Tier.

## Outbox path

`playtest/repot/outbox/REQ-20261102-defeat-seal-bs/`
