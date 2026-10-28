# SCREEN: Hall Outpost door plaque

Hall trophy room — right door plaque above the Outpost (mudroom) door. Replaces the retired study-book `SignStudy` art that `_hide_retired_chrome` used to hide.

Viewport: 1680×1040 (4× native 420×260). Units below are **native** unless noted.

## Export spec

| Field | Value |
|-------|--------|
| File | `assets/dungeon/home/doors/door_sign_outpost.png` |
| Native / shipped | 18×14 / **72×56** RGBA |
| Style | Same family as `door_sign_study` / `hall` / `workshop` / `loft`: wood plaque + icon, 1px dark outline, transparent outside plaque |
| Icon | Backpack (ochre pack + sage bedroll) — reads Outpost / travel, not Study book |
| Layout node | `SignOutpost` in `data/cabin-layout.json` → `rooms.hall` |
| Origin / size / z | `[385, 110]` / `[18, 14]` / `2` |
| Hotspot | `[383, 108, 22, 18]` (slight pad over plaque) |
| Hover key | `cabin.hall.sign_outpost` → **To the Outpost** (Spin locked; do not invent copy) |
| Import | Clone sibling `door_sign_*.png.import`; `mipmaps/generate=false`; Nearest via project `default_texture_filter=0` |

## Runtime wire

- `scripts/cabin/cabin_room.gd` `_tag_for`: `"SignOutpost": "cabin.hall.sign_outpost"`
- `scripts/cabin/room_hall.gd` `_hide_retired_chrome`: hide only `ShelfPrev` / `ShelfNext` / `Gauge` — **do not** hide `SignOutpost`
- Main cabin left-door study sign (`rooms.main` `SignStudy`) is unchanged

## Pasteable Cursor implement prompt

```
Install hall Outpost door plaque art and unhide it.

1. Commit attached door_sign_outpost.png (72×56 RGBA) to
   assets/dungeon/home/doors/door_sign_outpost.png + matching .import
   (clone door_sign_study.png.import; mipmaps off).
2. data/cabin-layout.json rooms.hall: rename SignStudy → SignOutpost,
   file doors/door_sign_outpost.png, keep origin [385,110] size [18,14] z 2,
   hotspot [383,108,22,18], note "hall right door → Outpost; hover key cabin.hall.sign_outpost".
3. scripts/cabin/cabin_room.gd _tag_for: add "SignOutpost": "cabin.hall.sign_outpost".
4. scripts/cabin/room_hall.gd _hide_retired_chrome: remove SignStudy from the hide list
   (leave ShelfPrev/ShelfNext/Gauge). Do not hide SignOutpost.
5. NEVER edit player-copy.json — Spin owns cabin.hall.sign_outpost = "To the Outpost".
6. Add playtest/repot/inbox/REQ-20261028-hall-sign-outpost.md (shots 01 plaque, 02 hover tip).
7. PR → playtest/latest.
```

## Verify

1. Enter trophy hall → right door plaque is backpack wood sign (visible).
2. Hover plaque → tip **To the Outpost**.
3. Right door still opens Outpost; left BackDoor unchanged.
