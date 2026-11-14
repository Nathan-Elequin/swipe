---
id: REQ-20261114-keyword-tips-A-fix
status: done
priority: high
pr: 516
tip_sha: 8f471fb7
branch: cursor/keyword-tips-a-runtime-fix-869d
created: 2026-11-14T08:50:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue into a fight (or tutorial as noted)
---

# Keyword tips A — runtime fix re-shoot

Re-verify the nine Direction A rows after import / editor / wheel / teach / pin / pip / log / dock fixes. Compare against `design/visual/SCREEN-keyword-tips.md` and the prior outbox `REQ-20261114-keyword-tips-A`.

## What to verify

- Keyword chip + card icons load (`kw_*.png`, `kw_*_card.png`, seal, pip ring) — no word-only chips from failed `.ctex`.
- F1 defs editor opens, live preview updates, Revert + Save work.
- Wheel keep-out uses BossWheel (`wheel_view`), not Main’s `wheel` Array.
- First-sighting: 3 gold pulses, then card fades in with `new_star` (capture real-time frames).
- While pinned, hovering other chips does not change the card.
- Poison pip card paints on Main (`top_level`), clear of the wheel.
- Combat log rows show icon chips; hover docks the parchment in the log column.
- Busy hotbar: item card prefers above the plate when room (not covering neighbors); never inside wheel keep-out.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | hotbar item with a keyword (e.g. Longbow Across / Decay) | chip icons visible + parchment docked above/right of plate, not over other hotbar cards when above fits | 01-item-hover-chip-card.png |
| 02 | fight | Flee monster plate (Imp / Phantom / Commander) | Flee chip icon + parchment card | 02-monster-flee-card.png |
| 03 | fight | monster with Poison pip | pip hover ring + side-rail Poison card with card icon; plate hidden; card painted (not missing) | 03-poison-pip-hover.png |
| 04a | fight | fresh save / unseen keyword, mid teach | first-sighting gold pulse (halo visible, card still dim/closed) | 04a-teach-pulse.png |
| 04b | fight | same teach, mid open | card fading in / mid alpha with star starting | 04b-teach-mid.png |
| 04c | fight | same teach, open | parchment fully open, `new_star` visible | 04c-teach-card-open.png |
| 05 | tutorial | beat with Spin / Across (or similar taught keyword) | talk-box chip with icon + card below/beside talk | 05-tutorial-chip-hover.png |
| 06 | fight | 8-monster busy board, item/Flee card open | card clear of wheel keep-out; prefer above hotbar plate | 06-busy-8-monster.png |
| 07 | fight | combat log line with Flee / Spin / Poison | log row shows icon chips; parchment docked in log column | 07-log-hint.png |
| 08 | fight | click a chip to pin, then hover another keyword | seal stays; `_kind` unchanged; other hover ignored | 08-pinned-vs-hover.png |
| 09 | any | F1 keyword defs editor | editor opens; edit body → live preview; Revert restores | 09-f1-editor-preview-revert.png |

## Pass criteria

- All rows shot at 1680×1040 (or note viewport).
- Icons readable on chips and card headers (not text-only).
- Teach sequence has three real-time frames (04a/04b/04c), not a forced `modulate.a`.
- Prior fail rows 04 / 07 / 08 / 09 from REQ-20261114-keyword-tips-A now pass.

## Outbox path

`playtest/repot/outbox/REQ-20261114-keyword-tips-A-fix/` with `shots/` and `RESULT.md`.
