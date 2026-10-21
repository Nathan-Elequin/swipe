# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import os,sys; sys.path.insert(0,os.path.join(os.path.dirname(os.path.abspath(__file__)),".."))
from lib import *
import functools; print=functools.partial(print,flush=True)
A='base/a/'
jobs=[J(anim,A+'claw_lit.png','the badge lights up: its rim brightens to cream and an inner glow pulses, badge stays in place','claw_lit'),
 J(anim,A+'claw_burst.png','the badge bursts on impact: cream and red shards radiate outward and fade','claw_burst'),
 J(anim,A+'flame_burst.png','the fire-rim badge bursts: flames lick outward and fade','flame_burst'),
 J(anim,A+'stamp.png','the brass stamp ring presses down and leaves an ink tick mark in the middle','stamp'),
 J(anim,A+'pdrip.png','the purple poison drop slowly drips, a small droplet forms at the bottom and falls','pdrip'),
 J(anim,A+'pburst.png','the purple-green poison bubble bursts, droplets spray outward','pburst'),
 J(anim,A+'hdrip.png','the small red heart drains and drips a red drop downward','hdrip'),
 J(anim,A+'sai_single.png','the sai twirls around once, then splits into two crossed sais','sai_split',n=8,last=A+'sai_pair.png'),
 J(anim,A+'marble.png','the red and blue swirl inside the glass marble slowly rotates, marble stays still','marble_idle'),
 J(anim,A+'marble.png','the red and blue colours inside the marble swirl fast and blend together, marble stays still','marble_swirl',n=6),
 J(anim,A+'cat.png','slow celestial sparkle twinkles inside the cat-eye marble, marble stays still','cat_idle'),
 J(anim,A+'hook.png','the grappling hook spins around as it is thrown out on its rope','hook_throw',n=6),
 J(anim,A+'stone.png','the stone shell cracks apart and shatters into chunks that fall away','petrify'),
 J(anim,A+'sparkle.png','gold four-point sparkle twinkles: grows, flashes bright, shrinks','sparkle')]
par(jobs,3)
