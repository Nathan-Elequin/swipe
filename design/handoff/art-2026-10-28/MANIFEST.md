# Spinheritance monster + item art — 2026-10-28 (Pixel art executor)

Built 2026-10-28 21:30 CT on the box. Refs: box mirror `/workspace/spin_idx/r` (playtest/latest with the Oct 28 Harpy redraw; extra/harpy.png md5 ca50a6df matches the tip). Catalog text was read from the mirror's `data/catalog.json`. Cherry was not touched.

## Oligarch redo — 2026-10-28 ~22:05 CT (Nathan feedback: Harpy and Oligarch both had dark hair)
- The Oligarch is now a **redhead (red/auburn) in a royal emerald-green gown with gold trim**. She is still a female high-elf merchant with fancy clothes, and she still faces LEFT. The slash keeps the gold-coin toss. Her full pack was rebuilt so every frame matches: still, facing f0–f3, wheel base/b0/b1, slash base/f0–f3.
- That took **4 gens**: pixflux base ×2 (s22 = full body for facing and wheel; s33 came out as a close-up and became the slash portrait), animate idle ×1 and animate slash ×1. Balance went **1018 → 1014**.
- An emerald ramp was added to the cleanup palette: 163a26 245c38 3a8a4e 62b070. Hair uses the existing reds 9a3428/d0644a. The still is hand-pixelled 16px recoloured to match.
- The old purple files are kept in `oligarch-redo/old/`. The showcase is `showcase/oligarch_redhead.png` (old vs new, with Harpy for contrast). `monsters_pack*.png` and `oligarch_before_after.png` were refreshed.
- Sandbag, Scorpion, Harpy and the items are untouched (byte-identical).
- The emerald ramp makes the purple ramp unnecessary for Oligarch, but it stays in the cleanup palette (harmless).

## PixelLab spend
- First batch: balance **1063 → 1018**, so **45 generations**. The Oligarch redo added 4 more, for a running total of **49 gens** and a balance of **1014** (45 logged 200 calls. 1 call returned 422 and was not charged: pixflux 16×16 is below the 32×32 minimum).
- Cap 80 and floor 200 are enforced in `work/lib.py`. Both were respected.
- Gens by piece: scorpion 9, spiked_shield 8 (both variants), sandbag 6, oligarch 6, orb 4, flying_saucer 4, mute_stone 4, harpy 4.
- Every call is in `calls.log` (payload without the b64, balance before and after, files).

## How each piece was made
- **Monster facing idle (48)**: pixflux 48 base facing west (2 seeds, pick), then animate-with-text-v3 with 4 frames. Shipped frames are 0..3.
- **Slash cut-in (48)**: pixflux close-up portrait (init = bicubic crop of the base for oligarch and sandbag, text-only reroll for scorpion), then animate-with-text-v3 with 4 frames. `_slash_base` = the neutral portrait (frame 0) and `_slash_f0..f3` = the 4 action frames (beggar peer layout).
- **Wheel (24)**: the facing frames mode-downsampled with the shared union crop and outline rebuilt. Full body, ≤24 tall. `base` = facing f0. `breathe_f0` and `breathe_f1` are the two other facing frames that differ most from the base and from each other (all three are distinct).
- **Stills (16 → 64)**: hand-pixelled at 16×16 in `work/hand_stills.py` from the PixelLab design, then 4× nearest. Generated stills at 16px came out as mush with no eyes, so a reroll would not have fixed them.
- **Items (16 → 64, or 14×16 → 56×64)**: PixelLab gave the concepts (pixflux 32, a blocky-init reroll, a bitforge 16 style-ref reroll). All three downsampled to mush at 16px, so the finals are **hand-pixelled** in `work/hand_items.py` against the peer item sheet.
- **Cleanup** on every frame: Lab-nearest snap to spinheritance.hex plus a 7-colour purple ramp (lich/poison ramp 2e2450 4a3a78 7a6aa8 4a446a 766e9a aaa2c6 e8dcc0, needed for Oligarch's gown). Also: islands under 4 px removed, orphans removed, 1px #100e0c outline rebuilt, alpha 0/255 only, shared union crop + bottom-align across frames (no per-frame jitter), integer scale only, Nearest. Verified: 0 off-palette pixels and binary alpha on all 56 files.

## Facing (Nathan lock Oct 26: monsters face LEFT)
| id | drawn facing | recommended MONSTER_FACES |
|---|---|---|
| sandbag | front, eyes looking left | `"sandbag": "L"` (or omit = front, never flipped) |
| scorpion | LEFT (pincers left) | `"scorpion": "L"` |
| oligarch | LEFT 3/4 (redhead/green redo) | `"oligarch": "L"` |
| harpy | LEFT (all 4 facing frames now consistent; tip f2/f3 had turned frontal) | **change `"harpy": "R"` → `"L"`**. Tip says R while the art is drawn left, so `monster_flip_h` mirrors her the wrong way. |

## Files (`final/` mirrors `res://`)
| path | size |
|---|---|
| `assets/dungeon/anim/facing/harpy_facing_idle_f0.png` | 48×48 |
| `assets/dungeon/anim/facing/harpy_facing_idle_f1.png` | 48×48 |
| `assets/dungeon/anim/facing/harpy_facing_idle_f2.png` | 48×48 |
| `assets/dungeon/anim/facing/harpy_facing_idle_f3.png` | 48×48 |
| `assets/dungeon/anim/facing/oligarch_facing_idle_f0.png` | 48×48 |
| `assets/dungeon/anim/facing/oligarch_facing_idle_f1.png` | 48×48 |
| `assets/dungeon/anim/facing/oligarch_facing_idle_f2.png` | 48×48 |
| `assets/dungeon/anim/facing/oligarch_facing_idle_f3.png` | 48×48 |
| `assets/dungeon/anim/facing/sandbag_facing_idle_f0.png` | 48×48 |
| `assets/dungeon/anim/facing/sandbag_facing_idle_f1.png` | 48×48 |
| `assets/dungeon/anim/facing/sandbag_facing_idle_f2.png` | 48×48 |
| `assets/dungeon/anim/facing/sandbag_facing_idle_f3.png` | 48×48 |
| `assets/dungeon/anim/facing/scorpion_facing_idle_f0.png` | 48×48 |
| `assets/dungeon/anim/facing/scorpion_facing_idle_f1.png` | 48×48 |
| `assets/dungeon/anim/facing/scorpion_facing_idle_f2.png` | 48×48 |
| `assets/dungeon/anim/facing/scorpion_facing_idle_f3.png` | 48×48 |
| `assets/dungeon/anim/slash/harpy_slash_base.png` | 48×48 |
| `assets/dungeon/anim/slash/harpy_slash_f0.png` | 48×48 |
| `assets/dungeon/anim/slash/harpy_slash_f1.png` | 48×48 |
| `assets/dungeon/anim/slash/harpy_slash_f2.png` | 48×48 |
| `assets/dungeon/anim/slash/harpy_slash_f3.png` | 48×48 |
| `assets/dungeon/anim/slash/oligarch_slash_base.png` | 48×48 |
| `assets/dungeon/anim/slash/oligarch_slash_f0.png` | 48×48 |
| `assets/dungeon/anim/slash/oligarch_slash_f1.png` | 48×48 |
| `assets/dungeon/anim/slash/oligarch_slash_f2.png` | 48×48 |
| `assets/dungeon/anim/slash/oligarch_slash_f3.png` | 48×48 |
| `assets/dungeon/anim/slash/sandbag_slash_base.png` | 48×48 |
| `assets/dungeon/anim/slash/sandbag_slash_f0.png` | 48×48 |
| `assets/dungeon/anim/slash/sandbag_slash_f1.png` | 48×48 |
| `assets/dungeon/anim/slash/sandbag_slash_f2.png` | 48×48 |
| `assets/dungeon/anim/slash/sandbag_slash_f3.png` | 48×48 |
| `assets/dungeon/anim/slash/scorpion_slash_base.png` | 48×48 |
| `assets/dungeon/anim/slash/scorpion_slash_f0.png` | 48×48 |
| `assets/dungeon/anim/slash/scorpion_slash_f1.png` | 48×48 |
| `assets/dungeon/anim/slash/scorpion_slash_f2.png` | 48×48 |
| `assets/dungeon/anim/slash/scorpion_slash_f3.png` | 48×48 |
| `assets/dungeon/anim/wheel/harpy_wheel_base.png` | 24×24 |
| `assets/dungeon/anim/wheel/harpy_wheel_breathe_f0.png` | 24×24 |
| `assets/dungeon/anim/wheel/harpy_wheel_breathe_f1.png` | 24×24 |
| `assets/dungeon/anim/wheel/oligarch_wheel_base.png` | 24×24 |
| `assets/dungeon/anim/wheel/oligarch_wheel_breathe_f0.png` | 24×24 |
| `assets/dungeon/anim/wheel/oligarch_wheel_breathe_f1.png` | 24×24 |
| `assets/dungeon/anim/wheel/sandbag_wheel_base.png` | 24×24 |
| `assets/dungeon/anim/wheel/sandbag_wheel_breathe_f0.png` | 24×24 |
| `assets/dungeon/anim/wheel/sandbag_wheel_breathe_f1.png` | 24×24 |
| `assets/dungeon/anim/wheel/scorpion_wheel_base.png` | 24×24 |
| `assets/dungeon/anim/wheel/scorpion_wheel_breathe_f0.png` | 24×24 |
| `assets/dungeon/anim/wheel/scorpion_wheel_breathe_f1.png` | 24×24 |
| `assets/dungeon/extra/oligarch.png` | 64×64 |
| `assets/dungeon/extra/sandbag.png` | 64×64 |
| `assets/dungeon/extra/scorpion.png` | 64×64 |
| `assets/dungeon/items/flying_saucer.png` | 64×64 |
| `assets/dungeon/items/mute_stone.png` | 56×64 |
| `assets/dungeon/items/orb.png` | 64×64 |
| `assets/dungeon/items/spiked_shield.png` | 56×64 |
| `assets/dungeon/items/spiked_shield_block.png` | 56×64 |

### Item notes
- `items/spiked_shield.png` (56×64) is the **PRIMARY** and goes in ITEM_PNG. It is the attack-leaning face: a red round shield with a big centre spike. It replaces the Oct 10 grey placeholder.
- `items/spiked_shield_block.png` (56×64) is the **optional** block-leaning face: a blue kite with studs. It is not wired anywhere yet. If the card later swaps art on its Block face, map the Block state to it. Otherwise leave it out of the PR or keep it as unused source.
- `items/mute_stone.png` (56×64) is the Chaos Stone: a dark rune stone with orange and teal arrows chasing in a circle (swap). Filename unchanged, replacing the purple flower.
- `items/orb.png` (64×64) is a pale-blue crystal focus on a gold stand with teal inner glow. "Grey unless Safe" is runtime state (the card greys). No separate grey PNG.
- `items/flying_saucer.png` (64×64) is a white porcelain dinner saucer with a blue rim band, glass dome and rim lights.

### Harpy polish (identity unchanged: dark hair, brown wings, cream dress)
- `anim/facing/harpy_facing_idle_f0..f3` are re-animated from the tip f0. They stay turned LEFT in every frame.
- `anim/slash/harpy_slash_base, f0..f3` are **real cut-in frames**: a new head-and-shoulders portrait with wings flaring and a talon slash at f3. They are no longer full-body idle copies.
- `anim/wheel/harpy_wheel_base, breathe_f0, breathe_f1` are three distinct full-body frames. Before, breathe_f0 was a byte copy of base.
- **Delete the tip's `anim/slash/harpy_slash_f4.png` (and its .import)**. `monster_slash_frames` loads f0..f11 until the first gap, so the stale f4 idle copy would play after the new f3.
- `extra/harpy.png` is **not** in this pack. The tip still stays (it is off the 4× grid. Follow-up if Nathan wants it).

### Not done / caveats
- Peer `wheel_breathe_f0/f1` files for beggar and lich are close-up crops, not full body. This pack follows the brief (full body ≤24). The wheel seat uses only `_wheel_base`, so either style is safe.
- Sandbag's slash is an expression cut-in (puffs, scowls, blushes). It does not move much, the same as the beggar peer.
- Scorpion's slash portrait is a full scorpion strike (venom flash f0–f2) rather than a face close-up. The face close-up rolls were unreadable.
- Oligarch facing is 48×48, like the peers (64 was optional).

## Wire checklist (scripts/dungeon_art.gd + data/catalog.json)
- [ ] MONSTER_PNG: add `"sandbag": "res://assets/dungeon/extra/sandbag.png"` and `"scorpion": "res://assets/dungeon/extra/scorpion.png"`. Oligarch is already listed and its file is replaced. Note that wheel_frames_all only iterates MONSTER_PNG keys.
- [ ] MONSTER_FACES: add `"sandbag": "L"`, `"scorpion": "L"`, `"oligarch": "L"`. Change `"harpy": "R"` → `"L"`.
- [ ] ITEM_PNG: add `"orb": "res://assets/dungeon/items/orb.png"` and `"flying_saucer": "res://assets/dungeon/items/flying_saucer.png"`. spiked_shield and mute_stone are already mapped (files replaced).
- [ ] catalog flags.art → true for sandbag, scorpion, orb, flying_saucer (currently false). oligarch, spiked_shield and mute_stone are already true. Clean the stale "Art missing" / "Art is a stand-in…" / "Needs art" phrases in exceptions/notes only if the field is not author-locked (respect author_lock / locked_fields).
- [ ] git rm `assets/dungeon/anim/slash/harpy_slash_f4.png` + `.import`.
- [ ] Let Godot generate `.import` files for the new PNGs (headless import) and commit them. Use the same params as the peers (compress/mode=0, mipmaps off). The project filter is Nearest.
