# ARC2 — Banking contract tests (evidence)

**Status:** EXECUTED (tests-only correction)  
**Package:** ARC2 only — no production edits to `home_cabin.gd` / `main.gd` / `campaign_shell.gd`  
**PR:** https://github.com/Nathan-Elequin/swipe/pull/437  
**Base tip at branch creation:** `playtest/latest` @ `1a3fc7f478440c59798a367573f9bea537845c88`  
**Audit baseline (stale for tip):** `d21da5d56753a3f6589f2e73c8232f7dd6939c95` — not assumed current  
**Engine:** Godot `4.7.2.stable.official.ed1daf0bf`  
**Model setting:** grok-4.5 effort low, fast false  

**SHAs:** Do not stamp follow-up “report only” commits into this file. Record **tested-code SHA** (commit that contains the suite) and **branch head at evidence capture** in the run artifact / chat return. They may differ if later commits are docs-only.

## Row kinds (honest counting)

| Kind | Counts as PASS? | Fails suite? |
|---|---|---|
| **ASSERT** | Yes if evaluated predicate true | Yes on FAIL |
| **STATIC** | Yes if source-shape predicate true | Yes on FAIL |
| **NOTE** | Never | No |
| **UNCOVERED** | Never | No |

NOTE/UNCOVERED are printed separately. They are not assertions.

## Commands

```bash
export GODOT="$HOME/godot/Godot_v4.7.2-stable_linux.x86_64"
BANKING_CONTRACT_LOG=/path/to/artifact.log ./tools/qa/run_banking_contract.sh
```

Runner uses `mktemp` per-run workdirs (`trap` cleanup of that dir only).

## Totals (from suite `TOTALS` line)

Last local green run before the correction commit (working tree matched these counts; re-confirm at tested-code SHA in artifacts):

| Metric | Count |
|---|---|
| ASSERT PASS | 26 |
| ASSERT FAIL | 0 |
| STATIC PASS | 3 |
| STATIC FAIL | 0 |
| NOTE | 2 |
| UNCOVERED | 3 |

Genuine evaluated rows = ASSERT + STATIC = **29**. NOTE+UNCOVERED = **5** (not PASS).

Historical `TIP_SMOKE_OK` / `CAMPAIGN_SHELL_OK` / `BIOME_CABINETS_OK` are **not** new ARC2 proof.

## Scope claims (corrected)

| ID | Kind | What it actually proves |
|---|---|---|
| META.multiset_* | ASSERT | Helper rejects `[net,sai]` vs `[net,net]`; accepts permutations |
| ATTR.* / B0–B3 / B5 / B6.smoke… / U* / L1 / P1.roundtrip|load|rebank | ASSERT | CampaignShell + catalog behavior with explicit id lists |
| B4.shell_explicit_filtered_list | ASSERT | Shell credits only ids present in the **caller-supplied** list |
| B4.live_consume_drop_carry_in | UNCOVERED | Not an in-game consume/drop/carry-in path |
| B6.mill_skip_vs_bank | NOTE | Mill-skip vs bank orthogonality is commentary; B6 credit ASSERT is the evaluated proof |
| P1.suite_avoids_live_save_io | NOTE | Suite design avoids `CampaignShell.write`; not a non-write runtime proof |
| T.src_* / N.src_* | STATIC | Current `main.gd` source shape only — not three-route execution or general proof |
| BOUNDARY.* | UNCOVERED | Named gaps |

## Coverage boundaries

1. Mocked empty / filtered lists ≠ proof tutorial/death callers never bank.  
2. No cabin UI / Trophy Room / live hotbar / exported-web save.  
3. No live `_campaign_bank_from_hand` under a real hotbar.  
4. P1 is in-memory JSON + `_copy_state` only.  
5. STATIC checks reflect immutable tip source at run time, not future-proof guarantees.  
6. ARC1 cabin lifecycle is out of scope.

## Production failures

None observed on the covered ASSERT/STATIC surface in the last green run. Do not rewrite assertions to bless defects.

## Next action

Spin reviews exact tested-code SHA + artifact TOTALS / CI tip-smoke status, then merges when satisfied. No deploy from this package.
