# Mudroom batch B: wire art (Cursor agent)

Read `manifest.json` in this folder. Copy each PNG to its `target` path in the repo (see manifest). Do not edit PNG bytes.

## Build
1. Build the mudroom loadout room in code. Back wall: NinePatchRect or tiled TextureRect with `mudroom_wall_96.png`. Floor: horizontal tile of `mudroom_floor_96x32.png`. Props: place `mudroom_pegs_96x32.png` on the back wall, `mudroom_boots_32x32.png` on the floor, and `mudroom_prep_table_96x48.png` on the right.
2. Use Nearest filter, no mipmaps. Keep 4 px grid alignment for sprites.
3. Replace the `room_workshop` stand-in on the loadout entry point only. Do not change the other four cabin rooms.
4. Do not change layout, copy, or wheel position (548, 350). Do not add text.

## Checks (headless)
- `godot --headless --path . --import` runs with no new parse errors.
- Text audit and layout check selftests pass, if present.
- `py -3 tools/qa/check_ui_pngs.py` passes, if present.

## Done
Comment on the PR with the list of changed files and check results. Merge rule applies per the automation instructions.
