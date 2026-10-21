from pl import *
import os,time
LP=open('../13_PIXELLAB_logo_wheel_dot/README.md').read().split('```')[1].strip()
call('/create-image-bitforge',{'description':"shaggy grey-blue dire wolf monster, huge toothy grin, glowing yellow eyes, scarred ear, rusty iron collar with a broken chain link, heavy clawed paws, running, side view facing right, dark fantasy dungeon game sprite, single color black outline, light from upper left",
 'image_size':{'width':32,'height':32},'no_background':True,'style_image':b64('../cleanup-all/mon_goblin_f0_native32.png'),'style_strength':50,
 'color_image':b64(palette_img()),'outline':'single color black outline','shading':'medium shading','detail':'medium detail','view':'side','direction':'east','seed':5},'raw/wolf_bitforge',20)
call('/create-image-bitforge',{'description':"the same small adventurer in a teal hood with goblin-green skin, red scarf, brown tunic and boots, side view facing right, reaching forward with both arms to grab something, game sprite, single color black outline, light from upper left",
 'image_size':{'width':48,'height':48},'no_background':True,'style_image':b64('../cleanup-all/sprout_design_views_f2_native48.png'),'style_strength':70,
 'init_image':b64('../cleanup-all/sprout_design_views_f2_native48.png'),'init_image_strength':120,
 'color_image':b64(palette_img()),'outline':'single color black outline','shading':'medium shading','detail':'medium detail','view':'side','direction':'east','seed':9},'raw/sprout_bitforge',20)
call('/create-image-pixflux',{'description':LP,'image_size':{'width':32,'height':32},'no_background':True,'init_image':b64('logo/sketch_32.png'),'init_image_strength':200,
 'color_image':b64(palette_img()),'outline':'single color black outline','shading':'medium shading','detail':'low detail','view':'high top-down','seed':3},'raw/logoA_pixflux',20)
call('/create-image-pixen',{'description':LP,'image_size':{'width':16,'height':16},'no_background':True,'outline':'single color black outline','detail':'low detail','view':'high top-down','seed':4},'raw/logoB_pixen',20)
