# Monster4 facing notes — 2026-11-06

- **Stills (Pixel lock):** huntsman A · quicksand_crab B · phantom B · collector C → `assets/dungeon/extra/{id}.png` (64×64)
- **Facing (all A):** huntsman 48×48; crab/phantom/collector 64×64 → `assets/dungeon/anim/facing/{id}_facing.png`
- **Idle:**
  - huntsman + quicksand_crab: real f0–f3 from facing A
  - phantom + collector: idle gens deferred — facing plate **duplicated** to f0–f3 (Anvil pattern)
- Nearest filter (project default `default_texture_filter=0`); lossless; no mipmaps
