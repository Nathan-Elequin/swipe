# Clear-commit → eligibility → Leave wiring

Source tip base: `1a13e353` (merge #491). Harness invokes production `Main._commit_dungeon_clear` only — never assigns `final_clear_eligible` directly.

## `scripts/main.gd` — `_commit_dungeon_clear`

```
if not visual_only:
    dungeons_cleared += 1
    ...
    if _campaign_on and _campaign != null:
        CAMPAIGN_SHELL.note_tip_dungeon_cleared(_campaign.rules, _campaign.state)
        _campaign.write()
phase = "rest"
```

## `scripts/campaign_shell.gd` — `note_tip_dungeon_cleared`

Sets `run.final_clear_eligible = true` only when active run is on `last_tip_biome_id` (non-endless).

## `scripts/campaign_shell.gd` — `recognize_final_dungeon_clear`

Requires `run.final_clear_eligible` + played_pool == last tip; then sets durable `final_dungeon_cleared` and returns `{kind: final_clear}` once.

## `scripts/main.gd` — Leave bank

`_campaign_bank_from_hand_with_milestones(stamp_crosses=true)` calls `recognize_final_dungeon_clear` before `end_run` (which clears the run / eligible flag).

## Harness assertion trail

1. `CLEAR_COMMIT_TRACE before_elig=false after_elig=true …`
2. `N07_POS_TRACE clear→elig=true flag_before_leave=false`
3. Leave emits `final_clear` once
4. Save/reload + clear-commit + Leave → `N07_ONCE … leave_final=false`
