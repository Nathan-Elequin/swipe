#!/usr/bin/env python3
"""Build Swipe audio pass 1 from downloaded CC0 packs + sfxgen synth output.

  python3 tools/audio/build_audio.py --src <dir with packs> --synth <sfxgen out> --out assets/audio
Needs ffmpeg (libvorbis), numpy, soundfile.  Also writes assets/audio/CREDITS-pass1.txt fragment.
Source layout expected under --src (as downloaded by the sound pass):
  kenney_<pack>/Audio/...   (unzipped Kenney packs)
  oga/<file>                (OpenGameArt downloads)
"""
import argparse, json, os, subprocess, tempfile
import numpy as np, soundfile as sf

K = "https://kenney.nl/assets/"
PACKS = {
 "interface": ("kenney_interface-sounds/Audio/", "Kenney — Interface Sounds", "Kenney (kenney.nl)", "CC0 1.0", K + "interface-sounds"),
 "rpg":       ("kenney_rpg-audio/Audio/", "Kenney — RPG Audio", "Kenney (kenney.nl)", "CC0 1.0", K + "rpg-audio"),
 "impact":    ("kenney_impact-sounds/Audio/", "Kenney — Impact Sounds", "Kenney (kenney.nl)", "CC0 1.0", K + "impact-sounds"),
 "casino":    ("kenney_casino-audio/Audio/", "Kenney — Casino Audio", "Kenney (kenney.nl)", "CC0 1.0", K + "casino-audio"),
 "jingles":   ("kenney_music-jingles/Audio/", "Kenney — Music Jingles", "Kenney (kenney.nl)", "CC0 1.0", K + "music-jingles"),
 "ui":        ("kenney_ui-audio/Audio/", "Kenney — UI Audio", "Kenney (kenney.nl)", "CC0 1.0", K + "ui-audio"),
 "oga_rbl":   ("oga/", "RPG Battle Loop", "iamoneabe", "CC0 1.0", "https://opengameart.org/content/rpg-battle-loop"),
 "oga_deep":  ("oga/", "Dungeon Deep", "Eldritch Grim", "CC0 1.0", "https://opengameart.org/content/dungeon-deep-0"),
 "oga_fire_m":("oga/", "A Small Fire Will Do (Calming Loop)", "Trex0n (Cal McEachern)", "CC0 1.0 (credit appreciated)", "https://opengameart.org/content/a-small-fire-will-do-calming-loop"),
 "oga_fire":  ("oga/", "Fireplace Sound loop", "PagDev", "CC0 1.0", "https://opengameart.org/content/fireplace-sound-loop"),
 "oga_cat":   ("oga/", "Cat Purr & Meow", "Kerzoven", "CC0 1.0", "https://opengameart.org/content/cat-purr-meow"),
 "synth":     ("", "Swipe sfxgen (tools/audio/sfxgen.py)", "Swipe / generated", "CC0 1.0 (original)", "tools/audio/sfxgen.py"),
}
# kind: ui | sfx | sting | amb | music ; layers: [(pack, file, gain_db, pitch, delay_s)]
def L(pack, f, g=0.0, p=1.0, d=0.0): return (pack, f, g, p, d)
M = {}
def add(name, kind, *layers, **o): M[name] = dict(kind=kind, layers=list(layers), **o)

# UI
add("ui_hover_soft_a", "ui", L("synth", "ui_hover_soft_a.wav"))
add("ui_hover_soft_b", "ui", L("synth", "ui_hover_soft_b.wav"))
add("ui_tick", "ui", L("interface", "tick_002.ogg"))
add("ui_back", "ui", L("interface", "back_002.ogg"))
# Wheel
for v in "abc": add(f"wheel_tick_{v}", "ui", L("synth", f"wheel_tick_{v}.wav"))
add("wheel_detent", "sfx", L("synth", "wheel_detent.wav"))
add("wheel_land_weak", "sfx", L("impact", "impactWood_light_002.ogg"))
add("wheel_land_tough", "sfx", L("impact", "impactPlank_medium_001.ogg"))
add("wheel_land_deadly", "sfx", L("impact", "impactBell_heavy_001.ogg", 0, 0.8), maxlen=1.6)
# Combat — player
for i, f in enumerate(["impactPunch_medium_000", "impactPunch_medium_001", "impactPunch_medium_002"], 1): add(f"atk_hit_light_{i}", "sfx", L("impact", f + ".ogg"))
for i, f in enumerate(["impactPunch_heavy_000", "impactPunch_heavy_001"], 1): add(f"atk_hit_heavy_{i}", "sfx", L("impact", f + ".ogg"))
add("atk_slash", "sfx", L("rpg", "knifeSlice.ogg"))
add("blk_gain_1", "sfx", L("impact", "impactPlate_light_000.ogg"))
add("blk_gain_2", "sfx", L("impact", "impactPlate_light_001.ogg"))
add("blk_gain_big", "sfx", L("impact", "impactPlate_heavy_000.ogg"))
add("heal_sparkle", "sfx", L("synth", "heal_sparkle.wav"), L("impact", "impactGlass_light_001.ogg", -10, 1.2))
add("defeat_slash", "sfx", L("rpg", "knifeSlice2.ogg"))
add("smoke_poof", "sfx", L("synth", "smoke_poof.wav"))
add("echo_bell", "sfx", L("impact", "impactBell_heavy_002.ogg", 0, 1.25), echo=True, maxlen=1.8)
add("chaos_warble", "sting", L("jingles", "Pizzicato jingles/jingles_PIZZI03.ogg"))
add("egg_crack", "sfx", L("impact", "impactGlass_light_003.ogg", 0, 0.75), L("impact", "impactSoft_medium_001.ogg", -3, 0.8))
add("egg_squelch", "sfx", L("impact", "impactSoft_heavy_002.ogg", 0, 0.7))
add("util_magnet", "sfx", L("synth", "util_magnet.wav"))
# Monsters
add("mon_hurt_deadly", "sfx", L("impact", "impactMetal_heavy_000.ogg", 0, 0.85))
add("mon_death_weak", "sfx", L("impact", "impactSoft_heavy_000.ogg"))
add("mon_death_tough", "sfx", L("impact", "impactWood_heavy_001.ogg", 0, 0.85))
add("mon_death_deadly", "sfx", L("impact", "impactBell_heavy_003.ogg", 0, 0.7), maxlen=2.0)
add("loot_coins", "sfx", L("rpg", "handleCoins.ogg"))
add("loot_coins_small", "sfx", L("rpg", "handleCoins2.ogg"))
add("player_oof_a", "sfx", L("synth", "gob_oof_a.wav"))
add("player_oof_b", "sfx", L("synth", "gob_oof_b.wav"))
add("status_petrify", "sfx", L("impact", "impactMining_001.ogg", 0, 0.8))
add("status_poison", "sfx", L("synth", "status_poison.wav"))
add("status_hypnotize", "sfx", L("synth", "status_hypnotize.wav"))
add("status_silence", "sfx", L("impact", "impactBell_heavy_004.ogg", 0, 1.1), lowpass=900, maxlen=0.6)
add("mon_leech_pulse", "sfx", L("synth", "mon_leech_pulse.wav"))
add("mon_hornet_buzz", "sfx", L("synth", "mon_hornet_buzz.wav"))
add("mon_cube_gulp", "sfx", L("impact", "impactSoft_medium_003.ogg", 0, 0.6))
add("mon_clockwork", "sfx", L("rpg", "metalClick.ogg"))
# Speech
for i in range(1, 9): add(f"nib_blip_{i:02d}", "ui", L("synth", f"nib_blip_{i:02d}.wav"))
for i in range(1, 5): add(f"monster_blip_{i:02d}", "ui", L("synth", f"monster_blip_{i:02d}.wav"))
# Buckets / hand
add("bucket_open", "sfx", L("casino", "cards-pack-open-1.ogg"))
for i in (1, 2, 3): add(f"card_place_{i}", "sfx", L("casino", f"card-place-{i}.ogg"))
add("card_slide", "ui", L("casino", "card-slide-1.ogg"))
add("card_shove", "sfx", L("casino", "card-shove-1.ogg"))
# Cabin
for i in range(4): add(f"cabin_step_{i+1}", "amb", L("impact", f"footstep_wood_00{i}.ogg"))
add("cabin_sack", "sfx", L("rpg", "dropLeather.ogg"), L("rpg", "handleCoins2.ogg", -4, 0.95, 0.04))
add("cabin_sit", "sfx", L("impact", "impactWood_medium_000.ogg", -2, 0.9), L("rpg", "creak3.ogg", -3, 1.0, 0.05))
for i in (1, 2, 3): add(f"cabin_rock_{i}", "amb", L("rpg", f"creak{i}.ogg", 0, 0.9), lowpass=2500)
add("cabin_trophy", "sfx", L("impact", "impactPlank_medium_002.ogg", -2, 1.1), L("synth", "cabin_glint.wav", -4, 1.0, 0.05))
add("cabin_glint", "ui", L("synth", "cabin_glint.wav"))
add("cabin_cat_mew", "amb", L("oga_cat", "cat_softmew.wav"))
add("cabin_cat_mewpurr", "amb", L("oga_cat", "cat_mewpurr.wav"))
add("cabin_cat_purr_loop", "amb", L("oga_cat", "cat_purrsleepy_loop.wav"), loop="xfade", loop_start=0.7, loop_len=4.8)
add("cabin_fire_loop", "amb", L("oga_fire", "fire.wav"), loop="xfade", loop_start=2.0, loop_len=12.0)
# Stings
add("sting_deadly", "sting", L("jingles", "Hit jingles/jingles_HIT06.ogg"))
add("sting_bucket", "sting", L("jingles", "Pizzicato jingles/jingles_PIZZI02.ogg"))
add("sting_victory", "sting", L("jingles", "Pizzicato jingles/jingles_PIZZI10.ogg"))
add("sting_clear", "sting", L("jingles", "Pizzicato jingles/jingles_PIZZI15.ogg"))
add("sting_defeat", "sting", L("jingles", "Sax jingles/jingles_SAX01.ogg"))
# Music (whole-file loops; trims measured in samples @44.1k)
add("music_combat", "music", L("oga_rbl", "rbl_0.mp3"), trim=(1011, 2605292), edge_fade_ms=4)  # 32 bars @130 BPM; micro-fade masks the wrap
add("music_deadly", "music", L("oga_deep", "dungeon_deep.mp3"), trim=(0, 1142158))
add("music_cabin", "music", L("oga_fire_m", "a_small_fire_will_do.wav"), trim=(0, 2822400), lufs=-22)
# Suno biome beds are drop-in files in assets/audio/ (not encoded here):
#   Verdant Hollow: music_verdant_hollow_intro.ogg, music_verdant_hollow_loop.ogg
#   Cinder Forge Approach F: music_cinder_forge_a.ogg (bed), music_cinder_forge_b.ogg (drums),
#     music_cinder_forge_c.ogg (heat). Credits: write_credits.py trailer + assets/audio/CREDITS.txt.

TARGET_RMS = {"ui": -20.0, "sfx": -16.0, "sting": -16.0, "amb": -22.0}

def decode(path, sr, ch, pitch=1.0, lowpass=None, echo=False):
    af = []
    if pitch != 1.0: af += [f"asetrate={int(sr*pitch)}", f"aresample={sr}"]
    if lowpass: af.append(f"lowpass=f={lowpass}")
    if echo: af.append("apad=pad_dur=1.2,aecho=0.8:0.6:180|360:0.45|0.25")
    cmd = ["ffmpeg", "-nostdin", "-v", "error", "-i", path] + (["-af", ",".join(af)] if af else []) + ["-ac", str(ch), "-ar", str(sr), "-f", "f32le", "-"]
    x = np.frombuffer(subprocess.run(cmd, capture_output=True, check=True).stdout, np.float32)
    return x.reshape(-1, ch).copy()

def trim_silence(x, thr_db=-55):
    a = np.abs(x).max(1); nz = np.nonzero(a > 10 ** (thr_db / 20))[0]
    return x[nz[0]: nz[-1] + 1] if len(nz) else x

def active_rms_db(x):
    m = x.mean(1); fr = 480; n = len(m) // fr
    if n == 0: return 20 * np.log10(np.sqrt(np.mean(m ** 2)) + 1e-9)
    r = np.sqrt(np.mean(m[: n * fr].reshape(n, fr) ** 2, 1)); pk = r.max()
    act = r[r > pk * 0.1]
    return 20 * np.log10(np.sqrt(np.mean(act ** 2)) + 1e-9)

def xfade_loop(x, sr, start, length, fade=1.0):
    s, L_, F = int(start * sr), int(length * sr), int(fade * sr)
    body = x[s: s + L_].copy(); pre = x[s - F: s] if s >= F else x[s + L_: s + L_ + F]
    tail = x[s + L_ - F: s + L_]
    w = np.linspace(0, 1, F)[:, None]
    # blend loop end into the material that precedes loop start -> seamless wrap
    body[-F:] = tail * np.sqrt(1 - w) + pre * np.sqrt(w)
    return body

def lufs(path):
    out = subprocess.run(["ffmpeg", "-nostdin", "-i", path, "-af", "ebur128", "-f", "null", "-"], capture_output=True, text=True).stderr
    return float([l for l in out.splitlines() if l.strip().startswith("I:")][-1].split()[1])

def build(name, spec, src, synth, outdir, tmp):
    kind = spec["kind"]; music = kind == "music"
    sr, ch = (44100, 2) if music else (48000, 1)
    mix = None
    for pack, f, g, p, d in spec["layers"]:
        base = synth if pack == "synth" else os.path.join(src, PACKS[pack][0])
        y = decode(os.path.join(base, f), sr, ch, p, spec.get("lowpass"), spec.get("echo", False))
        if not music and not spec.get("loop"): y = trim_silence(y)
        y = y * 10 ** (g / 20); off = int(d * sr)
        if mix is None: mix = np.zeros((off + len(y), ch), np.float32)
        if len(mix) < off + len(y): mix = np.pad(mix, ((0, off + len(y) - len(mix)), (0, 0)))
        mix[off: off + len(y)] += y
    x = mix
    if "trim" in spec: a, n = spec["trim"]; x = x[a: a + n]
    if "edge_fade_ms" in spec:
        f = int(spec["edge_fade_ms"] / 1000 * sr); w = np.sin(np.linspace(0, np.pi / 2, f))[:, None]
        x[:f] *= w; x[-f:] *= w[::-1]
    if spec.get("loop") == "xfade": x = xfade_loop(x, sr, spec.get("loop_start", 0.5), spec["loop_len"], 0.6)
    if "maxlen" in spec and len(x) > spec["maxlen"] * sr:
        n = int(spec["maxlen"] * sr); x = x[:n]; f = int(0.25 * sr); x[-f:] *= np.linspace(1, 0, f)[:, None]
    if not music and not spec.get("loop"):
        f = min(int(0.004 * sr), len(x)); x[-f:] *= np.linspace(1, 0, f)[:, None]
    wav = os.path.join(tmp, name + ".wav")
    if music:
        sf.write(wav, x, sr, subtype="FLOAT"); gain = spec.get("lufs", -20.0) - lufs(wav)
        x = x * 10 ** (gain / 20)
    else:
        gain = TARGET_RMS[kind] - active_rms_db(x)
        gain = min(gain, -1.0 - 20 * np.log10(np.abs(x).max() + 1e-9)); x = x * 10 ** (gain / 20)
    pk = np.abs(x).max()
    if pk > 10 ** (-1 / 20): x = np.tanh(x / pk * 1.2) / np.tanh(1.2) * 10 ** (-1 / 20)  # soft safety clip
    sf.write(wav, x, sr, subtype="FLOAT")
    q = ["-c:a", "libvorbis", "-q:a", "1.5"] if music else ["-c:a", "libvorbis", "-q:a", "4"]
    dst = os.path.join(outdir, name + ".ogg")
    subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-y", "-i", wav] + q + ["-map_metadata", "-1", dst], check=True)
    return dst, len(x) / sr

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True); ap.add_argument("--synth", required=True); ap.add_argument("--out", required=True)
    ap.add_argument("--manifest", help="write JSON manifest here")
    a = ap.parse_args(); os.makedirs(a.out, exist_ok=True); rows = []
    with tempfile.TemporaryDirectory() as tmp:
        for name, spec in M.items():
            dst, dur = build(name, spec, a.src, a.synth, a.out, tmp)
            srcs = [dict(pack=PACKS[p][1], author=PACKS[p][2], licence=PACKS[p][3], url=PACKS[p][4],
                         file=(PACKS[p][0].split("/", 1)[-1] if p != "synth" else "") + f, gain_db=g, pitch=pi)
                    for p, f, g, pi, d in spec["layers"]]
            rows.append(dict(file=name + ".ogg", kind=spec["kind"], seconds=round(dur, 3), bytes=os.path.getsize(dst), sources=srcs))
            print(f"{name:24s} {dur:7.3f}s {os.path.getsize(dst)/1024:7.1f} KB")
    if a.manifest: json.dump(rows, open(a.manifest, "w"), indent=1)
