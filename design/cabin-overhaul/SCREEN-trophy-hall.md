# SCREEN: Trophy Hall (the Cabinet)

Room index 1, host x = 1680. Mock: `_pixel_extras/review/mocks/03_trophy_hall_tooltip.png`. Hotspots: `_pixel_extras/review/room_hall_hotspots_2x.png`.

**This room reuses the existing shelf code**: `_hole`, `_shelf_host`, `_rebuild_shelves`, `_screen_of_bucket` (733), `_wipe_pan` (973), `_on_nav`, mounts, glints, burst and `note_seen`/`swipe_ids`. It moves into `RoomHall`, and only the hole rect and the chrome change. Do not create a second Seen/Swiped store.

## Node tree
```
RoomHall (Control, at host x 1680)          scripts/cabin/room_hall.gd
├── Bg          rooms/room_hall.png
├── Glow        rooms/room_hall_glow.png (candle light; alpha flicker Tween 0.9↔1.0, 0.8 s)
├── Flame0      AnimatedSprite2D props/candle_flame_f0..f2 @ 140 ms (random start frame)
├── _hole       (existing Control, STOP, clip) MOVED to native Rect2(100,24,260,160)
│   ├── _shelf_host  (existing; rebuilt per shelf page)
│   │   └── wrap per item (existing): mount / item / glint / lab / burst
│   │       ├── NewGlow  AnimatedSprite2D fx/shelf_new_glow_f0..f3 @ 160 ms loop at mount origin-(4,4) (NEW only)
│   │       └── NewTag   TextureRect fx/new_tag.png at mount origin+(22,-2) (NEW only)
│   ├── _cordon      (existing; uses shelf_locked.png fallback)
│   └── _shelf_fade  (existing)
├── ShelfPrev   cabin_hotspot ui/shelf_arrow_left.png    → _on_nav(-1)
├── ShelfNext   cabin_hotspot ui/shelf_arrow_right.png   → _on_nav(+1)
├── Gauge       TextureProgressBar under ui/gauge_under.png, progress ui/gauge_fill.png (+ hotspot)
├── BackDoor    cabin_hotspot (open doorway baked in bg; hover doors/doorway_hover.png)
├── SideDoor    cabin_hotspot doors/side_door_locked.png | side_door_closed.png → Outpost
└── SignOutpost doors/door_sign_outpost.png (hover cabin.hall.sign_outpost)
```

The old `_prev_btn`, `_next_btn` and `_pips` gallery doors are deleted. `_back` is deleted.

## Placements and hotspots
| node | file | native rect (x,y,w,h) | 4x rect | hotspot native | hotspot 4x | hover file | z | note |
|---|---|---|---|---|---|---|---|---|
| room_hall_glow | `rooms/room_hall_glow.png` | (20,40,91,175) | (80,160,364,700) | - | - | - | 1 | light overlay |
| BackDoor | `None` | (6,132,32,63) | (24,528,128,252) | (2,126,40,69) | (8,504,160,276) | `doors/doorway_hover.png` | 2 | back (always open) |
| SideDoor | `doors/side_door_locked.png` | (378,132,32,63) | (1512,528,128,252) | (374,124,40,71) | (1496,496,160,284) | `doors/side_door_hover.png` | 2 | to Outpost |
| SignOutpost | `doors/door_sign_outpost.png` | (385,110,18,14) | (1540,440,72,56) | (383,108,22,18) | (1532,432,88,72) | - | 2 | hover key cabin.hall.sign_outpost |
| Flame0 | `props/candle_flame_f0.png` | (61,62,6,9) | (244,248,24,36) | - | - | - | 4 |  |
| Gauge | `ui/gauge_under.png` | (148,188,164,5) | (592,752,656,20) | (148,186,164,9) | (592,744,656,36) | - | 3 | cabinet completion (TextureProgressBar); hover = "x of y" tooltip |
| ShelfPrev | `ui/shelf_arrow_left.png` | (124,185,16,12) | (496,740,64,48) | (122,183,20,16) | (488,732,80,64) | `ui/shelf_arrow_left_hover.png` | 4 | shelf page prev |
| ShelfNext | `ui/shelf_arrow_right.png` | (320,185,16,12) | (1280,740,64,48) | (318,183,20,16) | (1272,732,80,64) | `ui/shelf_arrow_right_hover.png` | 4 | shelf page next |
| Shelf | `None` | (100,24,260,160) | (400,96,1040,640) | (100,24,260,160) | (400,96,1040,640) | - | 3 | existing _shelf_host goes here (hole moved from (140,20) to (100,24), same 260x160) |

Shelf hole: native (100,24,260,160) = 4x (400,96,1040,640). It was (140,20,260,160) before. The size is unchanged, so the mount grid math in `_rebuild_shelves` stays the same; only `_hole.position` changes.

## Behaviour
| Hotspot | Hover | Click |
|---|---|---|
| Mount, swiped | `fly_tip` (below) | Clears NEW if set (remove from `new_unseen`, `_save()`, NewGlow fades out over 0.3 s, cue `cabin.shelf_chime`). |
| Mount, seen but not home | `fly_tip`: name + ability + `cabin.tip.seen` (no journal) | none |
| Mount, never seen (silhouette) | **New:** hover connected for unseen too. Tag `cabin.tip.locked` only; no name. | none |
| Locked bucket row | `cabin.tip.locked` | none |
| ShelfPrev / ShelfNext | `cabin.hot.cabinet` | `_on_nav(∓1)` (existing wipe, existing `cabin.pan`). Hidden at the first/last page. |
| Gauge | `cabin.hall.gauge` (`{n}`/`{total}` = `cabinet_progress()`), or `cabin.hall.full` | none |
| BackDoor | `cabin.hot.back` | Pan to main. |
| SideDoor | locked `cabin.hot.door_locked` / open `cabin.hot.door_study` | Locked: `cabin.locked`. Open: pan to the study. |

Arrow keys (`_input` 1561–1567): `ui_left`/`ui_right` page the shelves via `_on_nav`. At the first page, `ui_left` pans to main. At the last page, `ui_right` pans to the study (if unlocked).

## Tooltip (fly_tip, z 110): "small ability on top, mostly Grandpa's journal"
- Flow is unchanged: `_on_cabin_item_hovered` (1808) → `_cabin_item_from_id` → `_item_rule` (9654) → `fly_tip.show_rule(...)` → `_place_fly(slot)` (10086).
- **Add** a journal block to `hover_panel.gd` `show_rule` (80) through a new optional argument `journal := {}`. Layout:
  1. Name (existing title style) + `cabin.tip.new` in red on the right if the id is in `new_unseen`.
  2. The ability line: the existing `_item_rule` body, rendered **one size smaller** and in a muted ink (#6e5434).
  3. 1px rule (#a8946c).
  4. `cabin.tip.journal` header (small, muted).
  5. `lore.json` → `items.<id>.journal` (body size).
  6. Each footnote in `items.<id>.footnotes` (smallest size, #7a6a48).
- Panel skin while in the cabin: `ui/tooltip_parchment_9.png` 9-slice, margins 10 native (40 at 4x). Max width 156 native (624 px). Combat keeps its current skin.
- Load `data/lore.json` once in `Main._ready` next to the catalog. A missing journal entry = omit the block (no fallback text).

## NEW item arrival (from the win homecoming; see SCREEN-homecoming.md)
1. The homecoming pans the host to the hall while the item is in flight. Then `_on_nav` jumps the shelf to `_screen_of_bucket(bucket)` of that item.
2. On landing: the existing `trophy_place_burst` plus cue `cabin.trophy`, then NewGlow + NewTag stay until hover/click.
3. When several NEW items sit on different shelf pages, pages flip in bucket order with the existing `_wipe_pan`.

## Animations / Tweens
| What | Frames | Timing |
|---|---|---|
| Existing glint | plaque_glint_f0..f3 | as today |
| NewGlow | fx/shelf_new_glow_f0..f3 | 160 ms loop |
| Arrow hover | `_hover` swap | none |
| Gauge fill | TextureProgressBar value Tween | 0.6 s CUBIC OUT, after each landing |
| Candle | props/candle_flame_f0..f2 | 140 ms |

## Copy and cues
**Copy:** `cabin.room.hall`, `cabin.hot.cabinet`, `cabin.hot.gauge`, `cabin.hot.back`, `cabin.hot.door_locked`, `cabin.hot.door_study`, `cabin.hall.gauge`, `cabin.hall.full`, `cabin.tip.journal`, `cabin.tip.new`, `cabin.tip.locked`, `cabin.tip.seen`, `cabin.locked`

**Cues:** `cabin.hover`, `cabin.click`, `cabin.pan`, `cabin.trophy`, `cabin.glint`, `cabin.shelf_chime`, `cabin.locked`, `cabin.room_sign`

## Code hooks
`_rebuild_shelves`, `_screen_of_bucket` (733), `_wipe_pan` (973), `_on_nav`, `_mount_stem` (1133; the missing seen/unseen art keeps its modulate fallback), `_on_cabin_item_hovered` (1808), `_cabin_item_from_id`, `_item_rule` (9654), `hover_panel.gd` `show_rule` (80), `_place_fly` (10086), `swipe_ids` (97), `note_seen` (87).
