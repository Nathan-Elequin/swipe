# Sanitized copy for the Cursor handoff (from art-kit/pixellab/run4). Token is read ONLY from env PIXELLAB_API_TOKEN.
import os
import sys,os,json,numpy as np; sys.path.insert(0,os.path.dirname(os.path.abspath(__file__)))
from clean4 import *; from mons import *
from PIL import Image
CH=json.load(open('pchoice.json')) if os.path.exists('pchoice.json') else {}
os.makedirs('work/pb',exist_ok=True); os.makedirs('work/crop',exist_ok=True)
CENTER={'leech_league','gelatinous_cube','amalgam'}
def crop_close(b,cv,k=''):
    a=np.array(b)[...,3]>0; ys,xs=np.where(a); y0,y1=ys.min(),ys.max(); x0,x1=xs.min(),xs.max(); S=b.size[0]
    if k in CENTER:
        ii=np.pad(a.astype(int),((1,0),(1,0))).cumsum(0).cumsum(1); best=(-1,0,0)
        for y in range(0,S-cv+1):
            for x in range(0,S-cv+1):
                v=ii[y+cv,x+cv]-ii[y,x+cv]-ii[y+cv,x]+ii[y,x]
                if v>best[0]: best=(v,x,y)
        x,y=best[1],best[2]
    elif (x1-x0)>1.2*(y1-y0):   # wide body facing right: head is top-right
        right=a[:,x1-cv//2:x1+1]; ry=np.where(right.any(1))[0]
        x=int(np.clip(x1+2-cv,0,S-cv)); y=int(np.clip(ry.min()-2,0,S-cv))
    else:
        top=a[y0:y0+max(4,int((y1-y0)*0.35))]; cx=int(np.where(top)[1].mean())
        x=int(np.clip(cx-cv//2,0,S-cv)); y=int(np.clip(y0-1,0,S-cv))
    c=b.crop((x,y,x+cv,y+cv)); return c
def run(ids=None):
    for k,(cv,n,act,desc,ref) in M.items():
        if ids and k not in ids: continue
        raw=CH.get(k,{}).get('raw',f'pb_{k}_s31' if os.path.exists(f'raw/pb_{k}_s31_0.png') else f'pb_{k}_s11')
        p=f'raw/{raw}_0.png'
        if not os.path.exists(p): continue
        b=clean(Image.open(p)); 
        if CH.get(k,{}).get('mirror'): b=b.transpose(Image.FLIP_LEFT_RIGHT)
        S=BASE[cv]; b=fit(b,S,S,True); b.save(f'work/pb/{k}.png')
        crop_close(b,cv,k).save(f'work/crop/{k}.png')
if __name__=='__main__': run(sys.argv[1].split(',') if len(sys.argv)>1 else None)
