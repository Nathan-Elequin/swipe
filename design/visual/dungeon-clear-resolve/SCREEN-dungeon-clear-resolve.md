# SCREEN — Dungeon-clear resolve v3 (wheel fold → proud hold → jump → Rope Exit)

Owner: Pixel (art/UI). Audio: Reel. Design locked by Nathan on 2026-11-04 (v3 proud hold).
Repo: `boss-rush` on Cherry, branch **`playtest/latest`**.
Player-facing title is **Spinheritance**. This spec adds **no** player-facing copy and changes none.

v3 locks (Nathan / Reel 2026-11-04):
1. Kill the `sprout_victory` dance loop — brief proud hold on **one** victory pose (~0.35 s), then crouch→jump.
2. Accordion fold duration **~1.10 s** (was 0.42).
3. Keep `sting.clear` soft A bed (Reel #359, peak ≈ −14 dBFS). Play at **authored level (0 dB offset)** with `skip_duck` so victory music leads and the sting stays an audible soft underlayer. Do **not** apply the old coalesce-A −10 dB duck (it would bury soft A).

---

## 0. Scope

**Fires only** on a full dungeon clear on the adventure path, i.e. the `await _play_clear_parade()` branch of
`main.gd::_enter_dungeon_clear()`. This is the branch that ends in `phase = "rest"`, then Rope Exit
(`rope_exit.open_exit`) with `between_dungeons` music.

**Out of scope, do not touch:** the tutorial clear branch, the Classic `not adventure` branch (`_classic_swipe_home()`),
per-kill `boss_wheel.collapse_slice()`, death or defeat, and `_nest_wheel()` (campaign slide).

**Kill on this path:**
1. The burrow route: `burrow_mouth_f*`, `burrow_curtain`, `burrow_mound`, walkoff hop, curtain wipe, `hero_arrive_f*`, land-dust, `clear_burst_f*`, `clear_embers_f*`.
2. The empty transparent wheel sliding down (`_nest_wheel` is not on this path — leave it alone).
3. Rope Exit's own 0.3 s alpha fade-in when it opens from the resolve. It must appear instantly under the black.
4. The `VICTORY_MARKS` dance loop (v2). Hold one proud still instead.

---

## 1. Beat table (master clock `t`, seconds)

Target total is **≈2.80 s**. Every row is driven by one master clock (§4), so `freeze_at` keeps working.

| # | Beat | t start | t end | What moves | Easing | Notes |
|---|------|--------:|------:|------------|--------|-------|
| A0 | Handoff | 0.00 | 0.00 | Overlay Sprout spawns on the **exact** hub rect, with `hub_parade_hide=true` set the same frame | — | No pop: same 96×96 rect, same top-left `(-48,-50)` from `rim_global()`, same frame (`sprout_victory_f0`) |
| A1 | Chrome out | 0.00 | 0.20 | Spin arrows, moves counter, prompt label and Take arc fade to 0 | linear | Hotbar stays. Hard-hide after fade for the whole `_clear_resolving` |
| A2 | **Wheel fold (reverse accordion)** | 0.00 | **1.10** | Wedges fan shut toward the bottom hinge. Rim and hub ring shrink with them. Final blade squash | see §2 | Slower drama (was 0.42). **SFX `sting.clear` soft A at t=0.00, authored gain, `skip_duck: true`** |
| A3 | Aura bloom | 0.95 | 1.20 | Radial gold glow pops at the hinge, then fades | OUT_BACK, then linear fade | Late fold / early proud |
| B | **Proud hold** | 1.10 | 1.45 | One `sprout_victory` still (prefer **f2** arms-up). **No loop / no VICTORY_MARKS** | hold | ~0.35 s. Facing right, never mirrored |
| C1 | Anticipation | 1.45 | 1.58 | Hold `f0`. Squash scale.y 1.0→0.86 and scale.x 1.0→1.08 at the feet pivot | OUT_QUAD | Gear overlays squash with it |
| C2 | Jump up | 1.58 | 1.72 | `f2` (arms up). y −40 px. Stretch 1.0→1.06 y | OUT_QUAD | |
| C3 | **Jump DOWN off bottom** | 1.72 | 2.15 | `f2`. y falls to `viewport.h + 16` (fully off-screen) | front-loaded pow 0.65 | Exit speed `v_exit` is recorded and reused in E1 |
| D1 | **Wipe OUT** (upward wipe and dissolve to black) | 1.85 | 2.20 | Black front rises **bottom→top** with a noise-dissolve edge | OUT_QUAD cover | Sprout layer sits **under** the wipe, so he falls into the black |
| D2 | **SWAP (0 frames)** | 2.20 | 2.20 | Screen is 100% black. Main commits rest and Rope Exit opens **instantly** with its `_hero` hidden | — | Must be the same frame. Landing handoff A |
| D3 | **Wipe IN** (inverse, from black) | 2.20 | 2.55 | The black's trailing edge keeps rising bottom→top, revealing the Rope Exit chamber bottom-first | linear | Same edge direction as D1 |
| E1 | **Fall-in from TOP** | 2.20 | 2.65 | Sprout enters at `y = -h`, falling at speed `v_exit`, lands on the Rope Exit hero spot | OUT_QUAD from v_exit | Drawn **above** the wipe. Scale 1.5→2.0 (96→128 px) |
| E2 | Land and hand off | 2.65 | 2.80 | Squash then rebound. On the last frames the overlay hides and `rope_exit._hero` shows | OUT_QUAD | Handoff A (squash hides the art pop) |
| — | Done | 2.80 | — | `run()` returns. `_play_clear_parade` restores the hub flags. `_refresh()` | — | Rope interactable from 2.80 |

`freeze_at` shot marks for Repot are listed in §7.

---

## 2. Wheel fold (reverse accordion). This is NOT `collapse`

**Distinction:** `boss_wheel.collapse` together with `collapse_slice(index)` kills **one** wedge (`slay_index`). **Do not reuse `collapse`.** Drive `fold` 0→1 over **1.10 s** (linear master clock; per-wedge ease + stagger in `_draw_fold`).

How it looks in `_draw()` when `fold > 0.001`:
- At clear time the wheel is the **empty-seat disc**. Fold whatever slices are present. If `slices.size()==0`, treat it as `CHALLENGE_SEATS` equal ghost wedges.
- Each wedge i gets a local `f_i` with stagger, eased so mid-fold keeps readable gaps (linear ease — BACK/EASE_IN expanded spans; see `_fold_ease`).
- Wedge angular span closes toward `FOLD_HINGE` (bottom). Radius 1→0.55. Rim arc only over open spans.
- Hub ring / pips / counter scale toward the hinge and hide past `fold > 0.6`. Hub Sprout is already hidden by `hub_parade_hide`.
- Last 15%: blade squash + brief gold line. At `fold == 1` draw nothing. **Dungeon BG stays visible through gaps.**
- Reset `fold = 0.0` at the D2 swap. Keep fold across `set_slices` while `hub_parade_hide` is true.

---

## 3. Transition: continuous motion, no burrow

One `CanvasLayer` (parade `_layer`, layer 40) holds:

| z | Node | Purpose |
|---|------|---------|
| 2 | `InputLock` Control, full rect, `MOUSE_FILTER_STOP` | No clicks during the resolve |
| 4 | `_hero` Sprite2D (+ gear at z 5) | Overlay Sprout for beats A0–C3 |
| 10 | `Wipe` ColorRect + `ShaderMaterial` | D1 and D3 |
| 12 | `_hero` z-raised **above** the wipe for E1–E2 | Visible while falling through black |

Wipe shader: same as v2 (`progress` 0..2, soft 0.08, nearest noise teeth). Cover 1.85→2.20, uncover 2.20→2.55. Swap callback at `progress == 1` / `t >= 2.20`.

**Swap at D2 (same frame):**
1. `on_swap` Callable fires once.
2. Main runs `_commit_dungeon_clear` (or visual-only when `freeze_at >= 0` so holds do not double-log `end dungeon N`).
3. Rope Exit opens instant (`open_instant`), hero hidden until E2 handoff A.
4. `wheel.fold = 0.0`.

---

## 4. Implementation shape (`scripts/cabin/clear_parade.gd`)

Keep `run(wheel, art, on_swap)`, `freeze_at`, `PROCESS_MODE_ALWAYS`, idle-frame `_wait()`.

4.1 **One master clock.** `_pose(t)` sets every sprite, wipe `progress`, and `wheel.fold` from `t`. For `freeze_at >= 0`, `_pose(freeze_at)` and hold (re-pose loop so Spin cannot restore).

4.2 **Frames.** `art.sprout_anim("victory")` → `sprout_victory_f0..f3` at scale 1.5 (96 px). Proud hold uses **f2** (`PROUD_FRAME := 2`). Crouch f0; jump/fall f2. Gear via `_gear_sets(..., "victory")`; hold gear frame 2 on jump/fall.

4.3 **Continuous jump.** C3 front-loaded fall off bottom; E1 fall-in from top with scale 1.5→2.0; E2 land squash → handoff A (overlay hide, rope hero show).

4.4 **Main.** `_commit_dungeon_clear` once; `_clear_resolving` re-entry guard; `hub_parade_hide` set/restore; Spin chrome hard-hidden for the whole resolve. Do **not** touch `_nest_wheel`.

4.5 **SFX.** At fold start: `sfx.play_event(&"sting.clear", {"skip_duck": true})`. Soft A bed (`sting_clear.ogg`, Reel #359). Authored cue gain only (0 dB offset). `skip_duck` prevents the cue's `duck_music` from pulling victory music down under the sting.

---

## 5. Assets

| Asset | Path | Size | Use |
|------|------|------|-----|
| Victory stills | `assets/dungeon/anim/player/sprout_victory_f0..f3.png` | 64×64 | f0 handoff/crouch; **f2 proud hold + jump/fall**; no dance loop |
| Victory gear | `assets/dungeon/hero_run/gear/{cap,helm,goggles,rope}/run_victory_f0..f3.png` | 96×96 | Gear over the hold |
| Rope Exit hero | `assets/dungeon/home/hero/hero_idle_loot_f0.png` | 128×128 | Landing handoff A |
| Wipe noise / aura | runtime | — | Unchanged |
| SFX | `sting.clear` → `assets/audio/sting_clear.ogg` (soft A) | ~0.45 s | Fold start at authored gain; skip_duck |

**Stop using on this path (leave files on disk):** burrow/curtain/mound/arrive/dust/burst/embers, walkoff, and the v2 `VICTORY_MARKS` dance.

---

## 6. Code landmines (carry forward from v2)

- **L1–L11** from v2 still apply (Rope soft-lock, re-entry, `hub_parade_hide`, input lock, Rope Exit fade, scale, `_nest_wheel` leave alone, land handoff A, `collapse` vs `fold`, HTML5 idle waits).
- **L11 Audio (v3):** Adventure path fires `sting.clear` only inside `clear_parade` at fold start, at authored gain with `skip_duck: true`. Soft A is already on tip (#359). Tutorial/Classic still fire the cue from `main.gd`. Do not re-apply the old coalesce-A −10 dB duck.
- **freeze_at / end-dungeon log:** holds must set visual-only commit so multi-shot Repot sessions do not stack `end dungeon N`.

---

## 7. Repot: F5 drain request

Entry: F5 playtest hub → Middle Progress → campaign delve 0 → clear the wheel. Viewport 1680×1040. Shots 01–07 use `clear_parade.freeze_at`. Shot 08 uses `freeze_at = -1`.

Updated v3 `freeze_at` table:

| id | room | setup | expect | filename |
|----|------|-------|--------|----------|
| 01 | fight | freeze_at **0.45** | wheel mid-fold: wedges fanned toward the bottom hinge, gaps showing **dungeon BG**. ONE overlay Sprout (f0) on the hub spot. Spin fading/hidden. No rope | 01-fold-mid.png |
| 02 | fight | freeze_at **0.95** | wheel nearly folded (thin blade or nothing), gold aura blooming, dungeon BG visible, Sprout still on hub. No burrow | 02-fold-bloom.png |
| 03 | fight | freeze_at **1.25** | Sprout **proud hold** on one still (f2 arms-up), facing right, unmirrored, 96 px, gear aligned. No dance loop, no wheel, no burst/embers | 03-proud-hold.png |
| 04 | fight | freeze_at **1.50** | crouch squash on f0, feet on the same baseline as 03 | 04-crouch.png |
| 05 | fight | freeze_at **1.95** | Sprout falling (f2) in the lower third, black dissolve rising with chunky teeth. Spin / arrows / counter hidden | 05-fall-wipe.png |
| 06 | black→rope | freeze_at **2.30** | mostly black, bottom band of Rope Exit under dissolve edge, Sprout entering from the **top**. No arrive/dust | 06-fall-in.png |
| 07 | rope | freeze_at **2.65** | land squash on Rope Exit hero spot. Rope Exit full alpha. Only ONE hero | 07-land.png |
| 08 | rope | freeze_at -1, ~0.5 s after return | rope interactive, hub flags restored, exactly one `end dungeon N`, clicks live after | 08-after.png |

Pass criteria:
- No burrow mouth, curtain, mound, hero_arrive or land dust. No wax seal. Nothing mirrored.
- No transparent empty wheel disc or `_nest_wheel` slide on this path.
- Proud hold is a **still**, not a looping dance.
- Fold is the slow ~1.1 s accordion (readable mid-fold gaps at 0.45).
- Sting is soft under victory music (not a metal slap).
- Log contains exactly one `end dungeon N` per clear (including across freeze_at holds).
- Outbox: `playtest/repot/outbox/REQ-20261104-dungeon-clear-resolve-v3/shots/`.

---

## 8. Pasteable Cursor prompt (v3)

```
Repo: boss-rush (Godot 4). Branch: playtest/latest.
Spec: design/visual/dungeon-clear-resolve/SCREEN-dungeon-clear-resolve.md (v3 proud hold).

Goal: retime dungeon-clear resolve — fold 1.10s → proud hold (~0.35s, one sprout_victory still, no VICTORY_MARKS dance) → crouch→jump→wipe→Rope Exit handoff A. Play sting.clear soft A at authored gain with skip_duck so victory music leads and the sting stays audible. Preserve continuous jump, hub_parade_hide, hard-hide Spin chrome, freeze_at no double end-dungeon log, leave _nest_wheel alone, no burrow path.

Primary file: scripts/cabin/clear_parade.gd (+ audio_fx skip_duck ctx). Update this SCREEN. Open Repot REQ-20261104-dungeon-clear-resolve-v3 with the §7 freeze_at table.
```
