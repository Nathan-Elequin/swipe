# run3 PROGRESS (started 19:54 CDT, balance 2000 -> budget floor 1850)
- lib3.py: call wrapper (logs usage to calls.log, budget guard = sum usage_gens <= 150). sheet.py contact sheets. clean3.py = run2 finalize2 clean().
- NOTE: bitforge style_image must equal output size (48px ogre style failed at 32/64 with 500; not charged).
- b1 (bases, 15 gens): picked base/wolf32 (wolf_px_a), hornet32 (hor_px_b), goblin32, skeleton32, spider48, dragon64 (pixflux init from cleanup-all natives), lantern32 (lantern_b), coin32 (coin_b), scroll_closed48/open48.
- b2 (running): 14 animations (wolf x2, hornet, goblin, skeleton, spider, dragon, sprout64 hurt/victory/defeat/blink, lantern, coin, scroll unfurl). Raw out in raw/<name>_0..4.png
- Next: review b2 sheet, rerolls, finalize.py -> final/, showcase/, copy to Cherry.
- 20:45: b2 done for 12 anims (27 gens used, bal 1973). coin_glint + scroll_unfurl still in flight inside the original b2.py process (pid 1265748) - do NOT relaunch unless that process died with no raw/coin_glint_*, raw/scroll_unfurl_*.
- 20:50: b2 review: wolf design faces LEFT (fix: base mirrored -> base/wolf*_R.png). Rerolls launched in b3.py (pid see ps): wolf_gallop_c, wolf_gallop_d (wolf rerolls 2/2 used), s64_victory_r2 (fists weak). Others OK: hornet_fly_a, goblin_run, skeleton_run, spider_move, dragon_move, s64_hurt (subtle), s64_defeat, s64_blink, lantern_flicker. Fallback for wolf: mirror wolf_gallop_b frames.
- 20:55: job6 hero: generate-image-v2 cost not in official docs (3rd-party says 10; USD page ambiguous) -> used /create-image-pro-flash 128px, official /pro-flash/cost estimate = 6 gens. b4.py -> raw/hero128_*.
- 20:52: hero128 done (6 gens, raw/hero128_0/1). coin_glint done. finalize3.py written (needs choices.json). Waiting: scroll_unfurl (b2), b3 rerolls.
- 20:57: picks in choices.json (wolf_gallop_c, victory_r2, hero128_0). scroll_unfurl r1 jumps rolled->open; reroll scroll_unfurl_r2 launched (b5.py).
- 20:53: finalize3 ran once (scroll r1). defeat switched to per-frame feet align. Pending scroll_unfurl_r2 then final finalize + showcase + copy.
- 20:56: scroll_unfurl_r2 failed (stays rolled, just tilts); keeping r1. Final+showcase built. Next: copy to Cherry.
- 20:57: DONE. Copied final/ + showcase/ (132 files) to Cherry C:\Users\Natha\Documents\spinheritance-art-kit\returns\pixellab\run3\. Balance 2000 -> 1961 (39 gens). Nothing pending.
- touch-up pass started 20:59: backups in final/_pre_touchup/. t1.py = 2 pixflux gens for victory raised arms (raw/s64_vic_arms_a/b).
- 21:0x: touch.py applied wolf relight, hurt lean+flash, blink 2f, scroll inbetweens (final/ overwritten).
- 21:03 TOUCH-UP PASS DONE (touch.py, vic.py, regen.py; originals in final/_pre_touchup/). 2 gens used (s64_vic_arms_a/b pixflux; both kept arms down -> rejected; arms hand-drawn in vic.py).
  wolf relit upper-left (normal-based ramp remap) on base+f0-3; hurt f2/f3 lean back 2/3px + head tilt 1px, new sprout64_hurt_f1_flash; victory f1/f2 hand-drawn raised fists; blink now 2 frames (f0 open, f1 closed; f2/f3 removed); scroll f1/f2 = 1/3, 2/3 unrolled, f3 open; coin glint frames re-bottom-aligned (1px vertical jitter fix).
  Regenerated x4, GIFs (+ sprout64_hurt_flash gif), contact_sheet_x4.png. Copied to Cherry run3\ (stale blink f2/f3 removed there; x4 copies moved to final\_pre_touchup\x4).
