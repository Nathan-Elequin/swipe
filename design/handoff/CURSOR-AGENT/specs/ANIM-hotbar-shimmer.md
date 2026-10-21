# ANIM: Hotbar shimmer + ready/unusable life (Weak / Tough / Deadly)

**Goal.** Rank reads at a glance from a diagonal glint in rank colour: faster and brighter as rank rises, plus a sparkle on Deadly. Ready cards breathe; unusable cards sink.
**The word "Tier" never appears.** The only rank words are Weak / Tough / Deadly (`tier.1/2/3.name`). Jam has reworded the Swap keyword to "same rank (Weak, Tough or Deadly)" and Clockwork Knight to "Two Tough monsters if I live".

## Hooks (real code)
- **Rank colour:** `item_card._tier_shine()` (~L554): copper `#d4894e`, silver `#f4f7fb`, gold `#ffe6a8`. Rank comes from `set_palette(fill, metal, tier)` (~L547).
- **Today's pulse:** `_apply_style(hot)` (~L727) and `_draw()` (~L801) lerp the rim toward the shine. Replace this with the shader glint and keep the rim lerp for hover.
- **Playable:** `set_playable(on)` (~L633), `_sync_lock_shade()` (~L301). Drive the lift and sink here.
- **Armed passives:** `set_passive_icons(plus, ban, on)` (~L622) → add `set_armed(on, label_key)` for:
  - Double-Buckler, Healing Potion, Pacemaker, Danger Magnet
  - Sling: label **"Loaded"**, tooltip **"Loaded: your next Attack can hit any monster."**
- **Same shader elsewhere:**
  - draft gate (`draft_gate.gd::_skin_panel(tier)` ~L186, `_metal(tier)` ~L237)
  - Dungeon Deck (`dungeon_deck.gd::set_peek_tier` ~L126)
  - the gate relic flight (`mount_relic`)

## Layout
- **Cards:** 118×120 in a `GridContainer` (`hotbar_box`, `main.gd` ~L1126; 12 columns, or 5 in adventure). On screen at 1680×1040 they read as 128×172 with a label (see mockup 3).
- **Glint:** two parallel diagonal bands (26px and 8px wide, 8px apart) at 60°, masked to the card's rounded rect, additive at α0.45 / 0.28.
- **Deadly sparkle:** three 8×8 stars at random points inside the rim, one at a time.

## Timing

| Rank | Glint sweep | Rest between sweeps | Extra |
|---|---|---|---|
| Weak | 900ms | 4.0s | — |
| Tough | 700ms | 2.6s | — |
| Deadly | 500ms | 1.6s | sparkle 4f @ 80ms every 1.2s |

- Each card's phase is offset by `hash(uid) % rest`, so cards never sweep in sync.
- **Ready (usable while fighting):** lift −2px and a breathe scale of 1.0↔1.015 at 0.5Hz.
- **Unusable:** sink +2px, `modulate` 0.7, desaturate 0.6 (shader uniform); transition 160ms.
- **Armed:** a slow orbiting 2px glint around the rim (one lap per 2.4s), plus the label chip ("Loaded" for Sling).
- **Hover:** the existing rim lerp plus a forced immediate sweep.

## Nodes
```
ItemCard
 └─ material: ShaderMaterial(rank_shimmer.gdshader)   [shader]
      uniforms: shine_col, speed, rest, phase, desat, armed
 └─ Sparkle (AnimatedSprite2D, Deadly only)            [PL]
```
**Shader:** compute `t = fract((TIME + phase) / (sweep + rest))`; band position = `t * (1 + slope) * sweep_ratio`; add `shine_col * band_mask * alpha`; then `mix(col, grey, desat)`. Use one shader for all three ranks.

## Assets

| File (`assets/ui/anim/`) | Native | Frames | Type |
|---|---|---|---|
| `deadly_sparkle_f0-3.png` | 8×8 | 4 | [PL] |
| Everything else | — | — | [shader / TW] |

## QA
1. A hand with one Weak, one Tough and one Deadly item (seat via devtest). Run a 6s capture at 10fps: three different glint rates; the Deadly card shows sparkles.
2. In a fight, an unusable card (The Boot vs a healthier enemy, `warn.boot`) sits lower and greyer.
3. Sling armed: the "Loaded" chip and orbit glint; hovering shows the tooltip with Jam's exact string.
4. `text_audit`: grep every visible string and tooltip for "Tier" → **0 hits** (include the Swap keyword and the Clockwork explainer).
