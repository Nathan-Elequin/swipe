# Cherry F5 smoke — hub Sprout, no left face-off

Godot is often unavailable in cloud agents. Run this on Cherry after `load-pr` / checkout of this branch.

## Steps

1. F5 → Brand New (or Middle Progress) → start a fight with a full wheel.
2. Confirm Sprout idle is in the **center of the wheel hub**, not a big actor on the left floor.
3. Confirm the facing monster **portrait + callout** sit on the **right** of the wheel.
4. Use an Attack item (e.g. Spiked Flail). Hub Sprout should play the swipe / grab frames in the hub; the left stage Control stays hidden.
5. Use a non-Attack item (Block / Utility). Same: hub anim only; no multi-second hitch from overlapping left-stage + hub + hall redraws.
6. Spin again. Sprout should **not** run off left and run back on; hub stays populated through the spin.

## Source checks (no Godot)

```bash
python3 tools/qa/check_hub_sprout_no_faceoff.py
python3 tools/qa/check_combat_fx_budget.py
```

Expect `HUB_SPROUT_NO_FACEOFF_OK` and `COMBAT_FX_BUDGET_HOOKS_OK`.
