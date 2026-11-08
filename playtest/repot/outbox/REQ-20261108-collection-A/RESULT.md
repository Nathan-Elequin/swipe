---
id: REQ-20261108-collection-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T08:35:00-06:00
machine: Cherry
tip_sha: 4844853d5ec0a8c18bba2d4c5c0f8cbdda1a884a
base_tip: 4a103c42fae3ce2a1abcd1036aae70ae30a49f75
godot: windowed isolated process (not MCP 6550), Godot 4.7.2-stable, viewport 1680x1040
branch_fixes: cursor/collection-a-honesty-drain-e524
n08_blocker: fixed
local_tip_smoke: TIP_SMOKE_OK
---

# Result â€” honesty drain + N08 premature-complete fix

**Hard stop honored:** tip-smoke on `0a37d7e1` alone did **not** merge. N08 showed Full collection while totals were incomplete â€” fixture/eligibility fixed and re-shot before merge.

## Root cause (N08)

1. **Fixture** â€” positive present passed `new_ids: [last]` then cancelled presentation before reveal â†’ overview undercounted (e.g. 65/67) while milestone payload still listed `collection_complete`.
2. **Roster mismatch** â€” progress-menu `_pool_roster` counted hold/retired cards; banking/milestones did not â†’ UI total inflated vs bankable roster.
3. **Production** â€” `collection_complete` already full-roster-only in `milestones_from_bank`; gate capped 5/5 kept. Added UI guard: suppress Full collection line unless overview totals are complete.

## Fixes

- `progress_menu._pool_roster` skips hold/retired (matches banking).
- Overview suppresses `collection_complete` when `_overall_unique_counts` is short.
- Case 23 harness: settled state (no unrevealed new_ids); injects complete on negative to prove suppression; rejects N08 if Full collection with incomplete totals.
- Live bankable roster on this tip = **66** (15+14+14+12+11). Prior â€œ67â€ was the inflated UI total.

## N08 evidence (visually verified)

| shot | totals | Full collection line |
|------|--------|----------------------|
| `N08a-incomplete-66.png` | **65/66** (Cinder 11/12) | **absent** |
| `N08-inheritance-handoff.png` | **66/66** (all biomes full) | **present** (Spin placeholder) |

## Honesty levels (unchanged)

- **05** unit only â€” live mill offer-decline not exercised.
- **03/06â€“08/10/17** unit-only.
- **01** PARTIAL â€” soft non-replay.
- **22** PARTIAL â€” COPY_GAP distinct final-clear summary.
- **RM/SC** NOTRUN.
- Gate lines remain capped **5/5**.

## Spin gaps (listed)

Known 7 placeholders + case 22 final-clear summary gap. No invented prose.

## Remaining precise limits

1. 01 soft tutorial non-replay / full playthrough.
2. 05 live mill offer-decline.
3. 22 COPY_GAP.
4. RM/SC NOTRUN.
5. Authoritative complete = **live bankable roster (66)**, not the old inflated 67.

## Artifacts

Harness `HONESTY_DRAIN_DONE` Â· `MILESTONE_SELFTEST_OK` Â· local `TIP_SMOKE_OK` Â· log `honesty-drain-stdout.log` Â· store media `2026-11-08-honesty-drain/`.
