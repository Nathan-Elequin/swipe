Build pass 2 of the animation plan (`design/visual/BUILD-ORDER.md`): the slash portrait cut-in. Implemented with the Cursor CLI. Logs are in `design/cli-runs/10-anim-pass2/`. `PROMPT.md` is the Pass 2 prompt verbatim. `PROMPT-fix.md` is the follow-up that adds the final art, native sizing and a 6-seat check. The attempt-1 log is a network drop that made no edits.

## What changed
- **`scripts/ability_slash.gd`**: monster payloads now play a full-screen diagonal band cut-in at 1680x1040. It has:
  - a dim layer and a band with speed lines (`shaders/slash_lines.gdshader`)
  - a flash disc whose colour depends on the ability family
  - the portrait at 4x, sized from each frame's native canvas (80px art is fitted into a 256px box)
  - the name and call name
  - timings: snap in 120ms, frames at 70ms, hold 120ms, slash out 160ms
- Each monster's first cut-in in a run holds an extra 250ms (`_slash_seen`, reset in `_reset_run`). The cut-in honours `payload.fast` and `Engine.time_scale`.
- Item triggers keep the small gutter banner unchanged.
- **`scripts/dungeon_art.gd`**: new `monster_slash_frames(id)` loads `assets/dungeon/anim/slash/<id>_slash_f*.png` by path. If a monster has no frames, it falls back to `monster_still` with a punch-in (scale 3.6 to 4.0, 2px shake).
- **`scripts/main.gd`**:
  - Triclops gets the call name "Cut And Run" when its `call_name` is empty.
  - The gutter is parked for item banners only.
  - `reset_slash_seen` is called at run start.
- Nothing depends on the seat count. QA includes a 6-seat Ogre shot.

## Art
- **Final PixelLab slash frames for 54 monsters** (base plus 4-6 frames each) are in `assets/dungeon/anim/slash/`, imported with Nearest, no mipmaps, Lossless.
- **Hornet Swarm and Almighty Worm have no files yet**, because touch-ups are pending. They use the still punch-in fallback, and their expected filenames are listed in `assets/dungeon/anim/slash/PLACEHOLDERS.md`.

## QA (1680x1040, shot harness)
godot-mcp attaches to the open editor on the main folder, not this worktree, so the shots come from the repo shot harness.

Screenshots in `design/visual/anim-qa/slash-portrait/`:
- `01_ogre_60ms`, `02_ogre_300ms`, `03_ogre_700ms` (300ms checked against `design/visual/mock_slash_portrait_ogre.png`)
- `04_hornet_still`
- `05_vampire_frames`
- `06_queue_three`
- `07_ogre_first`, `08_ogre_second`
- `09_item_banner`
- `10_ogre_6_seats`

Results:
- Three queued triggers never overlap.
- The first Ogre cut-in runs about 1504ms and the second about 1134ms.
- `godot --headless --quit` exits 0 with no script or parse errors.
- The text audit finds no "Tier". Its only hit is the existing Shield "4" overflow, which was there before this pass.

Not exported or pushed to itch.
