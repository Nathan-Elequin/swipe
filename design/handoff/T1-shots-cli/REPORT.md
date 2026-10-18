# T1-shots-cli — REPORT

## Status
PASS (code) / shots pending

## Checkpoint
`aa2bfd6db82a4c95faff550bd4bab3b88ccd1b48` (branch point, before this task)

## Commits
- `8b99196adc38c20e84d6d86daaf684b7feffbf9e` — T1-shots-cli(1): add the --shots runner and save backup.
- T1-shots-cli(2): this REPORT.md

## Files changed
- `scripts/main.gd` — `--shots` / `--text-targets` starts the harness; normal boot restores a leftover marker
- `scripts/shot_cli.gd` — arg parse, template gate, save backup / marker
- `scripts/dev/shot_harness.gd` — one stem → function table, selected captures, exit code
- `scripts/dev/text_audit.gd` — audit copy follows `--shots-out`
- `tools/qa/check_shot_cli.gd` — headless parse check (does not boot the game)

## Shots
No PNGs. Windowed Godot was not started.

64 stems (plus the name `all`):

`30_hub_idle`, `31_hub_badges`, `32a_blk_empty`, `32b_blk_full`, `32c_blk_up`, `32d_hp_flash`, `32e_hp_low`, `32f_hp_empty`, `33_pierce_float`, `34a_swipe_f2`, `34b_hit`, `34c_block_f1`, `34d_heal_f2`, `34e_grab_f1`, `34f_victory`, `34g_death_f3`, `35_death_dim`, `36a_gear_helm`, `36b_gear_helm_swipe`, `36c_gear_cap`, `36d_gear_none`, `37a_clear_idle`, `37b_clear_swipe_f2`, `37c_clear_block_f1`, `37d_clear_heal_f2`, `37e_clear_lowhp_f0`, `38_courier_walkoff`, `39_untouched`, `40a_cabin_gear_helm_sit`, `40b_cabin_gear_helm_rock`, `40c_cabin_gear_helm_walk`, `40d_cabin_gear_helm_walk_sad`, `40e_cabin_gear_helm_dump`, `40f_cabin_gear_helm_shake`, `41a_cabin_rock_cap`, `41b_cabin_rock_helm`, `42_cabin_gear_none`, `43a_cabin_flip_walk_loot`, `43b_cabin_flip_dump`, `15a_map_classic_selected`, `15b_map_challenge_hover`, `15c_map_challenge_selected`, `18_rope_exit_belly1`, `19_rope_exit_sack_peek`, `20_caught_sheet`, `21a_win_homecoming_dump`, `21b_win_homecoming_fly`, `22_loss_homecoming`, `13a_intro_panel1`, `13b_intro_panel2`, `13c_intro_panel3`, `text_combat_tips`, `text_item_hand`, `14_keyring_midbeat`, `24_rope_exit_belly3`, `text_cabin_main`, `text_cabin_bubble`, `text_pause`, `text_map`, `text_journal`, `text_radio`, `text_will`, `text_drawer`, `text_parchment`

`--text-targets` is the same runner with this list: `13a_intro_panel1,13b_intro_panel2,13c_intro_panel3,text_combat_tips,text_item_hand`.

Output dir: `res://design/audit-shots/cursor` unless `--shots-out=<res:// dir>`.

Exit codes: `0` all requested captures ok, `1` any skip or text-audit failure, `2` bad args, unknown name, or save backup/restore error.

## Audit
Not run (no captures).

## Verify (pending, windowed)
Run these only when Nathan is not in Godot. Do not add `--headless` (the viewport is empty). One process at a time. `user://` is shared.

```powershell
$godot = 'C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
$wt = 'C:\Users\Natha\Documents\boss-rush-wt\T1-shots-cli'
& $godot --headless --path $wt --script res://tools/qa/check_shot_cli.gd
& $godot --path $wt -- --shots=30_hub_idle
& $godot --path $wt -- --text-targets
& $godot --path $wt -- --shots=nope
& $godot --path $wt -- --shots=all
```

Expect: the headless check prints `SHOT_CLI_OK` and exits 0. `30_hub_idle` and `--text-targets` exit 0 only if those captures and the text audit pass. `nope` exits 2. `all` exits 1, because `21a_win_homecoming_dump` and `21b_win_homecoming_fly` still always skip.

## Checks run + results
- `godot --headless --path <this worktree> --script res://tools/qa/check_shot_cli.gd` — exit 0, `SHOT_COUNT 64`, `SHOT_CLI_OK`.
- That script does not boot `main.gd` and does not touch `user://home_cabin.json`.
- The same process logs pre-existing parse errors in `addons/godot_mcp/game_bridge/mcp_game_bridge.gd` (autoload), and a `FitLabelBox` warning while loading the harness outside the normal class scan. The check still ran the new registry.
- Windowed shots: not run.

## Deviations
- `--text-targets` no longer writes `design/cli-runs/02-fx-tooltips`. It uses the shot runner and `design/audit-shots/cursor`.
- Backup and marker code is in `scripts/shot_cli.gd`, which is not under `scripts/dev`, so an exported build can still restore a leftover marker. The runner does not start when `OS.has_feature("template")` is true. `DevFlag.on()` is still `OS.has_feature("editor")` only.
- `--shots=all` includes the two homecoming stems that the harness still skips on purpose.

## Questions
None.

## Nathan should look at
No acceptance PNGs. This task is the runner only.
