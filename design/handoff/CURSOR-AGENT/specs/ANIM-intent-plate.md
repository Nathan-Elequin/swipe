# ANIM: Intent plate (one badge per incoming hit)

**Goal.** Before the player clicks Take, show every incoming hit as its own claw badge with the **raw hit** inside (Block not subtracted; when Block soaks a hit, that badge flashes blue). Never use the word "atk". Each badge fires as *its* hit lands.

Example: Hornet Swarm shows two badges, each with **2**. Badge 1 bursts on hit 1, badge 2 on hit 2.

## Hooks (real code)

**Count and value of hits.**
- `main.gd::_hit_count(index)` (~L12824): Hornet 2, Shambling Mound = HP, Kobold Trapper 1 + `items_used_this_combat`, silenced → 1.
- `_preview_swing(m, left_blk, allow_buckler)` (~L12739) and `_incoming_total()` (~L12783): per-hit values for the badges.
- Add a pure helper `_intent_hits() -> Array[Dictionary]`, one entry per hit: `{n_raw, soaked, pierce, src_index, poison, loop}`. `n_raw` is the hit before Block. Use the per-hit `_preview_swing` chain only to know which hits Block will soak (Block is spent on hit 1, ruling `double_hit_spends_block`).

**Special shapes.**
- `_shark_attack_player` (~L12872) loops until you bleed. Show the first hit's badge, then end the row with a **loop chip**. Reuse the wheel's existing Shark loop mark: `boss_wheel.gd` ~L1948–1957 draws the glyph `↻` in a 32×16 capsule (fill `#1c120ce8`, 1.5px `#e8c36a` border, 12px gold text with a `#1c120c` outline). There is no PNG for it. Extract that drawing into a shared helper (e.g. `UxStyle.draw_multi_tag(ci, mark, tag, font)`) so the wheel and the plate use the same look. Shambling Mound's `∞` and Hornet's `×2` come from the same code, so keep them consistent.
- `_damsel_resolve` (~L9733): neighbour hits. Badges carry the neighbour's mini portrait chip, ordered Left then Right.
- `_harpy_poke` (~L10936): a poke after each item. The badge appears at use time (see item-hover-preview).
- `_apply_double_buckler` (~L12751): the halved value shows on the badge.

**Firing.**
- `_apply_resolve_hits()` (~L6272): the loop var `h` is the badge index.
- Call `intent_plate.fire(h)` right after `combat_stage.lunge()` inside `_owner_attack(m, hit_n, …)` (~L6303). `hit_n` is 1-based.
- `swing["pierce"]` selects the flame variant.
- On `incoming == 0` (blocked), play the *blocked* variant.

**Refresh.**
- Wherever `btn_done.text` is set (`PLAYER_COPY.fill("combat.take_hit", …)` ~L15647), also call `intent_plate.sync(_intent_hits())`.
- Also refresh on `_on_spin` once `phase = "fighting"`, and after `_count_item_use()` (~L11340).

**Clear.** In `_play_ended_visuals` / `_play_leave_visuals` (~L6202 / ~L6224).

## Layout (1680×1040)
- **Anchor:** above the facing monster.
  - If `combat_stage.visible`, centre over the top edge of the combat_stage rect, 12px gap.
  - Otherwise, beside `wheel_view.slice_portrait_global(facing_index)`, offset outward along the slice spoke by 150px. **After pass 6 (ANIM-wheel-monsters):** when the stage is hidden, use the hub edge facing the slice (`centre + dir*(hub_r+40)`) instead, because the outward spot holds the new nameplate. Use a capsule with a 3px gold tail pointing at the portrait (as in mockup 1, which puts the plate at x≈420–600, y≈300–396 for the Hornet slice).
- **Badge:** 64×64 on screen (16×16 native at 4x), with a 20px gap between badges.
- **Wrap and overflow:** up to 5 badges per row, then a second row. Above 8 hits (Shambling Mound), show 7 badges plus a `×N` overflow badge.
- **Capsule:** fill `#14100c` at α0.92, 3px `gold` border, radius 14, padding 16.
- **Number:** centred in the badge, in the default font. Size 30 for 1 digit, 24 for 2. `ink_on_dark` with an `outline` of 3.

## Timing (ms)

| Event | Animation |
|---|---|
| Plate in, after the wheel lands | 0–140 drop from −24px, `TRANS_BACK`; badges stagger 60ms each |
| Live change (Net, Kobold +1, item kill) | number dissolve 200 (same as `item_card._dissolve`); added badge pops 0→1.15→1 in 160; removed badge shrinks to 0 in 120 |
| `fire(h)` | lit frames 0–160 (4f @ 40ms), burst 160–320 (4f @ 40ms), then sits *spent* (grey, α0.55). The next badge pulses 1.0→1.08 at 2Hz as "next". |
| Block soaks the hit (fully or partly) | badge keeps its **raw** number, flashes blue `#6ec8e8` for 120 and shows a shield chip. A full soak has no burst; a partial soak plays a small burst. |
| Pierce (Dragon) | flame variant; the burst is drawn *over* the hub Block badge |
| Plate out | fade 160 |

## Nodes
```
IntentPlate (Control, top_level, z_index 13, mouse_filter IGNORE)  ← new scripts/intent_plate.gd
 ├─ Capsule (Panel, StyleBoxFlat)                                   [TW]
 ├─ Tail (Line2D ×2)                                                [TW]
 └─ Row (HBoxContainer)
     └─ IntentBadge ×N (Control)                                    ← scripts/intent_badge.gd
         ├─ Face (AnimatedSprite2D: idle / lit / burst / blocked / flame)  [PL]
         ├─ Num (Label)                                             [TW dissolve]
         └─ Chip (TextureRect: shield / drop / footprints / neighbour mini-portrait) [PL icons]
     └─ LoopChip (Control, _draw via the shared ↻ tag helper; Shark only)   [TW]
```
API: `sync(hits:Array)`, `fire(i:int, blocked:bool, pierce:bool)`, `ghost(hits:Array)` (used by item-hover-preview), `clear()`. No shader needed.

## Assets

| File (`assets/ui/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `intent_claw_idle.png` | 16×16 | 1 | [PL] base: dark-red rounded badge, 3 bone claw rakes, empty centre for the number |
| `intent_claw_lit_f0-3.png` | 16×16 | 4 | [PL] |
| `intent_claw_burst_f0-3.png` | 24×24 (overflows the badge) | 4 | [PL] |
| `intent_claw_flame_idle.png` | 16×16 | 1 | [PL] variant base (fire rim) |
| `intent_claw_flame_burst_f0-3.png` | 24×24 | 4 | [PL] |
| `intent_chip_shield.png`, `intent_chip_drop.png`, `intent_chip_flee.png` | 8×8 each | 1 | [PL] (one sheet gen) |
| Shark loop chip | — | — | [TW] reuses the wheel's `↻` tag drawing; no art |
| Spent / blocked / next pulse | — | — | [TW] modulate and scale only |

## QA (godot-mcp)
1. Seat Hornet Swarm, `qa_spin_idx` = its slice, Spin. Shot `01_hornet_plate.png` at 400ms: two badges, each **2**.
2. Click Take. Shots at +60ms after the first lunge (`02_hit1_lit.png`, badge 1 lit, badge 2 idle) and after the second (`03_hit2.png`).
3. Give 2 Block (Shield), repeat: badge 1 still reads **2** and flashes blue (soaked); badge 2 bursts.
4. Kobold Trapper: use 2 items. Shot shows 3 badges.
5. Dragon: flame variant shot. Shambling Mound with HP 9: overflow `×N` shot. Shark: one badge plus the `↻` loop chip, matching the wheel tag pixel for pixel (crop and compare).
6. `text_audit`: no "atk"/"ATK" string in the plate.
