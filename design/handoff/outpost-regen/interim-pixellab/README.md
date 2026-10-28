# Spinheritance Outpost art pack v3 (Torchlit Burrow), 2026-10-28

Made with the PixelLab `/create-image-pixflux` endpoint (text_guidance 8, single colour black outline, medium shading, medium detail, palette `color_image`). After generation every image was snapped to the palette (Lab nearest), downscaled with mode sampling where it was made at 2×, despeckled, cleared of islands and orphan pixels, and given a rebuilt 1px `#100E0C` outline on transparent sprites. Alpha is 0 or 255 only. Scaling is nearest-neighbour at integer factors only. No text, letters or numbers, and no "Tier".
The final files are in `final/`. Raw generations are in `raw/`. Scripts are `plx.py` (API, budget cap 80), `pal.py`, `inits.py`, `post.py`, `finalize.py` and `contacts.py`.
Spend: **51 gens** (cap 80). Balance went from 1135 to **1084**. See `calls.log`.

## Palette
Core (all files): soot 1A120E, hub 140D0A, void 0B0706, oak 3B2618, inset 4A2F1F, seat-wood 5A3A22, edge 7A4E2B, rivet B8733A, parchment E9D3A1, dim A88C66, bait gold FFD84A, torch F09A34, ink 100E0C.
Biome trim accents (cases only, since biomes need their own colour): verdant 2E4A1E/4F7A2A/7BA83E · mire 33331A/5E5E2A/8A8A3E · ashen 2E2E32/4A4A4E/7A7A80/B0B0B4 + crimson 8A1E24 (all brown wood remapped to grey) · cinder 5A1E0E/C0461C · shadow 1E1A3A/3A2E6A/6A5AA8.

## A) Outpost room layers (replace the mudroom tiles; filenames kept for wire compatibility)
| final/ file | size | Godot target |
|---|---|---|
| mudroom_wall_96.png | 96×96 | assets/dungeon/home/mudroom/mudroom_wall_96.png |
| mudroom_wall_96_x4_384.png | 384×384 | optional, see the note |
| mudroom_floor_96x32.png | 96×32 | assets/dungeon/home/mudroom/mudroom_floor_96x32.png |
| mudroom_pegs_96x32.png | 96×32 | assets/dungeon/home/mudroom/mudroom_pegs_96x32.png |
| mudroom_boots_32x32.png | 32×32 | assets/dungeon/home/mudroom/mudroom_boots_32x32.png |
| mudroom_prep_table_96x48.png | 96×48 | assets/dungeon/home/mudroom/mudroom_prep_table_96x48.png |
| outpost_room_plate_420x260.png | 420×260 | assets/dungeon/home/rooms/outpost_room_plate_420x260.png (reference) |
| outpost_room_plate_1680x1040.png | 1680×1040 | assets/dungeon/home/rooms/outpost_room_plate.png (optional bg) |
| outpost_room_plate_alt_420x260.png | 420×260 | reference only (alternate seed) |

Wall nine-slice note: `cabin_kit.nine()` sets `patch_margin = 12 * PX` (48) on a 96px texture, which leaves no centre. Either use the 384px ×4 copy (its 48px margin matches the 12px native beam border) or set the margins to 12 on the 96px file.
Plate note: generated at 400×248 (the API caps at 400 and needs multiples of 4), then reflect-padded 10px on the left and right and 6px on the top and bottom to reach 420×260.

## B) Biome trophy cases (124×400 RGBA, open frame, no glass, transparent outside)
| final/ file | Godot target |
|---|---|
| case_verdant_hollow.png | assets/dungeon/home/cabinets/case_verdant_hollow.png |
| case_sunken_mire.png | assets/dungeon/home/cabinets/case_sunken_mire.png |
| case_ashen_crypt.png | assets/dungeon/home/cabinets/case_ashen_crypt.png |
| case_cinder_forge.png | assets/dungeon/home/cabinets/case_cinder_forge.png |
| case_shadow_abyss.png | assets/dungeon/home/cabinets/case_shadow_abyss.png |
The interior is forced to solid void #0B0706 at native x 16..107 and y 44..366, which is the item-mount area.

## C) Held map (Sprout POV)
| final/ file | size | Godot target |
|---|---|---|
| map_held_parchment_420x260.png | 420×260 | assets/ui/map/held/map_held_parchment_420x260.png |
| map_held_parchment_1680x1040.png | 1680×1040 | assets/ui/map/held/map_held_parchment.png |
| map_hands_overlay_420x260.png | 420×260 | assets/ui/map/held/map_hands_overlay_420x260.png |
| map_hands_overlay_1680x1040.png | 1680×1040 | assets/ui/map/held/map_hands_overlay.png |
| map_hands_overlay_left.png | 135×112 | assets/ui/map/held/map_hands_overlay_left.png |
| map_hands_overlay_right.png | 108×101 | assets/ui/map/held/map_hands_overlay_right.png |
The parchment is transparent outside the sheet. It has five blank stamp circles at native (≈70,186) (≈140,106) (≈215,176) (≈290,91) (≈355,166) (±4px, after padding), joined by dotted navigator lines, with small ink glyphs in the corners. The hands overlay uses the same 420×260 canvas, so draw it on top of the parchment at (0,0).

## D) Contact sheets (for Nathan)
CONTACT_outpost_layers.png (tiles at ×4, a tiled layer preview at the code positions, both plates at ×2) · CONTACT_cases_v3.png · CONTACT_map_hands.png

## Rerolls and failures
- Map at 210×130 returned 422 twice (no charge; the size must be a multiple of 4). It was rerolled at 400×248. Seed 43 drew letters and was rejected; seed 44 is used.
- Cases v1 (init strength 200) came out flat, so v2 used strength 90. Ashen v2 came out brown and was remapped to ash grey in post. A door handle on the mire case was painted out.
- Floor v1/v2 had a baked spotlight, so v3 used a plank block-in init (s15). Seed s16 never ran because of a local file error (not charged).
- Hands: single-hand gens were weak and the pair at strength 150 came out as blobs. The pair at strength 40 (s58) is used, with the held paper and background removed in post.
- Wall v1 had a lamp and spotlight, so the v2 beam frame (s14) is used, cropped to the frame.
