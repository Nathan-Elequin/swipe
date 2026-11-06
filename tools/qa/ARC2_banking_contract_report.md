# ARC2 — Banking contract tests (evidence)

**Status:** EXECUTED (tests-only PR)  
**Package:** ARC2 only — no production edits to `home_cabin.gd` / `main.gd` / `campaign_shell.gd`  
**Base tip at branch creation:** `playtest/latest` @ `1a3fc7f478440c59798a367573f9bea537845c88`  
**PR:** https://github.com/Nathan-Elequin/swipe/pull/437 · head `b8e6965e944f06e897e44ebf05ab7d1da945a977`  
**Audit baseline (stale for tip):** `d21da5d56753a3f6589f2e73c8232f7dd6939c95` — not assumed current  
**Engine:** Godot `4.7.2.stable.official.ed1daf0bf`  
**Model setting:** grok-4.5 effort low, fast false  

## Commands run

```bash
export GODOT="$HOME/godot/Godot_v4.7.2-stable_linux.x86_64"
./tools/qa/run_banking_contract.sh
# contextual historical (not new ARC2 proof):
godot --headless --path . --script res://scripts/dev/campaign_shell_selftest.gd   # CAMPAIGN_SHELL_OK exit 0
godot --headless --path . --script res://scripts/dev/biome_cabinets_selftest.gd  # BIOME_CABINETS_OK exit 0
```

| Suite | Mark | Exit |
|---|---|---|
| `banking_contract_selftest.gd` | `BANKING_CONTRACT_OK` | **0** |
| `campaign_shell_selftest.gd` (historical) | `CAMPAIGN_SHELL_OK` | 0 |
| `biome_cabinets_selftest.gd` (historical) | `BIOME_CABINETS_OK` | 0 |

Historical `TIP_SMOKE_OK` / `CAMPAIGN_SHELL_OK` / `BIOME_CABINETS_OK` are **not** new proof of ARC2 acceptance cases.

## Files in this PR

| Path | Role |
|---|---|
| `scripts/dev/banking_contract_selftest.gd` | Deterministic shell + catalog + source-trace cases |
| `tools/qa/run_banking_contract.sh` | Headless runner |
| `tools/qa/ARC2_banking_contract_report.md` | This evidence report |
| `tests/README.md` | Pointer to ARC2 runner/report |

No production source edits.

## Attribution verified at tip (catalog → cabinet)

| Id | Catalog `pool` | Cabinet via `BucketRules.of_card` + `pool_for_bucket` |
|---|---|---|
| net, sai, shield, spinning_top, throwing_knife, flying_saucer | 1 | b1 |
| smoke_bomb, bracers | 1 | b1 (current; mill-skip ≠ bank skip) |
| breastplate | 2 | **b2** (item origin, not delve location) |

Quota: `cabinet_quota` = **5**. Filling every Pool 1 peg is **not** the dungeon-2 gate (`cabinets_complete` stays false after b1≥5 alone).

## Case results (expected → actual)

All rows **PASS** at tip `1a3fc7f4…` unless noted. Fixture A = `net,sai,shield,spinning_top,throwing_knife`; F = `flying_saucer`; four = A − knife.

| ID | Expected | Actual |
|---|---|---|
| ATTR.catalog_b1_openers | A+F → b1 | pools all b1 |
| ATTR.breastplate_is_b2 | breastplate → b2 | pool=b2 |
| ATTR.smoke_bomb_catalog_b1 | smoke_bomb → b1 | pool=b1 |
| ATTR.bracers_catalog_b1 | bracers → b1 | pool=b1 |
| ATTR.quota_five | quota 5 | quota=5 |
| B0.empty_hand | bank [] → +0, b1=0, dungeon2 locked | added=[] b1=0 can_start1=false |
| B1.one_held | [net] → +1, locked | added=[net] b1=1 |
| B2.two_held | [net,sai] → +2, locked | added=[net,sai] b1=2 |
| B3.six_held_A_plus_F | A+F → +6, unlock (INTENDED 0→6) | added_n=6 b1=6 unlock1=true complete_all=false |
| B3.bank_alone_no_stamp | bank alone → no map piece | pieces=0 |
| B4.carry_in_held_only | only held net credits; consumed/dropped absent | banked=net |
| B5.duplicate_same_haul_then_repeat | [net,net]→+1; repeat→+0 | first=[net] second=[] b1=1 |
| B6.smoke_and_bracers_bank_b1 | both credit b1 (current) | added=[smoke_bomb,bracers] b1=2 |
| B6.mill_skip_does_not_block_bank_api | shell has no mill filter | documented |
| U1.four_baseline_locked | four → b1=4 locked | b1=4 unlock1=false |
| U1.four_to_five_unlocks | 4→5 opens dungeon2; pool-complete false | b1=5 can_start1=true complete=false |
| U2.zero_to_five_first_return | first return A unlocks (INTENDED) | b1=5 can_start1=true |
| U2.zero_to_six_first_return | first return A+F unlocks (INTENDED) | b1=6 |
| U3.stamp_first_after_threshold | stamp after 5 → first b2 piece | id=b2 first=true pieces=1 |
| U3.later_bank_no_repeated_unlock_stamp | dup +0, new +1, stamp not first | dup=[] new=[flying_saucer] stamp2_first=false |
| P1.roundtrip_parse | isolated JSON parse | typeof=Dictionary |
| P1.load_keeps_ledger_and_count | ledger+count+piece preserved | b1=5 pieces=1 |
| P1.rebank_and_restamp_idempotent | re-bank +0; re-stamp not first | added=[] first=false |
| P1.no_user_save_write | in-memory roundtrip only | roundtrip ok; no live save I/O |
| L1.breastplate_credits_b2_not_location | breastplate → b2; b1 retained | b1=5 b2=1 attr=b2 |
| L1.per_origin_counters | b1=2, b2=1 independent | b1=2 b2=1 |
| T.src_tutorial_finish_no_bank_call | `_road_finish_to_cabin` no bank/swipe; empty open | has_empty_open=true has_bank=false |
| T.src_yes_skip_midskip_share_finish | Yes/Skip paths call finish helper | finish_hooks_present |
| N.src_death_loss_no_bank | loss → abort; abort no bank | loss_calls_abort=true abort_has_bank=false |
| BOUNDARY.mocked_empty_hand_not_caller_proof | named coverage gap | documented |
| BOUNDARY.ui_cabin_hotbar_save_uncovered | named UI/save gaps | documented |

## Coverage boundaries (not proven by this PR)

1. **Mocked empty hand ≠ caller proof.** `bank([])` emptiness does not prove tutorial/death never bank. Source traces (`T.src_*`, `N.src_*`) are STATIC shape checks only. Human matrix T1–T3 / N3 still required for save-file / live-hotbar proof.
2. **No interactive cabin / Trophy Room / hotbar driver.** Cabin clicks, bank FX, ceremony, required pre-run Trophy Room route: ARC1/3/4.
3. **No live `_campaign_bank_from_hand` integration under a real `hotbar`.** Shell receives an explicit id list; main builds that list from held cards — not executed here.
4. **No exported-web / same-origin save persistence.** P1 is in-memory JSON roundtrip only; does not mutate `user://campaign_save.json`.
5. **Push-block vs Bank-home ceremony differences** (stamp suppression) not re-proven beyond existing shell invariant bank≠stamp.
6. **Mudroom seating path** still unused by campaign arm (audit STATIC) — out of weekend trophy scope.

## Production failures found

**None** in the ARC2 machine matrix. Shell ledger/unlock/attribution at tip matches the locked player contract for the covered helper surface. Do not rewrite assertions to bless defects — none observed here.

If ARC1 finds cabin navigation bugs, those stay on the cabin PR — not this tests-only surface.

## Next action (coordinator)

1. Review this PR evidence at exact head SHA after merge-ready push.  
2. Merge to `playtest/latest` when satisfied (Spin owns merge).  
3. Keep ARC1 cabin diagnosis independent; do not treat `BANKING_CONTRACT_OK` as cabin-nav proof.  
4. Human/F5 matrix rows T/N/B4/U remain scheduled for later arcs.  
