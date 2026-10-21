# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import os,sys; sys.path.insert(0,os.path.join(os.path.dirname(os.path.abspath(__file__)),".."))
from lib import *
import functools; print=functools.partial(print,flush=True)
I=", game item sprite, 1px dark outline, light from upper left, no background"
A='base/a/'
def pb_then_burst():
    out=pix("glossy round bubble of purple poison with bright green toxic swirls inside, purple and green colours only"+I,48,48,'pbubble_r3',29)
    if not out: return
    import sys; sys.path.insert(0,'.'); from procui import shrink; from clean4 import up
    from PIL import Image
    b=shrink(Image.open(out[0]).convert('RGBA'),24); b.save('work/ui/pbubble.png'); up(b,2).save(A+'pburst.png')
    anim(A+'pburst.png','the purple-green poison bubble swells and bursts, purple droplets splash outward and fade','pburst_r2',seed=17)
par([J(pix,"thick braided brown hemp rope, vertical, filling the full width and height, twisted strands"+", game texture tile, no background",32,64,'rope_r2',7),
 J(anim,A+'sai_single.png','the sai spins quickly like a propeller with the blade always visible, then it separates into two crossed sais','sai_split_r2',seed=23,n=8,last=A+'sai_pair.png'),
 J(anim,A+'hdrip.png','the red heart drains from the top down and a red blood drop drips off its bottom tip','hdrip_r2',seed=23),
 J(pb_then_burst)],3)
