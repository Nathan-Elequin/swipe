# Tests (tip smoke)

Spinheritance has **no GUT / gdUnit4** addons yet. Headless checks are thin `SceneTree` scripts under `scripts/dev/*_selftest.gd` and `tools/qa/*.gd`, run with Godot **4.7.2** (matches `project.godot` `config/features`).

## Tip smoke (tutorial rails)

Catches Brand New / Skip / draft / choice / Harpy→Dragon / cabin-arrive **data + script** soft-lock classes without rendering or an Autopilot play-agent.

| Check | Why (soft-lock / rail bug class) |
|---|---|
| `draft:fangs` wait present | Missing wait soft-locks Fangs take |
| Goblin `choice` allow = Boot / Breastplate / Take, **no Shield** | Wrong allow soft-locks or teaches Shield |
| `B27c` rows with `branch=breastplate` | Breastplate Keep path missing |
| Every player-copy wait is a known rail kind | Unknown wait never resolves |
| `_wait_shows_next`: continue yes; choice / draft / item / done / auto_spin / move no | Next hidden/shown wrong |
| No script `hint` on TutorialGuide + no `tut.hint` assignments | False `tut.hint =` crash |
| Skip path: `S1` `skip_only` + `B54` `rig=reveal` before `B55` | Skip/Yes lose pool-1 reveal before cabin arrive |
| Harpy→Dragon spine waits (`auto_spin` harpy_a/dragon, `item:arrow_head`, `move`, `item:shield`, `item:spiked_flail`) | Spine beats dropped from tip copy |
| Yes-path `auto_spin` preceded by `continue` or `draft:*` | Kill/loot no longer auto-lands the next foe |
| Arrow Head: tip says from start + `_start_tutorial` hotbar includes it | Mid-tutorial grant / missing starter |
| Cabin under road: `_hide_cabin_under_road` + unlock before `music_cabin` / arrive | Cabin chrome/music under road / arrive order flipped |

### Local (Linux / CI)

From repo root (Godot 4.7.2 on `PATH`, or set `GODOT`):

```bash
./tools/qa/run_tip_smoke.sh
```

Or directly:

```bash
godot --headless --path . --import
godot --headless --path . --script res://scripts/dev/tip_smoke_selftest.gd
```

Expect `TIP_SMOKE_OK` and exit `0`.

### Local (Cherry / Windows)

Same script path under Git Bash, or:

```powershell
& 'C:\Users\Natha\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe' `
  --headless --path . --script res://scripts/dev/tip_smoke_selftest.gd
```

### CI

`.github/workflows/tip-smoke.yml` runs on PRs to `playtest/latest`, **push** to `playtest/latest`, and `workflow_dispatch`.

## Related existing checks

- `tools/qa/check_tutorial_beats.gd` — older beat wait inventory
- `scripts/dev/campaign_shell_selftest.gd` — campaign shell
- `scripts/dev/banking_contract_selftest.gd` — ARC2 banking contract (held / duplicate / carry-in / threshold / persist / attribution). Run: `./tools/qa/run_banking_contract.sh`. Report: `tools/qa/ARC2_banking_contract_report.md`
- `tools/dev/godot-check.ps1` — import + parse only (not tip rails)
