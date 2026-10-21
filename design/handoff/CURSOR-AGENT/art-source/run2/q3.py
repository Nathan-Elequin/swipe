import sys,os,time; sys.path.insert(0,'<ART_KIT>/pixellab'); sys.path.insert(0,'<ART_KIT>/pixellab/run2'); os.chdir('<ART_KIT>/pixellab/run2')
while os.path.exists('/proc/1153560'): time.sleep(10)
import pl; pl.LOG='<ART_KIT>/pixellab/run2/calls.log'
from pl import call,b64
from cf import cleanframe
from PIL import Image
def anim(base,action,prefix,n=4,seed=11,nb=True):
    return call('/animate-with-text-v3',{'first_frame':b64(base),'action':action,'frame_count':n,'no_background':nb,'seed':seed},prefix,0)
# hornet: clean still then animate
call('/create-image-pixflux',{'description':"swarm of exactly three big angry hornets in a tight triangle, bold black and yellow stripes, big angry red eyes, clear wings, stingers pointing right, flying to the right, dungeon monster game sprite, single color black outline, light from upper left",
 'image_size':{'width':32,'height':32},'no_background':True,'color_image':b64(pl.palette_img()),'text_guidance_scale':9,
 'outline':'single color black outline','shading':'medium shading','detail':'medium detail','view':'side','direction':'east','seed':8},'raw/hornet_still',0)
im=cleanframe(Image.open('raw/hornet_still_0.png'),bottom=False); im.save('base/hornet_base32.png')
anim('base/hornet_base32.png','buzzing flight to the right, wings flapping fast, hornets bobbing up and down','raw/hornet_fly')
anim('base/sprout_base64.png','idle breathing, scarf and hood gently flutter, blinks','raw/s64_idle')
anim('base/sprout_base64.png','run cycle, running to the right, arms pumping, legs alternating, side view','raw/s64_run')
anim('base/p1_candle_crop64.png','candle flame flickers and sways, warm light pulses, nothing else moves','raw/p1_candle',nb=False)
anim('base/p3_seal_crop64.png','a small gold glint sparkle sweeps across the red wax seal, nothing else moves','raw/p3_seal',nb=False)
anim('base/sprout_base48.png','spins around in place with arms out, greedy and happy, side view','raw/sprout_spin')
anim('base/nib_base32.png','waves goodbye with the free hand while holding the lantern','raw/nib_wave')
anim('base/sprout_base64.png','reaching forward with both arms to grab an item, then pulling it to the chest, side view facing right','raw/s64_grab')
anim('base/sprout_base64.png','overhand throw to the right, arm winds up behind head then throws forward, side view','raw/s64_throw')
anim('base/pocketwatch_32.png','gentle floating bob with a gold glint sparkle','raw/pocketwatch_glint')
anim('base/grimoire_32.png','gentle floating bob with a gold glint sparkle','raw/grimoire_glint')
anim('base/s64/sprout_design_views_f1_native64.png','idle breathing, blinks, scarf flutters','raw/s64_34_idle')
anim('base/sprout_base48.png','jumps up happily and lands, side view facing right','raw/sprout_jump')
anim('base/ogre_base48.png','heavy club swing attack to the right','raw/ogre_swing')
