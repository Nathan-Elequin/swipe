# SCREEN — Hub Spin button

Owner: Cursor cloud · Locked numbers from Nathan (Nov 19) · Viewport: **1680×1040**

Scope:
1. Round **Spin** initiate button centered on the wheel hub (covers Sprout / hearts at dungeon start).
2. Wheel (`boss_wheel`) global rect never changes during core combat phases after layout settles — only a window resize may change it.
3. Old placard Spin row under the wheel is gone. Take arc seat stays the fighting-state rect in every combat phase.

Never show `Tier` or `ATK` to players. No new player-facing words — reuse existing `combat.spin` ("Spin").

---

## 1. Hub Spin button

| Token | Value | Notes |
|---|---|---|
| Diameter | **104** px | Mid of 96–112 lock |
| Font | 22 pt, `#1c120c` fill, `#100e0c` outline 4 | Existing Spin string |
| Face (normal) | `#e8c36a` fill, `#3a3220` border 4, corner radius = diameter | StyleBoxFlat circle |
| Shadow (normal) | size 8, offset (0, 4), alpha 0.5 | Chunky gold/wood |
| Face (hover) | `#d4a84a`, shadow size 3, offset (0, 1) | Pressed look |
| Hover drop | **+3** px Y | Position nudge on enter |
| Face (pressed / click) | `#c49a3a`, shadow size 1 | Darker |
| z-index | 28 (absolute) | Above wheel (0), under hotbar (40) |
| Parent | `play_field` | Positioned in play-field local space |

**Hover**
- Apply hover stylebox + drop `HUB_SPIN_HOVER_DROP` (3 px).
- Play existing `wheel.spin_hover`.

**Click**
1. `click` SFX (−6 dB).
2. Squash scale → `(1.16, 0.82)` in **0.045** s.
3. Punch scale → `(1.08, 1.08)` in **0.07** s (TRANS_BACK).
4. Parallel: `land_burst` FxOneShot at wheel hub center, draw scale **2.4**, 16 fps, z 52.
5. Fade + scale out to `(0.55, 0.55)` / alpha 0 in **0.12** s (starts after squash).
6. Hide, then run existing `_on_spin()` (wheel spin / whoosh unchanged).

**Visibility**
- `phase == "ready"` and (`not adventure` **or** `_await_first_spin`).
- Adventure / Challenge after the first spin: existing auto-spin — no hub button.
- Tutorial `wait == "spin"`: same hub button; Nib focus tag `"spin"` still returns `btn_spin`.

---

## 2. Wheel rect lock

| Token | Value |
|---|---|
| Lock moment | After nest settle, or first `_layout_play_field` in a combat action-slot phase |
| Unlock | Viewport size change; leaving combat phases; nest tween; challenge draft open |
| Held phases | ready / spinning / fighting / slaying (+ draft / devtest slot height) |

`btn_wrap` still reserves `COMBAT_ACTION_SLOT_H` (64). Spin is **not** a child of that row.

---

## 3. Take arc

Unchanged from Feel pass B: Safe idle through ready/spinning; live Take when fighting. Global arc rect identical across those states when the wheel is locked.
