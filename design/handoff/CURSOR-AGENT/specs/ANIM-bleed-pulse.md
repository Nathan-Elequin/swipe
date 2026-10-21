# ANIM: Bleed pulse (one red ring per HP-loss event)

**Goal.** Every time you lose HP counts as **one** event, however much you lost. Show it as a single red ring out from the hub hearts. Every listener visibly *catches* the ring before its number changes. This teaches Spiked Flail, Breastplate, Vampire, Ogre, Pacemaker, Blood Chalice, Druid and Dire Wolf at once.

## Hooks (real code)

**The five HP-loss sites in `main.gd`:**

| Site | Function | Calls `_note_hp_lost`? |
|---|---|---|
| ~L6321 | `_owner_attack` | yes |
| ~L6365 | `_apply_egg_hurt` | yes |
| ~L8217 | `_tick_player_poison` | **no** |
| ~L10760 | `_bleed(n)` | yes |
| ~L11838 | `_player_take_atk(n)` | **no** |

- Add `signal bled(n:int)` and emit it from a single helper `_emit_bleed(n)` called at all five sites.
- **REQUIRED CODE FIX (same pass):** two sites skip `_note_hp_lost`, so Pacemaker (exact-2 heal) and Blood Chalice (`last_hp_lost`) miss these losses. Add the call:
  1. `main.gd::_tick_player_poison()` (~L8213–8219). Inside `if hp < before:`, after `lost_hp_this_combat = true`, add `_note_hp_lost(before - hp)`.
  2. `main.gd::_player_take_atk(n)` (~L11830–11841). Inside `if incoming > 0:`, after `lost_hp_this_combat = true`, add `_note_hp_lost(incoming)`.
  3. Then add `_emit_bleed(n)` next to every `_note_hp_lost` call (now 5 sites), so the ring and the bookkeeping never drift. Better: call `_emit_bleed` from inside `_note_hp_lost`.
  4. Regression: run the logic QA rows for `pacemaker` and `blood_chalice` (`design/qa/logic-pass/covering/rows/blood_chalice-heal-at-3.json` and similar) and add one poison-tick row for each item.
- `_bleed_begin()` / `_bleed_end()` (~L10468) already bracket batches. Queue rings while `_bleed_hold > 0` and release them staggered at `_bleed_end`.

**Listeners and their catch:**

| Listener | Hook | Catch |
|---|---|---|
| Vampire | `_grow_vampires()` | ring reaches the slice: bat flick + "+1/+1" |
| Ogre | `_hurt_ogres(lost)` | mirrored red drop to the Ogre HP |
| Dire Wolf | `_sync_dire_wolves()` | sword number drops with the hearts |
| Spiked Flail | `atk_hp_loss` card | spike grows, number dissolve |
| Breastplate | Keep condition | the Keep glint switches on |
| Pacemaker | `_note_hp_lost` exact 2 | ECG spike + heal 1 |
| Blood Chalice | `last_hp_lost` | fill line to n |
| Druid | after `_owner_attack` | vines heal 2n |

- Each listener plays a 1-frame "hop" (TW) when the ring front passes its position, then its own existing number update.

## Layout (1680×1040)
- Ring origin: `hub_hearts_global()`.
- The ring expands to radius 900 (covers the hotbar at y≈1010 and the wheel rim). Line 6px `hurt #e07a7a` → 2px `danger` with fading alpha.
- A listener catches when `distance(origin, listener) <= ring_r`. Cards use the card centre; slices use `slice_portrait_global(i)`.

## Timing (ms)

| Event | Animation |
|---|---|
| Ring | 0→900px in 450 (`TRANS_QUAD` out), alpha 0.9→0 |
| Catch | hop −6px and a red tint, 120 total, starting at its pass time |
| Multiple events in one batch | stagger rings 150 apart; never merge them (that is the lesson) |

## Nodes
```
BleedPulse (Node2D, top_level, z 11)  ← scripts/bleed_pulse.gd; ring drawn with draw_arc in _draw  [TW]
```
Listener hops are Tweens on the existing card and slice punch helpers (`punch_hp(i)`, `punch_atk(i)`, `item_card.bounce()`). Optional drop particles reuse the `heart_drip` frames from poison-pop. **No new art required.**

## Assets
None new; reuses `heart_drip_f0-3` (poison-pop). Everything else is [TW].

## QA
1. Hornet Swarm with Spiked Flail and Vampire on the wheel, no Block. Take: two rings 150ms apart; Flail +2 twice; Vampire +1/+1 twice. Shots at ring 1 at 225ms, and at the catch.
2. Player poison tick of exactly 2 with Pacemaker held: the ring fires **and** Pacemaker heals 1. Blood Chalice then shows the poison amount. Harpy poke (`_player_take_atk`) does the same.
3. Fully blocked hit: **no** ring.
