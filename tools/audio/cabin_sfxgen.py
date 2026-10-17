#!/usr/bin/env python3
"""Cabin-overhaul synth recipes (CC0, self-generated for Swipe). Reuses the helpers in tools/audio/sfxgen.py.

    python3 tools/audio/cabin_sfxgen.py --out /tmp/swipe_cabin_synth
"""
import argparse, os, sys
import numpy as np
import soundfile as sf
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sfxgen import SR, t_axis, env_adsr, env_exp, osc, noise, filt, resonator, finish, nib_blip, VOWELS  # noqa

R = {}
def reg(name, fn, *a, **k): R[name] = (fn, a, k)

def wood_tap(rng, f=900, decay=0.03, dur=0.12):
    n = int(SR * dur); x = noise(n, rng) * env_exp(n, 0.002)
    y = resonator(x, f, decay) + 0.5 * resonator(x, f * 2.3, decay * 0.5)
    return finish(filt(y, "high", 180.0))

def metal_ping(rng, f, dur=0.5, decay=0.12):
    t = t_axis(dur); n = len(t)
    x = sum(a * np.sin(2 * np.pi * f * m * t + rng.uniform(0, 6)) * env_exp(n, decay / m ** 0.5) for m, a in ((1, 1), (2.76, .5), (5.4, .25), (8.9, .12)))
    return x * env_adsr(n, 0.0005, 0.01, 1, 0.01, hold=dur)

def key_jingle(rng):
    dur = 0.9; n = int(SR * dur); out = np.zeros(n)
    for k in range(9):
        s = int(SR * (rng.uniform(0, 0.55))); f = rng.uniform(2600, 4800)
        p = metal_ping(rng, f, 0.3, 0.05) * rng.uniform(0.4, 1.0)
        out[s: s + len(p)] += p[: n - s]
    clank = noise(n, rng) * env_exp(n, 0.01); out += 0.3 * filt(clank, "bp", (1500.0, 5000.0))
    return finish(out)

def radio_static(rng, dur=4.0):
    n = int(SR * dur); x = filt(noise(n, rng), "bp", (700.0, 4200.0)) * 0.5
    crk = (rng.uniform(0, 1, n) > 0.9994) * rng.uniform(-1, 1, n); x += resonator(crk, 2500, 0.002) * 3
    hum = 0.08 * np.sin(2 * np.pi * 60 * t_axis(dur)) + 0.04 * np.sin(2 * np.pi * 120 * t_axis(dur))
    x = x + hum
    f = int(SR * 0.4); w = np.linspace(0, 1, f); x[:f] = x[:f] * w + x[-f:] * (1 - w); x = x[: n - f]   # loop-safe wrap
    return finish(x, -3, 0)

def radio_tune(rng):
    dur = 0.7; t = t_axis(dur); n = len(t)
    sweep = 900 + 1800 * np.sin(np.linspace(0, np.pi, n)) ** 2
    wh = osc(sweep, "sine") * 0.35 * env_adsr(n, 0.05, 0.1, 0.8, 0.2, hold=0.3)
    st = filt(noise(n, rng), "bp", (900.0, 5000.0)) * (0.6 - 0.4 * np.sin(np.linspace(0, np.pi, n)))
    return finish(wh + st * env_adsr(n, 0.01, 0.1, 0.9, 0.15, hold=0.4))

def radio_on(rng):
    dur = 0.9; t = t_axis(dur); n = len(t)
    f = 60 + 60 * (1 - np.exp(-t * 6)); hum = osc(f, "saw") * 0.3; hum = filt(hum, "low", 600.0)
    return finish((hum + 0.2 * filt(noise(n, rng), "bp", (1000.0, 4000.0)) * np.linspace(0, 1, n)) * env_adsr(n, 0.15, 0.1, 1, 0.2, hold=0.5))

def item_pop(rng, f0=700):
    dur = 0.16; t = t_axis(dur); n = len(t)
    f = f0 * 2 ** (np.linspace(0, 1.2, n)); x = osc(f, "sine") * env_exp(n, 0.035)
    return finish(x + 0.3 * filt(noise(n, rng), "high", 2500.0) * env_exp(n, 0.006))

def sparkle(rng, base=2093, notes=(0, 4, 7, 12, 16), dur=0.9):
    n = int(SR * dur); out = np.zeros(n)
    for k, st in enumerate(notes):
        s = int(SR * 0.045 * k); p = metal_ping(rng, base * 2 ** (st / 12), 0.5, 0.09) * (0.9 - 0.1 * k)
        out[s: s + len(p)] += p[: n - s]
    return finish(out)

def whoosh(rng, dur=0.45, lo=400, hi=3000, up=True):
    n = int(SR * dur); x = noise(n, rng); e = np.sin(np.linspace(0, np.pi, n)) ** 2
    seg = 24; out = np.zeros(n); L_ = n // seg
    for k in range(seg):
        c = lo + (hi - lo) * (k / seg if up else 1 - k / seg); a, b = k * L_, (k + 1) * L_
        out[a:b] = filt(x, "bp", (c * 0.7, c * 1.3))[a:b]
    return finish(out * e, -2)

def shelf_chime(rng):
    return sparkle(rng, 1568, (0, 7), 1.2)

def low_rumble(rng, dur=1.4):
    n = int(SR * dur); x = filt(noise(n, rng), "low", 120.0) * 4 + 0.3 * np.sin(2 * np.pi * 42 * t_axis(dur))
    return finish(x * env_adsr(n, 0.2, 0.2, 0.8, 0.6, hold=0.5))

def moth_flutter(rng):
    dur = 0.6; n = int(SR * dur); t = t_axis(dur)
    am = (np.sin(2 * np.pi * 22 * t) > 0.3).astype(float)
    return finish(filt(noise(n, rng), "bp", (300.0, 1400.0)) * am * env_adsr(n, 0.05, 0.1, 0.7, 0.2, hold=0.3), -6)

def psst(rng):
    dur = 0.55; n = int(SR * dur); x = filt(noise(n, rng), "bp", (2500.0, 7000.0))
    e = np.concatenate([env_adsr(int(SR * .09), 0.003, 0.02, 0.4, 0.04, hold=0.03), np.zeros(int(SR * .06)), env_adsr(n - int(SR * .15), 0.01, 0.05, 0.8, 0.12, hold=0.2)])
    p = np.zeros(n); p[: int(SR * 0.012)] = filt(noise(int(SR * 0.012), rng), "low", 800.0) * 2
    return finish(x * e[:n] + p)

def blip_seq(rng, specs, gap=0.07):
    parts = []
    for base, glide, v in specs:
        parts.append(nib_blip(rng, base, glide, VOWELS[v])); parts.append(np.zeros(int(SR * gap)))
    return finish(np.concatenate(parts))

def gob_voice(rng, f0, f1, dur, vowel_f=(700, 1200)):
    t = t_axis(dur); n = len(t); f = np.linspace(f0, f1, n) * (1 + 0.02 * np.sin(2 * np.pi * 6 * t))
    x = osc(f, "saw"); y = filt(x, "bp", (vowel_f[0] * 0.7, vowel_f[0] * 1.3)) + 0.6 * filt(x, "bp", (vowel_f[1] * 0.8, vowel_f[1] * 1.2))
    return finish(y * env_adsr(n, 0.01, 0.05, 0.8, 0.08, hold=dur * 0.6))

def sigh(rng):
    dur = 0.9; n = int(SR * dur); x = filt(noise(n, rng), "bp", (500.0, 2200.0))
    v = gob_voice(rng, 190, 120, dur, (600, 1000)) * 0.25
    return finish(x * env_adsr(n, 0.12, 0.2, 0.6, 0.4, hold=0.2) + v)

def cog_tick(rng):
    return finish(np.concatenate([wood_tap(rng, 3200, 0.006, 0.05) * 0.8, np.zeros(int(SR * 0.04)), wood_tap(rng, 2600, 0.006, 0.05)]))

reg("cab_hover_wood_a", wood_tap, 950, 0.02, 0.09); reg("cab_hover_wood_b", wood_tap, 1080, 0.02, 0.09)
reg("cab_key_jingle", key_jingle); reg("cab_radio_static_loop", radio_static); reg("cab_radio_tune", radio_tune); reg("cab_radio_on", radio_on)
reg("cab_item_pop_a", item_pop, 700); reg("cab_item_pop_b", item_pop, 820); reg("cab_item_burst", sparkle)
reg("cab_item_whoosh", whoosh, 0.45, 500, 3500, True); reg("cab_panel_whoosh", whoosh, 0.35, 300, 1400, False)
reg("cab_shelf_chime", shelf_chime); reg("cab_hole_rumble", low_rumble); reg("cab_moth", moth_flutter)
reg("cab_nib_psst", psst)
reg("cab_nib_gasp", blip_seq, [(300, 1.5, "o"), (420, 1.4, "a")], 0.03)
reg("cab_nib_chuckle", blip_seq, [(420, 0.9, "e"), (380, 0.9, "e"), (340, 0.85, "u")], 0.05)
reg("cab_hero_yip", gob_voice, 260, 420, 0.22, (800, 1500)); reg("cab_hero_sigh", sigh)
reg("cab_cog_tick", cog_tick); reg("cab_unlock_glint", sparkle, 2637, (0, 7, 12), 0.6)

def drawer_slide(rng, dur=0.42):
    """wooden drawer dragged open: band-passed friction noise with a stick-slip chatter, rising slightly"""
    n = int(SR * dur); t = t_axis(dur)
    chatter = 0.55 + 0.45 * (np.sin(2 * np.pi * (28 + 18 * t / dur) * t) > 0.2)
    x = filt(noise(n, rng), "bp", (260.0, 1600.0)) * chatter
    body = resonator(filt(noise(n, rng), "low", 600.0) * 0.6, 180, 0.04)
    return finish((x + 0.5 * body) * env_adsr(n, 0.03, 0.05, 0.9, 0.08, hold=dur * 0.7))

reg("cab_drawer_slide", drawer_slide); reg("cab_geode_chime", sparkle, 1319, (0, 3, 7, 12), 1.0)

if __name__ == "__main__":
    ap = argparse.ArgumentParser(); ap.add_argument("--out", required=True); a = ap.parse_args(); os.makedirs(a.out, exist_ok=True)
    LATE = ["cab_drawer_slide", "cab_geode_chime"]          # added later: own seeds, so the original files rebuild bit-identical
    ORIG = sorted(k for k in R if k not in LATE)
    for name, (fn, args, kw) in sorted(R.items()):
        rng = np.random.default_rng(9000 + ORIG.index(name) if name in ORIG else 9500 + LATE.index(name))
        sf.write(os.path.join(a.out, name + ".wav"), fn(rng, *args, **kw), SR, subtype="PCM_16")
    print(len(R), "synth wavs ->", a.out)
