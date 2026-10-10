# Cursor — apply Swipe creative v2

## Own this

Replace player-facing strings from Jam’s `data/player-copy.json` (v2). Do **not** invent better jokes. Do **not** revive mill/Pip copy. Do **not** change ids, math, wait/focus keys, or UI layout.

## Steps

1. Diff / overwrite `data/player-copy.json` with the v2 file Jam delivered (id `swipe-player-copy-v2`).
2. If Roster / content-board shadows card `ability` / `explainer` / `name`, sync those fields from the same keys in player-copy (`card.monster.*`, `card.item.*`) or re-Save from board after paste — **player-copy + board must match**.
3. Confirm tutorial still uses wait/focus from code; only `body` / `go` / `hint` / speaker come from copy keys.
4. Play **How to Play** once: Shield → Safe → Boot → Helmet → Safe. Nib voice should feel new, not Pip-renamed.
5. Spot-check Begin → door: bait label, Take, owner taunt, seat cue.
6. Art TODO only if easy: helmet stem not a flask (`dungeon_art.gd`). Else leave TODO for Nathan.

## Acceptance

- Title **Swipe**; win **Ours**; lose **Caught**.
- Gate: THE DOOR / THE BAIT / THE OWNER.
- Tutorial speaker **Nib**; lines are v2 (e.g. beat 01 mentions “eight angry owners”, not “sticky-fingered one… round room” v1).
- Taunts sound like theft discovery (“My knife?!”, “raccoon”, etc.), not generic mill threats.
- Goblin / rule monsters still teach the same rules; speech still starts with I/My where required.

## Out of scope

New screens, new modes, renaming frozen ids, changing numbers, editor/Roster chrome.
