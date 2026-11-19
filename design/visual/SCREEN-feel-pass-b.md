# SCREEN — Feel pass B (layout / UI)

Owner: Cursor cloud · Locked numbers from Nathan (Nov 18) · Viewport: **1680×1040**

Scope (this PR only — lane A owns timing / FX / spin tween / stat anim):
1. Nothing moves during a spin (Take stays, constant `btn_wrap` height, constant move-arrow radius).
2. Combo tracker as a vertical left-gutter rail.
3. Compact monster inspect on the keyword-card parchment frame.
4. Stuck hover clear.

Never show `Tier` or `ATK` to players. No new player-facing words.

---

## 1. Take arc + `btn_wrap` (nothing moves)

| Token | Value | Notes |
|---|---|---|
| Viewport | 1680×1040 | Design reference |
| `COMBAT_ACTION_SLOT_H` | 64 px | Reserved under `play_field` in ready / spinning / fighting / slaying |
| Take arc z | 21 | Unchanged |
| Idle Safe modulate | `self_modulate.a = 0.55` | Dimmed, disabled, word = existing `combat.safe` ("Safe"), take count 0 |
| Live Take modulate | `Color.WHITE` | Full opacity when an enemy is up |
| Pop | Only when arc was hidden → shown | Skip if already visible through the spin |

**Phases**
- `ready` / `spinning` (no enemy): `_sync_take_arc_safe_idle` — Safe, disabled, dimmed.
- `fighting` (enemy up): `_sync_take_arc` as before.
- Outside combat phases: `_hide_take_arc`.

**Move arrows**
- Visible in `ready` / `spinning` / `fighting` (adventure or tutorial moves).
- Radius / pad unchanged when the arc is up (`PlaytestUx.move_arrow_b2_pad`).

---

## 2. Combo tracker rail (`cascade_ticker.gd`)

| Token | Value |
|---|---|
| Token size | 40×40 |
| Icon | 28×28 inside token |
| Gap | 6 px |
| Strip pad | 10 px |
| Rail gap to wheel | 10 px (rail right edge → wheel left edge) |
| Max tokens shown | 12 |
| z-index | 45 (above hotbar 40) |
| Dim alpha (spent / older) | 0.70 |
| Newest | Small scale pop 1.0 → 1.08 → 1.0 (~0.14 s), no flash / no pulse |
| Layout | Vertical `VBoxContainer`, top → bottom |
| Dock | `dock_to_wheel(wheel)` from `_layout_play_field` / `begin()` |
| Show / hide timing | Unchanged: `begin()` at cascade start, `end()` at cascade end |

**Keep-out (1680×1040)**
- Must not intersect the wheel rect.
- Must not intersect the hotbar (`hotbar_wrap` z 40, bottom strip).
- Sit in the left gutter; clamp x ≥ 8 so it stays clear of the combat log column (`ViewFrame.LOG_W` 240, `LOG_BTN_GAP` 8).

---

## 3. Compact monster inspect (`hover_panel.gd` fly tip)

Same visual frame as `keyword_tip.gd`:

| Token | Value |
|---|---|
| Width | 296 (`MONSTER_CARD_W`) |
| Parchment | `assets/ui/trophy/parchment_tag.png`, margins 24, content L20 T16 R20 B18 |
| Header icon | 56×56 portrait slot (48–64 crisp integer scale) |
| Name | 20 pt, ink `#4A2F1F` |
| Rank | Existing Minion / Elite / Boss string (13 pt) |
| Stats | Heart + attack pip badges (existing `WheelStatBadge`, no "ATK" / "Tier" labels) |
| Rule | 2 px `#C9B183` |
| Body | 17 pt ability sentence + existing call pill |
| Dropped | Centered tall column; description / flavor (`hint`) line |

**Placement (`_place_fly`)**
- Prefer beside the hovered seat (right if seat is right of wheel center, else left).
- Avoid covering the wheel hub (±48 px vertical pad from wheel top/bottom).
- Keyword capsules still attach via the existing stack.

**Legacy compare (selftest)**
- Old typical height ~280; compact must measure clearly smaller in area and height.

---

## 4. Stuck hover

| Fix | Where |
|---|---|
| Mouse motion updates `hover_index` even while `spinning` / `busy` | `boss_wheel._gui_input` — clicks still blocked |
| `_on_mouse_out` always clears hover | Tutorial poll / reconciler re-applies if still over a seat |
| Clear freed `_fly_card` | `_on_slice_hovered` + `_reconcile_hover_inspect` |
| Reconciler every process frame (non-tutorial) | `_reconcile_hover_inspect` — hide plate when cursor leaves owner |
| Item unhover | Only reopen a monster plate if the cursor is still on that slice |

---

## Files

- `scripts/main.gd` — Take Safe idle, constant slot, move arrows, dock ticker, hover reconciler, fly place
- `scripts/cascade_ticker.gd` — vertical left rail
- `scripts/hover_panel.gd` — compact parchment monster
- `scripts/boss_wheel.gd` — motion while busy
- `scripts/dev/feel_pass_b_selftest.gd`
- `design/visual/SCREEN-feel-pass-b.md` (this file)

## Out of scope (lane A)

Spin tween, timing, FX, stat number animations.
