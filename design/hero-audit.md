# Hero appearance audit

Audit only (2026-10-17). No code or art changes. Goal: replace the in-run knight (Kenney `knight_m`, shield in hand) with the cabin goblin thief.

There is no dedicated run-hero shot harness. Cabin poses use `home_cabin.debug_pose`. Run poses were forced through existing functions (`_start_tutorial`, hub sting fields, `_sync_overlay`). Screenshots: `design/hero-audit/*.png` at **1680×1040**.

Viewport is `project.godot` `window/size/viewport_width=1680`, `viewport_height=1040`.

---

## 1. Every place the player character is drawn

The run “hero” is **not a scene node**. It is a `draw_texture_rect` inside `BossWheel._draw_hub_block`. The cabin goblin **is** nodes (`Sprite2D` / `TextureRect` / `AnimatedSprite2D`).

### 1.1 Wheel hub (combat, ready, draft, tutorial, hall wipe)

| Field | Value |
|---|---|
| Script | `scripts/boss_wheel.gd` |
| How it draws | `_draw()` → `_draw_hub_block()` — **no Sprite2D** |
| Runtime path | `/root/Main/@MarginContainer@5/@HBoxContainer@6/@VBoxContainer@7/@Control@8/@Control@19` (`wheel_view`) |
| Node type | `Control` (`BossWheel`) |
| Texture | `art.frames("knight_m")` → atlas idle `knight_m_idle_anim_f0..f3` |
| Native size | **16×28** (`assets/dungeon/tile_list.txt` 162–165) |
| Draw size | **56×80** screen px (`boss_wheel.gd` 1629) |
| Scale | **3.5×** wide, **~2.86×** tall (non-uniform) |
| Position | Wheel center `c` + `(0, -6 + bob)` + `hub_nudge`. Bob: `sin(_glow_t * 4) * 2` (1618–1619) |
| Pivot | Texture rect centered on that point (`ppos - psz * 0.5`) |
| z-index | Wheel `z_index = 0` (`main.gd` 777) |
| flip_h | Never |
| Wired | `main.gd` 771: `wheel_view.set_player(art.frames("knight_m"))` |
| Frames API | `dungeon_art.gd` 243–252 (`idle_anim` first) |
| Visible on | Ready, fighting, slaying, draft (behind the door), tutorial, defeat-under-overlay (then covered). Hidden when cabin is up. |

Hub circle: `draw_circle(c, radius * HUB_FRAC)` with `HUB_FRAC = 0.34` (`boss_wheel.gd` 22, 887). On a 640×640 wheel, `_radius()` = 294.4 so hub radius ≈ **100 px**.

Idle frame advance: `int(_glow_t / 0.18) % tex_player.size()` (1627) → **~5.56 fps**, 4 frames, loops.

### 1.2 Hall-wipe courier (between dungeons)

| Field | Value |
|---|---|
| Node | `_courier` created in `main.gd` 1007–1016 |
| Runtime path | `/root/Main/@TextureRect@168` |
| Type | `TextureRect` |
| Size | 96×96, `pivot_offset` (48, 48), **scale 1.35** during walk-off (2115–2117) |
| Texture | `art.run_frames("knight_m")` then idle fallback (`main.gd` 2114–2117) |
| Native | 16×28 run frames (`tile_list.txt` 166–169) |
| z-index | 100, `top_level = true` |
| flip_h | false on knight-off; monster couriers may flip (`_walk_courier` 7276) |
| Trigger | `_play_hall_wipe` → `_walk_knight_off` (`main.gd` 2084, 2112–2137) |
| Motion | Center of wheel → off the right edge in 0.62 s; frame swap every 0.07 s |
| SFX | `run.knight_off` (`data/sfx-map.json` 3189; `main.gd` 2097, 2126) |

Same `_courier` node is reused for **monster** walks, item flies, and draft slams. Only `_walk_knight_off` uses player art.

### 1.3 Cabin idle chair (hub / main room)

Two stacked implementations share origin **(10, 205) native = (40, 820) screen**.

**A. Layout hotspot (what you see on the menu)**

| Field | Value |
|---|---|
| Data | `data/cabin-layout.json` 322–341, node `"Hero"` |
| Class | `CabinHotspot` extends `TextureRect` (`scripts/cabin/cabin_hotspot.gd`) |
| Runtime | `/root/Main/CabinRoot/RoomsClip/RoomsHost/RoomMain/Hero` |
| Texture | `hero_rock_f0.png` |
| Native / shipped | 32×32 / **128×128** |
| Scale | 1.0 (files are already 4×) |
| Position | origin × 4 → (40, 820); `centered` N/A (Control top-left) |
| z | 5 |
| flip_h | no |
| Hover | none |
| Click | `cabin.hot.chair` → `_on_chair` (`home_cabin.gd` 2911–2912, 3089) |

Shown by `_set_idle_hero_visible(true)` in `show_menu` (328). **Static frame 0 only.** Not the rock loop.

**B. Homecoming rock loop (after an arrive)**

| Field | Value |
|---|---|
| Node | `_rock` `AnimatedSprite2D` (`home_cabin.gd` 2469–2475) |
| Position | `_pt(10, 205)` = (40, 820), `centered = false` |
| Frames | `hero_rock_f1, f2, f3, f0` at **4 fps**, loop (`home_cabin.gd` 759–760) |
| z | 5 |
| Visible | After `_settle_arrive_chair` (1283–1287). **Hidden** on normal `show_menu`. |

### 1.4 Cabin walking Sprite2D (arrive / drop / sit / cheer)

| Field | Value |
|---|---|
| Node | `_hero` `Sprite2D` named `"Hero"` (`home_cabin.gd` 642–648) |
| Runtime (after interior reparent) | `/root/Main/CabinRoot/RoomsClip/RoomsHost/RoomMain/@Sprite2D@…` |
| Host | Reparented: `_ext_root` outdoors, main room indoors (`_host_hero` 803–809) |
| Filter | nearest, `centered = false` |
| z | 1 exterior; 2 doorway; 4 interior walk (835, 871, 888) |
| Scale | 1.0 |
| Texture size | 128×128 (32×32 native × 4) |
| Placement | `_place_hero` (812–816): `position = _pt(x, y)`; if `flip_h`, **x += 32 native** so the feet stay put |
| Default hidden | `show_menu` sets `_hero.visible = false` (323) |

### 1.5 Rope exit (challenge rest)

| Field | Value |
|---|---|
| Script | `scripts/cabin/rope_exit.gd` |
| Runtime | `/root/Main/@Control@391/@Sprite2D@398` |
| Type | `Sprite2D`, `centered = false`, z 4 |
| Idle texture | `hero/hero_idle_loot_f0.png` (101) |
| Position | `KIT.pt(170, 200)` = **(680, 800)** |
| Native / shipped | 32×32 / 128×128 |
| Screen | Full-bleed overlay z 80 (29) |
| Climb | Tween x to 400, then y to −160; swap `hero_climb_f0/f1` every 0.32 s (156–172) |
| Deeper | Tween toward hole, scale 0.6, fade (175–188) |

Layout twin (not the live node): `data/cabin-layout.json` 1087–1100.

### 1.6 Map overlay marker

| Field | Value |
|---|---|
| Script | `scripts/cabin/map_overlay.gd` 78, 185 |
| Type | `AnimatedSprite2D` |
| Art | `overlays/map_hero_f0.png`, `map_hero_f1.png` |
| Native / shipped | **16×16** / 64×64 (`SIZES.md` 302) |
| fps | 1000/400 = **2.5 fps**, loop |
| Position | pin tip − (8, 28) native (`map_overlay.gd` 185) |
| z | 3 |

This is a paper-doll marker, not the 32×32 thief.

### 1.7 Cutscene panels (painted, not a sprite)

`scripts/cabin/cutscene_player.gd` 219–232. Full-frame PNGs:

- `assets/dungeon/home/cutscenes/intro_p1.png` … `intro_p5.png`
- `ending_p1.png` … `ending_p3.png`
- `keyring_p1.png`

The goblin is **baked into the illustration**. No `Sprite2D`. Replay from study (`play_intro(true)`).

### 1.8 Screens where the hero does **not** appear

| Screen | What you see instead |
|---|---|
| Combat stage | **Monster** portrait (`scripts/combat_stage.gd`). 192×160, right of wheel. Not the player. |
| Ability slash | Item/monster art (`scripts/ability_slash.gd`) |
| Draft door actor | Mystery owner / relic, not the player. Hub knight still sits on the wheel behind a 0.34-alpha wash (`draft_gate.gd` 300). |
| Caught / defeat overlay | Headline + button. No sprite. Hub is under an almost-opaque `Color("100e0cf2")` (`main.gd` 1100). |
| Pause | Settings sheet. Cabin chair or hub may peek around the edges depending on veil. |
| Tutorial | Highlights the **hub**. Same knight draw. |
| Dummy | Workshop prop `props/dummy.png` — training dummy, not the player (`cabin-layout.json` ~810). |
| Journal portraits | Monsters / items (`journal_overlay.gd`). |
| Wall portraits | `PortraitSmall` / `PortraitBig` flavor art. |

---

## 2. Animations and tweens

### 2.1 Run knight (hub)

| Name | Frames | fps | Loop | Trigger |
|---|---|---|---|---|
| Atlas idle | 4 (`idle_anim_f0..3`) | ~5.56 (`_glow_t / 0.18`) | yes | Always while hub draws |
| Atlas run | 4 (`run_anim_f0..3`) | ~14 (0.07 s/frame) | during tween | `_walk_knight_off` only |
| Atlas hit | 1 (`hit_anim_f0`) | — | — | **Never used.** `dungeon_art.hit_frame` (262) has no callers. |
| Idle bob | — | 4 rad/s, ±2 px | yes | `_draw_hub_block` |
| Hurt sting | tint red, nudge (5, 3), HP floater, burst on sprite | 0.30 s | no | `play_hub_sting("hurt")` (`boss_wheel.gd` 274; `main.gd` 5183) |
| Block sting | tint blue, nudge (−2.5, 0), punch BLK badge, burst on shield icon | 0.34 s | no | `play_hub_sting("block")` (`main.gd` 5197) |
| Item punch | BLK badge scale via `hub_flash` | 0.28 s | no | `punch_hub()` (`boss_wheel.gd` 267; `main.gd` 9688) |
| Screen flash | full-viewport `fx_flash` | 0.32 s fade | no | `_flash_screen` (`main.gd` 10705) red on hit, blue on block, gold on clear |

**There is no attack / swipe / heal / death / victory clip on the knight.** Item use does not change the body. Death is the overlay. Victory leaves the wheel (rope or cabin).

### 2.2 Cabin goblin

Times from `home_cabin.gd` and `assets/dungeon/home/SIZES.md`. Files are 4× of 32×32 unless noted.

| Family | Frames | Timing | Loop | Wired? | Trigger |
|---|---|---|---|---|---|
| `hero_walk` | 4 | 8 fps | yes | yes | Interior walk without sack (`_begin_walk` loot=false, 1019) |
| `hero_walk_loot` | 4 | 8 fps | yes | yes | Exterior path + interior with sack (838, 892, 1001) |
| `hero_walk_sad` | 4 | 8 fps (spec) | yes | **no** | Art exists; loss arrive still uses `walk_loot` |
| `hero_idle_blink` | 2 | hold 1.5–3 s / 120 ms | — | yes | Doorstep wait (`home_cabin.gd` 858) |
| `hero_idle_loot` | 2 | — | — | rope only | `rope_exit.gd` 101 (f0 only, not the blink pair) |
| `hero_drop_sack` | 4 | 140/140/220/160 ms | no | yes | `_play_drop` 1038; bump on f2 |
| `hero_sit` | 5 | 150/120/110/200/250 ms | no | yes | `_play_sit` 1054; bump on f3 |
| `hero_rock` | 4 | 4 fps | yes | hotspot = f0 static; `_rock` = loop after arrive | Chair |
| `hero_cheer` | 2 | 160 ms each, twice | no | yes | `_play_cheer` 2790 after ending |
| `hero_climb` | 2 | ~160–320 ms | during climb | yes | `rope_exit.gd` 162–170 |
| `hero_sack_dump` | 5 | spec 48×40 | no | **no** | Win dump never plays |
| `hero_sack_shake` | 6 | spec 48×40 | no | **no** | Loss empty-sack never plays |

Tweens (not SpriteFrames): exterior camera pan; walk along Bezier (`home_cabin.gd` 980–1004); rope x then y (`rope_exit.gd` 160–164); deeper scale+fade (182–186); cheer has no y-tween in code (SIZES asked for −4 px on f1; not implemented).

### 2.3 Events with **no** hero body animation today (should probably get one)

1. **Attack / swipe** in combat — monster lunges (`combat_stage.lunge`); hub stays on idle.
2. **Heal** (potion, cleric, Victory Flask, etc.).
3. **Death** — overlay only; no slump / fall.
4. **Victory / dungeon clear** — gold flash, then rope or cabin. No hub cheer.
5. **Picking a card / draft slam** — door animates; hub idle.
6. **Stealing / looting a relic** at the gate.
7. **Low HP** — hearts dim and hub HP badge flashes; body does not change.
8. **Item use** — slash portrait + hub BLK punch only.
9. **Block** — blue tint, not a raise-shield pose (and the goblin has no shield).
10. **Loss homecoming** — still the loot walk + drop; `walk_sad` / `sack_shake` unused.
11. **Win homecoming dump** — `sack_dump` unused; drop_sack plays even on loss (sack hidden if loss, `home_cabin.gd` 1278).
12. **Wearing gear in a run** — see §5.

---

## 3. Hero-related UI (offsets vs the body)

All hub offsets are in **wheel local pixels**, relative to wheel center `c`. On a 640 wheel, `hub_r ≈ 100`.

| Element | Where | Offset from `c` | Notes |
|---|---|---|---|
| Body | `draw_texture_rect` 56×80 | `(0, -6 + bob)` + `hub_nudge` | `boss_wheel.gd` 1618–1630 |
| HP heart | filled polygon + number | `(-22, hub_r * 0.42)` ≈ **(-22, 42)** | 1636–1646 |
| BLK “shield” | **drawn polygon**, not the knight’s shield sprite | `(24, hub_r * 0.42)` ≈ **(24, 42)** | 1660–1675 |
| “HP” / “BLK” labels | under badges | +22 y (HP), `sw*0.92+8` (BLK) | |
| Hurt floater | `-%d` | starts at HP pos, rises `−36 * t` | `play_hub_sting` 280–286; `_draw_floaters` 1601 |
| Hurt burst | 6 rays + arc | origin = **sprite** `ppos` | 1691 |
| Block burst | same | origin = **BLK badge** | 1691 |
| Pierce slash | across BLK badge | — | 1676–1683 |
| Old BLK ghost | fading previous number | BLK badge | 1684–1687 |
| Top-left hearts | `hearts_box` 6× `TextureRect` 32×32 | play-field `(8, trophy_h+4)` → global ~(28, 12) | `main.gd` 723–738, 10803–10806. Kenney `ui_heart_full`, **not** parented to the hub sprite. Hidden when overlay is up (10617). |
| Trophy | skull count | above hearts | not the hero |
| Screen flash | `fx_flash` ColorRect, z 60, full rect | — | `main.gd` 1018–1024 |
| Shadow | none on hub | — | Rock PNG has a baked shadow on row 31 (`SIZES.md` 48) |
| Shader | none on hub | — | Tint is `Color.WHITE.lerp(red/blue, sting)` (1621–1625). `combat_stage` outline shader is for **monsters**. |

BLK UI is a **geometric shield**. That reads as “you are a knight with a shield” even before the sprite swap. Replacing the body without touching this badge will still say shield.

---

## 4. Knight / shield references

### 4.1 Asset stems and ids (must change for a goblin run body)

| Ref | File:line | Role |
|---|---|---|
| `art.frames("knight_m")` | `main.gd` 771 | Hub idle |
| `art.run_frames("knight_m")` | `main.gd` 2115 | Walk-off |
| `_walk_knight_off` | `main.gd` 2112 | Function name |
| `run.knight_off` | `main.gd` 2097, 2126; `data/sfx-map.json` 3189 | SFX cue id |
| `knight_m_idle_anim_f0..3` | `assets/dungeon/tile_list.txt` 162–165 | 16×28 |
| `knight_m_run_anim_f0..3` | 166–169 | 16×28 |
| `knight_m_hit_anim_f0` | 170 | Unused |

### 4.2 Same atlas stem, **not** the player (do not retarget blindly)

| Ref | File:line | Role |
|---|---|---|
| `"gargoyle": "knight_m"` | `dungeon_art.gd` 28 | Fallback stem; gargoyle has `MONSTER_PNG` extra |
| `"anvil"/"juggernaut": "knight_f"` | 36–37 | Other monsters |
| `"shield"/"breastplate"/"spiked_shield": "weapon_knight_sword"` | 43, 55, 65 | Item **fallback** atlas; extras exist in `ITEM_PNG` |

### 4.3 Player-facing copy keys (list only; not edited)

**No copy key contains `knight`.**

Keys that say **shield** (the item, or the word):

- `tutorial.beat.05.body`
- `tutorial.beat.07.body`
- `tutorial.beat.07.go`
- `tutorial.beat.07.hint`
- `taunt.shield.1` … `taunt.shield.5`

Defeat sheet (comments still say Caught; live headline is locked **Defeated**):

- `title.lose`
- `title.lose_sub`
- `defeat.home`

Keys that already call the player a **goblin / thief / raccoon** (useful once the sprite matches):

- `intro.p1`
- `tutorial.beat.01.body`
- `tutorial.beat.17.body`
- `taunt.shield.1` (“raccoon”)
- plus other `taunt.*.*` lines that say “thief”

Card name/ability for item Shield live in the catalog (`data/catalog.json` / board), not as `card.item.shield.*` rows in `player-copy.json`.

---

## 5. Cabin goblin vs run knight, and gear

### Two different characters today

| | Cabin | Run |
|---|---|---|
| Species | Goblin thief, 32×32 native, 4× PNGs | Kenney knight, 16×28 atlas slice |
| Folder | `assets/dungeon/home/hero_*.png` and `assets/dungeon/home/hero/` | `assets/dungeon/atlas.png` stem `knight_m` |
| Node | Sprite2D / TextureRect / AnimatedSprite2D | `draw_texture_rect` on the wheel |
| Loader | `dungeon_art.home_tex` → `res://assets/dungeon/home/%s.png` (`dungeon_art.gd` 312–316) | `dungeon_art.frames("knight_m")` |
| Gear | Saved in `gear_worn` | Never read |

### Gear (cap / goggles / helm / rope)

- Slots: `head` (helm **or** cap), `eyes` (goggles), `belt` (rope). `data/cabin-layout.json` 1390–1395.
- Save: `user://home_cabin.json` via `home_cabin.gd` 36, 1987–1989, 2032.
- Rack: `_refresh_gear` hides the peg when that piece is worn (`room_main.gd` 81–92).
- Chair click with anything worn **hangs it back up** (`_on_chair` 3089–3093).
- Overlay PNGs exist per family under `assets/dungeon/home/hero/gear/{cap,goggles,helm,rope}/` (`SIZES.md` 204–251). Spec says **draw above** the base frame.

**Worn gear is not visible on the body today.** `_set_hero_frame` (`home_cabin.gd` 3247–3260) would load `hero/gear/{piece}/{family}_fN.png` and **replace** `_hero.texture` (not composite). **Nothing calls it.** All live walks/sits/cheers set `_hero.texture` directly. The idle chair hotspot is a single `hero_rock_f0` with no overlay. `_hero_layers` (`home_cabin.gd` 92) is unused.

**Runs never look at `gear_worn`.** Swapping the hub to goblin frames would still show a bare thief unless run code grows the same overlay path.

### Cabin comment

`home_cabin.gd` 2: “Gear is cosmetic.”

---

## 6. Space limits

Screen is 1680×1040. Native ÷ screen depends on the spot’s scale.

### Combat hub (the tight one)

Measured with tutorial/combat up: wheel **640×640** at global ~(520, 57); center local (320, 320); hub radius **100**.

| | Screen px | Native px |
|---|---|---|
| Current body | 56×80 | 16×28 |
| Hub disk | diameter ~200 | — |
| HP / BLK badges | ~32–36 wide, sit **42 px below** center | — |
| Safe box (inside disk, above badges) | about **90×70** | at current scale ≈ **26×24**; at cabin 4× ≈ **22×17** |

A cabin goblin **32×32 at 4× = 128×128** does **not** fit. It would cover HP/BLK and spill the hub. Options for the swap:

1. Draw the 32×32 goblin at ~2× (~64×64) and keep badges.
2. New 16×28 (or 16×32) run sheet, hub stays 56×80.
3. Move HP/BLK off the hub if the body must stay 128.

### Cabin chair (40, 820) 128×128

| Neighbor | Screen | Gap |
|---|---|---|
| Fire | (304, 656) 128×128 | ~136 px to the right-up |
| Nib | (864, 688) | far |
| Floor | screen bottom 1040 | 92 px below sprite |

Safe grow: about **160×160** screen (**40×40** native) before the fire fights it. 32×32 at 4× is already the language of this room.

### Rope exit (680, 800) 128×128

Ladder at x=384, hole at x=1000. Horizontal room ~200 px either side. Climbing goes **up off-screen**; tall frames are fine. Keep width ≤ ~48 native (192 px) so the hole/ladder stay readable.

### Map marker

16×16 at 4× = 64×64. Keep this small; it sits on a pin.

### Walk-off courier

96×96 × 1.35 ≈ **130×130**. Transient, rightward. 32×32 goblin at ~3–4× fits.

### Cutscenes

Full 1680×1040. Separate painted panels; not a drop-in sprite.

---

## 7. Screenshots

All 1680×1040, `design/hero-audit/`.

| File | State | How it was posed |
|---|---|---|
| `01_cabin_idle.png` | Chair, static `hero_rock_f0` | Default cabin `show_menu` |
| `02_cabin_walk.png` | Exterior loot walk | `debug_pose("walk")` |
| `03_cabin_drop_sack.png` | Interior drop f2 (hotspot still on — `debug_pose("drop")` does that) | `debug_pose("drop")` |
| `04_map_hero.png` | 16×16 map marker | `debug_pose("map")` |
| `05_cabin_cheer.png` | `hero_cheer_f1` on the rug | Forced texture |
| `06_rope_exit_idle.png` | `hero_idle_loot_f0` | `rope_exit.open_exit` |
| `07_tutorial_hub_idle.png` | Knight hub + How to Play | `_start_tutorial` |
| `08_combat_idle.png` | Knight hub + goblin **monster** stage | Tutorial closed, `show_monster("goblin")` |
| `09_combat_hit.png` | Red sting + screen flash | `hub_sting = hurt` |
| `10_combat_block.png` | Blue sting + BLK punch | `hub_sting = block` |
| `11_combat_attack.png` | **Monster** lunge; hub still idle | `combat_stage._lunge_x = 22` |
| `12_caught.png` | Defeat overlay (`title.lose` = “Defeated”) | `_sync_overlay` at `phase == "defeat"` |
| `13_pause_in_run.png` | Settings over combat | `settings_ui.open_menu(true)` |
| `14_pause_cabin.png` | Settings over chair | `open_menu(false)` |
| `15_rope_climb.png` | `hero_climb_f0` mid-ladder | Forced texture + position |
| `16_draft_gate.png` | Mystery door; hub still on the wheel | `draft_gate.present_mystery` |

Not captured as a live frame (art is the panel PNG itself): intro / ending / key-ring cutscenes. Not captured: `walk_sad`, `sack_dump`, `sack_shake` (unwired). Not captured: hall-wipe courier (0.62 s).

---

## Summary

| Spot | Node | Native | Scale / draw | Animations needed |
|---|---|---|---|---|
| Wheel hub | `BossWheel` draw, not a sprite | 16×28 knight | 56×80 (3.5× / 2.86×) | Idle (have), hit, block, attack, low HP, death, victory, item use |
| Hall walk-off | `_courier` TextureRect | 16×28 run | 96×96 @ 1.35 | Walk (have, knight). Goblin walk_loot or walk |
| Cabin chair idle | `RoomMain/Hero` TextureRect | 32×32 | 128×128 @ 1 | Rock loop (art exists; menu uses f0 only) |
| Cabin arrive | `_hero` Sprite2D | 32×32 | 128×128 @ 1 | Walk loot, blink, drop, sit (wired). Sad / dump / shake unwired |
| Cabin cheer | same `_hero` | 32×32 | 128×128 | Cheer (wired, ending only) |
| Rope rest | `rope_exit._hero` Sprite2D | 32×32 | 128×128 | Idle loot, climb, vanish into hole |
| Map | AnimatedSprite2D | 16×16 | 64×64 @ 1 | Tiny bob (have) |
| Draft / tutorial | same hub draw | 16×28 | 56×80 | Steal / pick-card if you want a tell |
| Caught | overlay Label | — | — | Optional slump before overlay |
| Pause | settings; chair or hub behind | — | — | None |
| Cutscenes | TextureRect panels | full frame | 1680×1040 | Already painted goblin |
| Gear overlays | unused `_set_hero_frame` | 32×32 / 48×40 | 4× | Composite in cabin **and** run if gear should show in delves |

**Swap implication:** you cannot paste the 128×128 cabin thief onto the hub. The run needs a smaller sheet (or the hub UI has to move). Gear is cabin-save only and does not draw on anyone.
