# SCREEN — Dungeon-clear resolve (wheel fold → victory → jump → Rope Exit)

Owner: Pixel (art/UI). Audio: Reel. Design locked by Nathan on 2026-11-03.
Repo: `boss-rush` on Cherry, branch **`playtest/latest`** (checked at `4f9b7b13`).
Player-facing title is **Spinheritance**. This spec adds **no** player-facing copy and changes none.

---

## 0. Scope

**Fires only** on a full dungeon clear on the adventure path, i.e. the `await _play_clear_parade()` branch of
`main.gd::_enter_dungeon_clear()` (line ~2616). This is the branch that ends in `phase = "rest"`, then Rope Exit
(`rope_exit.open_exit`) with `between_dungeons` music.

**Out of scope, do not touch:** the tutorial clear branch, the Classic `not adventure` branch (`_classic_swipe_home()`),
per-kill `boss_wheel.collapse_slice()`, and death or defeat.

**Kill on this path:**
1. The burrow route in `clear_parade.gd`: `burrow_mouth_f*`, `burrow_curtain`, `burrow_mound`, the walkoff hop, the curtain wipe, `hero_arrive_f*` with the land-dust pop-up, `clear_burst_f*` and `clear_embers_f*`.
2. The empty transparent wheel sliding down. See §6.L7: the only slide-down in code is `_nest_wheel()`.
3. Rope Exit's own 0.3 s alpha fade-in when it opens from the resolve. It must appear instantly under the black.

---

## 1. Beat table (master clock `t`, seconds)

Target total is **≈2.50 s** (the old parade was 2.70 s). Every row is driven by one master clock (§4), so `freeze_at` keeps working.

| # | Beat | t start | t end | What moves | Easing | Notes |
|---|------|--------:|------:|------------|--------|-------|
| A0 | Handoff | 0.00 | 0.00 | Overlay Sprout spawns on the **exact** hub rect, with `hub_parade_hide=true` set the same frame | — | No pop: same 96×96 rect, same top-left `(-48,-50)` from `rim_global()`, same frame (`sprout_victory_f0`) |
| A1 | Chrome out | 0.00 | 0.18 | Spin arrows, moves counter, prompt label and Take arc fade to 0 | linear | Hotbar stays. The existing rest stow hides it at the swap |
| A2 | **Wheel fold (reverse accordion)** | 0.00 | **0.42** | Wedges fan shut toward the bottom hinge. Rim and hub ring shrink with them. Final blade squash | see §2 | Fast snap. **SFX `sfx.play_event(&"sting.clear")` at t=0.00** (Reel coalesce A) |
| A3 | Aura bloom | 0.34 | 0.52 | Radial gold glow pops at the hinge, then fades. 3–5 spark ticks | OUT_BACK, then linear fade | Godot only: `GradientTexture2D` radial sprite plus `draw_arc` ticks |
| B | **Victory dance** | 0.30 | 1.30 | `sprout_victory_f0→f3`. Eight marks, about 0.12 s each (two loops). Ends on f3 | step | Starts during the fold's tail, so there is no dead air. Dungeon BG is visible behind |
| C1 | Anticipation | 1.30 | 1.40 | Hold `f0`. Squash scale.y 1.0→0.86 and scale.x 1.0→1.08 at the feet pivot | OUT_QUAD | Gear overlays squash with it |
| C2 | Jump up | 1.40 | 1.54 | `f2` (arms up). y −40 px. Stretch 1.0→1.06 y | OUT_QUAD | |
| C3 | **Jump DOWN off bottom** | 1.54 | 1.92 | `f2`. y falls to `viewport.h + 16` (fully off-screen) | IN_QUAD | Exit speed `v_exit` is recorded and reused in E1 |
| D1 | **Wipe OUT** (upward wipe and dissolve to black) | 1.66 | 1.98 | Black front rises **bottom→top** with a noise-dissolve edge | IN_OUT_SINE | Sprout layer sits **under** the wipe, so he falls into the black |
| D2 | **SWAP (0 frames)** | 1.98 | 1.98 | Screen is 100% black. Main commits rest and Rope Exit opens **instantly** with its `_hero` hidden | — | Must be the same frame. No await between D1 end and D3 start |
| D3 | **Wipe IN** (inverse, from black) | 1.98 | 2.30 | The black's trailing edge keeps rising bottom→top, revealing the Rope Exit chamber bottom-first | IN_OUT_SINE | Same edge direction as D1, so it reads as one continuous descent |
| E1 | **Fall-in from TOP** | 1.98 | 2.38 | Sprout enters at `y = -h`, falling at speed `v_exit` (same velocity, one continuous jump), and lands on the Rope Exit hero spot | OUT_QUAD from v_exit (§4.3) | Drawn **above** the wipe, so he is visible over the black. Scale 1.5→2.0 (96→128 px), matching the Rope Exit hero size |
| E2 | Land and hand off | 2.38 | 2.50 | 0.06 s squash (y 0.88), then rebound to 1.0. On the last frame the overlay hides and `rope_exit._hero` shows | OUT_QUAD | Optional: reuse `amb.rope_creak` here (Rope Exit already cues it) |
| — | Done | 2.50 | — | `run()` returns. `_play_clear_parade` restores the hub flags. `_refresh()` | — | Rope interactable from 2.50 |

`freeze_at` shot marks for Repot are listed in §7.

---

## 2. Wheel fold (reverse accordion). This is NOT `collapse`

**Distinction:** `boss_wheel.collapse` together with `collapse_slice(index)` kills **one** wedge (`slay_index`), and `collapse` is read in about 10 places as "the dying slice". **Do not reuse `collapse`.** Add a new property:

```gdscript
## Dungeon-clear resolve: whole-wheel reverse accordion. 0 = open, 1 = folded away.
var fold: float = 0.0:
    set(v):
        fold = clampf(v, 0.0, 1.0)
        queue_redraw()
const FOLD_HINGE := PI * 0.5   # bottom (pointer side), screen-down in Godot
const FOLD_STAGGER := 0.045    # per-wedge delay as a fraction of fold, so pieces clack in sequence
```

How it looks in `_draw()` when `fold > 0.001`:
- At clear time the wheel is the **empty-seat disc** (dark wedges with "+" seat marks, rim, hub ring, heart pips, block counter). Fold whatever slices are present. If `slices.size()==0`, treat it as `CHALLENGE_SEATS` equal ghost wedges.
- Each wedge i gets a local `f_i = clamp((fold - i*FOLD_STAGGER) / (1 - n*FOLD_STAGGER), 0, 1)`, eased `TRANS_BACK/EASE_IN` (a tiny overshoot before it clacks shut).
- Wedge angular span: `span_i = base_span * (1 - f_i)`. Its centre angle slerps from its seat angle to `FOLD_HINGE`. The result is a fan closing like a hand fan onto the bottom hinge.
- Radius: `R_i = R * lerp(1.0, 0.55, f_i)`. The rim arc draws only over the union of the still-open spans, so it shortens as the fan closes.
- Hub ring, heart pips and block counter scale toward the hinge with `ease(fold, 2.0)` and hide at `fold > 0.6`. The hub *Sprout* is already hidden by `hub_parade_hide`. The overlay owns him.
- Last 15% (`fold > 0.85`): the closed blade squashes `scale.y 1→0` on the hinge with `draw_set_transform`, and a 2 px gold line flashes for 1 frame at `fold ≈ 0.92`.
- After `fold == 1` draw nothing (no transparent empty disc). **Keep the dungeon BG and biome ambient visible behind.** Do not dim or tint the BG. The "path opens" read comes from the wheel leaving.
- Drive it with `create_tween().tween_property(wheel_view, "fold", 1.0, 0.42)` with `TRANS_LINEAR`. The per-wedge ease and stagger shape it, so the tween stays linear. Or set it from the master clock (§4) so `freeze_at` holds.
- Reset `fold = 0.0` at the D2 swap, after the wheel is hidden by rest. `_prep_next_dungeon` / `set_slices` must also force `fold = 0`, so the next dungeon cannot spawn folded.

Godot only: `draw_colored_polygon` / `draw_arc` / `draw_set_transform` in the existing `_draw`. No SubViewport, no new shaders on the wheel.

---

## 3. Transition: continuous motion, no burrow

One `CanvasLayer` (the existing parade `_layer`, layer 40, which already sits above Rope Exit's z 80 Control because a CanvasLayer beats z_index) holds:

| z | Node | Purpose |
|---|------|---------|
| 2 | `InputLock` Control, full rect, `MOUSE_FILTER_STOP` | No clicks reach the wheel, hotbar or rope during the resolve (see §6.L4) |
| 4 | `_hero` Sprite2D (+ gear Sprite2Ds at z 5) | Overlay Sprout for beats A0–C3 |
| 10 | `Wipe` ColorRect, full rect, `ShaderMaterial` | D1 and D3 |
| 12 | `_hero` reparented / z-raised **above** the wipe for E1–E2 | Visible while falling through black |

Wipe shader (canvas_item, about 15 lines). Uniforms: `progress` (0..2), `soft` (0.08), `noise_tex` (a `NoiseTexture2D` built in code, `FastNoiseLite`, 128 px, seamless):
```glsl
shader_type canvas_item;
uniform float progress = 0.0;   // 0..1 = cover bottom→top, 1..2 = uncover bottom→top
uniform float soft = 0.08;
uniform sampler2D noise_tex : repeat_enable, filter_nearest;
void fragment() {
    float n = texture(noise_tex, UV * vec2(6.0, 4.0)).r * 0.18;   // dissolve teeth
    float h = 1.0 - UV.y + n;                                     // 0 at bottom, ~1 at top
    float lead = progress;                                        // leading (cover) edge
    float trail = progress - 1.0;                                 // trailing (uncover) edge
    float a = smoothstep(lead + soft, lead - soft, h) * smoothstep(trail - soft, trail + soft, h);
    COLOR = vec4(0.0, 0.0, 0.0, a);
}
```
- D1: `progress 0→1` over 0.32 s. D3: `progress 1→2` over 0.32 s. **One tween `0→2`** spanning 1.66→2.30 with the swap callback at `progress == 1`, so there is no seam and zero latency.
- Pixel art: keep `filter_nearest` on the noise so the dissolve edge is chunky, not blurred.

**Swap at D2 (same frame, not deferred):**
1. `parade.swap_ready` signal, or a `Callable` passed into `run()`, fires at `t >= 1.98`.
2. Main runs `_commit_dungeon_clear(instant_rope := true)` synchronously. That is today's tail after the `await`: `dungeons_cleared += 1`, `note_dungeon_clear`, `_advance_bucket_counter`, `phase = "rest"`, `facing_index = -1`, `_refresh()`.
3. `_refresh()` → `_sync_overlay()` → `rope_exit.open_exit(...)`. Add `rope_exit.open_instant = true` (or an `instant` arg) so `modulate.a = 1.0` with **no 0.3 s tween**, plus `rope_exit.set_hero_hidden(true)`.
4. Fall-in landing target: add `rope_exit.hero_land_global() -> Vector2`, which returns `_hero.get_global_transform_with_canvas().origin` (top-left, since `centered=false`) plus the 128×128 size. Do **not** hard-code `KIT.pt(188,208)`.
5. Wheel: `wheel_view.fold = 0.0` (it is hidden in rest anyway).

---

## 4. Implementation shape (clear_parade.gd rewrite)

Keep the file and class (`scripts/cabin/clear_parade.gd`), the `run(wheel, art)` entry, `freeze_at`, `PROCESS_MODE_ALWAYS`, and the HTML5-safe `_wait()` (idle frames, **not** physics timers. The comment in the file explains the old soft-lock).

4.1 **One master clock.** Write `func _pose(t: float) -> void` as a pure function that sets every sprite, the wipe `progress` and `wheel.fold` from `t`. Drive it with `tween_method(_pose, 0.0, TOTAL, TOTAL)` *or* the existing `while t < end_t` loop. For `freeze_at >= 0`, call `_pose(freeze_at)` and hold, the same as today. This removes the duplicated "exact-beat re-paint" block (lines ~124–176), which is a straight copy of the loop body.

4.2 **Frames.** Load `art.sprout_anim("victory")` → `res://assets/dungeon/anim/player/sprout_victory_f0..f3.png` (64×64). The hub already draws these into a **96×96** rect (`_draw_hub_block`), so the overlay must use `scale = Vector2(1.5, 1.5)`. `_pixel_scale()` only scales textures ≤48 px and would leave these at 1× (tiny). See §6.L6. Gear: keep `_gear_sets(art, wheel, "victory")`, which gives `hero_run/gear/{cap,helm,goggles,rope}/run_victory_f0..3.png` at 96×96. These are the same gear frames the hub draws over sprout_victory. Draw gear at scale 1 into the same rect. During C2/C3/E1 hold gear frame 2.

4.3 **Continuous jump math.** C3: `y(t) = y0 + 0.5*g*(t-1.54)^2`, with `g` chosen so y reaches `vh+16` at 1.92. Record `v_exit = g*(1.92-1.54)`. E1: start at `y = -h_draw` with velocity `v_exit*k` (k≈0.9). Solve a quadratic ease-out so velocity reaches about 0 at `land_y` at t=2.38 (a damped catch, not a bounce). Scale lerps 1.5→2.0 across E1. Keep x continuous: exit x is the hub x. Entry x lerps from `hub_x` to `land_x` over E1 with `EASE_OUT`, so the drift reads as one arc.

4.4 **Main split.** Replace the post-await tail of `_enter_dungeon_clear` with `_commit_dungeon_clear()` and make sure it runs **exactly once**:
```gdscript
var _clear_committed := false
func _commit_dungeon_clear() -> void:
    if _clear_committed: return
    _clear_committed = true
    dungeons_cleared += 1
    if home_cabin and home_cabin.has_method("note_dungeon_clear"):
        home_cabin.note_dungeon_clear()
    _advance_bucket_counter()
    phase = "rest"
    _log("end", "dungeon %s" % dungeons_cleared)
    facing_index = -1
    _refresh()
```
`_enter_dungeon_clear`: `_clear_committed = false` → `await _play_clear_parade()` (which passes `_commit_dungeon_clear` as the swap callback) → **then call `_commit_dungeon_clear()` again unconditionally** (no-op if already done). That is the soft-lock guard if the parade is freed, skipped or never reaches the swap. Keep the final `_refresh()`.

---

## 5. Assets

| Asset | Path | Size | Use |
|------|------|------|-----|
| Victory dance | `assets/dungeon/anim/player/sprout_victory_f0..f3.png` | 64×64 each (bbox f0 13..51 × 2..64, f1/f2 arms-up widest 6..59) | B dance. f0 for C1 crouch, **f2 (arms up) for jump and fall**, f3 dance end |
| Victory gear | `assets/dungeon/hero_run/gear/{cap,helm,goggles,rope}/run_victory_f0..f3.png` | 96×96 | Gear over the dance (already used by the hub) |
| Rope Exit hero | `assets/dungeon/home/hero/hero_idle_loot_f0.png` | 128×128 | Landing handoff target (rope_exit `_hero`) |
| Wipe noise | runtime `NoiseTexture2D` + `FastNoiseLite` | 128 | No file |
| Aura bloom | runtime `GradientTexture2D` (radial, gold `e8c36a` → transparent) | 64 | No file |
| SFX | `sting.clear` (Reel, coalesce A) | `assets/audio/sting_clear.ogg` | Fire at fold start (t=0). Already on tip. |

**Does the jump need new art?** **No, not to ship.** The squash/stretch tween on `f0` (crouch) and `f2` (arms-up "whee") reads well at speed.
*Nice-to-have (optional, Pixel):* `sprout_jump_f0` (deep crouch) and `sprout_jump_f1` (tucked fall, feet up), 64×64, same palette. If they are added, swap them in for C1 and C3/E1 without code changes beyond the frame lookup.

**Stop using on this path (leave the files on disk. Do not delete PNGs in this pass):**
`assets/dungeon/vfx/clear/burrow_mouth_f*`, `burrow_curtain.png`, `assets/dungeon/home/overlays/burrow_mound.png`,
`assets/dungeon/home/hero/hero_arrive_f*`, `assets/dungeon/home/overlays/land_dust_f*`, `assets/dungeon/vfx/clear/clear_burst_f*`, `clear_embers_f*`,
and `hero_run/run_walkoff_f*` and `hero_run/run_victory_f*` (the overlay switches to `sprout_victory`).
`git grep` on 2026-11-03 found these referenced only in `clear_parade.gd`, but `shot_harness.gd` uses `run_walkoff` (shot 38). Keep the files.

**Delete from `clear_parade.gd`:** constants `HOP_START, HOP_END, WIPE_END, ARRIVE_END, DUST_START, DUST_PLAY, CHEER_MARKS` (replace with the new beat constants), `_update_land_dust()`, `_walk_index()`, every `burst/embers/mouth/arrive/dust/curtain/mound` load and sprite, the `hop` var, and the duplicated freeze re-paint block.

---

## 6. Code landmines (verified on Cherry @ 4f9b7b13)

- **L1 Rope soft-lock.** The callers of `_enter_dungeon_clear()` (main.gd 5715, 8241, 8281, 9113, 11443, 14677, 18102) call it **without await**, then `_refresh()` while phase is still `ready`. The in-code comment says the rope never opens unless `_refresh()` runs again after `phase="rest"`. The commit must call `_refresh()`, and it must also run if the parade aborts (§4.4).
- **L2 Re-entry.** `_enter_dungeon_clear` has no busy guard (only `_find_loaded_bag()`), and phase stays `ready` for about 2 s. A second caller during the resolve would start a second parade and add 2 to `dungeons_cleared`. Add a `_clear_resolving` guard at the top and clear it after the commit.
- **L3 `hub_parade_hide`.** It gates the hub Sprout draw in `boss_wheel.gd:1352/3844/3853` and `_hub_set()` (main.gd 22412). `_play_clear_parade` sets it and restores it via a `tree_exiting` lambda and at the end. Keep both restore paths. Also restore `hub_sprout_on = saved`. After the swap the wheel is hidden by rest, so restoring at 2.50 is invisible, which is fine.
- **L4 No input lock today.** The parade layer holds only Sprites, so clicks pass through to the wheel and hotbar during the resolve. Add the full-rect `MOUSE_FILTER_STOP` lock (pattern: `NestInputLock` in `_nest_wheel`) and free it at the end and in `tree_exiting`.
- **L5 Rope Exit fade.** `open_exit()` sets `modulate.a = 0` and tweens it to 1 over 0.3 s when it is not already visible. That breaks the zero-latency swap. Add an instant path. `open_exit` also calls `_reset_hero_pose()` (it resets the `_hero` texture and position), so hide the hero **after** `open_exit`, then unhide at E2.
- **L6 Scale.** sprout_victory is 64 px. The hub draws it at 96 (1.5×, non-integer nearest scaling, which is the existing look). The Rope Exit hero is native 128 at 1×. `_pixel_scale()` in clear_parade only upsizes ≤48 px textures. Set the scale explicitly (1.5, lerping to 2.0 in E1).
- **L7 "Empty wheel slide-down" = `_nest_wheel()`** (main.gd 2985). It tweens `_wheel_nest_offset` from −side to 0 over 0.45 s with TRANS_BACK, and it is called on campaign delve start (3070) and on Continue/Push deeper after `splash.play_out()` (3606). It is **not** on the clear path. If Nathan's "kill" means that slide-in at the next dungeon, it is a separate change (it also runs at campaign start), so confirm before cutting. On the clear path itself, the fold (§2) replaces the dangling empty disc, and nothing should slide.
- **L8 Art-style pop at landing.** The Rope Exit `_hero` is `hero_idle_loot_f0` (128 px, loot sack, chunkier home-art style), visibly different from `sprout_victory`. **OPEN for Nathan:** (A, default) hand off on the E2 squash frame so the squash hides the swap, or (B) change the rope_exit hero texture to `sprout_idle_f0` at 2× for style continuity. B touches rope_exit's walk/climb anims (`_hero` is used at rope_exit.gd:932 and elsewhere), so it is bigger.
- **L9 `collapse` vs `fold`.** `collapse` stays at 1 after a kill until `set_slices` gets the shorter wheel (comment at boss_wheel.gd:1038). On the final kill the resolve can start while `collapse==1` and `slay_index` is set. Call `wheel.clear_slay()` (or zero `collapse` and `slay_index = -1`) before starting `fold`, or the dead wedge double-draws.
- **L10 HTML5.** Keep idle-frame waits. Don't use `get_tree().create_timer` with physics, or `await tw.finished` on a tween bound to a node that can be freed. Use the existing `_await_bound_tween` pattern from boss_wheel.
- **L11 Audio order.** Locked 2026-11-03: fire `sting.clear` once at fold start (t=0 inside clear_parade). Adventure path skips the early `_enter_dungeon_clear` sting so it does not double-fire; tutorial/Classic still fire it there. Bed is `assets/audio/sting_clear.ogg` (−6 dB, Stings bus).

---

## 7. Repot: F5 drain request (drop into `playtest/repot/inbox/REQ-YYYYMMDD-dungeon-clear-resolve.md`)

Entry: F5 playtest hub → Middle Progress → campaign delve 0 → clear the wheel. Viewport 1680×1040. Shots 01–07 use `clear_parade.freeze_at`. Shot 08 uses `freeze_at = -1`.

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | freeze_at 0.16 | wheel mid-fold: wedges fanned toward the bottom hinge, gaps showing **dungeon BG** (not black, not a transparent disc). ONE overlay Sprout on the hub spot, no hub Sprout under it. Spin arrows/counter fading. No rope | 01-fold-mid.png |
| 02 | fight | freeze_at 0.40 | wheel almost gone (thin blade or nothing at the hinge), gold aura bloom at the hinge, dungeon BG fully visible, Sprout on victory frame. No burrow mouth, mound or curtain | 02-fold-bloom.png |
| 03 | fight | freeze_at 0.80 | Sprout dancing `sprout_victory` (arms up, f1/f2), facing right, unmirrored, at 96 px, gear (if worn) aligned. No wheel, no burst, no embers | 03-victory.png |
| 04 | fight | freeze_at 1.35 | crouch squash on f0, feet still on the same baseline as 03 | 04-crouch.png |
| 05 | fight | freeze_at 1.75 | Sprout falling (f2) in the lower third, black dissolve front rising from the bottom with chunky pixel teeth. No curtain | 05-fall-wipe.png |
| 06 | black→rope | freeze_at 2.06 | screen mostly black, the bottom band of the **Rope Exit chamber** revealed under a dissolve edge, Sprout entering from the **top** above the black. No arrive pop-up, no land dust | 06-fall-in.png |
| 07 | rope | freeze_at 2.40 | Sprout landing squash on the Rope Exit hero spot. Rope Exit fully visible at full alpha (no half-faded chrome). Only ONE hero visible | 07-land.png |
| 08 | rope | freeze_at -1, ~0.5 s after return | rope exit open and interactive, hub flags restored, `dungeons_cleared` incremented exactly once (check the log line `end dungeon N`), clicks blocked during the resolve and live after | 08-after.png |

Pass criteria:
- No burrow mouth, curtain, mound, hero_arrive or land dust in any shot. No wax seal. Nothing mirrored.
- No transparent empty wheel disc or wheel slide in any shot.
- 06 vs 05: the wipe edge moves the same direction (up), and there is no all-black hold frame longer than 1 frame (Repot: run once at freeze_at −1 with frame capture or a log of `t` at swap; the swap logs `resolve swap t=1.98`).
- Log contains exactly one `end dungeon N` per clear.
- Outbox: `playtest/repot/outbox/REQ-YYYYMMDD-dungeon-clear-resolve/shots/`.

---

## 8. Pasteable Cursor prompt

```
Repo: boss-rush (Godot 4.7). Branch: playtest/latest. Player-facing title is Spinheritance; do NOT add or change any player-facing copy.
Spec: design/visual/dungeon-clear-resolve/SCREEN-dungeon-clear-resolve.md (read fully first; beat table §1 is authoritative).

Goal: replace the dungeon-clear burrow parade with: whole-wheel reverse-accordion fold (0.42s) → Sprout victory dance (sprout_victory_f0..f3) → big jump down off the bottom → upward dissolve wipe to black → zero-latency inverse wipe into the Rope Exit chamber while Sprout falls in from the top and lands (one continuous jump). Fires ONLY on the adventure full-clear branch of main.gd::_enter_dungeon_clear (the `await _play_clear_parade()` path). Tutorial and Classic (`not adventure`) branches unchanged.

Do:
1. scripts/boss_wheel.gd: add `var fold: float` (setter clamps + queue_redraw), FOLD_HINGE = PI*0.5, FOLD_STAGGER = 0.045. In _draw, when fold > 0.001: per-wedge staggered TRANS_BACK/EASE_IN fan-close toward the bottom hinge (span*(1-f_i), centre angle → hinge, radius 1→0.55), rim arc only over open spans, hub ring/pips/counter scale to hinge and hide past 0.6, last 15% squash the blade to 0 with a 1-frame 2px gold line at ~0.92, draw nothing at 1.0. Empty wheel (0 slices) folds CHALLENGE_SEATS ghost wedges. Do NOT reuse or change `collapse`/`collapse_slice`. Reset fold=0 in set_slices / next-dungeon prep. Before folding, clear any lingering slay (collapse/slay_index).
2. scripts/cabin/clear_parade.gd: rewrite run(wheel, art, on_swap: Callable = Callable()). Keep freeze_at, PROCESS_MODE_ALWAYS, idle-frame _wait(). One pure `_pose(t)` drives everything (master clock); freeze_at → _pose(freeze_at) and hold; delete the duplicated freeze re-paint block. Remove burrow_mouth/curtain/mound, hero_arrive, land_dust, clear_burst, clear_embers, run_walkoff, walkoff hop, _update_land_dust, _walk_index and the old beat consts. Overlay hero uses art.sprout_anim("victory") at scale 1.5 (96px, exactly the hub rect from rim_global()+(-48,-50)), gear via _gear_sets(art, wheel, "victory") at scale 1. Add full-rect MOUSE_FILTER_STOP input lock on the layer. Add wipe ColorRect + canvas_item shader (spec §3; nearest NoiseTexture2D teeth) with one progress tween 0→2 (1.66→2.30s). Jump: crouch f0 squash (1.30–1.40), up 40px f2 (1.40–1.54), gravity fall off bottom (1.54–1.92) recording v_exit; at t>=1.98 call on_swap exactly once (log "resolve swap t=%.2f"), then hero z above wipe, fall in from top with v_exit, OUT_QUAD catch to rope_exit.hero_land_global() by 2.38, scale 1.5→2.0, 0.06s land squash, then hide overlay and call rope_exit.set_hero_hidden(false). Total 2.50s. Fire sfx.play_event(&"sting.clear") at t=0. Aura bloom: runtime radial GradientTexture2D (e8c36a→transparent) at the hinge 0.34–0.52.
3. scripts/main.gd: extract the post-parade tail of _enter_dungeon_clear into `_commit_dungeon_clear()` guarded by `_clear_committed` (runs once). Pass it as on_swap through _play_clear_parade → parade.run. After `await _play_clear_parade()` call `_commit_dungeon_clear()` again unconditionally (no-op if done) so the rope can never soft-lock if the parade is freed/skipped. Add a `_clear_resolving` re-entry guard at the top of the adventure branch (callers don't await). Keep the hub_parade_hide set/restore paths (tree_exiting lambda + end). Fade spin arrows / moves counter / prompt / Take arc to 0 over 0.18s at resolve start and restore them on rest/next dungeon. Do NOT touch _nest_wheel in this change.
4. scripts/cabin/rope_exit.gd: add `open_instant: bool` (or instant arg) so open_exit sets modulate.a=1 with no 0.3s tween when called from the swap; add `set_hero_hidden(b)` (applied AFTER _reset_hero_pose) and `hero_land_global() -> Vector2` from _hero.get_global_transform_with_canvas(). No copy changes.
5. Do not delete any PNGs. Do not touch the tutorial or Classic clear paths, collapse_slice, or player-facing strings.

Verify: F5 → playtest hub → Middle Progress → campaign delve 0 → clear wheel. Exactly one `end dungeon N` log line; rope interactable at ~2.5s; no clicks land during the resolve; freeze_at 0.16/0.40/0.80/1.35/1.75/2.06/2.40 each holds a clean frame matching spec §7. Then drop the Repot request from spec §7.
Do not commit or push unless asked.
```
