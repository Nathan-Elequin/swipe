---
id: REQ-20261114-keyword-tips-A
status: open
priority: high
branch: cursor/keyword-tips-direction-a-56aa
created: 2026-11-14T08:30:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Middle Progress / Continue into a fight (or tutorial as noted)
---

# Keyword tips Direction A

Locked parchment keyword card redesign: icon chips, unified card, first-sighting teach, pin/seal, F1 defs editor. Verify against `design/visual/SCREEN-keyword-tips.md` and the contact / F5 / F7 reference frames.

## What to verify

- Keywords render as icon chips (icon + colored word + underline) on item plates, monster plates, tutorial talk box, speech bubbles, and combat log — and are hoverable.
- One parchment card (no gold capsule, no separate log hint panel, no Rust mini-plate).
- Card never intersects the wheel keep-out circle (radius + 16px).
- Poison / Marked pips open the card on the side rail and hide that monster's plate while hovered.
- First-sighting: 3 gold pulses + card auto-open with `new_star`; dismiss on next action; interrupted teach replays.
- Click pins (wax seal); Esc / click elsewhere unpins; while pinned other hovers do nothing.
- F1 editor: edit a definition with live preview, then Revert (release builds hide the editor).

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | hotbar item with a keyword (e.g. Longbow Across / Decay) | chip on plate + parchment card docked above/right | 01-item-hover-chip-card.png |
| 02 | fight | Flee monster plate (Imp / Phantom / Commander) | Flee chip + parchment card | 02-monster-flee-card.png |
| 03 | fight | monster with Poison pip | pip hover ring + side-rail Poison card; plate hidden | 03-poison-pip-hover.png |
| 04 | fight | fresh save / unseen keyword | first-sighting pulse + card with new_star | 04-first-sighting-teach.png |
| 05 | tutorial | beat with Spin / Across (or similar taught keyword) | talk-box chip hoverable + card below/beside talk | 05-tutorial-chip-hover.png |
| 06 | fight | 8-monster busy board, card open | card clear of wheel keep-out | 06-busy-8-monster.png |
| 07 | fight | combat log line with Flee / Spin / Poison | log chip + card in log column | 07-log-hint.png |
| 08 | fight | click a chip to pin, then hover another | pinned seal vs hover-only | 08-pinned-vs-hover.png |
| 09 | any | F1 keyword defs editor | edit body, live preview updates, Revert restores | 09-f1-editor-preview-revert.png |

## Pass criteria

- All rows shot at 1680×1040.
- Each `expect` readable in the PNG without guessing.
- No gold capsule; parchment card matches Direction A chrome.
- F1 editor hidden when not authoring / release.

## Outbox path

`playtest/repot/outbox/REQ-20261114-keyword-tips-A/` with `shots/` and `RESULT.md`.
