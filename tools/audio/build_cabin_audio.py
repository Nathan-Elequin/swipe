#!/usr/bin/env python3
"""Build the cabin-overhaul cues (CC0 packs + cabin_sfxgen synth), loudness-matched with the same rules as build_audio.py.

  python3 tools/audio/cabin_sfxgen.py --out /tmp/cab_synth
  python3 tools/audio/build_cabin_audio.py --src <packs dir> --synth /tmp/cab_synth --out assets/audio --manifest tools/audio/cabin_manifest.json
"""
import argparse, json, os, sys, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build_audio as B

B.PACKS["oga_mbox"] = ("oga/musicbox/", "4 Music Box Tracks", "Mjorlaja & Aureolus_Omicron", "CC0 1.0", "https://opengameart.org/content/4-music-box-tracks")
B.PACKS["synth_cab"] = ("", "Swipe cabin_sfxgen (tools/audio/cabin_sfxgen.py)", "Swipe / generated", "CC0 1.0 (original)", "tools/audio/cabin_sfxgen.py")
L = B.L
M = {}
def add(name, kind, *layers, **o): M[name] = dict(kind=kind, layers=list(layers), **o)
S = lambda f, g=0.0, p=1.0, d=0.0: L("synth", f, g, p, d)   # synth layers resolve to --synth

# hotspots
add("cab_hover_a", "ui", S("cab_hover_wood_a.wav")); add("cab_hover_b", "ui", S("cab_hover_wood_b.wav"))
add("cab_click", "ui", L("impact", "impactWood_light_000.ogg"), L("interface", "click_002.ogg", -8))
add("cab_locked", "sfx", L("rpg", "metalLatch.ogg", 0, 1.1), L("impact", "impactMetal_light_001.ogg", -6, 1.2, 0.06))
# doors / key ring
add("cab_unlock", "sfx", L("rpg", "metalLatch.ogg", 0, 0.9), L("impact", "impactMetal_light_003.ogg", -4, 1.3, 0.12), S("cab_unlock_glint.wav", -6, 1.0, 0.16))
add("cab_chain_drop", "sfx", L("impact", "impactMetal_medium_002.ogg", 0, 1.1), L("impact", "impactMetal_light_004.ogg", -3, 0.9, 0.09), L("impact", "impactMetal_light_002.ogg", -6, 1.2, 0.17))
add("cab_door_creak", "sfx", L("rpg", "creak2.ogg", 0, 0.85), L("rpg", "doorOpen_2.ogg", -4))
add("cab_key_jingle", "sfx", S("cab_key_jingle.wav"), L("rpg", "metalClick.ogg", -6, 1.2, 0.05))
add("sting_unlock", "sting", L("jingles", "Steel jingles/jingles_STEEL02.ogg"))
# radio
add("cab_radio_on", "sfx", L("rpg", "metalClick.ogg"), S("cab_radio_on.wav", -2, 1.0, 0.04))
add("cab_radio_knob", "ui", L("interface", "tick_004.ogg", 0, 0.8))
add("cab_radio_tune", "sfx", S("cab_radio_tune.wav"))
add("cab_radio_static_loop", "amb", S("cab_radio_static_loop.wav"), loop="xfade", loop_start=0.7, loop_len=2.4)
# paper
for i in (1, 2, 3): add(f"cab_page_flip_{i}", "sfx", L("rpg", f"bookFlip{i}.ogg"))
add("cab_book_open", "sfx", L("rpg", "bookOpen.ogg")); add("cab_book_close", "sfx", L("rpg", "bookClose.ogg"))
add("cab_scroll", "sfx", L("rpg", "bookFlip2.ogg", 0, 0.8), L("rpg", "cloth3.ogg", -6, 1.1, 0.05))
add("cab_map_pin", "ui", L("impact", "impactTin_medium_000.ogg", 0, 1.5), L("interface", "select_003.ogg", -8))
add("cab_seal_stamp", "sfx", L("impact", "impactPlank_medium_003.ogg", 0, 0.8), L("impact", "impactSoft_medium_002.ogg", -2))
# homecoming
add("cab_sack_shake", "sfx", L("rpg", "handleSmallLeather.ogg"), L("rpg", "cloth1.ogg", -3, 1.0, 0.14), L("rpg", "handleSmallLeather2.ogg", -2, 1.05, 0.30))
add("cab_sack_empty", "sfx", L("impact", "impactSoft_heavy_001.ogg", 0, 0.8))
add("sting_empty", "sting", L("jingles", "Sax jingles/jingles_SAX03.ogg", 0, 0.9))
add("cab_moth", "sfx", S("cab_moth.wav"))
add("cab_item_pop_a", "sfx", S("cab_item_pop_a.wav"), L("casino", "card-place-1.ogg", -8))
add("cab_item_pop_b", "sfx", S("cab_item_pop_b.wav"), L("casino", "card-place-2.ogg", -8))
add("cab_item_burst", "sfx", S("cab_item_burst.wav"), L("impact", "impactGlass_light_000.ogg", -8, 1.2))
add("cab_item_whoosh", "sfx", S("cab_item_whoosh.wav"))
add("cab_shelf_chime", "sfx", S("cab_shelf_chime.wav"))
add("cab_hero_yip", "sfx", S("cab_hero_yip.wav")); add("cab_hero_sigh", "sfx", S("cab_hero_sigh.wav"))
# rope exit
add("cab_rope_climb_1", "sfx", L("rpg", "cloth2.ogg"), L("rpg", "creak1.ogg", -6, 1.3)); add("cab_rope_climb_2", "sfx", L("rpg", "cloth4.ogg"), L("rpg", "creak3.ogg", -6, 1.35))
add("cab_rope_creak", "amb", L("rpg", "creak1.ogg", 0, 0.75), lowpass=2200)
add("cab_hole_rumble", "sfx", S("cab_hole_rumble.wav"))
# props
add("cab_gear_take", "sfx", L("rpg", "clothBelt.ogg"), L("rpg", "metalClick.ogg", -8, 1.3)); add("cab_gear_hang", "sfx", L("rpg", "beltHandle1.ogg"))
add("cab_dummy", "sfx", L("impact", "impactSoft_medium_000.ogg"), L("rpg", "creak3.ogg", -5, 1.2, 0.05))
add("cab_bed", "sfx", L("impact", "impactSoft_heavy_003.ogg", 0, 0.9))
add("cab_telescope", "sfx", L("rpg", "metalClick.ogg", 0, 0.9), L("interface", "maximize_003.ogg", -6))
add("cab_trunk", "sfx", L("rpg", "bookOpen.ogg", 0, 0.7), L("rpg", "creak1.ogg", -4, 1.0, 0.04))
add("cab_brag_cog", "ui", S("cab_cog_tick.wav"))
add("cab_room_sign", "ui", L("impact", "impactWood_light_002.ogg", 0, 1.2))
add("cab_panel_whoosh", "ui", S("cab_panel_whoosh.wav"))
# the left-hand drawer (post-ending secret)
add("cab_drawer_stuck", "sfx", L("impact", "impactWood_medium_001.ogg", 0, 1.1), L("impact", "impactWood_light_003.ogg", -3, 1.2, 0.08), L("impact", "impactWood_light_001.ogg", -5, 1.25, 0.16), L("impact", "impactMining_000.ogg", -12, 1.3, 0.05))
add("cab_drawer_unlatch", "sfx", L("rpg", "metalLatch.ogg", 0, 1.3), L("rpg", "metalClick.ogg", -4, 0.9, 0.12), S("cab_unlock_glint.wav", -12, 1.0, 0.2))
add("cab_drawer_open", "sfx", S("cab_drawer_slide.wav"), L("impact", "impactMining_002.ogg", -4, 1.1, 0.34), L("impact", "impactMining_004.ogg", -7, 1.25, 0.44))
add("cab_geode_chime", "sfx", S("cab_geode_chime.wav"), L("impact", "impactGlass_light_002.ogg", -8, 0.9))
# Nib
add("nib_psst", "ui", S("cab_nib_psst.wav")); add("nib_gasp", "ui", S("cab_nib_gasp.wav")); add("nib_chuckle", "ui", S("cab_nib_chuckle.wav"))
# stings / music
add("sting_intro", "sting", L("jingles", "Steel jingles/jingles_STEEL07.ogg", 0, 0.85))
add("sting_ending", "sting", L("jingles", "Steel jingles/jingles_STEEL03.ogg"), L("jingles", "Pizzicato jingles/jingles_PIZZI10.ogg", -6, 1.0, 0.25))
add("music_intro", "music", L("oga_mbox", "musicbox3_sad_tune.ogg"), lufs=-22)
add("music_ending", "music", L("oga_mbox", "musicbox4_happy_polka.ogg"), lufs=-22)
add("music_station_waltz", "music", L("oga_mbox", "musicbox1_spooky_waltz.ogg"), lufs=-23)
add("music_station_tune", "music", L("oga_mbox", "musicbox2_cute_tune.ogg"), lufs=-23)

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", required=True); ap.add_argument("--synth", required=True); ap.add_argument("--out", required=True); ap.add_argument("--manifest")
    a = ap.parse_args(); os.makedirs(a.out, exist_ok=True); rows = []
    with tempfile.TemporaryDirectory() as tmp:
        for name, spec in M.items():
            dst, dur = B.build(name, spec, a.src, a.synth, a.out, tmp)
            pk = lambda p: "synth_cab" if p == "synth" else p
            srcs = [dict(pack=B.PACKS[pk(p)][1], author=B.PACKS[pk(p)][2], licence=B.PACKS[pk(p)][3], url=B.PACKS[pk(p)][4],
                         file=(B.PACKS[p][0].split("/", 1)[-1] if p != "synth" else "") + f, gain_db=g, pitch=pi) for p, f, g, pi, d in spec["layers"]]
            rows.append(dict(file=name + ".ogg", kind=spec["kind"], seconds=round(dur, 3), bytes=os.path.getsize(dst), sources=srcs))
            print(f"{name:24s} {dur:7.3f}s {os.path.getsize(dst)/1024:7.1f} KB")
    if a.manifest: json.dump(rows, open(a.manifest, "w"), indent=1)
