# CURSOR: wire the biome-enter splash (placeholder art)

Paste everything below the line into the Cloud Agent / Cursor prompt. Repo `Nathan-Elequin/swipe`, base **`playtest/latest`** (tip checked 2026-11-01 2:31 PM CST: `6026b9475`).

---

You are working in **Spinheritance** (Godot **4.7**, GDScript). Base branch: **`playtest/latest`**. Open a PR into `playtest/latest`. Don't force-push. Don't touch itch export.

## Goal
Add a **biome-enter story splash**. It shows every time the player enters a biome from the campaign map. Verdant Hollow (`b1`) ships first, using placeholder art. Layout, timings, and copy are **locked by Nathan**. Don't redesign anything, and don't write any player-facing words.

Read first (they're in this PR's `design/biome-enter-splash/`; create the folder and paste them in if missing):
- `SCREEN-biome-enter-splash.md`: regions, chrome, sequence, timings
- `ASSET-LIST-biome-enter-splash.md`: asset paths, naming, Nearest import

## Files you'll touch (confirm on tip)
- `scripts/main.gd`: `_on_campaign_start()` (~L2749), `_begin_campaign_delve()` (~L2777), `_layout_play_field()` (~L21572, sets `wheel_view.position`), the leave-biome paths `_push_interrupt_home()`, `_go_home_loss()`, `_open_home_cabin()`
- `scripts/audio_fx.gd`: **read only** for `music_biome_dungeon(biome_id)` (~L851) and `music_to(bed, fade_s)` (~L739). Don't change them.
- `scripts/campaign_shell.gd`: `current_biome_id()`, `biome_name()` (read only)
- `scripts/home_cabin.gd`: `counters.delves` (read only; it already goes up in `_leave_for_run` before the map start)
- `scripts/player_copy.gd`: use `PLAYER_COPY.text(key)` / `PLAYER_COPY.fill(key, vars)`
- `data/player-copy.json`: add the 5 rows below
- NEW `scripts/ui/biome_splash.gd` (+ optional `scenes/ui/biome_splash.tscn`)
- NEW `assets/ui/biome_splash/bg_verdant_placeholder.png` (1680×832) and `cue_leaf_placeholder.png` (12×12). If the PNGs aren't attached, make the BG by cropping the top 832px of `assets/ui/biome_full/bg_wheel_b1.png`, and draw the leaf as a 12×12 pixel icon (#9cc45a / #5f8f3c / stem #7A4E2B). Import both with **Filter Nearest**, mipmaps off.

## Copy: add these rows to `data/player-copy.json` EXACTLY (don't edit the text)
```json
{"cat": "Splash", "key": "splash.chrome.biome",   "where": "Biome-enter splash · top-left plate (biome name)", "text": "{name}"},
{"cat": "Splash", "key": "splash.chrome.dungeon", "where": "Biome-enter splash · top-left stat",               "text": "Dungeon {n}"},
{"cat": "Splash", "key": "splash.chrome.delves",  "where": "Biome-enter splash · top-left stat",               "text": "Delves: {n}"},
{"cat": "Splash", "key": "splash.chrome.continue", "where": "Biome-enter splash · leaf cue",                    "text": "click anytime"},
{"cat": "Splash", "key": "splash.biome.verdant_hollow", "where": "Biome-enter splash · narration · Verdant Hollow", "text": "I stepped into the Verdant Hollow and at once felt the wet through the soles of my boots. Moss covered the walls and much of the floor, and the air smelled of earth after rain. I raised my lantern and went on along the only path that offered itself, deeper under the mountain."}
```
(Also wire `crystal_cavern`, `ashen_crypt`, `cinder_forge`, `shadow_abyss` with the Spin-locked first-person paragraphs in `data/player-copy.json` / SCREEN §4 — paste exactly.)
- Fill: `{name}` = `CAMPAIGN_SHELL.biome_name(_campaign.rules, biome_id)`; dungeon `{n}` = `dungeon_index`; delves `{n}` = `home_cabin.counters.delves`.
- Click cue label: Spin-locked key `splash.chrome.continue` = `click anytime` (leaf kept). **Never** reuse `intro.next`. **Never type other player-facing words.** **Never show Tier.**
- Narration key = `splash.biome.<slug>`, where slug = biome name lowercased with spaces → `_`. If `PLAYER_COPY.has_key()` is false for that slug → **skip the splash** for that biome (the rest of the sequence still runs: dissolve, music, wheel nest).
- If `scripts/dev/text_audit.gd` has an allowlist or registry of keys, register the new keys there too.

## Splash node: `scripts/ui/biome_splash.gd`
`CanvasLayer` (layer above the play field and map) → root `Control` full rect, `mouse_filter = STOP`, design size 1680×1040 (let the project stretch handle scaling).
Children (rects in SCREEN §2):
- Art `TextureRect` 0,0,1680,832, cover, NEAREST. Texture lookup: `bg_<short>.png` → `bg_<short>_placeholder.png` → `res://assets/ui/biome_full/bg_wheel_<biome_id>.png` (top-anchored cover). `<short>` = first word of the biome name, lowercased.
- Vignette + bottom fade: `GradientTexture2D` TextureRects.
- Sprout `TextureRect` (500,432) 320×320, texture `res://assets/dungeon/anim/player/sprout_idle_f0.png` (or `art.sprout_anim("idle")[0]` if `art` is handy), NEAREST. Shadow `ColorRect` 144×16 at (624,744), #12261b α .6.
- Chrome `VBoxContainer` at (40,36), separation 8: plate Label (biome) + 2 stat Labels in `PanelContainer`s with `StyleBoxFlat` (colors in SCREEN §3).
- Narration `Panel` 0,700,1680,340 (`StyleBoxFlat`); `Label` x64 w1552, autowrap, 36px theme font, color #E9D3A1, max 5 lines.
- Cue: leaf `TextureRect` ×2 bottom-right of the bar + Label from `splash.chrome.continue` ("click anytime"). Bob 2px, Tween loop 0.8s, `TRANS_SINE`.
- Optional `CPUParticles2D` fireflies (24, 2×2 px #E8D36A).

API:
```gdscript
signal dismissed
func play_in(biome_id: String, ctx: Dictionary) -> void   # builds, sets modulate.a = 0, tweens to 1 over 0.35s (TRANS_SINE, EASE_IN_OUT)
func wait_dismissed() -> void                              # awaits the click; returns right away if already skipped
func play_out() -> void                                    # kills the in-tween if it's running, tweens modulate:a current→0 over 0.20s, then queue_free()
```
If a skip lands during `play_in`, stop the in-tween where it is and return early. The caller then hides the map and runs setup in that same frame, and `play_out` fades from whatever alpha the splash reached. No alpha jump up, no pop.
Input: in `_unhandled_input` (and `_gui_input` on the root), accept **any** mouse button press, screen touch, or key press **any time, including mid-dissolve**. Call `get_viewport().set_input_as_handled()`, latch `_skipped = true`, emit `dismissed` once. **No Timer, no minimum dwell, no auto-advance.**

## Flow wiring in `main.gd`
Today: `_on_campaign_start` → `campaign_map.hide_map()` → `_begin_campaign_delve()`, which calls `sfx.music_biome_dungeon(biome_id)` in the draft phase (~L2799–2801).

Change it to:
1. `_on_campaign_start(index, shortcut, endless)`:
   - Set a `_splash_busy` guard so a double click returns early. Set the map's input to IGNORE.
   - If `not endless` and the narration key exists: create the splash, `await splash.play_in(biome_id, ctx)`. **On the first frame of `play_in` (splash appear), call `sfx.music_biome_dungeon(biome_id)` once.** Native `music_to` fade only. No extra volume tweens.
   - If there's no splash (missing key): still call `music_biome_dungeon` at this point (unless endless), then do the soft dissolve of the map (0.35s) without a splash.
   - `campaign_map.hide_map()`, then `await _begin_campaign_delve(index, shortcut, endless, splash)`.
   - ctx for chrome: you need `biome_id`, `biome_name`, `dungeon_index` (= `1 if endless else index + 1`, same formula as in `_begin_campaign_delve`), and `delves` (`home_cabin.counters.delves`). Compute them before `play_in`.
2. `_begin_campaign_delve(...)`:
   - **Delete** the `music_biome_dungeon` block at ~L2799–2801 (it moved to splash appear). `_adventure_continue` (Push deeper) uses the same `_present_campaign_splash` helper for the next tip biome.
   - Keep all setup up to and including `_empty_wheel(CHALLENGE_SEATS)`. It runs behind the opaque splash.
   - Then, before `_campaign_arm_delve()`: `if splash: await splash.wait_dismissed(); await splash.play_out()`, then `await _nest_wheel()`.
3. `_nest_wheel()`: input locked the whole time (a full-rect `Control`, `mouse_filter = STOP`, or the existing busy flag). Tween the wheel from about one wheel-height above its rest to rest over **0.45s, `TRANS_BACK`, `EASE_OUT`**. **Don't tween `wheel_view.position` directly**, because `_layout_play_field()` resets it. Add `var _wheel_nest_offset := 0.0` that `_layout_play_field()` adds to `wheel_y`, tween that var (`tween_method` → set + relayout), and set it back to 0 at the end. Unlock input only after the tween finishes.
4. Leave biome (all paths back to cabin or map: `_push_interrupt_home`, `_go_home_loss`, `_open_home_cabin` from a run): add one helper `_biome_dissolve_out()`, a full-screen `ColorRect` #0B0706 with `modulate:a` 0→1 over 0.35s `TRANS_SINE`, swap the scene behind it, then 1→0. **No splash.** Don't change any music calls on these paths. Victory music stays on the clear path only (`music_after_dungeon_clear`).

## Music rules (hard)
- `music_biome_dungeon(biome_id)` is called **exactly once per splash appear** (map enter and Push deeper). Never on skip, fade out, nest, or arm-delve.
- No new fades. Use the native `music_to` crossfade inside `music_biome_dungeon`.
- Don't touch `audio_fx.gd` or the music config.

## Verify (headless + manual)
- Add `scripts/dev/biome_splash_selftest.gd` (follow the pattern of the existing `scripts/dev/*_selftest.gd`). It should check: the splash builds for `b1`; chrome strings equal `"Verdant Hollow"`, `"Dungeon 1"`, `"Delves: N"`; the narration equals the key text byte-for-byte; a skip during `play_in` leads to `play_out` with no alpha jump up; a missing key (`b2`) gives no splash.
- Log audio with the existing `log_audio` and confirm a single `music_to` start per enter.
- Screenshot at 1680×1040: splash (Verdant) and the wheel after nest. Put them in `playtest/repot/outbox/REQ-20261101-biome-enter-splash/shots/`.
- Run `scripts/dev/text_audit.gd` and confirm no unknown strings.

## Don't
- Invent or edit any player-facing words, or show Tier.
- Add an auto-advance timer or a minimum dwell.
- Show a splash on leaving a biome or in Endless. Push deeper into b1–b5 should splash.
- Restart the music on skip or nest.
- Use non-Nearest filtering on splash art.
