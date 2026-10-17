# Home Cabin — art brief

Paste this entire file to the sprite / asset agent as the first message. They do not need the Godot repo. Existing item and monster card sprites stay. This agent does **not** redraw cards.

You are drawing a new **place**: a small wooden cabin the thief walks home to. Code will composite looping parts and drop existing 16×16 (4×) item icons onto mounts. You draw the room, the door, the hero, the fire, the lantern, and one reusable trophy mount.

---

## Style lock

- Same pipeline as the rest of this game: draw at native pixel size, then **4× nearest-neighbor**. No blur, no photoreal photographs, no AI-photo look.
- Palette (use these hexes, plus close neighbors): wood `#3a2416`, wood highlight `#5a3a24`, gold `#c4a574`, hot gold `#e8c36a`, dark interior `#120e0c`, warm window `#e8c36a` / `#f8d48a`, night trees `#1c1814`.
- Outline-first, chunky pixels. Kenney Tiny Dungeon / 0x72 energy — not a second art style.
- Unique-art rule does **not** apply to furniture (one fireplace is fine). It **does** apply if you invent a new collectible object that is not a mount. Do not invent collectibles.

## Screen size

Game viewport is **1680×1040**.

Author backgrounds at **420×260** pixels, then 4× nearest → exact fullscreen. Do not letterbox. Do not add black bars.

Safe click zone for the door: at least **48×64 native** (192×256 on screen).

## Folder and format

All files go in `assets/dungeon/home/` (new folder).

PNG, RGBA, indexed-looking palettes, no JPEG. Transparent where noted. Filenames must match exactly.

---

## A. Exterior (one place, night, cozy)

- `cabin_exterior.png` — 420×260. Small wooden cabin in trees/hills, **closed door**, one window with warm light, hanging lantern. Ground **path from the left edge** (that is where the camera pan arrives). Night, not noon.
- `cabin_door_closed.png` — door only, transparent background, to overlay if easier than a baked door. Same perspective as the exterior door.
- `cabin_door_open_f0.png` … `cabin_door_open_f2.png` — 3 frames, door swinging **inward**. Same size and registration as the closed door.
- `lantern_swing_f0.png` … `lantern_swing_f2.png` — 3 frames, same pivot, **12–16 native px**. Loop. Warm yellow, not white.

## B. Interior (one place, mantle + chair)

- `cabin_interior.png` — 420×260. Fireplace/mantle on the back wall, rocking chair **left of the fire**, wood floor, enough blank wall for bucket shelves. Leave a **clear rectangle** on the right/back wall for code to spawn shelf rows. **Do not paint 40 items into the background.**
- Suggested shelf hole: x=140–400, y=20–180 in native pixels (code will scale ×4).
- `cabin_interior_guides.png` — same 420×260 as the interior, with a **magenta 1px rectangle** around that shelf hole. Not shipped in the game; guides only.

## C. Hero

This game has **no player sprite** today. Nib (tutorial goblin) is not the thief. Draw a new side-view hooded thief / loot-swiper that matches Tiny Dungeon silhouettes.

- Native **32×32** per frame (4× → 128px on screen). Transparent. Feet planted on a 1px shadow.
- `hero_walk_f0.png` … `hero_walk_f3.png` — 4 frames, walking **right**.
- `hero_walk_loot_f0.png` … `hero_walk_loot_f3.png` — same walk, sack of loot on the back (arrive at the cabin).
- `hero_rock_f0.png` … `hero_rock_f3.png` — sitting in a rocking chair, 4 frames, subtle. **Bake the chair into these frames** so seating does not clip.
- Idle blink optional. **No attack frames.**

## D. Fireplace

- `fire_f0.png` … `fire_f2.png` — 3 frames, same size, loop. Native **32×32** so it reads on the mantle.
- Do not reuse combat `flame.png`. That is a burst, too small and too wild.

## E. Trophy mount (one reusable object, not 40 item paintings)

- `trophy_mount.png` — native **32×40**. Wooden shield/plaque. Empty center ~16×16 where code drops the existing item PNG. Gold nameplate strip along the bottom (~32×8) with **no letters** (engine draws the name).
- `trophy_mount_hover.png` — optional brighter gold rim. Engine can also modulate.
- `plaque_glint_f0.png` … `plaque_glint_f3.png` — tiny **16×8** spark sweep, additive-friendly white/gold. Stronger on hover is an engine alpha, not a second sheet.

## F. Collection states (shelf chrome)

- `shelf_locked.png` — dark silhouette of a shelf row + padlock. Wide enough for 4 mounts (native ~128×40). Used for unopened buckets.
- `item_seen_overlay.png` — 16×16 grey outline frame. Engine may instead modulate the item to grey; this overlay is a fallback.

## G. Do not draw

- Do not redraw any item or monster card.
- Do not put English on plaques, doors, or banners.
- Do not draw a second HUD, hearts, or the dungeon wheel in these scenes.
- Do not animate the whole room as a GIF. Separate looping parts (fire, lantern, rock, glint).

---

## Animation timing (match the engine)

- Walk-off: 0.7–1.0s, ~8fps walk.
- Pan to exterior: 0.6s ease-out.
- Door click → open: 0.35s, then cut or 0.2s fade to interior.
- Fire / lantern / rock: loop, 6–8fps, never stop while the interior is up.
- Plaque glint: 1.2s loop at rest, 0.4s loop on hover.

## Handoff

Return a folder of PNGs named as above, plus a one-page note of native sizes for each file. Do not ship `cabin_interior_guides.png` into the game build; keep it next to the interiors so the implementer can align shelves.
