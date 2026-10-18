# Draft-gate tier and intro panel 2

## (a) Root cause

The true guard tier is the pending monster, through `_pack_tier_now()` in `scripts/main.gd`. In the harness that is Bandit. Catalog `data/catalog.json` gives Bandit `"tier": 2` (line 2938) and Breastplate `"tier": 3` (line 566). `PlayerCopy.tier_name` maps those to Tough and Deadly (`data/player-copy.json` keys `tier.2.name` and `tier.3.name`).

The header already used that monster tier. `DraftGate.present_mystery` stores the integer passed from `_present_gate`, and `_show_guard` prints `PlayerCopy.tier_name` of it (`scripts/draft_gate.gd`). The loot card did not. `_dress_showcase_card` called `_rank_label` on the item. `_rank_label` uses `pack_tier` when it is set, and otherwise the item's own catalog `tier`.

The harness state was inconsistent data, not a pair a player gets from a live draft. `_shot_itch_draft_gate` built the monster and the item with `_make_monster` / `_make_item` and never called `_stamp_pack`. Bandit stayed tier 2. Breastplate stayed tier 3. The header said Tough. The card said Deadly.

A live draft does not do that. `_draw_offer("draft")` (`scripts/main.gd`) takes one pack tier from the monster and `_stamp_pack`s that same integer onto both the monster and the item. `_open_petitioner` and `_auto_fill_rest` are the callers, and both use `"draft"`. After that stamp, the old card label and the header already agreed. `_draw_offer("starter")` would stamp the item with the item's own catalog tier, but nothing in `scripts/main.gd` calls the starter kind.

The display still had two readers. Any present that skipped the stamp (this harness) showed two words. Both readers now use one integer: `_pack_tier_now()`, captured as `guard_tier` in `_present_gate` and passed into `present_mystery` and `_refresh_offer_card`. The header and the card each call `PlayerCopy.tier_name` on that integer. The harness now stamps the same integer onto both dictionaries, which is what a live draft already did.

## (b) Intro panel 2 bed

The tan block was painted into `assets/dungeon/home/cutscenes/intro_p2.png`. It was not a missing TextureRect, a ColorRect, or a layering bug. The cutscene draws one texture on `_panel_a` (`scripts/cabin/cutscene_player.gd`): position native (50, 40), shipped (200, 160), size 1280×720, `z_index` 1.

In that PNG the flat color `#c4a574` was a rectangle at shipped pixels (160, 532, 324×56), native (40, 133, 81×14). Panel 1 already paints the bed in `intro_p1.png`: the same tan, wood `#a8844c`, a blue blanket `#4a6a8a`, and a red stripe `#8a2e2a`. Those pixels were copied onto panel 2 wherever panel 2 was the flat tan. Goblin pixels were left in place, so the blanket stops at the goblin.

`assets/dungeon/home/props/bed.png` is a different drawing (the loft quilt, 96×40 native). It was not placed on this panel.

The first harness shot still showed the old tan because Godot was serving the previous `.ctex`. `--import` rebuilt `intro_p2.png`, and the rerun has the blue blanket and red stripe in `13b_intro_panel2.png` (blanket blue `#4a6a8a` at shot pixels about x 480–683, y 692–723).

## Files changed

- `scripts/main.gd` — offer card rank and rim use the guard tier
- `scripts/dev/shot_harness.gd` — draft-gate shot stamps that tier; text-target shots write here
- `assets/dungeon/home/cutscenes/intro_p2.png` — panel 1 bed pixels on the tan block

## Text audit

`text_audit.json` in this folder, `updated` 2026-10-17T19:14:19, `"failures": []`.

Shots: `13a_intro_panel1.png`, `13b_intro_panel2.png`, `13c_intro_panel3.png`, `text_combat_tips.png`, `text_item_hand.png`, `40_itch_midfight.png`, `41_itch_draft_gate.png`, `42_itch_boss.png`.

`41_itch_draft_gate.png` shows "Guarded by a Tough monster" and the Breastplate rank Tough.

## Soft-lock check

A one-shot Godot script (not kept in the tree) loaded `scripts/home_cabin.gd` `_load_save` / `intro_pending` / `_gate_on` and restored `user://home_cabin.json`.

- No save: `intro_seen=false`, `pending=true`, `pack=1`, `gate=true`, `nib_first=false`. Boot calls `play_intro()` from `_sync_overlay` when `intro_pending()` is true (`scripts/main.gd`).
- Old save, version 2, `intro_seen` true, no `intro_pack`: load forces `intro_seen=false`, `intro_pack=1`, `pending=true`, `gate=true`. That is the `intro_pack < 1` branch in `_read_v2` from commit `4a15394`.
- Save with `intro_pack` 1 and `intro_seen` true: `pending=false`.

`_gate_on()` is what `set_gate` uses to show the psst prompt and play Nib's `psst` animation (`scripts/cabin/room_main.gd`). A click on that prompt emits hotspot `Nib`. The harness intro shots are `play_intro()` on a running game (panels 1–3 captured, then the cutscene aborted).

## Web export

`export_presets.cfg` has preset Web. Headless `--export-release Web` wrote `build/web/` and exited 0. `index.html`, `index.js`, `index.wasm`, and `index.pck` are there. Not uploaded. Not committed.

## Could not fix

Nothing left from this pass. The loft quilt sprite was not used, because it is not the bed painted in panel 1.
