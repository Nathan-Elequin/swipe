# SCREEN: Biome-enter splash

Status: **LOCKED by Nathan (2026-11-01)**. Wire it with placeholder art first. Painted art comes later through ChatGPT/Doop.
Owner: Pixel (layout, FX, art). Spin (all player copy).
Layout lock: Doop `BN2zgJKB3g`, export `verdant_splash_layout_lock@2x.png` (3360×2080 = 1680×1040 @2x).
Sequence storyboard: Doop sequence frame (`f2`): map → dissolve → story splash → wheel nests.

## 1. When it shows

| Event | Splash? | Transition |
|---|---|---|
| Player enters a biome **from the campaign map** (`campaign_map.start_asked` → `_on_campaign_start`) | **Yes, on every enter** | Soft dissolve in → splash → skip → fade out → wheel nests |
| Player leaves a biome (back to cabin or map: win, loss, push-home) | **No** | Soft dissolve out only |
| Push deeper mid-run (`_adventure_continue`) into the next tip biome | **Yes** (same splash as map enter) | Splash for the **next** biome → skip → fade out → wheel nests. No hall wipe on this path. |
| Endless run | No (Endless has no biome narration and no `music_biome_dungeon` today) | Existing hall wipe |

Tip biomes **b1–b5** always show the splash on map enter (placeholder art OK). Slug = snake_case of the campaign biome name: `verdant_hollow`, `crystal_cavern`, `ashen_crypt`, `cinder_forge`, `shadow_abyss`. If `splash.biome.<slug>` is missing from `data/player-copy.json`, still show the splash with chrome + an **empty** narration Label — do not invent words and do not skip. Spin keys light up later with no code change. Biome ambient particles start on the splash still (shared `BiomeAmbient` kit over art, behind chrome) and continue into the delve.

## 2. Frame (1680×1040 design space)

```
┌──────────────────────────────── 1680 ────────────────────────────────┐
│ [Biome name plate]  ← chrome stack @ (40,36), VBox, 8px sep           │
│ [DUNGEON n]                                                           │
│ [DELVES: n]                     ART REGION 1680×832 (80%)             │
│                                                                       │
│        New Sprout 64px idle_f0 ×5 Nearest      monster hint:          │
│        box (500,432) 320×320                   eyes only (1200,430)   │
│ ──────────── bottom fade 72px ─────────────────────────────── y 832 ──│
│ NARRATION BAR 1680×208 (20%)  6px top border #7A4E2B                  │
│   inner panel inset 24/18/24/20, 4px border #3B2618, fill #211610     │
│   text box x96 w1280, 36px / 40px line, ≤3 lines        [leaf] cue    │
└───────────────────────────────────────────────────────────────────────┘
```

### Regions
| Region | Rect (x,y,w,h) | Notes |
|---|---|---|
| Art | 0,0,1680,832 | One scene per biome. `TextureRect`, `STRETCH_KEEP_ASPECT_COVERED`, `texture_filter = NEAREST`. |
| Vignette | 0,0,1680,832 | One gradient `TextureRect` (radial, dark edges). Placeholder: `GradientTexture2D`. |
| Bottom fade | 0,760,1680,72 | Vertical gradient `rgba(11,7,6,0)` → `rgba(11,7,6,.85)`. |
| Chrome stack | 40,36 | `VBoxContainer`, separation 8. See §3. |
| New Sprout | 500,432,320,320 | `TextureRect` of `res://assets/dungeon/anim/player/sprout_idle_f0.png` (64px) at ×5, NEAREST. Ground shadow: 144×16 rect at (624,744), #12261b @ 60%. Sits on the left-third line, faces right toward the path. |
| Monster hint | ~1200,430,200,220 | **Eyes only.** Glints in the dark, never a body or silhouette. Painted into the art later. Placeholder art has none. |
| Fireflies | art region | `CPUParticles2D`, ~24 particles, 2×2 px squares #E8D36A, slow drift, low alpha flicker. Optional on placeholder pass. |
| Narration bar | 0,832,1680,208 | `Panel` with `StyleBoxFlat` for now (fill #1A120E, top border 6px #7A4E2B, inner shadow #4A2F1F). Painted 9-slice (24px margins) later. |
| Narration text | 96,870,1280,132 | `Label`, autowrap, 36px font from the project theme, line height 40, color #E9D3A1, max 3 lines. |
| Click cue | right 56, bottom 30 of the bar | Leaf icon 12px ×2 NEAREST that bobs 2px (Tween loop 0.8s, sine). Label uses Spin key `splash.chrome.continue` = `click anytime` (lowercase; leaf kept). **Never** reuse `intro.next` / "Click to continue". |

Scaling: build the screen in 1680×1040 and let the project's existing stretch settings scale it. No per-element DPI math.

## 3. Chrome (top-left, EXACT Spin copy)

| Line | Key | Text | Fill |
|---|---|---|---|
| 1 (plate, larger) | `splash.chrome.biome` | `{name}` | `CAMPAIGN_SHELL.biome_name(rules, biome_id)`, e.g. "Verdant Hollow" |
| 2 (stat) | `splash.chrome.dungeon` | `Dungeon {n}` | `dungeon_index` after `_begin_campaign_delve` sets it (`index + 1`) |
| 3 (stat) | `splash.chrome.delves` | `Delves: {n}` | `home_cabin.counters.delves` (lifetime, same count as the Brag-o-Meter; it already went up when the player left the cabin) |

- **Never show Tier.** No tier name, number, or pips anywhere on the splash.
- Stat style: Silkscreen-like caps from the theme, 17px, letter-spacing 2, color #EFE0B6, fill rgba(26,18,14,.9), 3px border #4A2F1F, pad 3/10/2/10.
- Plate style: larger display font, biome-tinted text (Verdant #9cc45a), 3px border #7A4E2B.

## 4. Narration copy (EXACT, Spin-locked)

`splash.biome.verdant_hollow` =
> The Hollow breathes green under Mount Grumblegut. Moss drinks what little light sneaks in. The path ahead is soft, damp, and already listening.

Show it as written. The Doop mock breaks it into 3 lines at the sentence ends; with autowrap at 1280px and 36px it fits in 3 lines. Don't add, cut, or retype anything; read it through `PLAYER_COPY.text()`.

## 5. Sequence + timings (locked)

| Step | Duration | What happens | Input |
|---|---|---|---|
| 0. Click biome on map | t=0 | Map input locks (`mouse_filter = IGNORE` / busy flag) so a double click can't re-trigger. | locked |
| 1. Soft dissolve in | **0.35s** | Splash `modulate:a` 0→1 over the map, `TRANS_SINE`, `EASE_IN_OUT`. **Music starts here:** `sfx.music_biome_dungeon(biome_id)` (native `music_to` fade). Once the splash is opaque, hide the map and run delve setup behind it. | **skip accepted** |
| 2. Splash holds | **until click** | No timer, no minimum dwell, no auto-advance. | **skip accepted** (any mouse button, touch, or key) |
| 3. Fade out | **~0.20s** | `modulate:a` → 0 from the current alpha. Then `queue_free`/hide. | locked |
| 4. Wheel nests | **~0.45s** | Wheel drops in from above and settles: `TRANS_BACK`, `EASE_OUT`. | locked **until settle** |
| 5. Play | | Normal arm-delve and challenge setup continue. | unlocked |

- **Skip mid-dissolve:** kill the dissolve Tween and start the fade out from the current alpha. No pop and no snap to 1.
- The skip is consumed by `_unhandled_input` → `set_input_as_handled()` so it never reaches the wheel or the map.
- **Music does not re-trigger** on skip, fade out, or nest. It's called exactly once, at splash appear.

## 6. Leaving a biome

Soft dissolve out (fade to the backdrop color, ~0.35s, `TRANS_SINE`) on the way back to cabin or map. **No splash.** Music stays on its current rules: victory music only on the clear path (`music_after_dungeon_clear`), cabin music from the existing cabin open.

## 7. Palette (Verdant)

Bar #1A120E · bar border #7A4E2B · inner #211610 / #3B2618 · text #E9D3A1 · stat text #EFE0B6 · leaf #9cc45a / #5f8f3c / stem #7A4E2B · art ramp #0f2219 → #1b3a26 → #2a4f2f → #2e5530 · firefly #E8D36A.

## 8. Out of scope / don't

- No new player-facing words. No Tier. No "Press any key" or OS-style button.
- No monster bodies in the art. Eyes only.
- No auto-advance timer, ever.
- No splash on leave or Endless. Push deeper into b1–b5 uses the same splash as map enter.
