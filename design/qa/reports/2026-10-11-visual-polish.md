# QA — 2026-10-11 Direction A polish

## Feature

- Name / id: Hide authoring chrome; dim defeat pointer; wire `door.guard`; Pixel talk box / spotlight / loot glow / oak 9-slice
- Spec: `design/HANDOFF.md` Jam polish list; `design/visual/SCREEN-how-to-play.md`, `SCREEN-victory.md`, `SCREEN-draft-gate.md`, `SCREEN-defeat.md`; `assets/ui/panels/README.md`
- Checklist: Copy/UI

## Result

PASS WITH NOTES

## Checklist

| Check | Expected | Actual | Evidence | Pass/Fail |
|---|---|---|---|---|
| Authoring log + copy stamp off player screens | Hidden on Adventure mill, How to Play, victory, defeat, pause | `log_btn`/`log_label`/`_copy_stamp` false on title, tutorial, draft ask, victory, defeat, pause | dumps + `talk_box_qa_v2.png` · `draft_gate_qa_v2.png` · `victory_qa_v2.png` · `defeat_qa_v2.png` | Pass |
| Same chrome only in Developer Test | Log button + stamp on `phase == "devtest"` | stamp true (`copy: swipe-player-copy-v3-draftgate · 2026-10-10`); log_btn true; log body closed until Log | dump after `_open_dev_test` | Pass |
| Defeat pointer matches dim wheel | `#5A5048` at 22% | pointer modulate == wheel modulate `[0.353, 0.314, 0.282, 0.22]` | dump + `defeat_qa_v2.png` | Pass |
| `door.guard` on bait card | "Guarded by a {tier} monster"; `{tier}` from `tier.N.name`; never "Tier" | "Guarded by a " + Weak pill + " monster" | dump `guard_a/pill/b` + `draft_gate_qa_v2.png` | Pass |
| Victory glow PNG | `vfx_glow_gold.png` at (128,90) 840×600 | path + pos/size match | dump + `victory_qa_v2.png` | Pass |
| Title pop + 16 gold particles | after last loot drop | title_a 1.0 after delay; `_spark.amount` 16 | dump (`spark_emit` false in the still — one-shot already finished) | Pass WITH NOTES |
| Talk box 9-slice | `ui_talkbox.png` 96/22/12/12, content 44/28 | StyleBoxTexture that path | dump + `talk_box_qa_v2.png` | Pass |
| Spotlight ring | `ui_spotlight_ring.png` at (215,17); seat ring for one-seat beats | wheel ring visible at 215,17 | dump + `talk_box_qa_v2.png` | Pass |
| Oak 9-slice panels | theme + column + pause | pause `ui_panel_oak.png`; victory gold oak column | dump + screenshots | Pass |
| Wheel locked | (548,350) | hub 236+312, 38+312 | dumps | Pass |
| No "Tier" on player labels | | none on plates; "Tier 1 lure" only inside hidden log text | dump `log_lab` false; log_text still contains authoring "Tier 1 lure" | Pass |
| No `data/` edits | | git: no `data/` in this pass | | Pass |
| Errors | none | no new script errors after parse fix | `godot_editor_read` get_log_messages since 262 | Pass |

## Bugs

None that fail the bar.

1. **Repro** — victory still after ~1s: the 16 gold squares have already died (`one_shot`, 0.55 s). Dump caught `amount` 16 while emitting.
2. **Likely file** — `scripts/end_plate.gd` `_pop_title`
3. **Suggested fix** — none; motion is live. Still is the settled plate.
4. **Severity** — polish

## Balance notes

Visual / copy wiring only. Draft mill this run: Weak / Throwing Knife.

## Player-facing copy issues

- `door.pass` still locked as "Leave it" (pips carry remaining passes).
- `door.owner` / `door.shiny` still ALL CAPS.
- `tutorial.beat.01.go` is "I'm in"; mockup says "Show me".
- `door.guard` still says "monster" (Jam's COPY-FLAGS asked for "owner"). Wired as saved. No `data/` edit.

## What was fixed this loop

- Loop 1: `StyleBoxTexture.AXIS_STRETCH_STRETCH` parse error on 4.7 — dropped the enum; default stretch.
- Loop 2: clean victory recapture after a Developer Test overlay polluted `victory_qa_v2.png`.
- Still left: locked Leave / ALL CAPS bait labels / "I'm in".

## Next agent: start here

1. Do not edit `data/` for the copy flags above.
2. Seat-size spotlight (`ui_spotlight_ring_seat.png`) is wired; this How to Play still used the wheel ring.
