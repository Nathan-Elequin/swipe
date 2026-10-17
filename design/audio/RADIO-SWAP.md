# Radio swap: Snatchwick Melodeon stations 1–3

**Status:** ready to apply · **Date:** 2026-10-17 · **Pack:** `swipe-radio-pack.zip` (mirrors repo paths)
Nathan chose all three tracks. All are CC0 1.0 (OpenGameArt); I checked the licence on each track's own page.

| Station | Bed id | File | Source | Length | Loop |
|---|---|---|---|---|---|
| 0 | `cabin` | `music_cabin.ogg` | unchanged (A Small Fire Will Do, Trex0n) | — | — |
| 1 | `station_inn` | `music_station_inn.ogg` | Medieval: The Old Tower Inn (loop), RandomMind | 49.95 s | seamless loop |
| 2 | `station_rag` | `music_station_rag.ogg` | Ragtime! Jazz, Tarush Singhal | 111.84 s | beat-aligned loop |
| 3 | `station_harp` | `music_station_harp.ogg` | Meadow Thoughts, Écrivain | 149.36 s | piece ends on a ring-out and restarts (no click) |

The `ending` bed (`music_ending.ogg`, music-box happy polka) **stays** for the ending cutscene. It is only removed from the radio.

## Changes
1. **Add** `assets/audio/music_station_inn.ogg`, `music_station_rag.ogg` and `music_station_harp.ogg` from the pack. Let the Godot editor generate the `.import` files. If your bed loader doesn't apply `loop` from sfx-map at runtime, tick **Loop** in each file's import settings (loop offset 0).
2. **Delete** `assets/audio/music_station_waltz.ogg`, `music_station_waltz.ogg.import`, `music_station_tune.ogg` and `music_station_tune.ogg.import`. Before deleting, run `rg "music_station_waltz|music_station_tune|station_waltz|station_tune"` to make sure nothing else references them.
3. **`scripts/home_cabin.gd` line 20**
   `const STATION_BEDS := ["cabin", "station_waltz", "station_tune", "ending"]`
   → `const STATION_BEDS := ["cabin", "station_inn", "station_rag", "station_harp"]`
4. **`scripts/cabin/radio_overlay.gd` line 9**
   `const BEDS := ["cabin", "station_waltz", "station_tune", "ending"]`
   → `const BEDS := ["cabin", "station_inn", "station_rag", "station_harp"]`
5. **`data/sfx-map.json`**: follow `data/radio-stations.patch.json`.
   - Add beds `station_inn`, `station_rag` and `station_harp`, each with `{file: music_station_<x>, gain_db 0, loop true, resume_position true}`.
   - Remove beds `station_waltz` and `station_tune`.
   - Keep `cabin` and `ending` as they are.
   - Set `radio.stations` to `["cabin","station_inn","station_rag","station_harp"]`. Leave `station_copy_keys` and `crossfade_s 0.6` unchanged.
6. **`data/player-copy.json`**: rewrite rows `radio.station.1..3` (cat Radio, where "Station name under the dial", `draft: false`, note "Jam-approved 2026-10-17"; keep the straight apostrophe in Gloria's).
   - 1 **The Rusty Tankard** (was The Grumble Waltz)
   - 2 **Snatchwick Rag** (was Gloria's Lullaby)
   - 3 **Gloria's Lullaby** (was Snatchwick Polka)
   - Station 0, "Fireside Crackle", is unchanged.
7. **Credits**: merge `assets/audio/CREDITS.additions.txt` into `assets/audio/CREDITS.txt`. That means adding 3 lines and removing the waltz and tune lines. Keep the music_ending (happy polka) line. Then delete the additions file.
8. **Saves**: station order is kept, so a `radio_station` index 1–3 maps to inn/rag/harp automatically. If anything stores the bed *name*, add the alias map from the patch (`station_waltz→station_inn`, `station_tune→station_rag`, `ending→station_harp`).

## Audio prep (done in pack)
- All three files: 44.1 kHz stereo OGG Vorbis q1.5, static gain to −20 LUFS (no limiter, so the loops are unaffected), true peak ≤ −1 dBFS. Measured on the decoded OGG:
  - inn −20.1 LUFS / −4.7 dBTP
  - rag −20.0 / −2.2
  - harp −20.1 / −5.5
- **inn:** the author's loop WAV. Its beat grid runs continuously across the wrap. I added a 5.8 ms crossfade to remove a sample-level step that could have clicked.
- **rag:** this track wasn't made as a loop, but the source is cut at a phrase boundary. I trimmed 50 ms of pre-attack from the head so the first downbeat lands on the beat grid carried across the wrap. The measured seam shift is +20 ms against +17 to +25 ms at 9 points inside the track, so it's within normal variation. There's also a 15 ms fade-out at the seam.
- **harp:** I trimmed 0.38 s of trailing silence. The last ring-out (about −45 dB) gets a 150 ms fade, then the piece restarts on its first note.

## Test checklist
- [ ] Each station 0–3 plays from the Melodeon dial and shows the right station name.
- [ ] Stations 1–3 each loop at least twice with no click, gap or tempo hiccup. Wraps happen at 0:50 (inn), 1:52 (rag) and 2:29 (harp).
- [ ] Station switching still crossfades (0.6 s). `resume_position` restores where each station left off.
- [ ] Levels sit level-matched with station 0 under the cabin SFX (fire, ambience). None should jump out.
- [ ] Save on each station, then quit and load: the same station is playing.
- [ ] Load an **old save** with `radio_station` 1, 2 or 3. It should play inn, rag or harp with no error or fallback-to-silence.
- [ ] The ending cutscene still plays `music_ending` (happy polka).
- [ ] No missing-resource errors for `music_station_waltz` or `music_station_tune` in the editor or at runtime (re-import or clear `.godot/imported` if needed).
- [ ] Web export: all three stations load and loop in the browser build (check for OGG decode errors in the console). The total size added is about 2.8 MB of OGG, less the two removed files.
- [ ] CREDITS.txt has been updated.
