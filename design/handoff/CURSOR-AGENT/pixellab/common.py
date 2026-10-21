# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import numpy as np, os, sys
sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from paths import PALETTE_HEX
from PIL import Image
PAL_HEX=[l.strip() for l in open(PALETTE_HEX) if l.strip()]
def hex2rgb(h): return tuple(int(h[i:i+2],16) for i in (0,2,4))
PAL=np.array([hex2rgb(h) for h in PAL_HEX],dtype=float)
def to_lab(rgb):
    c=rgb/255.0; c=np.where(c>0.04045,((c+0.055)/1.055)**2.4,c/12.92)
    M=np.array([[0.4124,0.3576,0.1805],[0.2126,0.7152,0.0722],[0.0193,0.1192,0.9505]])
    xyz=c@M.T/np.array([0.9505,1.0,1.089])
    f=np.where(xyz>0.008856,np.cbrt(xyz),7.787*xyz+16/116)
    return np.stack([116*f[...,1]-16,500*(f[...,0]-f[...,1]),200*(f[...,1]-f[...,2])],-1)
def snap_idx(rgb,pal):
    lab=to_lab(rgb.reshape(-1,3).astype(float)); pl=to_lab(pal)
    out=np.empty(len(lab),dtype=np.int32)
    for s in range(0,len(lab),200000):
        d=((lab[s:s+200000,None,:]-pl[None])**2).sum(-1); out[s:s+200000]=d.argmin(1)
    return out.reshape(rgb.shape[:2])
def mode_cells(idx,cell,W,H,ox=0.0,oy=0.0,ignore=-1,minfrac=0.5):
    out=np.full((H,W),ignore,dtype=np.int32)
    for y in range(H):
        y0=int(round(oy+y*cell)); y1=max(y0+1,int(round(oy+(y+1)*cell)))
        # use inner core of the cell to avoid edge bleed
        m=max(0,int((y1-y0)*0.2)); yy0,yy1=y0+m,y1-m if y1-m>y0+m else y1
        for x in range(W):
            x0=int(round(ox+x*cell)); x1=max(x0+1,int(round(ox+(x+1)*cell)))
            n=max(0,int((x1-x0)*0.2)); xx0,xx1=x0+n,x1-n if x1-n>x0+n else x1
            c=idx[yy0:yy1,xx0:xx1].ravel()
            if c.size==0: continue
            v,cnt=np.unique(c,return_counts=True)
            if ignore in v and ignore!=-99:
                k=list(v).index(ignore)
                if cnt[k]>=c.size*minfrac: out[y,x]=ignore; continue
                cnt=cnt.copy(); cnt[k]=0
            out[y,x]=v[cnt.argmax()]
    return out
def despeckle(idx,ignore=None):
    # replace pixels whose 4 neighbours all differ from it and agree (>=3) on another value
    H,W=idx.shape; o=idx.copy(); n=0
    for y in range(1,H-1):
        for x in range(1,W-1):
            v=idx[y,x]; nb=[idx[y-1,x],idx[y+1,x],idx[y,x-1],idx[y,x+1]]
            if v in nb: continue
            vals,c=np.unique(nb,return_counts=True)
            if c.max()>=3: o[y,x]=vals[c.argmax()]; n+=1
    return o,n
