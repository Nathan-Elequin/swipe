# Tests (tip smoke v1)

Spinheritance has **no GUT / gdUnit4** addons yet. Headless checks are thin `SceneTree` scripts under `scripts/dev/*_selftest.gd` and `tools/qa/*.gd`, run with Godot **4.7.2** (matches `project.godot` `config/features`).

## Tip smoke (tutorial rails)

Catches Brand New / Skip / draft / choice **data + script** soft-lock classes without rendering or an Autopilot play-agent.

| Check | Why (noon bug class) |
|---|---|
| `draft:fangs` wait present | Missing wait soft-locks Fangs take |
| Goblin `choice` allow = Boot / Breastplate / Take, **no Shield** | Wrong allow soft-locks or teaches Shield |
| `B27c` rows with `branch=breastplate` | Breastplate Keep path missing |
| Every player-copy wait is a known rail kind | Unknown wait never resolves |
| `_wait_shows_next`: continue yes; choice / draft / item / done no | Next hidden/shown wrong |
| No script `hint` on TutorialGuide + no `tut.hint` assignments | False `tut.hint =` crash |

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

`.github/workflows/tip-smoke.yml` runs on PRs to `playtest/latest` and `workflow_dispatch`.

## Related existing checks

- `tools/qa/check_tutorial_beats.gd` — older beat wait inventory
- `scripts/dev/campaign_shell_selftest.gd` — campaign shell
- `tools/dev/godot-check.ps1` — import + parse only (not tip rails)
