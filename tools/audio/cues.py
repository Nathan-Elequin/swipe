#!/usr/bin/env python3
"""Single source of truth for Swipe cue data (pass 1).
python3 tools/audio/cues.py --manifest manifest.json --table design/audio/_cue_table.md --map data/sfx-map.json
Each cue: id, event, loc (file:line from audio-director.md), status (keep|keep+|replace|new),
desc, files (asset basenames, no extension; one is picked at random), bus, db, pitch (lo,hi),
cd (cooldown ms), voices (max simultaneous), prio (0 low..3 high), layers [(cue, db_offset, delay_ms)].
"""
import argparse, json
EXISTING = {  # repo files kept as-is: source pack (per CREDITS.txt)
 **{k: "Kenney Interface Sounds (existing repo file)" for k in "bong click click2 confirm confirm_big drop error error_big glass hover land open pluck question scratch select switch whoosh".split()},
 **{k: "Kenney RPG Audio (existing repo file)" for k in "block block_heavy book chop cloth creak door_close door_open door_slam draw hit metal_latch".split()},
 "bleed": "Original (existing repo file)", "music": "yd — Dungeon Ambience, OGA, CC0 (existing)"}
C = []
def c(id, event, loc, status, desc, files, bus="SFX", db=-8, pitch=(0.97, 1.03), cd=0, voices=4, prio=1, layers=(), **extra):
    C.append(dict(id=id, event=event, loc=loc, status=status, desc=desc, files=list(files), bus=bus, db=db,
                  pitch=list(pitch), cd=cd, voices=voices, prio=prio, layers=[list(l) for l in layers], **extra))
N = (1.0, 1.0)
# ---------------------------------------------------------------- title / pause / overlay
c("ui.hover_title", "Title pill hover (How to Play / Dive In / Adventure / Challenge / Home)", "main.gd:1068–1073", "new", "Soft wooden 'tok', quieter cousin of hover.wav", ["ui_hover_soft_a", "ui_hover_soft_b"], "UI", -16, (0.95, 1.05), 60, 1, 0)
c("ui.tutorial_start", "Title click How to Play", "main.gd:11068–11069", "keep", "Book flip + door open", ["book"], "UI", -10, N, 0, 1, 2, [("ui.door_open", 0, 0)])
c("ui.door_open", "(layer) door open", "—", "keep", "Kenney RPG door", ["door_open"], "SFX", -8, (0.97, 1.03), 0, 2, 1)
c("ui.quick_start", "Title click Dive In", "main.gd:1966–1967", "keep", "Confirm + door open", ["confirm"], "UI", -10, N, 0, 1, 2, [("ui.door_open", -4, 0)])
c("run.start", "Adventure / Challenge start (_reset_run)", "main.gd:1646, 1657, 1582", "keep", "Big confirm", ["confirm_big"], "UI", -8, N, 300, 1, 2)
c("ui.menu_open", "Escape opens settings", "main.gd:3945–3947", "keep", "Open; Music ducks −6 dB while paused", ["open"], "UI", -12, N, 0, 1, 2, duck_music=(-6, 0.15, "hold"))
c("ui.slider_tick", "Settings slider drag (SFX / UI / Ambience)", "settings_menu.gd:222–234", "replace", "Tiny tick routed to the bus being dragged (preview); replaces rapid click spam", ["ui_tick"], "UI", -12, (0.98, 1.02), 70, 1, 0)
c("ui.resume", "Settings Resume", "settings_menu.gd:239", "keep", "Click", ["click"], "UI", -8, N, 0, 1, 1)
c("ui.mode_pick", "Settings start-over mode", "settings_menu.gd:245", "keep", "Confirm", ["confirm"], "UI", -8, N, 0, 1, 1)
c("ui.editor_open", "Settings Roster/Script (editor only)", "settings_menu.gd:252, 259", "keep", "Book (editor only — no new assets)", ["book"], "UI", -10, N, 0, 1, 0)
c("ui.hover_menu", "Settings button hover", "settings_menu.gd:173–201", "new", "Soft wooden tok", ["ui_hover_soft_a", "ui_hover_soft_b"], "UI", -18, (0.95, 1.05), 60, 1, 0)
c("ui.back", "Settings close (Esc / back)", "settings_menu.gd:216–219", "new", "Short 'back' blip; Music unducks 0.3 s", ["ui_back"], "UI", -12, N, 0, 1, 1, duck_music=(0, 0.3, "release"))
c("ui.undo", "Undo", "main.gd:5278, 5282", "keep", "Whoosh 0.72 + click2", ["whoosh"], "UI", -12, (0.72, 0.72), 80, 1, 1, [("ui.click2", 0, 0)])
c("ui.redo", "Redo", "main.gd:5278", "keep", "Whoosh 1.2 + click2", ["whoosh"], "UI", -12, (1.2, 1.2), 80, 1, 1, [("ui.click2", 0, 0)])
c("ui.click2", "(layer) click2", "—", "keep", "Kenney click2", ["click2"], "UI", -8, N, 0, 2, 1)
c("ui.illegal", "Illegal action (undo/spin/done etc.)", "main.gd:5298, 4466, 4608–4620, 5341–5366", "keep", "Error", ["error"], "UI", -12, (1.0, 1.0), 120, 1, 1)
c("ui.log_toggle", "Combat log toggle", "main.gd:8954", "keep", "Switch", ["switch"], "UI", -14, N, 0, 1, 0)
# ---------------------------------------------------------------- draft gate
c("draft.seat_starter", "Starters seated N/E/S/W", "main.gd:3125", "replace", "Card placed on table + drop; pitch steps up per seat (code passes 0.92+0.06·i)", ["card_place_1", "card_place_2", "card_place_3"], "SFX", -10, (0.98, 1.02), 0, 2, 1, [("draft.drop", -2, 0)])
c("draft.drop", "(layer) drop", "—", "keep", "Kenney drop", ["drop"], "SFX", -10, N, 0, 3, 1)
c("draft.starter_kit", "Starter items granted", "main.gd:3232–3233", "keep", "Cloth + confirm", ["cloth"], "SFX", -10, N, 0, 1, 1, [("ui.confirm_soft", -4, 0)])
c("ui.confirm_soft", "(layer) confirm", "—", "keep", "Confirm", ["confirm"], "UI", -10, N, 0, 2, 1)
c("draft.offer", "Petitioner / offer shown", "main.gd:3253–3254", "keep", "Creak + question", ["creak"], "SFX", -12, N, 0, 1, 1, [("ui.question", 0, 0)])
c("ui.question", "(layer/prompt) question", "main.gd:5397", "keep", "Question blip", ["question"], "UI", -10, N, 0, 1, 1)
c("draft.mystery", "Mystery relic shown at gate", "draft_gate.gd:261", "new", "Wobbly pizzicato trill (same family as Chaos) — 'what's in the box?'", ["chaos_warble"], "Stings", -16, N, 0, 1, 1)
c("draft.take", "Take (send through gate)", "main.gd:3289–3301", "keep+", "Existing latch/slam/whoosh → door/bong chord kept; + small coin rattle (the goblin pockets it)", ["metal_latch"], "SFX", -6, N, 0, 1, 2, [("loot.coins_small", -8, 220)])
c("draft.refuse", "Leave / refuse", "main.gd:3328–3329", "keep", "Scratch + switch 0.85", ["scratch"], "SFX", -10, N, 0, 1, 1)
c("draft.autofill", "Out of refusals, auto-fill", "main.gd:3355–3373", "keep", "Creak then slam+latch / door", ["creak"], "SFX", -12, N, 0, 1, 1)
c("draft.courier", "Courier flies relic to wheel", "main.gd:3403", "keep", "Whoosh 1.1", ["whoosh"], "SFX", -10, (1.08, 1.12), 0, 2, 1)
c("draft.seat_fail", "Seat fail (no empty)", "main.gd:3421", "keep", "Error", ["error"], "UI", -14, N, 0, 1, 1)
c("draft.mill_done", "Mill finished, wheel ready", "main.gd:3275–3276", "keep", "Door close + confirm_big", ["door_close"], "SFX", -10, N, 0, 1, 2)
c("draft.next_offer", "Next offer drawn", "main.gd:3009, 3027", "keep", "Book flip", ["book"], "SFX", -10, (0.95, 1.05), 0, 1, 1)
c("speech.monster", "Monster speech line (gate / any speech_box)", "main.gd:10045", "new", "Low gibberish grumble: 2–5 blips per line (see speech rules)", ["monster_blip_01", "monster_blip_02", "monster_blip_03", "monster_blip_04"], "UI", -14, (0.9, 1.1), 70, 1, 1, speech=True)
# ---------------------------------------------------------------- challenge
c("chal.seat_dungeon", "Seat 6 dungeon monsters", "main.gd:2470–2483", "replace", "Card-place variants instead of stacked drops; voice-limited so 6 rapid seats don't pile up", ["card_place_1", "card_place_2", "card_place_3"], "SFX", -10, (0.95, 1.08), 60, 2, 1)
c("chal.offer_pick", "Opening pick-two shown", "main.gd:2590–2591", "keep", "Book + open", ["book"], "SFX", -10, N, 0, 1, 1)
c("chal.commit", "Commit chosen item", "main.gd:2619–2620", "keep+", "Confirm + cloth; + tiny coin clink", ["confirm"], "UI", -12, N, 0, 1, 2, [("loot.coins_small", -6, 60)])
c("chal.discard", "Discard one (forced)", "main.gd:2647", "replace", "Card shoved off the table", ["card_shove"], "SFX", -10, N, 0, 1, 1)
c("chal.holes", "Holes resolve / refill", "main.gd:2717–2758", "keep", "Open+bong or drop+whoosh (as today)", ["open"], "SFX", -10, N, 50, 2, 1)
c("chal.begin", "Begin play", "main.gd:2554–2555", "keep", "Confirm + door open", ["confirm"], "UI", -10, N, 0, 1, 2)
# ---------------------------------------------------------------- hand
c("hand.hover", "Hover a hand card", "main.gd:10983", "keep", "Hover blip (90 ms cap)", ["hover"], "UI", -18, (1.03, 1.07), 90, 1, 0)
c("hand.select", "Select / click to use", "main.gd:5369", "keep", "Select", ["select"], "UI", -10, N, 0, 1, 1)
c("hand.petrified", "Click a petrified card", "main.gd:5359–5360", "replace", "Error + short stone grind (reads as 'stuck')", ["error"], "UI", -10, N, 150, 1, 1, [("status.petrify", -8, 0)])
c("hand.option_pick", "Pick an option", "main.gd:5448, 5468", "keep", "Click2", ["click2"], "UI", -8, N, 0, 1, 1)
c("hand.toss", "Discard / toss spent card", "main.gd:5816–5821", "replace", "Card shove + cloth (whoosh kept when spent)", ["card_shove"], "SFX", -12, (0.95, 1.05), 40, 2, 1, [("ui.cloth", -6, 0)])
c("ui.cloth", "(layer) cloth", "—", "keep", "Cloth", ["cloth"], "SFX", -10, (0.95, 1.05), 0, 3, 1)
c("hand.gain", "Gain item into hand", "main.gd:6497–6503", "replace", "Card placed + soft open", ["card_place_1", "card_place_2", "card_place_3"], "SFX", -10, (0.97, 1.05), 40, 2, 1)
c("hand.gain_blocked", "Gain blocked (hand full)", "main.gd:6497–6503", "keep", "Error + cloth", ["error"], "UI", -10, N, 120, 1, 1)
c("chaos.pick", "Chaos Stone pick", "main.gd:5982–6016", "keep", "Question / select / error", ["question"], "UI", -10, N, 0, 1, 1)
c("chaos.transform", "Chaos transform", "main.gd:6033–6034", "keep+", "Whoosh 0.86 + bong 0.7 + wobbly pizzicato trill (chaos identity)", ["whoosh"], "SFX", -8, (0.86, 0.86), 0, 1, 2, [("chaos.warble", -6, 0)])
c("chaos.warble", "(layer) chaos trill", "—", "new", "Kenney pizzicato trill", ["chaos_warble"], "Stings", -12, (0.97, 1.03), 0, 1, 1)
c("hand.upgrade", "Item upgrade visual", "main.gd:6078–6080", "keep", "Whoosh + pluck + confirm", ["whoosh"], "SFX", -8, (0.9, 0.9), 0, 1, 2)
c("hand.upgrade_fail", "Merchant upgrade fail", "main.gd:7498", "keep", "Error", ["error"], "UI", -10, N, 0, 1, 1)
# ---------------------------------------------------------------- wheel
c("wheel.hover_slice", "Hover a slice", "main.gd:4339", "keep", "Hover", ["hover"], "UI", -18, (1.0, 1.06), 90, 1, 0)
c("wheel.click_slice", "Click slice", "main.gd:4311", "keep", "Select", ["select"], "UI", -10, N, 0, 1, 1)
c("wheel.place", "Place monster on empty", "main.gd:4362–4363", "keep", "Drop + confirm 1.08", ["drop"], "SFX", -8, N, 0, 1, 2)
c("wheel.bribe", "Bribe / remove", "main.gd:4392–4393", "keep+", "Scratch + creak; + coin handful (it IS a bribe)", ["scratch"], "SFX", -8, N, 0, 1, 2, [("loot.coins", -10, 40)])
c("wheel.mode_place", "Toggle place mode", "main.gd:3859", "keep", "Switch", ["switch"], "UI", -12, N, 0, 1, 1)
c("wheel.mode_bribe", "Toggle bribe mode", "main.gd:3868", "keep", "Switch 0.92", ["switch"], "UI", -12, (0.92, 0.92), 0, 1, 1)
c("wheel.spin_start", "Spin start", "main.gd:4484–4486", "keep", "Door open + whoosh 0.9; music → combat", ["door_open"], "SFX", -10, N, 0, 1, 2, [("draft.courier", -2, 0)], music="combat")
c("wheel.tick", "Segment passes pointer during 1.2 s spin", "boss_wheel.gd:461 (spin_to tween)", "new", "Wooden ratchet pawl; dedicated tick player; pitch & level follow spin speed", ["wheel_tick_a", "wheel_tick_b", "wheel_tick_c"], "SFX", -14, (0.96, 1.04), 35, 3, 1, dedicated="tick")
c("wheel.spin_hover", "Hover Spin button", "main.gd:9134", "new", "Soft tok", ["ui_hover_soft_a", "ui_hover_soft_b"], "UI", -18, (1.05, 1.1), 90, 1, 0)
c("wheel.deck_hover", "Hover deck (Challenge peek)", "main.gd:10521", "keep", "Hover", ["hover"], "UI", -18, N, 90, 1, 0)
c("wheel.num_tick_atk", "ATK number ticks", "boss_wheel.gd:723", "new", "Tick, lower", ["ui_tick"], "UI", -16, (0.85, 0.9), 45, 1, 0)
c("wheel.num_tick_hp", "HP number ticks", "boss_wheel.gd:741", "new", "Tick, higher", ["ui_tick"], "UI", -16, (1.12, 1.18), 45, 1, 0)
c("wheel.detent", "(layer) wheel settles", "main.gd:4491", "new", "Wooden clunk at land", ["wheel_detent"], "SFX", -8, (0.97, 1.03), 0, 1, 2)
c("wheel.land_chord", "(layer) existing land chord", "main.gd:4491–4493", "keep", "door_close + land + bong", ["door_close"], "SFX", -8, N, 0, 1, 2)
c("wheel.land_weak", "Spin lands on Weak monster", "main.gd:4491–4493", "replace", "Detent + existing chord + light wood knock", ["wheel_land_weak"], "SFX", -10, (1.0, 1.08), 0, 1, 2, [("wheel.detent", 0, 0), ("wheel.land_chord", 0, 0)])
c("wheel.land_tough", "Spin lands on Tough monster", "main.gd:4491–4493", "replace", "Detent + chord + heavier plank thud", ["wheel_land_tough"], "SFX", -8, (0.95, 1.0), 0, 1, 2, [("wheel.detent", 0, 0), ("wheel.land_chord", 0, 0)])
c("wheel.land_deadly", "Spin lands on Deadly monster", "main.gd:4491–4493, show_monster 4532", "replace", "Detent + chord + deep bell + Deadly sting; music → deadly", ["wheel_land_deadly"], "SFX", -8, (1.0, 1.0), 0, 1, 3, [("wheel.detent", 0, 0), ("wheel.land_chord", 0, 0), ("sting.deadly", 0, 120)], music="deadly")
# ---------------------------------------------------------------- combat — player cards
c("atk.hit_light", "Attack connects, dmg < 5", "main.gd:7878 (_deal_atk_at), 5506", "replace", "Meaty punch + knife slice layer (replaces hit+chop)", ["atk_hit_light_1", "atk_hit_light_2", "atk_hit_light_3"], "SFX", -7, (0.94, 1.08), 40, 3, 2, [("atk.slash", -8, 0)])
c("atk.hit_heavy", "Attack connects, dmg ≥ 5", "main.gd:7878", "new", "Heavy punch + slash, slightly lower", ["atk_hit_heavy_1", "atk_hit_heavy_2"], "SFX", -6, (0.92, 1.02), 40, 3, 2, [("atk.slash", -6, 0)])
c("atk.slash", "(layer) blade", "—", "new", "Kenney knifeSlice", ["atk_slash"], "SFX", -10, (0.95, 1.1), 0, 3, 1)
c("atk.legacy", "(fallback) old hit+chop", "main.gd:7878–7879", "keep", "hit.ogg (+chop) — fallback when a map entry is missing", ["hit"], "SFX", -8, (0.94, 1.08), 40, 3, 1)
c("atk.fizzle", "Attack fizzle / Goblin immune / 0 dmg", "main.gd:7829, 7863", "keep", "Glass 0.85", ["glass"], "SFX", -8, (0.85, 0.85), 60, 2, 1)
c("blk.gain", "Gain Block (n < 4)", "main.gd:7201", "replace", "Shield plate knock (iron) + quiet old block layer", ["blk_gain_1", "blk_gain_2"], "SFX", -8, (0.96, 1.06), 40, 2, 2, [("blk.legacy", -8, 0)])
c("blk.legacy", "(layer) block.ogg", "—", "keep", "Kenney RPG block", ["block"], "SFX", -8, N, 0, 2, 1)
c("blk.gain_big", "Gain Block (n ≥ 4)", "main.gd:7201–7203", "replace", "Heavy plate + block_heavy tail", ["blk_gain_big"], "SFX", -7, (0.95, 1.02), 40, 2, 2, [("blk.heavy_legacy", -8, 0)])
c("blk.heavy_legacy", "(layer) block_heavy.ogg", "—", "keep", "Kenney RPG block_heavy", ["block_heavy"], "SFX", -14, N, 0, 2, 1)
c("heal.gain", "Heal raises HP", "main.gd:7217", "replace", "Warm 3-note bell arpeggio + glass sparkle (replaces pluck)", ["heal_sparkle"], "SFX", -9, (0.98, 1.03), 80, 2, 2)
c("defeat.use", "Defeat card succeeds", "main.gd:5708, 5760, 5781", "replace", "Decisive knife slice + quiet draw", ["defeat_slash"], "SFX", -7, (0.95, 1.02), 0, 1, 2, [("defeat.legacy", -6, 0)])
c("defeat.legacy", "(layer) draw.ogg", "—", "keep", "Kenney RPG draw", ["draw"], "SFX", -8, N, 0, 1, 1)
c("defeat.fail", "Defeat card fails", "main.gd:5708, 5760, 5781", "keep", "Error ± latch", ["error"], "UI", -10, N, 120, 1, 1)
c("util.net", "Net (atk_drop)", "main.gd:5633", "keep", "Latch + scratch", ["metal_latch"], "SFX", -8, N, 0, 1, 2)
c("util.quiet", "Quiet Bell / Silence", "main.gd:5663", "keep+", "Cloth + pluck + muffled bell (sound being smothered)", ["cloth"], "SFX", -10, N, 0, 1, 2, [("status.silence", -2, 30)])
c("util.caltrops", "Caltrops (atk_zero)", "main.gd:5617", "keep", "Latch + scratch", ["metal_latch"], "SFX", -8, (1.05, 1.1), 0, 1, 2)
c("util.magnet", "Magnet resolves", "main.gd:5488+ (_apply_ops magnet branch)", "new", "Rising 'zing' (comic magnet pull)", ["util_magnet"], "SFX", -10, (0.97, 1.03), 0, 1, 2)
c("util.hook", "Hook resolves", "main.gd:5488+ (_apply_ops hook branch)", "new", "Quick high slash + cloth tug", ["atk_slash"], "SFX", -10, (1.2, 1.3), 0, 1, 2, [("ui.cloth", -4, 60)])
c("util.fail", "Utility fails", "main.gd:5488+", "keep", "Error", ["error"], "UI", -10, N, 120, 1, 1)
c("smoke.use", "Smoke card", "main.gd:5585", "new", "Comic smoke-bomb poof (toss sfx still plays)", ["smoke_poof"], "SFX", -8, (0.95, 1.05), 0, 1, 2)
c("chaos.echo_bell", "Echo Bell copies last card", "main.gd:5474–5479, 7274–7280", "new", "Bright bell with slap echo, then the copied card's own cues 90 ms later", ["echo_bell"], "SFX", -9, (1.0, 1.0), 0, 1, 3)
c("chaos.echo_empty", "Echo Bell with nothing to copy", "main.gd:5511", "keep", "Error", ["error"], "UI", -10, N, 0, 1, 1)
c("egg.hurt", "Egg hurts you", "main.gd:4826–4841", "replace", "Eggshell crack on top of the normal hit/blocked chord", ["egg_crack"], "SFX", -8, (0.95, 1.05), 0, 2, 2)
c("egg.lay", "Spider Egg laid", "main.gd:6794–6796", "replace", "Wet squelch + low scratch (bleed layer removed)", ["egg_squelch"], "SFX", -10, (0.9, 1.0), 80, 2, 1, [("draft.refuse_scratch", -6, 40)])
c("draft.refuse_scratch", "(layer) scratch", "—", "keep", "Scratch", ["scratch"], "SFX", -12, (0.7, 0.8), 0, 2, 1)
c("egg.queen_eat", "Spider Queen eats eggs", "main.gd:6761–6762", "replace", "Squelch + gulp", ["egg_squelch"], "SFX", -8, (0.75, 0.85), 0, 1, 2, [("mon.cube_gulp", -4, 120)])
# ---------------------------------------------------------------- combat — resolution / monster body / statuses
c("combat.done", "Click Done (legal)", "main.gd:4636, 4641", "keep", "Click", ["click"], "UI", -8, N, 0, 1, 1)
c("combat.done_hover", "Hover Done", "main.gd:10195", "keep", "Hover", ["hover"], "UI", -18, N, 90, 1, 0)
c("mon.telegraph", "Bodyguard redirect path step", "main.gd:7809", "keep", "Whoosh −14, +0.06 pitch per step; now voice-limited", ["whoosh"], "SFX", -14, N, 100, 2, 1)
c("mon.lunge", "Monster lunge (visual)", "combat_stage.gd:136 (trigger site in main.gd)", "new", "Short airy whoosh just before connect", ["whoosh"], "SFX", -16, (1.15, 1.25), 80, 1, 1)
c("player.hurt", "Monster Attack hits you", "main.gd:4855–4856", "replace", "Heavy punch + chop + goblin 'hrk!' (error layer dropped)", ["atk_hit_heavy_1", "atk_hit_heavy_2"], "SFX", -6, (0.85, 0.95), 60, 2, 3, [("player.chop", -4, 0), ("player.oof", -4, 40)])
c("player.chop", "(layer) chop", "—", "keep", "Kenney chop", ["chop"], "SFX", -6, (0.95, 1.05), 0, 2, 1)
c("player.oof", "(layer) goblin hurt voice", "—", "new", "Synth goblin 'hrk' (no words)", ["player_oof_a", "player_oof_b"], "UI", -10, (0.95, 1.08), 150, 1, 2)
c("player.blocked", "Monster Attack fully blocked", "main.gd:4863–4865", "keep+", "block_heavy + bong + glass; + plate clang", ["block_heavy"], "SFX", -5, N, 60, 2, 2, [("blk.gain_big", -6, 0)])
c("player.pierce_zero", "Dragon pierce, 0 through Block", "main.gd:4798", "keep", "Glass", ["glass"], "SFX", -10, N, 0, 1, 1)
c("player.poke", "Damage taken (Needleback poke etc.)", "main.gd:7989, 7996", "replace", "Light punch + goblin 'hrk' (glass when 0)", ["atk_hit_light_1", "atk_hit_light_2", "atk_hit_light_3"], "SFX", -9, (0.85, 0.95), 60, 2, 2, [("player.oof", -6, 30)])
c("status.bleed", "Bleed", "main.gd:7239–7240", "keep", "Original drip + cloth 0.75", ["bleed"], "SFX", -4, (0.95, 1.05), 80, 2, 2)
c("status.petrify", "Petrify (Gargoyle)", "main.gd:7395–7396", "replace", "Stone grind + latch (replaces latch+cloth)", ["status_petrify"], "SFX", -8, (0.95, 1.02), 0, 1, 2, [("util.net", -6, 0)])
c("status.poison", "Poison mark applied", "main.gd:8180, 8214–8230", "replace", "Bubbling blips (replaces error) + click2", ["status_poison"], "SFX", -9, (0.95, 1.05), 0, 1, 2)
c("status.hypnotize", "Hypnotize / Pocketwatch", "main.gd:8360, combat_stage.gd:149", "new", "Tick-tock + woozy vibrato swirl", ["status_hypnotize"], "SFX", -10, (0.98, 1.02), 0, 1, 2)
c("status.silence", "(layer) silence", "—", "new", "Muffled bell", ["status_silence"], "SFX", -10, N, 0, 1, 1)
c("mon.cube_ask", "Cube asks feed", "main.gd:7420–7421", "keep", "Question + cloth", ["question"], "UI", -10, N, 0, 1, 1)
c("mon.cube_feed", "Feed Cube", "main.gd:7539–7540", "replace", "Gelatinous gulp + glass 0.8", ["mon_cube_gulp"], "SFX", -8, (0.9, 1.0), 0, 1, 2)
c("mon.cube_gulp", "(layer) gulp", "—", "new", "Gulp", ["mon_cube_gulp"], "SFX", -8, (0.9, 1.05), 0, 2, 1)
c("mon.merchant_ask", "Merchant ask", "main.gd:7444–7445", "keep+", "Question + pluck + coin rattle", ["question"], "UI", -10, N, 0, 1, 1, [("loot.coins_small", -6, 80)])
c("mon.cleric_tax", "Cleric heal tax", "main.gd:7002", "replace", "Lower heal arpeggio (replaces pluck)", ["heal_sparkle"], "SFX", -12, (0.8, 0.84), 0, 1, 2)
c("mon.cleric_refuse", "Cleric refuse", "main.gd:7045", "keep", "Error", ["error"], "UI", -10, N, 0, 1, 1)
c("mon.cleric_yank", "Cleric yank light", "main.gd:7080–7090", "keep", "Whoosh + scratch + error", ["whoosh"], "SFX", -10, N, 0, 1, 2)
c("mon.vampire_grow", "Vampire grows", "main.gd:6248", "keep", "Pluck 0.7 (now 120 ms cooldown)", ["pluck"], "SFX", -10, (0.7, 0.7), 120, 1, 1)
c("mon.damsel", "Damsel neighbours resolve", "main.gd:6612–6614", "keep", "Pluck 1.35 + bong 1.5 + open 1.2", ["pluck"], "SFX", -10, (1.35, 1.35), 0, 1, 2)
c("mon.leech_pulse", "Leech pulse (repeats)", "main.gd:6671–6672", "replace", "Wet suction pulse, pitch climbs per repeat (code passes pitch); bong kept quiet", ["mon_leech_pulse"], "SFX", -10, (0.98, 1.02), 90, 2, 1)
c("mon.berserker_rage", "Berserker hits 8 Atk", "main.gd:6720–6722", "keep", "error_big + chop + whoosh", ["error_big"], "SFX", -8, N, 0, 1, 2)
c("mon.berserker_cool", "Berserker cools from 8", "main.gd:6724–6726", "keep", "Glass + cloth + pluck", ["glass"], "SFX", -10, N, 0, 1, 1)
c("mon.clockwork_spawn", "Clockwork heirs spawn", "main.gd:7578–7579", "replace", "Clockwork click + drop + latch", ["mon_clockwork"], "SFX", -8, (0.95, 1.05), 60, 2, 2, [("draft.drop", 0, 40)])
c("mon.commander_flee", "Commander flees", "main.gd:6544–6545", "replace", "Three fast scurrying steps + whoosh + door", ["cabin_step_1", "cabin_step_2", "cabin_step_3", "cabin_step_4"], "SFX", -10, (1.2, 1.35), 0, 3, 2, [("draft.courier", -2, 200)], repeat=(3, 70))
c("mon.cleave_immune", "Cleave extra target immune", "main.gd:8047", "keep", "Glass", ["glass"], "SFX", -10, N, 60, 2, 1)
c("mon.harpy_poke", "Harpy interrupt Attack", "main.gd:7317", "keep", "Uses player.hurt / player.blocked; chain-limited by their cooldowns", ["whoosh"], "SFX", -14, (1.2, 1.3), 120, 1, 1)
c("mon.hornet_buzz", "Hornet second swing", "_swing / Done (Hornet)", "new", "Angry buzz before the 2nd swing", ["mon_hornet_buzz"], "SFX", -12, (0.95, 1.1), 0, 1, 2)
c("mon.hurt_weak", "Monster HP drops (Weak)", "main.gd:7878–7879", "replace", "Light punch, pitched up a touch", ["atk_hit_light_1", "atk_hit_light_2", "atk_hit_light_3"], "SFX", -9, (1.02, 1.12), 40, 3, 2)
c("mon.hurt_tough", "Monster HP drops (Tough)", "main.gd:7878–7879", "replace", "Heavy punch", ["atk_hit_heavy_1", "atk_hit_heavy_2"], "SFX", -9, (0.95, 1.05), 40, 3, 2)
c("mon.hurt_deadly", "Monster HP drops (Deadly)", "main.gd:7878–7879", "replace", "Heavy punch + low armour clank", ["mon_hurt_deadly"], "SFX", -9, (0.9, 1.0), 40, 2, 2, [("mon.hurt_tough", -2, 0)])
c("mon.slay_chord", "(layer) existing slay chord", "main.gd:4678–4680", "keep", "bong + whoosh + scratch", ["bong"], "SFX", -10, N, 0, 2, 2)
c("mon.death_weak", "Monster slain (Weak)", "main.gd:4678–4680", "replace", "Soft body thud + slay chord + small coin clink", ["mon_death_weak"], "SFX", -8, (1.0, 1.1), 0, 2, 2, [("mon.slay_chord", 0, 0), ("loot.coins_small", -6, 150)])
c("mon.death_tough", "Monster slain (Tough)", "main.gd:4678–4680", "replace", "Heavy wood thud + slay chord + coins", ["mon_death_tough"], "SFX", -7, (0.95, 1.02), 0, 2, 2, [("mon.slay_chord", 0, 0), ("loot.coins", -8, 160)])
c("mon.death_deadly", "Monster slain (Deadly)", "main.gd:4678–4680", "replace", "Deep bell toll + slay chord + big coin spill; music → combat", ["mon_death_deadly"], "SFX", -6, (0.95, 1.0), 0, 1, 3, [("mon.slay_chord", 0, 0), ("loot.coins", -4, 200)], music="combat")
c("mon.neighbor_kill", "Neighbour kill (Crossbow/Longbow)", "main.gd:8471–8473", "replace", "Same as mon.death_<tier of victim>", ["mon_death_weak"], "SFX", -8, N, 60, 2, 2, alias_by_tier="mon.death_")
c("trophy.tick", "Trophy count ticks up", "main.gd:10575–10576", "keep", "Bong 0.85 + pluck 1.35", ["bong"], "UI", -12, (0.85, 0.85), 80, 1, 1)
c("loot.coins", "(layer) coin handful", "—", "new", "Kenney handleCoins", ["loot_coins"], "SFX", -10, (0.95, 1.08), 120, 1, 1)
c("loot.coins_small", "(layer) coin clink", "—", "new", "Kenney handleCoins2", ["loot_coins_small"], "SFX", -10, (0.95, 1.1), 80, 2, 1)
# ---------------------------------------------------------------- stings
c("sting.deadly", "Deadly first shown (per-boss pitch via sfx-map)", "main.gd:4491 / 4532", "new", "Low orchestral hit, falling", ["sting_deadly"], "Stings", -6, (1.0, 1.0), 2000, 1, 3, duck_music=(-8, 0.05, 0.8))
c("sting.bucket", "Bucket reveal opens", "bucket_reveal.gd:233–234", "new", "Rising whole-tone pizzicato run", ["sting_bucket"], "Stings", -8, N, 0, 1, 3, duck_music=(-6, 0.05, 1.2))
c("sting.victory", "Run victory", "main.gd:4876–4884", "new", "Bright pizzicato run up (sneaky-triumphant)", ["sting_victory"], "Stings", -5, N, 0, 1, 3, duck_music=(-30, 0.1, "hold"))
c("sting.clear", "Dungeon cleared", "main.gd:1677–1679", "new", "Pizzicato cadence", ["sting_clear"], "Stings", -6, N, 0, 1, 3, duck_music=(-12, 0.1, 1.5))
c("sting.defeat", "Player dies", "main.gd:4886–4887", "new", "Sad sax descending (the joke)", ["sting_defeat"], "Stings", -5, N, 0, 1, 3, duck_music=(-30, 0.1, "hold"))
# ---------------------------------------------------------------- buckets
c("bucket.open", "Bucket overlay opens", "bucket_reveal.gd:233–234", "keep+", "Bong 0.72 + whoosh 0.85 kept; + card-pack tear + bucket sting", [], "SFX", -8, N, 0, 1, 3, [("bucket.pack", 0, 0), ("sting.bucket", 0, 120)])
c("bucket.pack", "(layer) card pack tear", "—", "new", "Kenney card pack open", ["bucket_open"], "SFX", -8, N, 0, 1, 2)
c("bucket.card_pop", "Each shadow card pops", "bucket_reveal.gd:254", "replace", "Card placed (replaces drop)", ["card_place_1", "card_place_2", "card_place_3"], "SFX", -10, (0.9, 1.06), 50, 3, 1)
c("bucket.ready", "Ready to continue", "bucket_reveal.gd:257, 264", "keep", "confirm_big / confirm", ["confirm_big"], "UI", -10, N, 0, 1, 2)
c("bucket.card_hover", "Hover a revealed card", "bucket_reveal.gd:348–351", "replace", "Card slide + hover (replaces pluck+whoosh+hover stack)", ["card_slide"], "UI", -16, (1.0, 1.1), 90, 1, 0)
# ---------------------------------------------------------------- tutorial / Nib
c("tut.continue", "Tutorial Continue / Next", "main.gd:11082", "keep", "Click", ["click"], "UI", -12, N, 0, 1, 1)
c("tut.skip", "Tutorial Skip", "main.gd:11087", "new", "Back blip", ["ui_back"], "UI", -12, N, 0, 1, 1)
c("speech.nib", "Each Nib sentence", "tutorial_guide.gd:242 (advance)", "new", "Goblin gibberish blips, 1 per ~3 visible chars (or 3–6 burst per line if no typewriter)", ["nib_blip_01", "nib_blip_02", "nib_blip_03", "nib_blip_04", "nib_blip_05", "nib_blip_06", "nib_blip_07", "nib_blip_08"], "UI", -12, (0.94, 1.12), 55, 1, 1, speech=True)
c("tut.nudge", "Nudge ('Not that one')", "main.gd:5366", "keep", "Error (+ one Nib blip)", ["error"], "UI", -12, N, 0, 1, 1)
c("tut.d2_seat", "Dungeon-2 seat", "main.gd:11183–11184", "keep", "Door open + whoosh", ["door_open"], "SFX", -10, N, 0, 1, 1)
# ---------------------------------------------------------------- home cabin
c("cabin.open", "Cabin UI opens", "home_cabin.gd:113 (from main.gd:1718)", "keep+", "Cloth; music crossfades to cabin bed (1.5 s)", ["cloth"], "SFX", -12, N, 0, 1, 1, music="cabin")
c("cabin.pan", "Camera pan to cabin", "home_cabin.gd:396", "keep", "Whoosh 0.9", ["whoosh"], "SFX", -12, (0.9, 0.9), 0, 1, 1)
c("cabin.step", "Goblin walks (per footfall frame)", "home_cabin.gd:450 (_walk_hero)", "new", "Small wooden footsteps, alternating, light (tiny goblin)", ["cabin_step_1", "cabin_step_2", "cabin_step_3", "cabin_step_4"], "Ambience", -12, (1.1, 1.25), 120, 2, 1)
c("cabin.door", "Door opens (arrive / click)", "home_cabin.gd:405, 542", "keep", "Door open", ["door_open"], "SFX", -10, N, 0, 1, 1)
c("cabin.sack", "Sack drop", "home_cabin.gd:470 (_play_drop)", "new", "Leather sack thump + coin jingle", ["cabin_sack"], "SFX", -6, (0.95, 1.0), 0, 1, 2)
c("cabin.sit", "Sit in chair", "home_cabin.gd:484 (_play_sit)", "new", "Wood thump + chair creak", ["cabin_sit"], "SFX", -9, (0.95, 1.02), 0, 1, 1)
c("cabin.rock", "Chair rock (once per rock cycle)", "home_cabin.gd:445, 553", "new", "Soft low creaks, alternate fwd/back", ["cabin_rock_1", "cabin_rock_2", "cabin_rock_3"], "Ambience", -18, (0.92, 1.0), 600, 1, 0)
c("cabin.fire_start", "Fire start", "home_cabin.gd:528", "replace", "Low 'whoomp' (pitched-down poof) instead of confirm; starts fire loop fade-in 1.5 s", ["smoke_poof"], "SFX", -14, (0.55, 0.6), 0, 1, 1, loop_start="amb.fire")
c("amb.fire", "Fire loop / crackle", "home_cabin.gd:526 (_fire.play('burn'))", "new", "Wood-burning fireplace loop (12 s, crossfaded)", ["cabin_fire_loop"], "Ambience", -10, N, 0, 1, 1, loop=True)
c("cabin.trophy", "Trophy placed / burst", "home_cabin.gd:718 (_play_burst)", "new", "Wooden shelf knock + sparkle; + coins", ["cabin_trophy"], "SFX", -8, (0.97, 1.05), 120, 2, 2, [("loot.coins_small", -6, 60)])
c("cabin.glint", "Plaque glint", "home_cabin.gd:742", "new", "Tiny high 'ting'", ["cabin_glint"], "UI", -18, (0.95, 1.1), 400, 1, 0)
c("cabin.cat", "Cat idle (random, ≥ 8 s apart)", "home_cabin.gd:802 (_tick_cat)", "new", "Soft mew / mew-purr", ["cabin_cat_mew", "cabin_cat_mewpurr"], "Ambience", -12, (0.95, 1.05), 8000, 1, 1)
c("amb.cat_purr", "Cat purr loop (while cat sleeps / goblin sits)", "home_cabin.gd:802", "new", "Sleepy purr loop", ["cabin_cat_purr_loop"], "Ambience", -18, N, 0, 1, 0, loop=True)
c("cabin.close", "Close cabin", "main.gd:1743", "keep+", "Ambience loops fade 0.8 s; music → title", ["cloth"], "SFX", -14, N, 0, 1, 1, music="title")
# ---------------------------------------------------------------- run
c("run.hall_wipe", "Hall wipe between fights", "main.gd:1896–1897", "keep", "Door open + whoosh", ["door_open"], "SFX", -10, N, 0, 1, 1)
c("run.knight_off", "Knight walks off", "main.gd:1925", "keep+", "Cloth kept; + 4 light steps", [], "SFX", -12, N, 0, 1, 1, [("cabin.step", 0, 0)], repeat=(4, 260))
c("run.dungeon_clear", "Dungeon cleared", "main.gd:1677–1679", "replace", "confirm_big + sting.clear; music returns to title", ["confirm_big"], "UI", -8, N, 0, 1, 3, [("sting.clear", 0, 80)], music="title")
c("run.victory", "Victory (incl. Adventure death after ≥1 clear)", "main.gd:4876–4884", "replace", "confirm_big + victory sting + coins", ["confirm_big"], "UI", -8, N, 0, 1, 3, [("sting.victory", 0, 60), ("loot.coins", -4, 400)], music="title_after_sting")
c("run.defeat", "Player dies", "main.gd:4886–4887", "replace", "error_big + sad sax; music ducks to silence then title returns after 3 s", ["error_big"], "UI", -8, N, 0, 1, 3, [("sting.defeat", 0, 150)], music="title_after_sting")
c("run.leave", "Leave run → cabin", "main.gd:1711", "keep", "Whoosh", ["whoosh"], "SFX", -10, N, 0, 1, 1)
c("editor.*", "Roster / Script / Dev Test (editor only)", "roster_editor.gd 286–2063, script_editor.gd 145–273, main.gd 1273–1498", "keep", "Untouched; not in web build", ["click"], "UI", -10, N, 0, 1, 0)

for _x in C:
    if _x["status"] == "keep+": _x["files"] = []

def source_of(f, man):
    if f in EXISTING: return EXISTING[f]
    m = man.get(f + ".ogg")
    if not m: return "?"
    def one(s):
        if s["pack"].startswith("Swipe sfxgen"): return f"sfxgen.py `{s['file'][:-4]}`"
        return f"{s['pack']}: `{s['file']}`" + (f" ×{s['pitch']} pitch" if s['pitch'] != 1.0 else "")
    return " + ".join(one(s) for s in m["sources"])

def table(man):
    hdr = "| Cue id | Event | File:line | Status | Sound | Asset(s) → source | Bus | dB | Pitch | Cooldown / voices / prio | Layers |\n|---|---|---|---|---|---|---|---|---|---|---|\n"
    rows = []
    for x in C:
        files = ", ".join(f"`{f}`" for f in x["files"]) or "(existing calls stay; adds layers)"
        srcs = "; ".join(sorted({source_of(f, man) for f in x["files"]})) or "—"
        lay = ", ".join(f"{l[0]} ({l[1]:+} dB, +{l[2]} ms)" for l in x["layers"]) or "—"
        extra = []
        if x.get("music"): extra.append(f"music→{x['music']}")
        if x.get("duck_music"): extra.append(f"duck {x['duck_music'][0]} dB")
        if x.get("loop"): extra.append("LOOP")
        if x.get("dedicated"): extra.append(f"dedicated {x['dedicated']} player")
        if extra: lay += " · " + ", ".join(extra)
        p = x["pitch"]; ps = f"{p[0]:.2f}" if p[0] == p[1] else f"{p[0]:.2f}–{p[1]:.2f}"
        rows.append(f"| `{x['id']}` | {x['event']} | {x['loc']} | **{x['status']}** | {x['desc']} | {files} → {srcs} | {x['bus']} | {x['db']} | {ps} | {x['cd']} ms / {x['voices']} / {x['prio']} | {lay} |")
    return hdr + "\n".join(rows) + "\n"

def sfx_map():
    cues = {}
    for x in C:
        if x["id"] == "editor.*": continue
        d = dict(files=x["files"], bus=x["bus"], db=x["db"], pitch=x["pitch"], cooldown_ms=x["cd"], max_voices=x["voices"], priority=x["prio"])
        if x["layers"]: d["layers"] = [dict(cue=l[0], db_offset=l[1], delay_ms=l[2]) for l in x["layers"]]
        for k in ("music", "loop", "dedicated", "speech", "loop_start", "alias_by_tier"):
            if x.get(k) is not None: d[k] = x[k]
        if x.get("duck_music"):
            a, b, r = x["duck_music"]; d["duck_music"] = dict(db=a, attack_s=b, release_s=r)
        if x.get("repeat"): d["repeat"] = dict(count=x["repeat"][0], interval_ms=x["repeat"][1])
        cues[x["id"]] = d
    T = lambda t: {"1": f"mon.{t}_weak", "2": f"mon.{t}_tough", "3": f"mon.{t}_deadly"}
    return {
     "version": 1,
     "doc": "Swipe audio map. See design/audio/AUDIO-SPEC.md. Files resolve to res://assets/audio/<name>.ogg then .wav. Keys under 'lookup' are tried in 'fallback_chain' order; first hit wins.",
     "path_prefix": "res://assets/audio/",
     "buses": {"Master": {"default_linear": 1.0}, "Music": {"default_linear": 0.85}, "Ambience": {"default_linear": 0.8},
               "SFX": {"default_linear": 1.0}, "UI": {"default_linear": 0.9}, "Stings": {"follows": "Music", "default_linear": 1.0}},
     "prefix_bus": {"ui.": "UI", "speech.": "UI", "sting.": "Stings", "amb.": "Ambience", "music.": "Music"},
     "defaults": {"bus": "SFX", "db": -8, "pitch": [0.97, 1.03], "cooldown_ms": 0, "max_voices": 4, "priority": 1},
     "voice_pool": {"sfx_players": 16, "steal": "oldest_lowest_priority_not_above_new", "tick_player_polyphony": 3, "speech_players": 1},
     "fallback_chain": ["card_id", "special_id", "ops_kind", "card_color", "tier", "default"],
     "lookup": {
       "card_id": {"echo_bell": {"use_pre": "chaos.echo_bell", "copied_delay_ms": 90, "empty": "chaos.echo_empty"},
                   "chaos_stone": {"use": "chaos.transform"}, "smoke_bomb": {"use": "smoke.use"},
                   "magnet": {"use": "util.magnet"}, "hook": {"use": "util.hook"}, "net": {"use": "util.net"},
                   "quiet_bell": {"use": "util.quiet"}, "caltrops": {"use": "util.caltrops"}, "pocketwatch": {"use": "status.hypnotize"},
                   "_note": "Ids are best guesses from the audit; Cursor must verify against data/catalog.json and drop/rename unknown keys."},
       "special_id": {"slime_boss": {}, "spider_queen": {"special": "egg.queen_eat", "egg": "egg.lay"}, "dragon": {"pierce_zero": "player.pierce_zero"},
                      "commander": {"special": "mon.commander_flee"}, "vampire": {"special": "mon.vampire_grow"}, "two_headed_serpent": {"special": "mon.damsel"},
                      "leech_league": {"special": "mon.leech_pulse"}, "clockwork_knight": {"special": "mon.clockwork_spawn"}, "cowardly_king": {},
                      "berserker": {"rage": "mon.berserker_rage", "cool": "mon.berserker_cool"}, "gelatinous_cube": {"ask": "mon.cube_ask", "feed": "mon.cube_feed"},
                      "merchant": {"ask": "mon.merchant_ask", "fail": "hand.upgrade_fail"}, "cleric": {"tax": "mon.cleric_tax", "refuse": "mon.cleric_refuse", "yank": "mon.cleric_yank"},
                      "gargoyle": {"special": "status.petrify"}, "harpy": {"special": "mon.harpy_poke"}, "hornet_swarm": {"second_swing": "mon.hornet_buzz"},
                      "bodyguard": {"telegraph": "mon.telegraph"}, "needleback": {"poke": "player.poke"}, "kobold_trapper": {}, "basilisk": {},
                      "_note": "Keys = monster ids; confirm against MONSTER_SPECIAL (main.gd:126–160)."},
       "ops_kind": {"atk*": {"hit": "atk.hit_light", "hit_heavy": "atk.hit_heavy", "heavy_threshold": 5, "zero": "atk.fizzle"},
                    "blk*": {"gain": "blk.gain", "gain_big": "blk.gain_big", "big_threshold": 4},
                    "heal_*": {"gain": "heal.gain"}, "defeat_*": {"use": "defeat.use", "fail": "defeat.fail"},
                    "atk_drop": {"use": "util.net"}, "atk_zero": {"use": "util.caltrops"}, "quiet": {"use": "util.quiet"},
                    "smoke": {"use": "smoke.use"}, "egg_hurt": {"use": "egg.hurt"}, "atk_echo": {"empty": "chaos.echo_empty"}},
       "card_color": {"atk": {"hit": "atk.hit_light"}, "blk": {"gain": "blk.gain"}, "heal": {"gain": "heal.gain"}, "defeat": {"use": "defeat.use"},
                      "utility": {"use": "util.net", "fail": "util.fail"}, "smoke": {"use": "smoke.use"}, "chaos": {"use": "chaos.transform"}, "egg": {"use": "egg.hurt"}},
       "tier": {"enter": {"1": "wheel.land_weak", "2": "wheel.land_tough", "3": "wheel.land_deadly"}, "hurt": T("hurt"), "death": T("death")},
       "default": {"hit": "atk.legacy", "gain": "blk.legacy", "use": "hand.select", "fail": "ui.illegal", "enter": "wheel.land_weak", "hurt": "mon.hurt_weak", "death": "mon.death_weak"}},
     "deadly_sting_pitch": {"_doc": "pitch multiplier for sting.deadly + wheel.land_deadly per boss id (semitones in comment)",
        "slime_boss": 0.84, "spider_queen": 1.12, "dragon": 0.75, "commander": 1.0, "vampire": 0.94,
        "two_headed_serpent": 1.19, "leech_league": 1.06, "clockwork_knight": 0.89, "cowardly_king": 1.33},
     "wheel_ticks": {"cue": "wheel.tick", "min_interval_ms": 35, "pitch_from_speed": [0.92, 1.12], "db_from_speed": [-18, -12], "final": "wheel.detent"},
     "speech": {"nib": {"cue": "speech.nib", "chars_per_blip": 3, "burst_if_no_typewriter": [3, 6], "burst_interval_ms": [70, 110], "duck_music_db": -3},
                "monster": {"cue": "speech.monster", "chars_per_blip": 4, "burst_if_no_typewriter": [2, 5], "burst_interval_ms": [90, 140], "duck_music_db": -3,
                            "pitch_by_tier": {"1": 1.1, "2": 1.0, "3": 0.85}}},
     "music": {
       "crossfade_s": {"default": 0.8, "to_deadly": 0.5, "from_deadly": 1.2, "to_cabin": 1.5, "to_title": 1.2},
       "between_fights_duck_db": -4,
       "beds": {"title": {"file": "music", "gain_db": 14.0, "loop": True, "note": "yd Dungeon Ambience file is ~-40 LUFS; +14 dB puts it ~-26"},
                "combat": {"file": "music_combat", "gain_db": -4.0, "loop": True, "resume_position": True},
                "deadly": {"file": "music_deadly", "gain_db": -3.0, "loop": True, "resume_position": False},
                "cabin": {"file": "music_cabin", "gain_db": -2.0, "loop": True, "resume_position": True},
                "verdant_hollow_intro": {"file": "music_verdant_hollow_intro", "gain_db": -4.0, "loop": False, "resume_position": False, "next": "verdant_hollow"},
                "verdant_hollow": {"file": "music_verdant_hollow_loop", "gain_db": -4.0, "loop": True, "resume_position": True},
                "cinder_forge": {"file": "music_cinder_forge_a", "gain_db": -4.0, "loop": True, "resume_position": True},
                "cinder_forge_b": {"file": "music_cinder_forge_b", "gain_db": -4.0, "loop": True, "resume_position": False},
                "cinder_forge_c": {"file": "music_cinder_forge_c", "gain_db": -4.0, "loop": True, "resume_position": False}},
       "biome_beds": {"b1": "verdant_hollow", "verdant_hollow": "verdant_hollow", "b4": "cinder_forge", "cinder_forge": "cinder_forge"},
       "states": {"title": "title", "draft": "title", "tutorial": "title", "challenge_setup": "title", "combat": "combat", "between_fights": "combat(ducked)",
                  "deadly": "deadly", "cabin": "cabin", "victory": "sting then title", "defeat": "sting then title",
                  "verdant_hollow": "verdant_hollow_intro then verdant_hollow",
                  "cinder_forge": "cinder_forge A always; B combat; C Tier-3"}},
     "cues": cues}

if __name__ == "__main__":
    ap = argparse.ArgumentParser(); ap.add_argument("--manifest", required=True); ap.add_argument("--table"); ap.add_argument("--map")
    a = ap.parse_args(); man = {m["file"]: m for m in json.load(open(a.manifest))}
    missing = [f for x in C for f in x["files"] if f not in EXISTING and f + ".ogg" not in man]
    assert not missing, missing
    ids = {x["id"] for x in C}; bad = [(x["id"], l[0]) for x in C for l in x["layers"] if l[0] not in ids]; assert not bad, bad
    if a.table: open(a.table, "w").write(table(man))
    if a.map: json.dump(sfx_map(), open(a.map, "w"), indent=1, ensure_ascii=False)
    from collections import Counter
    top = [x for x in C if not x["event"].startswith("(")]
    print("cues", len(C), "player-facing events", len(top), Counter(x["status"] for x in top))
    used = {f for x in C for f in x["files"]}; print("unused new assets:", sorted(set(m[:-4] for m in man) - used))
