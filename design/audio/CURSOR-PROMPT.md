# Cursor prompt — Swipe audio pass 1

Paste everything below the line into Cursor (Agent mode) at the root of the Swipe repo.

---

You're implementing **audio pass 1** for Swipe (Godot 4.7.2, single scene `scenes/main.tscn`, web export on itch). A sound designer has already made every asset, the full spec, and a data map. Your job is to install them and wire them into the code. Work carefully and commit after each step.

## Ground rules

- **Never change player-facing text.** Don't edit existing strings in scenes, scripts, `data/player-copy.json` / `.csv`, or the tutorial lines. The only new text is the labels for two new volume sliders (step 4). Add them as new keys the same way existing slider labels are defined. Never show the word "Tier" to players. Internal names like `tier`, `weak`, `tough`, `deadly` are fine in code.
- **Keep `scripts/audio_fx.gd` as the only audio manager.** Don't add `AudioStreamPlayer` nodes to combat, wheel, or cabin scripts. Those scripts emit signals or call the `sfx` helper.
- **Existing calls stay valid.** `sfx.play(id, db, pitch)`, `sfx.hover()`, `start_music()`, `set_combat_music(on)`, `duck_music(db)`, and `stop_music()` keep their signatures. Leave any call site whose cue is marked **keep** alone.
- Line numbers below come from `design/audio/audio-director.md`-era code (the audit). They will drift as you edit, so find each spot by **function name + file** and confirm the old sound calls are there before changing them. Work **bottom-up inside a file** so the earlier line numbers stay valid.
- Don't touch editor-only audio (roster_editor, script_editor, Dev Test).
- Branch: `git checkout -b audio-pass-1`. Make one commit per step, with messages like `audio(1): …`.

## Step 0: unpack and read

1. Unzip the pack (`swipe-audio-pass.zip`, which Nathan will place in the repo root or tell you the path) into a temp dir, e.g. `python3 -c "import zipfile;zipfile.ZipFile('swipe-audio-pass.zip').extractall('/tmp/sap')"` (the `zip`/`unzip` binaries may be missing).
2. Read `/tmp/sap/design/audio/AUDIO-SPEC.md` in full, especially §2 buses, §3 voices, §4 wheel ticks, §5 music state machine, §6 sfx-map semantics, and §7 cue table. Then read `/tmp/sap/data/sfx-map.json`. Both are authoritative. When this prompt and the spec disagree on a value, the JSON wins.

## Step 1: install assets and data (commit `audio(1): add pass-1 assets, map, spec, tools`)

- Copy `/tmp/sap/assets/audio/*.ogg` into `assets/audio/`. **Don't overwrite existing files.** None of the new names collide, so if one does, stop and report it.
- `assets/audio/CREDITS.txt`: the new file is a superset ledger. Merge it with the existing one and keep any existing line it doesn't already cover. Also add a one-line pointer in `CREDITS.md` ("Audio pass 1: see assets/audio/CREDITS.txt").
- Copy `data/sfx-map.json`, `design/audio/AUDIO-SPEC.md`, `design/audio/CURSOR-PROMPT.md`, and `tools/audio/*` to the same paths in the repo. `tools/` must stay out of the web export: check `export_presets.cfg` and add `tools/*` to the exclude filter if needed. `data/*.json` must be included (the preset includes `all_resources` plus `*.txt`; add `*.json` to the include filter if `data/sfx-map.json` would otherwise be dropped, since it isn't a resource). Verify after the export in step 7.
- Run the Godot import (`godot --headless --import` or open the editor once) so `.import` files are generated.
- **Loop flags:** in the `.import` files (`[params]`) set `loop=true` and `loop_offset=0.0` for `music_combat.ogg`, `music_deadly.ogg`, `music_cabin.ogg`, `cabin_fire_loop.ogg`, and `cabin_cat_purr_loop.ogg`. Also set it in code when the stream loads (`stream.loop = true`), as `music.ogg` already does. Every other new `.ogg` has `loop=false`.

## Step 2: bus layout (commit `audio(2): bus layout`)

Rewrite `default_bus_layout.tres` per spec §2: Master (HardLimiter, ceiling −1 dB) → Music (slot 0 `AudioEffectAmplify`, the "Duck"), Stings, Ambience (LowPassFilter, cutoff 20000), SFX (Compressor, threshold −14, ratio 3, attack 5 ms, release 120 ms), and UI. All of them send to Master. Extend `_ensure_bus` in `audio_fx.gd` so all six exist at runtime even if the .tres is missing.

## Step 3: extend `scripts/audio_fx.gd` (commit `audio(3): AudioFx event system, pool 16, A/B music, unlock`)

Keep it as Main's child (`sfx`), as it is today. Only promote it to an autoload `Audio` if an overlay really needs it before `_build_ui`. If you do, keep `main.gd`'s `sfx` reference pointing at the same instance. `PROCESS_MODE_ALWAYS` stays.

Implement:
1. **Map loading:** read `res://data/sfx-map.json` in `setup()`. For each cue, preload its files (`path_prefix + name + ".ogg"`, falling back to `.wav`) into a `Dictionary[StringName, Array[AudioStream]]`. Also register every existing bind id so `play(id)` keeps working. `push_warning` on missing files and keep going.
2. **Pool 16** (was 8): each voice stores `{cue_id, priority, started_ms}`. Stealing follows spec §3: same-cue `max_voices` first, then the oldest voice with priority ≤ the new cue's, otherwise drop. Legacy `play()` = priority 1, bus by **id prefix** (`prefix_bus` in the map; plain legacy ids go to SFX, except `hover`, `click`, `click2`, `select`, `question`, `error`, `switch`, `confirm`, and `confirm_big`, which go to **UI**).
3. **`play_event(cue_id: StringName, ctx := {}) -> void`:** cooldown check, random file pick (no immediate repeat), `db = cue.db + ctx.get("db_offset", 0)`, `pitch = randf_range(cue.pitch) * ctx.get("pitch_mul", 1.0)`, clamped to 0.5–2.0. Then layers (each plays at *its own* cue db + `db_offset`, after `delay_ms`, using a `SceneTreeTimer` with `process_always = true`), `repeat` (count/interval), `duck_music`, `music` (state change, see 6), and `loop_start`. Allow `ctx.delay_ms` to delay the whole event.
4. **`resolve(event: StringName, ctx: Dictionary) -> StringName`:** walk `fallback_chain` over `lookup` (ops_kind keys ending in `*` match by prefix; numeric tier keys are strings) and return the first hit for `event`, otherwise `lookup.default[event]`. Add a tiny helper `tier_of(monster) -> int` that reads the pack tier the way `main.gd:2891–2896` does.
5. **Dedicated players:** a tick player (`max_polyphony = 3`) with `play_tick(speed01)` per `wheel_ticks` (35 ms min interval, pitch/db lerp by speed), and a speech player with `speak(kind: StringName, text: String, ctx := {})` per the `speech` rules (per-char if the caller reports reveal progress through `speak_progress(kind, visible_chars)`, otherwise a burst sized by text length, never repeating a file twice in a row, ducking Music −3 dB while speaking). Also two ambience loop players with `loop_start(cue_id, fade_s)`, `loop_stop(cue_id, fade_s)`, and `loop_stop_all(fade_s)` on the Ambience bus.
6. **Music A/B + state machine** (spec §5): `music_to(bed: StringName, fade_s: float)` does an equal-power crossfade between two players. `resume_position` beds remember their position. `gain_db` comes per bed from the map and **replaces `MUSIC_GAIN_DB`**; retire `COMBAT_DUCK_DB`. Ducking goes through the Music bus Amplify effect (`duck(db, attack, release_or_"hold")`, `unduck(release)`), never the slider. States: TITLE, COMBAT, BETWEEN (combat bed, Duck −4 dB), DEADLY, CABIN, VICTORY, DEFEAT. Remap the existing functions: `start_music()` → TITLE; `set_combat_music(true)` → COMBAT (or stay in DEADLY); `set_combat_music(false)` → BETWEEN; new `music_title()`, `music_deadly()`, `music_cabin()`, `music_victory()`, and `music_defeat()`. VICTORY/DEFEAT duck −30 dB, play their sting, then go to TITLE after 2.5 s / 3 s with a 2 s fade-in.
7. **Web first-click unlock:** in `_input`, on the first mouse/key/touch press set `_unlocked`. On web (`OS.has_feature("web")`), restart the current bed at its saved position and restart any active loops. Show no UI text.
8. **Pause:** add `on_pause(open: bool)`. On open, Duck −6 dB and lower the Ambience low-pass to 1200 Hz. On close, restore both over 0.3 s. Call it where the settings menu opens and closes.
9. **Save v2:** `user://audio.json` with keys `version, master, music, ambience, sfx, ui` (defaults 1.0 / 0.85 / 0.8 / 1.0 / 0.9). Load v1 files without errors. The Stings bus volume follows Music.

## Step 4: settings sliders (commit `audio(4): Ambience + UI sliders`)

In `scripts/settings_menu.gd`, add Ambience and UI sliders next to Master/Music/SFX, in the same style. Use new label keys and don't edit existing ones. Dragging SFX/UI/Ambience plays `ui.slider_tick` on that bus (70 ms cooldown). Master/Music play nothing. Add hover (`ui.hover_menu`) on the menu buttons and `ui.back` on close.

## Step 5: wire the cues (one commit per group: `audio(5a): title/ui`, `5b: draft+challenge`, `5c: hand+cards`, `5d: wheel+ticks`, `5e: combat+monsters+statuses`, `5f: buckets`, `5g: tutorial speech`, `5h: cabin`, `5i: run/music states`)

Every non-**keep** row of the spec §7 cue table, by call site. Build `ctx` with what's available: `card_id`, `ops_kind`, `card_color`, `tier`, `monster_id`, `dmg`, `pitch_mul`.

- **main.gd:1068–1073** — Title pill hover (How to Play / Dive In / Adventure / Challenge / Home) → `ui.hover_title` (new): add `play_event(&"ui.hover_title", ctx)`
- **settings_menu.gd:222–234** — Settings slider drag (SFX / UI / Ambience) → `ui.slider_tick` (replace): settings_menu.gd:222–234: replace the SFX-slider click with `ui.slider_tick` routed to the dragged bus (SFX/UI/Ambience); Master/Music silent
- **settings_menu.gd:173–201** — Settings button hover → `ui.hover_menu` (new): add `play_event(&"ui.hover_menu", ctx)`
- **settings_menu.gd:216–219** — Settings close (Esc / back) → `ui.back` (new): add `play_event(&"ui.back", ctx)`
- **main.gd:3125** — Starters seated N/E/S/W → `draft.seat_starter` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"draft.seat_starter", ctx)`
- **draft_gate.gd:261** — Mystery relic shown at gate → `draft.mystery` (new): add `play_event(&"draft.mystery", ctx)`
- **main.gd:3289–3301** — Take (send through gate) → `draft.take` (keep+): keep existing lines, add `play_event(&"draft.take")`
- **main.gd:10045** — Monster speech line (gate / any speech_box) → `speech.monster` (new): main.gd:10045 `speech_box.present`: `sfx.speak(&"monster", text, {tier=t, monster_id=id})`
- **main.gd:2470–2483** — Seat 6 dungeon monsters → `chal.seat_dungeon` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"chal.seat_dungeon", ctx)`
- **main.gd:2619–2620** — Commit chosen item → `chal.commit` (keep+): keep existing lines, add `play_event(&"chal.commit")`
- **main.gd:2647** — Discard one (forced) → `chal.discard` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"chal.discard", ctx)`
- **main.gd:5359–5360** — Click a petrified card → `hand.petrified` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"hand.petrified", ctx)`
- **main.gd:5816–5821** — Discard / toss spent card → `hand.toss` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"hand.toss", ctx)`
- **main.gd:6497–6503** — Gain item into hand → `hand.gain` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"hand.gain", ctx)`
- **main.gd:6033–6034** — Chaos transform → `chaos.transform` (keep+): keep existing lines, add `play_event(&"chaos.transform")`
- **main.gd:4392–4393** — Bribe / remove → `wheel.bribe` (keep+): keep existing lines, add `play_event(&"wheel.bribe")`
- **boss_wheel.gd:461 (spin_to tween)** — Segment passes pointer during 1.2 s spin → `wheel.tick` (new): see spec §4: new signal `segment_passed` in boss_wheel.gd, connect in main.gd → `sfx.play_tick(speed01)`
- **main.gd:9134** — Hover Spin button → `wheel.spin_hover` (new): add `play_event(&"wheel.spin_hover", ctx)`
- **boss_wheel.gd:723** — ATK number ticks → `wheel.num_tick_atk` (new): add `play_event(&"wheel.num_tick_atk", ctx)`
- **boss_wheel.gd:741** — HP number ticks → `wheel.num_tick_hp` (new): add `play_event(&"wheel.num_tick_hp", ctx)`
- **main.gd:4491–4493** — Spin lands on Weak monster → `wheel.land_weak` (replace): branch on the landed monster's tier: `play_event(resolve(&"enter", {tier=t}), {monster_id=id})`; remove the old door_close/land/bong lines (they are now the `wheel.land_chord` layer). Deadly: pitch_mul = deadly_sting_pitch[id]
- **main.gd:4491–4493** — Spin lands on Tough monster → `wheel.land_tough` (replace): (same branch as above)
- **main.gd:4491–4493, show_monster 4532** — Spin lands on Deadly monster → `wheel.land_deadly` (replace): (same branch as above; also music → deadly)
- **main.gd:7878 (_deal_atk_at), 5506** — Attack connects, dmg < 5 → `atk.hit_light` (replace): in `_deal_atk_at` replace hit+chop with `play_event(resolve(&"hit", ctx))` where ctx has card_id, ops_kind, card_color, dmg; dmg ≥ 5 → `hit_heavy`. Then ALSO play `mon.hurt_<tier>` for the target (see mon.hurt_*) at its own level
- **main.gd:7878** — Attack connects, dmg ≥ 5 → `atk.hit_heavy` (new): (branch inside the same call as atk.hit_light)
- **main.gd:7201** — Gain Block (n < 4) → `blk.gain` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"blk.gain", ctx)`
- **main.gd:7201–7203** — Gain Block (n ≥ 4) → `blk.gain_big` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"blk.gain_big", ctx)`
- **main.gd:7217** — Heal raises HP → `heal.gain` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"heal.gain", ctx)`
- **main.gd:5708, 5760, 5781** — Defeat card succeeds → `defeat.use` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"defeat.use", ctx)`
- **main.gd:5663** — Quiet Bell / Silence → `util.quiet` (keep+): keep existing lines, add `play_event(&"util.quiet")`
- **main.gd:5488+ (_apply_ops magnet branch)** — Magnet resolves → `util.magnet` (new): add `play_event(&"util.magnet", ctx)`
- **main.gd:5488+ (_apply_ops hook branch)** — Hook resolves → `util.hook` (new): add `play_event(&"util.hook", ctx)`
- **main.gd:5585** — Smoke card → `smoke.use` (new): add `play_event(&"smoke.use", ctx)`
- **main.gd:5474–5479, 7274–7280** — Echo Bell copies last card → `chaos.echo_bell` (new): in `_apply_ops` / `_ops_of` when the card is echo_bell and ops were copied: play `chaos.echo_bell`, then delay the copied card's cues by 90 ms (pass `delay_ms` in ctx or await a 0.09 s timer before the existing sounds)
- **main.gd:4826–4841** — Egg hurts you → `egg.hurt` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"egg.hurt", ctx)`
- **main.gd:6794–6796** — Spider Egg laid → `egg.lay` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"egg.lay", ctx)`
- **main.gd:6761–6762** — Spider Queen eats eggs → `egg.queen_eat` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"egg.queen_eat", ctx)`
- **combat_stage.gd:136 (trigger site in main.gd)** — Monster lunge (visual) → `mon.lunge` (new): add `play_event(&"mon.lunge", ctx)`
- **main.gd:4855–4856** — Monster Attack hits you → `player.hurt` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"player.hurt", ctx)`
- **main.gd:4863–4865** — Monster Attack fully blocked → `player.blocked` (keep+): keep existing lines, add `play_event(&"player.blocked")`
- **main.gd:7989, 7996** — Damage taken (Needleback poke etc.) → `player.poke` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"player.poke", ctx)`
- **main.gd:7395–7396** — Petrify (Gargoyle) → `status.petrify` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"status.petrify", ctx)`
- **main.gd:8180, 8214–8230** — Poison mark applied → `status.poison` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"status.poison", ctx)`
- **main.gd:8360, combat_stage.gd:149** — Hypnotize / Pocketwatch → `status.hypnotize` (new): add `play_event(&"status.hypnotize", ctx)`
- **main.gd:7539–7540** — Feed Cube → `mon.cube_feed` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"mon.cube_feed", ctx)`
- **main.gd:7444–7445** — Merchant ask → `mon.merchant_ask` (keep+): keep existing lines, add `play_event(&"mon.merchant_ask")`
- **main.gd:7002** — Cleric heal tax → `mon.cleric_tax` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"mon.cleric_tax", ctx)`
- **main.gd:6671–6672** — Leech pulse (repeats) → `mon.leech_pulse` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"mon.leech_pulse", ctx)`
- **main.gd:7578–7579** — Clockwork heirs spawn → `mon.clockwork_spawn` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"mon.clockwork_spawn", ctx)`
- **main.gd:6544–6545** — Commander flees → `mon.commander_flee` (replace): replace whoosh+door with play_event (3 scurry steps then whoosh); keep door_open
- **_swing / Done (Hornet)** — Hornet second swing → `mon.hornet_buzz` (new): add `play_event(&"mon.hornet_buzz", ctx)`
- **main.gd:7878–7879** — Monster HP drops (Weak) → `mon.hurt_weak` (replace): `_deal_atk_at` 7878–7879: target tier → `resolve(&"hurt", {tier=t})`
- **main.gd:7878–7879** — Monster HP drops (Tough) → `mon.hurt_tough` (replace): (same)
- **main.gd:7878–7879** — Monster HP drops (Deadly) → `mon.hurt_deadly` (replace): (same)
- **main.gd:4678–4680** — Monster slain (Weak) → `mon.death_weak` (replace): `_play_ended_visuals` 4678–4680: replace bong+whoosh+scratch with `play_event(resolve(&"death",{tier=t}))` (chord is now a layer)
- **main.gd:4678–4680** — Monster slain (Tough) → `mon.death_tough` (replace): (same)
- **main.gd:4678–4680** — Monster slain (Deadly) → `mon.death_deadly` (replace): (same; triggers music deadly→combat)
- **main.gd:8471–8473** — Neighbour kill (Crossbow/Longbow) → `mon.neighbor_kill` (replace): `_kill_neighbor` 8471–8473: same as death, using the victim's tier
- **main.gd:4491 / 4532** — Deadly first shown (per-boss pitch via sfx-map) → `sting.deadly` (new): add `play_event(&"sting.deadly", ctx)`
- **bucket_reveal.gd:233–234** — Bucket reveal opens → `sting.bucket` (new): add `play_event(&"sting.bucket", ctx)`
- **main.gd:4876–4884** — Run victory → `sting.victory` (new): add `play_event(&"sting.victory", ctx)`
- **main.gd:1677–1679** — Dungeon cleared → `sting.clear` (new): add `play_event(&"sting.clear", ctx)`
- **main.gd:4886–4887** — Player dies → `sting.defeat` (new): add `play_event(&"sting.defeat", ctx)`
- **bucket_reveal.gd:233–234** — Bucket overlay opens → `bucket.open` (keep+): keep existing lines, add `play_event(&"bucket.open")`
- **bucket_reveal.gd:254** — Each shadow card pops → `bucket.card_pop` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"bucket.card_pop", ctx)`
- **bucket_reveal.gd:348–351** — Hover a revealed card → `bucket.card_hover` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"bucket.card_hover", ctx)`
- **main.gd:11087** — Tutorial Skip → `tut.skip` (new): add `play_event(&"tut.skip", ctx)`
- **tutorial_guide.gd:242 (advance)** — Each Nib sentence → `speech.nib` (new): tutorial_guide.gd:242 `advance`: emit/call `sfx.speak(&"nib", text)` (see spec §6 speech rules); no text changes
- **home_cabin.gd:113 (from main.gd:1718)** — Cabin UI opens → `cabin.open` (keep+): keep existing lines, add `play_event(&"cabin.open")`
- **home_cabin.gd:450 (_walk_hero)** — Goblin walks (per footfall frame) → `cabin.step` (new): home_cabin.gd:450 `_walk_hero`: one call per footfall frame (or every 0.26 s while walking if there are no frame events)
- **home_cabin.gd:470 (_play_drop)** — Sack drop → `cabin.sack` (new): add `play_event(&"cabin.sack", ctx)`
- **home_cabin.gd:484 (_play_sit)** — Sit in chair → `cabin.sit` (new): add `play_event(&"cabin.sit", ctx)`
- **home_cabin.gd:445, 553** — Chair rock (once per rock cycle) → `cabin.rock` (new): home_cabin.gd:445, 553: one creak per rock cycle (connect to animation loop / frame 0)
- **home_cabin.gd:528** — Fire start → `cabin.fire_start` (replace): replace the existing sfx.play line(s) for this event with `play_event(&"cabin.fire_start", ctx)`
- **home_cabin.gd:526 (_fire.play('burn'))** — Fire loop / crackle → `amb.fire` (new): home_cabin.gd:526 when `_fire.play("burn")`: `sfx.loop_start(&"amb.fire", 1.5)`; stop (0.8 s) on cabin close
- **home_cabin.gd:718 (_play_burst)** — Trophy placed / burst → `cabin.trophy` (new): add `play_event(&"cabin.trophy", ctx)`
- **home_cabin.gd:742** — Plaque glint → `cabin.glint` (new): add `play_event(&"cabin.glint", ctx)`
- **home_cabin.gd:802 (_tick_cat)** — Cat idle (random, ≥ 8 s apart) → `cabin.cat` (new): home_cabin.gd:802 `_tick_cat`: when the cat does an idle action, random chance 35 %, cooldown 8 s
- **home_cabin.gd:802** — Cat purr loop (while cat sleeps / goblin sits) → `amb.cat_purr` (new): start when the cat is in its sleep/idle loop or the goblin sits (home_cabin.gd:484/802); stop on close
- **main.gd:1743** — Close cabin → `cabin.close` (keep+): keep existing lines, add `play_event(&"cabin.close")`
- **main.gd:1925** — Knight walks off → `run.knight_off` (keep+): keep existing lines, add `play_event(&"run.knight_off")`
- **main.gd:1677–1679** — Dungeon cleared → `run.dungeon_clear` (replace): main.gd:1677–1679: keep confirm_big; replace the −2 duck with sting.clear and music → TITLE
- **main.gd:4876–4884** — Victory (incl. Adventure death after ≥1 clear) → `run.victory` (replace): main.gd:4876–4884 victory branch: keep confirm_big; add sting + coins; music state VICTORY
- **main.gd:4886–4887** — Player dies → `run.defeat` (replace): main.gd:4886–4887: keep error_big; replace `duck_music(-16)` with music state DEFEAT

Also:
- `main.gd:3945–3947` (Escape opens settings): keep `open`, add `sfx.on_pause(true)`. Call `on_pause(false)` on resume/close.
- **Wheel ticks (5d):** in `boss_wheel.gd`, add `signal segment_passed(index: int, speed01: float)`. Drive the existing `spin_to` tween (≈ line 461) with `tween_method` (or watch `rotation` in `_process` while a spin is active). Compute the segment under the pointer from the seat count and emit on every change, with `speed01` = current angular speed / peak speed. Don't change the spin's duration or easing. In `main.gd`, connect it to `sfx.play_tick(speed01)`. The landing is still handled in `_on_spin`, where `wheel.detent` is layered into `wheel.land_<tier>`. Number ticks: `play_atk_ticks` / `play_hp_ticks` (`boss_wheel.gd:723`, `741`) emit a signal (or call the helper through the reference main already passes in) for `wheel.num_tick_atk` / `wheel.num_tick_hp`, one per visible increment.
- **Deadly pitch:** for `wheel.land_deadly` and `sting.deadly`, pass `pitch_mul = map.deadly_sting_pitch.get(monster_id, 1.0)`.
- **Echo Bell:** see spec §6. Bell first, then the copied card's own sounds 90 ms later.
- **Seat pitch step:** `draft.seat_starter` keeps the existing per-seat pitch climb by passing it as `pitch_mul`. Leech pulse does the same with its climbing pitch.
- **Card ids / special ids** in `lookup` are guesses from the audit. Check them against `data/catalog.json` and `MONSTER_SPECIAL` (`main.gd:126–160`), fix the keys in `data/sfx-map.json`, and note any changes in your report.

## Step 6: credits (commit `audio(6): credits`)

Make sure `assets/audio/CREDITS.txt` lists every file in `assets/audio/` (write a quick script to diff the directory listing against the ledger). Make sure `CREDITS.md` points to it.

## Step 7: verify and report (commit `audio(7): verify script` if you add one)

1. Add `tools/audio/verify_audio.gd` (a `SceneTree` script run with `godot --headless --script tools/audio/verify_audio.gd`). It should: load `data/sfx-map.json`; check that every cue's files resolve to a loadable `AudioStream`; check that every layer cue id exists; check that every `lookup` target exists; check that the six buses exist with the right effects; and check that the five loop files have `loop == true`. Exit with code 1 on any failure.
2. `godot --headless --quit-after 300` (or open the project): no script errors.
3. Run the game (F5) and walk through it: title hover/click → Adventure (draft gate take/refuse, wheel spin, so you can hear ticks and land on a Weak, a Tough, and a Deadly monster if possible) → play one card of each class → kill a monster (coins) → pause (duck + sliders, including the new two) → Home cabin (steps, door, sack, sit, rock, fire loop, cat, trophy) → back to title → How to Play (Nib blips) → Challenge (bucket reveal). Watch the Output panel for warnings from `AudioFx`.
4. If the export templates are installed, export Web (preset 0). Confirm `data/sfx-map.json` is in the pck/zip and `tools/` isn't. Load `build/web/index.html` via a local server and confirm the music starts on the first click.
5. **Report:** commits made; any call sites you couldn't find, or where you deviated from the spec, and why; id fixes in the map; verify-script output; the size of `assets/audio/` (it should be about 3.9 MB); and anything that sounded wrong.
