import sys,numpy as np
sys.path.insert(0,'<TITLE_TEASER>/gen')
import logo as L
from PIL import Image
def base():
    gl=[L.g_S(),L.g_p(bowl=True),L.g_i(dot=False),L.g_n(),L.g_n(True),L.g_e(),L.g_r(),L.g_i(),L.g_t(),L.g_a(),L.g_n(),L.g_c(),L.g_e()]
    face,offs,W=L.render(gl); out=L.shade(face,W)
    L.coin(out,W-8,4); L.coin(out,W-14,0)
    return out,offs
def compose(dot, name):
    out,offs=base()
    x,dy,w=offs[2]
    d=np.array(dot.convert('RGBA')); h,ww=d.shape[:2]
    cx=x+2; bottom=L.XT-2+dy
    L.paste(out,d,cx-ww//2,bottom-h+1)
    cols=np.nonzero(out[:,:,3].any(0))[0]; out=out[:,cols[0]:cols[-1]+1]
    im=Image.fromarray(out,'RGBA'); return im
if __name__=='__main__':
    out,offs=base(); cols=np.nonzero(out[:,:,3].any(0))[0]
    Image.fromarray(out[:,cols[0]:cols[-1]+1],'RGBA').save('logo/logo_base_plain_p_nodot.png')
    print(out.shape, offs[2])
