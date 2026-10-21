Follow-up for pass 2 on branch anim/pass2-slash-portrait (commit 879401e is yours). Re-read design/visual/ANIM-slash-portrait.md.

New: the final PixelLab slash art has been dropped into assets/dungeon/anim/slash/ for 54 monsters (<id>_slash_base.png + <id>_slash_f0..fN.png; native sizes 32/48/64/80 px, 4-6 frames). It overwrote your Ogre placeholders. Hornet Swarm and Almighty Worm deliberately have NO files yet (touch-ups pending) and must keep using the still punch-in fallback.

Do:
1. Import the new PNGs headless (Filter Nearest, no mipmaps, Lossless, same settings as the existing ogre .import files) and commit the PNGs plus their .import files. Revert every unrelated --import churn (other .import files, project.godot, default_bus_layout.tres) before committing.
2. Make sure the cut-in sizes each monster's frames by their native size (shown at 4x, or fit to the spec's portrait box if 80px at 4x is too big) and never assumes 64x64. Frame count comes from the files present.
3. The cut-in must not depend on the number of wheel seats (the game can run 4-8 seats; a test branch uses 6). Check ability_slash.gd and the harness for any 8-seat assumption, and add a QA shot of an Ogre cut-in with 6 seats seated.
4. Rewrite assets/dungeon/anim/slash/PLACEHOLDERS.md: list which monsters have final art now, and keep hornet_swarm and almighty_worm (expected filenames) as still pending.
5. Re-run the QA at 1680x1040 into design/visual/anim-qa/slash-portrait/, overwriting the PNGs: Ogre at 60/300/700ms (compare 300ms against design/visual/mock_slash_portrait_ogre.png), Hornet Swarm using the still fallback, Vampire now using its real frames (rename the shot 05_vampire_frames.png and delete 05_vampire_still.png), three queued triggers never overlapping, first Ogre cut-in longer than the second, item trigger still showing the small banner, plus 10_ogre_6_seats.png. Look at every PNG you produce.
6. Remove design/visual/anim-qa/slash-portrait/_run.log from the branch (stray log). Run Godot headless --quit and confirm no new SCRIPT ERROR / parse errors, and run the text audit (no "Tier").

Rules: never show "Tier"; use only existing copy; respect payload.fast and Engine.time_scale; don't touch input bindings. Nathan's Godot editor is open on his main folder: never touch it, the main folder, other worktrees, or the branch `movement`; one Godot process at a time on this worktree. Don't commit .wrangler/, .art-ping.env, .art-ping.last, build/ or stray logs; never read or print .art-ping.env. Don't push, merge, rebase, stash or reset.

Commit on the branch as anim-pass2(2): with a summary of what changed and the final screenshot list. Don't export or push to itch.
