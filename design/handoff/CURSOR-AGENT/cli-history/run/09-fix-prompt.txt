Follow-up QA fix for pass 1 on branch anim/pass1-intent-bleed (commit 5c3702b is yours). Re-read design/visual/ANIM-intent-plate.md and design/visual/ANIM-bleed-pulse.md QA sections.

Reviewer found these QA problems in design/visual/anim-qa/:
1. intent-plate/01_hornet_plate.png, 02_hit1_lit.png and 03_hit2.png show NO intent plate at all (03/04 scenarios do). The first Hornet Swarm scenario must show two badges, each "2". Find out why the plate is missing on the first scenario (sync timing, plate not created yet, visibility, layout) and fix the real cause in game code if it is a game bug, not only in the harness.
2. 02_hit1_lit / 03_hit2 must come from the real Take path (btn_done -> _apply_resolve_hits -> _owner_attack -> fire), captured mid-sequence, so badge 1 is visibly lit/spent before badge 2. Don't call intent_plate.fire() directly from the harness.
3. 04_hornet_block_soak: capture the moment badge 1 flashes blue on the real Take with 2 Block; it must still read 2.
4. bleed-pulse/01_hornet_two_rings: drive it through real HP loss on Take (not bleed_pulse.on_bled() from the harness), capture while both rings are visible, with Spiked Flail + Vampire hopping.
5. bleed-pulse/02_poison_pacemaker: capture while the ring is visible after the poison tick of 2 (heal 1 already works).
6. Revert design/qa/logic-pass/covering/progress.json to its origin/main content (a 4-row subset run overwrote the 131-row snapshot). Keep the two new poison-tick rows.

Then re-run the shots at 1680x1040, overwrite the PNGs, re-run the pacemaker and blood_chalice covering rows (poison-tick rows must pass), run scripts/dev/text_audit.gd, and run Godot headless --quit to confirm no new SCRIPT ERROR / parse errors. Look at every PNG you produce before you finish.

Rules: never show "ATK"/"atk" or "Tier" to players in new UI; new strings go through PLAYER_COPY.text(); respect Engine.time_scale; don't change Space or input bindings. Nathan's Godot editor is open on the main folder: never touch it, the main folder or other worktrees; one Godot process at a time on this worktree. Revert --import churn (.import files, project.godot) you didn't mean to change before committing. Don't commit .wrangler/, .art-ping.env, .art-ping.last, build/ or stray logs; never read or print .art-ping.env. Don't push, merge, rebase, stash or reset.

Commit on the branch as anim-pass1(2): with a summary of what changed and the final screenshot list. Don't export or push to itch.
