# REQ-20261108 progress menu — acceptance receipt

**Do not merge** until receipts below match the PR tip and CI on that tip is reviewed.

## Source body vs wrapper

| Role | SHA | Notes |
|------|-----|--------|
| **VALIDATION_HEAD / feature body** | *(filled after code commit)* | Aggregate total + settle + public main-routes harness |
| Wrapper-only later | *(if any)* | RESULT text / outbox stamp only — not gameplay |

Logs and shots below stamp `PROGRESS_SOURCE_SHA` / `SHOT_SOURCE_BODY_SHA` / `PROGRESS_MENU_MAIN_ROUTES_SHA`.

## Shot labels

| Prefix | Meaning |
|--------|---------|
| `FIXTURE-*` | Synthetic/example roster only — **not** catalog acceptance |
| `CATALOG-*` | Full catalog + `dungeon_art` Nearest icons — Pixel first-pass candidate |
| `CATALOG-BEFORE / MID / AFTER` | New-cell land settle evidence (hidden → fading → settled bright) |

### CATALOG paths

- `shots/CATALOG-BEFORE-new-hidden.png`
- `shots/CATALOG-MID-new-fading.png`
- `shots/CATALOG-AFTER-new-settled.png`
- `shots/CATALOG-01-collection-b1.png`
- `shots/CATALOG-02-next-goal.png`
- `shots/CATALOG-03-overview.png` (includes `postrun.collection.total`)
- `shots/CATALOG-04-death.png`
- `shots/CATALOG-05-tutorial.png`

## Logs (raw)

- `source-check.log` — `PROGRESS_MENU_OK` (30 postrun keys + `postrun.collection.total`)
- `ceremony.log` / selftest — `PROGRESS_MENU_CEREMONY_OK`
- `main-routes.log` — `PROGRESS_MENU_MAIN_ROUTES_OK` (public Leave/Push/loss/give_up/tutorial + `_campaign_bank_from_hand`; no force-pass on timeout)
- `shots.log` — `SHOTS_OK` with BEFORE/MID/AFTER evidence + icon count
- `banking-base-3a4be900.log` — clean `--import` then banking on `origin/playtest/latest` worktree
- `banking-head.log` — same command on feature tree after clean import

## Banking same-base (valid)

Prior “base 7pass/19fail” was **INVALID** (ReviewStage parse / missing `BucketRules.of_card` / no attribution). Re-run with import:

| Tree | assert_pass | assert_fail | Note |
|------|-------------|-------------|------|
| base `playtest/latest` @ worktree | 19 | 7 | outdated pool fixtures (`flying_saucer`→b2, `breastplate`→b1) |
| head (this feature) | 19 | 7 | **same 7 fail IDs** — no gameplay change to match suite |

Fail IDs (both): `ATTR.catalog_b1_openers`, `ATTR.breastplate_is_b2`, `B3.six_held_A_plus_F`, `U2.zero_to_six_first_return`, `U3.later_bank_no_repeated_unlock_stamp`, `L1.breastplate_credits_b2_not_location`, `L1.per_origin_counters`.

## Main routes coverage

Invoked public: `_adventure_leave`, `_push_interrupt_home`, `_go_home_loss`, `_give_up`, `_road_finish_to_cabin(false|true)`, `_campaign_bank_from_hand(true|false)`.

- Keyboard: `InputEventAction` / cell `gui_input` (not `_inspect` alone).
- Soft `HARNESS_RESET` only between cases — never counted as route proof; timeout leaves waiting state visible.
- **UNCOVERED** (explicit, not duplicate integration): `mid_menu_disk_reload_full_ui`; `full_delve_nest_settle`.

## Flags / hold

- Aggregate copy `postrun.collection.total` integrated (Overview).
- Hold merge until exact-head CI job reviewed — no prior-tip green inference.
