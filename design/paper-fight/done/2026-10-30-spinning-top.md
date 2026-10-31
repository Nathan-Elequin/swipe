# Paper Fight — Spinning Top (done)

**Answers (2026-10-30):**
1. Counter: only Spins while this copy is in the hotbar.
2. At 7: leaves after Oligarch, before the player can click items this fight.
3. Starts at Attack 1 (base), then +1 per Spin while held.

See `CURRENT.md` as of the fight for the full write-up. Built as: Attack = 1 + spins_held, cap 7, Discard after `_apply_oligarch_on_spin`, Flee/Smoke/auto-spin/landing all count because the tick sits with Marble on every Spin resolve. Pool 1 T1 Attack; Crossbow 1→2, Grimoire 2→3.
