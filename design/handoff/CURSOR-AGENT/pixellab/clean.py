# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import sys,numpy as np
import os; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from common import PAL,snap_idx,mode_cells,despeckle
from PIL import Image
INK=0  # index of 100e0c
DARKS={0,1,2,3}
def N4(m):
    o=np.zeros(m.shape,int)
    o[1:]+=m[:-1];o[:-1]+=m[1:];o[:,1:]+=m[:,:-1];o[:,:-1]+=m[:,1:];return o
def N8(m):
    o=N4(m).copy()
    o[1:,1:]+=m[:-1,:-1];o[:-1,:-1]+=m[1:,1:];o[1:,:-1]+=m[:-1,1:];o[:-1,1:]+=m[1:,:-1];return o
def components(mask):
    H,W=mask.shape;lab=np.zeros((H,W),int);n=0;sizes={}
    for y in range(H):
        for x in range(W):
            if mask[y,x] and not lab[y,x]:
                n+=1;st=[(y,x)];lab[y,x]=n;c=0
                while st:
                    a,b=st.pop();c+=1
                    for da,db in((1,0),(-1,0),(0,1),(0,-1),(1,1),(-1,-1),(1,-1),(-1,1)):
                        p,q=a+da,b+db
                        if 0<=p<H and 0<=q<W and mask[p,q] and not lab[p,q]: lab[p,q]=n;st.append((p,q))
                sizes[n]=c
    return lab,sizes
def clean(im,target=24,maxcontent=None,outline=True):
    a=np.array(im.convert('RGBA'))
    op=a[...,3]>=128
    idx=snap_idx(a[...,:3],PAL); idx[~op]=-1
    # drop tiny islands
    lab,sz=components(op)
    if sz:
        big=max(sz,key=sz.get)
        for k,s in sz.items():
            if s<6 and k!=big: idx[lab==k]=-1
    op=idx>=0
    # crop
    ys,xs=np.nonzero(op); idx=idx[ys.min():ys.max()+1,xs.min():xs.max()+1]; op=idx>=0
    mc=maxcontent or (target-2 if outline else target)
    h,w=idx.shape
    if max(h,w)>mc:
        s=max(h,w)/mc; W2,H2=max(1,round(w/s)),max(1,round(h/s))
        idx=mode_cells(idx,s,W2,H2,ignore=-1,minfrac=0.5); op=idx>=0
    # interior despeckle (only fully-interior pixels)
    # remove pixel orphans (no 4-neighbour opaque)
    orphan=op&(N4(op)==0); idx[orphan]=-1; op=idx>=0
    if outline:
        # pad then: boundary darks -> ink; remove redundant outer ink; add ink ring where missing
        idx=np.pad(idx,1,constant_values=-1); op=idx>=0
        edge=op&(N4(~op)>0)
        isdark=np.isin(idx,list(DARKS))
        idx[edge&isdark]=INK
        ink=idx==INK; body=op&~ink
        # ink not touching body (8-neigh) is redundant
        red=ink&(N8(body)==0); idx[red]=-1; op=idx>=0; body=op&(idx!=INK)
        ring=(~op)&(N4(body)>0)
        idx[ring]=INK; op=idx>=0
    # place on target canvas, bottom-centered-ish (centered)
    h,w=idx.shape
    if max(h,w)>target:
        s=max(h,w)/target; idx=mode_cells(idx,s,round(w/s),round(h/s),ignore=-1); h,w=idx.shape
    can=np.full((target,target),-1); y0=(target-h)//2; x0=(target-w)//2
    can[y0:y0+h,x0:x0+w]=idx
    out=np.zeros((target,target,4),np.uint8)
    m=can>=0; out[m,:3]=PAL[can[m]].astype(np.uint8); out[m,3]=255
    return Image.fromarray(out,'RGBA')
def x(im,k): return im.resize((im.size[0]*k,im.size[1]*k),Image.NEAREST)
