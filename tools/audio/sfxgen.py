#!/usr/bin/env python3
"""Swipe sfxgen: tiny sfxr-style synthesizer for the gaps no CC0 pack covers.

Deterministic (seeded), CC0 output (self-generated for Swipe).
Requires: numpy, scipy, soundfile.  Writes 48 kHz mono 16-bit WAVs to --out
(build_audio.py then encodes them to OGG Vorbis).

    python3 tools/audio/sfxgen.py --out /tmp/swipe_synth
"""
import argparse, os
import numpy as np
from scipy import signal
import soundfile as sf

SR = 48000

def t_axis(dur): return np.arange(int(SR * dur)) / SR

def env_adsr(n, a=0.002, d=0.05, s=0.0, r=0.05, hold=0.0):
    a_n, d_n, h_n, r_n = (int(SR * v) for v in (a, d, hold, r))
    e = np.concatenate([np.linspace(0, 1, max(a_n, 1)),
                        np.linspace(1, s, max(d_n, 1)) if s < 1 else np.ones(max(d_n, 1)),
                        np.full(h_n, s),
                        np.linspace(s, 0, max(r_n, 1))])
    if len(e) < n: e = np.pad(e, (0, n - len(e)))
    return e[:n]

def env_exp(n, tau):
    return np.exp(-np.arange(n) / (SR * tau))

def osc(freq, kind="sine", duty=0.5, rng=None):
    """freq: array (Hz per sample)."""
    ph = 2 * np.pi * np.cumsum(freq) / SR
    if kind == "sine": return np.sin(ph)
    if kind == "square": return signal.square(ph, duty)
    if kind == "saw": return signal.sawtooth(ph)
    if kind == "tri": return signal.sawtooth(ph, 0.5)
    raise ValueError(kind)

def noise(n, rng): return rng.uniform(-1, 1, n)

def filt(x, kind, f, order=2, q=None):
    if kind == "bp":
        b, a = signal.butter(order, [f[0] / (SR / 2), f[1] / (SR / 2)], "band")
    else:
        b, a = signal.butter(order, f / (SR / 2), kind)
    return signal.lfilter(b, a, x)

def resonator(x, f, decay):
    """2-pole resonant filter (wood/body ring)."""
    r = np.exp(-1 / (SR * decay)); w = 2 * np.pi * f / SR
    return signal.lfilter([1 - r], [1, -2 * r * np.cos(w), r * r], x)

def finish(x, peak_db=-1.0, fade_ms=3):
    x = x - np.mean(x)
    fn = int(SR * fade_ms / 1000)
    if fn > 1: x[-fn:] *= np.linspace(1, 0, fn)
    m = np.max(np.abs(x)) or 1
    return (x / m * 10 ** (peak_db / 20)).astype(np.float32)

# ---------------------------------------------------------------- recipes
def wheel_tick(rng, body=1800, ring=0.012, click=0.0025):
    """Wooden ratchet pawl: noise click into two wood resonators."""
    n = int(SR * 0.05)
    exc = noise(n, rng) * env_exp(n, click)
    x = resonator(exc, body, ring) * 1.0 + resonator(exc, body * 2.37, ring * 0.6) * 0.5
    x += filt(exc, "highpass", 4000) * 0.35
    return finish(x)

def wheel_detent(rng):
    """Final 'clunk' when the wheel settles: lower, longer tick + thump."""
    n = int(SR * 0.16)
    exc = noise(n, rng) * env_exp(n, 0.004)
    x = resonator(exc, 900, 0.03) + 0.6 * resonator(exc, 2100, 0.015)
    t = t_axis(0.16)
    x += 0.8 * np.sin(2 * np.pi * (140 - 60 * t / 0.16) * t) * env_exp(n, 0.03)
    return finish(x)

def nib_blip(rng, base, glide, vowel, dur=0.075):
    """Goblin gibberish syllable: pulse wave with pitch glide through 2 formants."""
    t = t_axis(dur); n = len(t)
    f = base * (1 + glide * t / dur) * (1 + 0.03 * np.sin(2 * np.pi * 28 * t))
    src = osc(f, "square", duty=0.3)
    f1, f2 = vowel
    x = filt(src, "bp", (f1 * 0.8, f1 * 1.25)) * 1.0 + filt(src, "bp", (f2 * 0.85, f2 * 1.2)) * 0.6
    x += 0.15 * src
    x *= env_adsr(n, a=0.004, d=0.02, s=0.7, r=0.03, hold=dur - 0.06)
    return finish(x, -1.0)

VOWELS = {"a": (750, 1200), "e": (500, 1900), "i": (320, 2300), "o": (480, 850), "u": (350, 700), "ae": (650, 1700)}

def ui_hover_soft(rng, f0=1400):
    """Soft wooden 'tok' for title/settings hover (quieter cousin of hover.wav)."""
    n = int(SR * 0.04)
    exc = noise(n, rng) * env_exp(n, 0.0012)
    x = resonator(exc, f0, 0.006) + 0.4 * resonator(exc, f0 * 1.9, 0.004)
    return finish(x)

def smoke_poof(rng):
    """Comic smoke-bomb poof: noise burst, falling bandpass, little pop at front."""
    dur = 0.55; t = t_axis(dur); n = len(t)
    x = noise(n, rng)
    out = np.zeros(n); hop = 480
    for i in range(0, n, hop):
        fc = 2600 * np.exp(-3.2 * i / n) + 250
        seg = filt(x[max(0, i - 2000):i + hop], "bp", (fc * 0.6, min(fc * 1.6, 20000)))[-hop:]
        out[i:i + len(seg)] = seg[:n - i]
    out *= env_adsr(n, a=0.01, d=0.08, s=0.55, r=0.38, hold=0.06)
    pop = np.sin(2 * np.pi * (300 - 200 * t) * t) * env_exp(n, 0.015)
    return finish(out + 0.7 * pop)

def heal_sparkle(rng):
    """Warm rising 3-note bell arpeggio (C6 E6 G6) for Heal."""
    dur = 0.6; n = int(SR * dur); x = np.zeros(n)
    for k, (f, d) in enumerate([(1046.5, 0.0), (1318.5, 0.07), (1568.0, 0.14)]):
        o = int(SR * d); m = n - o; t = np.arange(m) / SR
        tone = np.sin(2 * np.pi * f * t) + 0.3 * np.sin(2 * np.pi * f * 2.76 * t) * env_exp(m, 0.05)
        x[o:] += tone * env_exp(m, 0.18) * env_adsr(m, 0.004, 0.01, 1, 0.01, hold=dur) * (0.9 - 0.15 * k)
    return finish(x)

def poison_bubbles(rng):
    """Bubbling cauldron blips: sine bubbles with upward chirp."""
    dur = 0.7; n = int(SR * dur); x = np.zeros(n)
    for _ in range(9):
        o = int(rng.uniform(0, dur - 0.08) * SR); bd = rng.uniform(0.03, 0.06); m = int(SR * bd)
        t = np.arange(m) / SR; f0 = rng.uniform(300, 700)
        b = np.sin(2 * np.pi * np.cumsum(f0 * (1 + 2.5 * t / bd)) / SR) * env_adsr(m, 0.003, bd * 0.3, 0.6, bd * 0.5)
        x[o:o + m] += b * rng.uniform(0.5, 1)
    return finish(filt(x, "lowpass", 3000))

def hypno_wobble(rng):
    """Pocketwatch hypnotize: tick-tock + detuned vibrato sine swirl."""
    dur = 1.1; t = t_axis(dur); n = len(t)
    f = 520 * (1 + 0.12 * np.sin(2 * np.pi * 5.5 * t)) * (1 - 0.25 * t / dur)
    x = 0.6 * osc(f, "sine") + 0.4 * osc(f * 1.505, "sine")
    x *= env_adsr(n, 0.08, 0.1, 0.8, 0.5, hold=0.4)
    for k, o in enumerate([0.0, 0.32, 0.64]):
        i = int(o * SR); m = int(0.03 * SR)
        exc = noise(m, rng) * env_exp(m, 0.002)
        x[i:i + m] += 0.8 * resonator(exc, 3200 if k % 2 == 0 else 2600, 0.01)
    return finish(x)

def glint_ting(rng):
    """Tiny high sparkle for plaque glint."""
    dur = 0.35; t = t_axis(dur); n = len(t)
    x = np.sin(2 * np.pi * 3520 * t) + 0.5 * np.sin(2 * np.pi * 5274 * t) * env_exp(n, 0.04)
    return finish(x * env_exp(n, 0.09) * env_adsr(n, 0.001, 0.01, 1, 0.01, hold=dur))

def leech_pulse(rng):
    """Wet suction pulse: lowpassed noise swell + falling sine 'slurp'."""
    dur = 0.28; t = t_axis(dur); n = len(t)
    x = filt(noise(n, rng), "bp", (200, 900)) * env_adsr(n, 0.05, 0.05, 0.6, 0.15, hold=0.03)
    x += 0.8 * np.sin(2 * np.pi * np.cumsum(420 - 250 * t / dur) / SR) * env_adsr(n, 0.02, 0.05, 0.6, 0.15, hold=0.05)
    return finish(x)

def gob_oof(rng, base=210):
    """Player goblin 'hrk!' when hurt: short falling formant blip."""
    return nib_blip(rng, base, -0.45, VOWELS["u"], dur=0.12)

def hornet_buzz(rng):
    dur = 0.5; t = t_axis(dur); n = len(t)
    f = 190 * (1 + 0.04 * np.sin(2 * np.pi * 9 * t)) + rng.normal(0, 2, n)
    x = osc(f, "saw") * (1 + 0.5 * np.sin(2 * np.pi * 31 * t))
    x = filt(x, "bp", (300, 2500)) * env_adsr(n, 0.04, 0.05, 0.8, 0.15, hold=0.25)
    return finish(x)

def magnet_zing(rng):
    dur = 0.35; t = t_axis(dur); n = len(t)
    f = 300 * np.exp(2.2 * t / dur)
    x = osc(f, "tri") * env_adsr(n, 0.005, 0.05, 0.7, 0.12, hold=0.15)
    x += 0.4 * osc(f * 2.01, "sine") * env_exp(n, 0.1)
    return finish(x)

RECIPES = {}
def reg(name, fn, *a, **k): RECIPES[name] = (fn, a, k)

reg("wheel_tick_a", wheel_tick, body=1800); reg("wheel_tick_b", wheel_tick, body=1650, ring=0.010)
reg("wheel_tick_c", wheel_tick, body=1950, ring=0.014); reg("wheel_detent", wheel_detent)
for i, (b, g, v) in enumerate([(310, 0.25, "a"), (360, -0.2, "e"), (280, 0.4, "o"), (400, -0.3, "i"),
                               (330, 0.1, "ae"), (290, -0.35, "u"), (380, 0.5, "a"), (340, -0.1, "o")]):
    reg(f"nib_blip_{i+1:02d}", nib_blip, b, g, VOWELS[v])
for i, (b, g, v) in enumerate([(140, 0.15, "o"), (120, -0.25, "a"), (160, 0.3, "u"), (130, -0.1, "ae")]):
    reg(f"monster_blip_{i+1:02d}", nib_blip, b, g, VOWELS[v], dur=0.1)
reg("ui_hover_soft_a", ui_hover_soft, 1400); reg("ui_hover_soft_b", ui_hover_soft, 1250)
reg("smoke_poof", smoke_poof); reg("heal_sparkle", heal_sparkle); reg("status_poison", poison_bubbles)
reg("status_hypnotize", hypno_wobble); reg("cabin_glint", glint_ting); reg("mon_leech_pulse", leech_pulse)
reg("gob_oof_a", gob_oof, 210); reg("gob_oof_b", gob_oof, 235); reg("mon_hornet_buzz", hornet_buzz)
reg("util_magnet", magnet_zing)

if __name__ == "__main__":
    ap = argparse.ArgumentParser(); ap.add_argument("--out", required=True); ap.add_argument("--only", nargs="*")
    a = ap.parse_args(); os.makedirs(a.out, exist_ok=True)
    for i, (name, (fn, args, kw)) in enumerate(sorted(RECIPES.items())):
        if a.only and name not in a.only: continue
        rng = np.random.default_rng(sum(map(ord, name)) * 7919)  # stable seed per recipe
        sf.write(os.path.join(a.out, name + ".wav"), fn(rng, *args, **kw), SR, subtype="PCM_16")
        print("wrote", name)
