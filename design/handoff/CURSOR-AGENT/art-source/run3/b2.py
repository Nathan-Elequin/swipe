from lib3 import *
import functools; print=functools.partial(print,flush=True)
G="galloping run cycle to the right: legs clearly alternate between fully stretched out front and back and gathered under the belly, body stays inside the frame"
jobs=[J(anim,'base/wolf32.png',G,'wolf_gallop_a',seed=11),J(anim,'base/wolf40pad.png',G,'wolf_gallop_b',seed=29),
 J(anim,'base/hornet32.png','three hornets buzzing in place, wings flapping fast, each hornet bobbing up and down','hornet_fly_a',seed=11),
 J(anim,'base/goblin32.png','fast sneaky run cycle to the right, legs alternating, arms pumping','goblin_run',seed=11),
 J(anim,'base/skeleton32.png','run cycle to the right holding the dagger forward, bony legs alternating','skeleton_run',seed=11),
 J(anim,'base/spider48.png','scuttling walk to the right, eight legs stepping in alternating waves, body bobs','spider_move',seed=11),
 J(anim,'base/dragon64.png','prowling walk to the right, legs stepping, wings slowly flapping, tail swaying','dragon_move',seed=11),
 J(anim,'base/sprout64.png','gets hit: flinches and recoils backward with a pained face, then recovers, facing right','s64_hurt',seed=11),
 J(anim,'base/sprout64.png','victory cheer: jumps up happily and raises both fists in the air, facing right','s64_victory',seed=11),
 J(anim,'base/sprout64.png','defeated: is knocked backward, falls down and ends lying flat on the ground','s64_defeat',seed=11),
 J(anim,'base/sprout64.png','standing still idle, blinks eyes once, nothing else moves','s64_blink',seed=11),
 J(anim,'base/lantern32.png','the candle flame inside the lantern flickers and the warm glow pulses, the lantern stays still','lantern_flicker',seed=11),
 J(anim,'base/coin32.png','a bright gold glint sparkle twinkles across the coins and the ruby, nothing moves','coin_glint',seed=11),
 J(anim,'base/scroll_closed48.png','the rolled parchment scroll unfurls and opens up into a flat document','scroll_unfurl',seed=11,last='base/scroll_open48.png')]
par(jobs,3)
