---
id: REQ-20261114-keyword-tips-audit
status: done
priority: high
tip_sha: 2c7b5865
created: 2026-11-14T07:15:00Z
created_by: pixel
viewport: 1680x1040
---

# Keyword teaching audit (Pixel design input)

Nathan wants to redesign how keywords (Flee, Poison, Decay, Shroud, ...) are highlighted and taught. Pixel needs evidence of EVERY place a keyword is highlighted or explained today. Capture evidence only; don't change code or copy.

Code map (for finding surfaces):
- `scripts/keyword_tip.gd`: the gold-bordered capsule (`show_def`, `show_def_at_cursor`, `pin_def`, `show_callout`).
- `scripts/ux_style.gd`: `paint()` colors keywords; `with_def_link` / `wire_def_hover` make them hoverable `[url=kw:id]`; `def_of()` lists all keyword ids.
- Callers: `hover_panel.gd` (item card / hotbar hover), `boss_wheel.gd` (monster callout / inspect plate, mark tip), `speech_bubble.gd` (Nib + monster speech), `tutorial_guide.gd` (tutorial prose highlights), `item_card.gd`, `combat_log.gd`, `map_overlay.gd`, `rope_exit.gd`, `trophy_board.gd`.

Use dev hooks / roster to set up fights fast, and note which hooks you used.

## Shots (1680x1040, full frame + a 2x crop of the tooltip region)
| id | surface | setup | capture |
|----|---------|-------|---------|
| K01 | item hover on hotbar | item text with a keyword (e.g. Decay, Swap, Loaded, Rust) | card alone, then hovering the keyword so the tip shows |
| K02 | item with 2+ keywords | any item whose text has 2 keywords | both tips one after another |
| K03 | unplayable / petrified / cursed item | Gaze or Curse fight | hover card + tip |
| K04 | monster inspect plate on the wheel | Flee monster (e.g. Imp/Phantom) | plate, then the keyword tip |
| K05 | monster with Poison mark on the wheel | after poisoning | wheel mark/pip, plus its tip on hover |
| K06 | Shroud monster | Phantom | shrouded seat + tip |
| K07 | Marked / Trapper, Bear Trap, Toll, Hex, Beggar, Gaze | one each if reachable | seat/pip + tip |
| K08 | Nib or monster speech bubble with a keyword | tutorial or any speech with a highlighted word | bubble + hover tip |
| K09 | tutorial guide beat that teaches a keyword | fresh tutorial, beats that highlight Spin / Flee / Attack etc. | each such beat |
| K10 | combat log line with a keyword | after a Flee / Poison resolve | log + hover if hoverable |
| K11 | first time a keyword appears in a normal run (any 'new keyword' moment if one exists) | fresh save first fight | the moment |
| K12 | a busy combat frame with a tip open | 5+ monsters, full hotbar | to judge clutter/overlap with wheel and hotbar |
| K13 | every keyword tip in isolation | via a debug call to `show_def(def_of(id))` for each id in `def_of()` | one crop each, named `K13-<id>.png` |

Also write `audit/keyword-surfaces.md`, listing for each surface: how it is triggered (hover / click / auto), whether it can be pinned, how it dismisses, its z-order, and whether it overlaps the wheel or hotbar.

## Outbox
`playtest/repot/outbox/REQ-20261114-keyword-tips-audit/` with `shots/`, `audit/keyword-surfaces.md` and `RESULT.md` (one line per row: captured or blocked, plus any bug seen). Back up Nathan's save before a fresh save and restore it after. Commit only the outbox and push to playtest/latest. Never stash local edits; commit them first as a WIP checkpoint.
