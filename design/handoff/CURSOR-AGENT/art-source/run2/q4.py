import sys,os,time; sys.path.insert(0,'<ART_KIT>/pixellab'); os.chdir('<ART_KIT>/pixellab/run2')
while not os.path.exists('watch.log'): time.sleep(3)
time.sleep(5)
import pl; pl.LOG='<ART_KIT>/pixellab/run2/calls.log'
from pl import call,b64
def anim(base,action,prefix,n=4,seed=11,nb=True):
    return call('/animate-with-text-v3',{'first_frame':b64(base),'action':action,'frame_count':n,'no_background':nb,'seed':seed},prefix,0)
anim('base/p1_candle_crop64.png','candle flame flickers and sways, warm light pulses, nothing else moves','raw/p1_candle',nb=False)
anim('base/p3_seal_crop64.png','a small gold glint sparkle sweeps across the red wax seal, nothing else moves','raw/p3_seal',nb=False)
anim('base/pocketwatch_32.png','gentle floating bob with a gold glint sparkle','raw/pocketwatch_glint')
anim('base/grimoire_32.png','gentle floating bob with a gold glint sparkle','raw/grimoire_glint')
anim('base/sprout_base48.png','overhand throw: first pulls throwing arm far back behind the head, then whips it forward and releases to the right, side view','raw/sprout_throw_r2',seed=29)
