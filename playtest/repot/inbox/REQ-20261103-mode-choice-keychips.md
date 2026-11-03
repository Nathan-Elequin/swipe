---
id: REQ-20261103-mode-choice-keychips
status: open
priority: high
branch: playtest/latest
created: 2026-11-03T17:05:00Z
created_by: cloud-agent
viewport: 1680x1040
entry: F5 playtest hub → Brand New / Middle Progress → combat with Throwing Knife (and Net or Magnet if available)
---

# Look H mode-choice key chips — icons + ATK labels visible

`PanelContainer` on each knife/row target only supports one child. Content VBox/HBox and the key chip were both direct children, so Godot laid out the chip as the sole child and the overlay showed giant centered "1" / "2". Fix: one full-rect `Control` host under the panel; content + small corner key chip are siblings under that host.

## What to verify

- Throwing Knife overlay shows knife icon tiles, red throw / green keep badges, primary ATK lines, secondary discard/keep — not bare huge digits.
- Key chips "1" and "2" are small (~12px) in the bottom-right of each target.
- Net / Magnet row targets still show icon + label (+ pips) with small key chips.
- Hover rim stays CHOICE `#7CC8F0`. No Look C tags / ItemCard clones.

## Screenshots required

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | combat | open Throwing Knife mode choice (2-up) | both targets show knife icon + ATK/discard\|keep; tiny 1/2 corner chips | 01-knife-overlay.png |
| 02 | combat | open Net or Magnet row mode choice | rows show icon + label + pips; small key chips, not full-panel digits | 02-row-overlay.png |

## Pass criteria

- Shots at 1680×1040 (or note viewport).
- Expect readable without guessing that icons/labels are present and digits are corner chips.
- `RESULT.md` marks each id pass/fail.

## Outbox path

`playtest/repot/outbox/REQ-20261103-mode-choice-keychips/`
