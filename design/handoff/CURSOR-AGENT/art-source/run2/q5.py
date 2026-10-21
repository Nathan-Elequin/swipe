import sys,os,time; sys.path.insert(0,'<ART_KIT>/pixellab'); os.chdir('<ART_KIT>/pixellab/run2')
while os.path.exists('/proc/1180245'): time.sleep(5)
time.sleep(5)
import pl; pl.LOG='<ART_KIT>/pixellab/run2/calls.log'
from pl import call,b64
def anim(base,action,prefix,n=4,seed=11,nb=True):
    return call('/animate-with-text-v3',{'first_frame':b64(base),'action':action,'frame_count':n,'no_background':nb,'seed':seed},prefix,0)
anim('base/p3_seal_crop64.png','the wax seal stays still; a tiny four-point gold star twinkle appears on its upper-left edge, grows, and fades','raw/p3_seal_r2',nb=False,seed=37)
anim('base/sprout_base64.png','reaching forward with both arms far out to the right to grab an item, then pulling it to the chest, side view','raw/s64_grab')
anim('base/sprout_base64.png','overhand throw: pulls arm far back behind the head, then whips it forward and releases to the right, side view','raw/s64_throw')
anim('base/s64/sprout_design_views_f1_native64.png','idle breathing, blinks, scarf flutters','raw/s64_34_idle')
anim('base/nib_base32.png','waves goodbye with the free hand while holding the lantern','raw/nib_wave')
anim('base/sprout_base48.png','spins around in place with arms out, greedy and happy, side view','raw/sprout_spin')
