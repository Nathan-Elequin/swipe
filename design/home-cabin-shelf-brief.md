# Home Cabin shelves — art packet

Paste this entire file to the sprite / asset agent as the first message. They do not need the Godot repo. **Do not redraw any item or monster card.** Existing 16×16 (4×) item icons drop into an empty well on the mount.

This is a follow-up to `design/home-cabin-art-brief.md`. Keep the same cabin, hero, fire, and lantern. This packet is only the **trophy wall**: readable nameplates, a “seen but not brought home” mount, mysterious empty mounts, and doorways so the thief can walk between bucket rooms.

---

## Style lock

- Draw at native pixel size, then **4× nearest-neighbor**. No blur, no photoreal, no AI-photo look.
- Palette: wood `#3a2416`, wood highlight `#5a3a24`, gold `#c4a574`, hot gold `#e8c36a`, dark interior `#120e0c`, plaque ink well (empty, no letters) `#c4a574` / `#e8c36a`, unseen wood `#241810`, chain `#4a4a52`, padlock body `#6a6e78`, padlock gold `#c4a574`.
- Outline-first, chunky pixels. Kenney Tiny Dungeon / 0x72 energy.
- Do **not** paint English, numbers, or item art onto any of these files. The engine draws names.

## Screen and folder

Game viewport is **1680×1040**. Interior background is already `assets/dungeon/home/cabin_interior.png` at that size.

New files go in `assets/dungeon/home/`. PNG, RGBA. Filenames must match exactly.

The shelf hole on the interior (native 420×260 space, then 4×) is **x=140–400, y=20–180**. Doorways sit on the left and right edges of that hole. Mounts are spawned by code inside the hole; do not paint a grid of plaques into the interior.

---

## 1. Trophy mount (readable nameplate)

Current `trophy_mount.png` is native **32×40** (4× → 128×160). The gold strip is only ~8px tall, so names like “Counting Beads” are unreadable.

Replace with a taller plate. Keep one reusable object, not 40 paintings.

- `trophy_mount.png` — native **40×56**. Wooden shield / plaque. Empty center well **16×16** where code drops the item PNG. Place that well at **(12, 10)** so it stays optically centered in the wood, not on the gold. Gold nameplate strip along the bottom **40×14** with **no letters**. 4× → 160×224.
- `trophy_mount_hover.png` — same size and registration. Brighter gold rim and slightly warmer wood. Engine swaps this on hover for items that have been brought home.

## 2. Seen, not brought home

These items were offered or held in a dungeon, but the thief did not walk them home. Full item art is visible. They must **not** look gold or glint.

- `trophy_mount_seen.png` — same **40×56** and same 16×16 well at **(12, 10)**. Nameplate is **unpolished wood or dull leather**, not gold. Same empty plate (no letters). This is the tell.
- `trophy_mount_seen_hover.png` — matching hover. A little lighter wood, still not gold.

## 3. Unseen / locked silhouette well

Code will drop the real item PNG in black (`modulate` near `#120e0c`) so the shape is a mystery. You draw the empty mount only.

- `trophy_mount_unseen.png` — same **40×56**. Darker wood, no gold, empty well at **(12, 10)**. Recessed, dusty, a little hungry. No letters, no question mark, no eyes.

## 4. Plaque glint (brought-home only)

Current glint is 16×8 native (4× → 64×32), too short for a 14px-tall plate.

- `plaque_glint_f0.png` … `plaque_glint_f3.png` — native **24×14** (4× → 96×56). Additive-friendly white/gold spark that sweeps left-to-right across the gold strip only. Transparent outside the spark. Same pivot: top-left of the gold plate. Loop.

## 5. Room door (clickable, in the scene)

The hearth is one room. **Screen 1** is starter loot (bucket 0) in three rows. **Screen 2** is buckets 1–3, one bucket per row. Screen 3 is 4–6, and so on. The thief walks to a **door in the right wall** to go to the next screen. This door is the click target. It must read as furniture in the cabin, not a UI chevron, and still be obviously clickable (gold rim on hover is added by code if you skip a hover frame).

- `gallery_door_right.png` — native **36×88**, transparent. Wooden interior door, same perspective as `cabin_interior.png` (face-on back wall). Closed. Latch/handle on the right. Pivot top-left. Code places it at about native **(364, 100)** overlapping the right edge of the shelf hole. 4× → 144×352.
- `gallery_door_left.png` — same size. For walking back. Handle on the left. Code places it near native **(104, 100)**, between the fireplace and the plaques.
- `gallery_door_right_hover.png` / `gallery_door_left_hover.png` — optional. Brighter wood and a warmer gold edge. Engine can also modulate.
- `gallery_door_open_right_f0.png` … `f2.png` — optional 3-frame inward swing, same size and registration. If missing, engine falls back to the exterior `cabin_door_open_f*` stretched into this slot (looks wrong — please draw these).

Do **not** draw arrow buttons, chevrons, or “next” text. The door is the control.

## 6. Cordon overlay (locked wall)

When the current wall’s bucket is not unlocked yet, code shows mysterious silhouettes and lays this on top.

- `gallery_cordon.png` — native **260×160**, transparent. A chain and one padlock that can sit over a cluster of mounts without hiding their silhouettes completely. Keep the center ~60% alpha or sparser so shapes read through. No English. 4× → 1040×640.
- Do not reuse `shelf_locked.png` as-is; that asset is a 4-mount-wide bar and will not cover 2×2 / 3×3 clusters.

## 7. Place burst

Keep existing `trophy_place_burst_f0.png` … `f4.png` unless the new mount size makes them look tiny. If you redo them: native **48×48**, additive gold dust, registered around the item well.

---

## Do not draw

- Do not redraw any item or monster card.
- Do not put English, numbers, or bucket labels on plaques, doors, or chains.
- Do not paint 40 items into the interior background.
- Do not change the fireplace, chair, rug, window, or hero unless a file above overlaps them (doorways must not cover the chair).

## How code will plug this in

```
res://assets/dungeon/home/<filename>.png
```

Engine loads by stem (`trophy_mount_seen`, `gallery_door_left`, …). If a stem is missing, it falls back to the current 32×40 mount. Matching filenames are the whole integration.

Registration lock:

| File | Native | 4× | Well / pivot |
|---|---|---|---|
| trophy_mount*.png | 40×56 | 160×224 | empty 16×16 at (12, 10); nameplate bottom 40×14 |
| plaque_glint_f*.png | 24×14 | 96×56 | top-left of gold plate |
| gallery_door_* | 36×88 | 144×352 | top-left; right door ~ native (364, 100) |
| gallery_cordon.png | 260×160 | 1040×640 | fills the shelf hole |

## Handoff

Return the folder of PNGs named as above, plus a one-page note of native sizes. Do not ship guide overlays into the game build.
