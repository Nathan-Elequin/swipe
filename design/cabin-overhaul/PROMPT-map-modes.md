# Visual prompt — Map mode picker (Adventure = Challenge weight)

Paste this whole file to the visual-designer agent. They return PNGs this repo can drop in with no follow-up interview.

The cabin map is how the player starts a run. Right now the mountain drawing plus tiny pins make **Challenge Mode** invisible, and **Adventure Mode** does not read as an equal choice. Code is already wired: two equal tags at the bottom of the sheet (`Adventure Mode`, `Challenge Mode`), a smaller `Quick Start`, pin hitboxes, a description parchment, Back / Off we go. These files replace the art those nodes sit on.

## What to return

Folder: `assets/dungeon/home/overlays/`

Native sizes below. Also ship each file **4× nearest-neighbor** (no blur, no generated mip). Transparent unless noted.

| File | Native px | 4× px | Notes |
|---|---|---|---|
| `map_close.png` | 360×232 | 1440×928 | Opaque parchment mountain sheet. This is the whole close-up. |
| `map_plaque_adventure.png` | 148×18 | 592×72 | Transparent. Idle plaque. |
| `map_plaque_adventure_hover.png` | 150×20 | 600×80 | 2px larger; register at origin − (1,1) native. |
| `map_plaque_adventure_press.png` | 150×20 | 600×80 | Same as hover, pressed. |
| `map_plaque_challenge.png` | 148×18 | 592×72 | Same template as adventure. Equal weight. |
| `map_plaque_challenge_hover.png` | 150×20 | 600×80 | |
| `map_plaque_challenge_press.png` | 150×20 | 600×80 | |
| `map_plaque_shortcut.png` | 92×16 | 368×64 | Smaller. Third option, not equal to the two mains. |
| `map_plaque_shortcut_hover.png` | 94×18 | 376×72 | |
| `map_plaque_shortcut_press.png` | 94×18 | 376×72 | |
| `map_marker_adventure.png` | 20×32 | 80×128 | Transparent pin/house at The Gatehouse. |
| `map_marker_adventure_hover.png` | 22×34 | 88×136 | |
| `map_marker_adventure_selected.png` | 20×32 | 80×128 | Selected. |
| `map_marker_challenge.png` | 20×32 | 80×128 | Same silhouette language as adventure, different color/icon. |
| `map_marker_challenge_hover.png` | 22×34 | 88×136 | |
| `map_marker_challenge_selected.png` | 20×32 | 80×128 | |
| `map_marker_shortcut.png` | 16×24 | 64×96 | Smaller marker. |
| `map_marker_shortcut_hover.png` | 18×26 | 72×104 | |
| `map_marker_shortcut_selected.png` | 16×24 | 64×96 | |
| `map_desc_panel.png` | 132×72 | 528×288 | Optional 9-slice-friendly parchment for the description box. If you only ship a flat panel, keep a 10px native margin that can stretch. |

Also return a one-page size list (filename, native, 4×, transparent/opaque).

## How code uses these

- `map_close.png` is a TextureRect at native origin (30, 14) on a 420×260 cabin screen (1680×1040 at 4×). It does not include the UI tags; tags are drawn on top.
- Plaques replace the current 9-slice choice tags. Code places:
  - Adventure plaque at sheet-local **(16, 196)**
  - Challenge plaque at sheet-local **(176, 196)** — same size, same row, same visual weight
  - Shortcut plaque at sheet-local **(16, 218)**
- Markers sit on the mountain at layout pins (sheet-local): Gatehouse **(92, 168)**, Long Drop **(184, 92)**, Shortcut **(268, 150)**. Pivot is the point of the pin / feet of the house (bottom-center).
- Selected marker swaps to `*_selected`. Hover uses the 2px-larger file at origin − 1 native.
- Description panel at sheet-local **(214, 88)**. Code still writes title + body on top; leave the panel empty of English.
- Depth flags already exist (`map_flag.png`). Do not redraw those as clickable mode pins. They are progress marks on the center path, not start buttons.

## What to draw on `map_close.png`

Keep the mountain / Mount Grumblegut idea. Change the **information design**:

1. **Two equal destinations** on the mountain: a house/gate at the foot (Adventure / The Gatehouse) and a high camp or long drop at the peak (Challenge / The Long Drop). Same icon scale. Same contrast. A stranger should see two places to go, not one house and a bunch of tiny flags.
2. **Quick Start** is a goat-path or rope off to the right, clearly smaller, labeled by the plaque not by a third giant landmark.
3. **Do not draw English.** No words, no “Adventure”, no “Challenge”, no “X = treasure”. Code owns all text.
4. The center dashed path may keep small progress flags, but they must read as **marks on a trail**, not as the things you click to pick a mode. Smaller than the two mode markers, muted, not house-shaped.
5. Leave a **clear band** across native y 196–232 with low-contrast ground so the two plaques and the shortcut plaque sit on it without fighting the peak.
6. Leave the upper-right slope (native ~214,88, 132×72) relatively quiet for the description panel.

## Palette

Match the cabin overlays (nearest-neighbor 16-bit-looking, not photoreal):

- Parchment: `#f0e6d8`, `#e2d0b0`, `#c4a574`
- Ink: `#3a2414`
- Muted: `#a8946c`, `#6e5434`
- Night sky if you keep stars: `#1c1814` with sparse `#f0e6d8` dots
- Adventure marker: warm lantern gold `#e8c36a`
- Challenge marker: same gold, plus a deeper rust `#8a4030` so it is distinct but not louder
- Shortcut marker: muted brown `#6e5434`

## Do not

- Do not put English on the mountain, plaques, or markers.
- Do not make Challenge a tiny flag and Adventure a big house.
- Do not redraw cabin room art, Nib, or card sprites.
- Do not ship photographs.
- Do not antialias; 4× nearest-neighbor only.

## Style

Kenney Tiny Dungeon / Jetrel / 0x72 adjacent. Same family as `overlays/map_close.png` already in the folder, but with the layout rules above. Close is allowed; a torch for a house is not.
