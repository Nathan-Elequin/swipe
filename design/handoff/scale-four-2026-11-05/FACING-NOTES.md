# Scale-four FACING — glass_asp B2 + imp B (2026-11-05)

Nathan ship-path: facing + short idle for **glass_asp** and **imp** only. Items (venom_veins D, kiss_of_death D) untouched.

## Balance
- Floor: **100**
- Before: **828.6**
- After: **818.5**
- Billed: **~10.1** gens (8 create-image + 2 animate-with-text-v3 @ ~1.05 each)
- Cap target: ≤16 — under.

## Init / size match
| Asset | Locked still | Facing canvas | Init prep |
|-------|--------------|---------------|-----------|
| glass_asp | `locked/still_b2.png` 56×64 | 64×64 | NEAREST **pad** → `facing/init_from_b2_64.png` |
| imp | `locked/still_b.png` 64×64 | 48×48 | NEAREST **fit** → `facing/init_from_b_48.png` |

Palette: `art-kit/_reference/refs/spinheritance.hex`. Motion-language refs only: `basilisk` / `poison_frog` / `goblin` / `harpy` facing idles (not copied as creatures).

## glass_asp (T2) — 64×64

| ID | Seed | Endpoint | Notes |
|----|------|----------|-------|
| **A*** | 2101 | bitforge style=basilisk ss=12 init=B2@280 | Clean single coiled asp, segmented green — **LOCK** |
| B | 2207 | bitforge style=poison_frog ss=10 init@250 | Ouroboros / self-bite — skip |
| C | 2505 | bitforge style=basilisk_facing_idle ss=14 init@220 | Tighter coil, head higher — strong alt |
| D | 2613 | pixflux init@200 | Reintroduced companion figure (B2 artifact) — skip |

**Recommend / locked: A** → `facing/facing_locked.png` + `locked/facing_LOCKED.png`

Idle (from A via `/animate-with-text-v3`, seed 3001, frame_count=4, enhance_prompt):
- `facing/facing_idle_f0.png` … `f3.png` (API also returned f4 raw; kept first 4)
- Subtle coil breathe / head bob

## imp (T1) — 48×48

| ID | Seed | Endpoint | Notes |
|----|------|----------|-------|
| A | 2303 | bitforge style=goblin ss=12 init=B@280 | Prop/staff lean — skip |
| B | 2411 | bitforge style=harpy ss=10 init@250 | Rocky / brown-heavy — skip |
| **C*** | 2701 | bitforge style=goblin_facing_idle ss=14 init@220 | Burrow-green, big ears, toothy grin — **LOCK** |
| D | 2819 | pixflux init@200 | Similar green front; neutraler mouth — alt |

**Recommend / locked: C** → `facing/facing_locked.png` + `locked/facing_LOCKED.png`

Idle (from C via `/animate-with-text-v3`, seed 3107):
- `facing/facing_idle_f0.png` … `f3.png`
- Ear twitch / micro-bob breathe

## Contact sheets
- Master: `/workspace/pixellab-batch-2026-11-05/scale-four/CONTACT-facing.png`
- Per: `glass_asp/facing/CONTACT-glass_asp-facing.png`, `imp/facing/CONTACT-imp-facing.png`

## Notes / caveats
- Locked still B2 still contains a small companion figure; facing prompts forced **single subject**. Cand D reintroduced it — discarded.
- True orthographic “camera south” is soft across PixelLab; A/C are best portrait reads vs side stills.
- Idle f0 is **not** byte-identical to locked facing (API regenerates cycle) — normal for v3.
- No Godot wiring / catalog / PRs in this pass.

## Absolute paths (locked deliverables)
```
/workspace/pixellab-batch-2026-11-05/scale-four/glass_asp/locked/facing_LOCKED.png
/workspace/pixellab-batch-2026-11-05/scale-four/glass_asp/facing/facing_locked.png
/workspace/pixellab-batch-2026-11-05/scale-four/glass_asp/facing/facing_idle_f{0,1,2,3}.png
/workspace/pixellab-batch-2026-11-05/scale-four/glass_asp/facing/cand_{a,b,c,d}.png

/workspace/pixellab-batch-2026-11-05/scale-four/imp/locked/facing_LOCKED.png
/workspace/pixellab-batch-2026-11-05/scale-four/imp/facing/facing_locked.png
/workspace/pixellab-batch-2026-11-05/scale-four/imp/facing/facing_idle_f{0,1,2,3}.png
/workspace/pixellab-batch-2026-11-05/scale-four/imp/facing/cand_{a,b,c,d}.png

/workspace/pixellab-batch-2026-11-05/scale-four/CONTACT-facing.png
/workspace/pixellab-batch-2026-11-05/scale-four/FACING-NOTES.md
```
