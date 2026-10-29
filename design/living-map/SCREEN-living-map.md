# SCREEN: Living map (seeded Deadly sprites on the held map)

**Project:** Spinheritance (Godot 4.7) · repo `Nathan-Elequin/swipe` · branch `playtest/latest` · tip read at `b86e95ee` (2026-10-29 00:19 CDT)
**Design owner:** Pixel (Nathan handed off style) · **Locked by Nathan:** 2026-10-28
**Viewport:** 1680×1040 · all art uses Nearest filtering · nothing here needs generated art

## Doop mockups (canvas `K5t2l_veMo`)
| Frame | id | PNG |
|---|---|---|
| LM · Living map, seeded mid-run (idle patrol) | `DoUVLCGSwy` | https://doop.design/i/DoUVLCGSwy.png?scale=2 · `/workspace/living-map/LM_living_map_idle@1x.png` |
| LM · Living map, hover name lift (magenta build notes) | `9TaaNmV0Kc` | https://doop.design/i/9TaaNmV0Kc.png?scale=2 · `/workspace/living-map/LM_living_map_hover@1x.png` |
| LM-PLATE · map-in-hands with no ink looms (Godot plate) | `w8wF4MIkv8` | https://doop.design/i/w8wF4MIkv8.png?scale=1 · `/workspace/living-map/LM_PLATE_map_in_hands_living@1x.png` |

Magenta callouts in the hover frame are build notes. They never appear in the game.

---

## 1. Behavior (what the player sees)

1. When Sprout gets back to the cabin, the next run is **seeded right away**: a full deck for every biome in run order, with each Deadly unique across the whole run chain.
2. When the player opens the held map (cabin map hotspot or Space), every **open** biome node has its seeded **Deadly** monsters walking near it as tiny full-color sprites (the real `facing_idle` game sprites at 48px). Verdant Hollow shows 1, Sunken Mire 2, Ashen Crypt 2, Cinder Forge 2, Shadow Abyss 3 (counts follow `campaign.json` `mix.deadly`).
3. Every monster patrols on its own: it walks a short lane beside its node, waits, turns back, and plays its 4-frame idle with a 3px stepped bob. When a biome has several monsters, each one gets its own lane, timer and phase, so they never move in lockstep.
4. **Hover on a monster:** it lifts (y −14px and scale 0.75→1.0, so 48→64px, crisp at 1:1) and its patrol pauses. A name tag appears above it with the monster's catalog `name` and the existing gold **DEADLY** chip (`PlayerCopy.tier_name(3)`). Moving the mouse off reverses the lift, and the patrol picks up where it stopped.
5. **Unmapped or locked biomes show no monsters.** They stay fog with a "?" ring. This was Pixel's call; see Open questions.
6. **Between-dungeon "monsters coming" telegraph screens are gone.** The map is now the only place that shows what's coming.
7. **M in a dungeon** opens the same map read-only: monsters stay alive, stamps don't respond, and Space, Esc or M closes it. Closing it **must not** abort the run.
8. The player never sees the word "Tier". Only Weak, Tough and Deadly appear.

## 2. Ground truth on tip (read before you build)

- `scripts/cabin/held_map.gd` is the map. `present(rules, state)` → `_rebuild()` places a stamp, start pin or locked blob at `TRAIL[i+1]` over the baked plate `assets/ui/map/held/map_in_hands.png`.
- **The baked plate already contains two ink "looming" monsters (Gulpwyrm, Bogmother).** These need to be removed or they will fight the live sprites. Swap `HELD_PLATE` to the new loom-free plate (see ASSET-LIST, `map/held/map_in_hands_living.png`).
- `CampaignShell.compose(rules, rng, rows, biome_id, used_deadly)` returns `{ids, telegraph, short}`. `telegraph` holds the tier-3 ids in that deck, and it **appends them to `used_deadly`**.
- Today `compose` only runs **at delve start** (`main.gd::_campaign_arm_delve`, ~L2706) and only for the current biome. That means nothing is seeded while the player is in the cabin. This screen needs seeding to move earlier (§4).
- `begin_run()` clears `state.seen_deadly`, so Deadlies are unique **per run** and not across the save.
- `_campaign_show_telegraph()` (main.gd ~L2734) is already a no-op that just hides the map. `campaign_map.gd::show_bosses()` is the old "N Deadly bosses are in this delve" screen and has **no callers**. Delete both.
- `_close_campaign_map()` (main.gd ~L2638) **calls `_campaign_abort()` when `_campaign_on`**. M-in-dungeon needs a separate close path that doesn't abort.
- Nothing binds KEY_M in main.gd. `title_teaser.gd:609` uses M only while the teaser is up, so it doesn't conflict.
- Monster display name = `monsters_by_id[id]["name"]`. Example: `two_headed_serpent` shows as **"Damsel in Distress"**, so always use the data name and never the id.
- Sprites: `assets/dungeon/anim/facing/<id>_facing_idle_f0..f3.png`, 64×64 RGBA, 4 frames. All 17 tier-3 monsters have them.

### TRAIL does not match the plate (bug to fix while you're here)
I measured the node centres from the Doop plate render (B-SHIP / LM-PLATE, screen space 1680×1040):

| node | tip `TRAIL` | measured on plate | delta |
|---|---|---|---|
| Gatehouse pin (foot) | (840,220) | (816,236) | −24,+16 |
| b1 Verdant Hollow | (900,340) | **(962,363)** | +62,+23 |
| b2 Sunken Mire | (520,480) | **(648,473)** | +128,−7 |
| b3 Ashen Crypt | (1180,520) | **(998,567)** | −182,+47 |
| b4 Cinder Forge | (780,720) | **(659,672)** | −121,−48 |
| b5 Shadow Abyss | (1280,780) | **(985,759)** | −295,−21 |

Update `TRAIL` to the measured values (keep the order Cabin → b1…b5). Otherwise the hit rects, stamps and the new monster lanes will float away from the drawn nodes. This mismatch is probably why stamps look doubled on the current plate.

## 3. Placement: monster lanes relative to the node centre (screen px)

Each entry is an `anchor` (where the foot of the sprite sits at rest) and `dx` (how far the lane runs; the sprite walks from anchor to anchor+dx and back). Lanes were checked against the plate so they stay clear of labels, the trail and stamp hit rects.

```gdscript
## held_map.gd — per-biome lanes, offsets from TRAIL[i+1]. Slot k = k-th Deadly in telegraph order.
const LANES := {
	"b1": [ {"at": Vector2(90, 100),  "dx": -50.0} ],
	"b2": [ {"at": Vector2(-130, -55), "dx": -48.0}, {"at": Vector2(-200, 55), "dx": 56.0} ],
	"b3": [ {"at": Vector2(150, 40),  "dx": 50.0},  {"at": Vector2(-150, 30), "dx": -48.0} ],
	"b4": [ {"at": Vector2(-150, -10), "dx": -50.0}, {"at": Vector2(140, 40), "dx": 48.0} ],
	"b5": [ {"at": Vector2(-160, 10), "dx": -50.0}, {"at": Vector2(150, -20), "dx": 50.0}, {"at": Vector2(40, 95), "dx": 40.0} ],
}
```
- b1 and b2 lanes are exact from the Doop mock. b3–b5 lanes are Pixel's placements on the plate fog area. Tune them by eye once those biomes are unlocked in a shot.
- If a biome deals more Deadlies than it has lanes (e.g. Endless later), stack the extras on the last lane with `at += Vector2(0, 26*n)` and a phase offset.
- z-order: monsters sit above the plate and route ink, below stamps/hit buttons and `_tip`. The `Pins` child order is plate → ink → **Monsters** → Pins → tip.

## 4. Seeding (run state)

New persisted key on campaign state:
```
state["next_run"] = {
  "seed": int,                       # RNG seed so the map and the delve agree
  "deals": { "b1": {"ids": [...], "telegraph": [...]}, ..., "b5": {...} }
}
```
- **New** `CampaignShell.seed_next_run(rules, state, rows, seed) -> void`: make one `RandomNumberGenerator` (seed = `seed`) and one local `used := []`, then call `compose(rules, rng, rows, "b%d" % n, used)` for b1..b5 in order. This is the same pattern as the selftest loop "ten deadly across the save", so every Deadly is unique across the run chain. Store the result in `state.next_run`. **Don't** touch `state.seen_deadly` here.
- `rows` = the same filtered rows `_campaign_arm_delve` builds today. Pull that loop out into `_campaign_rows() -> Array` in main.gd and reuse it in both places.
- **When to (re)seed:** after the homecoming bank finishes (cabin return), on fresh campaign or new save load when `next_run` is missing or empty, and after any DEV cheat that changes cabinets. Don't reseed on map open, because the monsters have to stay the same between opens.
- **Consume:** in `_campaign_arm_delve`, if `state.next_run.deals[biome]` exists, use it in place of calling `compose`. Then filter `telegraph` and `ids` against the run's real `seen_deadly`, so a Deadly already met this run can't repeat. Swap any filtered-out Deadly for a fresh compose pull. Append the telegraph to `seen_deadly` the same way it works now. If the entry is missing, fall back to `compose` as it does today.
- `_copy_state()` must tolerate an old save with no `next_run` (default `{}`), following the existing comment's rule about not hard-indexing keys.
- **Map read:** `held_map.present()` gets the Deadly list per biome from `state.next_run.deals[pool].telegraph`. While a run is active and the map was opened with M, hide any id already in `state.seen_deadly` (met this run). Optional, but it reads well.

## 5. Godot build

### New node: `MapMonster` (inner class in held_map.gd, or `scripts/cabin/map_monster.gd`)
```
MapMonster (Control, mouse_filter STOP, size 56x56 centred on foot-8)
 ├─ Shadow  (ColorRect 32x6, Color(0.227,0.141,0.078,0.32), at foot, no blur)
 ├─ Body    (AnimatedSprite2D, centered=true, offset=Vector2(0,-32),
 │           texture_filter NEAREST, scale 0.75, SpriteFrames "idle" = facing_idle f0..f3 @ 4 fps, loop)
 └─ Tag     (PanelContainer hidden; StyleBoxFlat bg #EFE0B6, border 3 #1A120E, shadow_size 0,
             shadow_offset (0,4) #1A120E, corner_radius 0; HBox: name FitLabelBox + Deadly chip)
```
- **SpriteFrames:** build them at runtime from `assets/dungeon/anim/facing/%s_facing_idle_f%d.png`. If an id is missing frames, skip that monster and log it; never show a blank.
- **Patrol (per monster):** a looping `Tween` with `TRANS_SINE`/`EASE_IN_OUT`: `position:x` → `anchor.x+dx` over `rng.randf_range(4.0,6.0)`s, `tween_interval(randf_range(1.0,2.0))`, back to `anchor.x`, interval, loop. Start phase = `rng.randf()*period` (or seek the tween) so monsters sharing a biome stay out of step. Flip `Body.flip_h` while walking left only if the sprite has a facing (facing_idle is front-on, so leave `flip_h` off).
- **Bob:** a 2-step bob on `Body.position.y` of 0 → −3 px, toggled every 0.45 s by a `Timer` or `_process` accumulator, like `Hands._process`. It's stepped and not eased, to keep the pixel look.
- **Hover lift:** `mouse_entered` → pause the patrol tween (`tw.pause()`), kill the lift tween, then a new Tween 0.12 s `TRANS_QUAD`/`EASE_OUT`: `Body.position:y` → −14, `Body.scale` → `Vector2.ONE` (48 → 64px, so it lands exactly at 1:1). Show the Tag at `foot + Vector2(-tag.w/2, -64-14-tag.h-10)` and clamp it to the sheet. Shadow alpha goes to .45 and width to 40. `mouse_exited` reverses it (0.10 s) and calls `tw.play()`. Use `set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)` like `_peel()`, because the map runs with `PROCESS_MODE_ALWAYS`.
- **Tag text:** `monsters_by_id[id].name` through `KIT.fit_label("", Rect2(0,0,200,28), 18, 12, 1, KIT.INK, CENTER)` followed by `lab.set_plain(name)` (same pattern as `_add_name`). The chip text is `PlayerCopy.tier_name(3)`, upper-cased, on a `UxStyle.metal(3)` gold StyleBoxFlat with a 2px `#1A120E` border. No new copy keys.
- **Hit priority:** the monster hit area is its own 56×56 rect. Where it overlaps a stamp hit button, the monster gets the hover. Clicking a monster does nothing (no start, no cue).
- `held_map.gd` needs the monster catalog. Add `present(rules, state, monsters_by_id := {})`, or pass a `Callable` name lookup. `campaign_map.show_map()` forwards it from main.

### Remove the telegraph screen
- Delete `campaign_map.gd::show_bosses()` and the `"bosses"` branch of `_kind`.
- Delete `main.gd::_campaign_show_telegraph()` and its `await` in `_campaign_arm_delve`. `_campaign_telegraph` can stay as run data (the map reads seeds from state).
- grep for `telegraph` / `show_bosses` / "Deadly boss" afterwards. Nothing between dungeons should list the incoming monsters anymore.

### Open from the cabin and with M in a dungeon
- Cabin: no change. `home_cabin.held_map_wanted` → `_toggle_held_map` → `campaign_map.show_map`.
- Dungeon: in `main.gd::_unhandled_input`, on `KEY_M` (pressed, not echo), when `_campaign_on` and `phase` is a dungeon phase with no modal open (settings, sack_peek, cutscene, playtest UIs, authoring desks) → `_peek_campaign_map()`.
- `_peek_campaign_map()`: `campaign_map.show_map(rules, state, monsters_by_id, {"read_only": true})`. In read-only mode `held_map` builds stamps **without** hit buttons, or with `disabled=true`, so `start_asked` can't fire. Monsters keep their hover.
- Closing: `campaign_map._input` treats **M** like Space/Esc. In read-only mode it emits a new signal `peek_closed`, which main connects to `campaign_map.hide_map()` **only**. Never send it to `_close_campaign_map()`, which aborts the run.
- Pause: in read-only mode, pause the dungeon (`get_tree().paused = true`, then restore on close). The map runs `PROCESS_MODE_ALWAYS`, so its tweens keep moving.

## 6. Repot REQ checklist (screenshots, 1680×1040)
Outbox: `playtest/repot/outbox/REQ-20261029-living-map/shots/`

| id | setup | expect | file |
|---|---|---|---|
| 01 | Fresh save → DEV "Fill the Verdant Hollow cabinet" → return to cabin → open map from cabin hotspot | Held map shows **no Gulpwyrm/Bogmother ink**. Verdant has 1 full-color Deadly sprite near the node, Sunken Mire has 2. Unmapped biomes have no sprites. | 01-open-map-cabin.png |
| 02 | Same, wait 3 s and take a second shot | Sprites are in different lane positions from 01 (patrol), with feet on the parchment, crisp Nearest pixels and no blur | 02-idle-patrol.png |
| 03 | Hover a Sunken Mire monster | Sprite lifted 14px at 64px. The tag shows the catalog name + gold DEADLY chip (Silkscreen-style pixel font, parchment plank, hard shadow). The other monster keeps walking. | 03-hover-name.png |
| 04 | DEV "Fill every cabinet" → cabin → map | Every biome open. b2–b4 show 2 monsters each and b5 shows 3, each on its own lane with none overlapping. No Deadly repeats across the map. | 04-multi-monster.png |
| 05 | Start a Verdant run → in the dungeon press **M**, then M again | Same map, read-only: monsters live, stamp hover does nothing, M closes **back to the same fight with the run intact** (HP/wheel unchanged) | 05-m-in-dungeon.png |
| 06 | Start a delve (any stamp), and Push into the next biome | No "Deadly bosses are in this delve" / telegraph screen appears at any point. The delve opens straight into play. The deck's Deadlies match the sprites from the map (log `telegraph` vs `next_run.deals`). | 06-telegraph-gone.png |

Pass: all six PNGs present. No text says "Tier". No new player-facing strings. `campaign_shell_selftest` is green, with a new test added: "seed_next_run gives 1/2/2/2/3 unique Deadlies b1..b5, and arm_delve consumes them".

## 7. Open questions for Nathan (Pixel picked a default; one word changes it)
1. Locked or unmapped biomes: **no sprites** (default) vs a faint pencil silhouette?
2. Endless seal (mix has 2 Deadly): give it living monsters once it's unlocked? Default: not in this pass.
3. Clicking a monster: does nothing (default) vs acts the same as clicking its biome stamp?
4. During a run (M), hide Deadlies already met this run (default yes)?

## 8. Copy flags for Spin
- No new strings. The tag uses the catalog `name` + `PlayerCopy.tier_name(3)`.
- The plate's baked lines ("Grandpa's Map of Mount Grumblegut", "START HERE", "here the map gets... hazy", etc.) are existing STUB copy. They're unchanged here and still need Spin/Jam finals.

---

## Cursor implement prompt (paste as-is)

```
Repo Nathan-Elequin/swipe, branch playtest/latest (Godot 4.7, viewport 1680x1040). Implement the LIVING MAP per SCREEN-living-map.md + ASSET-LIST.md (supplied with this prompt; commit both under design/living-map/ first).

Goal: the held map (scripts/cabin/held_map.gd) shows the NEXT run's seeded Deadly (tier-3) monsters as tiny full-color sprites patrolling near each OPEN biome node; hover lifts the sprite and shows its catalog name + the existing DEADLY chip; between-dungeon telegraph screens are removed; the map opens from the cabin (as now) and read-only with M inside a dungeon.

Do, in order:
1. Assets: add assets/ui/map/held/map_in_hands_living.png (1680x1040, download https://doop.design/i/w8wF4MIkv8.png?scale=1 — Doop frame w8wF4MIkv8 @1x — same plate with the Gulpwyrm/Bogmother ink looms removed; import Nearest, no mipmaps, lossless). Point held_map.gd HELD_PLATE at it, fall back to map_in_hands.png.
2. Fix held_map.gd TRAIL to measured plate centres: [(816,236),(962,363),(648,473),(998,567),(659,672),(985,759)].
3. campaign_shell.gd: add static seed_next_run(rules, state, rows, seed) -> composes b1..b5 in order with ONE rng(seed) and ONE local used[] (unique Deadlies across the chain), stores state.next_run = {seed, deals:{pool:{ids,telegraph}}}; never mutates state.seen_deadly. fresh_state/_copy_state default next_run = {} safely.
4. main.gd: extract _campaign_rows() from _campaign_arm_delve. Call seed_next_run after the homecoming bank completes, on campaign load when next_run empty, and after DEV cheats. In _campaign_arm_delve use next_run.deals[biome] if present (filter against seen_deadly, refill via compose if short), else compose as today. Delete _campaign_show_telegraph() and its await; delete campaign_map.gd show_bosses() + "bosses" kind.
5. held_map.gd: add MapMonster (Control + AnimatedSprite2D from assets/dungeon/anim/facing/<id>_facing_idle_f0..f3.png @4fps, scale 0.75, NEAREST, hard 32x6 shadow). Spawn one per id in next_run.deals[pool].telegraph for biomes where can_start is true, at TRAIL[i+1] + LANES[pool][k].at (LANES table in the spec). Looping Tween patrol (sine in/out 4–6 s, 1–2 s pauses, random phase), stepped 3px bob every 0.45 s. Hover: pause patrol, 0.12 s QUAD/OUT lift y-14 + scale to 1.0, show tag (parchment #EFE0B6 StyleBoxFlat, 3px #1A120E border, 0-blur 4px shadow) with KIT.fit_label name from monsters_by_id[id].name + gold chip PlayerCopy.tier_name(3).to_upper(); exit reverses. Tweens use TWEEN_PAUSE_PROCESS. Monster nodes sit above route ink, below stamp hit buttons/tip. Clicking a monster does nothing. Thread monsters_by_id via campaign_map.show_map -> held_map.present.
6. M key: in main._unhandled_input, KEY_M (pressed, !echo) during an active campaign dungeon with no modal open -> show_map(..., read_only=true): stamps inert, monsters live, pause tree; campaign_map treats M like Space/Esc and in read-only emits peek_closed -> hide_map() + unpause ONLY (never _close_campaign_map, which aborts the run).
7. Never show the word "Tier". No new player-facing strings.
8. Tests: extend scripts/dev/campaign_shell_selftest.gd: seed_next_run gives deadly counts 1/2/2/2/3 for b1..b5, all unique, seen_deadly untouched; arm-delve consumption matches seeded telegraph.
9. Repot: write playtest/repot/inbox/REQ-20261029-living-map.md with the 6 shots in the spec §6 (01 open map cabin, 02 idle patrol, 03 hover name, 04 multi-monster biome, 05 M in dungeon, 06 telegraph gone) and capture them into playtest/repot/outbox/REQ-20261029-living-map/shots/.
Open a PR into playtest/latest. Doop refs: canvas K5t2l_veMo frames DoUVLCGSwy (idle), 9TaaNmV0Kc (hover, magenta = notes only), w8wF4MIkv8 (plate).
```
