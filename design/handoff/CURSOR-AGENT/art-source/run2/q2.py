import sys,os,time; sys.path.insert(0,'<ART_KIT>/pixellab'); os.chdir('<ART_KIT>/pixellab/run2')
while os.path.exists('/proc/1145441'): time.sleep(10)
import pl; pl.LOG='<ART_KIT>/pixellab/run2/calls.log'
from pl import call,b64
def anim(base,action,prefix,n=4,seed=11):
    return call('/animate-with-text-v3',{'first_frame':b64(base),'action':action,'frame_count':n,'no_background':True,'seed':seed},prefix,0)
anim('base/sprout_base48.png','big reach: leans forward and stretches both arms far out to the right to snatch a floating item, then clutches it to his chest','raw/sprout_grab_r2',seed=23)
