# Swipe audio pass 1 — pack contents (mirrors repo paths)

- `design/audio/AUDIO-SPEC.md` — full sound + music spec, cue table (§7), sourcing (§8), asset list (§9)
- `design/audio/CURSOR-PROMPT.md` — paste-ready implementation prompt for Cursor
- `design/audio/audio-director.md` — the input audit (for reference)
- `data/sfx-map.json` — data-driven cue map (cues, lookup/fallback chain, music beds, speech, wheel ticks)
- `assets/audio/*.ogg` — 85 new assets (2.0 MB); `assets/audio/CREDITS.txt` — full licence ledger (merge with existing)
- `tools/audio/` — `fetch_sources.sh` (download CC0 sources), `sfxgen.py` (synth), `build_audio.py` (process/encode),
  `cues.py` (regenerates cue table + sfx-map), `write_credits.py`, `manifest.json` (build output record)

Rebuild: `tools/audio/fetch_sources.sh /tmp/src && python3 tools/audio/sfxgen.py --out /tmp/synth &&
python3 tools/audio/build_audio.py --src /tmp/src --synth /tmp/synth --out assets/audio --manifest tools/audio/manifest.json`
(needs ffmpeg with libvorbis, numpy, scipy, soundfile)
