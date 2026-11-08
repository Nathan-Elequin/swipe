---
id: REQ-20261108-collection-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T09:00:00-06:00
machine: Cherry
tip_sha: d1656f47379b07a1b670c45428ef1ec55dc76935
runtime_watermark: d1656f47*
branch_fixes: cursor/collection-a-final-clear-e524
godot: windowed isolated process (not MCP 6550), Godot 4.7.2-stable, viewport 1680x1040
final_clear: final_dungeon_cleared + milestone
local_tip_smoke: TIP_SMOKE_OK
---

# Result — final-clear recognition + receipt honesty

No all-24 claim. No owner F5. No preference mutation. Seat 6550 untouched.

## N07 / final dungeon clear (owner contract)

Production Leave from last tip biome (`b5`) now:
- sets durable `campaign_save.final_dungeon_cleared`
- emits milestone `final_clear` once
- does **not** set `won` / `endless_unlocked`
- does **not** emit `collection_complete`

UI: approved summary **Made it home…** + Spin placeholder milestone line. **COPY_GAP** `postrun.summary.final_clear`.

Shot `N07-final-dungeon-victory.png`: incomplete collection 10/66, final-clear line present, Full collection absent. Save/reload keeps flag; no replay.

## N08

| shot | claim |
|------|-------|
| `N08a-incomplete-66.png` | 65/66 no Full collection |
| `N08-bank-receipt.png` | **New item types added: 1.** + 66/66 Full collection |
| `N08-inheritance-handoff.png` | settled reload once, no replay |

Fixture bank path (not physical acquisition). Excluded Cinder: `danger_magnet` hold.

## Tutorial

Reachable finish → `tutorial_done` reload → ordinary `kind=win`. Helper second `_road_finish` non-idempotence recorded, **not** player regression.

## Remaining limits

05 live mill · RM/SC NOTRUN · Spin COPY_GAPs · physical N08 · full tutorial rails

## SHA / dirty

Runtime watermark `d1656f47*` (dirty WIP). Exact-head tip-smoke required before merge of this branch.
