# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import os,sys; sys.path.insert(0,os.path.join(os.path.dirname(os.path.abspath(__file__)),".."))
from lib import *
import functools; print=functools.partial(print,flush=True)
def bf(desc,w,h,prefix,seed,style,ss=30,init=None,init_s=200):
    p={'description':desc,'image_size':{'width':w,'height':h},'no_background':True,'color_image':b64(palette_img()),'style_image':b64(style),'style_strength':ss,'seed':seed,**STY}
    if init: p['init_image']=b64(init); p['init_image_strength']=init_s
    return call('/create-image-bitforge',p,prefix)
par([J(bf,"dark-red rounded claw badge icon, three bone-white claw rake marks on top, empty dark centre for a number, 1px dark outline, game UI icon",16,16,'test_claw16',3,'base/style_16.png'),
     J(bf,"round brass stamp ring icon, empty transparent middle, 1px dark outline, game UI icon",12,12,'test_token12',3,'base/style_12.png')],2)
