# Trophy board art batch: report (2026-11-13)

Spec: `/workspace/trophy-board/ASSETS.md` + `SCREEN-trophy-board.md`. Repo checked against `origin/playtest/latest` (`92c46120`). The local clone holds an equivalent rebased commit (`0132c37e`, empty diff), so I didn't reset it. Nothing was pushed.

## Credits
- Before: **705.9**. After: **635.9**. Spent: **70.0** (70 successful generations at 1 credit each).
- 17 more requests were rejected for free (422): 24x24 crests and 16x32 levers are under PixelLab's 32x32 minimum area. The crests were redone at 32x32 and cropped to 24x24. The lever was hand-pixelled.
- The balance never went near the 100 floor. The runner checks `balance - 6 >= 100` before every call.
- Call log: `art/calls.log`. Scripts: `art/gen/`.

## What shipped (123 PNGs, all at the stored size, exact x4 nearest-neighbour from native)
Every file in ASSETS.md sections A, B, C, D and E is present. Sizes were checked against the spec by script: 123/123 matched, none missing.

| Group | Files | How it was made |
|---|---|---|
| A1/A1g/A2 rooms | `room_trophy.png`, `room_trophy_glow.png`, `room_main.png` | Pixel edit of the existing plates (no AI). Hall: the frame, chained door, stool and old sconce are removed. The wallpaper (12x28 tile), wainscot and ceiling beams (64 px period) are rebuilt from the plate's own pixels, with two sconces at the spec spots. Main: only x242..300 / y121..207 changed (checked by diff): the centre door becomes log wall and floor, plus a peg rail with a coat, hat and scarf. |
| B1/B14/B2 frame, gold trim, cog | | Hand-pixelled to the exact geometry: window (12,22,308,154), plaque recess, cog sockets at (6,58)/(325,58), dot groove centred under the 5 dots. Fluted rails and brass caps use the old hall frame's look. |
| B3 backdrops x5 | `face_bg_*` | PixelLab pixflux 308x156 with a biome palette, 3 candidates each. Cropped to 154 rows, toned down, middle darkened one step, quantised to 24 colours. |
| B4 crests x5 | `crest_*` | PixelLab 32x32, 3 seeds per biome. The seed-29 set was picked so all five share one shield shape, then cropped to 24x24. Leaf / crystal shard / skull / anvil+flame / crescent eye. |
| B5 plaques x5 | `plaque_*` | PixelLab 120x24, 2 candidates each, with the flat brass centre (x14..106, y6..18) painted in afterwards. Trims: vines / ice rime / bone knobs / riveted iron with embers / shadow tendrils. |
| B6 padlock (+hover) | | PixelLab 40x48, 3 candidates. Hover is a one-step brightening. |
| B7 lights, B7f flash, B8 lever (locked/ready/pulled/pull x5/glow), B9 arrows x6, B10 dots x4 + pip x2, B11 recesses x4, B12 aura x6 + compact x6, B13 twinkle x4, B16 rise glint x6, B17 poof x5, B18 dust x3 | | Hand-pixelled in the spec palettes (BRASS/WOOD/IRON/LINEN, outline #100e0c). |
| B15 satchel idle/open x4/close x3 | | PixelLab 48x40 (3 candidates; picked the clean front-view one with red stitching and a brass buckle). The open and close frames are hand-derived from it. Its outer edge was recoloured to #100e0c. |
| C1/C2 splashes x9 | `splash/portal_*`, `splash/shortcut_*` | PixelLab pixen at the **full 420x208 native size** (2 candidates each), so no x8 fallback was needed. The bottom 40 rows are darkened for the Nib bar. |
| D map | fog x4, fog_clear x6, node_glow x4, start_pointer, badge (blank), path_dash | Hand-pixelled. PixelLab fog came back as mountains and forest, so I rejected it. |
| E Nib | `nib_react_f0..f3`, `nib_watch` | Pixel edits of `nib_idle_f0` at 24x32. They keep his palette and feet row 30. |

Also in `ship/`:
- `assets/ui/trophy_board/SIZES.md` (new).
- `assets/dungeon/home/SIZES-trophy-additions.md`: rows to merge into `assets/dungeon/home/SIZES.md`. I didn't edit the repo file.

Skipped on purpose, because the spec marks them [TW]/code: the item silhouette, the known-node tint, the skip button, the hover card, the slide/shake/fly motion, and the fog drift.

## Deliverables
- `ship/` (repo-mirrored) and `ship.zip`
- `alts/`: every candidate at x4, with the chosen one prefixed `PICKED_`. Covers crest, face_bg, plaque, padlock, satchel and splash.
- `contact-sheet-1.png`: small UI and FX. `contact-sheet-2.png`: frame, backdrops, plaques, satchel, map, Nib. `contact-sheet-3.png`: rooms and splashes.
- `mock-board.png`: 1680x1040 Verdant Hollow face with the real b1 pool laid out 3/5/6 per the §3 math. It mixes unseen silhouettes, seen and claimed items (lit recess, aura and twinkle). 3 of 5 lights are lit, the lever is locked, and there's a new pip on dot 2.
- `mock-board-unlock.png`: 5 lights lit, lever ready with its glow, Nib in his react pose.
- The plaque name in the mocks is rendered with EB Garamond SemiBold only to show placement. It isn't baked into any asset.

## Missing
- Nothing in ASSETS.md is missing.
- Audio (section F) is Reel's job and wasn't in scope.

## Fidelity concerns (for Pixel / Nathan review)
1. **Backdrops carry their own inner border** (moss frame, stone border, riveted plate, ice rim). Inside the oak board frame this reads as a second inner frame. The verdant grass and the cinder flames along the bottom sit behind the bottom pyramid row and are busier than "low contrast". The crystal backdrop is still fairly light. If these read as too busy in game, the alternates are in `alts/face_bg/`. A plain hand-painted re-tone of the middle would also work.
2. **The splashes are a different art idiom from the cabin.** They're denser pixen pixel art with ~20+ colours and a generic dungeon-stone look. They are on the x4 pixel grid, which the existing `biome_splash/bg_*` paintings are not. The pinned notes have scribble lines, not legible text.
3. **The lever and the satchel open/close frames are hand-made and simple.** The chain on `lever_locked` is a thin diagonal; the lock state relies mostly on the dull knob. A PixelLab lever was impossible at 16x32.
4. **The Nib edits are minimal.** The react clap is a small blue hands block on his chest. `nib_watch` only shifts his face 1 px left and hides his hands; there is no real 3/4 turn. Fine at 96x128 in game, but it needs a real redraw if Nathan wants a clear turn.
5. **Room plate:** a few 1-px floor-joint specks remain where the old frame's feet stood (native y 197..203), and they're barely visible. `cabin-layout.json` main still lists the `RunDoor` sprite at (250,130), so Package A has to drop that node or the door sprite will draw over the new wall.
6. **Shared `fog_clear`** starts from the `fog_crystal` shape. On the other three nodes the first frame swaps silhouette slightly. The spec asked for one shared set; per-node variants would be cheap if that's noticed.
7. **Spec mismatch:** ASSETS B1 gives the dot groove as native x132..252, which doesn't line up with the SCREEN dot positions (x 712+k·56 → native 134..198). I centred the groove on the actual dots (x127..205).
