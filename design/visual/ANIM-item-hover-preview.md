# ANIM: Item hover preview (ghosted intent changes)

**Goal.** While hovering a usable item in a fight, ghost what the intent plate *would* become if you used it. Examples:
- Net: the badge numbers drop by the chosen amount (shown as a range).
- Kobold Trapper: a ghost +1 badge.
- Harpy: a ghost poke badge (resolves right after this item).
- Amalgam: badge numbers ×2.
- Bushido: the second item shows "no effect".
- A kill: all badges dim out.
Also ghost the hearts, the way `_on_done_hover` already does (`_ghost_hp`).

## Hooks (real code)
- **Hover in:** `main.gd::_on_item_hovered(it, card)` (~L16044). **Hover out:** `_on_item_unhovered()` (~L16062).
- **Simulation:** add a pure `_preview_after_use(it) -> {hits:Array, enemy_hp:int, kill:bool, notes:Array}`.
  - Snapshot the state the way the undo system does (`_capture_run()`), apply the item's ops through the same resolver with fx and sfx disabled (there is already a `logic_qa.busy` no-fx path in `_play_ended_visuals`), read `_intent_hits()` (from ANIM-intent-plate), then restore.
  - **Decision (Nathan): build phase 1 as the rule table below.** The full sim is a later option only.

    | Case | Preview |
    |---|---|
    | `items_used_this_combat + 1` | Kobold Trapper extra hit |
    | Harpy | +1 poke badge |
    | Amalgam | `hp*2`, `atk*2` |
    | Net | −1…−3 shown as a range |
    | Bushido, if this would be the 2nd use | "no effect" |
    | ATK ≥ enemy HP | kill: dim all |

- **Output:** `intent_plate.ghost(hits)`, plus `wheel_view.set_preview({...})` (`boss_wheel.gd` ~L583 already exists for slice stat previews), plus a ghost on the Take button number.

## Layout
- Ghost badges sit at their final slots on the plate at α0.5 with a dashed 2px outline.
- Added badges are tinted `hurt` with a small "+" chip; removed badges get a strike.
- Changed numbers show `old → new` inside the badge for 2-digit fits; otherwise only the new number, in gold.
- Bushido "no effect": the card itself shows the strike-slash overlay (existing petrify-like dummy) at α0.6.

## Timing (ms)

| Event | Animation |
|---|---|
| Hover in | 80ms debounce, then ghosts fade in 120 |
| Hover out | 100 fade |
| Moving between cards | cross-fade 120 (no flicker) |
| Kill preview | badges desaturate and slide down 4px |

## Nodes
Reuse `IntentPlate.ghost()` (`IntentBadge` gets `ghost_mode`) **[TW]**. No new nodes.

## Assets
Reuses `intent_chip_*`. Adds:

| File (`assets/ui/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `intent_chip_plus.png` | 8×8 | 1 | [PL] (same sheet gen as the other chips) |
| Strike line | — | — | [TW] |

## QA
1. Kobold Trapper, with 1 item already used: hover another. Shot: 2 solid badges and 1 ghost "+".
2. Net on Hornet (2,2): the badges ghost to "2→0…1".
3. Amalgam: hover any item; ghost numbers ×2 and slice preview stats.
4. Bushido: hover the 2nd item; the "no effect" overlay shows.
5. Hover an item that kills: all badges dim; ghost hearts unchanged.
6. Rapid hover across 4 cards: no stale ghosts after hover out.
