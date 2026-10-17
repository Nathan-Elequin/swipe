# Swipe audio director

Audited 2026-10-17. This is the single handoff for a sound designer: what exists, every player-facing moment that can take a sound, buses, platforms, data, and where to plug a central system.

Game name in Godot: **Swipe**. Engine: Godot **4.7.2**. One play scene: `res://scenes/main.tscn`. Friends play the itch web build; this repo is the source.

License ledger (keep updated when you replace files): `assets/audio/CREDITS.txt`. Pack-level credit also in `CREDITS.md`. Older bed/SFX notes (not this inventory): `design/CREATIVE-UX-PACK.md` §6.

Do not implement from this file until Nathan asks. Cue **ids** in `scripts/audio_fx.gd` are the bind list — replace files in place or add ids; do not scatter new `AudioStreamPlayer` nodes into combat scripts.

---

## 1. Current audio

### 1.1 Files

All shipped audio is in `assets/audio/`. There is **no** `music_combat.ogg` on disk. Code still looks for it. Total size **1.90 MB**.

Loudness on WAVs is **unweighted RMS dBFS** and **peak dBFS** from PCM (not ITU-R BS.1770 LUFS). OGG PCM was not decoded in this audit.

| Path | Format | Length | Rate | Layout | RMS | Peak | Credit |
|---|---|---|---|---|---|---|---|
| `assets/audio/bleed.wav` | WAV 16-bit | 0.420 s | 44100 | mono | −18.0 | −7.0 | Original drip. `CREDITS.txt` |
| `assets/audio/bong.wav` | WAV 16-bit | 0.132 s | 44100 | mono | −16.6 | −0.9 | Kenney Interface |
| `assets/audio/click.wav` | WAV 16-bit | 0.019 s | 44100 | mono | −18.8 | −1.4 | Kenney Interface |
| `assets/audio/click2.wav` | WAV 16-bit | 0.019 s | 44100 | mono | −15.7 | −1.2 | Kenney Interface |
| `assets/audio/confirm.wav` | WAV 16-bit | 0.562 s | 44100 | mono | −15.1 | −1.0 | Kenney Interface |
| `assets/audio/confirm_big.wav` | WAV 16-bit | 0.501 s | 44100 | mono | −11.9 | −0.9 | Kenney Interface |
| `assets/audio/drop.wav` | WAV 16-bit | 0.202 s | 44100 | **stereo** | −20.1 | −1.1 | Kenney Interface |
| `assets/audio/error.wav` | WAV 16-bit | 0.556 s | 44100 | **stereo** | −20.2 | −0.5 | Kenney Interface |
| `assets/audio/error_big.wav` | WAV 16-bit | 0.139 s | 44100 | mono | −20.6 | −1.0 | Kenney Interface |
| `assets/audio/glass.wav` | WAV 16-bit | 0.126 s | 44100 | mono | −16.4 | −1.0 | Kenney Interface / RPG |
| `assets/audio/hover.wav` | WAV 16-bit | 0.023 s | 44100 | mono | −17.2 | −1.2 | Kenney Interface |
| `assets/audio/land.wav` | WAV 16-bit | 0.431 s | 44100 | mono | −15.3 | −0.9 | Kenney Interface |
| `assets/audio/open.wav` | WAV 16-bit | 0.316 s | 44100 | mono | −16.4 | −0.9 | Kenney Interface |
| `assets/audio/pluck.wav` | WAV 16-bit | 0.112 s | 44100 | **stereo** | −21.0 | 0.0 | Kenney Interface |
| `assets/audio/question.wav` | WAV 16-bit | 0.338 s | 44100 | mono | −10.1 | −0.9 | Kenney Interface |
| `assets/audio/scratch.wav` | WAV 16-bit | 0.125 s | 44100 | mono | −18.1 | −1.0 | Kenney Interface |
| `assets/audio/select.wav` | WAV 16-bit | 0.385 s | 44100 | mono | −19.3 | −0.7 | Kenney Interface |
| `assets/audio/switch.wav` | WAV 16-bit | 0.504 s | 44100 | **stereo** | −15.3 | −0.9 | Kenney Interface |
| `assets/audio/whoosh.wav` | WAV 16-bit | 0.528 s | 44100 | mono | −16.6 | −0.9 | Kenney Interface |
| `assets/audio/block.ogg` | Ogg Vorbis ~160 kbps | 0.446 s | **48000** | stereo | — | — | Kenney RPG Audio |
| `assets/audio/block_heavy.ogg` | Ogg Vorbis ~160 kbps | 1.461 s | 48000 | stereo | — | — | Kenney RPG Audio |
| `assets/audio/book.ogg` | Ogg Vorbis ~160 kbps | 0.154 s | 48000 | stereo | — | — | Kenney RPG Audio |
| `assets/audio/chop.ogg` | Ogg Vorbis ~160 kbps | 0.240 s | 48000 | stereo | — | — | Kenney RPG Audio |
| `assets/audio/cloth.ogg` | Ogg Vorbis ~160 kbps | 0.415 s | 48000 | stereo | — | — | Kenney RPG Audio |
| `assets/audio/creak.ogg` | Ogg Vorbis ~160 kbps | 0.661 s | 48000 | stereo | — | — | Kenney RPG Audio |
| `assets/audio/door_close.ogg` | Ogg Vorbis ~160 kbps | 0.675 s | 48000 | stereo | — | — | Kenney RPG Audio |
| `assets/audio/door_open.ogg` | Ogg Vorbis ~160 kbps | 0.919 s | 48000 | stereo | — | — | Kenney RPG Audio |
| `assets/audio/door_slam.ogg` | Ogg Vorbis ~160 kbps | 0.603 s | 48000 | stereo | — | — | Kenney RPG `doorClose_4` |
| `assets/audio/draw.ogg` | Ogg Vorbis ~160 kbps | 0.400 s | 48000 | stereo | — | — | Kenney RPG Audio |
| `assets/audio/hit.ogg` | Ogg Vorbis ~160 kbps | 0.600 s | 48000 | stereo | — | — | Kenney RPG Audio |
| `assets/audio/metal_latch.ogg` | Ogg Vorbis ~160 kbps | 0.261 s | 48000 | stereo | — | — | Kenney RPG extras |
| `assets/audio/music.ogg` | Ogg Vorbis ~64 kbps | **206.0 s** | 44100 | stereo | — | — | yd Dungeon Ambience, OpenGameArt, CC0 |

Credit is pack-level, not per filename, except `door_slam`, `metal_latch`, `bleed`, and `music`. WAV import uses Godot `compress/mode=2` (IMA-ADPCM `.sample`), `edit/loop_mode=0`. Example: `assets/audio/click.wav.import`.

Missing file still referenced: `res://assets/audio/music_combat.ogg` in `scripts/audio_fx.gd` lines 70–72. `assets/audio/CREDITS.txt` and `design/ART-TODO.md` record that it was never dropped in. Spin/fight ducks the yd bed **−2.5 dB** instead.

### 1.2 Bind list (`scripts/audio_fx.gd` `setup()`, lines 36–66)

| Id | File |
|---|---|
| `click` | `click.wav` |
| `click2` | `click2.wav` |
| `hover` | `hover.wav` |
| `select` | `select.wav` |
| `confirm` | `confirm.wav` |
| `confirm_big` | `confirm_big.wav` |
| `error` | `error.wav` |
| `error_big` | `error_big.wav` |
| `drop` | `drop.wav` |
| `open` | `open.wav` |
| `whoosh` | `whoosh.wav` |
| `land` | `land.wav` |
| `switch` | `switch.wav` |
| `scratch` | `scratch.wav` |
| `pluck` | `pluck.wav` |
| `bong` | `bong.wav` |
| `question` | `question.wav` |
| `glass` | `glass.wav` |
| `bleed` | `bleed.wav` |
| `hit` | `hit.ogg` |
| `chop` | `chop.ogg` |
| `block` | `block.ogg` |
| `block_heavy` | `block_heavy.ogg` |
| `draw` | `draw.ogg` |
| `cloth` | `cloth.ogg` |
| `door_open` | `door_open.ogg` |
| `door_close` | `door_close.ogg` |
| `door_slam` | `door_slam.ogg` |
| `metal_latch` | `metal_latch.ogg` |
| `creak` | `creak.ogg` |
| `book` | `book.ogg` |

`hit`, `block`, `draw`, and `bleed` **are used** (combat helpers). They are not dead binds.

### 1.3 AudioStreamPlayer / 2D nodes

**Zero** `AudioStreamPlayer` or `AudioStreamPlayer2D` nodes in any `.tscn`. `scenes/main.tscn` is a single `Main` Control.

Players are created in `scripts/audio_fx.gd`:

| Object | Created | Bus | Count |
|---|---|---|---|
| `music` | `setup()` line 27 | `Music` | 1 |
| `_pool[]` | `setup()` lines 31–35 | `SFX` | **8** round-robin `AudioStreamPlayer`s |

`sfx` is a child of `Main`, not an autoload. Instantiated at `scripts/main.gd` 997–999. Passed into Settings, Home Cabin, and Bucket Reveal.

### 1.4 Scripts that play sound

| Script | Role |
|---|---|
| `scripts/audio_fx.gd` | Bind ids, pool, music, buses, save |
| `scripts/main.gd` | Almost all gameplay cues |
| `scripts/settings_menu.gd` | Volume sliders, pause buttons |
| `scripts/home_cabin.gd` | Cabin enter / door / fire-start |
| `scripts/bucket_reveal.gd` | Bucket unlock overlay |
| `scripts/roster_editor.gd` | Editor only (hidden on web) |
| `scripts/script_editor.gd` | Editor only |

Scripts with **no** `sfx.play`: `boss_wheel.gd`, `combat_stage.gd`, `draft_gate.gd`, `item_card.gd`, `tutorial_guide.gd`, `speech_bubble.gd`, `content_editor.gd`, `challenge_draft.gd`, `dungeon_deck.gd`, `hover_panel.gd`. Those fire visuals or signals; `main.gd` (or the caller) plays the sound.

**Overlap:** `play()` always uses the next of 8 voices (`audio_fx.gd` 99–107). The same cue **can** overlap itself if two calls land on different pool slots before the first clip ends. A 9th overlapping play **steals** the oldest slot (cuts it). `hover()` debounce is 90 ms (`audio_fx.gd` 110–115). Pitch is clamped 0.7–1.4.

`play(id, db, pitch)` default db is **−6**. Call sites pass their own db. The 8 dB extra on the music player (`MUSIC_GAIN_DB`) is separate from SFX db.

---

## 2. Audio setup

### 2.1 `default_bus_layout.tres` (entire file)

```
bus/0 Master  volume_db 0  send ""
bus/1 Music   volume_db 0  send Master
bus/2 SFX     volume_db 0  send Master
```

No effects, no compressors, no UI bus, no Ambience bus. `audio_fx.gd` `_ensure_bus` (78–84) will add Music/SFX at runtime if missing; it does not add UI or Ambience.

### 2.2 Volume / settings

Escape overlay `scripts/settings_menu.gd`:

- Sliders Master / Music / SFX (lines 69–71, 154–170)
- Linear 0–1, saved to `user://audio.json` (`audio_fx.gd` 4, 198–221)
- Defaults: master 1.0, music **0.85**, sfx 1.0
- Bus mute at lin ≤ 0.001
- Dragging SFX plays `click` at −10 dB (222–234)
- Pause also has Resume / Quit (Quit hidden on web, line 88) / start-over modes
- `get_tree().paused = true` while open; `sfx` uses `PROCESS_MODE_ALWAYS` so sliders still tick

Music player extra gain: `MUSIC_GAIN_DB := 8.0` (`audio_fx.gd` 5). Combat duck: `COMBAT_DUCK_DB := -2.5` (line 6).

### 2.3 Autoload / manager

`project.godot` autoloads **only** `MCPGameBridge` (editor MCP). There is **no** audio autoload. `AudioFx` is a Node class used as `sfx` on Main.

### 2.4 Music loop and crossfade

- Title/draft bed: `music.ogg`, loop set in code (`audio_fx.gd` 67–69) and on the imported stream (`loop: true`).
- `start_music()` (118–131): snap to title bed, volume `MUSIC_GAIN_DB`, play if not already playing. **No crossfade.**
- `set_combat_music(true)` (134–144): **would** swap stream to `music_combat.ogg` and `music.play()` from the start. File missing, so it falls through to `duck_music(-2.5)` over 0.35 s (147–153). That is a volume tween, not a stream crossfade.
- `set_combat_music(false)`: unduck, or would swap back if combat bed existed.
- `stop_music()` (156–160): 0.5 s fade to −40 dB then stop. **Never called** from gameplay scripts.

Combat music on: `_on_spin` `main.gd:4484`. Combat music off: dungeon clear 1677, after fight (Challenge) 2802, player down 4881, clear after fight 4932, flee 7964, restore snapshot 5271.

Web: Godot HTML5 needs a user gesture to unlock AudioContext. `start_music()` runs from `_ready` (`main.gd` 481–482), so the bed may stay silent until the first click (title button / anywhere).

---

## 3. Player-facing events

**Can overlap:** Yes = the 8-voice pool will stack this cue with itself if retriggered before it ends. Hover is the only internally rate-limited cue.

### Title / pause / overlay UI

| Event | Sound now | Cue (db, pitch) | Function | File:line | How often | Overlap |
|---|---|---|---|---|---|---|
| Game boot, music start | music bed | `start_music` | `_ready` | `main.gd:482` | once per boot | n/a (single music player) |
| Title hover (How to Play / Dive In / Adventure / Challenge / Home) | **none** | — | `_title_pill` widgets | `main.gd:1068–1073` | per hover | — |
| Title click How to Play | book + door_open | −10 / −8 | `_start_tutorial` | `main.gd:11068–11069` | once | yes (two one-shots) |
| Title click Dive In (Challenge quick-start) | confirm + door_open | −10 / −12 | `_quick_start` | `main.gd:1966–1967` | once | yes |
| Title click Adventure Mode | confirm_big via reset | −8 | `_begin_run` → `_reset_run` | `main.gd:1646`, `1582` | once | no |
| Title click Challenge Mode | confirm_big via reset | −8 | `_begin_adventure` → `_reset_run` | `main.gd:1657`, `1582` | once | no |
| Title click Home | cloth (cabin open) | −12 | `_open_home_from_title` → `open_cabin` | `main.gd:1718`, `home_cabin.gd:113` | once | no |
| Escape opens settings | open | −12 | `_unhandled_input` | `main.gd:3945–3947` | once per open | no |
| Settings slider Master/Music | **none** (level only) | — | `_on_slider` | `settings_menu.gd:222–230` | continuous while drag | — |
| Settings slider SFX | click | −10 | `_on_slider` | `settings_menu.gd:234` | every slider tick | yes, rapid |
| Settings Resume | click | −8 | `_on_resume` | `settings_menu.gd:239` | once | no |
| Settings start-over mode | confirm | −8 | `_pick` | `settings_menu.gd:245` | once | no |
| Settings Roster/Script (editor) | book | −10 | `_on_roster` / `_on_script` | `settings_menu.gd:252`, `259` | once | no |
| Settings hover | **none** | — | buttons have no `mouse_entered` sfx | `settings_menu.gd:173–201` | — | — |
| Settings back (Esc) | **none** | — | `close_menu` | `settings_menu.gd:216–219` | once | — |
| Overlay Undo button | error if illegal; else whoosh+click2 | see Undo | `_on_undo` | `main.gd:5282` | per click | — |
| Combat log toggle | switch | −14 | `_toggle_log` | `main.gd:8954` | per toggle | no |
| Inspect (Shift / hover panel) | **none** (hover on card/slice is separate) | — | `hover_panel.gd` | no sfx | — | — |

### Draft / draft gate (Adventure mill)

Wheel: 8 seats. 4 cardinal starters, then petitioners until `starter_count + 4`. 3 refusals (`REFUSALS_MAX`). No draft reroll; leaving is refuse.

| Event | Sound now | Cue | Function | File:line | How often | Overlap |
|---|---|---|---|---|---|---|
| Starters seated N/E/S/W | drop, pitched up per seat | −10, 0.92+ | `_seat_night_watch` | `main.gd:3125` | 4 times, 0.22 s apart | yes |
| Starter items granted | cloth + confirm | −10 / −14 | `_grant_starter_kit` | `main.gd:3232–3233` | once | yes |
| Petitioner / offer shown | creak + question | −12 / −10 | `_open_petitioner` | `main.gd:3253–3254` | once per offer | yes |
| Mystery relic shown (gate UI) | **none extra** (offer sfx above) | — | `draft_gate.present_mystery` | `draft_gate.gd:261` | once | — |
| Take (Send through gate) | metal_latch + door_slam + whoosh, then door_open + bong | −6 / −4 0.92 / −12 1.08 then −8 1.05 / −10 0.9 | `_on_gate_send` | `main.gd:3289–3301` | once per take | yes (chord) |
| Leave / refuse | scratch + switch | −10 / −14 0.85 | `_on_gate_refuse` | `main.gd:3328–3329` | once per leave | yes |
| Out of refusals, auto-fill rest | creak; then slam+latch or door_open | mixed | `_auto_fill_rest` | `main.gd:3355–3373` | once | yes |
| Courier flies relic to wheel | whoosh | −10, 1.1 | `_fly_courier` | `main.gd:3403` | once per seat | no |
| Seat fail (no empty) | error | −14 | `_seat_petitioner` | `main.gd:3421` | rare | no |
| Mill finished, wheel ready | door_close + confirm_big | −10 / −12 | `_finish_mill` | `main.gd:3275–3276` | once | yes |
| Next offer drawn | book | −10 | `_draw_offer` | `main.gd:3009`, `3027` | per offer | no |
| Draft reroll | **none** (no reroll) | — | — | — | — | — |
| Gate hover/click chrome | **none** in `draft_gate.gd` | — | signals to main | `draft_gate.gd` | — | — |
| Monster speech at gate | **none** | — | `speech_box.present` | `main.gd:10045` | per line | — |

### Challenge draft / dungeon setup

| Event | Sound now | Cue | Function | File:line | How often | Overlap |
|---|---|---|---|---|---|---|
| Seat 6 dungeon monsters | drop per seat, then cloth+whoosh | −10 pitched / −10 / −14 1.2 | `_challenge_seat_dungeon` | `main.gd:2470–2483` | 6 drops, rapid | **yes, stacked** |
| Opening pick-two shown | book + open | −10 / −14 | `_challenge_offer_pick` | `main.gd:2590–2591` | per pair | yes |
| Commit chosen item | confirm + cloth | −12 / −14 | `_challenge_commit_item` | `main.gd:2619–2620` | per take | yes |
| Discard one (forced) | confirm | −12 | `_challenge_discard_one` | `main.gd:2647` | per discard | no |
| Holes resolve / refill | open + bong, or drop + whoosh | mixed | `_challenge_resolve_holes` | `main.gd:2717–2758` | per collapse | yes |
| Begin play | confirm + door_open | −10 / −12 | `_challenge_begin_play` | `main.gd:2554–2555` | once | yes |
| After fight, combat music off | duck off | `set_combat_music(false)` | `_challenge_after_fight` | `main.gd:2802` | per fight | n/a |
| Click Spin with no target picked | error | −12 | `_on_spin` | `main.gd:4466` | per illegal click | no |

### Hand / hotbar

There is no separate “draw into hand” anim with `draw.ogg` except Defeat cards and Scythe. Adding a card uses **open / cloth / pluck / drop** depending on source.

| Event | Sound now | Cue | Function | File:line | How often | Overlap |
|---|---|---|---|---|---|---|
| Hover a hand card | hover (−18, 1.05, 90 ms cap) | `sfx.hover()` | `_on_item_hovered` | `main.gd:10983` | per card enter | limited |
| Select / click to use | select; then error if illegal | −10; errors −12 | `_use_item` | `main.gd:5369`, 5341–5366 | per click | select+error can stack |
| Petrified click | error + metal_latch | −10 / −14 | `_use_item` | `main.gd:5359–5360` | per click | yes |
| Choose-options prompt (Knife, Net, Magnet, Spiked Shield) | question | −10 | `_use_item` | `main.gd:5397` | once per prompt | no |
| Pick an option | click2 | −8 | `_choose_option` | `main.gd:5448`, `5468` | once | no |
| Play resolves | **by ops kind**, not by card color | see Combat | `_apply_ops` | `main.gd:5488+` | per play | yes |
| Discard / toss (spent) | pluck, or cloth+whoosh | −10 / −8 / −16 1.2 | `_toss_item` | `main.gd:5816–5821` | per discard | yes |
| Gain item into hand | open, or error+cloth if blocked | −10 / −10 / −12 | `_try_gain_item` | `main.gd:6497–6503` | per gain | yes |
| Chaos Stone: pick two | question then select/error | mixed | `_begin_chaos` `_chaos_pick` | `main.gd:5982–6016` | 2 picks | — |
| Chaos transform | whoosh + bong | −8 0.86 / −12 0.7 | `_finish_chaos` | `main.gd:6033–6034` | once | yes |
| Item upgrade visual | whoosh + pluck + confirm | −8 0.9 / −6 1.15 / −10 0.85 | `_play_item_transform` | `main.gd:6078–6080` | per upgrade | yes |
| Merchant upgrade fail | error | −10 | `_upgrade_item` | `main.gd:7498` | rare | no |

### Wheel

Spin is **1.2 s**, cubic ease, extra full turn (`boss_wheel.gd:444–467`). **No per-tick / per-segment click** during rotation. Empty seats, monsters, and place/bribe highlights share one spin sound.

| Event | Sound now | Cue | Function | File:line | How often | Overlap |
|---|---|---|---|---|---|---|
| Hover a slice | hover | `sfx.hover()` | `_on_slice_hovered` | `main.gd:4339` | per slice, 90 ms | limited |
| Click slice (select / place target) | select | −10 | `_on_slice_clicked` | `main.gd:4311` | per click | no |
| Place monster on empty | drop + confirm | −8 / −14 1.08 | `_commit_place` | `main.gd:4362–4363` | once | yes |
| Bribe / remove | scratch + creak | −8 / −12 | `_bribe_at` | `main.gd:4392–4393` | once | yes |
| Toggle place mode | switch | −12 | `_on_place_mode` | `main.gd:3859` | per toggle | no |
| Toggle bribe mode | switch | −12, 0.92 | `_on_bribe_mode` | `main.gd:3868` | per toggle | no |
| Spin **start** | combat duck on + door_open + whoosh | −10 / −12 0.9 | `_on_spin` | `main.gd:4484–4486` | once per spin | yes |
| Spin **ticks / segment pass** | **none** | — | `spin_to` tween | `boss_wheel.gd:461` | 1.2 s silent | — |
| Spin **land** (any living monster) | door_close + land + bong | −8 / −14 / −16 | `_on_spin` | `main.gd:4491–4493` | once | yes (chord) |
| Empty slice land | never spun (live pool only) | — | `_on_spin` 4436–4438 | if none live → dungeon clear | — | — |
| Weak vs Tough vs Deadly land | **same land chord** | — | not branched | — | — | — |
| Hover Spin button | **none** (preview only) | — | `_on_spin_hover` | `main.gd:9134` | — | — |
| Hover deck (Challenge peek) | hover | `sfx.hover()` | `_on_deck_hovered` | `main.gd:10521` | per enter | limited |
| ATK/HP number ticks | **none** | — | `play_atk_ticks` / `play_hp_ticks` | `boss_wheel.gd:723`, `741` | visual | — |

### Combat — player cards (by class / color)

There are **no crits and no misses**. 0-damage Attack still plays `glass`. Card color is visual (`ux_style.gd:316–336`); combat sound follows `ops.kind` in `_apply_ops`.

| Class / color | Typical ops | Sound now | Function | File:line | Rate | Overlap |
|---|---|---|---|---|---|---|
| Attack (`atk`, fill `#5c2626`) | `atk*` | After select: `hit`+`chop` on connect | `_apply_ops` / `_deal_atk_at` | `main.gd:5506`, `7878` | per successful hit | yes (Twins can double) |
| Attack fizzle / Goblin immune / 0 | glass −8 0.85 | `_deal_atk_at` | `main.gd:7829`, `7863` | per fizzle | no |
| Block (`blk`, `#1c3d52`) | `blk*` | `block` −8; if n≥4 also `block_heavy` −14 | `_gain_blk` | `main.gd:7201–7203` | per Block gain | yes if Twins even-double |
| Heal (`heal`, `#243a22`) | `heal_*` | `pluck` −8 | `_heal` | `main.gd:7217` | per heal that actually raises HP | no |
| Defeat (`defeat`, `#3a2450`) | `defeat_hp` / `defeat_atk` / `defeat_only_item` | `draw` −8 on success; error±latch on fail | `_apply_ops` | `main.gd:5708`, `5760`, `5781` | once | no |
| Utility (`utility`, `#4a3d14`) | Net, Quiet Bell, Magnet, Hook, Caltrops, Poison | Net: latch+scratch (`atk_drop` 5633); Quiet: cloth+pluck (5663); Caltrops: latch+scratch (5617); fail: error | `_apply_ops` | per use | — |
| Smoke (`smoke`, `#3a2a38`) | `smoke` | toss sfx only (no unique smoke) | `_apply_ops` 5585 | once | — |
| Chaos (`chaos`, `#3a1460`) | Echo Bell uses **copied** ops; Chaos Stone is reroll | Echo has **no unique sting** — it plays the copied card’s sounds. Empty Echo: error −10 (`atk_echo` 5511) | `_ops_of` / `_apply_ops` | `main.gd:5474` | per use | — |
| Egg (`egg`, `#070605`) | `egg_hurt` | same as taking Attack: chop+error or block_heavy chord | `_apply_egg_hurt` | `main.gd:4826–4841` | once | yes |
| Spider Egg laid | bleed + scratch + cloth (very low pitch) | `_lay_spider_egg` | `main.gd:6794–6796` | once per egg on Spin | yes |
| Queen eats eggs | bleed 0.55 + cloth | `_apply_queen_eggs_on_spin` | `main.gd:6761–6762` | once per Queen spin if eggs | yes |

### Combat — resolution, statuses, monster body

| Event | Sound now | Cue | Function | File:line | How often | Overlap |
|---|---|---|---|---|---|---|
| Click Done (legal) | click | −8 | `_on_done` | `main.gd:4636`, `4641` | once | no |
| Click Done illegal | error 1.2 | −12 | `_on_done` | `main.gd:4608–4620` | per click | no |
| Hover Done | hover | `sfx.hover()` | `_on_done_hover` | `main.gd:10195` | per enter | limited |
| Monster telegraph (Bodyguard redirect path) | whoosh −14, pitch +0.06 per step | `_telegraph_pass` | `main.gd:7809` | per seat in path, 0.14 s | **yes, rapid** |
| Monster lunge visual | **none** (lunge is visual) | — | `combat_stage.lunge` | `combat_stage.gd:136` | once per swing | — |
| Monster Attack hits you | chop + error | −6 / −18 0.8 | `_play_attack_connect` | `main.gd:4855–4856` | once per connecting swing | yes |
| Monster Attack fully blocked | block_heavy + bong + glass | −5 / −8 1.12 / −12 1.3 | `_play_attack_blocked` | `main.gd:4863–4865` | once | yes |
| Dragon pierce, 0 through Block | glass −10 | `_owner_attack` | `main.gd:4798` | once | no |
| Damage taken (Needleback poke etc.) | chop −8, or glass if 0 | `_player_take_atk` | `main.gd:7989`, `7996` | per poke | yes |
| Block absorbed (non-pierce 0 HP loss) | blocked chord above | `_owner_attack` else branch | `main.gd:4801` | once | — |
| Bleed (Grief Jar / purple HP loss) | bleed −4 + cloth −14 0.75 | `_bleed` | `main.gd:7239–7240` | per bleed event | no |
| Petrify (Gargoyle) | metal_latch + cloth | −8 / −12 | `_petrify_best_atk` | `main.gd:7395–7396` | once on Spin into Gargoyle | yes |
| Poison mark applied | error, then whoosh+click2 | `_apply_mark` | `main.gd:8180`, `8214–8230` | per mark | — |
| Hypnotize / Pocketwatch | **none** on the watch anim | — | `_apply_hypnotize` / `play_hypnotize` | `main.gd:8360`, `combat_stage.gd:149` | — | — |
| Silence (Quiet Bell) | cloth + pluck | see utility | `_apply_ops` `"quiet"` | `main.gd:5663` | once | yes |
| Cube asks feed | question + cloth | `_cube_ask_feed` | `main.gd:7420–7421` | once | yes |
| Feed Cube | cloth + glass 0.8 | `_feed_cube` | `main.gd:7539–7540` | once | yes |
| Merchant ask | question + pluck | `_merchant_ask` | `main.gd:7444–7445` | once | yes |
| Cleric heal tax | pluck; refuse error; yank whoosh+scratch+error | `_cleric_play` / `_cleric_refuse` / `_cleric_yank_light` | `main.gd:7002`, `7045`, `7080–7090` | once | — |
| Vampire grows | pluck −10 0.7 | `_grow_vampires` | `main.gd:6248` | per HP you lose | can stack with hit |
| Damsel neighbors resolve | pluck 1.35 + bong 1.5 + open 1.2 | `_damsel_resolve` | `main.gd:6612–6614` | once | yes |
| Leech pulse | pluck + bong, pitch climbs | `_leech_pulse` | `main.gd:6671–6672` | **repeats until HP tied** | **yes, rapid** |
| Berserker hits 8 Atk | error_big + chop + whoosh | `_step_berserkers` | `main.gd:6720–6722` | once per cycle to 8 | yes |
| Berserker cools from 8 | glass + cloth + pluck | `_step_berserkers` | `main.gd:6724–6726` | once | yes |
| Clockwork heirs spawn | drop + metal_latch | `_spawn_clockwork_heirs` | `main.gd:7578–7579` | once | yes |
| Commander flee | whoosh + door_open | `_try_commander_flee` | `main.gd:6544–6545` | once | yes |
| Cleave extra target immune | glass | `_apply_cleave` | `main.gd:8047` | per immune | yes |
| Monster hurt (HP actually drops) | hit 0.94–1.08 + chop −16 | `_deal_atk_at` | `main.gd:7878–7879` | per hit | **yes** |
| Monster death / slay | bong + whoosh + scratch | `_play_ended_visuals` | `main.gd:4678–4680` | once | yes |
| Neighbor kill (Crossbow/Longbow) | same slay chord | `_kill_neighbor` | `main.gd:8471–8473` | per extra death | yes |
| Trophy count ticks up | bong 0.85 + pluck 1.35 | `_refresh` | `main.gd:10575–10576` | once per new kill shown | yes |
| Harpy interrupt Attack | owner-attack sounds | `_harpy_poke` → `_owner_attack` | `main.gd:7317` | after **each** item | **yes, can chain** |
| Hornet second swing | owner-attack sounds twice | `_owner_attack` | via `_swing` / Done | twice | yes |
| Crit | **not a rule** | — | — | — | — | — |
| Miss | **not a rule**; 0 dmg = glass | — | — | — | — | — |

Monster **enter** = combat stage `show_monster` at `main.gd:4532` (**no extra sting** beyond the spin-land chord). Hurt visual `combat_stage.take_hit` (`combat_stage.gd:124`) is silent. Death visual `play_slay` is silent; audio is `_play_ended_visuals`.

Sounds are **not** split by Weak / Tough / Deadly or by boss id, except Berserker’s 8-Atk chord and the specials listed above.

### Boss phases / intros

There is no separate boss-intro scene and no phase music.

| Event | Sound now | Where |
|---|---|---|
| Deadly (tier 3) first shown | same spin land | `_on_spin` `main.gd:4491` |
| Slime Boss / Spider Queen / Dragon / Commander / Vampire / Damsel / Clockwork / Cowardly King / Leech | only their specials’ cues | tables above |
| Berserker “phase” 3→4→8 | unique sting at 8 and cooldown | `main.gd:6710` |

### Buckets / loot reveal

| Event | Sound now | Cue | Function | File:line | Rate | Overlap |
|---|---|---|---|---|---|---|
| Overlay opens | bong 0.72 + whoosh 0.85 | `play` | `bucket_reveal.gd:233–234` | once per new bucket | yes |
| Each shadow card pops | drop, random pitch 0.9–1.06 | `play` | `bucket_reveal.gd:254` | per card, staggered | **yes** |
| Ready to continue | confirm_big or confirm | `play` | `bucket_reveal.gd:257`, `264` | once | no |
| Hover a revealed card | pluck 1.15 + whoosh 1.25 + hover | `_on_card_enter` | `bucket_reveal.gd:348–351` | per hover | yes |

### Echo Bell

No dedicated cue. `echo_bell` copies last item’s `ops` (`main.gd:5474–5479`, `7274–7280`) and plays **that** card’s sounds. If nothing to copy / 0 Attack: `error` at `main.gd:5511`. Echo itself is discarded (`keep_after = false`, 5523–5524).

### Nib tutorial

`tutorial_guide.gd` has **no** `sfx` calls. Lines are text only.

| Event | Sound now | Function | File:line |
|---|---|---|---|
| Tutorial starts | book + door_open | `_start_tutorial` | `main.gd:11068` |
| Continue / Next beat | click −12 | `_tut_on_continue` | `main.gd:11082` |
| Skip | **none** extra | `_tut_skip` | `main.gd:11087` |
| Each Nib sentence | **none** | `advance` | `tutorial_guide.gd:242` |
| Nudge (“Not that one”) | error from `_use_item` | `main.gd:5366` | |
| Dungeon-2 seat | door_open + whoosh | `_tutorial_d2_seat` | `main.gd:11183–11184` |

### Home cabin

| Event | Sound now | Cue | Function | File:line | Rate | Overlap |
|---|---|---|---|---|---|---|
| Cabin UI opens | cloth | −12 | `open_cabin` | `home_cabin.gd:113` | once | no |
| Camera pan to cabin | whoosh 0.9 | `_play_arrive` | `home_cabin.gd:396` | once | no |
| Walk (footsteps) | **none** | — | `_walk_hero` | `home_cabin.gd:450` | looping anim | — |
| Door opens (arrive or click) | door_open −10 | `_play_arrive` 405; `_on_door` 542 | once | no |
| Sack drop | **none** (screen bump only) | `_play_drop` | `home_cabin.gd:470` | once | — |
| Sit in chair | **none** | `_play_sit` | `home_cabin.gd:484` | once | — |
| Rock loop | **none** | `_rock.play("rock")` | `home_cabin.gd:445`, `553` | looping visual | — |
| Fire start | confirm −12 (**one shot**, not a fire loop) | `_start_interior_loops` | `home_cabin.gd:528` | once | no |
| Fire loop / crackle | **none** | `_fire.play("burn")` | `home_cabin.gd:526` | looping visual | — |
| Trophy placed / burst | **none** | `_play_burst` | `home_cabin.gd:718` | per new swipe | — |
| Plaque glint | **none** | glint anim | `home_cabin.gd:742` | hover visual | — |
| Cat idle | **none** | `_tick_cat` | `home_cabin.gd:802` | — | — |
| Close cabin | then `start_music` if returning to title | `_on_home_cabin_closed` | `main.gd:1743` | once | — |

### Win / lose / run start / end

| Event | Sound now | Cue | Function | File:line |
|---|---|---|---|---|
| Run reset / new run | confirm_big + start_music | `_reset_run` | `main.gd:1582–1583` |
| Hall wipe between fights | door_open + whoosh | `_play_hall_wipe` | `main.gd:1896–1897` |
| Knight walks off | cloth | `_walk_knight_off` | `main.gd:1925` |
| Dungeon cleared (win overlay or rest) | confirm_big + duck −2 | `_enter_dungeon_clear` | `main.gd:1677–1679` |
| Player dies | error_big + duck −16 | `_player_down` | `main.gd:4886–4887` |
| Adventure death after ≥1 dungeon cleared | treated as victory: confirm_big | `_player_down` | `main.gd:4876–4884` |
| Leave run → cabin | whoosh | `_adventure_leave` | `main.gd:1711` |
| Undo | whoosh (pitch 0.72) + click2; illegal error | `_undo_play_fx` / `_on_undo` | `main.gd:5278`, `5298` |
| Redo | whoosh pitch 1.2 + click2 | `_undo_play_fx` | `main.gd:5278` |

### Editor only (not in the itch web build)

Roster / Script / Developer Test: book, open, click2, confirm, error, switch, question, door_close — `roster_editor.gd` 286–2063, `script_editor.gd` 145–273, `main.gd` 1273–1498. Friends never hear these. Do not spend unique assets here.

---

## 4. Game structure

### 4.1 Scenes and flow

Only **one** Godot scene: `scenes/main.tscn`. Everything else is Control nodes built in `_build_ui`.

```
title
  ├─ How to Play → tutorial (forced 3-fight kit) → title/victory
  ├─ Adventure Mode (_begin_run) → draft mill (8-slot wheel) → ready → spin/fight loop → victory | defeat
  ├─ Challenge Mode / Dive In → bucket reveal → 6-seat dungeon + loot picks → fights → rest (next dungeon | Home | die)
  └─ Home → cabin overlay → back to title
```

Combat loop: `ready` → `_on_spin` (`spinning`, 1.2 s) → `fighting` (use items, click Done) → `slaying` → slice removed → `ready` again or `victory` / `defeat` / Challenge `rest`.

### 4.2 How long things last

| Beat | Duration |
|---|---|
| Wheel spin | **1.2 s** always (`boss_wheel.gd:461`). Ignores `ANIM_TIME_SCALE`. |
| Other anims | `ANIM_TIME_SCALE = 0.675` (`main.gd:48`) |
| Shortest fight | ~2–4 s (spin + Done, no items) |
| Typical fight | ~15–45 s player time; Harpy/Hornet/Leech longer |
| Adventure mill dungeon | 8 owners (4 starters + 4 drafted). Draft ~1–3 min + 8 fights. **~8–15 min** fluent |
| Challenge dungeon | 6 seats, deck refills. One dungeon **~5–12 min** |
| Music loop | 206 s, seamless if loop flag holds |
| Tutorial | Three fights (`tutorial_guide.gd:617`) |

### 4.3 Bosses

There is **no** `kind: "boss"` and no boss-only scene. **Deadly = tier 3.** Ids that read as bosses:

| Id | Name | Tier | ATK base | HP base |
|---|---|---|---|---|
| `slime_boss` | Slime Boss | 3 | = own HP | 9 |
| `spider_queen` | Spider Queen | 3 | 3 | 3 |
| `dragon` | Dragon | 3 | 6 | 6 |
| `commander` | Commander | 3 | 3 | 3 |
| `vampire` | Vampire | 3 | 5 | 5 |
| `two_headed_serpent` | Damsel In Distress | 3 | 0 | 9 |
| `leech_league` | Leech League | 3 | 4 | 1 |
| `clockwork_knight` | Clockwork Knight | 3 | 4 | 7 |
| `cowardly_king` | Cowardly King | 3 | 2 | 6 |

### 4.4 Monster families (all 35)

Tiers: **Weak = 1 (bronze `#c08050`)**, **Tough = 2 (silver)**, **Deadly = 3 (gold `#e8c36a`)** (`player_copy.gd:62–69`, `main.gd:2891–2896`).

**Weak:** `wizard` 5/2, `golem` 3/7, `goblin` 3/1, `skeleton` 3/3 (HP = last faced), `hornet_swarm` 2/3, `lich` 3/1, `hollow` (Twins) 6/6, `beggar` formula/4, `bodyguard` 3/3, `merchant` 4/4.

**Tough:** `ogre` 5/10, `berserker` 3/4 (Atk 3/4/8), `dire_wolf` = player HP / 4, `bandit` = item count / 3, `wraith` 3/3, `mimic` 5/6, `needleback` 3/5, `gelatinous_cube` 3/4, `gargoyle` 4/5, `harpy` 2/5, `kobold_trapper` 2/6, `basilisk` 4/5, `wick` 6/10, `anvil` 4/3, `juggernaut` 9/5, `cleric` 4/5.

**Deadly:** table in 4.3.

Full roster ids: `wizard`, `golem`, `goblin`, `skeleton`, `hornet_swarm`, `lich`, `ogre`, `vampire`, `berserker`, `dire_wolf`, `bandit`, `leech_league`, `wraith`, `mimic`, `two_headed_serpent`, `slime_boss`, `spider_queen`, `commander`, `dragon`, `needleback`, `gelatinous_cube`, `gargoyle`, `harpy`, `kobold_trapper`, `clockwork_knight`, `basilisk`, `hollow`, `beggar`, `wick`, `anvil`, `bodyguard`, `cowardly_king`, `merchant`, `juggernaut`, `cleric`.

### 4.5 Card classes and colours

Authorable fills (`scripts/ux_style.gd:292–336`):

| Id | Label | Fill | Family (`card_color_family`) |
|---|---|---|---|
| `atk` | Attack | `#5c2626` | ATK |
| `blk` | Block | `#1c3d52` | BLK |
| `heal` | Heal | `#243a22` | HEAL |
| `defeat` | Defeat | `#3a2450` | DEFEAT |
| `utility` | Utility | `#4a3d14` | ATK |
| `smoke` | Smoke | `#3a2a38` | SMOKE |
| `chaos` | Chaos | `#3a1460` | SKIP |
| `egg` | Egg | `#070605` | ATK |
| `auto` / empty | Auto | none | inferred from ops |

Live counts (catalog): atk 13, blk 9, defeat 5, utility 5, heal 4, chaos 2, smoke 1, egg 1, plus retired/hidden with blank color (`dagger`, `bandana`, `helmet_hidden`; `caltrops` color empty but ops `atk_zero`).

---

## 5. Constraints

| Item | Fact |
|---|---|
| Friend play | **Web** on itch: https://nathan-elequin.itch.io/swipe (`README.md`) |
| Export presets | **Only preset 0: Web** (`export_presets.cfg`). Path `build/web/index.html`. Filter `all_resources`, include `*.txt`, exclude `design/home/*`. Threads off. PWA off. |
| Desktop | Played in Godot editor (F5). **No Windows/Linux/macOS export preset.** |
| Mobile | **No** Android/iOS preset. Viewport 1680×1040, GL Compatibility. |
| Web audio | HTML5 Web Audio unlock. `start_music()` in `_ready` may be silent until first click. Prefer **OGG** for music; WAVs already import to `.sample`. Mixing 44.1 kHz WAVs with 48 kHz SFX OGGs is fine in Godot; keep new SFX 48 kHz stereo or 44.1 mono to match. |
| Autoplay | No click-to-unmute UI. Title click is the practical unlock. |
| Memory / size | **No written budget.** Current audio **1.90 MB**. Music is 1.15 MB of that. itch HTML5 zips the whole `build/web` folder; keep extra beds small (looping OGG 64–96 kbps stereo is the existing music pattern). |
| Editor-only audio | Roster/Script/Dev Test stripped from web. Don’t spend unique assets there. |

---

## 6. Data

| What | Path |
|---|---|
| Items + monsters (rules, ATK/HP, color, ops) | `data/catalog.json` (`items[]`, `monsters[]`) |
| Same cards, editor board | `data/content-board.json` (`items`, `monsters`) |
| Player-facing strings | `data/player-copy.json` / `.csv` |
| Runtime roster subset | `data/runtime.json` |
| Author locks | `data/author-locks.json` |
| Hardcoded ops fallback | `ITEM_OPS` `main.gd:71–124` |
| Hardcoded monster specials | `MONSTER_SPECIAL` `main.gd:126–160` |
| Art ids | `scripts/dungeon_art.gd` `ITEM_PNG` / `MONSTER_PNG` |

**No `sfx`, `sound`, or `audio` field exists on catalog cards.** `ops.kind` and `card_color` are the natural keys.

A designer could add keys without a schema fight — either a field on the card, or a side table `data/sfx-map.json` keyed by `card_id` / `ops.kind` / `special_id`. Suggested shape (not implemented):

```json
"sfx": {
  "use": "atk_light",
  "fail": "error",
  "enter": "land_deadly"
}
```

Fallback chain already implied by code: Echo copies ops → `ops.kind` match in `_apply_ops` → shared `_deal_atk_at` / `_gain_blk` / `_heal`.

---

## 7. Where to put a central audio system

**Keep and extend `scripts/audio_fx.gd`. Do not start a second manager.**

It already owns the pool, the Music player, bus volumes, and save. Every gameplay call is `sfx.play(id, db, pitch)`.

Do this, in order:

1. **Promote `AudioFx` to an autoload** named `Audio` (or keep it as Main’s child and pass it as today — autoload only matters if new overlays spawn before `_build_ui`). One instance. `PROCESS_MODE_ALWAYS` stays.
2. **Edit `default_bus_layout.tres`** to:
   - Master
   - Music → Master
   - SFX → Master (combat, wheel, cabin Foley)
   - UI → Master (hover, click, pause, tutorial continue)
   - Ambience → Master (cabin fire, dungeon bed if you split `music.ogg` into ambience + music)
3. **Route in `play()`** by optional bus argument or by id prefix (`ui.*` → UI bus). Default SFX so existing calls stay valid.
4. **Replace duck-as-combat with a real second loop** when `music_combat.ogg` exists; **crossfade 0.4–0.8 s** on two Music players (A/B) instead of `music.stream =` which restarts the bed (`set_combat_music` 138–142).
5. **Add a one-shot unlock** on first title click that calls `start_music()` again, for HTML5.
6. **Drive new combat variation from data** (`ops.kind` / `card_color` / `pack_tier` / `card_id`) inside `play()` or a thin `play_event("atk_hit", {tier=3, id="dragon"})` helper on `AudioFx`, not scattered new `AudioStreamPlayer`s in `boss_wheel.gd` / `combat_stage.gd`. Those nodes should emit or call the helper so spin ticks can be added later without touching combat math.
7. **Cabin fire / walk** belong on **Ambience** as looping streams with their own volume, not one-shot `confirm` (`home_cabin.gd:528`).

Pool size 8 is tight if you add spin ticks (could fire ~10–20/s). Either raise the pool to 16, or use a dedicated UI/tick player with a cooldown like `hover()`.

---

## Priority gaps (nothing here yet, or a stand-in that is the wrong object)

1. Spin ticks / segment pass (1.2 s of silence today).
2. Footsteps, sack drop, sit, chair rock, fire loop (cabin uses one `confirm` for fire).
3. Nib speech blip (tutorial lines are silent).
4. Card-class hits that match Attack / Block / Heal / Defeat instead of sharing `hit`+`chop`.
5. Deadly / boss enter sting (same land chord as Weak).
6. Echo Bell identity (plays the copied card only).
7. Title / settings hover.
8. Combat bed (`music_combat.ogg`) and a real crossfade.
9. HTML5 first-click unlock so the 206 s bed actually starts.

Credits are pack-level CC0. Replace files in place and update `assets/audio/CREDITS.txt`. Only `bleed.wav` is original to this repo.
