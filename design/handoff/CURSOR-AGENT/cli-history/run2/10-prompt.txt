Read design/visual/_COMMON.md and design/visual/ANIM-slash-portrait.md, then implement the cut-in system on branch anim/pass2-slash-portrait.

Scope:
1. Upgrade scripts/ability_slash.gd; keep its queue (play → _drain → _show).
   - For monster payloads (is_item == false), play the full-screen diagonal band cut-in from the spec: dim, band with speed lines, flash disc by ability family, portrait at 4x, name + call name. Timings: snap in 120ms, frames at 70ms, hold 120ms, slash out 160ms.
   - Items (is_item == true) keep the current small gutter banner unchanged.
2. A monster's FIRST cut-in in each run holds +250ms. Track `_slash_seen` and reset it at run start.
3. Add `monster_slash_frames(id)` to scripts/dungeon_art.gd, loading `assets/dungeon/anim/slash/<id>_slash_f*.png` (and `<id>_slash_base.png`). If no frames exist, fall back to `art.monster_still(id)` with a Tween punch-in (scale 3.6→4.0, 2px shake). That fallback is the default for every monster in this pass.
4. Honour payload.fast and Engine.time_scale. Don't touch input bindings.
5. Size and place the node full-rect 1680x1040, replacing the gutter sizing in main.gd around L15003 for the monster path only.

Art: PixelLab slash frames aren't in yet. Don't create per-monster placeholders; the still fallback covers them. Create one placeholder set to prove the frame path: assets/dungeon/anim/slash/ogre_slash_base.png and ogre_slash_f0.png … ogre_slash_f4.png (64x64, made from the current Ogre still). Add a shader at shaders/slash_lines.gdshader (create that folder if there isn't one). List the expected filenames for all 56 monsters (from the spec table) in assets/dungeon/anim/slash/PLACEHOLDERS.md.

Use only existing copy (title and call_name from the payload), plus Triclops's call name "Cut And Run" if call_name is empty for triclops. Never show "Tier".

QA with godot-mcp at 1680x1040, saving to design/visual/anim-qa/slash-portrait/:
- Ogre ability: shots at 60ms, 300ms and 700ms after the cut-in starts. Compare 300ms against the mockup mock_slash_portrait_ogre.png (Pixel will attach it).
- Hornet Swarm and Vampire use the still fallback.
- Three queued triggers never overlap.
- The first Ogre cut-in in a run is longer than the second.
- An item trigger still shows the small banner.
Run scripts/dev/text_audit.gd.

Commit on the branch with the files-changed summary and the screenshot list. Don't export or push to itch.
