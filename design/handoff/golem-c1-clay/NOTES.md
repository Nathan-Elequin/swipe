# Golem C1 clay boulder install

Pick: `golem_C1_clay_boulder_dopey` (Nathan final). Not C2.

Replaced facing idle f0–f3 (48), wheel idle/base/breathe (48 Weak/Tough native → 96 on screen), extra still (128×144).
**New** slash base+f0–f3 (48) — golem had no slash set before.

Bare clay boulder, tiny dopey face, no armor. PixelLab anims from C1 still (3 gens).

## Wheel path fix (follow-up)

`monster_wheel_frames` prefers `*_wheel_idle_fN` over base/breathe. #459 left armored idle f0–f3 in place and only wrote C1 base/breathe at the old 24 native size, so the loader never showed C1 on the wheel. Live wheel idle/base/breathe are now 48×48 byte-copies of C1 facing idle. Contact sheet of **loaded** paths: `contact-sheet-loaded.png`.
