from pl import *
import re,glob
for d in sorted(glob.glob('../1[4-9]_*')+glob.glob('../2[01]_*')):
    id=re.sub(r'^\.\./\d+_PIXELLAB_item_','',d)
    P=open(d+'/README.md').read().split('```')[1].strip()
    call('/create-image-pixflux',{'description':P,'image_size':{'width':32,'height':32},'no_background':True,
     'init_image':b64(f'refs/{id}_32.png'),'init_image_strength':180,'text_guidance_scale':8,
     'color_image':b64(palette_img()),'outline':'single color black outline','shading':'medium shading','detail':'medium detail','view':'side','seed':21},f'raw/pf180_{id}',22)
