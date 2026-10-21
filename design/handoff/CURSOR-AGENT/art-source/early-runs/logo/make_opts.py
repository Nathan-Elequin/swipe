import sys; sys.path.insert(0,'<ART_KIT>/pixellab'); sys.path.insert(0,'<ART_KIT>/pixellab/logo')
from clean import *
from compose import compose
import numpy as np
GOLD=(255,216,74,255); INKc=(16,14,12)
def rim(im):
    a=np.array(im); h,w=a.shape[:2]; c=(w-1)/2
    op=a[...,3]>0; ink=op&(np.abs(a[...,:3].astype(int)-INKc).sum(-1)<6)
    for y in range(h):
        for x_ in range(w):
            if op[y,x_] and not ink[y,x_] and (x_-c)+(y-c)<-3:
                nb=[(y+dy,x_+dx) for dy,dx in((1,0),(-1,0),(0,1),(0,-1))]
                if any(0<=p<h and 0<=q<w and (ink[p,q] or not op[p,q]) for p,q in nb): a[y,x_]=GOLD
    return Image.fromarray(a)
A=rim(clean(Image.open('raw/logoA_pixflux_0.png'),target=11,maxcontent=9))
B=clean(Image.open('raw/logoB_pixen_0.png'),target=11,maxcontent=9)
C=Image.open('logo/dotC_hand.png')
for k,d in zip('ABC',(A,B,C)):
    d.save(f'logo/logo_dot_opt{k}.png')
    L=compose(d,k); L.save(f'logo/logo_native_opt{k}.png'); x(L,4).save(f'logo/logo_preview_opt{k}_x4.png'); print(k,L.size)
# combined review
ims=[Image.open('<TITLE_TEASER>/out/logo_native.png')]+[Image.open(f'logo/logo_native_opt{k}.png') for k in 'ABC']
W=max(i.size[0] for i in ims)*4+16; c=Image.new('RGBA',(W,len(ims)*(160+8)+8),(26,22,18,255))
for j,i in enumerate(ims):
    s=x(i,4); c.paste(s,(8,8+j*168),s)
c.save('logo/logo_options_review_x4.png')
