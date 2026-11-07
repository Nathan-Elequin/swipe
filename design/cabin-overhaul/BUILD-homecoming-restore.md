# BUILD: Cabinet homecoming restore (S7)

## Goal

After a successful **campaign** Leave with newly banked item types, automatically stage the trophy hall, hand off with Nib, play the **existing** S7 bank FX into real pegs, show cumulative progress, then gated Spin lessons / unlock beat.

## Non-goals

- Room flip / door matrix / Outpost consolidation / ROOM_ORDER / map launch / unlock math
- Re-enabling removed collection card glow or relabeling CLAIMED peg twinkle
- Inventing glint lesson copy (Spin revising for New! badge)
- Tutorial reward credit

## Authoritative ledgers

| Ledger | Role |
|--------|------|
| `swiped` / campaign `banked` | Credit (unique brought home) |
| `bank_pending` | Presentation queue only (serialize, default `[]`) |
| `_bank_hold` | Session view of pending mounts |

Rules: never double-bank on resume; never seed pending from all historic banked; ack on completed mount step; cancel releases `_bank_busy` but keeps remaining pending.

## Flow

1. `swipe_ids` credits uniques → append `bank_pending` → save
2. Walk-in arrive settles (key ring first if due)
3. `_stage_homecoming_bank` → pan hall → focus primary pool → `nib.home.give_home`
4. Existing `_play_bank_sequence` FX (smoke → rays → arc → loud count)
5. Optional under-quota `nib.lesson.five_finds` if not already taught at extract and gate not met
6. On b1 cross: `nib.lesson.five_threshold` then existing case-open + map-piece unlock beat

## Lesson map (Spin-owned)

| Hook | Key | Gate |
|------|-----|------|
| Campaign ready + New! badge | `nib.lesson.new_mark` | once; not tutorial; not fighting |
| First b1 extract + NEW UNIQUE | `nib.lesson.extract_haul` | once; Verdant text; marks five_finds taught |
| Before S7 flight | `nib.home.give_home` | extract path only (not push-block) |
| After celebration under quota | `nib.lesson.five_finds` | once; **only if this haul includes b1**; skip if extract already taught or b1 gate met |
| After celebration, b1 cross | `nib.lesson.five_threshold` | once; crossed b1 only |
| Tutorial clear arrive | `nib.lesson.tutorial_return` | once; zero bank |

Non-b1 new returns must not teach Verdant five-finds merely because the b1 cabinet is still under quota / lesson flags unset.

## Ceremony cancellation ownership

`_bank_ceremony_gen` is begun on start, invalidated on `_abort_cabin_interaction` / `_clear_bank_anim`, and retired on owner `_release_bank_ceremony`.

Every await in `_play_bank_sequence` (give-home, FX, per-item flip/arc, waits, loud count, lessons, map-piece) re-checks `_owns_bank_ceremony(gen)` before ack or lock release. Stale coroutines must not:

- `_ack_bank_presented` (pending preserved)
- clear a newer ceremony's `_bank_busy`
- mutate shelves / crossed unlock side effects after invalidation

Earned `swiped` / campaign `banked` credit is never rolled back by cancel.

## Push-block

Intentional suppression retained: no S7 FX, no map piece, no give-home line. Items still mount after push dialog. Documented uncovered path: players on push-block miss the theatrical flight (by design).

## In-run New! vs peg twinkle

- Target cue: hotbar `New!` / extract `NEW UNIQUE` (`not is_swiped`)
- Not taught: trophy `_arm_twinkle` on CLAIMED pegs

## Verification distinction

| Layer | Command | Proves |
|-------|---------|--------|
| Source QA | `python3 tools/qa/check_cabinet_homecoming.py` | String/keys/wiring shape only |
| Engine protocol | `./tools/qa/run_homecoming_ceremony.sh` | Gen ownership + haul gate on bare instance |
| Local play | REQ H1–H12 | Real cancel/reentry, audio, non-b1 return |
