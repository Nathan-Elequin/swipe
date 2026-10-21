# ANIM: Spin cascade ticker (+ hold Shift to fast-forward)

**Goal.** After the wheel lands, `_on_spin` can fire about 25 triggers in a fixed order. Show them as a row of stamp tokens under the hub that light up one by one, each in sync with its ability slash. **Holding Shift fast-forwards the cascade.**

## Hooks (real code)

**Cascade order** (`main.gd::_on_spin`, ~L5861–6101, after `phase = "fighting"`):
1. `_apply_basilisk_gaze`
2. `_apply_siphon_jars` (Grief Jar)
3. `_apply_cursed_scrolls`
4. `_petrify_best_atk` / `_hydra_even_killer`
5. `_apply_death_bell_on_spin`
6. `_apply_mouse_scurry`
7. `_step_hexs`
8. `_tick_monster_poison`
9. `_sync_plague_poison` + `_apply_plague_heals_on_spin`
10. `_tick_player_poison`
11. `_step_berserkers`
12. `_step_marbles`
13. `_step_rusts`
14. `_apply_queen_eggs_on_spin`
15. `_apply_cultist_pacts_on_spin`
16. `_apply_juggernaut_on_spin`
17. `_apply_magicat_on_spin`
18. `_apply_poison_frog_on_spin`
19. `_harpy_poke`
20. `_apply_leech_on_spin`
21. `_cleric_after_spin`
22. `_fairy_after_spin`
23. Prompts: `_cube_ask_feed` / `_merchant_ask` / `_hired_ask_bribe` / `_worm_ask_hunger`

**Phase 1, lazy (cheap):**
- `ticker.begin()` after `_bleed_begin()` (~L6007).
- Each step calls `ticker.push(id, tex)` the moment it actually does something. The natural choke points are:
  - `_announce_slice(index, …)` (~L9280), which is already called by most monster triggers
  - `_flash_banner` for item triggers
  - `_tick_player_poison` / `_tick_monster_poison`
- `ticker.end()` at `_unlock_if_fighting()`.

**Phase 2 (nice):** a `_cascade_plan()` that predicts which steps will fire, so all tokens appear up front as dim and then light in order.

**Ability slash sync.** `ability_slash.play(payload)` already queues. Pass `payload["ticket"] = ticker index`, so the token lights when the slash shows and stamps when it leaves.

## Shift fast-forward
- In `main.gd::_process`: `var ff := phase in ["fighting","slaying"] and _walker_busy and Input.is_key_pressed(KEY_SHIFT) and not _text_input_focused()`.
- When `ff` changes, set `Engine.time_scale = 3.0 if ff else 1.0`, and tell `ability_slash` to use `fast` holds. Restore to 1.0 in `_unlock_if_fighting()`, on phase change, and on window focus loss (`NOTIFICATION_APPLICATION_FOCUS_OUT`).
- **Space is untouched:** do not block `ui_accept` and do not add a Spin shortcut.
- **Shift is already used:** "hold Shift to explain" (`inspect.shift`). Holding Shift during the cascade will also open explainers if the pointer is over a hover target. That is acceptable; just don't let the explainer panel steal focus.
- **HUD:** while held, show a `▶▶` chip at the right end of the ticker, plus a 2px gold speed-line shader on the ticker strip. No new words.
- **Audio:** `audio_fx` pitch is not scaled by time_scale. Optionally duck SFX by −6dB while `ff`.

## Layout (1680×1040)
- **Strip:** centred under the wheel at y ≈ 690 (between the wheel bottom ≈ 670 and the Take row ≈ 754), max width 640.
- **Tokens:** 48×48 on screen (12×12 native frame at 4x), 8px gap. Inside each: the monster's still (`art.monster_still(id)`) or the item icon, scaled into a 32×32 window.
- **Overflow:** more than 12 tokens slide left; old ones fade.

## Timing (ms, at 1x)

| State | Animation |
|---|---|
| Token appear | scale 0→1.1→1 over 140; dim α0.45 |
| Active (slash showing) | lift −6px, gold rim pulse at 4Hz, 1.0→1.12 scale in 80 |
| Done | *stamp* frames 4f @ 40ms (160), then sits at α0.7 with a tick mark |
| Strip out | when the cascade ends, hold 400 then fade 200 |
| Fast-forward (Shift held) | everything ×3 via `Engine.time_scale` (≈53ms token appear) |

## Nodes
```
CascadeTicker (Control, top_level, z 12, IGNORE)   ← scripts/cascade_ticker.gd
 ├─ Strip (NinePatchRect, existing panelInset_brown.png) [TW]
 ├─ Tokens (HBoxContainer) → Token ×N (Control: Frame AnimatedSprite2D [PL] + Icon TextureRect [reuse art])
 └─ FF (TextureRect ▶▶) [PL]
```

## Assets

| File (`assets/ui/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `ticker_token_frame.png` | 12×12 | 1 | [PL] base (stamp ring) |
| `ticker_token_stamp_f0-3.png` | 12×12 | 4 | [PL] |
| `ticker_ff.png` | 12×8 | 1 | [PL] (or draw it [TW]) |
| Icons | — | — | reuse monster stills and item icons, no new art |

## QA
1. Seat Plague Doctor, Spider Queen, Cultist and Harpy, and give the player Grief Jar and a Marble. Force-spin a Cultist neighbour. Shots at 300 / 900 / 1800ms: tokens appear, the active token is lifted, done tokens stamped.
2. Repeat holding Shift (godot-mcp key down `KEY_SHIFT`). Shot at 600ms shows the `▶▶` chip; the total cascade time is about a third.
3. Release mid-cascade: `Engine.time_scale` returns to 1.0 (log it). Alt-tab while held also restores 1.0.
4. Space behaves exactly as before this pass (no new shortcut, nothing blocked).
