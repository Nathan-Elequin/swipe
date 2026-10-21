# ANIM: Aura threads (who buffs or protects whom, on the wheel)

**Goal.** Draw always-on coloured threads from an aura source to the neighbours it affects. When slices collapse, the threads snap and re-tie, so moved buffs are visible.

**Already in code:** `boss_wheel.gd::_draw_bonds` (~L1642) draws pulsing bonds for **commander, lich, slime_boss, wraith**. Extend it; don't duplicate it.

## Hooks (real code)
- **Draw:** `boss_wheel.gd::_draw_bonds(c, radius)`, called from `_draw()` (~L1284). Endpoints: `_spoke(i)["port"]`; edge ticks: `_draw_edge_ticks(i,j,col)`.
- **Data:** slices come from `set_slices(next, face, mode)` (~L546). Monster ids are `s.card_id`; silenced is `s.silenced` (`_is_silenced` in main).
- **Snap and re-tie:**
  - `collapse_slice(index, pin)` (~L664) already animates the close-up.
  - Before the collapse, store the bond pairs. After the tween finishes, diff the new pairs: lost pairs play *snap*, new pairs play *tie*.
  - Also diff after `_sync_wheel_stats()` (main ~L4712), so Polymorph and Clockwork changes are covered.
- **Hover:** `hover_index` already brightens the bonds. Keep that.

## Thread table

| Source | Colour | Target | Glyph travelling along the thread |
|---|---|---|---|
| Commander (War Cry) | red `#d63a2a` | both neighbours | small sword tick |
| Lich (Siphon) | green `#8dcb8d` | both neighbours | wisp dot |
| Plague Doctor (Always Plague) | purple `#9a5bd1` | both neighbours | drop; padlock at the end (Always) |
| Wraith (Neighbor's Wrath) | pale `#c9b9a8` dashed | the *higher*-ATK neighbour only | ghost number |
| Slime Boss | keep current | — | — |
| Bodyguard (Protector) | steel `#a0a8b8` | arrow *from* neighbours *to* Bodyguard | shield |
| Prism (Refract Damage) | rainbow cycle | arrows *from* Prism *to* both neighbours | — |
| Cowardly King (Guards!) | steel | arrow to the Right neighbour (clockwise, as `_directed_neighbor_atk`) | — |
| Wick (Death Toll) | wax yellow `#f0d48a` | both neighbours, dotted | — |
| Leech League | dark red, only during its spin step | to the lowest-HP monster | — |

Silenced sources draw their thread grey at α0.25 and labelled by the existing `Silenced` status.

## Layout
- Threads are quadratic Béziers between portrait ports, bowed 18px toward the hub so they never cover numbers.
- Width 3px (hover 4px), with a 1px `outline` underlay.
- Glyphs (8×8 native at 3x = 24px) travel along each thread at 0.6 loops/s.

## Timing (ms)

| Event | Animation |
|---|---|
| Idle pulse | existing `0.5+0.5*sin(t*6)` |
| Snap | thread splits at its midpoint; both halves whip back to their ends in 180 (`TRANS_BACK`) with a 3-particle spark (existing `assets/dungeon/vfx/spark.png`) |
| Tie | thread draws from the source to the target in 240, then the glyph pops at the target stat (`punch_atk(j)` / `punch_hp(j)`) |
| Order after a collapse | the collapse tween → snaps (simultaneous) → ties (staggered 80) |

## Nodes
All drawing stays in `boss_wheel._draw` **[TW / _draw]**. Add `_bond_anim := {pair_key: {t, kind}}` advanced in `_process`. No shader needed.

## Assets

| File (`assets/ui/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `aura_glyph_sword.png`, `aura_glyph_wisp.png`, `aura_glyph_drop.png`, `aura_glyph_lock.png`, `aura_glyph_shield.png` | 8×8 each | 1 | [PL] (one sheet gen) |
| Threads, snap and tie | — | — | [TW] |

## QA
1. Seat Commander between Kobold Trapper and Lich. Shot: red threads to both and a green Lich thread.
2. Kill the Kobold. Shots at collapse end +100ms (snap) and +400ms (tie to the new neighbour, whose ATK punches +2).
3. Quiet Bell on Commander: grey thread.
4. Prism and Bodyguard arrows visible; hover brightens them.
