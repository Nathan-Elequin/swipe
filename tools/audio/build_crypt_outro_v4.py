#!/usr/bin/env python3
"""Ashen Crypt victory-outro demo v4: shift outro 1/64 note earlier vs the loop.

Nathan heard the v3 outro ~1/64 too late. Keep v3's baked clip and the loop's
full-bar linear fade (1->0 from 14.867250 to 16.991146). Place the outro so
extend 0.216146s (the downbeat) lands 1/64 note before the loop bar line.
"""
from __future__ import annotations

import json
import re
import subprocess
from pathlib import Path

import numpy as np
import soundfile as sf

DIR = Path("/workspace/crypt_outro")
SR = 48000
BPM = 113.0
BEAT_S = 60.0 / BPM
BAR_S = 4.0 * BEAT_S
SIXTYFOURTH_S = BAR_S / 64.0  # 0.033185840707964604
TP_CEILING_DB = -1.0

DOWNBEAT_EXT_SAMP = 10375  # 0.21614583333333334 s
BOOM_EXT_SAMP = 112382
PREROLL_SAMP = 6372  # 0.13275 s
FULL_GAIN_AFTER_SAMP = 144  # 3 ms
LOOP_START_SAMP = 1019469
BAR_LINE_DEMO_SAMP = 713628  # 14.86725 s
COMBAT_END_DEMO_S = 13.243354166666666
GAIN_DB = -5.70
LOOP_RAMP_SAMP = int(round(BAR_S * SR))  # 101947
LOOP_SILENT_DEMO_SAMP = BAR_LINE_DEMO_SAMP + LOOP_RAMP_SAMP  # 815575 = 16.9911458333 s

# Shift outro earlier by 1/64 note (nearest sample)
SHIFT_SAMP = int(round(SIXTYFOURTH_S * SR))  # 1593 = 0.0331875 s
OUTRO_DOWNBEAT_DEMO_SAMP = BAR_LINE_DEMO_SAMP - SHIFT_SAMP  # 712035 = 14.8340625 s
CLIP_START_DEMO_SAMP = OUTRO_DOWNBEAT_DEMO_SAMP - PREROLL_SAMP  # 705663 = 14.7013125 s
OUTRO_FULL_DEMO_SAMP = OUTRO_DOWNBEAT_DEMO_SAMP + FULL_GAIN_AFTER_SAMP  # 712179
BOOM_DEMO_SAMP = OUTRO_DOWNBEAT_DEMO_SAMP + (BOOM_EXT_SAMP - DOWNBEAT_EXT_SAMP)
LEAD_VS_BAR_SAMP = PREROLL_SAMP + SHIFT_SAMP  # clip start vs loop bar line


def load(path: Path) -> np.ndarray:
    y, sr = sf.read(path, always_2d=True)
    if sr != SR:
        raise SystemExit(f"{path} sr={sr}, expected {SR}")
    return y.astype(np.float64)


def linear_ramp(n: int, start: float, end: float) -> np.ndarray:
    if n <= 1:
        return np.array([end], dtype=np.float64) if n == 1 else np.zeros(0, dtype=np.float64)
    return np.linspace(start, end, n, endpoint=True, dtype=np.float64)


def write_wav24(path: Path, y: np.ndarray) -> None:
    sf.write(path, y, SR, subtype="PCM_24")


def encode_ogg(wav_path: Path, ogg_path: Path) -> None:
    subprocess.run(
        [
            "ffmpeg", "-y", "-hide_banner", "-loglevel", "error",
            "-i", str(wav_path), "-c:a", "libvorbis", "-b:a", "192k", str(ogg_path),
        ],
        check=True,
    )


def ebur128(path: Path) -> dict:
    proc = subprocess.run(
        ["ffmpeg", "-hide_banner", "-i", str(path), "-af", "ebur128=peak=true", "-f", "null", "-"],
        check=True, capture_output=True, text=True,
    )
    text = proc.stderr + "\n" + proc.stdout
    m = re.search(r"Summary:\s*(.*)$", text, re.S)
    block = m.group(1) if m else text
    integ = lra = tp = None
    im = re.search(r"\bI:\s*([-\d.]+)\s*LUFS", block)
    lm = re.search(r"\bLRA:\s*([-\d.]+)\s*LU", block)
    tm = re.search(r"True peak:\s*Peak:\s*([-\d.]+)\s*dBFS", block)
    if im:
        integ = float(im.group(1))
    if lm:
        lra = float(lm.group(1))
    if tm:
        tp = float(tm.group(1))
    return {"integrated_lufs": integ, "lra": lra, "true_peak_dbfs": tp}


def sha256(path: Path) -> str:
    proc = subprocess.run(["sha256sum", str(path)], check=True, capture_output=True, text=True)
    return proc.stdout.split()[0]


def rms(y: np.ndarray) -> float:
    return float(np.sqrt(np.mean(np.square(y))))


def db(x: float, eps: float = 1e-12) -> float:
    return 20.0 * np.log10(max(float(x), eps))


def main() -> None:
    A = load(DIR / "music_ashen_crypt_a.ogg")
    B = load(DIR / "music_ashen_crypt_b.ogg")
    C = load(DIR / "music_ashen_crypt_c.ogg")
    clip = load(DIR / "music_ashen_crypt_victory_v2.wav")

    gain_A = (10.0 ** (-2.0 / 20.0)) * 0.5
    gain_B = 10.0 ** (-2.0 / 20.0)
    gain_C = 10.0 ** (-2.0 / 20.0)
    loop_src = (
        A[LOOP_START_SAMP:] * gain_A
        + B[LOOP_START_SAMP:] * gain_B
        + C[LOOP_START_SAMP:] * gain_C
    )

    demo_len = CLIP_START_DEMO_SAMP + clip.shape[0]
    demo = np.zeros((demo_len, 2), dtype=np.float64)

    # Loop: full through the (now earlier) pre-roll and through the loop bar line,
    # then linear 1->0 over one bar — same as v3, not shifted.
    demo[:BAR_LINE_DEMO_SAMP] = loop_src[:BAR_LINE_DEMO_SAMP]
    ramp = linear_ramp(LOOP_RAMP_SAMP, 1.0, 0.0)
    end = min(BAR_LINE_DEMO_SAMP + LOOP_RAMP_SAMP, loop_src.shape[0], demo_len)
    n = end - BAR_LINE_DEMO_SAMP
    demo[BAR_LINE_DEMO_SAMP:end] = loop_src[BAR_LINE_DEMO_SAMP:end] * ramp[:n, None]

    demo[CLIP_START_DEMO_SAMP : CLIP_START_DEMO_SAMP + clip.shape[0]] += clip

    print(f"pre-trim demo sample peak {db(float(np.max(np.abs(demo)))):.3f} dBFS")
    print(f"demo_len {demo_len} = {demo_len/SR:.6f}s")
    print(f"shift {SHIFT_SAMP} samp = {SHIFT_SAMP/SR:.9f}s (64th exact {SIXTYFOURTH_S:.9f}s)")
    print(f"outro downbeat demo {OUTRO_DOWNBEAT_DEMO_SAMP/SR:.9f}s  (parent target 14.834064)")

    demo_path_wav = DIR / "demo_crypt_outro_v4.wav"
    write_wav24(demo_path_wav, demo)
    meas = ebur128(demo_path_wav)
    tp = meas["true_peak_dbfs"]
    pad_db = 0.0
    if tp is not None and tp > TP_CEILING_DB:
        pad_db = TP_CEILING_DB - tp
        demo *= 10.0 ** (pad_db / 20.0)
        print(f"true peak {tp:.2f} dBTP exceeds ceiling; applying {pad_db:.3f} dB trim")
        write_wav24(demo_path_wav, demo)
        meas = ebur128(demo_path_wav)
    else:
        print(f"true peak {tp} dBTP within ceiling; no trim")

    encode_ogg(demo_path_wav, DIR / "demo_crypt_outro_v4.ogg")

    grid = json.loads((DIR / "loop_bar_grid_analysis.json").read_text())

    # Verify outro placement vs v3: v3 downbeat at 713628, v4 at 712035
    # Baked fade at clip index PREROLL should sit at OUTRO_DOWNBEAT
    clip_at_downbeat = clip[PREROLL_SAMP]
    # loop still full there (14.834 < 14.867)
    residual = float(np.max(np.abs(
        demo[OUTRO_DOWNBEAT_DEMO_SAMP] - (loop_src[OUTRO_DOWNBEAT_DEMO_SAMP] * (10 ** (pad_db / 20) if pad_db else 1) + clip_at_downbeat * (10 ** (pad_db / 20) if pad_db else 1))
    )))
    loop_at_bar = 1.0
    loop_at_silent = float(np.max(np.abs(demo[LOOP_SILENT_DEMO_SAMP:LOOP_SILENT_DEMO_SAMP + 48] - (
        # outro only after loop silent; clip index =
        # LOOP_SILENT - CLIP_START
        clip[LOOP_SILENT_DEMO_SAMP - CLIP_START_DEMO_SAMP : LOOP_SILENT_DEMO_SAMP - CLIP_START_DEMO_SAMP + 48]
        if LOOP_SILENT_DEMO_SAMP + 48 <= demo_len else 0
    )))) if LOOP_SILENT_DEMO_SAMP < demo_len else None

    # Loop gain at the (shifted) boom
    if BAR_LINE_DEMO_SAMP <= BOOM_DEMO_SAMP < LOOP_SILENT_DEMO_SAMP:
        loop_gain_at_boom = float(ramp[BOOM_DEMO_SAMP - BAR_LINE_DEMO_SAMP])
    elif BOOM_DEMO_SAMP >= LOOP_SILENT_DEMO_SAMP:
        loop_gain_at_boom = 0.0
    else:
        loop_gain_at_boom = 1.0

    times = {
        "sixtyfourth_exact_s": SIXTYFOURTH_S,
        "sixtyfourth_used_s": SHIFT_SAMP / SR,
        "sixtyfourth_samples": SHIFT_SAMP,
        "preroll_s": PREROLL_SAMP / SR,
        "outro_lead_vs_bar_line_s": LEAD_VS_BAR_SAMP / SR,  # preroll + 64th
        "combat_end_demo_s": int(round(COMBAT_END_DEMO_S * SR)) / SR,
        "outro_fade_start_demo_s": CLIP_START_DEMO_SAMP / SR,
        "outro_downbeat_demo_s": OUTRO_DOWNBEAT_DEMO_SAMP / SR,
        "outro_full_demo_s": OUTRO_FULL_DEMO_SAMP / SR,
        "loop_bar_line_demo_s": BAR_LINE_DEMO_SAMP / SR,
        "loop_ramp_start_demo_s": BAR_LINE_DEMO_SAMP / SR,
        "loop_silent_demo_s": LOOP_SILENT_DEMO_SAMP / SR,
        "boom_demo_s": BOOM_DEMO_SAMP / SR,
        "file_end_demo_s": demo.shape[0] / SR,
        "clip_duration_s": clip.shape[0] / SR,
        "bar_period_s": BAR_S,
    }

    wiring = {
        "outro_style": "splice_plus_loop_bar_fade",
        "bar_period_s": BAR_S,
        "preroll_s": PREROLL_SAMP / SR,
        "outro_grid_lead_s": SHIFT_SAMP / SR,
        "outro_grid_lead": "1/64 note earlier than the loop bar line (Nathan v3 feedback)",
        "outro_lead_vs_bar_line_s": LEAD_VS_BAR_SAMP / SR,
        "outro_lead_vs_bar_line": (
            f"clip starts preroll_s + 1/64 before the loop bar line "
            f"({PREROLL_SAMP/SR:.6f} + {SHIFT_SAMP/SR:.6f} = {LEAD_VS_BAR_SAMP/SR:.6f}s). "
            f"The baked downbeat (extend 0.216146s) lands {SHIFT_SAMP/SR:.6f}s before the bar line."
        ),
        "outro": (
            "Same baked clip as v2/v3 (music_ashen_crypt_victory_v2): linear fade-in, "
            "full at downbeat + 3 ms, -5.70 dB baked, engine gain 0 dB. "
            "Start the clip (preroll + 1/64) before the loop's next bar line."
        ),
        "loop_ramp": (
            "Unchanged from v3: linear 1->0 over 1.0 * bar_period_s starting at the "
            f"loop bar line ({BAR_LINE_DEMO_SAMP/SR:.6f}s), silence at "
            f"{LOOP_SILENT_DEMO_SAMP/SR:.6f}s. Loop stays full through the outro pre-roll."
        ),
        "loop_ramp_frac_of_bar": 1.0,
        "loop_ramp_s": LOOP_RAMP_SAMP / SR,
        "engine_gain_db": 0.0 if pad_db == 0.0 else pad_db,
        "true_peak_pad_db": pad_db,
        "gain_baked_db": GAIN_DB,
        "note": (
            "Because the outro (and its boom) moved 1/64 earlier, the boom now lands "
            f"{(LOOP_SILENT_DEMO_SAMP - BOOM_DEMO_SAMP)/SR*1000:.2f} ms before the loop "
            "reaches silence. Loop gain at the boom is small but not zero."
        ),
    }

    report = {
        "version": 4,
        "tempos": {"credits_and_loop_bpm": BPM, "beat_s": BEAT_S, "bar_production_s": BAR_S, "sixtyfourth_s": SIXTYFOURTH_S},
        "times": times,
        "mix": {
            "A_db": -2.0, "A_boss_lin": 0.5, "B_db": -2.0, "C_db": -2.0,
            "musical_gain_offset_db": GAIN_DB, "true_peak_pad_db": pad_db,
            "clip_source": "music_ashen_crypt_victory_v2.wav (unchanged)",
        },
        "loudness": {"demo_ebur128": meas},
        "sfx_map": wiring,
        "loop_grid": {
            "assumed_bar_line_demo_s": grid["assumed_bar_line_demo_s"],
            "measured_bar7_onset_s": grid["measured_bar7_onset_s"],
            "measured_bar7_interpolated_s": 14.812640,
            "measured_bar7_offset_ms": grid["measured_bar7_offset_ms"],
            "measured_bar7_interpolated_offset_ms": (14.812640 - 14.867250) * 1000,
            "strong_bars_n": grid["strong_bars_n"],
            "strong_bars_mean_offset_ms": grid["strong_bars_mean_offset_ms"],
            "strong_bars_median_offset_ms": grid["strong_bars_median_offset_ms"],
            "strong_bars_std_ms": grid["strong_bars_std_ms"],
            "note": (
                "Loop drum downbeats are consistently early of the assumed 113 BPM grid "
                "from t=0 / loop-start (phase offset, not a drifting tempo: std 2.7 ms "
                "across 12 strong bars). Bar 7 interpolated onset is 14.812640 s "
                "(-54.61 ms vs assumed 14.867250). Nathan's 1/64 shift (33.19 ms) is in "
                "the right direction but smaller than the measured ~55 ms. After v4, the "
                "outro downbeat at 14.834063 s is still ~21.4 ms later than the measured "
                "loop downbeat (about one 96th-note; bar/96 = 22.12 ms)."
            ),
        },
        "verify": {
            "sum_residual_at_outro_downbeat": residual,
            "loop_gain_at_loop_bar_line": loop_at_bar,
            "loop_gain_at_boom": loop_gain_at_boom,
            "loop_residual_at_next_bar_line": loop_at_silent,
            "demo_sample_peak_dbfs": db(float(np.max(np.abs(demo)))),
        },
        "sha256": {
            "demo_crypt_outro_v4.ogg": sha256(DIR / "demo_crypt_outro_v4.ogg"),
            "demo_crypt_outro_v4.wav": sha256(DIR / "demo_crypt_outro_v4.wav"),
        },
        "samples": {
            "clip_start_demo": CLIP_START_DEMO_SAMP,
            "outro_downbeat_demo": OUTRO_DOWNBEAT_DEMO_SAMP,
            "shift": SHIFT_SAMP,
            "bar_line_demo": BAR_LINE_DEMO_SAMP,
            "loop_silent_demo": LOOP_SILENT_DEMO_SAMP,
            "boom_demo": BOOM_DEMO_SAMP,
            "demo_len": demo.shape[0],
            "clip_len": clip.shape[0],
        },
    }
    (DIR / "demo_report_v4.json").write_text(json.dumps(report, indent=2) + "\n")

    print("\n=== TIMELINE (demo v4) ===")
    print(f"combat end          {times['combat_end_demo_s']:.6f}s")
    print(f"outro fade start    {times['outro_fade_start_demo_s']:.6f}s")
    print(f"outro downbeat      {times['outro_downbeat_demo_s']:.6f}s  (1/64 before loop bar)")
    print(f"outro full          {times['outro_full_demo_s']:.6f}s  (downbeat+3ms)")
    print(f"loop bar line       {times['loop_bar_line_demo_s']:.6f}s  (loop ramp starts at 1.0)")
    print(f"loop silent         {times['loop_silent_demo_s']:.6f}s")
    print(f"boom                {times['boom_demo_s']:.6f}s  ({(LOOP_SILENT_DEMO_SAMP-BOOM_DEMO_SAMP)/SR*1000:+.2f} ms vs loop silent)")
    print(f"file end            {times['file_end_demo_s']:.6f}s")
    print(f"\nlead vs bar line {LEAD_VS_BAR_SAMP/SR:.6f}s (preroll {PREROLL_SAMP/SR:.6f} + 64th {SHIFT_SAMP/SR:.6f})")
    print(f"loop gain at boom {loop_gain_at_boom:.4f}")
    print(f"sum residual at outro downbeat {residual:.3e}")
    print(f"demo TP {meas['true_peak_dbfs']} dBTP  I={meas['integrated_lufs']} LUFS  LRA={meas['lra']}  pad={pad_db:.3f} dB")
    print("sha256 demo ogg", report["sha256"]["demo_crypt_outro_v4.ogg"])
    print("wrote", DIR / "demo_report_v4.json")


if __name__ == "__main__":
    main()
