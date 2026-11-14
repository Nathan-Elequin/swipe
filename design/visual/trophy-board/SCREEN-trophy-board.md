# SCREEN — Trophy Board (cabin Trophy Hall redesign)

**Status:** spec draft by Pixel, 2026-11-13, for Nathan's locked decisions of 2026-11-13. Supersedes `design/trophy-hall/SCREEN-trophy-hall.md` and `design/cabin-overhaul/SCREEN-trophy-hall.md`.
**Code facts** (file:line) are in `AUDIT.md`. **Art** is in `ASSETS.md`. **Work split** is in `PACKAGES.md`.
**Conventions:** see `design/visual/_COMMON.md`. 1680×1040 viewport; cabin art is 420×260 native at ×4. Integer scales only. All words go through `PLAYER_COPY.text(key, fallback)`. Never show "Tier", "ATK" or any number/counter on the board. Every tween respects `Engine.time_scale`.

The one sentence the screen has to teach: **"Bring home five different things from a place and the way deeper opens. Bring home all of them and Grandpa's shortcut opens."**

---

## 1. Player flow at a glance

```
Run ends (Leave / Nib push-block / death / give up)
  → cabin EXTERIOR (existing arrive walk; click the door)
  → fade 0.4s straight into the TROPHY HALL (main room skipped)
      [first successful return only: key-ring tour from main, then Nib moves to the hall, §9]
  → HOMECOMING: satchel rises; each new item flies to its slot (~2.0s each); lights fill
  → if 5 lights and the next portal is still shut: LEVER glows; Nib prompts; player pulls
        → RUMBLE → PORTAL SPLASH (Nib) → MAP: fog lifts off the next node → NEW-POOL REVEAL (Nib) → back to the hall
  → if the board just hit 100%: GOLD FRAME → SHORTCUT SPLASH (Nib) → MAP: path line drawn, node glows, "Start here"
  → idle: browse the board (←/→, arrows, rails, dots); walk ← to the main room; open the map (Space or the wall map) to start a run
```

There is no Outpost and no post-run menu. **The held map in the main room (or Space anywhere in the cabin) is the only way to start a run.**

---

## 2. Layout @ 1680×1040 (px; native = px ÷ 4)

Room plate: new `rooms/room_trophy.png` (ASSETS A1). It has the left doorway to main, no right door and no painted frame. Back-wall floor line ≈ y 790; characters' feet ≈ y 816.

| Element | Rect (x, y, w, h) px | Native | Notes |
|---|---|---|---|
| **Board outer** (frame, incl. feet) | 176, 40, 1328, 776 | 44,10,332,194 | 79% of the room width. Stands on two stubby feet at y 816. |
| Frame borders | top 88 · sides 48 · bottom 72 | 22 · 12 · 18 | Top band holds the plaque. Bottom band holds the dots. |
| **Face viewport** (clip; slides) | 224, 128, 1232, 616 | 56,32,308,154 | `clip_contents = true`. All per-biome content lives here. |
| Backdrop (per biome) | = face viewport | 308×154 | Tinted painted panel, ASSETS B3. |
| **Header plaque** | 600, 16, 480, 96 | 150,4,120,24 | Sticks 24 px above the frame. Biome name, centred, EB Garamond SemiBold 40, ink `#1c120c` on brass, max 400 px wide (`FitLabel` down to 30). |
| **Crest** | 240, 144, 96, 96 | 60,36,24,24 | Face-local. Slides with the face. |
| **Lights ×5** | x 672 + k·72, y 140, each 48×64 | 12×16 each, 6-native gap | Row centre x 840. Face-local. |
| **Lever** | 1344, 136, 64, 128 | 336,34,16,32 | Face-local. Hit rect is 96×160 centred on it. |
| **Pyramid area** | 224, 272, 1232, 464 | 56,68,308,116 | Rows from §3. |
| Slot (normal) | 128×128 | 32×32 | Item sprite drawn at 128 (= stored 64 px ×2, 8× native). |
| Slot (compact) | 80×80 | 20×20 | Sprite drawn at 64 (×1). Used only when the normal layout overflows (§3). |
| **Arrow L / R** | 176, 396, 48, 80 · 1456, 396, 48, 80 | 12×20 | Sit on the side rails. |
| **Rail hit zones** (click a side) | 176, 128, 48, 616 · 1456, 128, 48, 616 | | Whole rail is clickable; hovering lights the arrow. |
| **Biome dots ×5** | x 712 + k·56, y 764, each 32×32 | 8×8 | On the bottom band. Hit rect 48×48. |
| New pip | dot + (20, −6), 16×16 | 4×4 | |
| **Gold "complete" trim** | = board outer | 9-slice | Shown while the current face is 100%. |
| **Satchel** (homecoming only) | 744, 872, 192, 160 | 48×40 | Starts off-screen at y 1040. Mouth anchor (840, 892). |
| **Skip** (homecoming only) | 1504, 984, 152, 40 | | Text button, alpha 0.40 idle / 0.85 hover. |
| **Nib** (idle, after relocation) | 1544, 688, 96, 128 | 386,172,24,32 | Feet at y 816, right of the board. The hotspot is the same rect. |
| Back doorway (existing) | hotspot native 8,114,32,130 | | `BackDoor` → main. Unchanged. |
| Hover card | ≤ 520 wide | | Existing parchment lore card. Placed 12 px above the slot, flips below if it would go above y 16, x clamped to [16, 1664 − w]. |

Z order, back to front: plate → board backdrop → slot recesses → item sprites → claimed aura (behind the sprite: insert it before) → lights/lever/crest → frame (over the face edges) → plaque → dots → gold trim → Nib → satchel/flying items/FX → hover card → dialog → skip.

---

## 3. Pyramid layout (data-driven; Nathan will move items)

Implement `scripts/trophy_board_model.gd` (pure static, no nodes, unit-testable):

```
faces(rules, items_by_id) -> Array[Face]   # one per rules.biomes[i], in order
Face = { pool_id, name, index, rows: {3: [ids], 2: [ids], 1: [ids]} }
```

- **Membership:** card status not in {retired, hold}, not a token, not an always-starter (`BucketRules.is_always_starter`), and `CampaignShell.pool_for_bucket(rules, BucketRules.of_card(card)) == pool_id`. Use the same membership in `_bucket_entries` and in the 100% check. **There must be one function, called everywhere.**
- **Order inside a row:** name asc, then id asc. Same rule as `BiomeCabinets.fixed_slots`, so positions are stable across saves. Tier comes from `BucketRules.tier_of` (clamped 1–3).
- **Row geometry** (no constants per biome):
  1. Try normal: slot 128, hgap 24, max 8 per line. Each tier is one line. Tier 3 on top, 2 in the middle, 1 at the bottom. Line width `w = n·128 + (n−1)·24`, `x0 = 840 − w/2`. Lines stack from the top of the pyramid area with vgap 40. With 3 lines, `3·128 + 2·40 = 464` fills the area exactly.
  2. If any tier has more than 8 items or there are more than 3 lines: compact mode. Slot 80, hgap 16, max 14 per line, vgap 16. A tier with more than 14 items wraps onto extra lines, which stay contiguous and centred. Capacity is 4 lines × 14 (`4·80 + 3·16 = 368` ≤ 464); the block is centred vertically in the pyramid area.
  3. If even that overflows, `push_warning` and the selftest fails. The pool editor should flag it.
  4. An empty tier takes no line. The remaining lines centre vertically.
- Today's data (all fit normal mode): b1 3/5/6, b2 3/6/5, b3 3/5/6, b4 2/5/5, b5 2/5/4 (top/mid/bottom).
- The board rebuilds faces from data on every `show_menu` and after any `content-board` save (pool editor `_on_save` → `home_cabin.rebuild_board()`).

---

## 4. Item slot states

| State | Rule | Look | Hover card |
|---|---|---|---|
| **UNSEEN** | not in `seen` and not banked | Dark recess + item sprite as a **silhouette in code**: `modulate = Color(0.04, 0.03, 0.025, 0.92)` (same as `bucket_reveal.gd`). No art. | `board.tip.unseen`, no name |
| **SEEN** | seen, not banked (or banked but still in `_bank_hold`, i.e. not presented yet) | Dark recess + **plain sprite**, no glass, glint or aura | Item name only |
| **CLAIMED** | banked and presented | Lit brass-rim recess + full-colour sprite + **claimed aura** (looping gold shimmer behind the sprite) + a twinkle every 3–6 s (random phase per slot) | Name + `cabin.tip.journal` + journal body + footnotes (from `lore.json`). With no lore entry: name + `board.tip.claimed_nolore`. |
| **FRESH** (overlay on CLAIMED) | claimed and not in `board_viewed` | Same as CLAIMED, plus a 0.6 s brighten-and-settle the first time the face is shown. It also drives the dot pip. | same as CLAIMED |

Rules:
- On a locked face every slot is forced to UNSEEN, whatever the save says.
- Clicking a SEEN or CLAIMED slot emits `inspect_wanted(card_id)` (the existing inspect panel). Clicking UNSEEN gives a small bump and `cabin.locked`.
- The card shows no rank chip, no "Wares of the Nth Depth" line and no ATK. Remove those from `_show_lore_panel`.
- A face is **viewed** once it has been on screen for 0.6 s with no slide in progress. That adds its claimed ids to `board_viewed`.

---

## 5. Lights, lever and gates

### 5.1 Definitions (`trophy_board_model.gd` + `campaign_shell.gd`)

```
claimed_unique(state, face)  = |{ id ∈ face.ids : banked.has(id) }|      # current membership, not the stored pool string
lights_lit(face)             = portal_opened(next(face)) ? 5 : min(5, claimed_unique − held_in_this_face)
lever_state(face)            = LOCKED  if lights_lit < 5
                               READY   if lights_lit == 5 and not portal_opened(next(face))
                               SPENT   if portal_opened(next(face))
complete(face)               = face.ids non-empty and claimed_unique == |face.ids|
portal_opened(biome_id)      = state.map_pieces.has(biome_id)              # "endless" for b5's lever
biome_unlocked(i)            = i == 0 or portal_opened(biomes[i].id)
can_start(i)                 = i == 0 or state.shortcuts.has(biomes[i].id)
```

- Duplicates never count, because `banked` is a set.
- The threshold is still `cabinet_quota` (5) from `campaign.json`. Only the stored meaning changes: the portal opens when the **player pulls the lever**, not automatically at bank time. That gives the "the button opens it" moment Nathan asked for and keeps the same 5-unique rule.
- **Lights are latched** once the portal is open. If Nathan later moves items out of a pool, an opened face still shows 5 lit and a spent lever.
- **Shortcuts are latched** in `state.shortcuts`. Moving or adding items later never revokes an earned start.
- Endless: the b5 lever's "next" is `endless`. Pulling it sets `endless_unlocked = true` (still requires `cabinets_complete`, which is always true by then, because boards open in order).
- `push_needs_nib` = `not biome_unlocked(next)`. If the player has 5 lit but has not pulled the lever, the in-run Nib block uses the new line `nib.push_block.lever`.

### 5.2 Locked face (biome i whose portal is shut)

Full pyramid in silhouette. Padlock overlay (ASSETS B6) centred on the pyramid area. Five unlit lights. Lever hidden. The plaque name is shown with `modulate 0.7`. Padlock hover: `board.locked.tip` with `{prev}`. Lights hover (any face): `board.lights.tip`. This is how Nathan's "prove you understand 5 unique" is taught without a counter. **Every face, locked or not, shows five sockets that fill one per different find.**

### 5.3 Lever states → art

| State | Art | Hover | Click |
|---|---|---|---|
| LOCKED | `lever_locked` (dull, chained catch) | `board.lever.locked` | bump + `cabin.locked` |
| READY | `lever_ready` + glow halo pulsing 1.2 s; the 5 lights do a slow chase | `board.lever.ready` | starts §7 |
| SPENT | `lever_pulled` (down, no glow) | `board.lever.spent` with `{next}` | nothing |

---

## 6. Homecoming timeline

Entry (main.gd): every run end calls one function, `_go_home(kind, new_ids, held_ids, push_block)`, which **replaces** `_open_progress_menu` + `_finalize_progress_menu_result`. The ledger work (`CampaignShell.bank`, `swipe_ids`, `end_run`, seed next run) is unchanged. Then `home_cabin.open_cabin(walk_in = true, kind, new_ids, held_ids)`.

1. **Exterior** (existing `_show_exterior` / `_play_arrive` walk). The arrive ends with the door glowing and clickable. Clicking the door or the cabin, or pressing Enter, → `_fade_to_interior(target)`: 0.2 s to black, then 0.2 s in.
   - `target = "hall"` if the hall is unlocked, else `"main"`.
   - On the first successful return (`key_ring` due) the target is `"main"`. The key-ring tour runs, and at the end Nib walks into the hall (§9). The homecoming then runs in the hall.
   - Tutorial returns keep the existing `play_arrive_splash` → main (no items credit).
2. **Hall settle** (0.0 s): the board opens on the face of the first pending item. With nothing pending it opens on `board_face` (last viewed), defaulting to the deepest unlocked face. Input locked except Skip and Esc.
3. **No new items** (`bank_pending` empty after filtering to board ids): Nib says one line: `nib.board.empty.*` for a win with nothing new, `nib.home.loss.*` for death or give-up. Then idle (§10). Satchel stays hidden.
4. **Items:** order `bank_pending` by `(face.index, row tier asc, slot order)`, so slides are minimal and always rightward. Satchel rises: y 1040 → 872 over 0.35 s (`EASE_OUT`, `TRANS_BACK`), with `board.satchel_in`.

Per item, with **T = 2.00 s** nominal (`HOMECOMING_STEP = 2.0`, a constant):

| t (s) | Beat | Detail | Audio |
|---|---|---|---|
| (pre) | Slide, only if the face changes | 0.36 s slide (§8). The satchel stays put. | `board.slide` |
| 0.00 | Satchel jostle | Satchel plays `satchel_open` (4 f @ 12 fps). | `board.satchel_rustle` |
| 0.10 | **Rise** | Sprite (full colour, 128) appears at the mouth (840, 892) at scale 0.5, rises to (840, 760) at scale 1.0 over 0.40 s (`EASE_OUT`). `rise_glint` (6 f @ 15 fps) plays centred on it. | `board.rise_glint` |
| 0.50 | Hang | 0.15 s hold, ±2 px bob. | |
| 0.65 | **Fly** | Quadratic bezier from (840, 760) to the slot centre. Control point = midpoint + (0, −220). 0.55 s `EASE_IN_OUT`. Scale ends at slot size. `fly_spark` trail (existing `res://assets/dungeon/home/fx/fly_spark_f0-2.png`). | `board.whoosh` |
| 1.20 | **Poof** | `poof` (5 f @ 20 fps = 0.25 s) at the slot. Slot switches to CLAIMED, sprite scale 1.15 → 1.0 over 0.18 s, modulate 1.6 → 1.0 over 0.5 s. Aura fades in over 0.3 s. | `board.poof` |
| 1.45 | **Light** (only if this item raises `lights_lit`) | The next unlit light plays `light_flash` (4 f @ 16 fps), then holds `light_on`. Nib plays `nib_react` (and a bubble on the 1st and 5th light only: `board.light.say.*`). | `board.light_chime` (pitch +1 semitone per light, 1→5) |
| 2.00 | Next item | | |

After the last item: satchel `satchel_close` (3 f) and drops off-screen over 0.30 s (`board.satchel_out`). Then, in order:
- (a) any face whose lever just became READY → §7 prompt. The board slides to that face, the lever glows, and Nib says `nib.board.lever_ready.*`. **Nothing auto-pulls.**
- (b) after (a) is resolved, or if it does not apply, any face that just became complete → §7.2 shortcut sequence (automatic).
- (c) else idle.

**Skip button** (visible from step 4 until the last poof). Click → kill per-item tweens. All remaining items go straight to CLAIMED, lights go to their final state, and the board jumps (no slide) to the face of the last item. Play one `board.poof` and one `board.light_chime` if any light changed. Continue to (a)/(b)/(c). Skip never skips the lever prompt or the shortcut sequence. Those need their own clicks.

**Bookkeeping:** remove each id from `bank_pending` / `_bank_hold` when its poof fires (save once at the end, and on Skip). A crash mid-sequence leaves the unplaced ids pending, and they replay next time. This reuses the ceremony-gen tokens (`_begin_bank_ceremony` etc.) so a pan or close aborts cleanly.

---

## 7. Unlock sequences

### 7.1 Portal (player pulls a READY lever on face i; next = biomes[i+1] or Endless)

| t | Beat | Detail | Audio |
|---|---|---|---|
| 0.00 | Pull | `lever_pull` 5 f @ 12 fps (0.42 s), then holds `lever_pulled`. **Commit the save now:** `stamp_map_piece(rules, state, face.pool_id)` adds next to `map_pieces` + `pencil_fresh` (+ `endless_unlocked` for b5). | `board.lever_clunk` |
| 0.45 | **Rumble** | Shake the cabin root (not UI) for 1.4 s, amplitude 10 → 0 px, 30 Hz noise. Spawn 10 `dust_fall` motes at random x across 0–1680, falling from y −16 with a 0.6–1.1 s fall, staggered over 0.8 s. Light dust puff off the board top. Nib shows existing `nib/nib_gasp.png` for 1.0 s. | `board.rumble` (Reel), `music` ducks −8 dB |
| 1.90 | Fade | to black over 0.3 s | |
| 2.20 | **Portal splash** | Same layout as `ui/biome_splash.gd`: art 1680×832 (ASSETS C1, `portal_<next>.png`) + a 208 px Nib talk bar. Art fades in over 0.4 s with a slow 1.03 → 1.0 push-in over 4 s. Nib lines `nib.portal.1`, `nib.portal.2` (click to advance). | `sting.portal_open` (Reel) |
| on click | Fade | 0.3 s | |
| | **Map** | Held map (`scripts/cabin/held_map.gd`) `present(rules, state, monsters, {"reveal": next, "read_only": true})` (new opts keys; no launch hits, close = continue). The fog on `next`'s node dissolves (`fog_clear` 6 f @ 10 fps). The pencil segment to it draws in (existing `pencil_fresh` / `RouteInk`, 0.8 s). The node ends in the **Known** state (§8b). Nib line `nib.portal.map`. Continue on click (button `board.continue`) or Space. | `cabin.map_pin`, `cabin.stamp_thunk` |
| | **New-pool reveal** | `main._bucket_reveal.play(i+2, main._bucket_entries(i+2))`. This is the **identical** screen used after the tutorial, with its existing `bucket.title` / `bucket.sub`. When the cards have popped in, before "Onward" enables, Nib's talk bar appears over the bottom with `nib.portal.reveal.1`, `.2`. "Onward" then dismisses both. For Endless there is no reveal; it is replaced by `nib.portal.endless`. | existing `bucket.*` |
| | Return | Fade back into the hall on face i (lever SPENT). If this face is also complete → §7.2. | |

### 7.2 Shortcut (face i first reaches 100%, i ∈ b1..b4)

| t | Beat | Detail | Audio |
|---|---|---|---|
| 0.00 | Gild | The gold trim sweeps on clockwise around the board over 0.8 s (shader mask or 4 tweened 9-slice strips). Every claimed aura on the face pulses once. Nib `react`. | `board.complete_chime` |
| 1.00 | Nib | `nib.shortcut.1` in the hall | |
| | Fade + **shortcut splash** | biome_splash layout. Art `shortcut_<next>.png` (ASSETS C2). Nib `nib.shortcut.2`. | `sting.shortcut` (Reel) |
| | **Map** | Held map `present(..., {"shortcut_reveal": next, "read_only": true})`. A dashed path line draws from the start point (the start banner bottom centre, (945, 217)) to `TRAIL[i+2]` (the next biome's node) over 1.2 s (`EASE_IN_OUT`). The node goes **Startable**: glow ring fades in, the pointer drops in (0.3 s, `TRANS_BOUNCE`) and keeps bouncing, and the "Start here" badge pops (0 → 1.1 → 1.0, 0.3 s). Nib `nib.shortcut.3`. **Commit:** `shortcuts += next`, `shortcut_fresh += next`. | `board.path_draw` |
| | Return | Back to the hall on face i. | |

b5 at 100%: no shortcut, because there is no next biome. It plays the gild and `nib.board.complete_final`. If all five boards are 100%, the existing collection-complete / ending drawer (`campaign_map.show_drawer`) runs here instead of during banking.

If a lever is READY and the face is complete in the same homecoming, §7.1 runs first (the player pulls), then §7.2. A shortcut to biome j needs portal j open, which the order guarantees.

---

## 8. Map node states (held map)

| State | Rule (biome i ≥ 1) | Look | Hover / click |
|---|---|---|---|
| **a. Unknown** | `not biome_unlocked(i)` | Fog bank sprite over the node and its painted name (ASSETS D1). The fog drifts 2 px over 6 s. | none (`mouse_filter IGNORE`) |
| **b. Known** | `biome_unlocked(i) and not can_start(i)` | Flat ink stamp. Code: wax stamp `idle` art with `modulate Color(0.62, 0.58, 0.52)`, no peel, **no hit button, default cursor**. Pool monsters still patrol (existing). | none |
| **c. Startable** | `can_start(i)` | Wax stamp in full colour + soft gold glow ring (`node_glow`, 4 f loop) + existing peel/hover/press + `LaunchHit_<pool>`. Fresh shortcuts (`shortcut_fresh` not yet launched, and not in `shortcut_badge_seen`) also get a bouncing pointer + "Start here" badge. | existing `map.hint.click`; the click starts there (`start_asked(i, shortcut = true)`) |

- Verdant Hollow (i = 0) is always Startable, and the painted START HERE banner launches it (existing `_add_start_banner`). Players start there until they earn a shortcut.
- Shortcut path lines: each earned shortcut keeps a dashed line from the start point to its node. It is drawn static after the reveal and marches (dash offset 24 px/s) only while that node is fresh.
- The pointer and badge clear the first time the player launches from that node (`shortcut_fresh.erase`, `shortcut_badge_seen.append`).
- Endless keeps its existing sealed/open stamp logic.

---

## 9. Nib

- **Before the first successful return** Nib lives in the main room exactly as today (psst prompt, tutorial ask, idle lines).
- **One-time move** (`nib_in_hall == false` and `key_ring_seen` is about to become, or already is, true): at the end of `play_key_ring`, after the hall door unlocks, Nib walks through `SideDoor` (existing walk, 4 f @ 8 fps). The camera pans to the hall, and Nib walks from x 0 to his idle spot (1544) over 1.6 s. He turns and says `nib.board.move.1`, then `.2`. Set `nib_in_hall = true` and save. The homecoming then runs with Nib present. Old saves with `key_ring_seen = true` and `nib_in_hall = false` get the short version on their next hall entry: walk in from the left doorway, then the two lines.
- **After the move:** the main-room Nib sprite and hotspot are hidden. The hall has a Nib sprite plus hotspot at (1544, 688). Clicking him plays the existing `nib.idle.*` cycle. The `nib_talk(on)`, `_move_nib_x` and react helpers resolve "the Nib host" through one getter: `_nib_room()` returns "hall" when `nib_in_hall`, else "main".
- **Reacts:** `react` (4 f @ 10 fps, once) on every light on, the lever ready, the gild and the rumble (gasp). The idle loop is the existing 2 f.

---

## 10. Idle input and navigation

| Input | Effect |
|---|---|
| ← / `ui_left` | Slide to the previous face. On face 0, pan to the main room (existing room pan). |
| → / `ui_right` | Slide to the next face. On face 4, bump plus `cabin.locked` sound. |
| Keys 1–5 | Jump to that face. |
| Left/right arrow sprite or **side rail** click | Same as ← / →. |
| Biome dot click | Slide straight to that face (one slide, direction by sign, 0.36 s + 0.04 s per extra face, capped at 0.5 s). |
| Mouse wheel over the face | ±1 face (respects `invert_scroll`), 0.25 s debounce. |
| Hover slot / lights / lever / padlock / dot | Hover card or tag (copy table). |
| Click Nib | `nib.idle.*` |
| Space | Held map (existing). The map is the run start. |
| Esc | Pause (existing). |

**Slide:** the outgoing face tweens x by ∓1232 and the incoming face from ±1232 to 0, 0.36 s `TRANS_CUBIC EASE_IN_OUT`. Both are children of the face viewport. Parallax: the backdrop of each face moves at 1.0, and the frame's rail cog (ASSETS B2) rotates 90° per slide. A 0.12 s edge-shadow strip fades in and out on both inner edges. Input during a slide queues at most one more step (latest wins). The dot and arrows update at 50%. Persist `board_face` on every settle.

---

## 11. Reduced motion

There is no setting today. Add **"Reduce motion: on/off"** to `scripts/settings_menu.gd`, following the `invert_scroll` pattern (signal, then `home_cabin.reduce_motion`, saved in `home_cabin.json`). When on:
- Slides become 0.15 s cross-fades, with no positional travel and no cog spin.
- Homecoming: no rise or fly. Each item fades into its slot over 0.25 s, then poof, then 0.6 s hold, so T ≈ 0.9 s. Lights switch on without the flash frames. The chime stays.
- Rumble: **no shake** and no falling dust. Use a 0.4 s dim pulse of the room plus the rumble audio.
- Map: the fog clears with a 0.3 s fade, the path line appears whole, and the pointer is static.
- Aura and twinkle: the aura is a static frame (f0) with no twinkle.
- Gild: the trim fades in over 0.3 s.

---

## 12. Copy table (Pixel draft. Voice: plain, warm, short; matches `nib.*` in `player-copy.json`.)

Tokens: `{hero}`, `{grandpa|poss}`, `{the_grumble}`, `{biome}` (this board), `{prev}` (the board before), `{next}` (the place being opened).

| Key | Where | Text |
|---|---|---|
| `room.hall.name` (existing) | room toast | Trophy Hall |
| `board.tip.unseen` | hover, unseen slot | Yet to be seen. |
| `board.tip.claimed_nolore` | hover, claimed with no journal entry | Home where it belongs. |
| `cabin.tip.journal` (existing) | lore heading | From {grandpa\|poss} journal: |
| `board.lights.tip` | hover, lights | One light for each different find from {biome}. Five lights open the way deeper. |
| `board.locked.tip` | hover, padlock | Five different finds from {prev} open this one. |
| `board.lever.locked` | hover, lever | Light all five first. |
| `board.lever.ready` | hover, lever | Pull it. |
| `board.lever.spent` | hover, lever | The way to {next} is open. |
| `board.dot.tip` | hover, dot | {biome} |
| `board.skip` | skip button | Skip |
| `board.continue` | map beat button | Onward |
| `nib.board.move.1` | first move | Right. Somebody has to mind his board, and the chair's taken. |
| `nib.board.move.2` | first move | I'll keep watch in here from now on. Bring things home and I'll find them a spot. |
| `nib.board.empty.1` | win, nothing new | Nothing new this time. The board can wait. It's very patient. It's a board. |
| `nib.board.empty.2` | win, nothing new | Only things we already had. Still, you came back. That's the important bit. |
| `board.light.say.1` | bubble, 1st light | There's a light! |
| `board.light.say.5` | bubble, 5th light | Five! That's all five! |
| `nib.board.lever_ready.1` | lever ready | Five lights, {hero}. Five different finds from {biome}. |
| `nib.board.lever_ready.2` | lever ready | Give that lever a pull. Go on. He never let me touch it. |
| `nib.portal.1` | portal splash | Did you feel that? Something just opened up in {the_grumble}. |
| `nib.portal.2` | portal splash | There's a new way through, past {prev}. {next} is down there waiting. |
| `nib.portal.map` | map beat | There. {next}, right on his map. You'll still start in Verdant Hollow, mind. Fight your way down to it. |
| `nib.portal.reveal.1` | reveal screen | This is what lives down in {next}. |
| `nib.portal.reveal.2` | reveal screen | From now on, any of it can turn up on your way down. Keep your eyes open. |
| `nib.portal.endless` | b5 lever | That was the bottom. Was. Something deeper just woke up. |
| `nib.shortcut.1` | gild | Every last thing from {biome}. Every one, {hero}. |
| `nib.shortcut.2` | shortcut splash | And look what was tucked behind the last one. His old shortcut, straight down to {next}. |
| `nib.shortcut.3` | map path | From now on you can start right at {next}. Or begin at the Hollow, if you're feeling sentimental. |
| `map.badge.start_here` | map badge | Start here |
| `nib.board.complete_final` | b5 at 100% | That's everything. Every last thing he owned is home. |
| `nib.push_block.1` (reword) | in-run push block | Whoa, whoa. Not down there. Your {biome} board only has {n} lights. You're not ready for what's below. Let me take you home? |
| `nib.push_block.lever` | in-run, 5 lit, not pulled | Not yet. There's a lever at home with your name on it. Pull it, then we go deeper. |
| `nib.lesson.extract_haul`, `nib.lesson.five_finds`, `nib.lesson.five_threshold` (reword "cabinet" → "board") | in-run lessons | e.g. "Five different finds from Verdant Hollow light up his board and open the way deeper. They don't all have to come home together." |

Remove: `postrun.*` (30), `cabin.hall.*` gauge/plaque/ordinal/lift (15), `nib.piece.*` (4), `mudroom.*`, `room.mudroom.name`, `cabin.room.mudroom`, `cabin.hot.run_door`, `cabin.hot.door_outpost`, `cabin.hall.sign_outpost`, the Outpost back-door hover row. Mind the author-locks (AUDIT R7).

---

## 13. Open conflicts and decisions (for Nathan)

- **C1. Shortcut rule changes.** Today `can_start` is "one-behind": 5 in Crystal Cavern lets you start at Crystal Cavern. The new rule: 100% of Verdant Hollow (14 items today) lets you start at Crystal Cavern. Old saves are grandfathered (AUDIT R4).
- **C2. The lever is now part of the gate.** `biome_unlocked` flips on the pull, not at bank time. The threshold is the same (5 unique), but there is one more click. In-run Push also stays shut until the pull. The alternative (purely ceremonial lever, gate still automatic) is cheaper, but it lets "Push deeper" work before the "a new portal opened" moment.
- **C3. "Mixture in all levels."** Items from opened pools already mix into every dungeon (`_campaign_card_ok`). Monsters do not: `rows_for_biome` keeps each biome's monster deck to its own pool until all five cabinets are full. Either change `rows_for_biome` to "every opened pool ≤ this biome", or keep `nib.portal.reveal.2` loose ("on your way down"). I wrote the copy to be true either way.
- **C4. Ending drawer timing.** `bank()` sets `won` and pops the drawer during banking. That moves after the b5 portal or the full-collection gild.
- **C5. Gate count uses current pool membership** instead of the pool stored at bank time. Moving items can change light counts on boards that are not yet opened. Opened boards are latched.
- **C6. The trophy room stays locked until the first successful return** (key-ring tour). Deaths before that land in main. Alternative: unlock the hall at tutorial end.
- **C7. Nib size:** kept at 24×32 native (96×128 px) instead of 48×48, so he matches every existing Nib frame.
- **C8. Always-starter items** (Smoke Bomb) are not on any board. If one were, it would light a free light on the first Leave.
- **C9. Seen vs claimed** both show the full-colour sprite, as asked. Claimed reads through the lit brass rim and the aura. If playtests find them too close, add `SEEN_MODULATE` (default `Color.WHITE`) and try 0.8.
