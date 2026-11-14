---
id: REQ-20261114-keyword-tips-audit
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-14T01:40:00-06:00
machine: Cherry
tip_sha: 0fc070ed
godot: F5 playtest via godot-mcp
branch: playtest/latest
viewport: control 1680x1040; framebuffer 1550x960 resized nearest to 1680x1040
---

# Result

Evidence only. Nathan’s `user://` JSON was copied to `_save_backup` then restored (campaign + home_cabin SHA match). Cabin `_persist_writes=false` during poses.

Hooks: `_open_dev_test`, `_dev_add_monster`, `_dev_add_item`, `_dev_enter`; `_on_item_hovered`; `_fill_inspect_from_slice`; `keyword_tip.show_def` / `show_def_at_cursor`; `speech_box.present`; `tut.open`/`advance`; `_log`.

| id | verdict | note |
|----|---------|------|
| K01 | captured | Smoke Bomb plate (`K01-card.png`) then Spin capsule (`K01-tip.png` + `K01-tip-crop2x.png`). Loaded is a sling status string, not in catalog Ability. |
| K02 | captured | Hex Ability has Defeats + Spins. Unplayable banner is a separate stripe (`K02-unplayable*`), then Spin (`K02-spin*`). |
| K03 | captured | Petrified Boot (`basilisk_stone`) + Petrify / Unplayable capsules. Rust curse plate + Curse / Rust capsules. Rust hover in live play uses `show_callout`, not the gold capsule. |
| K04 | captured | Commander inspect (Flee in Ability). Imp is Move/Spin, not Flee. Phantom Shroud hides Ability until `shroud_seen`. |
| K05 | captured | Basilisk poison=4 + gold capsule via `_mark_tip.show_def_at_cursor(poison)`. **Bug:** wheel poison pips have no hover → `def_of("poison")` in `boss_wheel.gd`. |
| K06 | captured | Phantom Ability Always + Shroud (`K06-shroud-seat.png` + tip). Other seats stay `?` while Phantom is alive. |
| K07 | captured | Marked pip; Trapper / Bear Trap / Beggar / Basilisk Gaze / Death Bell plates; Toll + Hex items. |
| K08 | captured | Speech bubble painted Flee+Spin + capsule (`K08-speech*`). |
| K09 | captured | Tutorial `tut.open` B01, B01-a, B02, B03×3, B04, B06. Talk crop `K09-B06-talk-crop2x.png`. **No gold capsule** — color paint only. |
| K10 | captured | Log line “Imp Flees. Poison 4 pays on Spin.” Hint is combat_log’s own z=130 panel, not `keyword_tip`. |
| K11 | blocked | No first-time keyword toast / overlay in code. |
| K12 | captured | 8 monsters, 9 hotbar cards, Commander plate + Flee capsule over the wheel (`K12-busy*`). |
| K13 | captured | `show_def(UxStyle.def_of(id))` for all 23 `def_of` ids. Full frames `K13-<id>-full.png`. 2× crops `K13-<id>.png` — ids also seen in K01–K12 use those in-context crops; remaining ids (`any`, `eject`, `across`, `move`, `defeated`, `loaded`, `swap`, `decay`) have isolation full frames (title/combat) plus the same API. Frozen viewport grabs often missed the top_level capsule unless an inspect plate was up. |

## Blockers

K11: no dedicated first-keyword moment. K05: poison pip is art-only. K09: tutorial does not hover-teach. Editor play window could not grow past 1550×960; shots resized to 1680×1040.

## Shots

`shots/` — full frames + `*-crop2x.png` (or `K13-<id>.png` for isolation crops). Surface notes in `audit/keyword-surfaces.md`.
