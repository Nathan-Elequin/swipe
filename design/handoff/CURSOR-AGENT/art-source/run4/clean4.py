import sys,numpy as np
sys.path.insert(0,'<ART_KIT>/cleanup-test'); sys.path.insert(0,'<ART_KIT>/pixellab')
from common import PAL_HEX,hex2rgb,snap_idx
from clean import components,N4
from PIL import Image
PURP=['aaa2c6','7a6aa8','766e9a','4a446a','4a3a78','2e2450']
HEX=PAL_HEX+['8b1e1e','6a1c14','e07a7a','8dcb8d','d4894e','f4f7fb','ffe6a8']+PURP
PAL=np.array([hex2rgb(h) for h in HEX],float)
OUTI=HEX.index('100e0c'); DARK=[i for i,h in enumerate(HEX) if sum(int(h[j:j+2],16) for j in (0,2,4))<90]
def _idx(im):
    a=np.array(im.convert('RGBA')); op=a[...,3]>=128
    idx=snap_idx(a[...,:3].astype(float),PAL); idx[~op]=-1; return idx
def _img(idx):
    out=np.zeros(idx.shape+(4,),np.uint8); m=idx>=0; out[m,:3]=PAL[idx[m]].astype(np.uint8); out[m,3]=255; return Image.fromarray(out)
def down(im,f):
    """f x f cell mode downsample (alpha majority), palette indices"""
    if f==1: return im
    idx=_idx(im); H,W=idx.shape; h,w=H//f,W//f; o=np.full((h,w),-1)
    for y in range(h):
        for x in range(w):
            c=idx[y*f:(y+1)*f,x*f:(x+1)*f].ravel(); op=c[c>=0]
            if op.size*2<c.size: continue
            v,n=np.unique(op,return_counts=True)
            # prefer outline if it is present in a meaningful share (keeps edges crisp)
            o[y,x]=v[n.argmax()]
    return _img(o)
def clean(im,bottom=False,outline=True,minblob=4,ring_dark=True):
    idx=_idx(im); op=idx>=0
    lab,sz=components(op)
    if sz:
        big=max(sz,key=sz.get)
        for k,s in sz.items():
            if s<minblob and k!=big: idx[lab==k]=-1
    op=idx>=0; idx[op&(N4(op)==0)]=-1; op=idx>=0
    if outline:
        H,W=idx.shape; edge_ok=np.ones_like(op)
        body=op&~np.isin(idx,DARK); ring=(~op)&(N4(body)>0); idx[ring]=OUTI
        if ring_dark:  # opaque dark pixels on the silhouette edge -> outline colour
            op=idx>=0; p=np.pad(op,1); nb=~(p[:-2,1:-1]&p[2:,1:-1]&p[1:-1,:-2]&p[1:-1,2:])
            idx[op&nb&np.isin(idx,DARK)]=OUTI
    op=idx>=0
    if bottom and op.any():
        sh=idx.shape[0]-1-np.where(op.any(1))[0].max()
        if sh>0: idx=np.roll(idx,sh,0); idx[:sh]=-1
    return _img(idx)
def up(im,f): return im.resize((im.size[0]*f,im.size[1]*f),Image.NEAREST)
def fit(im,W,H,bottom=True):
    bb=im.getbbox(); o=Image.new('RGBA',(W,H))
    if not bb: return o
    c=im.crop(bb)
    if c.size[0]>W or c.size[1]>H: c=c.crop((0,0,min(W,c.size[0]),min(H,c.size[1])))
    o.paste(c,((W-c.size[0])//2,(H-c.size[1]) if bottom else (H-c.size[1])//2),c); return o
