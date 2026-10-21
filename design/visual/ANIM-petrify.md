# ANIM: Petrify (stone creep, countdown, shatter)

**Sources:**
- Gargoyle (Petrify): highest-ATK item until the next Spin.
- Hydra (Even Killer): every even ATK/BLK item until the next Spin, +2 ATK each.
- Basilisk (Petrifying Gaze): every other item for **3 Spins**, then it flees.

The tooltip copy already exists: "Unplayable until your next Spin."

## Hooks (real code)
- **Apply:**
  - `main.gd::_petrify_best_atk()` (~L11031)
  - `_hydra_even_killer()` (~L11095)
  - `_apply_basilisk_gaze()` (~L10977)
  - All end in `item_card.set_petrified(on, dummy)` (~L402), which today just shows `assets/dungeon/ui/petrify_stone.png` and greys the card.
  - Change to `set_petrified(on, dummy, spins_left := 0, animate := true)`.
- **Countdown:** `_tick_gaze_petrify()` (~L10969), run in `_on_spin` → `card.petrify_tick(spins_left)`.
- **Clear:** `_clear_petrify()` (~L10960) → `card.petrify_shatter()`.
- **Gaze beam:**
  - From `combat_stage` (or the slice portrait) to each target card, played before each `set_petrified` call.
  - Hydra: one beam per head, and `punch_atk(facing_index)` +2 per card.
  - Basilisk: the beam sweeps left→right across the hotbar.
- **Bushido:** the existing "dummy" overlay (`dummy = true`) stays separate. Do not shatter it.

## Layout
- **Card:** 118×120.
- **Stone overlay:** shader on the card (`ItemCard` CanvasItem material): a `creep` uniform 0→1 fills top-down with a 2px crack edge.
- **Countdown ring (Basilisk):** 3 pips on the card top-right corner, 12px each, drawn in `item_card._draw`.
- **Shatter:** 30×30 native at 4x (120px), over the card.
- **Beam:** Line2D, 6px, `#c9b9a8` → white core, with 3 dust particles at the hit.

## Timing (ms)

| Event | Animation |
|---|---|
| Beam | 0→hit in 160 |
| Creep | `creep` 0→1 in 360 (`TRANS_SINE`); card `modulate` → (0.58, 0.56, 0.52) as today |
| Hydra stagger | 120 per card |
| Basilisk countdown | pip cracks off on each Spin (100 flash + 3 shard particles) |
| Shatter | 5f @ 50 (250); stone pieces fall 40px with fade; card modulate → white in 150 |

## Nodes
```
ItemCard
 ├─ material: ShaderMaterial(petrify.gdshader)   [shader: needed for the top-down creep]
 ├─ _stone (existing TextureRect)                (kept as the final static look)
 └─ ShatterFx (AnimatedSprite2D, 4x)             [PL]
PetrifyBeam (Line2D, top_level)                  [TW]
```
**Shader `petrify.gdshader`:** mix to a greyscale stone texture where `UV.y < creep`, plus a crack line at `|UV.y − creep| < 0.02`. Uniforms: `creep`, `stone_tex` (= `petrify_stone.png`).

## Assets

| File (`assets/ui/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `petrify_shatter_f0-4.png` | 30×30 | 5 | [PL] (2 gens) |
| `petrify_pip.png` | 3×3 | 1 | [TW] (draw it, no gen) |
| Stone texture | — | — | reuse `assets/dungeon/ui/petrify_stone.png` |

## QA
1. Gargoyle: shots at 200 / 500ms (beam, creep half, full stone). Next Spin: shatter shot at 125ms.
2. Hydra with 3 even items: 3 staggered beams; the Hydra ATK punches +6.
3. Basilisk: every other card is stone with 3 pips; each Spin removes one pip; shatter on the 3rd.
4. Bushido dummy overlay is unaffected.
