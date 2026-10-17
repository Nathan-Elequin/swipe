# SCREEN: run hero (wheel hub goblin + HP/BLK badges)

Build spec for replacing the Kenney knight on the run screen with the goblin thief (Bartleby "Lucky" Snatchwick's grandson). Art: `assets/dungeon/hero_run/`. Every number is in `assets/dungeon/hero_run/layout.json`, and this doc and that file agree. Viewport 1680x1040. Units are shipped px. `c` = wheel centre = hub centre (the `c` passed to `BossWheel._draw_hub_block`).

## 1. Hero sprite on the hub

- Texture: 96x96 (native 24x24 at 4x Nearest). Pivot **(48,92)** = feet.
- Draw rect: `Rect2(c + Vector2(-48, -50) + hub_nudge, Vector2(96, 96))`, so the feet sit at **c + (0,42)**.
- Use `draw_texture_rect(tex, rect, false, sting_tint)`. Keep the existing hurt and block `sting_tint` and the `hub_nudge` knock tween.
- Delete these from `_draw_hub_block`:
  - the `bob` term (the idle frames already sink 1px; a code bob on top would double it and smear the pixels);
  - the `psz` 56x80 stretch.
- Snap the rect to whole pixels: `rect.position = rect.position.round()`. `hub_nudge` is fractional during the tween, and a fractional position breaks the pixel grid.
- Replace `tex_player` and `main.gd:771 set_player(art.frames("knight_m"))` with a small state machine that picks an animation by name. Timings are per frame, so drop the fixed `_glow_t / 0.18` index.

| anim | frames | ms per frame | playback | trigger |
|---|---|---|---|---|
| idle | 4 | 220,180,220,180 | loop | default |
| lowhp | 4 | 260,200,260,200 | loop | replaces idle while HP <= the low threshold (suggest <= 30% or <= 3) |
| swipe | 5 | 90,60,80,110,120 | once, then back to idle | player commits a swipe. **f2 = hit frame**: fire damage, sfx and the slice flash on entering f2 |
| hit | 3 | 70,110,120 | once | player loses HP (same moment as `hub_sting_kind = "hurt"`) |
| block | 3 | 60,160,120 | once | damage absorbed by BLK (with `hub_sting` block). **f1 = impact**: start the BLK badge punch here |
| heal | 4 | 120,120,220,180 | once | HP gained. f2 = gulp (start the HP number tick) |
| death | 5 | 140,140,160,200, hold f4 | once, hold last | HP 0. **f3 = floor hit**: screen bump 4px down for one frame (same as the cabin bump) |
| victory | 4 | 100,140,160,120 | play twice | boss defeated, before the hall wipe |
| grab | 4 | 100,90,140,180 | once | draft or relic pick. f1 = grab |
| walkoff | 4 | 70 each | loop | hall-wipe courier (`_walk_knight_off` and the second courier at main.gd ~7278) |

Priority when two triggers land on the same beat: death > hit > block > heal > swipe > grab > victory > lowhp/idle. A once-anim returns to lowhp or idle depending on HP.

## 2. Gear on the hub

- Gear pieces: cap, helm, goggles, rope (`gear_worn` head / eyes / belt slots).
- After the base frame, draw `hero_run/gear/<piece>/run_<anim>_f<N>.png` into the **same rect** with the same tint.
- Order: rope, goggles, then cap or helm. Cap and helm share the head slot, so draw at most one.
- Every frame of every animation has all four overlays. Never swap the texture for an overlay; always draw both. That swap is the cabin bug, see the wiring spec.

## 3. Badges: level, either side of his feet

The badges are textures. The number is still code-drawn: `_draw_bold_num(font, anchor, txt, 18, Color("f0e6d8"))`, centred on the anchor.

| badge | rect from c | size | visual centre from c | number anchor from c |
|---|---|---|---|---|
| HP heart | (-64, +24) | 44x40 | (-42, +40.4) | (-42, +41) |
| BLK heater shield | (+38, +21) | 44x48 | (+60, +40.1) | (+60, +41) |

- **Level:** the shield's visual centre (the alpha centroid of the heater shape, which sits higher than its rect centre) is level with the heart's. Both numbers share y = c.y + 41.
- **Not symmetric:** perfect mirror symmetry about his feet (shield centre x +42) would put the shield on his feet. x +38 is the closest position that keeps a 2px gap. To get there I nudged three frames:
  - the swipe f2 lower claw;
  - the swipe f3 fist (1px up);
  - the block f2 shield (1px up).
- **Clearance**, checked in `out/stage2/verify.json`:
  - at least 2px between the sprite and both badges on every hub frame, with every gear loadout (death f2-f4 excepted: see the dim rule, and walkoff runs off-hub);
  - the badges never touch each other;
  - the furthest badge pixel is 77 px (HP) and 94 px (BLK) from c, inside the ~100 px hub ring.
- **Remove from `_draw_hub_block`:**
  - `_draw_heart_shape`;
  - the shield `PackedVector2Array` polygon and polyline;
  - the pierce slash lines;
  - both caption calls: the "HP" and "BLK" `_draw_outlined_string` lines and the static "IGNORED" line.
  - No caption is drawn under either badge.
- **States:** swap the texture instead of lerping the fill colour.
  - **HP heart:**
    - `badge_hp` normal.
    - `badge_hp_flash` while the ghost < hp, or during the log focus. Alternate it with `badge_hp` at the existing `sin(_glow_t*12)` rate.
    - `badge_hp_low` at low HP.
    - `badge_hp_empty` at 0.
  - **BLK shield:**
    - `badge_blk` when shown > 0.
    - `badge_blk_empty` when shown <= 0.
    - `badge_blk_up` when ghost > blk, and for the log focus.
    - `badge_blk_pierced` while `hub_pierce` is set.
- **Pierce float:** when `set_hub_pierce(true)` turns pierce on, draw the **existing** pierce text once: the same string or copy key used today, unchanged.
  - Size 10, #e8c36a with a #100e0c outline, text-centred.
  - It rises from c + (60, 16) to c + (60, 2) over 0.7 s and fades 1 → 0 over the last 0.3 s. Then it is gone until pierce is next switched on.
  - It stays within r ≈ 90 px of c, clear of the ring. The cracked shield badge carries the state from then on.
- **Badge punch:**
  - Keep `hub_flash` / `hub_hp_flash` as an integer step: draw at 5x for one 60 ms frame, then back to 4x, re-centred on the same visual centre.
  - Alternative: offset the badge -4 px in y for 60 ms. Do not scale continuously.
- **Old-number float** (`_hub_old`): spawn it from the BLK number anchor (+60, +41).
- **Sting burst origin:**
  - hurt = c + (0, 8), his chest;
  - block = c + (60, 40), the shield visual centre.
- **Death dim:** from the moment death reaches **f2**, draw both badges (and their numbers) at **alpha 0.35**. They stay dimmed until the run screen resets.
- **Naming:** don't rename existing identifiers or keys that contain "shield" (e.g. `shield_c`, any copy, sfx or log keys). Only the drawing changes.

## 4. Hall-wipe courier (`_walk_knight_off` and the second courier at main.gd ~7278)

- Frames `run_walkoff_f0..f3`, 70 ms each. `_courier.size = 96x96`, `_courier.scale = Vector2(1, 1)` (**scale 1.0**; it was 1.35). Keep `pivot_offset` (48,48) and the existing start, destination and tween.
- Gear: add child TextureRects under `_courier` (same size, NEAREST, order rope, goggles, cap|helm) and set them per frame from `gear_worn`.
- Only the knight sprite lookups change to hero_run: `art.run_frames("knight_m")` and `art.frames("knight_m")` for the player. **Do not** retarget the boss and weapon fallbacks in `dungeon_art.gd`: `"gargoyle": "knight_m"`, `knight_f`, `weapon_knight_sword`.

## 5. Copy

No player-facing text changes. The badges carry no text, the HP and BLK captions are removed, and the pierce float reuses the existing string. No new strings or keys.

## 6. Palette (exact cabin-goblin colours)

| group | colours |
|---|---|
| outline | #100e0c |
| skin | #c4e07a #8cbc48 #5a8a30 |
| hood | #86b4a4 #4f8a7c #33605a #1f3d3a |
| patch | #a07a48 #74562e |
| scarf | #d0644a #9a3428 #5e1c18 |
| rope belt | #d0b07a #8a6a40 |
| pouch / brass | #7a5436 #4a3020 #e8c36a #b08a3c #f8e6a0 |
| sack | #c4a574 #a08458 #74603e #4e4028 |
| shorts | #463a2c #6a5a46 |
| face | #1c1814 socket, #f0c040 eye, #f0e6d8 tooth/claw |
| cap | #a8382a #6e2420 #f0e6d8 #c9b9a8 |
| iron | #e8dcc4 #9aa2b0 #6a7282 #3a3e48 |
| goggles | #6e5426 #8ad0d8 #4a9aa8 |
| wood | #c8925a #a87448 #74502e (the cabin chair woods) |
| potion | the scarf reds + goggle glass |

The heater shield (in hand and on the badge) is iron band #e8dcc4 / #9aa2b0 / #6a7282 / #3a3e48 with brass rivets and plank wood #c8925a / #a87448 / #74502e.

## 7. Decisions (locked by Nathan, 2026-10-17)

1. **Death:** from death f2, both badges dim to 35%.
2. **HP / BLK captions:** dropped.
3. **Pierce:** shown by the `badge_blk_pierced` cracked shield, plus one short float-up of the existing pierce text above the shield. It never overlaps the ring. No new text.
4. **Courier scale:** 1.0.
5. **Faceplant:** head-left, as drawn (he topples away from the boss; the sack drops and spills at his feet).
6. **Cap feather:** shortened 1 px, so the cap starts on canvas row 1 and never clips on the 1 px rises (victory hop, walkoff). All 40 cap overlays were regenerated and re-verified.
7. **Badges level:** the shield's visual centre is on the heart's y. x is pushed to +38 for clearance (section 3).

## 8. Test checklist

Use the screenshot harness (`scripts/dev/shot_harness.gd`) or by hand. Each line is pass/fail.

1. Hub at idle: the goblin replaces the knight. 96x96 at c+(-48,-50), feet at c+(0,42), crisp pixels (no blur, no half-pixel), no code bob.
2. Heart rect at c+(-64,24); shield rect at c+(38,21). Both numbers centred at y = c.y+41 (HP x -42, BLK x +60). No HP/BLK captions anywhere.
3. BLK 0 shows `badge_blk_empty`, BLK > 0 shows `badge_blk`, BLK gained shows `badge_blk_up`. HP flash, low and 0 show their textures.
4. Pierce boss: the cracked shield shows, and the existing pierce text floats up once from above the shield and fades. No slash line, no static caption, nothing over the ring.
5. Each combat event plays its animation and returns to idle or lowhp:
   - swipe, with damage and sfx on f2;
   - hit;
   - block, with the BLK punch on f1;
   - heal;
   - lowhp loop at low HP;
   - grab on a draft/relic pick;
   - victory ×2 on a boss kill;
   - death, with the bump on f3, holding f4.
6. Death: both badges are at 35% alpha from f2 onward.
7. Gear: with helm+goggles+rope, then cap+goggles+rope, gear sits correctly on every animation frame on the hub. Cap and helm are never shown together. With no gear, nothing extra is drawn.
8. Clearance: in no frame do the sprite and the badges touch (screenshots of idle, swipe f2, block f1, heal f2, lowhp f0).
9. Hall wipe: the courier shows run_walkoff at scale 1.0 (96x96) with the worn gear, and walks off as before.
10. Untouched: the gargoyle/knight_m, knight_f and weapon_knight_sword fallbacks still resolve; no player-facing text changed (diff the copy and string files: no changes); no "shield" key or identifier renamed.
11. Cabin: see the checklist in SPEC-cabin-hero-wiring.md section 4. Gear is composited over sit, rock, walk, walk_sad, sack_dump and sack_shake; no hat-only frames.
