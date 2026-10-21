import sys; sys.path.insert(0,'<ART_KIT>/pixellab'); import pl
from PIL import Image, ImageDraw
pl.LOG='<ANIM_PITCH>/mockups/layouts/pl/calls.log'; floor=int(open('floor.txt').read())
W,H=96,11
im=Image.new('RGBA',(W,H),(0,0,0,0)); d=ImageDraw.Draw(im)
O=(16,14,12,255);G=(232,195,106,255);GH=(255,216,74,255);B=(28,24,20,255);S=(168,120,40,255)
poly=[(3,0),(W-4,0),(W-1,H//2),(W-4,H-1),(3,H-1),(0,H//2)]
d.polygon(poly,fill=O)
d.polygon([(4,1),(W-5,1),(W-2,H//2),(W-5,H-2),(4,H-2),(1,H//2)],fill=G)
d.line([(4,1),(W-5,1)],fill=GH); d.line([(4,H-2),(W-5,H-2)],fill=S)
d.polygon([(5,2),(W-6,2),(W-4,H//2),(W-6,H-3),(5,H-3),(3,H//2)],fill=B)
d.point([(5,H//2),(W-6,H//2)],fill=GH)
im.save('init/tag.png')
pl.call('/create-image-pixflux',{'description':'pixel art game UI slim name tag plate, dark walnut center, thin bright gold bevelled rim, pointed ends with gold studs, crypt dungeon style, lit from the upper left, crisp pixels, no anti-aliasing',
 'image_size':{'width':W,'height':H},'no_background':True,'init_image':pl.b64(im),'init_image_strength':400,'text_guidance_scale':8,
 'color_image':pl.b64(pl.palette_img()),'outline':'single color black outline','shading':'basic shading','detail':'medium detail','view':'side','seed':7},'raw/tag',floor)
