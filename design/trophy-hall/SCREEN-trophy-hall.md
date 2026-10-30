# SCREEN: Trophy Hall (five biome cases + dumbwaiter)

**Project:** Spinheritance (Godot 4.7) · repo `Nathan-Elequin/swipe` (local `C:\Users\Natha\Documents\boss-rush` on Cherry) · branch `playtest/latest` · tip read at **`3519eae2`** (`3519eae202849d95942229b24416f12ae2218a46`, 2026-10-30 01:17 CDT, "Fix playtest issues 189-194…")
**Design owner:** Pixel (Trophy Hall words are Pixel's for now; all strings below are STUB) · **Locked by Nathan:** 2026-10-30 (v1 pool-gating prop = **dumbwaiter**, strata **cut**; ~1:42 AM CDT: **pools are never trimmed — cases paginate**)
**Viewport:** 1680×1040 · art is native ×4, Nearest, PNG · Godot-safe only: Theme/StyleBox, 9-slice (NinePatchRect), Tweens, AnimatedSprite2D. No shaders.
**Supersedes:** `design/cabin-overhaul/SCREEN-trophy-hall.md` (shelf-era spec) for the hall room.

## Doop mockups (canvas `K5t2l_veMo`)
| # | Frame | id | PNG |
|---|---|---|---|
| 1 | TH · Overview — strata + dumbwaiter | `LQYDndcx0L` | https://doop.design/i/LQYDndcx0L.png?scale=2 · `/workspace/trophy-hall/TH_LQYDndcx0L@1x.png` |
| 2 | TH · Zoom — ornate fixture (Opened case) | `BFx-Nk9guT` | https://doop.design/i/BFx-Nk9guT.png?scale=2 · `/workspace/trophy-hall/TH_BFx-Nk9guT@1x.png` |
| 3 | TH · Prop close-ups — strata vs dumbwaiter | `8f1j8BSEe-` | https://doop.design/i/8f1j8BSEe-.png?scale=2 · `/workspace/trophy-hall/TH_8f1j8BSEe-@1x.png` |
| 4 | TH · Return unlock beat | `nAq0ZecRXO` | https://doop.design/i/nAq0ZecRXO.png?scale=2 · `/workspace/trophy-hall/TH_nAq0ZecRXO@1x.png` |
| plate | D-SHIP · Cabinets wall (clean plate) — **unchanged**, = tip `rooms/cabinets_wall.png` | `sSXqYUHvO2` | https://doop.design/i/sSXqYUHvO2.png?scale=1 · `/workspace/trophy-hall/ref/D-SHIP_cabinets_wall_sSXqYUHvO2@1x.png` |

Magenta callouts are build notes and never ship. **Frames 1 and 3 still show the strata column (option A). Ignore it. It is cut.** Use only the right half of frame 3 (option B) and the dumbwaiter in frame 1. All copy in the frames is STUB.

---

## 1. Behavior (what the player sees)

1. The hall is the existing plate (`rooms/cabinets_wall.png`, Doop `sSXqYUHvO2`). It shows five tall cases, left→right = depth 1→5: **Verdant Hollow** (green), **Crystal Cavern** (white/glacial pale blue-white; it replaces the olive Sunken Mire case on the plate), **Ashen Crypt** (grey stone arch + candles), **Cinder Forge** (orange rivets/ember), **Shadow Abyss** (black void, teeth). Players never see "Sunken Mire" or the word "Tier".
2. Each case has a **crown sign**, a **lamp** hanging above it, a glass front with a **fixed 2×5 peg face** (10 pegs per page, each with a placard underneath; pools with more items get more pages, §5.3), and a **brass plaque** below it on the floor line. The plaque has a depth icon and the STUB line "Wares of the Nth Depth and below".
3. Each case is in one of four states, read straight from save data (§5):
   - **Locked (tease):** a dusty sheet covers the whole case. Only the biome-colour hem, the biome crest and a padlock show. You can't see any items.
   - **In progress** (unlocked, fewer than 5 unique claimed): the sheet is gone, the glass is shut (sheen over the pegs), the lamp is dark, the crest is grey, and the crown shows `n` of 5 pips lit plus `n/total` (`total` = live pool size, any number).
   - **Opened** (any 5 unique from that pool claimed; it doesn't matter which 5): the glass door hangs open, the lamp is lit (flicker), the crest is in biome colour, the crown shows 5 gold pips plus `n/total`. Opening a case means the **next dungeon is unlocked**.
   - **Complete** (every item in the live pool claimed, **on every page**): Opened, plus the crown and case trim gild gold, and every placard on every page is gold. Twinkles keep cycling. **100%** means all five cases are Complete. There's no separate 100% UI in v1.
4. **Pegs never move.** Each item in the pool owns one fixed peg on one fixed page (stable order, §5.3). Pools are **not trimmed**: when a pool has more than 10 items, the case gets more 2×5 pages. A row of brass page ticks on the case base, with chevron studs either side, shows and flips the pages. Peg states:
   - **Unseen:** black silhouette of the item, blank dark placard.
   - **Seen, unclaimed:** grey diagonal hatch over the item, pencil-dashed placard showing its name.
   - **Claimed:** full-colour item, gold placard with its name, and a twinkle every 3–6 s at random.
5. The **dumbwaiter** stands against the left wall between the back doorway and the Verdant case (§3). It has five stops (stop N = depth N = case N), a lamp per stop, a biome-colour tab per ledge, a car hanging on two ropes, and a lever on its base. **Stop N's lamp is lit when pool N is available** (stop 1 always is; stop N>1 lights when case N−1 is Opened). Dark stops show a small padlock.
6. **Click a lit stop:** the car rides there in steps and parks, and its tray shows a silhouette from that pool. The matching case's lamp flares and the case pulses. That biome's node **pulses on the held (living) map** the next time the player opens it (Space).
7. **Pull the lever:** the car rides down from stop 1, pausing briefly at each lit stop (that case flares in turn), and parks at the deepest lit stop. Any click or Esc skips to the end.
8. **Click an unlocked case** to zoom 2× onto it. The rest of the room dims by ~25%. Hovering a peg puts an amber frame on it and opens a parchment lore panel with brass corners and a tail pointing at the peg. Esc, right-click or a click outside the case zooms back out (§6).
9. **Coming home with the 5th unique** for a pool plays the unlock beat (§7): the item flies to its peg, the glass swings open, the lamp comes on, the crest takes its colour, and the next case's sheet slides off with its padlock dropping. Then the existing map-piece ceremony runs (Nib explains the next dungeon). When the newly unlocked dungeon is the 3rd, 4th or 5th, a shortcut scene follows. It's only a hook in this pass (§7.4).
10. **The strata soil column isn't in the room.** Don't build any of it: no soil bands, no depth tabs column, no "DEPTHS" sign.

## 2. Ground truth on tip (read before you build)

All of these come from `origin/playtest/latest` = local `HEAD` = `3519eae2`. Cherry's working tree has about 127 uncommitted changes. Build from the tip, not that tree.

**Room + plate**
- `scripts/cabin/room_hall.gd`: `RoomHall` (extends `cabin_room.gd`). `_build_special()` swaps the bg to `CABINETS_WALL = "rooms/cabinets_wall.png"` (fallback `rooms/room_hall.png`) and spawns candles from `extra.anchors.hall.flame`. `_hide_retired_chrome()` hides ShelfPrev/ShelfNext/Gauge. `_refresh_doors()`: **SideDoor (right wall, native (378,132,32,63)) → Outpost/mudroom**, BackDoor → main.
- `data/cabin-layout.json` → `extra.anchors.hall = {hole:[76,56,298,160], back_door:[6,132,32,63], side_door:[378,132,32,63], cases_bounds:[76,56,298,160], flame:[[61,62]]}`. The `case_glass` heights there are a stale 138; the code uses 121. The hall placement list has `Flame0` at native (61,62).
- Measured on the plate (px): case outer left edges ≈ 300 / 550 / 794 / 1038 / 1282, each ≈190 wide. Crowns start at y≈150 and the floor line is y≈798. The left doorway frame ends at x≈172. **The free wall gap is x 172–300.** The right wall is entirely the Outpost door (x≈1484–1660). The olive b2 case paint, vines and moss reach **px x 536–748, y 149–794**.

**Cases**
- `scripts/biome_cabinets.gd` (`class_name BiomeCabinets`):
  - `CASES`: **b2 is still `"Sunken Mire"`** with olive `tint 2a2916 / accent 8a7a3e` and `trophy_sunken_mire`.
  - `CASE_GLASS` (native): `[82,68,48,121] [138,68,48,121] [202,68,48,121] [262,68,48,121] [322,68,48,121]`. `CASES_BOUNDS [76,56,298,160]`.
  - b2 note: the Crystal Cavern body stays at (132,24) (it must cover the olive paint), and its window is canvas (6,44), so `CASE_GLASS[1]` = (138,68). Spires sheet and gild origin = room (126,22).
  - `trophy_texture(case, hover)` loads `assets/dungeon/home/cabinets/trophy_<biome>{_hover}.png` (96×96 = 24 native ×4). That came in with trophy-slots PR #179 and #182.
  - `trophy_local_rect` / `trophy_reserved_height` seat that pedestal trophy in the glass top.
  - `peg_column_layout` is a **vertical scrolling column** (`PEG_FIT_MAX 6`).
  - `order_mounts` puts collected items first in swipe order and the rest in hash order. **That reshuffles pegs and breaks the fixed-slot lock.**
  - `STUB_NAMES` maps "The Warren"/"Slime Pits" → "Sunken Mire". `progress_text` clamps to `n/5`.
- `scripts/home_cabin.gd`:
  - `_rebuild_shelves` (1760) → `_fill_biome_cases` (1862) → `_build_biome_case` (1883). This is a hit-only overlay per case: a Clip plus a scrolling Column of `_mount_slot`s, with wheel scroll in `_on_case_wheel` / `_scroll_case`.
  - `_place_biome_trophy` (1966). `_paint_locked_pool` (2006) is chain + "?" and has **no callers**.
  - `_on_case_hover` (2095) shows the keys `cabin.hall.locked / past_gate / next_piece / full / gauge`.
  - `_mount_slot` (2478) has three states: swiped = `trophy_mount`, seen = `item_seen_overlay` grey frame, unseen = item modulate `(0.09,0.07,0.06)`. Left-click emits `inspect_wanted(id)`.
  - `_live_pool` (1786) excludes `retired`/`hold`/tokens. `_group_cards_by_pool` (1797). `_shown_count` (1810) reads the campaign ledger minus `_bank_hold`. `_case_collected` (1840).
  - `focus_biome_case(pool)` (501) is a modulate pulse. `open_hall_after_push_block` (480).
  - `_play_bank_sequence` (2125): bag smoke → rays → `_bank_fx_arc_to_mount` per item → `_bank_fx_loud_count` → for each crossed pool `cabinet_gate_crossed.emit` + `await _map_piece_beat.play(pool)` → toast `extract.delving_improves`. The arc FX and the S3 ceremony are skipped on Push/cheat/death paths.
  - Rooms are **plain Controls**: `_rooms_clip` → `_rooms_host` (854), panned by position. **There's no Camera2D or CanvasLayer anywhere in `home_cabin.gd` / `main.gd`.**
- `scripts/campaign_shell.gd`: `cabinet_count(state,pool)` (143), `biome_unlocked(rules,state,i)` (159: previous case ≥ `cabinet_quota`), `pool_unlocked` (167), `shortcut_open`, `can_start`.
- `scripts/cabin/map_piece_beat.gd`: `play(filled_pool)` → `SHELL.stamp_map_piece(...)` + `_ceremony(next_name)`. This is the existing "explain next" beat. Its copy is Spin's, so leave it unchanged.
- `scripts/cabin/held_map.gd`: `present(rules, state, monsters_by_id := {}, opts := {})` (living map PR #180), `_add_stamp`, `_peel`.
- `scripts/dev/biome_cabinets_selftest.gd` covers `trophy_texture` and the peg layout.
- `data/campaign.json`: **`biomes[1].name = "Sunken Mire"`**, `cabinet_quota 5`, `card_pools 1..5 → b1..b5`.
- **Live pool sizes** (catalog `status=live`, pool 1–5): b1 **10** (+2 `todo`, which `_live_pool` still counts → 12), b2 **11**, b3 **13**, b4 **14**, b5 **10**. These change often, so cases **paginate** in 2×5 pages: b1 2 pages (10 + 2 todo), b2 2, b3 2, b4 2, b5 1 (§5.3).
- Existing art to reuse: `assets/dungeon/home/cabinets/trophy_{verdant_hollow,ashen_crypt,cinder_forge,shadow_abyss}{,_hover}.png`, `plaque_glint_f0..f3.png` (16×8), `trophy_place_burst_f0..f4.png`, `fx/fly_spark_f0..f2.png`, `fx/fly_trail.png`, `fx/shelf_new_glow_f0..f3.png`, `fx/new_tag.png`, `lantern_glow.png`, `item_seen_overlay.png`.
- **There's no dumbwaiter, strata or case-sheet code on tip.** The legacy `cabinets/case_*.png` frames are on disk but not drawn.

## 3. Dumbwaiter (the v1 pool-gating prop)

### Placement (Pixel's call)
Frame 1 draws the shaft on the right wall, but on the plate that wall is the Outpost door, and `sSXqYUHvO2` is locked unchanged. So the shaft goes in the **left-wall gap freed by cutting the strata**: native **x 45–73, y 38–199** (px **180–292, 152–796**). It covers the plate's stool and wall sconce. **Delete the hall `Flame0` placement and set `anchors.hall.flame` to `[]`**, because that candle sat on the covered sconce. `room_hall_glow` stays. Z: plate 0 < glow 1 < shaft 2 < car/ropes 3 < lamps/lever 4 < hover tag.

### Geometry (native; ×4 for px)
| part | rect / anchor (room native) | notes |
|---|---|---|
| Shaft (`dumbwaiter_shaft.png`) | (45,38) 28×161 | header 20 tall (y 38–58, blank plank + pulley housing), well 5×25 (y 58–183), base 16 (y 183–199). Left stile x 45–52 holds the 5 lamp sockets. Car well x 53–70. Right stile x 70–73 holds the biome tabs. |
| Stop band k (1..5) | (45, 58+25(k−1)) 28×25 | **hit rect** = 112×100 px (≥48×64 ok) |
| Lamp k | (46, 58+25(k−1)+9) 6×6 | `dumbwaiter_lamp_off/on`. A dark stop draws `case_padlock.png` at scale 0.5 over its socket. |
| Biome tab k | (70, 58+25(k−1)+19) 3×4 | `dumbwaiter_tab.png` modulated with the case accent (§5.1) |
| Ledge k | baked in the shaft at y = 58+25k−2 | 2-px brass lip |
| Car | x 54, bottom at ledge k → y = 58+25k−2−14 | `dumbwaiter_car.png` 16×14. Tray window at local (3,3) 10×8. Item silhouette drawn there at 32×32 px. |
| Ropes | 2 ColorRects 1×N native `#4A3020`, from pulley (x 58 and 65, y 52) to car top | resize every tween step |
| Pulley | (54,42) 10×10 | `dumbwaiter_pulley_f0..f1` (optional), flips frames while the car moves |
| Lever | (62,181) 8×16 | `dumbwaiter_lever_f0` idle / `f1` mid / `f2` pulled. Hit rect native (58,179,14,20) = 56×80 px. |
| Header sign | label rect (47,41) 24×8 | Label `cabin.hall.lift_sign` (STUB "LIFT"). Silkscreen, ink `#1E120C` on the plank. |

### States and input
- `lit[k] = CampaignShell.pool_unlocked(rules, state, "b%d" % k)`. `deepest = max k where lit`.
- `_lift_stop` (session var, not saved) is where the car parks. Default = `deepest`. After the return unlock beat it's set to the newly lit stop.
- **Hover a lit stop:** lamp modulate 1.0→1.3 (0.08 s), cue `cabin.hover`, tag = the biome display name from `BiomeCabinets.resolved_cases` (data, so no new key). **Hover a dark stop:** tag `cabin.hall.locked` (existing key).
- **Click a lit stop k:** if the car is busy, ignore. Otherwise call `_lift_to(k)`, which is a stepped ride (below). On arrival:
  - cue `cabin.click`
  - lamp k flare: modulate 1.6→1.0 over 0.3 s
  - `_flare_case("b%d" % k)`: the case lamp flares like this one, then `focus_biome_case(pool)` (existing pulse)
  - tray texture = the silhouette of the first **unclaimed** item in that pool's fixed slot order (modulate `(0.09,0.07,0.06)`, same as unseen). If the pool is Complete, the tray shows that pool's crest at 0.5.
  - `_map_focus_pool = "b%d" % k`
- **Click a dark stop:** cue `cabin.locked`. The lamp socket shakes x +1/−1/0 native at 50 ms steps. Nothing else happens.
- **Lever click** (when not busy): frames f0→f1→f2 at 80 ms, cue `cabin.click`. Then the tour: `_lift_to(1)`, and for each lit k from 1 to `deepest` do the arrival effects above with a 0.5 s pause, then park at `deepest` and set `_map_focus_pool` to it. Lever goes back f2→f1→f0. During the tour, input on stops is ignored. **A click anywhere or Esc** jumps the car to `deepest`, kills the tour tweens and resets the lever.
- **Stepped ride:** `tween_method(_set_car_y, from_y, to_y, 0.14 s × |Δstops|)`, with `_set_car_y` snapping to whole native px (`floor(y/4)*4` in screen px) so the car moves in pixel steps. It pauses 0.06 s at each ledge passed. Ropes are resized in `_set_car_y`. Pulley frames advance every 2 native px.
- **Map node pulse:** `home_cabin` passes `{"focus_pool": _map_focus_pool}` in `opts` when it opens the held map. `held_map.gd` then pulses that pool's stamp once: scale 1→1.12→1, twice, 0.18 s per half, `TRANS_QUAD`. After that `_map_focus_pool` is cleared. Locked pools never get a stamp, so there's nothing to pulse.
- While the hall is zoomed (§6) or the bank sequence is running, the dumbwaiter ignores input.

## 4. Room-level changes
- `anchors.hall.hole` and `cases_bounds` become **[0,0,420,260]** (the full room), and `_hole.clip_contents = false` in the hall. Crowns, lamps, sheets and plaques sit outside the old hole, and case roots are now positioned in plain room coordinates (`native × PX`). Update `BiomeCabinets.CASES_BOUNDS` to match. `CASE_GLASS` keeps its values.
- New per-case **outer rects** (room native; the sheet, gild and hit area use these):

| pool | outer rect | shape | crown label rect | lamp anchor (top-centre) | plaque rect |
|---|---|---|---|---|---|
| b1 | (75,37,48,163) | rect | (77,40,44,13) | (99,22) | (76,201,46,12) |
| b2 | (132,24,60,176) **Crystal Cavern body** | spires | (137,40,44,13) | (159,14) | (137,201,46,12) |
| b3 | (198,38,48,162) | arch | (200,44,44,11) | (222,22) | (199,201,46,12) |
| b4 | (259,38,48,162) | rect | (261,40,44,13) | (283,22) | (260,201,46,12) |
| b5 | (320,38,48,162) | rect (teeth) | (322,40,44,13) | (344,22) | (321,201,46,12) |

  The plaques sit on the floor line, px y 804–852. Check these by eye against the plate and adjust by at most 2 native. The b2 body PNG is placed at native (132,24) (px 528,96) and must fully cover the olive paint (px x 536–748, y 149–794).

## 5. Cases

### 5.1 Data changes (locked names, not copy invention)
- `data/campaign.json` `biomes[1].name` → **"Crystal Cavern"**.
- `BiomeCabinets.CASES[1]` → `{"id":"b2","name":"Crystal Cavern","tint":"2a4a60","accent":"b4d6ea","frame":"cabinets/case_crystal_cavern","trophy":"cabinets/trophy_crystal_cavern"}`.
- `STUB_NAMES`: "The Warren"/"Slime Pits" → "Crystal Cavern".
- Keep `case_sunken_mire.png` / `trophy_sunken_mire*.png` on disk (unused).
- Accents used for the sheet hem and lift tab: b1 `7dae62`, b2 `b4d6ea`, b3 `a8a29a` (ash grey; replaces red `8d3d3d` for the hem only), b4 `d06a28`, b5 `4c4588`.

### 5.2 State derivation (new statics in `BiomeCabinets`, pure, selftested)
```gdscript
enum CaseState { LOCKED, IN_PROGRESS, OPENED, COMPLETE }
static func case_state(rules, state, pool: String, slot_ids: Array) -> int
#   LOCKED      if not CampaignShell.pool_unlocked(rules, state, pool)
#   COMPLETE    if every pool item (all pages) is in state.banked
#   OPENED      if CampaignShell.cabinet_count(state, pool) >= quota_of(rules)   # any 5 unique
#   IN_PROGRESS otherwise
static func peg_state(id, banked: Dictionary, seen: Dictionary) -> int   # UNSEEN / SEEN / CLAIMED
static func fixed_slots(cards: Array) -> Array   # see 5.3; ALL pool items, stable order, any size
static func page_count(n: int) -> int            # maxi(1, ceili(n / 10.0))
static func slot_page(i: int) -> int             # i / 10
static func page_state(slot_ids, page, banked) -> int  # PAGE_FULL if every id on that page is claimed, else PAGE_OPEN
static func crown_text(claimed: int, total: int) -> String     # "%d/%d" over ALL pages
static func pips_lit(count: int, quota: int) -> int                      # mini(count, quota)
```
- Use the same counting `_shown_count` uses today, so items still held for the bank animation don't show early.
- Claimed = in the campaign `banked` ledger, or the legacy `swiped` when there's no campaign (current `_is_shelved`). Seen = existing `seen` / `_bank_hold`.

### 5.3 Fixed slots + pagination (replaces `order_mounts` for the hall). Nathan lock: pools are never trimmed; cases expand
- **Pool = the exact set the ledger counts:** `_group_cards_by_pool()[pool]`, which uses the same `_live_pool` filter as `_case_collected`. The pages therefore always show every item Complete needs. **There's no cap and no trimming.**
- **Order:** `fixed_slots(cards)` sorts by `(tier asc, name asc, id asc)`. It's computed from catalog data only, never from collection order, so nothing reshuffles while you collect. (Adding or removing catalog items can shift later slots. That's expected while pools are in flux.)
- **Placement:** global slot `i` → page `i / 10`, local slot `i % 10` → column `(i % 10) % 2`, row `(i % 10) / 2`. Every page uses the same ornate 2×5 peg face. The last page leaves any unused cells as **empty recesses** (recess + ledge only, no placard), so the face never changes shape.
- **Page bar (diegetic, on the case base, not a UI pager).** `PageBar` sits at room native `(glass.x, 190, 48, 6)`, the strip of case base between the glass bottom (y 189) and the plaque. It's only built when `page_count > 1`. Left→right:
  - **Chevron stud ◀** (`case_page_chevron.png` 4×5, flipped for ▶): brass. Its hover alt is `_hover`. It's dimmed to α .35 on the first page (and ▶ on the last). Paging doesn't wrap.
  - **Page ticks**: one per page, 3×3 native, 2-native gap, centred. Colours:
    - **current page:** amber `#F09A34`
    - **page fully claimed:** gold `#FFD84A`
    - **other pages:** dark `#3A2A1C`
    - all ticks have a 1-native `#1E120C` outline
  - **Chevron stud ▶**.
  - Up to 7 ticks fit. Beyond 7, show 7 ticks windowed around the current page with a 1-native gap-dot at the clipped end(s). Still no text.
- **Hit targets:**
  - **Overview:** the whole PageBar is one 192×(24+16) px hit strip (it pads 4 native up into the glass edge and down to the plaque top). Click on its left half = previous page, right half = next. Mouse wheel over the case flips pages: down = next, up = prev, 0.2 s debounce. Hovering the PageBar shows no tag. This replaces the tip's wheel-scroll column.
  - **Zoom (2×):** each chevron stud and each tick is its own hit (≥ 32×32 px on screen at 2×). Clicking a tick jumps to that page. ←/→ arrow keys flip pages while zoomed (they no longer pan rooms in zoom).
  - Locked cases have no PageBar: the sheet covers it.
- **Flip animation (stepped, Godot Tween):** the `Glass` clip holds a `PageStrip` (Control) with each page laid out at `x = page * 48 native`. A flip tweens `PageStrip.position.x` to `−page × 192 px` over 0.18 s via `tween_method` snapped to 4 px, so it slides a native pixel at a time. Then cue `cabin.click` and update the ticks. The door sheen (f0) stays put over the glass; only the pegs slide. Only the current and adjacent pages need to exist (build lazily, keep at most 3). The rest are rebuilt on flip.
- **Page memory:** `_case_page[pool]` is session-only (not saved). It defaults to the **first page that has an unclaimed item**, or 0 if Complete, and survives zoom in/out and `_rebuild_shelves`.
- **Pages follow the action:**
  - Bank arc (§7): before `_bank_fx_arc_to_mount(id, pool)`, flip that case to `slot_page(index_of(id))` (0.18 s) so the item always lands on a visible peg.
  - Dumbwaiter tray: shows the first unclaimed item across all pages.
  - Inspect/lore: hovers whatever page is showing.
- **Crown count** = `claimed / total` over all pages. **Pips** stay the 5-unique Opened gate.
- Delete the hall's scroll column (`_case_scroll`, `_case_columns`, `_case_clips`, `_on_case_wheel`, `_scroll_case`, `peg_column_layout` in the hall); the wheel now flips pages. Delete `_place_biome_trophy` from the glass top, because the page face uses the full glass. Move the pedestal trophy to the crest (5.5).

### 5.4 Peg cell (inside `CASE_GLASS`; cell 24×24 native = 96×96 px, 2 cols × 5 rows = 48×120)
| layer | rect in cell (native) | spec |
|---|---|---|
| Recess | (1,0,22,17) | StyleBoxFlat bg `#120C09`, border 1 native (4 px) `#2B1A12` |
| Item | (4,0,16,16) | item art `tex_by_item[id]` / `art.item_tex(id)`, 64×64, Nearest. Unseen: modulate `(0.09,0.07,0.06)`. Seen: modulate `(0.55,0.55,0.58)` + Hatch. Claimed: WHITE. |
| Hatch | (4,0,16,16) | `item_seen_hatch.png` (seen only) |
| Ledge | (0,17,24,2) | StyleBoxFlat `#5C3A22` with 1-native top line `#8A5A32` |
| Placard | (1,19,22,5) | NinePatchRect: `placard_blank_9` (unseen) / `placard_seen_9` (seen) / `placard_gold_9` (claimed) |
| Placard label | inside the placard, 1 native padding | catalog `name`, upper-cased, via `KIT.fit_label` 12→8 px. Ink `#1E120C` on gold. Pencil `#6E6E6E` on seen. Unseen shows no label. |
| Twinkle | (16,−2) 16×8 | AnimatedSprite2D `plaque_glint_f0..f3` at 60 ms, one-shot, re-armed by a Timer every `randf_range(3,6)` s (claimed only) |

### 5.5 Case chrome per state (`scripts/cabin/trophy_case.gd`, new `TrophyCase extends Control`)
| element | Locked | In progress | Opened | Complete |
|---|---|---|---|---|
| Sheet (`case_sheet_<shape>` + hem mask modulated by accent) | visible | hidden | hidden | hidden |
| Sheet crest (trophy_<biome>.png at 0.5, colour) + padlock (`case_padlock`) | visible, centred at sheet y 40% / 58% | – | – | – |
| Crown: crest (trophy_<biome> @0.5 = 48 px) + biome name + 5 pips + `n/total` | hidden by the sheet | crest `trophy_<biome>_grey`, pips n/5 | crest colour, 5 gold pips | same + gild |
| Glass door (`case_door_<rect\|arch>` AnimatedSprite2D) | hidden | f0 (shut, sheen) | f3 (open) | f3 |
| Lamp (`case_lamp_*` + `lantern_glow.png` modulate `#F09A34` α .5) | off, no glow | off | on flicker f0..f2 @140 ms, glow | on |
| Gild (`case_gild_<shape>`) | – | – | – | visible, + `plaque_glint` sweep on the crown every 4–7 s |
| Pegs + PageBar | not built | 2×5 page(s) + PageBar if >1 page | same | same, every page gold, every tick gold |
| b2 body (`case_crystal_cavern.png`) | always drawn (under the sheet) | ✓ | ✓ | ✓ |

- Shapes: b1, b4, b5 = `rect`; b3 = `arch`; b2 = `spires`. The door uses `arch` for b3 and `rect` for everything else.
- Crown pips are Godot-drawn: five 3×3 native squares, 1-native gap, on `#FFD84A`, off `#3A2A1C`, 1-native `#1A120E` border. Name: biome display name, Silkscreen 700, 12–16 px, fit to the crown label rect. Ink `#1E120C` on the light crowns (b2, b3), `#EFE0B6` on the dark ones (b1, b4, b5).
- Hover a case (overview): Locked → `cabin.hall.locked`. Other states → the existing `_on_case_hover` keys, and the crest swaps to `trophy_<biome>_hover` while hovered (reuses trophy-slots behaviour).
- Click a case: Locked → cue `cabin.locked`, no zoom. Otherwise zoom (§6).
- Pegs in the overview are **not** individually hoverable (too small). Peg hover and click only happen in zoom.

### 5.6 Brass plaque (each case)
NinePatchRect `case_plaque_9.png` at the plaque rect (§4), margins 4 native. Contents, left→right:
- Depth icon: five 2×5 native bars, 1-native gap. The first N are filled `#FFD84A`, the rest `#4A3020`, outline `#1E120C`.
- Label `cabin.hall.plaque` with `{ordinal}` = `cabin.hall.ordinal_N`, Silkscreen 10→8 px, 2 lines max, ink `#1E120C`.

Plaques show in every state, including Locked.

## 6. Zoom view + lore panel + item hover
- **Zoom rig:** the cabin is all Controls with no Camera2D (§2). A Camera2D wouldn't move these Controls if HomeCabin sits on a CanvasLayer. So build the locked "Camera2D 2× zoom" as a Tween on the `RoomHall` Control. The framing is identical.
  - `pivot_offset = Vector2.ZERO`. Target `scale = Vector2(2,2)`. `position = clamp((840,520) − 2·case_center, (−1680,−1040), (0,0))`.
  - Zoom in 0.35 s `TRANS_QUAD/EASE_OUT`, zoom out 0.25 s. Store the room's pre-zoom position and scale, and restore them exactly.
  - Both values are whole multiples, so pixels stay crisp under Nearest.
- **Dim:**
  - a ColorRect `#0B0706` covering the full room, inside `RoomHall`, alpha 0→**0.25** over 0.35 s. `z_index` above the plate and the other cases.
  - The focused `TrophyCase` gets `z_index` above the dim for the duration.
  - The dumbwaiter stays under the dim and its input is off.
- **Exit:** Esc (`ui_cancel`), right-click, or a left-click anywhere outside the focused case's outer rect zooms out. Room pan, arrow keys and door hotspots are disabled while zoomed.
- **Peg hover (zoom only):**
  - Amber frame: a Panel with StyleBoxFlat, no fill, border 1 native `#F09A34`, with an outer 1-native `#1A120E` line around the cell's recess+placard. It appears in 0 ms and goes away on exit.
  - cue `cabin.hover`.
- **Lore panel** (`LorePanel`, screen space, *not* scaled with the room; z 110 like `fly_tip`):
  - StyleBoxFlat bg `#EFE0B6`, border 4 px `#1A120E`, corner radius 0, hard shadow `#0B0706` offset (0,6) size 0, content margin 20/16.
  - Four `lore_corner_brass.png` TextureRects (24×24) in the corners, flipped with `flip_h`/`flip_v`.
  - Tail: a 16×20 px Polygon2D in parchment with a 4-px ink outline Line2D, on the side facing the peg. Its y tracks the peg centre, clamped 24 px from the panel corners.
  - Width 520 px. Placed right of the focused case if it fits within 1680−24, otherwise left. y is centred on the peg and clamped to 24…1016.
  - Content (VBox):
    1. Item icon 32 px + name, Pixelify Sans 700 28 px, ink `#1E120C`.
    2. Sub-line: `{biome} - ` + `cabin.hall.plaque` text, Silkscreen 12 px `#6E5434`.
    3. Body: `lore.json items.<id>.journal`, VT323 24 px `#4A3020`. **Omit the body if there's no entry.**
    4. A 1-px dashed rule `#A8946C`.
    5. Footer row: state word (`cabin.hall.lore_claimed` or existing `cabin.tip.seen`) on the left. On the right, the difficulty chip `PlayerCopy.tier_name(tier).to_upper()` on a `UxStyle.metal(tier)` StyleBoxFlat with a 3-px `#1A120E` border.
  - Per peg state:
    - **Claimed:** everything above.
    - **Seen:** name + sub-line + chip + `cabin.tip.seen`, no journal (same rule as today's `fly_tip`).
    - **Unseen:** only `cabin.tip.locked` (existing) in a one-line panel, no name.
  - The mock's "CLAIMED - RUN 12" has no run data on tip, so it's dropped.
- **Peg click (zoom):** claimed or seen → existing `inspect_wanted.emit(id)`. Unseen → nothing. Right-click on a peg still means zoom out. Playtest builds keep `comment_wanted` on right-click when `PLAYTEST_FLAG.on()`, which takes priority on pegs.

## 7. Return unlock beat (frame 4, about 1.2 s stepped after the arc)
This hooks into `_play_bank_sequence` when a pool crosses the gate (`crossed` already exists). It only runs on the extract path: never on Push interrupt, cheats or death (same guard as today).

1. **Panel 1, "bring home the 5th":** first flip the case to the item's page if needed (§5.3, 0.18 s). Then, as today, `_bank_fx_arc_to_mount(id, pool)` flies the item to its **fixed peg** (`_bank_mount_global_center` must resolve the new peg node name `Peg_<id>`). On landing, the peg rebuilds as claimed (gold placard), `trophy_place_burst` plays and cue `cabin.trophy` fires.
2. After `_bank_fx_loud_count`, for each `pool_id in crossed`, in order, `await _case_opened_beat(pool_id)`. This runs before `cabinet_gate_crossed.emit` and `_map_piece_beat.play`:
   - **Panel 2 (0.55 s):**
     - door frames f0→f1→f2→f3 at 100 ms each, cue `cabin.click`
     - lamp flicker on→off→on (60/60 ms), then loop f0..f2, with the glow alpha tweening 0→.5 over 0.15 s
     - crest **stays grey** for 0.15 s
   - **Panel 3 (0.65 s):**
     - crest texture swaps to colour, with a `plaque_glint_f0..f3` one-shot over it (40 ms/frame) and cue `cabin.glint`
     - then the **next** case (index+1, if it exists and is now unlocked): its sheet tweens `position.y += sheet.size.y` over 0.35 s (`TRANS_QUAD/EASE_IN`), clipped to that case's outer rect, with modulate α→0 over the last 0.1 s
     - its padlock drops separately: y +40 px and α→0 over 0.2 s. cue `cabin.locked` is *not* used here; use `cabin.glint`.
     - the next case is now In progress (glass shut, lamp dark, crest grey)
     - at the same moment the dumbwaiter's stop lamp for that pool turns on (frame swap plus a 1.6→1.0 flare), and `_lift_stop` is set to that stop. The car rides there after the beat ends.
3. Then the existing `cabinet_gate_crossed.emit` and `await _map_piece_beat.play(pool_id)` run. That's "explain next" plus the map node inking in, all existing and Spin-owned copy, unchanged.
4. **Shortcut hook:** if the newly unlocked biome index is 2, 3 or 4 (the 3rd/4th/5th dungeon), emit the new signal `shortcut_scene_wanted(pool_id: String)` after the map-piece beat. Main connects nothing yet. The Spelunky-style scene is a separate SCREEN and not part of this pass.
5. The change is permanent by construction: `TrophyCase` derives its state from the save on every `_rebuild_shelves()`, so no "opened" flag is needed. The Push-block path (`open_hall_after_push_block`) skips the beat and just shows the new state.
6. The beat ignores `_wait` skip (pass `ignore_skip=true`) only for the door and sheet tweens. A click skips straight to the final states.

## 8. Godot build sketch
```
RoomHall (scripts/cabin/room_hall.gd)                     scale/position tweened for zoom
 ├─ Bg (cabinets_wall.png — unchanged)
 ├─ room_hall_glow
 ├─ _hole (now full room, clip off) → _shelf_host
 │    ├─ Case_b1 … Case_b5 (TrophyCase, Control STOP, outer rect §4)
 │    │    ├─ Body        TextureRect (b2 only: cabinets/case_crystal_cavern.png)
 │    │    ├─ Glass       Control at CASE_GLASS rect, clip_contents
 │    │    │    └─ PageStrip (Control, x-tweened) → Page_n (Control 48×120 native) → Peg_<id> ×≤10 (Control 96×96): Recess, Item, Hatch, Ledge, Placard(NinePatchRect), Label, Twinkle
 │    │    ├─ PageBar     Control (only if >1 page): ChevL TextureRect, Ticks HBox(Panel 12×12 px), ChevR TextureRect
 │    │    ├─ Door        AnimatedSprite2D (door_rect|door_arch: "shut"=f0, "swing"=f0..f3 @10fps once, "open"=f3)
 │    │    ├─ Gild        TextureRect (Complete)
 │    │    ├─ Crown       Control: Crest TextureRect(48px), Name FitLabel, Pips HBox(5 Panel), Count Label
 │    │    ├─ Lamp        AnimatedSprite2D (off | on f0..f2 @140ms) + Glow TextureRect (lantern_glow, additive CanvasItemMaterial blend ADD)
 │    │    ├─ Sheet       Control clip → SheetTex, HemTex(modulate accent), SheetCrest, Padlock
 │    │    └─ Plaque      NinePatchRect + DepthBars + Label
 │    └─ (bank FX use _bank_fx_host as today)
 ├─ Dumbwaiter (scripts/cabin/dumbwaiter.gd, Control at native (45,38) 28×161)
 │    ├─ Shaft TextureRect · Pulley AnimatedSprite2D · RopeL/RopeR ColorRect · Car TextureRect + Tray TextureRect
 │    ├─ Stop1..5 (Control hit 112×100) → Lamp TextureRect, LockMark TextureRect, Tab TextureRect
 │    ├─ Lever (TextureButton-like Control + AnimatedSprite2D f0..f2)
 │    └─ Sign Label (cabin.hall.lift_sign)
 ├─ ZoomDim ColorRect (#0B0706, α 0)
 ├─ BackDoor / SideDoor / SignOutpost (unchanged)
 └─ (LorePanel lives in HomeCabin overlay layer, screen space)
```
- `dumbwaiter.gd` signals: `stop_chosen(pool)`, `tour_started`, `tour_finished`. API: `refresh(lit: Array[bool], park: int)`, `light_stop(k, flare := true)`, `ride_to(k) -> Signal`. All Tweens use `set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)` like `focus_biome_case`.
- `home_cabin.gd`:
  - `_fill_biome_cases` builds `TrophyCase`s from `BiomeCabinets.fixed_slots` (all items, paged) and calls `dumbwaiter.refresh`. `_case_page` is session-only.
  - `_open_hall_zoom(pool)` / `_close_hall_zoom()`
  - `_case_opened_beat(pool)`
  - `_map_focus_pool` is forwarded to `held_map.present(..., opts)`
  - new signal `shortcut_scene_wanted(pool_id)`
  - remove the scroll and pedestal code (§5.3)
- Textures load through `_home("cabinets/…")` / `_home("hall/…")`. If a PNG is missing, fall back to Godot-drawn placeholders (ColorRect / StyleBoxFlat in the palette), log once, and keep going. A missing asset must never crash and must never show the old olive case.
- Selftest `scripts/dev/biome_cabinets_selftest.gd`, add:
  - `case_state` truth table (locked / in-progress at 4 / opened at exactly 5, any 5 / complete)
  - `fixed_slots` is stable when shuffled input and banked order change
  - `fixed_slots` keeps every item (a pool of 23 → 23 slots, `page_count` 3, slot 22 → page 2 cell 2); `page_count(0..10)=1`, `(11)=2`; `page_state` is FULL only when every id on that page is claimed; Complete needs every page
  - b2 display name is "Crystal Cavern", and no `CASES` entry is "Sunken Mire"
  - `pips_lit` clamps
- **Don't invent mechanics:** no new currency, no new unlock rules, no new save keys (`_lift_stop` and `_map_focus_pool` are session-only), no sound files (reuse the cues listed).

## 9. Copy (all player-facing strings in this room; every new one is STUB, owner Pixel / Trophy Hall)
| key | STUB text | where | status |
|---|---|---|---|
| `cabin.hall.plaque` | `Wares of the {ordinal} Depth and below` | case plaque, lore sub-line | **NEW STUB** |
| `cabin.hall.ordinal_1..5` | `1st` `2nd` `3rd` `4th` `5th` | `{ordinal}` | **NEW STUB** |
| `cabin.hall.lift_sign` | `LIFT` | dumbwaiter header | **NEW STUB** |
| `cabin.hall.lift_lever` | `Pull` | lever hover tag | **NEW STUB** |
| `cabin.hall.lore_claimed` | `Claimed` | lore panel footer | **NEW STUB** |
| `cabin.hall.locked` · `cabin.hall.past_gate` · `cabin.hall.next_piece` · `cabin.hall.gauge` · `cabin.hall.full` · `cabin.tip.locked` · `cabin.tip.seen` · `cabin.room.hall` · `cabin.hall.sign_outpost` | existing | case/peg/stop hover | unchanged |
| biome names, item names, `lore.json` journals, `PlayerCopy.tier_name()` | data | crown, placards, panel | unchanged (b2 name per Nathan lock) |
| `nib.homecoming`, map-piece ceremony lines, `extract.delving_improves` | existing (Spin) | after the beat | **don't touch** |

- Add the new keys to `data/player-copy.additions.json` (and `player-copy.json` / `.csv` if that's how the build reads them on tip) with `"status": "STUB"` and the note `"Trophy Hall — Pixel owns for now"`.
- Nothing is baked into PNGs: no text, no digits on lamps.
- No "Tier", "Swipe" or "boss rush" anywhere.
- **Flag for Spin:** the crown `n/total` and the plaque line are the only new visible words. Page ticks are wordless. Everything outside the hall stays Spin's.

## 10. Repot REQ checklist (screenshots, 1680×1040)
Inbox `playtest/repot/inbox/REQ-20261030-trophy-hall-dumbwaiter.md`. Outbox `playtest/repot/outbox/REQ-20261030-trophy-hall-dumbwaiter/shots/`.

| id | setup | expect | file |
|---|---|---|---|
| 01 | Fresh save → cabin → hall | Verdant In progress (glass shut, lamp dark, grey crest, pips 0–n). b2–b5 sheeted: hem + crest + padlock only. The b2 sheet shows ice spires. Dumbwaiter on the left wall: stop 1 lit, 2–5 dark with padlocks, car at stop 1. **No strata column, no olive case.** Plaques read 1st…5th. | 01-hall-fresh.png |
| 02 | DEV `fill_b1` → hall | Verdant Opened (door open, lamp lit, colour crest, 5 gold pips, `n/12`, PageBar with 2 ticks). Crystal Cavern unsheeted, glacial white/blue body, In progress. Stops 1–2 lit, car at 2. | 02-hall-b1-opened.png |
| 03 | Click stop 2 (car elsewhere first) | Car rides in steps to stop 2. Crystal Cavern lamp flares and the case pulses. Tray shows an item silhouette. | 03-stop-click.png |
| 04 | Click the lever; capture mid-tour | Lever at the pulled frame, car between stops, ropes the right length | 04-lever-tour.png |
| 05 | After 03, press Space | Held map opens and the Crystal Cavern stamp pulses | 05-map-node-pulse.png |
| 06 | Click the Verdant case, hover a claimed peg | 2× zoom, room dimmed ~25%, amber frame on the peg, parchment lore panel with brass corners + tail, journal text, chip with no "Tier" | 06-zoom-claimed.png |
| 07 | Zoomed: hover a seen peg, then an unseen peg (2 shots) | Seen: grey hatch, dashed placard with name, panel without journal. Unseen: black silhouette, blank placard, `cabin.tip.locked` only. | 07a-zoom-seen.png, 07b-zoom-unseen.png |
| 08 | Press Esc | Back to the overview, pixel-identical to 02 | 08-zoom-out.png |
| 09 | Real extract bringing the 5th Crystal Cavern unique (3 captures) | a: item mid-arc to its fixed peg · b: door mid-swing, lamp on, crest still grey · c: crest in colour, Ashen sheet sliding off, padlock dropping, stop 3 lamp lit. Then the map-piece ceremony plays. | 09a/09b/09c-unlock-beat.png |
| 10 | DEV grant all Verdant items | Verdant Complete: gilded crown + trim, placards gold on **both pages**, both ticks gold, twinkles | 10-complete.png |
| 11 | Hall, Cinder Forge unlocked (DEV) → wheel over the case, then zoom and click ▶ and a tick (3 shots) | Overview: page 2 of 2 slid in stepped, tick 2 amber, last page shows empty recesses with no placards. Zoom: chevrons/ticks clickable, ←/→ flip. | 11a-page-wheel.png, 11b-page-zoom.png, 11c-page-tick.png |
| 12 | Real extract where the claimed item lives on page 2 of its case | Case flips to page 2 before the arc lands on the fixed peg | 12-bank-flip.png |

**Pass:**
- every PNG is present
- `biome_cabinets_selftest` is green
- `grep -ri "sunken mire" scripts data/campaign.json` turns up only the legacy filenames
- no "Tier" on screen
- tip SHA is recorded in RESULT.md
- the build report lists page counts per pool

## 11. Open questions (Pixel picked a default so nothing is blocked)
1. ~~Pool sizes vs a fixed 2×5 grid~~ **Resolved by Nathan (2026-10-30 ~1:42 AM CDT):** pools are not trimmed and not a rigid 2×7. Cases paginate in 2×5 pages (§5.3), and Complete counts every page.
2. **Dumbwaiter on the left wall instead of the right.** That's because the right wall is the Outpost door on the locked plate. Moving it right means a new plate with the door moved.
3. **The map-node pulse plays on the next held-map open**, rather than opening the map automatically from the hall.
