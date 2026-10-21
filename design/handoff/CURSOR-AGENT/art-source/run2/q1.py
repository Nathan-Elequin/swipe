import sys,os; sys.path.insert(0,'<ART_KIT>/pixellab'); os.chdir('<ART_KIT>/pixellab/run2')
import pl; pl.LOG='<ART_KIT>/pixellab/run2/calls.log'
from pl import call,b64,palette_img
from PIL import Image
def anim(base,action,prefix,n=4,seed=11):
    return call('/animate-with-text-v3',{'first_frame':b64(base),'action':action,'frame_count':n,'no_background':True,'seed':seed},prefix,0)
anim('base/sprout_base48.png','run cycle, running to the right, arms pumping, legs alternating, side view','raw/sprout_run')
anim('base/sprout_base48.png','reaching forward with both hands and grabbing an item, then pulling it in to the chest, side view facing right','raw/sprout_grab')
anim('base/sprout_base48.png','overhand throw to the right: winds up arm behind head, then throws forward, side view','raw/sprout_throw')
anim('base/nib_base32.png','lantern gently sways on its handle, idle breathing, small body bob','raw/nib_lantern')
anim('base/ogre_base48.png','heavy lumbering run to the right, club raised, side view','raw/ogre_run')
anim('base/wolf_base32.png','fast gallop to the right, leaping strides, legs stretching and gathering','raw/wolf_gallop')
call('/create-image-pixflux',{'description':"swarm of exactly three big angry hornets in a tight triangle, bold black and yellow stripes, big angry red eyes, clear wings, stingers pointing right, flying to the right, dungeon monster game sprite, single color black outline, light from upper left",
 'image_size':{'width':32,'height':32},'no_background':True,'color_image':b64(palette_img()),'text_guidance_scale':9,
 'outline':'single color black outline','shading':'medium shading','detail':'medium detail','view':'side','direction':'east','seed':8},'raw/hornet_still',0)
