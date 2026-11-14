# Keyword surfaces (live code, 2026-11-14, tip `0fc070ed`)

Gold capsule = `scripts/keyword_tip.gd` (`show_def` / `show_def_at_cursor` / `pin_def`). Default `z_index` **141**, `top_level` **true**, `mouse_filter` IGNORE unless pinned. Min size from `PlaytestUx.keyword_tip_min_size()` (280×82 in these shots). Rust / Phoenix ids can swap the capsule for `show_callout` (mini inspect plate, no gold border).

Paint / hover links: `UxStyle.paint`, `with_def_link`, `wire_def_hover` (`[url=kw:id]`). Click on a link calls `pin_def`. Hover-end calls `hide_def` unless `_pinned` or hover_panel `_pin_always`.

`def_of()` ids in `scripts/ux_style.gd`: any, eject, across, bear_trap, move, flee, defeated, marked, poison, spin, always, swap, loaded, unplayable, rust, decay, gaze, petrify, curse, shroud, toll, hex, beggar.

| surface | trigger | pin | dismiss | z-order | overlap with wheel / hotbar |
|---|---|---|---|---|---|
| Item inspect (`hover_panel` on `Main.fly_tip`) | Hover a hotbar `item_card` → `_on_item_hovered` → `show_rule`. Keywords in Ability/explainer are `[url=kw:]`. Hover the word → `show_def` on child `_kw_tip`, anchored to the plate. Unplayable stripe: `mouse_entered` → `show_def(unplayable)`. | Click the keyword (`pin_def`). Always can stay via `_pin_always` / `pin_always_def`. | Mouse leaves the word (`hide_def`) unless pinned. `hide_plate` unpins. | Plate **110**. Capsule **141** top-level. | Plate sits above the hotbar (K01–K03, K07 items). Capsule docks beside the plate; on a full 2×5 hand it sits on/next to cards (K12 fly 623,49 280×348; tip 911,49 280×82 — **over the wheel**, not the hotbar). |
| Item card itself (`item_card.gd`) | Hover lifts the card and emits `hovered`. **No** keyword capsule on the card. | n/a | n/a | Card in hotbar row. | Keywords are not taught on the card face; only via fly_tip. |
| Monster inspect plate (same `fly_tip`) | Hover a wheel slice → `_on_slice_hovered` → `_fill_inspect_from_slice`. Shrouded seats show `?` and skip Ability (`_monster_shrouded`). | Same click-to-pin on `[url=kw:]`. | Leave the word / leave the slice (`_idle_inspect`). | Plate **110**, capsule **141**. | Plate parks near the portrait (Commander K04 at top-center). Capsule to the right of the plate. **Overlaps wheel** easily; hotbar clear unless the plate is forced low. |
| Wheel mark pip (`boss_wheel._mark_tip`) | Hover Hunter’s Mark chip/sprite → `show_def_at_cursor(marked)`. Poison droplets are **drawn only** — no `show_def("poison")` in `boss_wheel.gd`. | No pin on mark hover. | Leave the chip → `hide_def`. | Created at 160, then remounted onto an overlay layer at **z=1** (`_mount_mark_tip`). Follows mouse. | K05/K07-marked: capsule at ~1245,621. **Overlaps wheel rim**, above hotbar. |
| Speech bubble (`speech_bubble.gd`) | `present()` with painted `[url=kw:]`. Body `MOUSE_FILTER_STOP` only when a kw url exists. Hover word → `wire_def_hover` on `_kw_tip`. | Click keyword → `pin_def`. | Leave word; `hide_speech` does not call `hide_def` (tip can linger if still visible). | Bubble **96**. Capsule **141**. | K08: bubble near portrait, capsule ~1046,361. **Over wheel**, above hotbar. |
| Tutorial guide (`tutorial_guide.gd`) | `UxStyle.paint(..., keyword_limit, taught ids)` colors words. **No** `wire_def_hover` / no `keyword_tip`. | n/a | Advance / Skip. | Guide **160** (above fly_tip 110–140 and keyword 141) so Next/Skip stay clickable. | Talk box K09 B06 at 1227,230 437×160 — **right of wheel**, above hotbar. No gold capsule. |
| Combat log (`combat_log.gd`) | `_link_kws` wraps flee/spin/always/unplayable/rust. Hover url → `_on_hint` with `def_of(id)`. | No pin. | `meta_hover_ended` → `_hide_hint`. | Log **7**. Hint panel **130** top-level (own StyleBox, **not** `keyword_tip`). | K10 hint at 32,917 552×38 — **over the hotbar left**. Does not cover the wheel. |
| Map overlay / rope exit / trophy board | No `UxStyle.paint` / `wire_def_hover` / `keyword_tip` in those scripts. | n/a | n/a | n/a | Keywords are not taught there today. |
| First-time “new keyword” toast | No `first` / `new_keyword` path in scripts. First teaching is tutorial paint + later hover links. | n/a | n/a | n/a | K11: no dedicated surface. |

## Pin / click

- Keyword urls: hover shows capsule; **click pins** (`UxStyle._on_def_click` → `pin_def`). Pinned tip uses `MOUSE_FILTER_STOP`.
- Rust url on a plate: hover uses `show_callout` (mini item plate), not the gold capsule.
- Phoenix / phoenix_egg urls: `show_callout` with `keyword_monster_callout`.

## Layout clamp

`keyword_tip._place` tries right, left, below, above the anchor, then `tooltip_clamp.place` against log block rects. `show_def_at_cursor` offsets 14,10 from the mouse.
