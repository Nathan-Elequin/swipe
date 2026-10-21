from lib4 import *
import functools; print=functools.partial(print,flush=True)
O=", game UI icon, bold simple shapes, 1px dark outline, no background"
I=", game item sprite, 1px dark outline, light from upper left, no background"
par([J(pix,"dark red rounded badge, three thick bright white diagonal claw scratch slashes across its upper half, plain dark red empty centre"+O,32,32,'claw_idle_r2',13),
 J(pix,"glossy purple poison bubble with green toxic swirls, round, about to burst"+I,48,48,'pbubble_r2',17),
 J(pix,"two steel sai daggers crossed in a big X shape, blades pointing up-left and up-right, brown wrapped handles at the bottom"+I,48,48,'sai_pair_r2',21,init='base/init_saipair48.png',init_s=90)],3)
