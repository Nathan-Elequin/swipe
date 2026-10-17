# SCREEN: Homecoming (win and loss)

Storyboard: `_pixel_extras/review/homecoming_storyboard_1x.png` (top row = win, bottom row = loss). GIFs: `hero_sack_dump_win.gif`, `hero_sack_shake_loss.gif`, `hero_walk_sad.gif`, `hero_cheer.gif`, `new_burst.gif`, `shelf_new_glow.gif`.

Entry point: `CabinRoot.play_homecoming(kind, new_ids, held_ids)`, reached via `_open_home_cabin(true)` (1758) → `open_cabin` (113) → `_play_arrive` (433). SYSTEMS §3.2 lists who calls it. Main has already run `_reset_run()`; `held_ids` and `new_ids` are captured **before** the reset.

Shared rules:
- The whole sequence has `_beat = "homecoming"`. Clicks only advance dialog. Escape fast-forwards to the end state (all items placed, dialog skipped, hero in the chair).
- Hero frames are swapped by tween callbacks, as today (`_walk_hero`, `_play_drop`, `_play_sit`), through `_set_hero_frame` so the gear overlays follow (SCREEN-main-room "Gear").
- The interior hero faces **left** (`flip_h = true`). Native positions below are the sprite's top-left.
  - Hero row y = 205 (feet row 30 → floor y 235).
  - Wide 48x40 frames go at hero origin − (8,8).

## Common opening (both kinds)
1. **Exterior** (existing `_play_arrive` 433): pan in, walk the Bezier path, door opens, fade to interior.
   - Win uses the existing `hero_walk_loot_f0..f3`.
   - Loss uses `hero/hero_walk_sad_f0..f3` with the walk tween duration ×1.3 (sad shuffle).
2. **Interior** = `RoomMain` (host x 0). The RunDoor plays `doors/run_door_open_f0..f2` reversed (closing) behind the hero.
   - The hero appears at (254,205) and walks to (70,205): Tween position.x, 1.1 s win / 1.5 s loss, 8 fps frame cycle.
   - Existing cue `cabin.step` on frames 0 and 2.

## WIN
| step | t (s) | Visual | Audio |
|---|---|---|---|
| W1 drop | 0.0 | Existing `hero_drop_sack_f0..f3` (as `_play_drop`) | `cabin.sack` |
| W2 grab / hug | +0.5 | `hero/hero_sack_dump_f0` 0.18 s, `f1` 0.22 s | — |
| W3 tip | +0.4 | `f2`: items start popping | `cabin.hero_yip` |
| W4 pour | hold | `f3` held while items pop | — |
| W5 done | end | `f4` (grin, empty sack on the floor) | — |

**Item pop** (during W3–W4): items in `held_ids` order, NEW ones first, 0.16 s apart.
- **Source:** sack mouth = wide-frame `DUMP_MOUTH` [40, 34], mirrored for flip_h: scene x = origin.x + (47 − 40), y = origin.y + 34. That is native (69,231) with the hero at (70,205).
- **Sprite:** item texture from `tex_by_item` at 16x16 native (64 px), in a `Sprite2D` under RoomMain.
- **Motion:** Tween arc to a rug slot. Slots fan out over x 92..236, y 222..238 native in a 12-slot grid. Duration 0.35 s with a peak 24 native px above the line, then a 2-step squash bounce (scale 1.15/0.9, 0.08 s).
- **Cues:** `cabin.item_pop` per item, plus `fx/dust_puff_f0..f2` on landing.
- **Caps:**
  - At most 12 non-NEW items are popped; the rest are skipped silently.
  - All NEW items always pop.
  - A Classic hand can be 50 items; a Challenge hand is at most 10 (`CHALLENGE_HAND`).
- **Coins:** `fx/coin_f0..f3` @ 80 ms: three coins spin out on the first pop (pure flavour).

**NEW item burst and flight** (each NEW item, after it lands, up to 3 in flight at a time):
1. `fx/new_burst_f0..f5` @ 60 ms, centred on the item, ADD blend. Cue `cabin.item_burst`. The hero plays `hero/hero_cheer_f0` 140 ms → `f1` 260 ms, with a Tween y −6 native and back.
2. The first NEW item triggers Nib's `nib.home.new` (bubble, non-blocking).
3. **Flight leg 1:**
   - Rides `fx/fly_spark_f0..f2` @ 80 ms, with a `CPUParticles2D` trail using `fx/fly_trail.png` (lifetime 0.35 s, 30 particles, gravity 0, colour #e8c36a→transparent).
   - Path: the item flies to the SideDoor centre (native (386,163)) on a quadratic Bezier peaking at y 120, over 0.55 s. Cue `cabin.item_whoosh`.
4. **Pan:** host pan to the hall (SYSTEMS §1.2). The shelf page jumps (`_on_nav`) to `_screen_of_bucket(bucket)` for that item.
5. **Flight leg 2:** from the hall's left doorway (native (22,163)) to the mount centre (`_hole` origin + mount rect), 0.45 s.
   - Landing: the existing `trophy_place_burst_f0..f4` + `cabin.trophy`.
   - Then `fx/shelf_new_glow_f0..f3` + `fx/new_tag.png`, which stay on (SCREEN-trophy-hall).
6. Gauge fill Tween (0.6 s). The new progress is checked for milestones (SYSTEMS §3.2).

**First haul ever** (hall still locked):
- The NEW items fly to the locked SideDoor and **hover** there in a cluster (each bobbing ±3 native px, sparks looping).
- The key-ring cutscene (SCREEN-keyring.md) starts as soon as the pops finish.
- Right after `keyring.door.hall` the hall door opens, the cluster does legs 2–5, and then the key ring continues with the study.

**Wrap-up:**
- Pan back to main (if it panned).
- Toast `cabin.new_count` (`{n}` = NEW count) in the room toast slot, only if n > 0.
- Nib dialog line:
  - `nib.home.nothing_new` when there were no NEW items;
  - else a random `nib.home.win.1..3`;
  - or the milestone line `nib.milestone.25/50/75` instead, when one was crossed.
- Rug items fade out (modulate.a → 0, 0.4 s), the empty sack stays, and the hero walks (existing `hero_walk_f0..f3`) to the chair (10,205).
- Existing `hero_sit_f0..f4` → `hero_rock` loop (existing `_play_sit`). Cue `cabin.sit`, then `cabin.rock`.
- Counters: `counters.hauls += 1`, `counters.homecomings += 1`.
- Then: key ring (if due and not already done above), then the ending (if full). Otherwise idle menu.

## LOSS
| step | t (s) | Visual | Audio |
|---|---|---|---|
| L1 stop | 0.0 | Hero stops at (70,205), `hero/hero_walk_sad_f0` | — |
| L2 thump | +0.2 | `hero/hero_sack_shake_f0` (crouch, the empty sack is on the floor behind him) at origin − (8,8); `fx/dust_puff_f0..f2` at (54,228) | `cabin.sack` |
| L3 shake | +0.3 | `f1, f2, f3, f2, f1, f2, f3` @ 120 ms (upside-down, hoisted) | `cabin.sack_shake` |
| L4 moth | at the first `f2` | `fx/moth_f0..f1` @ 100 ms, spawned at the sack mouth (wide-frame (18,1) → scene (60,198)); flutters up and left (Tween 1.2 s, sine x ±4) and fades | `cabin.moth` |
| L5 peer | +0.2 | `f4` held 0.7 s | `cabin.sack_empty`, then `sting.empty` |
| L6 slump | +0.7 | `f5` held 0.8 s | `cabin.hero_sigh` |
| L7 sit | — | The limp sack is left on the floor: `hero/hero_sack_empty_limp.png` at hero origin + (14,24) = (84,229). The hero walks sad to the chair (10,205), then plays the existing `hero_sit_f0..f4` → `hero_rock` at **3 fps** (sad rock) for this visit only. | `cabin.sit` |
| L8 Nib | — | Nib walks in 8 native px, talk anim. Random `nib.home.loss.1..3`. | `speech.nib` |

- Counters: `counters.homecomings += 1`, `counters.losses += 1`. No swipe, no key ring, no ending.
- Next menu visit: the limp sack is replaced by the normal `loot_sack_dropped.png` at the existing `_sack` spot (70,205).

## Node additions (inside RoomMain)
```
RoomMain
├── HomecomingLayer (Control, IGNORE, z above props)
│   ├── RugItems    (Node2D) item Sprite2Ds
│   ├── Fx          (Node2D) bursts, dust, coins, moth
│   └── Flyers      (Node2D) flying NEW items (+ CPUParticles2D trail each)
└── LimpSack        TextureRect hero/hero_sack_empty_limp.png (hidden unless the loss state)
```

## Copy and cues
**Copy:** `nib.home.loss.1`, `nib.home.loss.2`, `nib.home.loss.3`, `nib.home.win.1`, `nib.home.win.2`, `nib.home.win.3`, `nib.home.new`, `nib.home.nothing_new`, `nib.milestone.25`, `nib.milestone.50`, `nib.milestone.75`, `cabin.new_count`, `tutorial.speaker`

**Cues:** `cabin.step`, `cabin.sack`, `cabin.hero_yip`, `cabin.item_pop`, `cabin.item_burst`, `cabin.item_whoosh`, `cabin.trophy`, `cabin.pan`, `cabin.sit`, `cabin.rock`, `cabin.sack_shake`, `cabin.moth`, `cabin.sack_empty`, `sting.empty`, `cabin.hero_sigh`, `speech.nib`

## Code hooks
`_adventure_leave` (1717), `_enter_dungeon_clear` (1695) + new `_classic_swipe_home`, `_player_down` (4942/4947) → Caught → `_go_home_loss`, `_open_home_cabin` (1758) gains `kind`, `open_cabin` (113), `_play_arrive` (433), `_play_drop`, `_play_sit`, `_walk_hero`, `swipe_ids` (97, returns NEW), `_rebuild_shelves`, `_screen_of_bucket` (733), `_on_nav`, `_bump` (638).
