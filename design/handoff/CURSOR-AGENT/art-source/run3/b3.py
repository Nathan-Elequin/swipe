from lib3 import *
import functools; print=functools.partial(print,flush=True)
G="fast gallop to the right: front legs reach far forward while hind legs kick far back, then all four legs bunch together under the belly, full stride gallop cycle, stays inside the frame"
par([J(anim,'base/wolf40pad_R.png',G,'wolf_gallop_c',seed=41),J(anim,'base/wolf40pad_R.png',G,'wolf_gallop_d',seed=73),
 J(anim,'base/sprout64.png','victory cheer: throws both fists high above the head and hops with joy, big smile, facing right','s64_victory_r2',seed=37)],3)
