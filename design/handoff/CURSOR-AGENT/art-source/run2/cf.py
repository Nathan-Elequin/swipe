import sys,numpy as np
sys.path.insert(0,'<ART_KIT>/cleanup-test'); sys.path.insert(0,'<ART_KIT>/pixellab')
from common import *
from clean import components,N4
from PIL import Image
EXTRA=['7a6aa8','4a3a78','2e2450','aaa2c6','766e9a','4a446a','3e8ea8','7a9af0','633f2b','8c5228']
PALX=np.vstack([PAL,np.array([hex2rgb(h) for h in EXTRA],float)]); HEXX=PAL_HEX+EXTRA
OUT=HEXX.index('100e0c'); DARKS=[HEXX.index(h) for h in ('100e0c','1c1814','1a1210','0b0706','0c0e16')]
def cleanframe(im,bottom=True,outline=True):
    a=np.array(im.convert('RGBA')); N=a.shape[0]
    op=a[...,3]>=128; idx=snap_idx(a[...,:3].astype(float),PALX); idx[~op]=-1
    lab,sz=components(op)
    if sz:
        big=max(sz,key=sz.get)
        for k,s in sz.items():
            if s<6 and k!=big: idx[lab==k]=-1
    op=idx>=0; idx[op&(N4(op)==0)]=-1; op=idx>=0
    if outline:
        body=op&~np.isin(idx,DARKS); ring=(~op)&(N4(body)>0); idx[ring]=OUT
    op=idx>=0
    if bottom and op.any():
        sh=idx.shape[0]-1-np.where(op.any(1))[0].max()
        if sh>0: idx=np.roll(idx,sh,0); idx[:sh]=-1
    out=np.zeros(a.shape,np.uint8); m=idx>=0; out[m,:3]=PALX[idx[m]].astype(np.uint8); out[m,3]=255
    return Image.fromarray(out)
