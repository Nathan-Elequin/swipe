from lib3 import *
import functools; print=functools.partial(print,flush=True)
cols=['#'+l.strip() for l in open('<ART_KIT>/_reference/refs/spinheritance.hex') if l.strip()]
D=("hero shot of Sprout, a plucky young goblin-green adventurer with big pointed ears, wearing a teal hood and long teal cloak, red scarf, brown leather tunic and boots, a small sack on the hip, "
   "standing confidently facing right in a heroic three-quarter pose, holding up a shining gold coin, full body, same character as the style image, crisp 1px dark outline, light from upper left, no anti-aliasing")
call('/create-image-pro-flash',{'description':D,'image_size':{'width':128,'height':128},'no_background':True,'style_image':{'image':b64('base/sprout64.png'),'size':{'width':64,'height':64},'usage_description':'this is Sprout, the exact character to draw; copy his design, colours and pixel style'},
 'style_options':{'color_palette':False,'outline':True,'detail':True,'shading':True},'target_palette':{'colors':cols},'seed':7},'hero128')
