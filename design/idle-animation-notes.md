# Idle animation notes (for a later batch)

Status: only the static frame 0 ships right now, as `assets/dungeon/extra/<file>.png`. No strips have been drawn yet.

**When frames are drawn (brief §3 Animation):**
- 4 frames, looping, about 6 fps (about 167 ms per frame).
- Name them `<file>_idle_0.png` … `<file>_idle_3.png`, the same size as the still. Frame 0 is the current still, pixel for pixel.
- The game also asks for a 4-frame run/lunge at about 10 fps (`_run_0..3`). That's a separate pass; a few hints are below.
- Breath and sway only. Feet stay planted on the bottom row so the wheel and stage don't jitter. Move at most 1 authored pixel per frame (4 px at ship size).
- Keep the 1px #100e0c outline and the family ramps. Add no glow or tier trim, because the Weak/Tough/Deadly glow is the Godot shader's job.
- The game already does the combat idle bob and the 22 px lunge in code. Sprite frames should add character, not the bob. If both run together, drop the vertical breath on frames 1-3 and keep the secondary motion only.

**Default cycle:** use this when a row below says "default".

| Frame | Pose |
|---|---|
| 0 | rest |
| 1 | inhale: torso/head up 1 px, shoulders up |
| 2 | hold, plus a secondary detail (blink, cloth flick, etc.) |
| 3 | exhale back toward rest |

## Per-monster ideas

| id (file) | size | idle_0 → idle_3 |
|---|---|---|
| goblin | 16×16 | default. f2 the ears twitch outward 1 px and both eyes blink (Y→O); f3 the grin widens by one tooth. |
| ogre | 32×36 | slow heavy breath: belly out 1 px on f1–f2. Club bobs on the shoulder (tip down 1 px f2). Tiny head bobs late (f3) for a dopey lag. |
| skeleton | 16×28 | jaw chatter: jaw drops 1 px on f1 and f3, closes on f0/f2. Sword tip sways 1 px. Ribs stay still (no breath, it's a skeleton; that's the joke). |
| lich | 16×28 | floats: whole sprite (except the hem tatters) rises 1 px on f1–f2. Raised claws open/close (finger pixel in/out). Teal eye pixels swap light/dark on f2. Hem tatters shuffle left→right. |
| vampire | 16×28 | cape breathes: cape edges widen 1 px on f1–f2 to show more red lining. Red eyes narrow (one-row squint) on f2. Fangs show on f3. |
| wraith | 16×28 | drift: body up 1 px f1, up 2 px f2, up 1 px f3. Wisp tail flicks side to side. Reaching arms wave out of phase. The teal eyes stay fixed (stare). |
| needleback | 16×16 | quills ripple: quill tips rise 1 px in a wave front→back across f1–f3. Nose twitches (nostril pixel) on f2. |
| dire_wolf | 16×16 | default breath on the ribcage. Tail wags 1 px up/down. Jaw opens on f2 (pant), closes f3. Ears flick on f1. |
| harpy | 16×28 | wings beat: the wing tips go up (f1), out (f2), down (f3). Talons stay on the ground. Hair flicks. Mouth open on f2 (screech). |
| hornet_swarm | 16×16 | the three hornets bob out of phase (big: +1 on f1/f3, small left: +1 on f0/f2, small right: f2/f3). Wings alternate between two shapes every frame. |
| leech_league | 16×16 | wriggle: each leech body shifts its middle segment ±1 px in a wave. Sucker mouths pulse open/closed out of phase. The captain's cap pops up 1 px on f2. |
| spider_queen (spider.png) | 32×36 | legs tap: one leg pair at a time lifts its tip 1 px (front pair f1, second f2, third f3). Abdomen breathes 1 px. The six eyes blink in sequence on f2. Tiara stays put. |
| kobold_trapper | 16×16 | swings the snare loop: loop out 1 px (f1), swung (f2), back (f3). Tail tip flicks. Grin widens on f2. |
| basilisk | 16×16 | head bob like a lizard (+1 px f1, hold f2, down f3). Red comb flops on f2. Tongue flicks out on f3. |
| dragon | 32×36 | big slow breath: chest/belly expands 1 px f1–f2. Wing lifts 1 px at the tip on f2. Nostril smoke puff drifts up and fades (3 positions f1–f3, gone on f0). Tail tip curls. |
| slime_boss | 32×36 | squash and stretch: f1 squashes 1 px wider and 1 px shorter, f2 back to rest, f3 stretches 1 px taller. Crown wobbles with the top edge. Googly pupils roll inside the eyes. The swallowed sword drifts 1 px. |
| gelatinous_cube | 16×16 | jelly wobble: top face shifts 1 px left (f1) and right (f3). The skull and bone inside drift 1 px slower than the cube (they lag). Bubble pixels move up. |
| golem | 32×36 | very slow grind: shoulders sink 1 px on f2. Teal eye sockets flicker dim on f3. A pebble falls from a fist (f1 top, f2 mid, f3 gone). |
| gargoyle | 16×28 | stone, so almost still: wings creak open 1 px on f2 only. Eyes blink red→dark on f3. Plinth never moves. |
| clockwork_knight | 16×28 | the chest gear turns: rotate the tooth pixels one step per frame. The wind-up key turns (bow wide f0, edge-on f1, wide f2, edge-on f3). Teal eyes stay steady. |
| wick | 16×16 | flame flicker: the flame shape cycles through tall/lean-left/tall/lean-right. One wax drip slides down 1 px per frame, then resets. Nervous smile wobbles. |
| mimic | 16×16 | breathing chest: the lid lifts 1 px on f1–f2 (more teeth showing), tongue lolls 1 px. Lid eyes blink on f3. (The brief's 3-frame "open" strip is a separate, nice-to-have.) |
| anvil | 16×16 | grumpy: brows lower on f1–f2, mouth line tightens. A tiny hop on f2 (1 px up, stump stays). Otherwise heavy and still. |
| berserker | 16×28 | rage pant: chest heaves 2 steps. Axe raised higher on f2. Mouth open wider on f1/f2 (yell). Beard flicks. |
| bandit | 16×28 | shifty: eyes behind the mask look left (f1), centre (f2), right (f3). The loot sack jiggles 1 px. Scarf tail flutters. |
| commander | 16×28 | default breath. Plume flutters (tip pixel moves every frame). Sword tip rises 1 px on f2. Cape hem sways. |
| bodyguard | 16×28 | stance shift: the tower shield moves 1 px forward (down/out) on f1–f2. Helmet eyes peek over it on f2. Mostly still: the shield is the character. |
| juggernaut | 16×28 | heavy breath: pauldrons rise 1 px together on f1–f2. Red visor slit pulses between two reds (colour swap, not glow). Fists clench (knuckle pixel) on f2. |
| two_headed_serpent (damsel.png) | 16×28 | distress: hands pat the cheeks (in/out 1 px). Mouth O grows on f2. Hair sways. The tiny two-headed snake at her hem bobs its two heads alternately (the joke). |
| beggar | 16×28 | the bowl shakes 1 px left/right (hopeful). Hunched breath. Stick stays planted. Eyes look up on f2. |
| cowardly_king | 16×28 | trembling: knees knock (legs ±1 px alternating). Sweat drop moves down per frame and resets. Crown slips 1 px on f2. Hands wring. |
| merchant | 16×28 | the scales tip left (f1), level (f2), right (f3). Moustache wiggles. Satchel bumps. Grin. |
| hollow (Twins) | 32×36 | creepy sync: both twins tilt their heads 1 px the same way on f1–f2 (in perfect sync, which is the creepy part). Joined hands swing 1 px. On f3 only one twin blinks. Rag doll dangles. |
| wizard | 16×28 | default breath. Floppy hat tip bobs (the 2 tip pixels swing). Orb on the staff swaps light/dark highlight. Beard sways 1 px. |
| cleric | 16×28 | blessing hand rises 1 px on f1–f2. Book clasp catches light (pixel swap) on f2. Gentle breath. |
| nib | 16×28 | **tutorial speaker; needs talk-friendly frames.** f0 rest grin. f1 mouth open (talking). f2 monocle glint (pixel swap) plus one eyebrow up. f3 mouth half-open and tail flick. Coat pockets stay still so the loot remains readable. |

## Run / lunge hints (separate pass, 4 frames, about 10 fps)
- **Humanoids (16×28):** contact, pass, contact (mirror), pass. Lean the head 1 px forward. Weapons trail by 1 frame.
- **Beasts (wolf, basilisk, needleback, kobold):** gallop by lifting front and back leg pairs on alternate frames.
- **Floaters (lich, wraith, slime, hornets):** no legs. Stretch toward the target on f1–f2 and snap back on f3.
- **Large (32×36):** keep motion small, at most 2 px. They read heavy by moving less.
