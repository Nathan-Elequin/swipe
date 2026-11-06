---
id: REQ-20261106-draft-pick-seal
status: superseded
priority: high
pr: 416
tip_sha: b313459e
branch: playtest/latest
created: 2026-11-06T01:10:00Z
created_by: cursor-cloud
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue → fight until loot draft
---

# Cabin wax on the chosen draft card

Superseded 2026-11-05: Nathan pulled the wax seal and the grey X. A draft click adds the item immediately. Do not shoot this.

Nathan picked A (cabin wax). Overlay only — draft is still pick-1-of-2. Chosen card gets a wax press then a still seal. The leftover card gets a grey X. Recycler copies that come back get the slide-left mini-card. No new words, no “Tier”, no gate-door art, no wheel-seat changes.

## What to verify

- After you click one of the two loot cards, the chosen card shows a red wax seal (press, then it stays). The other card shows a grey X. Then the draft panel closes like before.
- Reroll and cancel do not stamp.
- When Recycler puts a copy back on the hotbar, that copy plays the slide-left mini-card. Countdown tick punch is unchanged.
- No new player-facing words. No “Tier” label. Wheel seats look the same size as F5 before this PR.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | Loot draft up. Click one card. Catch the stamp before the panel closes (~0.4s). | Red wax seal on the **chosen** card (bottom-right). Not the leftover. | 01-pick-seal.png |
| 02 | combat | Same pick. Catch the leftover in that same beat. | Grey X on the **not-taken** card. No wax seal on it. | 02-leftbehind-x.png |
| 03 | combat | Recycler in hand, discard until a copy comes back. | Slide-left mini-card overlay on the **returned copy**. Hotbar card itself does not slide. | 03-recycle-return.png |

## Pass criteria

- All rows shot at 1680×1040 (or note if viewport differs).
- Shot 01 is the wax seal on the taken card. Shot 02 is the grey X on the leftover. Shot 03 is Recycle’s slide-left, not the draft leftover.
- Each `expect` readable in the PNG without guessing.
- `RESULT.md` marks each id pass/fail with one line of evidence.
- Optional: `python3 tools/qa/check_draft_pick_seal.py` exits 0 (16×16, hard alpha, lossless import).
- Do not mark this request `done` from cloud.

## Outbox path

`playtest/repot/outbox/REQ-20261106-draft-pick-seal/`
