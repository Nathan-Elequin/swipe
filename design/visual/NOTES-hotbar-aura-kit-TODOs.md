# Hotbar aura kit — open Gaze edges (not locked)

Ship assumptions for PR `cursor/hotbar-aura-kit-9c33`. Spin owns final copy; Nathan owns final Gaze rulings.

## Locked and shipped
- Aura roles Direction A (READY / WARN / CHOICE / LINK / Unplayable hatch / stamps / Hex mint / Toll crimson).
- Spin-locked tip + keyword strings (exact).
- Basilisk stone is source-tied (`basilisk_stone`); Gargoyle/Hydra clear on Spin; Basilisk does not.
- Freed on Defeat/Slain (vacate) and Polymorph. Catapult/Eject keeps `gaze_id` and does **not** free.
- Quiet Bell on enter: silenced Basilisk grants no Gaze (`_is_silenced` early return) — matches catalog Flow.

## TODOs / assumptions (Gaze edges a–d)

1. **What counts as Use** — Assumed: any hotbar click that `_clicked_item_counts_as_use` (not Hex/Toll/passive countdown). Oligarch-forced use counts. Echo Bell that is not itself Gazed does not count as Using the Gazed card. **Not locked.**
2. **Fewer than 3 eligible** — Assumed: Gaze however many eligible remain (0–3), prefer unmarked, skip spent and already Basilisk-stoned. **Not locked.**
3. **Quiet Bell** — Assumed: silence on enter skips Gaze grant only; if Gaze already applied, Quiet Bell later does not clear marks (no change). **Not locked.**
4. **Ejected duration** — Assumed: Catapult does not free; marks persist until that Basilisk is Defeated/Polymorphed after it returns. **Not locked.**

## Escaped vs Flee
Task list named Escaped as a free condition; catalog Flow says Flee does not free. Current code frees on vacate/Polymorph only (not on `_flee_spin`). Confirm with Nathan if Escaped ≡ Flee.
