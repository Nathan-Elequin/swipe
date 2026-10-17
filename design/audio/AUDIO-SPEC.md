# Swipe — Audio Spec (pass 1)

Owner: sound pass 1, 2026-10-17. Input: `audio-director.md` (Cursor's audit). Engine: Godot 4.7.2, web build on itch (1680×1040, `scenes/main.tscn`).
Companion files: `data/sfx-map.json` (machine-readable version of §6–§7), `assets/audio/CREDITS.txt`, `tools/audio/*` (rebuild scripts), `design/audio/CURSOR-PROMPT.md` (implementation prompt).

Rules carried over from the audit: keep and extend `scripts/audio_fx.gd` (no second manager, no `AudioStreamPlayer` nodes in combat scripts); don't change player-facing text; never show the word "Tier" to players (internal keys `tier`, `weak/tough/deadly` are fine); editor-only screens get no new assets.

---

## 1. Sonic identity

**One line:** *a pocket full of stolen stuff in a damp stone hallway.* Everything is small, close, tactile and a bit cheeky; the dungeon is big, cold and far away.

| Material | Where it shows up | Character |
|---|---|---|
| **Wood** | the wheel (ratchet ticks, detent clunk), tables / card placement, the cabin (floorboards, chair, shelf) | warm, dry, short. The wheel is a *wooden* carnival wheel, not a casino one. |
| **Iron** | Block (shield plates), latches, gate, armoured Deadly hurt, petrify grind | dull clank, not sparkly sci-fi metal. Plates over swords. |
| **Cloth / leather** | the goblin's sack, tossing cards, Net, Quiet Bell, sack drop | soft, near-field, fast. |
| **Coins** | every *swipe*: taking a relic, bribes, monster loot on death, trophies, the sack at home | the game's signature. Small clink for small wins, a handful for kills, a spill for Deadly kills. |
| **Wet dungeon** | eggs, cube, leech, bleed drip, poison bubbles, the yd ambience bed | gooey and gross-funny rather than horror. |
| **Goblin mischief** | Nib's gibberish voice, the player's "hrk!", the pizzicato stings, sad-sax defeat, smoke "poof" | the humour layer. |

**How humour shows (and its limits):** humour lives in *timing and instrument choice*, not in silly SFX on every action. Pizzicato strings = tiptoeing thief; the defeat sting is a deflating sax; smoke is a cartoon poof; Nib and monsters speak gibberish (pitch = personality, Cowardly King is pitched *up*). Combat hits stay honest and punchy so the game still reads as dangerous.

**Readability (Kenney-ish clarity):** every cue has one obvious transient in the first 30 ms, short tails (≤ 0.6 s for anything that can repeat), and each card class owns a distinct material: Attack = flesh punch + blade, Block = iron plate, Heal = bell arpeggio, Defeat = decisive knife, Smoke = poof, Chaos = wobbly pizzicato + bell echo, Egg = shell crack. Weak / Tough / Deadly are told apart by *weight*: knock → plank thud → bell toll + sting.

**Avoid:** realistic gore/screams, voice with words, reverb-washed "epic" trailers, sci-fi zaps/lasers (the Digital Audio pack was auditioned and rejected), long risers on anything repeatable, bright high-mids that fatigue in 45 s fights, stacking more than ~3 voices per action.

---

## 2. Buses

`default_bus_layout.tres` (replace whole file):

| # | Bus | Send | Effects (in order) | Default slider (linear) | Notes |
|---|---|---|---|---|---|
| 0 | **Master** | — | `AudioEffectHardLimiter` (ceiling −1.0 dB, pre-gain 0, release 0.1 s) | 1.0 | safety only; should rarely engage |
| 1 | **Music** | Master | slot 0 `AudioEffectAmplify` named **Duck** (volume_db 0, driven by code) | 0.85 | beds only (A/B players). Slider = bus volume. Ducking = Amplify, never the slider. |
| 2 | **Stings** | Master | — | follows Music slider | victory/defeat/clear/bucket/Deadly stings + chaos trill. Not ducked by itself. |
| 3 | **Ambience** | Master | `AudioEffectLowPassFilter` cutoff 20000 (code drops to 1200 Hz while paused) | 0.8 | cabin fire loop, purr loop, footsteps, rock creaks, cat |
| 4 | **SFX** | Master | `AudioEffectCompressor` threshold −14 dB, ratio 3:1, attack 5 ms, release 120 ms, gain 0 | 1.0 | combat, wheel, gate, cards, cabin foley |
| 5 | **UI** | Master | — | 0.9 | hover, click, sliders, Nib/monster speech blips, trophy tick |

**Ducking (code, via Music/Duck amplify):** stings duck Music (values per cue in sfx-map `duck_music`), Nib/monster speech −3 dB while blips play, pause menu −6 dB + Ambience low-pass 1200 Hz, between fights −4 dB (see §5). Attack/release default 0.05 s / 0.6 s.

**Settings sliders:** Master, Music, **Ambience (new)**, SFX, **UI (new)**. Stings follow Music. Labels for the two new sliders: match existing slider label style (if labels come from `data/player-copy.json`, add new keys; do not edit existing strings). Dragging SFX/UI/Ambience plays `ui.slider_tick` *on that bus* (70 ms cooldown); Master/Music play nothing (the bed is audible).
**Save:** `user://audio.json` → `{"version":2,"master":1.0,"music":0.85,"ambience":0.8,"sfx":1.0,"ui":0.9}`; missing keys fall back to defaults so v1 files still load. Bus mute at linear ≤ 0.001 (as today).

---

## 3. Mix targets

**Asset mastering (done in this pass, `tools/audio/build_audio.py`):**

| Category | Asset target | Peak | Format |
|---|---|---|---|
| SFX one-shots | active-RMS ≈ −16 dBFS | ≤ −1 dBFS | OGG Vorbis 48 kHz mono q4 |
| UI / speech blips | active-RMS ≈ −20 dBFS | ≤ −1 dBFS | 48 kHz mono q4 |
| Stings | active-RMS ≈ −16 dBFS (≈ −16…−18 LUFS) | ≤ −1 dBFS | 48 kHz mono q4 |
| Ambience loops | active-RMS ≈ −22 dBFS | ≤ −1 dBFS | 48 kHz mono q4, crossfaded loop |
| Music beds | −20 LUFS integrated (cabin −22) | ≤ −6 dBFS measured | 44.1 kHz stereo, Vorbis q1.5 (~80 kbps) |

Existing files (`*.wav` Kenney Interface at RMS −10…−21, Kenney RPG OGGs) are left as they are; new assets were mastered to sit at the same per-call `db` scale, so `-8` means the same loudness for old and new.

**In-game balance (what the player hears, Master at 1.0):**

| Layer | Effective level | How |
|---|---|---|
| Music bed | ≈ −24…−26 LUFS short-term | per-bed `gain_db` in sfx-map (title +14, combat −4, deadly −3, cabin −2) × Music slider 0.85 |
| Ambience | ≈ −28 LUFS | fire loop at −10 dB on Ambience 0.8 |
| SFX peaks in a busy turn | ≈ −6…−3 dBFS peak, ≈ −16…−14 LUFS momentary | per-cue db (−6…−10 typical), SFX compressor |
| UI | 6–10 dB under SFX | per-cue db −12…−18 |
| Stings | ≈ SFX peak level, music ducked under them | per-cue db −5…−8 |

`MUSIC_GAIN_DB := 8.0` is replaced by per-bed `gain_db` (the title bed keeps its sound but gets +14 because the yd file is ≈ −40 LUFS). `COMBAT_DUCK_DB` is retired (real combat bed now exists).

**Pitch randomisation:** default ±3 % (0.97–1.03). Hits ±6–8 %, hovers ±5 %, cards ±5 %, speech blips 0.94–1.12 (+ per-speaker multiplier). Fixed-pitch cues (stings, legacy chords whose call sites pass pitch) have `[p, p]`. Final pitch clamp 0.5–2.0 (was 0.7–1.4; Deadly sting for Dragon needs 0.75 × random, speech needs up to 1.4).

**Voices, cooldowns, priority:**
* **Pool: 16** round-robin SFX/UI players (was 8) + dedicated players: **tick** (1 player, `max_polyphony = 3`), **speech** (1 player, retrigger cuts), **Music A/B**, **Sting** (1, `max_polyphony 2`), **Ambience loops** (fire, purr: 2 looping players) + ambience one-shots use the pool with bus Ambience.
* Each cue has `cooldown_ms` (drop the call if the same cue fired more recently) and `max_voices` (if exceeded, steal the oldest voice *of that cue*).
* `priority` 0–3 (0 hover/ticks, 1 normal, 2 important combat, 3 stings/land/death/victory). If all 16 are busy: steal the oldest voice whose priority ≤ the new cue's; if none, drop the new cue.
* Legacy `play(id, db, pitch)` calls stay valid (priority 1, no cooldown) so untouched call sites keep working.

---

## 4. Wheel ticks

The spin is a 1.2 s cubic-ease tween with an extra full turn (`boss_wheel.gd:444–467`, tween at `:461`). With 8 seats the pointer passes 8–16 boundaries; peak rate at the start ≈ 30–40/s.

* `boss_wheel.gd` gets `signal segment_passed(index: int, speed01: float)`. Drive the tween through `tween_method` (or poll the rotation in `_process` while spinning), compute `seg = floori(fposmod(rotation - pointer_offset, TAU) / (TAU / seat_count))`, emit on change. `speed01` = current angular speed / peak speed.
* `main.gd` connects it to `sfx.play_tick(speed01)`: dedicated tick player, cue `wheel.tick`, 35 ms min interval (skips are fine at the fast start), pitch `lerp(0.92, 1.12, speed01)` × random 0.96–1.04, db `lerp(-18, -12, speed01)`. Ticks thin out and drop in pitch as the wheel slows, which builds tension.
* On land: `wheel.detent` (wooden clunk) is layered into `wheel.land_<tier>`.

---

## 5. Music plan

All beds loop as whole files (loop points baked by trimming; import with `loop = true`, `loop_offset = 0`). Two Music players **A/B** on the Music bus; `music_to(bed, fade)` crossfades with equal-power curves; `resume_position` beds remember their playback position.

| Bed | File | Source / author / licence | Length & loop | Mood · tempo · key (auto-estimated) | Instrumentation | Plays when |
|---|---|---|---|---|---|---|
| **title** (also draft mill, tutorial, Challenge setup, between runs) | `music.ogg` (**keep**) | "Dungeon Ambience" — yd — CC0 — https://opengameart.org/content/dungeon-ambience | 206.0 s, whole-file loop | dark drone with crunchy movement; no strong pulse | ambient pads, textures | boot (after first-click unlock), title, draft gate, tutorial, cabin → title, after victory/defeat stings |
| **combat** | `music_combat.ogg` (**new**, finally fills the missing file) | "RPG Battle Loop" — iamoneabe — CC0 — https://opengameart.org/content/rpg-battle-loop | 59.077 s (= 32 bars at ~130 BPM; MP3 padding removed, 4 ms edge fades) | driving, dark-ish RPG battle; ≈130 BPM; ≈ A minor | retro-orchestral / synth RPG | from first Spin of a dungeon until dungeon clear / defeat / leave. Stays through "ready" between fights, ducked −4 dB. |
| **deadly** | `music_deadly.ogg` (**new**) | "Dungeon Deep" — Eldritch Grim — CC0 — https://opengameart.org/content/dungeon-deep-0 | 25.899 s (loop cut where the intro repeats, corr 0.98; ring-out tail dropped) | ominous, tense maze/dungeon loop | dark synth/ percussion | spin lands on a Deadly monster (after `sting.deadly`, 0.5 s xfade); back to combat bed (resume position, 1.2 s) on that monster's death or fight end |
| **cabin** | `music_cabin.ogg` (**new**) | "A Small Fire Will Do (Calming Loop)" — Trex0n (Cal McEachern) — CC0 (credit appreciated) — https://opengameart.org/content/a-small-fire-will-do-calming-loop | 64.000 s exactly (16 bars at 120 BPM / 60 felt) | cozy, meditative; ≈ G major | acoustic guitar | Home cabin open (1.5 s xfade from whatever was playing), with fire/purr ambience on top; back to title on close |
| stings | `sting_victory`, `sting_clear`, `sting_defeat`, `sting_bucket`, `sting_deadly`, `chaos_warble` | Kenney Music Jingles — CC0 — https://kenney.nl/assets/music-jingles (PIZZI10, PIZZI15, SAX01, PIZZI02, HIT06, PIZZI03) | 0.5–1.1 s one-shots on Stings bus | pizzicato = sneaky thief; sax = deflating defeat; low hit = Deadly | — | see cue table |

**Alternates auditioned (CC0, not shipped):** "8-bit – Infinite Darkness" by HydroGene (https://opengameart.org/content/8-bit-infinite-darkness, 165 s, very hot −11 LUFS, 6.6 MB source; good boss bed for a later pass), "Lava Dungeon Battle" by Sorth (8-bit, 64 s), "4 Music Box Tracks" by Aureolus_Omicron (https://opengameart.org/content/4-music-box-tracks; `musicbox2_cute_tune` 137 s is the music-box option for the cabin if Nathan prefers a music box over guitar; ~1.1 MB at 64 kbps).

**State machine** (`AudioFx.music_state`):

```
            first click (web unlock)
 BOOT ──────────────────────────────► TITLE ◄────────────────────────────┐
                                       │  Spin (main.gd:4484)              │ dungeon clear 1677 / flee 7964 /
                                       ▼                                   │ leave 1711 / restore-to-non-combat 5271
                                    COMBAT ── after fight (2802, 4932) ──► BETWEEN (combat bed, Duck −4 dB)
                                       ▲ │ land on tier 3 (4491)              │ next Spin → COMBAT (unduck 0.3 s)
                       Deadly slain /  │ ▼                                    │
                       fight ends      DEADLY                                 │
 any ──► CABIN (open_cabin) ──close──► TITLE                                  │
 player down 4881-4887 ──► DEFEAT: Duck −30 dB 0.1 s, sting.defeat, after 3 s → TITLE (fresh, fade-in 2 s)
 victory 4876-4884     ──► VICTORY: Duck −30 dB, sting.victory, after 2.5 s → TITLE
```

* `set_combat_music(true/false)` keeps its signature (call sites stay) but maps to COMBAT / BETWEEN. Only the *explicit* exits (clear, flee, leave, death, victory, restore to non-combat phase) return to TITLE. Read each call site in the audit list and pick the right one; `_challenge_after_fight` (2802) and "clear after fight" (4932) → BETWEEN unless the dungeon is cleared.
* Crossfades: default 0.8 s; →deadly 0.5 s; deadly→combat 1.2 s; →cabin 1.5 s; →title 1.2 s.
* `stop_music()` stays (0.5 s fade) for completeness.
* **Web first-click unlock:** `AudioFx` (PROCESS_MODE_ALWAYS) handles the first `InputEventMouseButton`/`InputEventKey`/`InputEventScreenTouch` press in `_input`: sets `_unlocked = true`, and if `OS.has_feature("web")` re-starts the current bed (`play(saved_pos)`) and any active ambience loops. `start_music()` in `_ready` still runs (desktop/editor plays immediately). Never show an "enable sound" UI text (no new player-facing copy).

---

## 6. Data-driven hooks (`data/sfx-map.json`)

```jsonc
{
  "version": 1,
  "path_prefix": "res://assets/audio/",             // file "x" → x.ogg, else x.wav
  "buses": {...}, "prefix_bus": {"ui.":"UI","speech.":"UI","sting.":"Stings","amb.":"Ambience","music.":"Music"},
  "defaults": {"bus":"SFX","db":-8,"pitch":[0.97,1.03],"cooldown_ms":0,"max_voices":4,"priority":1},
  "voice_pool": {"sfx_players":16, ...},
  "cues": {                                          // every cue in §7
    "atk.hit_light": {"files":["atk_hit_light_1","atk_hit_light_2","atk_hit_light_3"],"bus":"SFX","db":-7,
                      "pitch":[0.94,1.08],"cooldown_ms":40,"max_voices":3,"priority":2,
                      "layers":[{"cue":"atk.slash","db_offset":-8,"delay_ms":0}]},
    "wheel.land_deadly": {..., "layers":[...,{"cue":"sting.deadly","db_offset":0,"delay_ms":120}], "music":"deadly"},
    "amb.fire": {"files":["cabin_fire_loop"],"bus":"Ambience","db":-10,"loop":true}, ...
  },
  "fallback_chain": ["card_id","special_id","ops_kind","card_color","tier","default"],
  "lookup": {
    "card_id":   {"echo_bell":{"use_pre":"chaos.echo_bell","copied_delay_ms":90,"empty":"chaos.echo_empty"}, ...},
    "special_id":{"gelatinous_cube":{"ask":"mon.cube_ask","feed":"mon.cube_feed"}, ...},
    "ops_kind":  {"atk*":{"hit":"atk.hit_light","hit_heavy":"atk.hit_heavy","heavy_threshold":5,"zero":"atk.fizzle"},
                  "blk*":{"gain":"blk.gain","gain_big":"blk.gain_big","big_threshold":4}, "heal_*":{"gain":"heal.gain"}, ...},
    "card_color":{"atk":{...},"blk":{...},"heal":{...},"defeat":{...},"utility":{...},"smoke":{...},"chaos":{...},"egg":{...}},
    "tier":      {"enter":{"1":"wheel.land_weak","2":"wheel.land_tough","3":"wheel.land_deadly"},
                  "hurt":{"1":"mon.hurt_weak",...}, "death":{"1":"mon.death_weak",...}},
    "default":   {"hit":"atk.legacy","gain":"blk.legacy","use":"hand.select","fail":"ui.illegal",...}
  },
  "deadly_sting_pitch": {"dragon":0.75,"cowardly_king":1.33, ...},
  "wheel_ticks": {...}, "speech": {...}, "music": {"beds":{...},"crossfade_s":{...},"states":{...}}
}
```

**Resolution:** `resolve(event: StringName, ctx: Dictionary) -> StringName` walks `fallback_chain`: for each key present in `ctx` (`card_id`, `special_id`, `ops_kind`, `card_color`, `tier`), look up `lookup[key][ctx[key]]` (ops_kind keys ending in `*` are prefix matches) and return the first entry that has `event`. Then `play_event(cue_id, ctx)` plays the cue's files (random pick, no immediate repeat), applies db/pitch/cooldown/voices, schedules `layers` with their delays, applies `duck_music` and `music` state changes. Pitch multipliers from ctx (`pitch_mul`, e.g. `deadly_sting_pitch[monster_id]`, leech climb, seat step) multiply the random pitch.

**Layer level rule:** a layer plays at *the layer cue's own db + db_offset* (not relative to the parent).

**keep+ cues** have `files: []`: their existing `sfx.play(...)` lines stay exactly as they are; add one `play_event(id)` next to them to get the extra layer(s).

**Echo Bell:** when the played card is `echo_bell` and it copies ops, play `chaos.echo_bell` first, then resolve and play the *copied* card's cues delayed by `copied_delay_ms` (90 ms) so the bell reads as "this is an echo". Empty echo → `chaos.echo_empty` (existing error).

**Tier from monster:** `tier` comes from the monster's pack tier (1 Weak, 2 Tough, 3 Deadly). Internal only — no player-facing text.

**Speech (Nib + monsters):** gibberish only, never words. If text reveals per character, play one blip every `chars_per_blip` visible letters (skip spaces/punctuation; a `?` at line end raises the last blip ×1.15, `!` plays it +2 dB). If the line appears at once, play a burst of N blips (3–6 for Nib, 2–5 for monsters, scaled by line length) at 70–110 ms intervals. Pick the next file at random, never the same twice. Speaker pitch: Nib 1.0; monsters by tier (1.1 / 1.0 / 0.85); Cowardly King ×1.3. Speech ducks Music −3 dB while active.

---

## 7. Cue table

Status: **keep** = same sound as today (leave the call site alone); **keep+** = existing call stays, add the listed layer(s); **replace** = swap what plays (old file may stay as a layer); **new** = event was silent. Rows starting "(layer)" are helper cues referenced by layers, not separate events. dB is the per-call volume (same scale as existing `sfx.play` calls). Pitch shows the random range (or fixed value). Cooldown / voices / prio as defined in §3. All `.wav` names without a new source are existing repo files.

| Cue id | Event | File:line | Status | Sound | Asset(s) → source | Bus | dB | Pitch | Cooldown / voices / prio | Layers |
|---|---|---|---|---|---|---|---|---|---|---|
| `ui.hover_title` | Title pill hover (How to Play / Dive In / Adventure / Challenge / Home) | main.gd:1068–1073 | **new** | Soft wooden 'tok', quieter cousin of hover.wav | `ui_hover_soft_a`, `ui_hover_soft_b` → sfxgen.py `ui_hover_soft_a`; sfxgen.py `ui_hover_soft_b` | UI | -16 | 0.95–1.05 | 60 ms / 1 / 0 | — |
| `ui.tutorial_start` | Title click How to Play | main.gd:11068–11069 | **keep** | Book flip + door open | `book` → Kenney RPG Audio (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 2 | ui.door_open (+0 dB, +0 ms) |
| `ui.door_open` | (layer) door open | — | **keep** | Kenney RPG door | `door_open` → Kenney RPG Audio (existing repo file) | SFX | -8 | 0.97–1.03 | 0 ms / 2 / 1 | — |
| `ui.quick_start` | Title click Dive In | main.gd:1966–1967 | **keep** | Confirm + door open | `confirm` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 2 | ui.door_open (-4 dB, +0 ms) |
| `run.start` | Adventure / Challenge start (_reset_run) | main.gd:1646, 1657, 1582 | **keep** | Big confirm | `confirm_big` → Kenney Interface Sounds (existing repo file) | UI | -8 | 1.00 | 300 ms / 1 / 2 | — |
| `ui.menu_open` | Escape opens settings | main.gd:3945–3947 | **keep** | Open; Music ducks −6 dB while paused | `open` → Kenney Interface Sounds (existing repo file) | UI | -12 | 1.00 | 0 ms / 1 / 2 | — · duck -6 dB |
| `ui.slider_tick` | Settings slider drag (SFX / UI / Ambience) | settings_menu.gd:222–234 | **replace** | Tiny tick routed to the bus being dragged (preview); replaces rapid click spam | `ui_tick` → Kenney — Interface Sounds: `Audio/tick_002.ogg` | UI | -12 | 0.98–1.02 | 70 ms / 1 / 0 | — |
| `ui.resume` | Settings Resume | settings_menu.gd:239 | **keep** | Click | `click` → Kenney Interface Sounds (existing repo file) | UI | -8 | 1.00 | 0 ms / 1 / 1 | — |
| `ui.mode_pick` | Settings start-over mode | settings_menu.gd:245 | **keep** | Confirm | `confirm` → Kenney Interface Sounds (existing repo file) | UI | -8 | 1.00 | 0 ms / 1 / 1 | — |
| `ui.editor_open` | Settings Roster/Script (editor only) | settings_menu.gd:252, 259 | **keep** | Book (editor only — no new assets) | `book` → Kenney RPG Audio (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 0 | — |
| `ui.hover_menu` | Settings button hover | settings_menu.gd:173–201 | **new** | Soft wooden tok | `ui_hover_soft_a`, `ui_hover_soft_b` → sfxgen.py `ui_hover_soft_a`; sfxgen.py `ui_hover_soft_b` | UI | -18 | 0.95–1.05 | 60 ms / 1 / 0 | — |
| `ui.back` | Settings close (Esc / back) | settings_menu.gd:216–219 | **new** | Short 'back' blip; Music unducks 0.3 s | `ui_back` → Kenney — Interface Sounds: `Audio/back_002.ogg` | UI | -12 | 1.00 | 0 ms / 1 / 1 | — · duck 0 dB |
| `ui.undo` | Undo | main.gd:5278, 5282 | **keep** | Whoosh 0.72 + click2 | `whoosh` → Kenney Interface Sounds (existing repo file) | UI | -12 | 0.72 | 80 ms / 1 / 1 | ui.click2 (+0 dB, +0 ms) |
| `ui.redo` | Redo | main.gd:5278 | **keep** | Whoosh 1.2 + click2 | `whoosh` → Kenney Interface Sounds (existing repo file) | UI | -12 | 1.20 | 80 ms / 1 / 1 | ui.click2 (+0 dB, +0 ms) |
| `ui.click2` | (layer) click2 | — | **keep** | Kenney click2 | `click2` → Kenney Interface Sounds (existing repo file) | UI | -8 | 1.00 | 0 ms / 2 / 1 | — |
| `ui.illegal` | Illegal action (undo/spin/done etc.) | main.gd:5298, 4466, 4608–4620, 5341–5366 | **keep** | Error | `error` → Kenney Interface Sounds (existing repo file) | UI | -12 | 1.00 | 120 ms / 1 / 1 | — |
| `ui.log_toggle` | Combat log toggle | main.gd:8954 | **keep** | Switch | `switch` → Kenney Interface Sounds (existing repo file) | UI | -14 | 1.00 | 0 ms / 1 / 0 | — |
| `draft.seat_starter` | Starters seated N/E/S/W | main.gd:3125 | **replace** | Card placed on table + drop; pitch steps up per seat (code passes 0.92+0.06·i) | `card_place_1`, `card_place_2`, `card_place_3` → Kenney — Casino Audio: `Audio/card-place-1.ogg`; Kenney — Casino Audio: `Audio/card-place-2.ogg`; Kenney — Casino Audio: `Audio/card-place-3.ogg` | SFX | -10 | 0.98–1.02 | 0 ms / 2 / 1 | draft.drop (-2 dB, +0 ms) |
| `draft.drop` | (layer) drop | — | **keep** | Kenney drop | `drop` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.00 | 0 ms / 3 / 1 | — |
| `draft.starter_kit` | Starter items granted | main.gd:3232–3233 | **keep** | Cloth + confirm | `cloth` → Kenney RPG Audio (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 1 | ui.confirm_soft (-4 dB, +0 ms) |
| `ui.confirm_soft` | (layer) confirm | — | **keep** | Confirm | `confirm` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 2 / 1 | — |
| `draft.offer` | Petitioner / offer shown | main.gd:3253–3254 | **keep** | Creak + question | `creak` → Kenney RPG Audio (existing repo file) | SFX | -12 | 1.00 | 0 ms / 1 / 1 | ui.question (+0 dB, +0 ms) |
| `ui.question` | (layer/prompt) question | main.gd:5397 | **keep** | Question blip | `question` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `draft.mystery` | Mystery relic shown at gate | draft_gate.gd:261 | **new** | Wobbly pizzicato trill (same family as Chaos) — 'what's in the box?' | `chaos_warble` → Kenney — Music Jingles: `Audio/Pizzicato jingles/jingles_PIZZI03.ogg` | Stings | -16 | 1.00 | 0 ms / 1 / 1 | — |
| `draft.take` | Take (send through gate) | main.gd:3289–3301 | **keep+** | Existing latch/slam/whoosh → door/bong chord kept; + small coin rattle (the goblin pockets it) | (existing calls stay; adds layers) → — | SFX | -6 | 1.00 | 0 ms / 1 / 2 | loot.coins_small (-8 dB, +220 ms) |
| `draft.refuse` | Leave / refuse | main.gd:3328–3329 | **keep** | Scratch + switch 0.85 | `scratch` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `draft.autofill` | Out of refusals, auto-fill | main.gd:3355–3373 | **keep** | Creak then slam+latch / door | `creak` → Kenney RPG Audio (existing repo file) | SFX | -12 | 1.00 | 0 ms / 1 / 1 | — |
| `draft.courier` | Courier flies relic to wheel | main.gd:3403 | **keep** | Whoosh 1.1 | `whoosh` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.08–1.12 | 0 ms / 2 / 1 | — |
| `draft.seat_fail` | Seat fail (no empty) | main.gd:3421 | **keep** | Error | `error` → Kenney Interface Sounds (existing repo file) | UI | -14 | 1.00 | 0 ms / 1 / 1 | — |
| `draft.mill_done` | Mill finished, wheel ready | main.gd:3275–3276 | **keep** | Door close + confirm_big | `door_close` → Kenney RPG Audio (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 2 | — |
| `draft.next_offer` | Next offer drawn | main.gd:3009, 3027 | **keep** | Book flip | `book` → Kenney RPG Audio (existing repo file) | SFX | -10 | 0.95–1.05 | 0 ms / 1 / 1 | — |
| `speech.monster` | Monster speech line (gate / any speech_box) | main.gd:10045 | **new** | Low gibberish grumble: 2–5 blips per line (see speech rules) | `monster_blip_01`, `monster_blip_02`, `monster_blip_03`, `monster_blip_04` → sfxgen.py `monster_blip_01`; sfxgen.py `monster_blip_02`; sfxgen.py `monster_blip_03`; sfxgen.py `monster_blip_04` | UI | -14 | 0.90–1.10 | 70 ms / 1 / 1 | — |
| `chal.seat_dungeon` | Seat 6 dungeon monsters | main.gd:2470–2483 | **replace** | Card-place variants instead of stacked drops; voice-limited so 6 rapid seats don't pile up | `card_place_1`, `card_place_2`, `card_place_3` → Kenney — Casino Audio: `Audio/card-place-1.ogg`; Kenney — Casino Audio: `Audio/card-place-2.ogg`; Kenney — Casino Audio: `Audio/card-place-3.ogg` | SFX | -10 | 0.95–1.08 | 60 ms / 2 / 1 | — |
| `chal.offer_pick` | Opening pick-two shown | main.gd:2590–2591 | **keep** | Book + open | `book` → Kenney RPG Audio (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `chal.commit` | Commit chosen item | main.gd:2619–2620 | **keep+** | Confirm + cloth; + tiny coin clink | (existing calls stay; adds layers) → — | UI | -12 | 1.00 | 0 ms / 1 / 2 | loot.coins_small (-6 dB, +60 ms) |
| `chal.discard` | Discard one (forced) | main.gd:2647 | **replace** | Card shoved off the table | `card_shove` → Kenney — Casino Audio: `Audio/card-shove-1.ogg` | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `chal.holes` | Holes resolve / refill | main.gd:2717–2758 | **keep** | Open+bong or drop+whoosh (as today) | `open` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.00 | 50 ms / 2 / 1 | — |
| `chal.begin` | Begin play | main.gd:2554–2555 | **keep** | Confirm + door open | `confirm` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 2 | — |
| `hand.hover` | Hover a hand card | main.gd:10983 | **keep** | Hover blip (90 ms cap) | `hover` → Kenney Interface Sounds (existing repo file) | UI | -18 | 1.03–1.07 | 90 ms / 1 / 0 | — |
| `hand.select` | Select / click to use | main.gd:5369 | **keep** | Select | `select` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `hand.petrified` | Click a petrified card | main.gd:5359–5360 | **replace** | Error + short stone grind (reads as 'stuck') | `error` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 150 ms / 1 / 1 | status.petrify (-8 dB, +0 ms) |
| `hand.option_pick` | Pick an option | main.gd:5448, 5468 | **keep** | Click2 | `click2` → Kenney Interface Sounds (existing repo file) | UI | -8 | 1.00 | 0 ms / 1 / 1 | — |
| `hand.toss` | Discard / toss spent card | main.gd:5816–5821 | **replace** | Card shove + cloth (whoosh kept when spent) | `card_shove` → Kenney — Casino Audio: `Audio/card-shove-1.ogg` | SFX | -12 | 0.95–1.05 | 40 ms / 2 / 1 | ui.cloth (-6 dB, +0 ms) |
| `ui.cloth` | (layer) cloth | — | **keep** | Cloth | `cloth` → Kenney RPG Audio (existing repo file) | SFX | -10 | 0.95–1.05 | 0 ms / 3 / 1 | — |
| `hand.gain` | Gain item into hand | main.gd:6497–6503 | **replace** | Card placed + soft open | `card_place_1`, `card_place_2`, `card_place_3` → Kenney — Casino Audio: `Audio/card-place-1.ogg`; Kenney — Casino Audio: `Audio/card-place-2.ogg`; Kenney — Casino Audio: `Audio/card-place-3.ogg` | SFX | -10 | 0.97–1.05 | 40 ms / 2 / 1 | — |
| `hand.gain_blocked` | Gain blocked (hand full) | main.gd:6497–6503 | **keep** | Error + cloth | `error` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 120 ms / 1 / 1 | — |
| `chaos.pick` | Chaos Stone pick | main.gd:5982–6016 | **keep** | Question / select / error | `question` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `chaos.transform` | Chaos transform | main.gd:6033–6034 | **keep+** | Whoosh 0.86 + bong 0.7 + wobbly pizzicato trill (chaos identity) | (existing calls stay; adds layers) → — | SFX | -8 | 0.86 | 0 ms / 1 / 2 | chaos.warble (-6 dB, +0 ms) |
| `chaos.warble` | (layer) chaos trill | — | **new** | Kenney pizzicato trill | `chaos_warble` → Kenney — Music Jingles: `Audio/Pizzicato jingles/jingles_PIZZI03.ogg` | Stings | -12 | 0.97–1.03 | 0 ms / 1 / 1 | — |
| `hand.upgrade` | Item upgrade visual | main.gd:6078–6080 | **keep** | Whoosh + pluck + confirm | `whoosh` → Kenney Interface Sounds (existing repo file) | SFX | -8 | 0.90 | 0 ms / 1 / 2 | — |
| `hand.upgrade_fail` | Merchant upgrade fail | main.gd:7498 | **keep** | Error | `error` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `wheel.hover_slice` | Hover a slice | main.gd:4339 | **keep** | Hover | `hover` → Kenney Interface Sounds (existing repo file) | UI | -18 | 1.00–1.06 | 90 ms / 1 / 0 | — |
| `wheel.click_slice` | Click slice | main.gd:4311 | **keep** | Select | `select` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `wheel.place` | Place monster on empty | main.gd:4362–4363 | **keep** | Drop + confirm 1.08 | `drop` → Kenney Interface Sounds (existing repo file) | SFX | -8 | 1.00 | 0 ms / 1 / 2 | — |
| `wheel.bribe` | Bribe / remove | main.gd:4392–4393 | **keep+** | Scratch + creak; + coin handful (it IS a bribe) | (existing calls stay; adds layers) → — | SFX | -8 | 1.00 | 0 ms / 1 / 2 | loot.coins (-10 dB, +40 ms) |
| `wheel.mode_place` | Toggle place mode | main.gd:3859 | **keep** | Switch | `switch` → Kenney Interface Sounds (existing repo file) | UI | -12 | 1.00 | 0 ms / 1 / 1 | — |
| `wheel.mode_bribe` | Toggle bribe mode | main.gd:3868 | **keep** | Switch 0.92 | `switch` → Kenney Interface Sounds (existing repo file) | UI | -12 | 0.92 | 0 ms / 1 / 1 | — |
| `wheel.spin_start` | Spin start | main.gd:4484–4486 | **keep** | Door open + whoosh 0.9; music → combat | `door_open` → Kenney RPG Audio (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 2 | draft.courier (-2 dB, +0 ms) · music→combat |
| `wheel.tick` | Segment passes pointer during 1.2 s spin | boss_wheel.gd:461 (spin_to tween) | **new** | Wooden ratchet pawl; dedicated tick player; pitch & level follow spin speed | `wheel_tick_a`, `wheel_tick_b`, `wheel_tick_c` → sfxgen.py `wheel_tick_a`; sfxgen.py `wheel_tick_b`; sfxgen.py `wheel_tick_c` | SFX | -14 | 0.96–1.04 | 35 ms / 3 / 1 | — · dedicated tick player |
| `wheel.spin_hover` | Hover Spin button | main.gd:9134 | **new** | Soft tok | `ui_hover_soft_a`, `ui_hover_soft_b` → sfxgen.py `ui_hover_soft_a`; sfxgen.py `ui_hover_soft_b` | UI | -18 | 1.05–1.10 | 90 ms / 1 / 0 | — |
| `wheel.deck_hover` | Hover deck (Challenge peek) | main.gd:10521 | **keep** | Hover | `hover` → Kenney Interface Sounds (existing repo file) | UI | -18 | 1.00 | 90 ms / 1 / 0 | — |
| `wheel.num_tick_atk` | ATK number ticks | boss_wheel.gd:723 | **new** | Tick, lower | `ui_tick` → Kenney — Interface Sounds: `Audio/tick_002.ogg` | UI | -16 | 0.85–0.90 | 45 ms / 1 / 0 | — |
| `wheel.num_tick_hp` | HP number ticks | boss_wheel.gd:741 | **new** | Tick, higher | `ui_tick` → Kenney — Interface Sounds: `Audio/tick_002.ogg` | UI | -16 | 1.12–1.18 | 45 ms / 1 / 0 | — |
| `wheel.detent` | (layer) wheel settles | main.gd:4491 | **new** | Wooden clunk at land | `wheel_detent` → sfxgen.py `wheel_detent` | SFX | -8 | 0.97–1.03 | 0 ms / 1 / 2 | — |
| `wheel.land_chord` | (layer) existing land chord | main.gd:4491–4493 | **keep** | door_close + land + bong | `door_close` → Kenney RPG Audio (existing repo file) | SFX | -8 | 1.00 | 0 ms / 1 / 2 | — |
| `wheel.land_weak` | Spin lands on Weak monster | main.gd:4491–4493 | **replace** | Detent + existing chord + light wood knock | `wheel_land_weak` → Kenney — Impact Sounds: `Audio/impactWood_light_002.ogg` | SFX | -10 | 1.00–1.08 | 0 ms / 1 / 2 | wheel.detent (+0 dB, +0 ms), wheel.land_chord (+0 dB, +0 ms) |
| `wheel.land_tough` | Spin lands on Tough monster | main.gd:4491–4493 | **replace** | Detent + chord + heavier plank thud | `wheel_land_tough` → Kenney — Impact Sounds: `Audio/impactPlank_medium_001.ogg` | SFX | -8 | 0.95–1.00 | 0 ms / 1 / 2 | wheel.detent (+0 dB, +0 ms), wheel.land_chord (+0 dB, +0 ms) |
| `wheel.land_deadly` | Spin lands on Deadly monster | main.gd:4491–4493, show_monster 4532 | **replace** | Detent + chord + deep bell + Deadly sting; music → deadly | `wheel_land_deadly` → Kenney — Impact Sounds: `Audio/impactBell_heavy_001.ogg` ×0.8 pitch | SFX | -8 | 1.00 | 0 ms / 1 / 3 | wheel.detent (+0 dB, +0 ms), wheel.land_chord (+0 dB, +0 ms), sting.deadly (+0 dB, +120 ms) · music→deadly |
| `atk.hit_light` | Attack connects, dmg < 5 | main.gd:7878 (_deal_atk_at), 5506 | **replace** | Meaty punch + knife slice layer (replaces hit+chop) | `atk_hit_light_1`, `atk_hit_light_2`, `atk_hit_light_3` → Kenney — Impact Sounds: `Audio/impactPunch_medium_000.ogg`; Kenney — Impact Sounds: `Audio/impactPunch_medium_001.ogg`; Kenney — Impact Sounds: `Audio/impactPunch_medium_002.ogg` | SFX | -7 | 0.94–1.08 | 40 ms / 3 / 2 | atk.slash (-8 dB, +0 ms) |
| `atk.hit_heavy` | Attack connects, dmg ≥ 5 | main.gd:7878 | **new** | Heavy punch + slash, slightly lower | `atk_hit_heavy_1`, `atk_hit_heavy_2` → Kenney — Impact Sounds: `Audio/impactPunch_heavy_000.ogg`; Kenney — Impact Sounds: `Audio/impactPunch_heavy_001.ogg` | SFX | -6 | 0.92–1.02 | 40 ms / 3 / 2 | atk.slash (-6 dB, +0 ms) |
| `atk.slash` | (layer) blade | — | **new** | Kenney knifeSlice | `atk_slash` → Kenney — RPG Audio: `Audio/knifeSlice.ogg` | SFX | -10 | 0.95–1.10 | 0 ms / 3 / 1 | — |
| `atk.legacy` | (fallback) old hit+chop | main.gd:7878–7879 | **keep** | hit.ogg (+chop) — fallback when a map entry is missing | `hit` → Kenney RPG Audio (existing repo file) | SFX | -8 | 0.94–1.08 | 40 ms / 3 / 1 | — |
| `atk.fizzle` | Attack fizzle / Goblin immune / 0 dmg | main.gd:7829, 7863 | **keep** | Glass 0.85 | `glass` → Kenney Interface Sounds (existing repo file) | SFX | -8 | 0.85 | 60 ms / 2 / 1 | — |
| `blk.gain` | Gain Block (n < 4) | main.gd:7201 | **replace** | Shield plate knock (iron) + quiet old block layer | `blk_gain_1`, `blk_gain_2` → Kenney — Impact Sounds: `Audio/impactPlate_light_000.ogg`; Kenney — Impact Sounds: `Audio/impactPlate_light_001.ogg` | SFX | -8 | 0.96–1.06 | 40 ms / 2 / 2 | blk.legacy (-8 dB, +0 ms) |
| `blk.legacy` | (layer) block.ogg | — | **keep** | Kenney RPG block | `block` → Kenney RPG Audio (existing repo file) | SFX | -8 | 1.00 | 0 ms / 2 / 1 | — |
| `blk.gain_big` | Gain Block (n ≥ 4) | main.gd:7201–7203 | **replace** | Heavy plate + block_heavy tail | `blk_gain_big` → Kenney — Impact Sounds: `Audio/impactPlate_heavy_000.ogg` | SFX | -7 | 0.95–1.02 | 40 ms / 2 / 2 | blk.heavy_legacy (-8 dB, +0 ms) |
| `blk.heavy_legacy` | (layer) block_heavy.ogg | — | **keep** | Kenney RPG block_heavy | `block_heavy` → Kenney RPG Audio (existing repo file) | SFX | -14 | 1.00 | 0 ms / 2 / 1 | — |
| `heal.gain` | Heal raises HP | main.gd:7217 | **replace** | Warm 3-note bell arpeggio + glass sparkle (replaces pluck) | `heal_sparkle` → sfxgen.py `heal_sparkle` + Kenney — Impact Sounds: `Audio/impactGlass_light_001.ogg` ×1.2 pitch | SFX | -9 | 0.98–1.03 | 80 ms / 2 / 2 | — |
| `defeat.use` | Defeat card succeeds | main.gd:5708, 5760, 5781 | **replace** | Decisive knife slice + quiet draw | `defeat_slash` → Kenney — RPG Audio: `Audio/knifeSlice2.ogg` | SFX | -7 | 0.95–1.02 | 0 ms / 1 / 2 | defeat.legacy (-6 dB, +0 ms) |
| `defeat.legacy` | (layer) draw.ogg | — | **keep** | Kenney RPG draw | `draw` → Kenney RPG Audio (existing repo file) | SFX | -8 | 1.00 | 0 ms / 1 / 1 | — |
| `defeat.fail` | Defeat card fails | main.gd:5708, 5760, 5781 | **keep** | Error ± latch | `error` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 120 ms / 1 / 1 | — |
| `util.net` | Net (atk_drop) | main.gd:5633 | **keep** | Latch + scratch | `metal_latch` → Kenney RPG Audio (existing repo file) | SFX | -8 | 1.00 | 0 ms / 1 / 2 | — |
| `util.quiet` | Quiet Bell / Silence | main.gd:5663 | **keep+** | Cloth + pluck + muffled bell (sound being smothered) | (existing calls stay; adds layers) → — | SFX | -10 | 1.00 | 0 ms / 1 / 2 | status.silence (-2 dB, +30 ms) |
| `util.caltrops` | Caltrops (atk_zero) | main.gd:5617 | **keep** | Latch + scratch | `metal_latch` → Kenney RPG Audio (existing repo file) | SFX | -8 | 1.05–1.10 | 0 ms / 1 / 2 | — |
| `util.magnet` | Magnet resolves | main.gd:5488+ (_apply_ops magnet branch) | **new** | Rising 'zing' (comic magnet pull) | `util_magnet` → sfxgen.py `util_magnet` | SFX | -10 | 0.97–1.03 | 0 ms / 1 / 2 | — |
| `util.hook` | Hook resolves | main.gd:5488+ (_apply_ops hook branch) | **new** | Quick high slash + cloth tug | `atk_slash` → Kenney — RPG Audio: `Audio/knifeSlice.ogg` | SFX | -10 | 1.20–1.30 | 0 ms / 1 / 2 | ui.cloth (-4 dB, +60 ms) |
| `util.fail` | Utility fails | main.gd:5488+ | **keep** | Error | `error` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 120 ms / 1 / 1 | — |
| `smoke.use` | Smoke card | main.gd:5585 | **new** | Comic smoke-bomb poof (toss sfx still plays) | `smoke_poof` → sfxgen.py `smoke_poof` | SFX | -8 | 0.95–1.05 | 0 ms / 1 / 2 | — |
| `chaos.echo_bell` | Echo Bell copies last card | main.gd:5474–5479, 7274–7280 | **new** | Bright bell with slap echo, then the copied card's own cues 90 ms later | `echo_bell` → Kenney — Impact Sounds: `Audio/impactBell_heavy_002.ogg` ×1.25 pitch | SFX | -9 | 1.00 | 0 ms / 1 / 3 | — |
| `chaos.echo_empty` | Echo Bell with nothing to copy | main.gd:5511 | **keep** | Error | `error` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `egg.hurt` | Egg hurts you | main.gd:4826–4841 | **replace** | Eggshell crack on top of the normal hit/blocked chord | `egg_crack` → Kenney — Impact Sounds: `Audio/impactGlass_light_003.ogg` ×0.75 pitch + Kenney — Impact Sounds: `Audio/impactSoft_medium_001.ogg` ×0.8 pitch | SFX | -8 | 0.95–1.05 | 0 ms / 2 / 2 | — |
| `egg.lay` | Spider Egg laid | main.gd:6794–6796 | **replace** | Wet squelch + low scratch (bleed layer removed) | `egg_squelch` → Kenney — Impact Sounds: `Audio/impactSoft_heavy_002.ogg` ×0.7 pitch | SFX | -10 | 0.90–1.00 | 80 ms / 2 / 1 | draft.refuse_scratch (-6 dB, +40 ms) |
| `draft.refuse_scratch` | (layer) scratch | — | **keep** | Scratch | `scratch` → Kenney Interface Sounds (existing repo file) | SFX | -12 | 0.70–0.80 | 0 ms / 2 / 1 | — |
| `egg.queen_eat` | Spider Queen eats eggs | main.gd:6761–6762 | **replace** | Squelch + gulp | `egg_squelch` → Kenney — Impact Sounds: `Audio/impactSoft_heavy_002.ogg` ×0.7 pitch | SFX | -8 | 0.75–0.85 | 0 ms / 1 / 2 | mon.cube_gulp (-4 dB, +120 ms) |
| `combat.done` | Click Done (legal) | main.gd:4636, 4641 | **keep** | Click | `click` → Kenney Interface Sounds (existing repo file) | UI | -8 | 1.00 | 0 ms / 1 / 1 | — |
| `combat.done_hover` | Hover Done | main.gd:10195 | **keep** | Hover | `hover` → Kenney Interface Sounds (existing repo file) | UI | -18 | 1.00 | 90 ms / 1 / 0 | — |
| `mon.telegraph` | Bodyguard redirect path step | main.gd:7809 | **keep** | Whoosh −14, +0.06 pitch per step; now voice-limited | `whoosh` → Kenney Interface Sounds (existing repo file) | SFX | -14 | 1.00 | 100 ms / 2 / 1 | — |
| `mon.lunge` | Monster lunge (visual) | combat_stage.gd:136 (trigger site in main.gd) | **new** | Short airy whoosh just before connect | `whoosh` → Kenney Interface Sounds (existing repo file) | SFX | -16 | 1.15–1.25 | 80 ms / 1 / 1 | — |
| `player.hurt` | Monster Attack hits you | main.gd:4855–4856 | **replace** | Heavy punch + chop + goblin 'hrk!' (error layer dropped) | `atk_hit_heavy_1`, `atk_hit_heavy_2` → Kenney — Impact Sounds: `Audio/impactPunch_heavy_000.ogg`; Kenney — Impact Sounds: `Audio/impactPunch_heavy_001.ogg` | SFX | -6 | 0.85–0.95 | 60 ms / 2 / 3 | player.chop (-4 dB, +0 ms), player.oof (-4 dB, +40 ms) |
| `player.chop` | (layer) chop | — | **keep** | Kenney chop | `chop` → Kenney RPG Audio (existing repo file) | SFX | -6 | 0.95–1.05 | 0 ms / 2 / 1 | — |
| `player.oof` | (layer) goblin hurt voice | — | **new** | Synth goblin 'hrk' (no words) | `player_oof_a`, `player_oof_b` → sfxgen.py `gob_oof_a`; sfxgen.py `gob_oof_b` | UI | -10 | 0.95–1.08 | 150 ms / 1 / 2 | — |
| `player.blocked` | Monster Attack fully blocked | main.gd:4863–4865 | **keep+** | block_heavy + bong + glass; + plate clang | (existing calls stay; adds layers) → — | SFX | -5 | 1.00 | 60 ms / 2 / 2 | blk.gain_big (-6 dB, +0 ms) |
| `player.pierce_zero` | Dragon pierce, 0 through Block | main.gd:4798 | **keep** | Glass | `glass` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `player.poke` | Damage taken (Needleback poke etc.) | main.gd:7989, 7996 | **replace** | Light punch + goblin 'hrk' (glass when 0) | `atk_hit_light_1`, `atk_hit_light_2`, `atk_hit_light_3` → Kenney — Impact Sounds: `Audio/impactPunch_medium_000.ogg`; Kenney — Impact Sounds: `Audio/impactPunch_medium_001.ogg`; Kenney — Impact Sounds: `Audio/impactPunch_medium_002.ogg` | SFX | -9 | 0.85–0.95 | 60 ms / 2 / 2 | player.oof (-6 dB, +30 ms) |
| `status.bleed` | Bleed | main.gd:7239–7240 | **keep** | Original drip + cloth 0.75 | `bleed` → Original (existing repo file) | SFX | -4 | 0.95–1.05 | 80 ms / 2 / 2 | — |
| `status.petrify` | Petrify (Gargoyle) | main.gd:7395–7396 | **replace** | Stone grind + latch (replaces latch+cloth) | `status_petrify` → Kenney — Impact Sounds: `Audio/impactMining_001.ogg` ×0.8 pitch | SFX | -8 | 0.95–1.02 | 0 ms / 1 / 2 | util.net (-6 dB, +0 ms) |
| `status.poison` | Poison mark applied | main.gd:8180, 8214–8230 | **replace** | Bubbling blips (replaces error) + click2 | `status_poison` → sfxgen.py `status_poison` | SFX | -9 | 0.95–1.05 | 0 ms / 1 / 2 | — |
| `status.hypnotize` | Hypnotize / Pocketwatch | main.gd:8360, combat_stage.gd:149 | **new** | Tick-tock + woozy vibrato swirl | `status_hypnotize` → sfxgen.py `status_hypnotize` | SFX | -10 | 0.98–1.02 | 0 ms / 1 / 2 | — |
| `status.silence` | (layer) silence | — | **new** | Muffled bell | `status_silence` → Kenney — Impact Sounds: `Audio/impactBell_heavy_004.ogg` ×1.1 pitch | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `mon.cube_ask` | Cube asks feed | main.gd:7420–7421 | **keep** | Question + cloth | `question` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `mon.cube_feed` | Feed Cube | main.gd:7539–7540 | **replace** | Gelatinous gulp + glass 0.8 | `mon_cube_gulp` → Kenney — Impact Sounds: `Audio/impactSoft_medium_003.ogg` ×0.6 pitch | SFX | -8 | 0.90–1.00 | 0 ms / 1 / 2 | — |
| `mon.cube_gulp` | (layer) gulp | — | **new** | Gulp | `mon_cube_gulp` → Kenney — Impact Sounds: `Audio/impactSoft_medium_003.ogg` ×0.6 pitch | SFX | -8 | 0.90–1.05 | 0 ms / 2 / 1 | — |
| `mon.merchant_ask` | Merchant ask | main.gd:7444–7445 | **keep+** | Question + pluck + coin rattle | (existing calls stay; adds layers) → — | UI | -10 | 1.00 | 0 ms / 1 / 1 | loot.coins_small (-6 dB, +80 ms) |
| `mon.cleric_tax` | Cleric heal tax | main.gd:7002 | **replace** | Lower heal arpeggio (replaces pluck) | `heal_sparkle` → sfxgen.py `heal_sparkle` + Kenney — Impact Sounds: `Audio/impactGlass_light_001.ogg` ×1.2 pitch | SFX | -12 | 0.80–0.84 | 0 ms / 1 / 2 | — |
| `mon.cleric_refuse` | Cleric refuse | main.gd:7045 | **keep** | Error | `error` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `mon.cleric_yank` | Cleric yank light | main.gd:7080–7090 | **keep** | Whoosh + scratch + error | `whoosh` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 2 | — |
| `mon.vampire_grow` | Vampire grows | main.gd:6248 | **keep** | Pluck 0.7 (now 120 ms cooldown) | `pluck` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 0.70 | 120 ms / 1 / 1 | — |
| `mon.damsel` | Damsel neighbours resolve | main.gd:6612–6614 | **keep** | Pluck 1.35 + bong 1.5 + open 1.2 | `pluck` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.35 | 0 ms / 1 / 2 | — |
| `mon.leech_pulse` | Leech pulse (repeats) | main.gd:6671–6672 | **replace** | Wet suction pulse, pitch climbs per repeat (code passes pitch); bong kept quiet | `mon_leech_pulse` → sfxgen.py `mon_leech_pulse` | SFX | -10 | 0.98–1.02 | 90 ms / 2 / 1 | — |
| `mon.berserker_rage` | Berserker hits 8 Atk | main.gd:6720–6722 | **keep** | error_big + chop + whoosh | `error_big` → Kenney Interface Sounds (existing repo file) | SFX | -8 | 1.00 | 0 ms / 1 / 2 | — |
| `mon.berserker_cool` | Berserker cools from 8 | main.gd:6724–6726 | **keep** | Glass + cloth + pluck | `glass` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `mon.clockwork_spawn` | Clockwork heirs spawn | main.gd:7578–7579 | **replace** | Clockwork click + drop + latch | `mon_clockwork` → Kenney — RPG Audio: `Audio/metalClick.ogg` | SFX | -8 | 0.95–1.05 | 60 ms / 2 / 2 | draft.drop (+0 dB, +40 ms) |
| `mon.commander_flee` | Commander flees | main.gd:6544–6545 | **replace** | Three fast scurrying steps + whoosh + door | `cabin_step_1`, `cabin_step_2`, `cabin_step_3`, `cabin_step_4` → Kenney — Impact Sounds: `Audio/footstep_wood_000.ogg`; Kenney — Impact Sounds: `Audio/footstep_wood_001.ogg`; Kenney — Impact Sounds: `Audio/footstep_wood_002.ogg`; Kenney — Impact Sounds: `Audio/footstep_wood_003.ogg` | SFX | -10 | 1.20–1.35 | 0 ms / 3 / 2 | draft.courier (-2 dB, +200 ms) |
| `mon.cleave_immune` | Cleave extra target immune | main.gd:8047 | **keep** | Glass | `glass` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.00 | 60 ms / 2 / 1 | — |
| `mon.harpy_poke` | Harpy interrupt Attack | main.gd:7317 | **keep** | Uses player.hurt / player.blocked; chain-limited by their cooldowns | `whoosh` → Kenney Interface Sounds (existing repo file) | SFX | -14 | 1.20–1.30 | 120 ms / 1 / 1 | — |
| `mon.hornet_buzz` | Hornet second swing | _swing / Done (Hornet) | **new** | Angry buzz before the 2nd swing | `mon_hornet_buzz` → sfxgen.py `mon_hornet_buzz` | SFX | -12 | 0.95–1.10 | 0 ms / 1 / 2 | — |
| `mon.hurt_weak` | Monster HP drops (Weak) | main.gd:7878–7879 | **replace** | Light punch, pitched up a touch | `atk_hit_light_1`, `atk_hit_light_2`, `atk_hit_light_3` → Kenney — Impact Sounds: `Audio/impactPunch_medium_000.ogg`; Kenney — Impact Sounds: `Audio/impactPunch_medium_001.ogg`; Kenney — Impact Sounds: `Audio/impactPunch_medium_002.ogg` | SFX | -9 | 1.02–1.12 | 40 ms / 3 / 2 | — |
| `mon.hurt_tough` | Monster HP drops (Tough) | main.gd:7878–7879 | **replace** | Heavy punch | `atk_hit_heavy_1`, `atk_hit_heavy_2` → Kenney — Impact Sounds: `Audio/impactPunch_heavy_000.ogg`; Kenney — Impact Sounds: `Audio/impactPunch_heavy_001.ogg` | SFX | -9 | 0.95–1.05 | 40 ms / 3 / 2 | — |
| `mon.hurt_deadly` | Monster HP drops (Deadly) | main.gd:7878–7879 | **replace** | Heavy punch + low armour clank | `mon_hurt_deadly` → Kenney — Impact Sounds: `Audio/impactMetal_heavy_000.ogg` ×0.85 pitch | SFX | -9 | 0.90–1.00 | 40 ms / 2 / 2 | mon.hurt_tough (-2 dB, +0 ms) |
| `mon.slay_chord` | (layer) existing slay chord | main.gd:4678–4680 | **keep** | bong + whoosh + scratch | `bong` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.00 | 0 ms / 2 / 2 | — |
| `mon.death_weak` | Monster slain (Weak) | main.gd:4678–4680 | **replace** | Soft body thud + slay chord + small coin clink | `mon_death_weak` → Kenney — Impact Sounds: `Audio/impactSoft_heavy_000.ogg` | SFX | -8 | 1.00–1.10 | 0 ms / 2 / 2 | mon.slay_chord (+0 dB, +0 ms), loot.coins_small (-6 dB, +150 ms) |
| `mon.death_tough` | Monster slain (Tough) | main.gd:4678–4680 | **replace** | Heavy wood thud + slay chord + coins | `mon_death_tough` → Kenney — Impact Sounds: `Audio/impactWood_heavy_001.ogg` ×0.85 pitch | SFX | -7 | 0.95–1.02 | 0 ms / 2 / 2 | mon.slay_chord (+0 dB, +0 ms), loot.coins (-8 dB, +160 ms) |
| `mon.death_deadly` | Monster slain (Deadly) | main.gd:4678–4680 | **replace** | Deep bell toll + slay chord + big coin spill; music → combat | `mon_death_deadly` → Kenney — Impact Sounds: `Audio/impactBell_heavy_003.ogg` ×0.7 pitch | SFX | -6 | 0.95–1.00 | 0 ms / 1 / 3 | mon.slay_chord (+0 dB, +0 ms), loot.coins (-4 dB, +200 ms) · music→combat |
| `mon.neighbor_kill` | Neighbour kill (Crossbow/Longbow) | main.gd:8471–8473 | **replace** | Same as mon.death_<tier of victim> | `mon_death_weak` → Kenney — Impact Sounds: `Audio/impactSoft_heavy_000.ogg` | SFX | -8 | 1.00 | 60 ms / 2 / 2 | — |
| `trophy.tick` | Trophy count ticks up | main.gd:10575–10576 | **keep** | Bong 0.85 + pluck 1.35 | `bong` → Kenney Interface Sounds (existing repo file) | UI | -12 | 0.85 | 80 ms / 1 / 1 | — |
| `loot.coins` | (layer) coin handful | — | **new** | Kenney handleCoins | `loot_coins` → Kenney — RPG Audio: `Audio/handleCoins.ogg` | SFX | -10 | 0.95–1.08 | 120 ms / 1 / 1 | — |
| `loot.coins_small` | (layer) coin clink | — | **new** | Kenney handleCoins2 | `loot_coins_small` → Kenney — RPG Audio: `Audio/handleCoins2.ogg` | SFX | -10 | 0.95–1.10 | 80 ms / 2 / 1 | — |
| `sting.deadly` | Deadly first shown (per-boss pitch via sfx-map) | main.gd:4491 / 4532 | **new** | Low orchestral hit, falling | `sting_deadly` → Kenney — Music Jingles: `Audio/Hit jingles/jingles_HIT06.ogg` | Stings | -6 | 1.00 | 2000 ms / 1 / 3 | — · duck -8 dB |
| `sting.bucket` | Bucket reveal opens | bucket_reveal.gd:233–234 | **new** | Rising whole-tone pizzicato run | `sting_bucket` → Kenney — Music Jingles: `Audio/Pizzicato jingles/jingles_PIZZI02.ogg` | Stings | -8 | 1.00 | 0 ms / 1 / 3 | — · duck -6 dB |
| `sting.victory` | Run victory | main.gd:4876–4884 | **new** | Bright pizzicato run up (sneaky-triumphant) | `sting_victory` → Kenney — Music Jingles: `Audio/Pizzicato jingles/jingles_PIZZI10.ogg` | Stings | -5 | 1.00 | 0 ms / 1 / 3 | — · duck -30 dB |
| `sting.clear` | Dungeon cleared | main.gd:1677–1679 | **new** | Pizzicato cadence | `sting_clear` → Kenney — Music Jingles: `Audio/Pizzicato jingles/jingles_PIZZI15.ogg` | Stings | -6 | 1.00 | 0 ms / 1 / 3 | — · duck -12 dB |
| `sting.defeat` | Player dies | main.gd:4886–4887 | **new** | Sad sax descending (the joke) | `sting_defeat` → Kenney — Music Jingles: `Audio/Sax jingles/jingles_SAX01.ogg` | Stings | -5 | 1.00 | 0 ms / 1 / 3 | — · duck -30 dB |
| `bucket.open` | Bucket overlay opens | bucket_reveal.gd:233–234 | **keep+** | Bong 0.72 + whoosh 0.85 kept; + card-pack tear + bucket sting | (existing calls stay; adds layers) → — | SFX | -8 | 1.00 | 0 ms / 1 / 3 | bucket.pack (+0 dB, +0 ms), sting.bucket (+0 dB, +120 ms) |
| `bucket.pack` | (layer) card pack tear | — | **new** | Kenney card pack open | `bucket_open` → Kenney — Casino Audio: `Audio/cards-pack-open-1.ogg` | SFX | -8 | 1.00 | 0 ms / 1 / 2 | — |
| `bucket.card_pop` | Each shadow card pops | bucket_reveal.gd:254 | **replace** | Card placed (replaces drop) | `card_place_1`, `card_place_2`, `card_place_3` → Kenney — Casino Audio: `Audio/card-place-1.ogg`; Kenney — Casino Audio: `Audio/card-place-2.ogg`; Kenney — Casino Audio: `Audio/card-place-3.ogg` | SFX | -10 | 0.90–1.06 | 50 ms / 3 / 1 | — |
| `bucket.ready` | Ready to continue | bucket_reveal.gd:257, 264 | **keep** | confirm_big / confirm | `confirm_big` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 2 | — |
| `bucket.card_hover` | Hover a revealed card | bucket_reveal.gd:348–351 | **replace** | Card slide + hover (replaces pluck+whoosh+hover stack) | `card_slide` → Kenney — Casino Audio: `Audio/card-slide-1.ogg` | UI | -16 | 1.00–1.10 | 90 ms / 1 / 0 | — |
| `tut.continue` | Tutorial Continue / Next | main.gd:11082 | **keep** | Click | `click` → Kenney Interface Sounds (existing repo file) | UI | -12 | 1.00 | 0 ms / 1 / 1 | — |
| `tut.skip` | Tutorial Skip | main.gd:11087 | **new** | Back blip | `ui_back` → Kenney — Interface Sounds: `Audio/back_002.ogg` | UI | -12 | 1.00 | 0 ms / 1 / 1 | — |
| `speech.nib` | Each Nib sentence | tutorial_guide.gd:242 (advance) | **new** | Goblin gibberish blips, 1 per ~3 visible chars (or 3–6 burst per line if no typewriter) | `nib_blip_01`, `nib_blip_02`, `nib_blip_03`, `nib_blip_04`, `nib_blip_05`, `nib_blip_06`, `nib_blip_07`, `nib_blip_08` → sfxgen.py `nib_blip_01`; sfxgen.py `nib_blip_02`; sfxgen.py `nib_blip_03`; sfxgen.py `nib_blip_04`; sfxgen.py `nib_blip_05`; sfxgen.py `nib_blip_06`; sfxgen.py `nib_blip_07`; sfxgen.py `nib_blip_08` | UI | -12 | 0.94–1.12 | 55 ms / 1 / 1 | — |
| `tut.nudge` | Nudge ('Not that one') | main.gd:5366 | **keep** | Error (+ one Nib blip) | `error` → Kenney Interface Sounds (existing repo file) | UI | -12 | 1.00 | 0 ms / 1 / 1 | — |
| `tut.d2_seat` | Dungeon-2 seat | main.gd:11183–11184 | **keep** | Door open + whoosh | `door_open` → Kenney RPG Audio (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `cabin.open` | Cabin UI opens | home_cabin.gd:113 (from main.gd:1718) | **keep+** | Cloth; music crossfades to cabin bed (1.5 s) | (existing calls stay; adds layers) → — | SFX | -12 | 1.00 | 0 ms / 1 / 1 | — · music→cabin |
| `cabin.pan` | Camera pan to cabin | home_cabin.gd:396 | **keep** | Whoosh 0.9 | `whoosh` → Kenney Interface Sounds (existing repo file) | SFX | -12 | 0.90 | 0 ms / 1 / 1 | — |
| `cabin.step` | Goblin walks (per footfall frame) | home_cabin.gd:450 (_walk_hero) | **new** | Small wooden footsteps, alternating, light (tiny goblin) | `cabin_step_1`, `cabin_step_2`, `cabin_step_3`, `cabin_step_4` → Kenney — Impact Sounds: `Audio/footstep_wood_000.ogg`; Kenney — Impact Sounds: `Audio/footstep_wood_001.ogg`; Kenney — Impact Sounds: `Audio/footstep_wood_002.ogg`; Kenney — Impact Sounds: `Audio/footstep_wood_003.ogg` | Ambience | -12 | 1.10–1.25 | 120 ms / 2 / 1 | — |
| `cabin.door` | Door opens (arrive / click) | home_cabin.gd:405, 542 | **keep** | Door open | `door_open` → Kenney RPG Audio (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `cabin.sack` | Sack drop | home_cabin.gd:470 (_play_drop) | **new** | Leather sack thump + coin jingle | `cabin_sack` → Kenney — RPG Audio: `Audio/dropLeather.ogg` + Kenney — RPG Audio: `Audio/handleCoins2.ogg` ×0.95 pitch | SFX | -6 | 0.95–1.00 | 0 ms / 1 / 2 | — |
| `cabin.sit` | Sit in chair | home_cabin.gd:484 (_play_sit) | **new** | Wood thump + chair creak | `cabin_sit` → Kenney — Impact Sounds: `Audio/impactWood_medium_000.ogg` ×0.9 pitch + Kenney — RPG Audio: `Audio/creak3.ogg` | SFX | -9 | 0.95–1.02 | 0 ms / 1 / 1 | — |
| `cabin.rock` | Chair rock (once per rock cycle) | home_cabin.gd:445, 553 | **new** | Soft low creaks, alternate fwd/back | `cabin_rock_1`, `cabin_rock_2`, `cabin_rock_3` → Kenney — RPG Audio: `Audio/creak1.ogg` ×0.9 pitch; Kenney — RPG Audio: `Audio/creak2.ogg` ×0.9 pitch; Kenney — RPG Audio: `Audio/creak3.ogg` ×0.9 pitch | Ambience | -18 | 0.92–1.00 | 600 ms / 1 / 0 | — |
| `cabin.fire_start` | Fire start | home_cabin.gd:528 | **replace** | Low 'whoomp' (pitched-down poof) instead of confirm; starts fire loop fade-in 1.5 s | `smoke_poof` → sfxgen.py `smoke_poof` | SFX | -14 | 0.55–0.60 | 0 ms / 1 / 1 | — |
| `amb.fire` | Fire loop / crackle | home_cabin.gd:526 (_fire.play('burn')) | **new** | Wood-burning fireplace loop (12 s, crossfaded) | `cabin_fire_loop` → Fireplace Sound loop: `fire.wav` | Ambience | -10 | 1.00 | 0 ms / 1 / 1 | — · LOOP |
| `cabin.trophy` | Trophy placed / burst | home_cabin.gd:718 (_play_burst) | **new** | Wooden shelf knock + sparkle; + coins | `cabin_trophy` → Kenney — Impact Sounds: `Audio/impactPlank_medium_002.ogg` ×1.1 pitch + sfxgen.py `cabin_glint` | SFX | -8 | 0.97–1.05 | 120 ms / 2 / 2 | loot.coins_small (-6 dB, +60 ms) |
| `cabin.glint` | Plaque glint | home_cabin.gd:742 | **new** | Tiny high 'ting' | `cabin_glint` → sfxgen.py `cabin_glint` | UI | -18 | 0.95–1.10 | 400 ms / 1 / 0 | — |
| `cabin.cat` | Cat idle (random, ≥ 8 s apart) | home_cabin.gd:802 (_tick_cat) | **new** | Soft mew / mew-purr | `cabin_cat_mew`, `cabin_cat_mewpurr` → Cat Purr & Meow: `cat_mewpurr.wav`; Cat Purr & Meow: `cat_softmew.wav` | Ambience | -12 | 0.95–1.05 | 8000 ms / 1 / 1 | — |
| `amb.cat_purr` | Cat purr loop (while cat sleeps / goblin sits) | home_cabin.gd:802 | **new** | Sleepy purr loop | `cabin_cat_purr_loop` → Cat Purr & Meow: `cat_purrsleepy_loop.wav` | Ambience | -18 | 1.00 | 0 ms / 1 / 0 | — · LOOP |
| `cabin.close` | Close cabin | main.gd:1743 | **keep+** | Ambience loops fade 0.8 s; music → title | (existing calls stay; adds layers) → — | SFX | -14 | 1.00 | 0 ms / 1 / 1 | — · music→title |
| `run.hall_wipe` | Hall wipe between fights | main.gd:1896–1897 | **keep** | Door open + whoosh | `door_open` → Kenney RPG Audio (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `run.knight_off` | Knight walks off | main.gd:1925 | **keep+** | Cloth kept; + 4 light steps | (existing calls stay; adds layers) → — | SFX | -12 | 1.00 | 0 ms / 1 / 1 | cabin.step (+0 dB, +0 ms) |
| `run.dungeon_clear` | Dungeon cleared | main.gd:1677–1679 | **replace** | confirm_big + sting.clear; music returns to title | `confirm_big` → Kenney Interface Sounds (existing repo file) | UI | -8 | 1.00 | 0 ms / 1 / 3 | sting.clear (+0 dB, +80 ms) · music→title |
| `run.victory` | Victory (incl. Adventure death after ≥1 clear) | main.gd:4876–4884 | **replace** | confirm_big + victory sting + coins | `confirm_big` → Kenney Interface Sounds (existing repo file) | UI | -8 | 1.00 | 0 ms / 1 / 3 | sting.victory (+0 dB, +60 ms), loot.coins (-4 dB, +400 ms) · music→title_after_sting |
| `run.defeat` | Player dies | main.gd:4886–4887 | **replace** | error_big + sad sax; music ducks to silence then title returns after 3 s | `error_big` → Kenney Interface Sounds (existing repo file) | UI | -8 | 1.00 | 0 ms / 1 / 3 | sting.defeat (+0 dB, +150 ms) · music→title_after_sting |
| `run.leave` | Leave run → cabin | main.gd:1711 | **keep** | Whoosh | `whoosh` → Kenney Interface Sounds (existing repo file) | SFX | -10 | 1.00 | 0 ms / 1 / 1 | — |
| `editor.*` | Roster / Script / Dev Test (editor only) | roster_editor.gd 286–2063, script_editor.gd 145–273, main.gd 1273–1498 | **keep** | Untouched; not in web build | `click` → Kenney Interface Sounds (existing repo file) | UI | -10 | 1.00 | 0 ms / 1 / 0 | — |

---

## 8. Sourcing (verified 2026-10-17)

Every pack page was fetched and its licence read on the page (OpenGameArt "License(s)" field; Kenney `License.txt` inside each zip states "Creative Commons Zero, CC0"). Freesound was not used: its downloads need a logged-in account, and everything needed was available from Kenney/OGA or could be synthesized.

| Source | Licence (verified) | Page | Direct download used |
|---|---|---|---|
| Kenney — Interface Sounds | CC0 1.0 (License.txt) | https://kenney.nl/assets/interface-sounds | https://kenney.nl/media/pages/assets/interface-sounds/fa43c1dd4d-1677589452/kenney_interface-sounds.zip |
| Kenney — RPG Audio | CC0 1.0 | https://kenney.nl/assets/rpg-audio | https://kenney.nl/media/pages/assets/rpg-audio/8e99002d76-1677590336/kenney_rpg-audio.zip |
| Kenney — Impact Sounds | CC0 1.0 | https://kenney.nl/assets/impact-sounds | https://kenney.nl/media/pages/assets/impact-sounds/87b4ddecda-1677589768/kenney_impact-sounds.zip |
| Kenney — Casino Audio | CC0 1.0 | https://kenney.nl/assets/casino-audio | https://kenney.nl/media/pages/assets/casino-audio/2472606a04-1721639069/kenney_casino-audio.zip |
| Kenney — Music Jingles | CC0 1.0 | https://kenney.nl/assets/music-jingles | https://kenney.nl/media/pages/assets/music-jingles/f37e530b9e-1677590399/kenney_music-jingles.zip |
| Kenney — UI Audio (auditioned, unused) | CC0 1.0 | https://kenney.nl/assets/ui-audio | https://kenney.nl/media/pages/assets/ui-audio/490d233f68-1677590494/kenney_ui-audio.zip |
| Kenney — Digital Audio (auditioned, rejected: too sci-fi) | CC0 1.0 | https://kenney.nl/assets/digital-audio | https://kenney.nl/media/pages/assets/digital-audio/216eac4753-1677590265/kenney_digital-audio.zip |
| "RPG Battle Loop" — iamoneabe | CC0 | https://opengameart.org/content/rpg-battle-loop | https://opengameart.org/sites/default/files/rbl_0.mp3 |
| "Dungeon Deep" — Eldritch Grim | CC0 | https://opengameart.org/content/dungeon-deep-0 | https://opengameart.org/sites/default/files/dungeon_deep.mp3 |
| "A Small Fire Will Do (Calming Loop)" — Trex0n | CC0 (credit appreciated) | https://opengameart.org/content/a-small-fire-will-do-calming-loop | https://opengameart.org/sites/default/files/a_small_fire_will_do.wav |
| "Fireplace Sound loop" — PagDev | CC0 | https://opengameart.org/content/fireplace-sound-loop | https://opengameart.org/sites/default/files/fire.wav |
| "Cat Purr & Meow" — Kerzoven | CC0 | https://opengameart.org/content/cat-purr-meow | https://opengameart.org/sites/default/files/cat_softmew.wav, …/cat_mewpurr.wav, …/cat_purrsleepy_loop.wav |
| "Dungeon Ambience" — yd (existing `music.ogg`) | CC0 | https://opengameart.org/content/dungeon-ambience | https://opengameart.org/sites/default/files/dungeon002_0.ogg |
| Swipe sfxgen (self-generated) | CC0 (original) | `tools/audio/sfxgen.py` | — |

`tools/audio/fetch_sources.sh` re-downloads all of the above; `tools/audio/build_audio.py` rebuilds every new asset from them; `tools/audio/sfxgen.py` regenerates the synthesized ones; `tools/audio/cues.py` regenerates this cue table and `data/sfx-map.json`.

**Synthesized (no good CC0 match, or needed exact control):** wheel ticks ×3 + detent (wooden ratchet: noise exciter into two wood resonators), Nib blips ×8 and monster blips ×4 (pulse wave with pitch glide through two vowel formants — gibberish, no words), player "hrk" ×2, soft UI hover ×2, smoke poof (falling band-passed noise + pop), heal arpeggio (C6-E6-G6 bells), poison bubbles, hypnotize tick-tock swirl, plaque glint, leech pulse, hornet buzz, magnet zing.

## 9. Asset list (new in this pass)

| File | Kind | Length | Size | Source |
|---|---|---|---|---|
| `ui_hover_soft_a.ogg` | ui | 0.04 s | 3.9 KB | sfxgen `ui_hover_soft_a` |
| `ui_hover_soft_b.ogg` | ui | 0.04 s | 3.9 KB | sfxgen `ui_hover_soft_b` |
| `ui_tick.ogg` | ui | 0.02 s | 4.0 KB | Kenney — Interface Sounds `Audio/tick_002.ogg` |
| `ui_back.ogg` | ui | 0.07 s | 4.6 KB | Kenney — Interface Sounds `Audio/back_002.ogg` |
| `wheel_tick_a.ogg` | ui | 0.05 s | 4.1 KB | sfxgen `wheel_tick_a` |
| `wheel_tick_b.ogg` | ui | 0.04 s | 4.1 KB | sfxgen `wheel_tick_b` |
| `wheel_tick_c.ogg` | ui | 0.05 s | 4.1 KB | sfxgen `wheel_tick_c` |
| `wheel_detent.ogg` | sfx | 0.16 s | 4.4 KB | sfxgen `wheel_detent` |
| `wheel_land_weak.ogg` | sfx | 0.26 s | 4.7 KB | Kenney — Impact Sounds `Audio/impactWood_light_002.ogg` |
| `wheel_land_tough.ogg` | sfx | 0.48 s | 6.8 KB | Kenney — Impact Sounds `Audio/impactPlank_medium_001.ogg` |
| `wheel_land_deadly.ogg` | sfx | 1.60 s | 8.8 KB | Kenney — Impact Sounds `Audio/impactBell_heavy_001.ogg` ×0.8 |
| `atk_hit_light_1.ogg` | sfx | 0.28 s | 5.9 KB | Kenney — Impact Sounds `Audio/impactPunch_medium_000.ogg` |
| `atk_hit_light_2.ogg` | sfx | 0.29 s | 6.0 KB | Kenney — Impact Sounds `Audio/impactPunch_medium_001.ogg` |
| `atk_hit_light_3.ogg` | sfx | 0.36 s | 6.7 KB | Kenney — Impact Sounds `Audio/impactPunch_medium_002.ogg` |
| `atk_hit_heavy_1.ogg` | sfx | 0.56 s | 7.8 KB | Kenney — Impact Sounds `Audio/impactPunch_heavy_000.ogg` |
| `atk_hit_heavy_2.ogg` | sfx | 0.46 s | 7.2 KB | Kenney — Impact Sounds `Audio/impactPunch_heavy_001.ogg` |
| `atk_slash.ogg` | sfx | 0.39 s | 7.5 KB | Kenney — RPG Audio `Audio/knifeSlice.ogg` |
| `blk_gain_1.ogg` | sfx | 0.49 s | 7.4 KB | Kenney — Impact Sounds `Audio/impactPlate_light_000.ogg` |
| `blk_gain_2.ogg` | sfx | 0.59 s | 8.3 KB | Kenney — Impact Sounds `Audio/impactPlate_light_001.ogg` |
| `blk_gain_big.ogg` | sfx | 0.49 s | 7.3 KB | Kenney — Impact Sounds `Audio/impactPlate_heavy_000.ogg` |
| `heal_sparkle.ogg` | sfx | 0.60 s | 5.8 KB | sfxgen `heal_sparkle` + Kenney — Impact Sounds `Audio/impactGlass_light_001.ogg` ×1.2 |
| `defeat_slash.ogg` | sfx | 0.47 s | 8.3 KB | Kenney — RPG Audio `Audio/knifeSlice2.ogg` |
| `smoke_poof.ogg` | sfx | 0.53 s | 8.0 KB | sfxgen `smoke_poof` |
| `echo_bell.ogg` | sfx | 0.69 s | 7.4 KB | Kenney — Impact Sounds `Audio/impactBell_heavy_002.ogg` ×1.25 |
| `chaos_warble.ogg` | sting | 1.14 s | 11.2 KB | Kenney — Music Jingles `Audio/Pizzicato jingles/jingles_PIZZI03.ogg` |
| `egg_crack.ogg` | sfx | 0.25 s | 5.1 KB | Kenney — Impact Sounds `Audio/impactGlass_light_003.ogg` ×0.75 + Kenney — Impact Sounds `Audio/impactSoft_medium_001.ogg` ×0.8 |
| `egg_squelch.ogg` | sfx | 0.75 s | 5.1 KB | Kenney — Impact Sounds `Audio/impactSoft_heavy_002.ogg` ×0.7 |
| `util_magnet.ogg` | sfx | 0.35 s | 6.8 KB | sfxgen `util_magnet` |
| `mon_hurt_deadly.ogg` | sfx | 0.18 s | 4.6 KB | Kenney — Impact Sounds `Audio/impactMetal_heavy_000.ogg` ×0.85 |
| `mon_death_weak.ogg` | sfx | 0.51 s | 4.7 KB | Kenney — Impact Sounds `Audio/impactSoft_heavy_000.ogg` |
| `mon_death_tough.ogg` | sfx | 0.34 s | 4.5 KB | Kenney — Impact Sounds `Audio/impactWood_heavy_001.ogg` ×0.85 |
| `mon_death_deadly.ogg` | sfx | 0.86 s | 7.2 KB | Kenney — Impact Sounds `Audio/impactBell_heavy_003.ogg` ×0.7 |
| `loot_coins.ogg` | sfx | 0.72 s | 12.1 KB | Kenney — RPG Audio `Audio/handleCoins.ogg` |
| `loot_coins_small.ogg` | sfx | 0.30 s | 7.8 KB | Kenney — RPG Audio `Audio/handleCoins2.ogg` |
| `player_oof_a.ogg` | sfx | 0.12 s | 4.8 KB | sfxgen `gob_oof_a` |
| `player_oof_b.ogg` | sfx | 0.12 s | 4.9 KB | sfxgen `gob_oof_b` |
| `status_petrify.ogg` | sfx | 0.83 s | 8.1 KB | Kenney — Impact Sounds `Audio/impactMining_001.ogg` ×0.8 |
| `status_poison.ogg` | sfx | 0.57 s | 5.1 KB | sfxgen `status_poison` |
| `status_hypnotize.ogg` | sfx | 1.08 s | 6.4 KB | sfxgen `status_hypnotize` |
| `status_silence.ogg` | sfx | 0.25 s | 4.2 KB | Kenney — Impact Sounds `Audio/impactBell_heavy_004.ogg` ×1.1 |
| `mon_leech_pulse.ogg` | sfx | 0.28 s | 5.8 KB | sfxgen `mon_leech_pulse` |
| `mon_hornet_buzz.ogg` | sfx | 0.49 s | 10.6 KB | sfxgen `mon_hornet_buzz` |
| `mon_cube_gulp.ogg` | sfx | 0.21 s | 4.2 KB | Kenney — Impact Sounds `Audio/impactSoft_medium_003.ogg` ×0.6 |
| `mon_clockwork.ogg` | sfx | 0.37 s | 7.2 KB | Kenney — RPG Audio `Audio/metalClick.ogg` |
| `nib_blip_01.ogg` | ui | 0.07 s | 4.5 KB | sfxgen `nib_blip_01` |
| `nib_blip_02.ogg` | ui | 0.07 s | 4.5 KB | sfxgen `nib_blip_02` |
| `nib_blip_03.ogg` | ui | 0.07 s | 4.5 KB | sfxgen `nib_blip_03` |
| `nib_blip_04.ogg` | ui | 0.07 s | 4.5 KB | sfxgen `nib_blip_04` |
| `nib_blip_05.ogg` | ui | 0.07 s | 4.4 KB | sfxgen `nib_blip_05` |
| `nib_blip_06.ogg` | ui | 0.07 s | 4.4 KB | sfxgen `nib_blip_06` |
| `nib_blip_07.ogg` | ui | 0.07 s | 4.5 KB | sfxgen `nib_blip_07` |
| `nib_blip_08.ogg` | ui | 0.07 s | 4.4 KB | sfxgen `nib_blip_08` |
| `monster_blip_01.ogg` | ui | 0.10 s | 5.1 KB | sfxgen `monster_blip_01` |
| `monster_blip_02.ogg` | ui | 0.10 s | 5.1 KB | sfxgen `monster_blip_02` |
| `monster_blip_03.ogg` | ui | 0.10 s | 4.7 KB | sfxgen `monster_blip_03` |
| `monster_blip_04.ogg` | ui | 0.10 s | 5.1 KB | sfxgen `monster_blip_04` |
| `bucket_open.ogg` | sfx | 0.94 s | 12.1 KB | Kenney — Casino Audio `Audio/cards-pack-open-1.ogg` |
| `card_place_1.ogg` | sfx | 0.69 s | 9.0 KB | Kenney — Casino Audio `Audio/card-place-1.ogg` |
| `card_place_2.ogg` | sfx | 0.45 s | 7.7 KB | Kenney — Casino Audio `Audio/card-place-2.ogg` |
| `card_place_3.ogg` | sfx | 0.88 s | 10.9 KB | Kenney — Casino Audio `Audio/card-place-3.ogg` |
| `card_slide.ogg` | ui | 0.60 s | 8.2 KB | Kenney — Casino Audio `Audio/card-slide-1.ogg` |
| `card_shove.ogg` | sfx | 0.77 s | 10.4 KB | Kenney — Casino Audio `Audio/card-shove-1.ogg` |
| `cabin_step_1.ogg` | amb | 0.25 s | 4.3 KB | Kenney — Impact Sounds `Audio/footstep_wood_000.ogg` |
| `cabin_step_2.ogg` | amb | 0.25 s | 4.2 KB | Kenney — Impact Sounds `Audio/footstep_wood_001.ogg` |
| `cabin_step_3.ogg` | amb | 0.25 s | 4.2 KB | Kenney — Impact Sounds `Audio/footstep_wood_002.ogg` |
| `cabin_step_4.ogg` | amb | 0.25 s | 4.4 KB | Kenney — Impact Sounds `Audio/footstep_wood_003.ogg` |
| `cabin_sack.ogg` | sfx | 0.35 s | 7.5 KB | Kenney — RPG Audio `Audio/dropLeather.ogg` + Kenney — RPG Audio `Audio/handleCoins2.ogg` ×0.95 |
| `cabin_sit.ogg` | sfx | 0.35 s | 6.4 KB | Kenney — Impact Sounds `Audio/impactWood_medium_000.ogg` ×0.9 + Kenney — RPG Audio `Audio/creak3.ogg` |
| `cabin_rock_1.ogg` | amb | 0.65 s | 7.9 KB | Kenney — RPG Audio `Audio/creak1.ogg` ×0.9 |
| `cabin_rock_2.ogg` | amb | 0.84 s | 8.5 KB | Kenney — RPG Audio `Audio/creak2.ogg` ×0.9 |
| `cabin_rock_3.ogg` | amb | 0.33 s | 5.7 KB | Kenney — RPG Audio `Audio/creak3.ogg` ×0.9 |
| `cabin_trophy.ogg` | sfx | 0.40 s | 5.9 KB | Kenney — Impact Sounds `Audio/impactPlank_medium_002.ogg` ×1.1 + sfxgen `cabin_glint` |
| `cabin_glint.ogg` | ui | 0.35 s | 4.6 KB | sfxgen `cabin_glint` |
| `cabin_cat_mew.ogg` | amb | 1.92 s | 20.1 KB | Cat Purr & Meow `cat_softmew.wav` |
| `cabin_cat_mewpurr.ogg` | amb | 1.39 s | 16.5 KB | Cat Purr & Meow `cat_mewpurr.wav` |
| `cabin_cat_purr_loop.ogg` | amb | 4.80 s | 42.5 KB | Cat Purr & Meow `cat_purrsleepy_loop.wav` |
| `cabin_fire_loop.ogg` | amb | 12.00 s | 123.6 KB | Fireplace Sound loop `fire.wav` |
| `sting_deadly.ogg` | sting | 0.47 s | 8.1 KB | Kenney — Music Jingles `Audio/Hit jingles/jingles_HIT06.ogg` |
| `sting_bucket.ogg` | sting | 0.95 s | 11.0 KB | Kenney — Music Jingles `Audio/Pizzicato jingles/jingles_PIZZI02.ogg` |
| `sting_victory.ogg` | sting | 0.80 s | 9.6 KB | Kenney — Music Jingles `Audio/Pizzicato jingles/jingles_PIZZI10.ogg` |
| `sting_clear.ogg` | sting | 0.80 s | 9.3 KB | Kenney — Music Jingles `Audio/Pizzicato jingles/jingles_PIZZI15.ogg` |
| `sting_defeat.ogg` | sting | 0.83 s | 11.4 KB | Kenney — Music Jingles `Audio/Sax jingles/jingles_SAX01.ogg` |
| `music_combat.ogg` | music | 59.08 s | 619.1 KB | RPG Battle Loop `rbl_0.mp3` |
| `music_deadly.ogg` | music | 25.90 s | 231.6 KB | Dungeon Deep `dungeon_deep.mp3` |
| `music_cabin.ogg` | music | 64.00 s | 498.9 KB | A Small Fire Will Do (Calming Loop) `a_small_fire_will_do.wav` |

**85 new files, 2.01 MB.** Existing assets 1.90 MB → **total ≈ 3.91 MB** (budget ≤ 6 MB). Nothing existing was deleted or overwritten except `CREDITS.txt`, which is a superset of the old ledger (merge, keep any extra lines).

## 10. Risks, open questions, next pass

* **Licences:** all sources CC0; no CC-BY obligations. Trex0n asks (not requires) credit "Cal McEachern" — done in CREDITS.txt. Kenney packs are CC0 by their bundled License.txt. No NC/ND/unclear material anywhere.
* **Not verified by ear:** this pass was produced on a headless box; picks were made from duration, loudness, pitch-contour, key/tempo analysis and loop-seam measurements. Nathan should listen to: `music_combat` (style fit), `music_deadly` (fit for bosses), `sting_defeat` (sax may read as too goofy), the synthesized Nib blips (personality), and `wheel_tick_*` at speed.
* **Card / special ids** in `lookup.card_id` / `lookup.special_id` are best guesses from the audit; Cursor must verify them against `data/catalog.json` and `MONSTER_SPECIAL` (`main.gd:126–160`).
* **Combat bed wrap:** RBL wasn't built with a sample-exact loop; 4 ms edge fades hide the wrap but listen once. If it bothers, swap to "Infinite Darkness" (HydroGene, CC0, seamless by the author) at ~1.6 MB.
* **Pass 2 ideas:** per-boss leitmotif stings; a quiet "deadly layer" stem instead of a separate bed; the music-box cabin alternative; proper per-character typewriter in `tutorial_guide.gd` if it doesn't exist.
