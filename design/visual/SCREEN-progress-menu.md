# SCREEN — Post-run progress menu · Spinheritance · Godot 4.7

**Pass:** playable before pretty · **Viewport:** 1680×1040 · **Input:** mouse + keyboard only

## Goal

Between runs, show a **dedicated tabbed collection / results screen** — not cabin furniture and not the S7 trophy ceremony. Cabin remains optional and loved; it is no longer the automatic progress display.

## Non-goals

- Removing cabin / rooms / hall cabinets
- Mirror / door / room-map / unlock-math rewrites
- New collection mechanics, dialogue trees, Nib gating, controller support
- Ornate notebook / 3D page / generated background art
- Inventing player-facing lore (Spin owns copy; keys under `postrun.*`)

## Layout (1680×1040)

Flat Control hierarchy. Theme: existing project fonts + simple StyleBoxes. Nearest on item icons.

| Region | Approx rect | Role |
|--------|-------------|------|
| Title bar | full width, y 24–72 | `postrun.title` + Skip Recap |
| Tabs | y 80–120 | Overview / Collection / Next Goal |
| Summary strip | y 128–188 | Truthful result line for this return |
| Main grid / overview | y 200–820 | Area tabs + item cells |
| Footer actions | y 860–1000 | Next goal / destinations / Visit Cabin / Start New Run |

**Item cell:** icon + name always (missing included). Non-color-only state: badge text `postrun.collection.item_missing` / `postrun.collection.item_new` + modulate/outline contrast.

**Locked area:** visible; badge `postrun.collection.area_locked` + requirement line.

## State flow

1. Run ends (win Leave / Push-block home / death / give-up / tutorial Yes-complete).
2. Authoritative bank / abort already applied in main (unchanged ledgers).
3. Progress menu presents with payload from real `swiped` / campaign `banked` / `new_ids`.
4. Auto presentation: Overview → area just played → Next Goal, then pause.
5. Skip Recap fast-forwards presentation only; still commits ack of this return’s pending IDs.
6. Player selects: Start New Run (eligible starts only), Visit Cabin (optional), or browse tabs.
7. Cabin exit returns to title/menu shell without replaying ceremony.

## Copy (`data/player-copy.json`)

All UI strings use `PLAYER_COPY` / `postrun.*` keys (Spin-approved draft). Format via `PLAYER_COPY.fill`.

Guards (do not invent mechanics to match copy):

- Counts = newly committed distinct banked IDs this return
- `{total}` = full roster size for that area, not unlock threshold
- Tutorial summary only on completed tutorial (not Skip)
- Start buttons only where `CampaignShell.can_start`
- Route text is informational (same-run continue), never a continue-run button
- `postrun.hand_note` verified: `starter_item_mix [3,2,1]` = 6 from unlocked pools

## Assets / theme

- Reuse `tex_by_item` / catalog item icons (Nearest)
- No new metered art
- Buttons: existing FitButton / simple Button + StyleBoxFlat

## Acceptance

- Every return lands here with truthful result (incl. no-progress / death / tutorial zero)
- New uniques stagger into correct area slots; missing show icon+name
- Unlock/start-shortcut/same-run rules match `CampaignShell` today
- Optional cabin; no auto S7 hall ceremony on return
- Existing saves: historical collected shown; no replay arrivals
- Screenshots 1680×1040 under isolated userdata before ship review
