# Batch-2 facing notes — Anvil (2026-11-06)

- **Still:** reuse live `assets/dungeon/extra/anvil.png` (56×64). `still_LIVE_reused.png` in the upload matches tip still byte-for-byte — do **not** overwrite.
- **Facing lock:** Pixel facing **B** → `anvil/facing_LOCKED.png` (48×48).
- **Idle:** only one facing plate was locked. Duplicated that plate into:
  - `assets/dungeon/anim/facing/anvil_facing.png`
  - `assets/dungeon/anim/facing/anvil_facing_idle_f0.png` … `_f3.png`
- Same pattern as prior cards when idle gens were pending (scale-four glass_asp / imp shipped distinct idle frames; anvil idle is identical frames until a real idle set lands).
