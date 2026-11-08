---
id: REQ-20261108-collection-A
status: done
fulfilled_by: local-cursor
fulfilled_at: 2026-11-08T08:48:00-06:00
machine: Cherry
tip_sha: 5e75b7c9d5860314967015c1635c250699d28365
base_tip: 5e75b7c9d5860314967015c1635c250699d28365
prior_pr_head: f7f73e68165ce88a7102f9c33d89b65c22457f58
prior_base: 4a103c42fae3ce2a1abcd1036aae70ae30a49f75
godot: windowed isolated process (not MCP 6550), Godot 4.7.2-stable, viewport 1680x1040
branch_fixes: cursor/collection-a-acceptance-qa-e524
watermark: 5e75b7c9*
n08_path: bank-save-reload-native-ms
local_tip_smoke: pending
---

# Result — post-merge acceptance QA on tip `5e75b7c9`

No all-24 / end-to-end acceptance claim. No owner F5. No new mechanics/story/preferences/copy.

## SHA reconcile

| Ref | SHA |
|-----|-----|
| Merged playtest/latest | `5e75b7c9` (#488 merge of `f7f73e68`) |
| Prior PR base | `4a103c42` |
| Older shot watermark | `0a37d7e1*` (pre-N08-fix tip + dirty `*`) |
| This runtime retest | watermark **`5e75b7c9*`** on `cursor/collection-a-acceptance-qa-e524` |

Seat 6550 / PID 41644 untouched. Disposable APPDATA `collection-a-sandbox`. Local WIP (`.import` etc.) preserved — watermark `*` expected.

## 67→66 exclusion

- **Identity:** `danger_magnet` / **Danger Magnet**
- **Source:** content-board/catalog `status=hold`, `pool=4.0` (Cinder Forge)
- **Filter:** `_pool_roster` / `_pool_ids` skip `hold`/`retired` (matches banking)
- **Counts:** Cinder raw 13 → live 12; roster **66** = 15+14+14+12+11
- Log: `EXCLUDED_CINDER danger_magnet|Danger Magnet|hold|pool=4.0`

## N08 positive = bank → save → reload → native once

Last missing banked: `venom_veins`. `campaign.write()` then `load_all()`. Milestone from `milestones_from_bank` (not injected). Replay present: no `collection_complete`.

| shot | totals | Full collection |
|------|--------|-----------------|
| `N08a-incomplete-66.png` | **65/66** (Cinder 11/12) | absent |
| `N08-inheritance-handoff.png` | **66/66** | present once |

## N07 independence

b5 return with `cabinets_complete=false`, roster incomplete, `endless/won=false`. Summary = approved **"Made it home. No new item types added."** No Full collection.

**Precise blocker:** durable `won`/`endless_unlocked` only via `cabinets_complete` in `CampaignShell.bank()` — no independent final-dungeon-clear trigger. **COPY_GAP:** no approved distinct final-clear summary.

## Tutorial (01) adverse

Second direct `_road_finish_to_cabin` **reopens** tutorial (adverse, not soft non-replay). Subsequent ordinary win present is `kind=win`. Full in-dungeon tutorial still unautomated. N01 shows tutorial summary at **0/66**.

## Honesty labels

- **05** unit-only — live mill offer-decline not exercised
- **11/12** Climb/Push haul = **integration**, not physical-input journeys
- **RM/SC** NOTRUN (no preference mutation)
- Gate display remains capped **5/5**

## Remaining precise limits

1. 01 adverse second direct-call replay + unautomated full tutorial
2. 05 live mill offer-decline
3. 22 no independent final-dungeon-clear trigger + COPY_GAP
4. RM/SC NOTRUN
5. Spin placeholders (listed, not invented)

## Artifacts

`HONESTY_DRAIN_DONE` · `acceptance-qa-stdout.log` · store media `2026-11-08-acceptance-qa/`
