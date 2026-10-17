# SCREEN: The Study (journal/bestiary, the will, portrait, mountain model, the left-hand drawer)

Room index 2, host x = 3360. Mocks: `_pixel_extras/review/mocks/04_study_journal_bestiary.png`, `05_study_will.png`, `16_study_drawer_secret.png`, `17_study_drawer_note.png`, `18_study_drawer_ajar_glint.png`, `20_journal_will_replay.png`. GIF: `_pixel_extras/review/desk_drawer_open.gif`, `desk_drawer_rattle.gif`. Hotspots: `_pixel_extras/review/room_study_hotspots_2x.png`.

## Node tree
```
RoomStudy (Control, at host x 3360)        scripts/cabin/room_study.gd
├── Bg            rooms/room_study.png
├── Glow          rooms/room_study_glow.png (desk lamp; flicker Tween 0.92↔1.0, 0.7 s)
├── Flame0        props/candle_flame_f0..f2 @ 140 ms
├── PortraitBig   cabin_hotspot props/portrait_big.png        → Will close-up
├── Journal       cabin_hotspot props/journal.png | props/journal_new.png → Journal close-up
├── Will          cabin_hotspot props/will.png                → Will close-up
├── MountainModel cabin_hotspot props/mountain_model.png      → tooltip only
├── Drawer        cabin_hotspot props/desk_drawer.png | props/desk_drawer_ajar.png | props/desk_drawer_open_f0..f3 → Drawer close-up
├── DrawerGlint   AnimatedSprite2D fx/drawer_glint_f0..f4 on the knob (only while ending_seen and not drawer_opened)
├── BackDoor      cabin_hotspot (doorway baked; hover doors/doorway_hover.png) → Hall
├── SideDoor      cabin_hotspot doors/side_door_locked.png | side_door_closed.png → Workshop
└── SignWorkshop  doors/door_sign_workshop.png
```

## Placements and hotspots
| node | file | native rect (x,y,w,h) | 4x rect | hotspot native | hotspot 4x | hover file | z | note |
|---|---|---|---|---|---|---|---|---|
| room_study_glow | `rooms/room_study_glow.png` | (180,110,170,66) | (720,440,680,264) | - | - | - | 1 | light overlay |
| BackDoor | `None` | (6,132,32,63) | (24,528,128,252) | (2,126,40,69) | (8,504,160,276) | `doors/doorway_hover.png` | 2 | back (always open) |
| SideDoor | `doors/side_door_locked.png` | (378,132,32,63) | (1512,528,128,252) | (374,124,40,71) | (1496,496,160,284) | `doors/side_door_hover.png` | 2 | to workshop |
| SignWorkshop | `doors/door_sign_workshop.png` | (385,110,18,14) | (1540,440,72,56) | - | - | - | 2 |  |
| PortraitBig | `props/portrait_big.png` | (176,22,56,68) | (704,88,224,272) | (176,22,56,68) | (704,88,224,272) | `props/portrait_big_hover.png` | 3 | big portrait over the desk: opens the will |
| Journal | `props/journal.png` | (104,130,44,24) | (416,520,176,96) | (104,130,44,24) | (416,520,176,96) | `props/journal_hover.png` | 3 | Grandpa's journal on the lectern: opens the bestiary/compendium |
| Will | `props/will.png` | (226,146,36,14) | (904,584,144,56) | (226,146,36,14) | (904,584,144,56) | `props/will_hover.png` | 3 | the will on the desk: opens overlays/will_close |
| MountainModel | `props/mountain_model.png` | (336,28,30,32) | (1344,112,120,128) | (336,28,30,32) | (1344,112,120,128) | `props/mountain_model_hover.png` | 3 | bell-jar model of Grumblegut: shows deepest belly reached (tooltip) |
| Drawer | `props/desk_drawer.png` | (202,166,32,9) | (808,664,128,36) | (200,164,36,13) | (800,656,144,52) | `props/desk_drawer_hover.png` | 3 | left-hand drawer: stuck (rattle) before ending_seen; ajar + glint after; opens overlays/drawer_close |
| DrawerGlint | `fx/drawer_glint_f0.png` | (211,163,12,12) | (844,652,48,48) | - | - | - | 4 | hint: only while ending_seen and not drawer_opened |
| Flame0 | `props/candle_flame_f0.png` | (298,133,6,9) | (1192,532,24,36) | - | - | - | 4 |  |

| Hotspot | Hover | Click |
|---|---|---|
| PortraitBig | `cabin.hot.portrait_big` | Will close-up (cue `cabin.scroll`) |
| Will | `cabin.hot.will` | Will close-up |
| Journal | `cabin.hot.journal` | Journal close-up on the Bestiary tab (or Curiosities if no monster has been met). Cue `cabin.book_open`. `props/journal_new.png` is shown while any met monster's page is unread (`met_monsters` minus a new `bestiary_read` list; see note). |
| MountainModel | `cabin.model.deepest` (`{n}` = `deepest_belly`), or `cabin.model.none` when 0 | Bell-jar wobble Tween rotation ±2° ×2, 0.3 s. Cue `cabin.click`. |
| Drawer | `cabin.hot.drawer` (stuck) / `cabin.hot.drawer_ajar` (after the ending) / `cabin.hot.drawer_open` (opened before) | Stuck: rattle + `drawer.stuck.N`. After the ending: open (see "The left-hand drawer"). |
| BackDoor | `cabin.hot.back` | Pan to the hall |
| SideDoor | `cabin.hot.door_locked` / `cabin.hot.door_workshop` | Locked line or pan |

Note: add `"bestiary_read": []` to `home_cabin.json` v2. A page is marked read when it is shown. Same file, no new store (SYSTEMS §4).

## Journal close-up
```
JournalOverlay
├── Veil       ui/overlay_vignette.png (click = close)
├── Book       overlays/journal_spread.png at native (20,10)
├── Tabs       3 x TextureButton overlays/journal_tab_<bestiary|items|will>[_hover].png at book-local {"bestiary": [366, 30], "items": [366, 66], "will": [366, 102]}
│              tooltip labels journal.tab.bestiary / journal.tab.items / journal.tab.will
├── LeftPage   Control at book-local left page
│   ├── Portrait   TextureRect (monster or item art from DungeonArt, NEAREST, fit 64x64) at book-local [62, 34, 64, 64]
│   ├── Name       Label (catalog name)
│   ├── Grade      Label journal.weak | journal.tough | journal.deadly (monster catalog `tier` 1/2/3; NEVER print "Tier")
│   └── Ability    Label (catalog explainer/ability, muted, small)
├── RightPage  RichTextLabel: lore entry (bestiary entry / item journal + footnotes)
├── Footer     Label journal.met_count (Bestiary) or cabin.hall.gauge (Curiosities), journal.page
├── PageFlip   AnimatedSprite2D overlays/page_flip_f0..f2 @ 70 ms over the right page (flip_h for backwards)
└── Close      choice tag journal.close at native (170,232) 80x16
```
- `overlays/journal_spread.png` at native (20,10,380,240) = 4x (80,40,1520,960)
- Pages (book-local): {"left": [22, 18, 166, 204], "right": [196, 18, 166, 204]}.
- **Bestiary tab:** one monster per spread, in `data/runtime.json` `monsters` order. Unmet monsters show a black silhouette (portrait modulate #100e0c). `journal.unmet` replaces the name, and `journal.unmet_hint` goes on the right page (Jam emptied it; hide the label when the text is empty). Never print a placeholder like "???". The met count is `met_monsters.size()` of 35.
- **Curiosities tab:** one item per spread over the cabinet set (live, non-token).
  - Swiped items show the full journal entry plus footnotes.
  - Seen-only items show the name, ability and `cabin.tip.seen`.
  - Unseen items show a silhouette and `cabin.tip.locked`.
- **Will tab:** shows the will text (same as the Will close-up) on the right page and the big portrait on the left.
  - **Read it again** (Nathan decision 5): a choice tag `journal.will.replay` (ui/choice_tag 9-slice, 92x16 native) on the left page, centred under the portrait (book-local x 48, y 110; the portrait is [62, 34, 64, 64]). Click → `cabin.book_close`, the journal closes, the intro replays (SYSTEMS §7.2) and ends back in the study. Shown every time the Will tab is open; no save field.
- Paging: mouse wheel, `ui_left`/`ui_right` (handled before the room pan while open), or clicking the page corners (right 40 native px of each page). Each page turn: PageFlip anim, cue `cabin.page_flip`.
- Open: Book modulate.a 0→1 + position.y +8→0 native, 0.2 s CUBIC OUT, cue `cabin.book_open`. Close: cue `cabin.book_close`.

## Will close-up
```
WillOverlay
├── Veil     ui/overlay_vignette.png
├── Scroll   overlays/will_close.png at native (80,20)
├── Title    Label will.title (top of the scroll, centred, 2 lines max)
├── Body     RichTextLabel will.p1 .. will.p5 (paragraph gap 10 px at 4x), inside scroll-local [40, 34, 180, 150]
├── Sign     Label will.sign ; Witness Label will.witness (small, under Sign)
├── Seal     TextureRect overlays/wax_seal.png (first view) / overlays/wax_seal_broken.png at scroll-local [112, 186]
└── Close    choice tag will.close at native (170,234) 80x16
```
- `overlays/will_close.png` at native (80,20,260,220) = 4x (320,80,1040,880)
- Unroll: Scroll `scale.y` Tween 0.1→1.0, 0.35 s, BACK OUT, pivot at the top. Cue `cabin.scroll`.
- First ever open: the seal shows intact. On the first click anywhere it swaps to broken, with cue `cabin.seal_stamp` and a 2-frame dust (`fx/dust_puff_f0..f2` at the seal). Save `"will_read": true` (add to v2).
- The body can scroll if Jam's text runs long (RichTextLabel `scroll_active`, wheel only, no bar).

## The left-hand drawer (post-ending secret; Nathan decision 6)
The top-left drawer of the desk pedestal. It needs no new mechanic: one hotspot, three save flags (`drawer_hint_said`, `drawer_opened`, `geode_on_mantel`, plus `drawer_stuck_index`), the existing Nib dialog, the loft LetterCard and the room pan. State machine: SYSTEMS §7.1.

### States in the room
| State | When | Sprite (native origin) | Hover | Click |
|---|---|---|---|---|
| Stuck | `ending_seen == false` | `props/desk_drawer.png` at (202,166), pixel-identical to the baked front | `cabin.hot.drawer` | `props/desk_drawer_rattle_f0,f1,f2,f0` @ 60 ms at (200,166), cue `cabin.drawer_stuck`, Nib `drawer.stuck.<n>` (n = 1 + `drawer_stuck_index` % 3, then +1, saved) |
| Ajar | `ending_seen and not drawer_opened` | `props/desk_drawer_ajar.png` at (201,165) + DrawerGlint `fx/drawer_glint_f0..f4` at (211,163): 5f @ 70 ms, then a random 2.5–4 s wait, ADD blend ok | `cabin.hot.drawer_ajar` | Open (below) |
| Opened | `drawer_opened` | `props/desk_drawer.png` (closed again) | `cabin.hot.drawer_open` | Open (below) |

- Hover/press sprites: `props/desk_drawer_hover.png` / `props/desk_drawer_press.png` at (201,165); `props/desk_drawer_ajar_hover.png` at (200,164). The hotspot is (200,164,36,13) in every state.
- - `props/desk_drawer.png`: 32x9 [128x36]. top-left desk drawer, pixel-identical to the baked front (stuck until ending_seen)
- `props/desk_drawer_ajar.png`: 34x11 [136x44]. post-ending idle: front dropped 1px, warm light in the gap (34x11)
- `props/desk_drawer_ajar_hover.png`: 36x13 [144x52]. hover (canvas +2px, place at origin-(1,1))
- `props/desk_drawer_hover.png`: 34x11 [136x44]. hover (canvas +2px, place at origin-(1,1))
- `props/desk_drawer_open_f0.png` .. f3 (4 frames): 40x22 [160x88]. open: 4f @ 90ms then hold f3 while the close-up is up (40x22, place at (198,163))
- `props/desk_drawer_press.png`: 34x11 [136x44]. press (canvas +2px, place at origin-(1,1))
- `props/desk_drawer_rattle_f0.png` .. f2 (3 frames): 36x12 [144x48]. stuck click: f0,f1,f2,f0 @ 60ms (36x12, place at (200,166)); dust specks on f1/f2
- - `fx/drawer_glint_f0.png` .. f4 (5 frames): 12x12 [48x48]. post-ending hint on the drawer knob: 5f @ 70ms, then wait 2.5-4 s; centre (6,6) on the knob
- **Open:** hide `Drawer`, play `props/desk_drawer_open_f0..f3` @ 90 ms at (198,163) with cue `cabin.drawer_open`, hold f3, then open the close-up. When the close-up closes, play f3→f0 backwards @ 70 ms (cue `cabin.click`) and show the Opened state.
- The hint: right after the ending (SCREEN-ending), `cabin.drawer_unlatch` plays offscreen and Nib says `drawer.hint` once. The glint and the warm gap in `desk_drawer_ajar` carry the hint after that. The existing joke lines stay exactly as they are: `will.p5`, `keyring.door.study`, `letter_100`.

### Drawer close-up
```
DrawerOverlay
├── Veil      ui/overlay_vignette.png (click = close)
├── Title     Label drawer.title (above the box, y (o.y-14)*4, cream)
├── Box       overlays/drawer_close.png (centred; origin below), ~60 rocks and the Rightful Heir Latch baked in
├── Glow      AnimatedSprite2D overlays/lucky_geode_glow_f0..f2, frames 0-1-2-1 @ 220 ms, at box-local [47, 56] (hidden once geode_on_mantel)
├── Geode     cabin_hotspot overlays/lucky_geode_big.png at box-local [52, 60], hover drawer.geode (hidden once geode_on_mantel)
├── Note      cabin_hotspot overlays/drawer_note.png at box-local [156, 26], hover drawer.note
├── Take      choice tag drawer.take (only while the geode is in the drawer) at native (126,216) 92x16
└── Close     choice tag drawer.close at native (222,216) 72x16 (centred alone at (174,216) once the geode is gone)
```
- `overlays/drawer_close.png` at native (90,50,240,160) = 4x (360,200,960,640)
- - `overlays/lucky_geode_glow_f0.png` .. f2 (3 frames): 44x38 [176x152]. halo behind lucky_geode_big, 0-1-2-1 @ 220ms; drawer-local DRAWER_GEODE_GLOW
- Open: Box position.y +12→0 native and modulate.a 0→1, 0.22 s CUBIC OUT. First open ever: `drawer_opened = true`, save, then Nib `drawer.open.nib`.
- **Note:** opens the loft LetterCard (dialog_box 9-slice 220x170, centred) over the drawer with `lore.json` `drawer_note.title` / `.body`, cue `cabin.scroll`. Close with `cabin.trunk.close` (the existing letter-card close key). It is not added to `letters_read` and not shown in the trunk.
- **Geode or Take:** cue `cabin.geode_chime`, `geode_on_mantel = true`, save, close the overlay, pan to the main room (`cabin.pan`). `LuckyGeode` appears on the mantel at (68,105) with `doors/unlock_sparkle_f0..f3` centred on it, then Nib `drawer.taken.nib`.
- The Rightful Heir Latch at box-local [108, 134] is art only (no hotspot).
- Escape closes the close-up (SYSTEMS §9).

## Copy and cues
**Copy:** `cabin.room.study`, `cabin.hot.portrait_big`, `cabin.hot.journal`, `cabin.hot.will`, `cabin.hot.model`, `cabin.hot.back`, `cabin.hot.door_locked`, `cabin.hot.door_workshop`, `cabin.model.deepest`, `cabin.model.none`, `cabin.tip.seen`, `cabin.tip.locked`, `cabin.hall.gauge`, `journal.tab.bestiary`, `journal.tab.items`, `journal.tab.will`, `journal.unmet`, `journal.unmet_hint`, `journal.met_count`, `journal.page`, `journal.close`, `journal.weak`, `journal.tough`, `journal.deadly`, `will.title`, `will.p1`, `will.p2`, `will.p3`, `will.p4`, `will.p5`, `will.sign`, `will.witness`, `will.close`, `journal.will.replay`, `cabin.hot.drawer`, `cabin.hot.drawer_ajar`, `cabin.hot.drawer_open`, `drawer.stuck.1`, `drawer.stuck.2`, `drawer.stuck.3`, `drawer.title`, `drawer.open.nib`, `drawer.note`, `drawer.geode`, `drawer.take`, `drawer.close`, `cabin.trunk.close`

**Cues:** `cabin.hover`, `cabin.click`, `cabin.book_open`, `cabin.book_close`, `cabin.page_flip`, `cabin.scroll`, `cabin.seal_stamp`, `cabin.pan`, `cabin.locked`, `cabin.drawer_stuck`, `cabin.drawer_open`, `cabin.geode_chime`

## Code hooks
`note_met` (new, called in `_make_monster` 3510), `DungeonArt` monster/item textures (as the shelves already use `tex_by_item`), catalog `tier` → `journal.weak/tough/deadly`, `lore.json` `monsters.<id>.entry` / `items.<id>.journal`, `lore.json` `drawer_note`. Intro replay: `cutscene_player.play(INTRO, {replay = true})`.
