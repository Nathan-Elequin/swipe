#!/usr/bin/env python3
"""Write assets/audio/CREDITS.txt from the build manifest (+ the pre-existing repo files)."""
import json, sys
man = json.load(open(sys.argv[1])); out = sys.argv[2]
L = []
w = L.append
w("Swipe — audio credits / licence ledger")
w("======================================")
w("Every file in assets/audio/ is listed. Only CC0 1.0 sources and self-generated audio are used; no attribution is legally")
w("required for CC0, but we credit everyone anyway. Do NOT add non-commercial (NC), ND, or unclear-licence audio.")
w("CC0 1.0 deed: https://creativecommons.org/publicdomain/zero/1.0/")
w("")
w("Pack / source index")
w("-------------------")
packs = {}
for m in man:
    for s in m["sources"]: packs[s["pack"]] = (s["author"], s["licence"], s["url"])
packs.setdefault("Kenney — Interface Sounds", ("Kenney (kenney.nl)", "CC0 1.0", "https://kenney.nl/assets/interface-sounds"))
packs["Dungeon Ambience (OpenGameArt)"] = ("yd", "CC0 1.0", "https://opengameart.org/content/dungeon-ambience")
for k, (a, l, u) in sorted(packs.items()): w(f"* {k} — {a} — {l} — {u}")
w("")
w("Pre-existing files (unchanged by audio pass 1; credit per the original ledger)")
w("-----------------------------------------------------------------------------")
for f in "bong click click2 confirm confirm_big drop error error_big glass hover land open pluck question scratch select switch whoosh".split():
    w(f"{f}.wav — Kenney — Interface Sounds{' / RPG Audio' if f == 'glass' else ''} — Kenney — CC0 1.0 — https://kenney.nl/assets/interface-sounds")
for f in "block block_heavy book chop cloth creak door_close door_open draw hit".split():
    w(f"{f}.ogg — Kenney — RPG Audio — Kenney — CC0 1.0 — https://kenney.nl/assets/rpg-audio")
w("door_slam.ogg — Kenney — RPG Audio (doorClose_4) — Kenney — CC0 1.0 — https://kenney.nl/assets/rpg-audio")
w("metal_latch.ogg — Kenney — RPG Audio extras — Kenney — CC0 1.0 — https://kenney.nl/assets/rpg-audio")
w("bleed.wav — original drip made for Swipe — CC0 1.0")
w("music.ogg — \"Dungeon Ambience\" (dungeon002.ogg) — yd — CC0 1.0 — https://opengameart.org/content/dungeon-ambience")
w("")
w("Audio pass 1 (2026-10-17) — new files")
w("-------------------------------------")
w("Processing for all: trimmed, pitch-shifted where noted, normalised (SFX active-RMS target, peak <= -1 dBFS; music to")
w("-20/-22 LUFS), encoded OGG Vorbis (SFX 48 kHz mono q4, music 44.1 kHz stereo q1.5). Rebuild: tools/audio/build_audio.py")
w("")
for m in man:
    parts = []
    for s in m["sources"]:
        extra = []
        if s["pitch"] != 1.0: extra.append(f"pitch x{s['pitch']}")
        if s["gain_db"]: extra.append(f"{s['gain_db']:+} dB layer")
        parts.append(f"{s['pack']} / {s['file']}" + (f" ({', '.join(extra)})" if extra else "") + f" — {s['author']} — {s['licence']} — {s['url']}")
    w(f"{m['file']} ({m['seconds']:.2f} s)")
    for p in parts: w(f"    <- {p}")
w("")
w("Suno biome beds (drop-in OGGs; not rebuilt by build_audio.py)")
w("------------------------------------------------------------")
w("music_verdant_hollow_intro.ogg / music_verdant_hollow_loop.ogg — Verdant Hollow — Suno instrumental by Nathan (Dungeon Loop / refinedpolonaise473), 2026-10-29")
w("music_cinder_forge_a.ogg / music_cinder_forge_b.ogg / music_cinder_forge_c.ogg — Cinder Forge Approach F — Suno Forge Motif https://suno.com/s/mhvMHyfv72JqOpjX — loop trim 8.169s→73.629s (65.460s, 121 BPM) — Nathan (refinedpolonaise473), 2026-10-29")
w("music_crystal_cavern_a.ogg / music_crystal_cavern_b.ogg / music_crystal_cavern_c.ogg — Crystal Cavern Approach F (b2; replaces sunken_mire music keys) — 119 BPM — Nathan (refinedpolonaise473), 2026-10-30")
open(out, "w").write("\n".join(L) + "\n")
print("wrote", out, len(L), "lines")
